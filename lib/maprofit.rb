require "maprofit/version"
require "maprofit/magento/item"
require "maprofit/magento/invoice"
require "maprofit/magento/sql"
require "maprofit/magento/factory"
require "maprofit/calculation_configuration"
require "maprofit/magento_configuration"

module Maprofit
  @magento_conf = nil
  @calculation_conf = nil

  def self.load_conf
    if !@magento_conf.nil? && !@calculation_conf.nil?
      return { magento_conf: @magento_conf, calculation_conf: @calculation_conf }
    end
    conf = YAML.load_file('maprofit.yaml')
    @magento_conf ||= Maprofit::MagentoConfiguration.new(
      dbhost: conf["host"],
      dbport: conf["port"],
      dbname: conf["database"],
      dbuser: conf["username"],
      dbpass: conf["password"],
      eknetto_attr_id: conf["eknetto_attr_id"]
    )
    @calculation_conf ||= Maprofit::CalculationConfiguration.new(
      ignore_zero_cost: conf['ignore_zero_cost'],
      rate_gbp_eur:     conf['rate_gbp_eur'],
      free_shipping_penalty: conf['free_shipping_penalty']
    )
    return { magento_conf: @magento_conf, calculation_conf: @calculation_conf }
    # default params
    # db
    # logging
  end

  def self.magento_conf
    @magento_conf ||= load_conf[:magento_conf]
  end

  def self.calculation_conf
    @calculation_conf ||= load_conf[:calculation_conf]
  end
end
