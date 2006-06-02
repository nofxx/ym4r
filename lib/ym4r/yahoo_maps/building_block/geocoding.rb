require 'ym4r/yahoo_maps/app_id'
require 'ym4r/yahoo_maps/building_block/exception'
require 'open-uri'
require 'rexml/document'

module Ym4r
  module YahooMaps
    module BuildingBlock
      module Geocoding
        #Sends a request to the Yahoo! Maps geocoding service and returns the result in an easy to use Ruby object, hiding the creation of the query string and the XML parsing of the answer.
        def self.get(param)
          unless param.has_key?(:street) or
              param.has_key?(:city) or
              param.has_key?(:state) or
              param.has_key?(:zip) or
              param.has_key?(:location)
            raise MissingParameterException.new("Missing location data for the Yahoo! Maps Geocoding service")
          end
          
          url = "http://api.local.yahoo.com/MapsService/V1/geocode?appid=#{Ym4r::YahooMaps::APP_ID}&"
          url << "street=#{param[:street]}&" if param.has_key?(:street)
          url << "city=#{param[:city]}&" if param.has_key?(:city)
          url << "state=#{param[:state]}&" if param.has_key?(:state)
          url << "zip=#{param[:zip]}&" if param.has_key?(:zip)
          url << "location=#{param[:location]}&" if param.has_key?(:location)
          url << "output=xml"
          
          begin
            xml = open(URI.encode(url)).read
          rescue OpenURI::HTTPError => error
            raise BadRequestException.new(error.to_s)
          rescue
            raise ConnectionException.new("Unable to connect to Yahoo! Maps Geocoding service")
          end
          
          doc = REXML::Document.new(xml) 
          
          if doc.root.name == "Error"
            raise RateLimitExceededException.new("Rate limit exceeded for Yahoo! Maps Geocoding service")
          else
            results = []
            doc.elements.each("//Result") do |result|
              data = result.elements
              results << Geocoding::Result.new(result.attributes['precision'],
                                               result.attributes['warning'],
                                               data['Latitude'].text.to_f,
                                               data['Longitude'].text.to_f,
                                               data['Address'].text,
                                               data['City'].text,
                                               data['State'].text,
                                               data['Zip'].text,
                                               data['Country'].text)
            end
            results
          end
        end
        
        #Contains a result match from the Yahoo! Maps geocoding service. 
        class Result < Struct.new(:precision,:warning,:latitude,:longitude,:address,:city,:state,:zip,:country)
          
          #Convenience method for the lazy.
          def latlon
            [latitude,longitude]
          end
        
          #Convenience method for the lazy.
          def lonlat
            [longitude,latitude]
          end
        
          #Indicates if the location passed in the request could be exactly identified.
          def exact_match?
            warning.nil?
          end
          
        end
        
      end #Geocoding
    end #BuildingBlock
  end
end #Ym4r
