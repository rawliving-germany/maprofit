require 'yaml'
require 'mysql2'

module Maprofit::Magento
  module SQL
    def self.client
      # log puts "client"
      @client ||= make_client
    end

    def self.make_client
      conf = Maprofit::magento_conf
      Mysql2::Client.new(host:     conf.dbhost,
                         port:     conf.dbport,
                         database: conf.dbname,
                         username: conf.dbuser,
                         password: conf.dbpass,
                         reconnect: true)
    end

    def self.sales_order order_id
      query = client.prepare(
        "
        SELECT * FROM sales_order
        WHERE entity_id = ?
        "
      )
      query.execute order_id
    end

    def self.sales_order_items_for order_id
      query = client.prepare(
        "
         SELECT * FROM sales_order_item
         WHERE order_id = ?
        "
      )
      query.execute order_id
    end

    def self.sales_invoice invoice_nr
      query = client.prepare(
        "
         SELECT * FROM sales_invoice
         WHERE increment_id = ?
        "
      )
      query.execute invoice_nr
    end

    def self.sales_invoice_between start_date, end_date
      client.query(
        "
         SELECT * FROM sales_invoice
         WHERE created_at BETWEEN '#{start_date}' AND '#{end_date}'
        "
      )
    end

    def self.sales_order_between start_date, end_date
      client.query(
        "
         SELECT * FROM sales_order
         WHERE created_at BETWEEN '#{start_date}' AND '#{end_date}'
         AND status != 'closed' AND status != 'cancelled'
        "
      )
    end

    def self.sales_invoice_items_for invoice_order_id
      query = client.prepare(
        "
         SELECT * FROM sales_invoice_item
         WHERE order_item_id IN (SELECT item_id FROM sales_order_item
         WHERE order_id = ?)
        "
      )
      query.execute invoice_order_id
    end

    # varchar attribute for product
    def self.eav_attr_for product_id, attr_id
      query = client.prepare(
        "
         SELECT * FROM catalog_product_entity_varchar
         WHERE attribute_id = ?
         AND entity_id = ?
        "
      )
      query.execute attr_id, product_id
    end

  end
end
