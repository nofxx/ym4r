require 'ym4r/app_id'
require 'ym4r/exception'
require 'open-uri'
require 'rexml/document'

module Ym4r
  module BuildingBlock
    module Geocoding
      #Sends a request to the Yahoo! Maps geocoding service and returns the result in an easy to use Ruby object, hiding the creation of the query string and the XML parsing of the answer.
      #Raise a RateLimitExceededException if the limit of 5000 requests in 24 hours from the same IP is exceeded.
      #Raise a ConnectionException if the service is unreachable.
      def self.get(param)
        unless param.has_key?(:street) or
            param.has_key?(:city) or
            param.has_key?(:state) or
            param.has_key?(:zip) or
            param.has_key?(:location)
          raise Ym4r::MissingParameterException.new("Missing location data for the Yahoo! Maps Geocoding service")
        end
        
        url = "http://api.local.yahoo.com/MapsService/V1/geocode?appid=#{Ym4r::APP_ID}&"
        url << "street=#{param[:street]}&" if param.has_key?(:street)
        url << "city=#{param[:city]}&" if param.has_key?(:city)
        url << "state=#{param[:state]}&" if param.has_key?(:state)
        url << "zip=#{param[:zip]}&" if param.has_key?(:zip)
        url << "location=#{param[:location]}&" if param.has_key?(:location)
        url << "output=xml"
        
        begin
          xml = open(URI.encode(url)).read
        rescue OpenURI::HTTPError => error
          raise Ym4r::BadRequestException.new(error.to_s)
        rescue SystemCallError
          raise Ym4r::ConnectionException.new("Unable to connect to Yahoo! Maps Geocoding service")
        end
        
        doc = REXML::Document.new(xml) 
        
        if doc.root.name == "Error"
          raise Ym4r::RateLimitExceededException.new("Rate limit exceeded for Yahoo! Maps Geocoding service")
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
      
        def latlon
          [latitude,longitude]
        end
        
        def lonlat
          [longitude,latitude]
        end
        
        def exact_match?
          warning.nil?
        end
        
      end
      
    end #Geocoding
    
  end #BuildingBlock

end #Ym4r
