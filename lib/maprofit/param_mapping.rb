module Maprofit
  module ParamMapping
    def self.calculation_conf params
      calculation_conf = Maprofit::calculation_conf

      if !params.key?('ignore_zero_cost')
        calculation_conf.ignore_zero_cost = false
      else
        calculation_conf.ignore_zero_cost = true
      end
      if params.key?('rate_gbp_eur')
        calculation_conf.rate_gbp_eur = params['rate_gbp_eur']
      end
      if params.key?('free_shipping_penalty')
        calculation_conf.free_shipping_penalty = params['free_shipping_penalty']
      end
      if params.key?('start_date')
        calculation_conf.start_date = params['start_date']
      end
      if params.key?('end_date')
        calculation_conf.end_date = params['end_date']
      end

      calculation_conf
    end
  end
end
