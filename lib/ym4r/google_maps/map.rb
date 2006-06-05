module Ym4r
  module GoogleMaps 
    #The Ruby-space class representing the Google Maps API class GMap2.
    class GMap
      include MappingObject
      
      #A constant containing the declaration of the VML namespace, necessary to display polylines under IE.
      VML_NAMESPACE = "xmlns:v=\"urn:schemas-microsoft-com:vml\""
      
      #The id of the DIV that will contain the map in the HTML page. 
      attr_reader :container
      
      #By default the map in the HTML page will be globally accessible with the name +map+.
      def initialize(container, variable = "map")
        @container = container
        @variable = variable
        @init = []
        @global_init = []
      end

      #Outputs the header necessary to use the Google Maps API. By default, it also outputs a style declaration for VML elements.
      def header(with_vml = true)
        a = "<script src=\"http://maps.google.com/maps?file=api&v=2&key=#{API_KEY}\" type=\"text/javascript\"></script>\n"
        a << "<style type=\"text/css\">\n v\:* { behavior:url(#default#VML);}\n</style>" if with_vml
        a
      end

      #Outputs a style declaration setting the dimensions of the DIV container of the map. This info can also be set manually in a CSS.
      def header_width_height(width,height)
        "<style type=\"text/css\">\n##{@container} { height: #{height}px;\n  width: #{width}px;\n}\n</style>"
      end

      #Records arbitrary JavaScript code and outputs it during initialization inside the +load+ function.
      def record_init(code)
        @init << code
      end

      #Initializes the controls: you can pass a hash with keys <tt>:small_map</tt>, <tt>:large_map</tt>, <tt>:small_zoom</tt>, <tt>:scale</tt>, <tt>:map_type</tt> and <tt>:overview_map</tt> and a boolean value as the value (usually true, since the control is not displayed by default)
      def control_init(controls = {})
        @init << add_control(GSmallMapControl.new) if controls[:small_map]
        @init << add_control(GLargeMapControl.new) if controls[:large_map]
        @init << add_control(GSmallZoomControl.new) if controls[:small_zoom]
        @init << add_control(GScaleControl.new) if controls[:scale]
        @init << add_control(GMapTypeControl.new) if controls[:map_type]
        @init << add_control(GOverviewMapControl.new) if controls[:overview_map]
      end

      #Initializes the initial center and zoom of the map. +center+ can be both a GLatLng object or a 2-float array.
      def center_zoom_init(center, zoom)
        if center.is_a?(GLatLng)
          @init << set_center(center,zoom)
        else
          @init << set_center(GLatLng.new(center),zoom)
        end
      end

      #Initializes the map by adding an overlay (marker or polyline). It can be called multiple times
      def overlay_init(overlay)
        @init << add_overlay(overlay)
      end

      #Records arbitrary JavaScript code and outputs it during initialization outside the +load+ function (ie globally).
      def record_global_init(code)
        @global_init << code
      end
      
      #Initializes an icon  and makes it globally accessible through the JavaScript variable of name +variable+.
      def icon_init(icon , variable)
        @global_init << icon.declare(variable)
      end
      
      #Outputs the initialization code for the map. By default, it outputs the script tags, performs the initialization inside a function called +load+ and makes the map globally available.
      def to_html(options = {})
        no_load = options[:no_load]
        load_method = options[:load_method] || "load"
        no_script_tag = options[:no_script_tag]
        no_declare = options[:no_declare]
        no_global = options[:no_global]
        
        html = ""
        html << "<script type=\"text/javascript\">\n" if !no_script_tag
        html << "function addInfoWindowToMarker(marker,info){\nGEvent.addListener(marker, \"click\", function() {\nmarker.openInfoWindowHtml(info);\n});\nreturn marker;\n}\n"
        html << "function addInfoWindowTabsToMarker(marker,info){\nGEvent.addListener(marker, \"click\", function() {\nmarker.openInfoWindowTabsHtml(info);\n});\nreturn marker;\n}\n"
        html << @global_init * "\n"
        html << "var #{@variable};\n" if !no_declare and !no_global
        html << "function #{load_method}() {\nif (GBrowserIsCompatible()) {\n" if !no_load
        if !no_declare and no_global 
          html << "#{declare(@variable)}\n"
        else
          html << "#{assign_to(@variable)}\n"
        end
        html << @init * "\n"
        html << "\n}\n}\n" if !no_load
        html << "</script>" if !no_script_tag
        html
      end
      
      #Outputs in JavaScript the creation of a GMap2 object 
      def create
        "new GMap2(document.getElementById(\"#{@container}\"))"
      end
    end

    #Map types of the map
    module GMapType
      G_NORMAL_MAP = Variable.new("GMapType.G_NORMAL_MAP")
      G_SATELLITE_MAP = Variable.new("GMapType.G_SATELLITE_MAP")
      G_HYBRID_MAP = Variable.new("GMapType.G_HYBRID_MAP")
    end
  end
end

