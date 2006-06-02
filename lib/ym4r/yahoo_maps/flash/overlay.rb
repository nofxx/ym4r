module Ym4r
  module YahooMaps
    module Flash
      module Overlay
        EVENT_INITIALIZE = "Overlay.EVENT_INITIALIZE"
      end
      
      class CustomSWFOverlay < Struct.new(:url)
        include MappingObject
        
        def create
          "new CustomSWFOverlay('#{url}')"
        end
      end
      
      class GeoRSSOverlay < Struct.new(:url)
        include MappingObject
        
        def create
          "new GeoRSSOverlay('#{url}')"
        end
      end
      
      class LocalSearchOverlay
        include MappingObject
        
        EVENT_SEARCH_ERROR = "LocalSearchOverlay.EVENT_SEARCH_ERROR"
        EVENT_SEARCH_SUCCESS = "LocalSearchOverlay.EVENT_SEARCH_SUCCESS"
        
        def create
          "new LocalSearchOverlay()"
        end
      end
      
      class TrafficOverlay
        include MappingObject
        
        def create
          "new TrafficOverlay()"
        end
      end
    end
  end
end
