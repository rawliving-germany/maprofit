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
  end
end
