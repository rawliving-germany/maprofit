require 'awesome_print'

module Maprofit::Magento
  class Factory

    def self.invoices_between start_date, end_date, calculation_conf=nil, &block
      invoices_sql = Maprofit::Magento::SQL.sales_invoice_between start_date, end_date
      invoices_sql.each do |invoice_sql|
        puts " a invoice"
        invoice = invoice_from_sql_result invoice_sql

        items_for_order(invoice_sql['order_id']).each do |item|
          invoice.add_item item
        end
        yield invoice
      end
    end

    def self.invoice invoice_nr, calculation_conf=nil
      invoice_sql = Maprofit::Magento::SQL.sales_invoice invoice_nr
      invoice_sql = invoice_sql.first

      invoice = invoice_from_sql_result invoice_sql

      items_for_order(invoice_sql['order_id']).each do |item|
        invoice.add_item item
      end

      invoice
    end

    def self.items_for_invoice invoice_nr
      # Fetch EK attr
      invoice = Maprofit::Magento::SQL.sales_invoice invoice_nr
      #ap invoice.first
      items_for_order invoice.first['order_id']
    end

    def self.items_for_order order_id
      items = Maprofit::Magento::SQL.sales_invoice_items_for order_id

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

          msgs << '(eknetto)'
          bought_for_netto = eknetto_db * item_sql['qty'].to_f
        else
          bought_for_netto = bought_for_netto.to_f * item_sql['qty'].to_f

          if Maprofit::calculation_conf&.rate_gbp_eur
            bought_for_netto *= Maprofit::calculation_conf.rate_gbp_eur.to_f
          end
          msgs << 'price scaled from gbp'
          msgs << item_sql['base_cost'].to_f
        end

        #ap item

        item = Item.new(
          bought_for_netto: bought_for_netto,
          sold_for_netto:  item_sql['base_row_total'].to_f,
          sold_for_brutto: item_sql['base_row_total_incl_tax'].to_f,
          name:            item_sql['name'],
          msgs:            msgs
        )
        item
      end
    end

    def self.invoice_from_sql_result invoice_sql
      Maprofit::Magento::Invoice.new(
        shipping_costs_netto: invoice_sql['base_shipping_incl_tax'].to_f,
        grand_total:          invoice_sql['base_grand_total'].to_f,
        date:                 invoice_sql['created_at'],
        invoice_id:           invoice_sql['entity_id'],
        invoice_nr:           invoice_sql['increment_id']
      )
    end
  end
end
