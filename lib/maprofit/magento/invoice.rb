require 'attr_extras'

module Maprofit::Magento
  class Invoice
    attr_reader :items
    rattr_initialize [:shipping_costs_netto, :msgs, :grand_total, :invoice_id, :date, :invoice_nr]

    def add_item item
      (@items ||= []) << item
    end

    #def item id
    #  @items.select {}
    #end
  end
end

