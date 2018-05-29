require 'maprofit'

if ENV['MAPROFIT_CONFIG']
  # Load separate configuration file
end

require 'maprofit/app'
run App
