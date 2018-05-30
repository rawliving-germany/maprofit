module Maprofit
  class ProfitCalculation
    def calculate invoice
      profit = invoice.items.inject(0.0) do |sum, item|
        if item.bought_for_netto.to_f != 0
          sum + item.profit_netto
        else
          sum
        end
      end

      if invoice.shipping_costs_netto.to_f == 0.0
        profit -= Maprofit::calculation_conf.free_shipping_penalty.to_f
      end

      profit
    end
  end
end
