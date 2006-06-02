module Ym4r
  module YahooMaps
    module Flash
    
      module MapViews
        MAP = Variable.new("MapViews.MAP")
        HYBRID = Variable.new("MapViews.HYBRID")
        SATELLITE = Variable.new("MapViews.SATELLITE") 
      end
      
      class Map
        include MappingObject
        
        attr_reader :container
        attr_accessor :zoom, :latlon, :location, :view_type
        
        EVENT_INITIALIZE = "Map.EVENT_INITIALIZE"
        EVENT_MAP_GEOCODE_ERROR = "Map.EVENT_MAP_GEOCODE_ERROR"
        EVENT_MAP_GEOCODE_SUCCESS = "Map.EVENT_MAP_GEOCODE_SUCCESS"
        EVENT_MARKER_GEOCODE_ERROR = "Map.EVENT_MARKER_GEOCODE_ERROR"
        EVENT_MARKER_GEOCODE_SUCCESS = "Map.EVENT_MARKER_GEOCODE_SUCCESS"
        EVENT_MOVE = "Map.EVENT_MOVE"
        EVENT_PAN_START = "Map.EVENT_PAN_START"
        EVENT_PAN_STOP = "Map.EVENT_PAN_STOP"
        EVENT_TOOL_ADDED = "Map.EVENT_TOOL_ADDED"
        EVENT_TOOL_CHANGE = "Map.EVENT_TOOL_CHANGE"
        EVENT_TOOL_REMOVED = "Map.EVENT_TOOL_REMOVED"
        EVENT_ZOOM = "Map.EVENT_ZOOM"
        EVENT_ZOOM_STOP = "Map.EVENT_ZOOM_STOP"
        EVENT_ZOOM_START = "Map.EVENT_ZOOM_START"
        
        #+container+ is the DIV element in the page that will host the SWF map
        def initialize(container, options={})
          @container = container
          @latlon = options[:latlon]
          @location = options[:location] || ""
          @zoom = options[:zoom] || 14
          @view_type = options[:view_type] || MapViews::MAP
          @init = ""
        end
        
        #returns HTML code to add the necessary include and css code to initialize the map
        def header
          "<script type='text/javascript' src='http://api.maps.yahoo.com/v3.0/fl/javascript/apiloader.js?appid=#{Ym4r::APP_ID}'></script>\n"
        end
        
        def header_width_height(width,height)
          "<style type='text/css'>\n##{@container} {\n  height: #{@height}px;\n  width: #{@width}px;\n}\n</style>\n"
        end
        
        def record_init(code)
          @init << code
        end
        
        #creates the map and add any initialization javascript code returned by the block (like addition of a set of initial markers or other custom code). 
        def to_html(with_script_tag = true)
          html = ""
          html << "<script type=\"text/javascript\">\n" if with_script_tag
          html << @init
          html << "</script>\n" if with_script_tag
          html
        end
        
        def create
          unless @latlon.nil?
            "new Map('#{@container}','#{Ym4r::APP_ID}',#{@latlon.to_javascript},#{@zoom},#{@view_type.to_javascript})"
          else
            "new Map('#{@container}','#{Ym4r::APP_ID}','#{@location}',#{@zoom},#{@view_type.to_javascript})"
          end
        end
      end  
    end
  end
end
