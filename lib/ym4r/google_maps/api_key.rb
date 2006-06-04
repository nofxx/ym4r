require 'yaml'

module Ym4r
  module GoogleMaps
    #The key to be used by the google maps API. It is valid only for the subdiretories of the URL you applied for on this page : http://www.google.com/apis/maps/
    API_KEY = YAML::load_file(File.dirname(__FILE__) + '/config/config.yml')
  end
end
  

    
