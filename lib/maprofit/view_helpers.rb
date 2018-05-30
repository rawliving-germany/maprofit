require 'date'

module Maprofit
  module ViewHelpers
    # def labelize(string)
    #   Inflecto.humanize(Inflecto.underscore(string.to_s)).capitalize
    # end

    def hello
      "hello helper"
    end

    def euro number
      return "-" if number.nil?
      "%.2f €" % number
    end

    def magento_admin_url_for further_path
      Maprofit::magento_conf.magento_admin_url + further_path
    end

    def date d
      #DateTime.parse(d).strftime("%Y-%m-%d %a %H:%M")
      d.strftime("%Y-%m-%d %a %H:%M")
    end
  end
end
