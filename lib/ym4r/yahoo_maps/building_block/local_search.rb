require 'ym4r/yahoo_maps/app_id'
require 'ym4r/yahoo_maps/building_block/exception'
require 'open-uri'
require 'rexml/document'

module Ym4r
  module YahooMaps
    module BuildingBlock
      module LocalSearch
        #Send a request to the local search REST API V3. 
        def self.get(param)
          
          unless param.has_key?(:street) or
              param.has_key?(:city) or
              param.has_key?(:state) or
              param.has_key?(:zip) or
              param.has_key?(:location) or
              (param.has_key?(:longitude) and param.has_key?(:latitude))
            raise MissingParameterException.new("Missing location data for the Yahoo! Maps Local Search service")
          end
          
          unless param.has_key?(:query) or
              param.has_key?(:listing_id)
            raise MissingParameterException.new("Missing query data for the Yahoo! Maps Local Search service")
          end
          
          url = "http://api.local.yahoo.com/LocalSearchService/V3/localSearch?appid=#{Ym4r::YahooMaps::APP_ID}&"
          url << "query=#{param[:query]}&" if param.has_key?(:query)
          url << "listing_id=#{param[:query]}&" if param.has_key?(:listing_id)
          url << "results=#{param[:results]}&" if param.has_key?(:results)
          url << "start=#{param[:start]}&" if param.has_key?(:start)
          url << "sort=#{param[:sort]}&" if param.has_key?(:sort)
          url << "radius=#{param[:radius]}&" if param.has_key?(:radius)
          url << "street=#{param[:street]}&" if param.has_key?(:street)
          url << "city=#{param[:city]}&" if param.has_key?(:city)
          url << "state=#{param[:state]}&" if param.has_key?(:state)
          url << "zip=#{param[:zip]}&" if param.has_key?(:zip)
          url << "location=#{param[:location]}&" if param.has_key?(:location)
          url << "latitude=#{param[:latitude]}&" if param.has_key?(:latitude)
          url << "longitude=#{param[:longitude]}&" if param.has_key?(:longitude)
          url << "category=#{param[:category]}&" if param.has_key?(:category)
          url << "omit_category=#{param[:omit_category]}&" if param.has_key?(:omit_category)
          url << "minimum_rating=#{param[:minimum_rating]}&" if param.has_key?(:minimum_rating)
          url << "output=xml"
          
          begin
            xml = open(URI.encode(url)).read
          rescue OpenURI::HTTPError => error
            raise BadRequestException.new(error.to_s)
          rescue 
            raise ConnectionException.new("Unable to connect to Yahoo! Maps  REST service")
          end
          
          doc = REXML::Document.new(xml) 

          if doc.root.name == "Error"
            raise RateLimitExceededException.new("Rate limit exceeded for Yahoo! Maps Geocoding service")
          else
            doc_root = doc.root
            result_set = LocalSearch::ResultSet.new(doc_root.elements['ResultSetMapUrl'].text,
                                                    doc_root.attributes['totalResultsAvailable'].to_i,
                                                    doc_root.attributes['totalResultsReturned'].to_i,
                                                    doc_root.attributes['firstResultPosition'].to_i)
            doc.elements.each("//Result") do |result|
              data = result.elements
              
              rating_data = data['Rating'].elements
              if rating_data['AverageRating'].text != "NaN"
                rating = LocalSearch::Rating.new(rating_data['AverageRating'].text.to_f, #when NaN, converted to 0 but can be tested (since TotalRating is 0 in this case) with is_rated? on the rating object
                                                 rating_data['TotalRatings'].text.to_i,
                                                 rating_data['TotalReviews'].text.to_i,
                                                 Time.at(rating_data['LastReviewDate'].text.to_i),
                                                 rating_data['LastReviewIntro'].text)
              else
                rating = LocalSearch::Rating.new(0,0,0,Time.at(0),"")
              end

              categories = []
              data.each('//Category') do |category|
                categories << LocalSearch::Category.new(category.attributes['id'].to_i,
                                                        category.text)
              end
              
              result_set << LocalSearch::Result.new(result.attributes['id'].to_i,
                                                    data['Title'].text || "",
                                                    data['Address'].text || "",
                                                    data['City'].text || "",
                                                    data['State'].text || "",
                                                    data['Phone'].text || "",
                                                    data['Latitude'].text.to_f,
                                                    data['Longitude'].text.to_f,
                                                    rating,
                                                    data['Distance'].text.to_f,
                                                    data['Url'].text || "",
                                                    data['ClickUrl'].text || "",
                                                    data['MapUrl'].text || "",
                                                    data['BusinessUrl'].text || "",
                                                    data['BusinessClickUrl'].text || "",
                                                    categories)
             
            end
            
            result_set
            
          end
        end
        
        #Contains a list of results from the Yahoo! Maps Local Search REST service V3
        class ResultSet < Array
          attr_accessor :map_url, :total_results_available, :total_results_returned, :first_result_position
          
          def initialize(map_url,total_results_available, total_results_returned, first_result_position)
            super(0)
            @map_url = map_url
            @total_results_available = total_results_available
            @total_results_returned = total_results_returned
            @first_result_position = first_result_position
          end
          
        end
        
        #Contains a result from the Yahoo! Maps Local Search REST service V3. 
        class Result < Struct.new(:id,:title,:address,:city,:state,:phone,:latitude,:longitude,:rating,:distance,:url,:click_url,:map_url,:business_url,:business_click_url,:categories)
        
          #convenience method for the lazy
          def lonlat
            [longitude,latitude]
          end
          
          #convenience method for the lazy
          def latlon
            [latitude,longitude]
          end
          
        end

        class Category < Struct.new(:id,:name)
        end
        
        class Rating < Struct.new(:average_rating,:total_ratings,:total_reviews,:last_review_date,:last_review_intro)
          def is_rated?
            total_ratings != 0
          end
        end
        
      end #LocalSearch
    end #BuildingBlock
  end
end #Ym4r
