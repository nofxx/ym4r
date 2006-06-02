require 'ym4r/yahoo_maps/app_id'
require 'ym4r/yahoo_maps/building_block/exception'
require 'open-uri'
require 'rexml/document'

module Ym4r
  module YahooMaps
    module BuildingBlock
      module Traffic
        #Send a request to the traffic REST API. 
        def self.get(param)
          unless param.has_key?(:street) or
              param.has_key?(:city) or
              param.has_key?(:state) or
              param.has_key?(:zip) or
              param.has_key?(:location) or
              (param.has_key?(:longitude) and param.has_key?(:latitude))
            raise MissingParameterException.new("Missing location data for the Yahoo! Maps Traffic service")
          end
          
          url = "http://api.local.yahoo.com/MapsService/V1/trafficData?appid=#{Ym4r::YahooMaps::APP_ID}&"
          url << "street=#{param[:street]}&" if param.has_key?(:street)
          url << "city=#{param[:city]}&" if param.has_key?(:city)
          url << "state=#{param[:state]}&" if param.has_key?(:state)
          url << "zip=#{param[:zip]}&" if param.has_key?(:zip)
          url << "location=#{param[:location]}&" if param.has_key?(:location)
          url << "latitude=#{param[:latitude]}&" if param.has_key?(:latitude)
          url << "longitude=#{param[:longitude]}&" if param.has_key?(:longitude)
          url << "image_type=#{param[:image_type]}&" if param.has_key?(:image_type) #defaults to PNG
          url << "image_height=#{param[:image_height]}&" if param.has_key?(:image_height) #defaults to 500
          url << "image_width=#{param[:image_width]}&" if param.has_key?(:image_width) #defaults to 620
          url << "zoom=#{param[:zoom]}&" if param.has_key?(:zoom) #defaults to 6
          url << "radius=#{param[:radius]}&" if param.has_key?(:radius)
          url << "include_map=#{param[:include_map]?1:0}&" if param.has_key?(:include_map)
          url << "severity=#{param[:severity]}&" if param.has_key?(:severity)
          url << "output=xml"
          
          begin
            xml = open(URI.encode(url)).read
          rescue OpenURI::HTTPError => error
            raise BadRequestException.new(error.to_s)
          rescue
            raise ConnectionException.new("Unable to connect to Yahoo! Maps Traffic REST service")
          end
          
          doc = REXML::Document.new(xml) 
          
          if doc.root.name == "Error"
            raise RateLimitExceededException.new("Rate limit exceeded for Yahoo! Maps Traffic REST service")
          else
            results = Traffic::ResultSet.new(Time.at(doc.root.elements['LastUpdateDate'].text.to_i),doc.root.elements['Warning'].nil? ? nil : doc.root.elements['Warning'].text)
            
            doc.root.elements.each('//Result') do |result|
              data = result.elements
              results << Traffic::Result.new(result.attributes['type'],
                                             data['Title'].text,
                                             data['Description'].text,
                                             data['Latitude'].text.to_f,
                                             data['Longitude'].text.to_f,
                                             data['Direction'].text,
                                             data['Severity'].text.to_i,
                                             Time.at(data['ReportDate'].text.to_i),
                                             Time.at(data['UpdateDate'].text.to_i),
                                             Time.at(data['EndDate'].text.to_i),
                                             data['ImageUrl'].nil? ? nil : data['ImageUrl'].text)
            end
            results
            
          end
        end
        
        #Contains a list of results from the Yahoo! Maps Traffic REST API
        class ResultSet < Array
          attr_accessor :last_update_date,:warning
          
          def initialize(last_update_date,warning)
            super(0)
            @last_update_date = last_update_date
            @warning = warning
          end
          
          #Indicates if the location passed in the request could be exactly identified.
          def exact_match?
            warning.nil?
          end
        end
        
        #Contains a result from the Yahoo! Maps Traffic REST service. 
        class Result < Struct.new(:type,:title,:description,:latitude,:longitude,:direction,:severity,:report_date,:update_date,:end_date,:image_url)
          
          #Downloads the image (if there is one) to +file+.
          def download_to(file)
            if has_image?
              data = open(image_url).read
              open(file,"wb") do |f|
                f.write data
              end
            end
          end
          
          def has_image?
            ! image_url.nil?
          end
          
          #Convenience method for the lazy.
          def lonlat
            [longitude,latitude]
          end
          
          #Convenience method for the lazy.
          def latlon
            [latitude,longitude]
          end
          
        end
        
      end #Traffic
    end #BuildingBlock
  end
end #Ym4r
