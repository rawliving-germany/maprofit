require "maprofit/version"
require "maprofit/magento/item"
require "maprofit/magento/invoice"
require "maprofit/magento/sql"
require "maprofit/magento/factory"
require "maprofit/calculation_configuration"
require "maprofit/magento_configuration"
require "maprofit/profit_calculation"
require "maprofit/app_configuration"
require "maprofit/param_mapping"

module Maprofit
  @magento_conf = nil
  @calculation_conf = nil
  @app_conf = nil

  def self.load_conf
    if !@magento_conf.nil? && !@calculation_conf.nil? && !@app_conf.nil?
      return { magento_conf: @magento_conf, calculation_conf: @calculation_conf, app_conf: @app_conf}
    end

    conf = YAML.load_file('maprofit.yaml')
    @magento_conf ||= Maprofit::MagentoConfiguration.new(
      dbhost: conf["host"],
      dbport: conf["port"],
      dbname: conf["database"],
      dbuser: conf["username"],
      dbpass: conf["password"],
      eknetto_attr_id:   conf["eknetto_attr_id"],
      magento_admin_url: conf["magento_admin_url"]
    )
    @calculation_conf ||= Maprofit::CalculationConfiguration.new(
      ignore_zero_cost: conf['ignore_zero_cost'],
      rate_gbp_eur:     conf['rate_gbp_eur'],
      free_shipping_penalty: conf['free_shipping_penalty']
    )
    @app_conf ||= Maprofit::AppConfiguration.new(
      basic_auth_pass: conf['basic_auth_pass'],
      basic_auth_user: conf['basic_auth_user']
    )
    return { magento_conf: @magento_conf, calculation_conf: @calculation_conf, app_conf: @app_conf}
    # default params
    # logging
  end

  def self.magento_conf
    @magento_conf ||= load_conf[:magento_conf]
  end

  def self.calculation_conf
    @calculation_conf ||= load_conf[:calculation_conf]
  end

  def self.app_conf
    @app_conf ||= load_conf[:app_conf]
  end
end
