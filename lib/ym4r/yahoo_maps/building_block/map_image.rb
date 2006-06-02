require 'ym4r/yahoo_maps/app_id'
require 'ym4r/yahoo_maps/building_block/exception'
require 'open-uri'
require 'rexml/document'

module Ym4r
  module YahooMaps
    module BuildingBlock
      module MapImage
        #Send a request to the Map image API. Gets back a url to an image. This image can be downloaded later.
        def self.get(param)
          unless param.has_key?(:street) or
              param.has_key?(:city) or
              param.has_key?(:state) or
              param.has_key?(:zip) or
              param.has_key?(:location) or
              (param.has_key?(:longitude) and param.has_key?(:latitude))
            raise MissingParameterException.new("Missing location data for the Yahoo! Maps Map Image service")
          end
          
          url = "http://api.local.yahoo.com/MapsService/V1/mapImage?appid=#{Ym4r::YahooMaps::APP_ID}&"
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
          url << "output=xml"
          
          begin
            xml = open(URI.encode(url)).read
          rescue OpenURI::HTTPError => error
            raise BadRequestException.new(error.to_s)
          rescue
            raise ConnectionException.new("Unable to connect to Yahoo! Maps Map Image service")
          end
          
          doc = REXML::Document.new(xml) 
          
          if doc.root.name == "Error"
            raise RateLimitExceededException.new("Rate limit exceeded for Yahoo! Maps Map Image service")
          else
            result = doc.root
            MapImage::Result.new(result.attributes['warning'],
                                 result.text)
          end
        end
        
        #Contains a result match from the Yahoo! Maps Map Image service. 
        class Result < Struct.new(:warning,:url)
          
          #Downloads the image to +file+.
          def download_to(file)
            data = open(url).read
            open(file,"wb") do |f|
              f.write data
            end
          end
          
          #Indicates if the location passed in the request could be exactly identified.
          def exact_match?
            warning.nil?
          end
          
        end
      end #MapImage
    end #BuildingBlock
  end
end #Ym4r
