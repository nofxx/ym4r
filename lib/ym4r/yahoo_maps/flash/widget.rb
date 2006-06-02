module Ym4r
  module YahooMaps
    module Flash
      module Widget
        EVENT_INITIALIZE = "Widget.EVENT_INITIALIZE"
      end
      
      class NavigatorWidget
        include MappingObject
        
        def create
          "new NavigatorWidget()"
        end
      end
      
      class SatelliteControlWidget
        include MappingObject
        
        def create
          "new SatelliteControlWidget()"
        end
      end
      
      class ToolBarWidget
        include MappingObject
      
        def create
          "new ToolBarWidget()"
        end
      end
    end
  end
end
