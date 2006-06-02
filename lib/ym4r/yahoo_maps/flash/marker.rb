module Ym4r
  module YahooMaps
    module Flash
      module Marker
        EVENT_INITIALIZE = "Marker.EVENT_INITIALIZE"
      end
      
      class CustomPOIMarker < Struct.new(:index, :title, :description, :marker_color, :stroke_color)
        include MappingObject
        
        def create
          "new CustomPOIMarker('#{index}','#{title}','#{description}','#{marker_color}','#{stroke_color}')";
        end
      end
      
      class CustomImageMarker < Struct.new(:url)
        include MappingObject
        
        def create
          "new CutomImageMarker('#{url}')"
        end
      end
      
      class CustomSWFMarker < Struct.new(:url)
        include MappingObject
        
        def create
          "new CustomSWFMarker('#{url}')"
        end
      end
      
      class WaypointMarker < Struct.new(:index)
        include MappingObject
        
        def create
          "new WaypointMarker('#{index}')"
        end
      end
    end
  end
end

    
