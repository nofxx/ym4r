module Ym4r
  module GoogleMaps 
    class GMap
      include MappingObject
      
      VML_NAMESPACE = "xmlns:v=\"urn:schemas-microsoft-com:vml\""
      
      attr_reader :container
      
      def initialize(container, variable = "map")
        @container = container
        @variable = variable
        @init = ""
        @global_init = ""
      end

      def header(with_vml = true)
        a = "<script src=\"http://maps.google.com/maps?file=api&v=2&key=#{API_KEY}\" type=\"text/javascript\"></script>\n"
        a << "<style type=\"text/css\">\n v\:* { behavior:url(#default#VML);}\n</style>" if with_vml
        a
      end

      def header_width_height(width,height)
        "<style type=\"text/css\">\n##{@container} { height: #{height}px;\n  width: #{width}px;\n}\n</style>"
      end

      def record_init(code)
        @init << code
      end

      def control_init(controls = {})
        @init << add_control(GSmallMapControl.new) if controls[:small_map]
        @init << add_control(GLargeMapControl.new) if controls[:large_map]
        @init << add_control(GSmallZoomControl.new) if controls[:small_zoom]
        @init << add_control(GScaleControl.new) if controls[:scale]
        @init << add_control(GMapTypeControl.new) if controls[:map_type]
        @init << add_control(GOverviewMapControl.new) if controls[:overview_map]
      end

      def center_zoom_init(center, zoom)
        if center.is_a?(GLatLng)
          @init << set_center(center,zoom)
        else
          @init << set_center(GLatLng.new(center),zoom)
        end
      end

      def record_global_init(code)
        @global_init << code
      end
      
      def icon_init(icon , variable)
        @global_init << icon.declare(variable)
      end
      
      #allow :script, :no_script and :load in the method parameter. If the :load parameter has been chose, the load_method parameter must be filled too.
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
        html << @global_init
        html << "var #{@variable};\n" if !no_declare and !no_global
        html << "function #{load_method}() {\nif (GBrowserIsCompatible()) {\n" if !no_load
        if !no_declare and no_global 
          html << declare(@variable)
        else
          html << assign_to(@variable)
        end
        html << @init
        html << "}\n}\n" if !no_load
        html << "</script>" if !no_script_tag
        html
      end
      
      def create
        "new GMap2(document.getElementById(\"#{@container}\"))"
      end
    end

    module GMapType
      G_NORMAL_MAP = Variable.new("GMapType.G_NORMAL_MAP")
      G_SATELLITE_MAP = Variable.new("GMapType.G_SATELLITE_MAP")
      G_HYBRID_MAP = Variable.new("GMapType.G_HYBRID_MAP")
    end
  end
end
