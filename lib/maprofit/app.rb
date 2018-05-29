#require_relative 'config/env'
require_relative 'roda_utils'
require_relative 'view_helpers'

require 'roda'

class App < Roda
  plugin :render, {engine: 'haml', views: 'lib/maprofit/views/'}
  # Later, instead of using public, employ the asset and static plugins
  plugin :assets,
    #js: %w(
    #  vendor/underscore.js
    #  app.js
    #),
    css:  %w(
      style.css
    )
      #vendor/milligram.css
  plugin :not_found
  plugin :multi_route
  plugin :partials
  plugin :all_verbs
  plugin :error_handler
  plugin :basic_auth, authenticator: proc {|_, pass| pass == 'pass' }, realm: 'maprof'
  # plugin :static, ['/uploads'] if APP_ENV == "development"
  plugin :public, root: 'lib/maprofit/public/'

  include Maprofit::RodaUtils
  include Maprofit::ViewHelpers

  route do |r|
    r.assets
    r.public

    r.root {
      view 'index'
    }

    r.on("invoice") {
      # /invoice/INVOICENR (increment, not entity_id)
      r.get String do |invoice_nr|
        @invoice = Maprofit::Magento::Factory.invoice invoice_nr
        view 'invoice'
      end
      r.post String do |invoice_nr|
        @calculation_conf = Maprofit::calculation_conf
        if !r.params.key?('ignore_zero_cost')
          @calculation_conf.ignore_zero_cost = false
        end
        if r.params.key?('rate_gbp_eur')
          @calculation_conf.rate_gbp_eur = r.params['rate_gbp_eur']
        end
        if r.params.key?('free_shipping_penalty')
          @calculation_conf.free_shipping_penalty = r.params['free_shipping_penalty']
        end
        @invoice = Maprofit::Magento::Factory.invoice invoice_nr, @calculation_conf
        view 'invoice'
      end
    }
  end

  not_found do
    view "not_found"
  end

  error do |err|
    case err
    when nil
      # catch a proper error...
    # when CustomError
    #   "ERR" # like so
    else
      raise err
    end
  end
end
