module Ym4r
  module YahooMaps
    module Flash
      module Tool
        EVENT_INITIALIZE = "Tool.EVENT_INITIALIZE"
      end
      
      class CustomSWFTool < Struct.new(:url,:icon_url)
        include MappingObject
        
        EVENT_LOADED = "CustomSWFTool.EVENT_LOADED"
        
        def create
          "new CustomSWFTool('#{url}','#{icon_url}')"
        end
      end
      
      class PanTool
        include MappingObject
        
        EVENT_DRAG_STOP = "PanTool.EVENT_DRAG_STOP"
        EVENT_DRAG_START = "PanTool.EVENT_DRAG_START"
        
        def create
          "new PanTool()"
        end
      end
    end
  end
end
