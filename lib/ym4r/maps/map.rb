require 'ym4r/app_id'
require 'ym4r/maps/mapping'

module Ym4r
  module Maps
    
    module MapViews
      MAP = "MapViews.MAP"
      HYBRID = "MapViews.HYBRID"
      SATELLITE = "MapViews.SATELLITE" 
    end
    
    class Map
      include MappingObject
      
      attr_reader :container, :width, :height
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
      def initialize(container, width, height, options={})
        @container = container
        @width = width
        @height = height
        @latlon = options[:latlon]
        @location = options[:location] || ""
        @zoom = options[:zoom] || 14
        @view_type = options[:view_type] || MapViews::MAP
      end

      #returns HTML code to add the necessary include and css code to initialize the map
      def header
        "<script type='text/javascript' src='http://api.maps.yahoo.com/v3.0/fl/javascript/apiloader.js?appid=#{Ym4r::APP_ID}'></script>\n<style type='text/css'>\n##{@container} {\n  height: #{@height}px;\n  width: #{@width}px;\n}\n</style>\n"
      end
      
      #creates the map and add any initialization javascript code returned by the block (like addition of a set of initial markers or other custom code). 
      def to_html(variable = "map")
        html = "<script type='text/javascript'>\n"
        html << declare(variable)
        if block_given?
          html << yield(self)
        end
        html << "</script>\n"
      end

      def create
        unless @latlon.nil?
          "new Map('#{@container}','#{Ym4r::APP_ID}',#{@latlon.to_javascript},#{@zoom},#{@view_type})"
        else
          "new Map('#{@container}','#{Ym4r::APP_ID}','#{@location}',#{@zoom},#{@view_type})"
        end
      end
            
    end  
  end
end
