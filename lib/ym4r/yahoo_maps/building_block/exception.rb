module Ym4r
  module YahooMaps
    module BuildingBlock
      #Raised if the rate limit per 24 hours per IP is reached
      class RateLimitExceededException < StandardError
      end
      
      #Raised if the Yahoo Maps building bloc service is unreachable
      class ConnectionException < StandardError
      end
      
      #Raised if the service returns an HTTP error (due to bad arguments passed to the service)
      class BadRequestException < StandardError
      end
      
      #Raised if all the data needed is not passed to the get method of the service
      class MissingParameterException < StandardError
      end
    end
  end
end
