require 'ym4r/google_maps/api_key'
require 'open-uri'
require 'rexml/document'

module Ym4r
  module GoogleMaps
    module Geocoding

      GEO_SUCCESS = 200
      GEO_MISSING_ADDRESS = 601
      GEO_UNKNOWN_ADDRESS = 602
      GEO_UNAVAILABLE_ADDRESS = 603
      GEO_BAD_KEY = 610
      GEO_TOO_MANY_QUERIES = 620
      GEO_SERVER_ERROR = 500
      
      #Gets placemarks by querying the Google Maps Geocoding service with the +request+ string
      def self.get(request)
        
        url = "http://maps.google.com/maps/geo?q=#{request}&key=#{API_KEY}&output=xml"
        begin
          xml = open(URI.encode(url)).read
        rescue
          raise ConnectionException.new("Unable to connect to Google Maps Geocoding service")
        end
        
        doc = REXML::Document.new(xml) 
                        
        response = doc.elements['//Response']
        placemarks = Placemarks.new(response.elements['name'].text,response.elements['Status/code'].text.to_i)
        response.elements.each("Placemark") do |placemark|
          data = placemark.elements
          data_country = data['//CountryNameCode']
          data_administrative = data['//AdministrativeAreaName']
          data_sub_administrative = data['//SubAdministrativeAreaName']
          data_locality = data['//LocalityName']
          data_dependent_locality = data['//DependentLocalityName']
          data_thoroughfare = data['//ThoroughfareName']
          data_postal_code = data['//PostalCodeNumber']
          placemarks << Geocoding::Placemark.new(data['address'].text,
                                                 data_country.nil? ? "" : data_country.text,
                                                 data_administrative.nil? ? "" : data_administrative.text,
                                                 data_sub_administrative.nil? ? "" : data_sub_administrative.text,
                                                 data_locality.nil? ? "" : data_locality.text,
                                                 data_dependent_locality.nil? ? "" : data_dependent_locality.text,
                                                 data_thoroughfare.nil? ? "" : data_thoroughfare.text,
                                                 data_postal_code.nil? ? "" : data_postal_code.text,
                                                 *(data['//coordinates'].text.split(",")[0..1].collect {|l| l.to_f }))
        end
        placemarks
      end

      #Group of placemarks returned by the Geocoding service. If the result is valid the +statius+ attribute should be equal to <tt>Geocoding::GEI_SUCCESS</tt>
      class Placemarks < Array
        attr_accessor :name,:status

        def initialize(name,status)
          super(0)
          @name = name
          @status = status
        end
      end

      #A result from the Geocoding service.
      class Placemark < Struct.new(:address,:country_code,:administrative_area,:sub_administrative_area,:locality,:dependent_locality,:thoroughfare,:postal_code,:longitude,:latitude)
        def lonlat
          [longitude,latitude]
        end

        def latlon
          [latitude,longitude]
        end
      end
    
      #Raised when the connection to the service is not possible
      class ConnectionException < StandardError
      end
    end
  end
end
