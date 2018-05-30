require 'attr_extras'

module Maprofit::Magento
  class Item
    #attr_initialize :bought_for_netto
    #rattr_initialize [:bought_for_netto, :sold_for_netto, :sold_for_brutto, :tax_class, :discount, :name]
    aattr_initialize [:bought_for_netto, :sold_for_netto, :sold_for_brutto, :tax_class, :discount, :name, :msgs, :qty]

    def profit_netto
      @sold_for_netto - @bought_for_netto
    end

    def profit_netto_percent
      (100 * (@sold_for_netto / @bought_for_netto) - 1.0)
    end
  end
end
