require 'awesome_print'

module Maprofit::Magento
  class OrderFactory < Maprofit::Magento::Factory
    def self.orders_between start_date, end_date, calculation_conf=nil, &block
      invoices = []

      orders_sql = Maprofit::Magento::SQL.sales_order_between start_date, end_date
      orders_sql.each do |order_sql|
        invoice = invoice_from_sql_result order_sql

        order_items_for_order(order_sql['entity_id']).each do |item|
          invoice.add_item item
        end

        yield invoice if block_given?
        invoices << invoice if !block_given?
      end

      return invoices if !block_given?
    end

    def self.order_items_for_order order_id
      items = Maprofit::Magento::SQL.sales_order_items_for order_id

      items.map do |item_sql|
        # Cost defined? If so, its in GBP.
        msgs = []
        if (bought_for_netto = item_sql['base_cost']).nil? || bought_for_netto.to_f == 0.0
          eknetto_db = Maprofit::Magento::SQL.eav_attr_for(item_sql['product_id'],
                                                           Maprofit::magento_conf.eknetto_attr_id)
          if !eknetto_db.to_a.empty?
            eknetto_db = eknetto_db.to_a.first['value'].to_f
          else
            eknetto_db = 0.0
          end

          msgs << "(eknetto #{eknetto_db})"
          bought_for_netto = eknetto_db * item_sql['qty_invoiced'].to_f
        else
          bought_for_netto = bought_for_netto.to_f * item_sql['qty_invoiced'].to_f

          if Maprofit::calculation_conf&.rate_gbp_eur
            bought_for_netto *= Maprofit::calculation_conf.rate_gbp_eur.to_f
          end
          msgs << "(gbp #{item_sql['base_cost'].to_f})"
        end

        item = Item.new(
          bought_for_netto: bought_for_netto,
          sold_for_netto:   item_sql['base_row_total'].to_f,
          sold_for_brutto:  item_sql['base_row_total_incl_tax'].to_f,
          name:             item_sql['name'],
          qty:              item_sql['qty_invoiced'].to_i,
          msgs:             msgs
        )

        if item.profit_netto <= 0
          item.msgs << "LOSS!"
        end
        item
      end
    end

    def self.invoice order_id, calculation_conf=nil
      invoice_sql = Maprofit::Magento::SQL.sales_order order_id

      invoice_sql = invoice_sql.first
      invoice = invoice_from_sql_result invoice_sql

      order_items_for_order(invoice_sql['entity_id']).each do |item|
        invoice.add_item item
      end

      invoice
    end
  end
end
