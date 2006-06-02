require 'yaml'

module Ym4r
  module GoogleMaps
    API_KEY = YAML::load_file(File.dirname(__FILE__) + '/config/config.yml')
  end
end
  

    
