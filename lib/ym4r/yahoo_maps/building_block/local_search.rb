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
          url << "output=json"
          
          begin
            json = open(URI.encode(url)).read
          rescue OpenURI::HTTPError => error
            raise BadRequestException.new(error.to_s)
          rescue 
            raise ConnectionException.new("Unable to connect to Yahoo! Maps  REST service")
          end
          
          #see http://rubyforge.org/snippet/detail.php?type=snippet&id=29. Safe?
          json_obj = eval(json.gsub(/(["'])\s*:\s*(['"0-9tfn\[{])/){"#{$1}=>#{$2}"})
          
          if json_obj.has_key?("Error")
            raise RateLimitExceededException.new("Rate limit exceeded for Yahoo! Maps Traffic REST service")
          else
            json_result_set = json_obj['ResultSet']
            
            result_set = LocalSearch::ResultSet.new(json_result_set['ResultSetMapUrl'],
                                                    json_result_set['totalResultsAvailable'].to_i,
                                                    json_result_set['totalResultsReturned'].to_i,
                                                    json_result_set['firstResultPosition'].to_i)
            
            unless json_result_set['Result'].nil?
              json_results = [json_result_set['Result']].flatten #uniform processing in case there is only one result
              
              json_results.each do |json_result|
              
                #get the rating
                json_rating = json_result['Rating']
                rating = LocalSearch::Rating.new(json_rating['AverageRating'].to_f, #when NaN, converted to 0 but can be tested (since TotalRating is 0 in this case) with is_rated? on the rating object
                                                 json_rating['TotalRatings'].to_i,
                                                 json_rating['TotalReviews'].to_i,
                                                 Time.at(json_rating['LastReviewDate'].to_i),
                                                 json_rating['LastReviewIntro'])
                
                #get the categories
                categories = []
                unless json_result['Categories']['Category'].nil? #no category present in the result
                  json_categories = [json_result['Categories']['Category']].flatten #uniform processing in case there is only one category
                  json_categories.each do |json_category|
                    categories << LocalSearch::Category.new(json_category['id'].to_i,
                                                            json_category['content'])
                  end
                end
                
                result_set << LocalSearch::Result.new(json_result['id'].to_i,
                                                      json_result['Title'],
                                                      json_result['Address'],
                                                      json_result['City'],
                                                      json_result['State'],
                                                      json_result['Phone'],
                                                      json_result['Latitude'].to_f,
                                                      json_result['Longitude'].to_f,
                                                      rating,
                                                      json_result['Distance'].to_f,
                                                      json_result['Url'],
                                                      json_result['ClickUrl'],
                                                      json_result['MapUrl'],
                                                      json_result['BusinessUrl'],
                                                      json_result['BusinessClickUrl'],
                                                      categories)
                
              end 
            end #unless json_result_set['Result'].nil?
            
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
