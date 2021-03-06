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
  if Maprofit::app_conf.basic_auth_pass && Maprofit::app_conf.basic_auth_user
    plugin :basic_auth, authenticator: proc {|user, pass| user == Maprofit::app_conf.basic_auth_user && pass == Maprofit::app_conf.basic_auth_pass  }, realm: 'maprof'
  else
    STDERR.puts "Basic auth not configured"
  end
  # plugin :static, ['/uploads'] if APP_ENV == "development"
  plugin :public, root: 'lib/maprofit/public/'
  plugin :partials, views: 'lib/maprofit/views/'
  plugin :streaming

  include Maprofit::RodaUtils
  include Maprofit::ViewHelpers

  route do |r|
    r.assets
    r.public
    r.basic_auth

    r.root {
      view 'index'
    }

    r.on("orders") {
      # /orders/today
      @calculation_conf = Maprofit::ParamMapping::calculation_conf(r.params)
      r.get "today" do
        @invoices = []
        Maprofit::Magento::OrderFactory.orders_between(Date.today.strftime("%Y-%m-%d"), (Date.today + 1).strftime("%Y-%m-%d")) {|i| @invoices << i}
        view 'invoices'
      end
      r.is do
        @invoices = []
        Maprofit::Magento::OrderFactory.orders_between(@calculation_conf.start_date, @calculation_conf.end_date) {|i| @invoices << i}
        view 'invoices'
      end
    }
    r.on("order") {
      # /order/ORDERID (entity_id)
      @calculation_conf = Maprofit::ParamMapping::calculation_conf(r.params)

      r.get String do |order_id|
        @invoice = Maprofit::Magento::OrderFactory.invoice order_id
        view 'invoice'
      end
      r.post String do |order_id|
        @invoice = Maprofit::Magento::OrderFactory.invoice order_id, @calculation_conf
        view 'invoice'
      end
    }

    r.on("invoice") {
      # /invoice/INVOICENR (increment, not entity_id)
      @calculation_conf = Maprofit::ParamMapping::calculation_conf(r.params)

      r.get String do |invoice_nr|
        @invoice = Maprofit::Magento::Factory.invoice invoice_nr
        view 'invoice'
      end
      r.post String do |invoice_nr|
        @invoice = Maprofit::Magento::Factory.invoice invoice_nr, @calculation_conf
        view 'invoice'
      end
    }
    r.on("invoices") {
      @calculation_conf = Maprofit::ParamMapping::calculation_conf(r.params)

      # POST/GET /invoices
      r.is do
        @invoices = []
        Maprofit::Magento::Factory.invoices_between(@calculation_conf.start_date, @calculation_conf.end_date) {|i| @invoices << i}
        view 'invoices'
      end
      r.get "today" do
        @invoices = []
        Maprofit::Magento::Factory.invoices_between(Date.today.strftime("%Y-%m-%d"), (Date.today + 1).strftime("%Y-%m-%d")) {|i| @invoices << i}
        view 'invoices'
      end
      r.get String do |date|
        stream do |out|
          Maprofit::Magento::Factory.invoices_between('2017-11-12', '2017-11-13') do |invoice|
            @invoice = invoice
            out << partial('invoice_in_list')
          #@invoices.each do |invoice|
          #  out << partial('invoice_in_list')
          #  sleep 2
          #end
          end
        end
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
