require 'ym4r/google_maps/mapping'

module Ym4r
  module GoogleMaps
    #A graphical marker positionned through geographic coordinates (in the WGS84 datum). An HTML info window can be set to be displayed when the marker is clicked on.
    class GMarker
      include MappingObject
      attr_accessor :point, :options, :info_window, :info_window_tabs
      #The +points+ argument can be either a GLatLng object or an array of 2 floats. The +options+ keys can be: <tt>:icon</tt>, <tt>:clickable</tt>, <tt>:title</tt>, <tt>:info_window</tt> and <tt>info_window_tabs</tt>. The value of the +info_window+ key is a string of HTML code that will be displayed when the markers is clicked on. The value of the +info_window_tabs+ key is an array of GInfoWindowTab objects.
      def initialize(point, options = {})
        if point.is_a?(Array)
          @point = GLatLng.new(point)
        else
          @point = point
        end
        @info_window = options.delete(:info_window)
        @tab_info_window = options.delete(:info_window_tabs)
        @options = options
      end
      #Creates a marker: If an info_window or info_window_tabs is present, the response to the click action from the user is setup here.
      def create
        if @options.empty?
          creation = "new GMarker(#{@point.to_javascript})"
        else
          options = "{"
          options << @options.to_a.collect do |v|
            "#{v[0].to_s} : #{javascriptify_variable(v[1])}"
          end.join(",")
          options << "}"
          creation = "new GMarker(#{@point.to_javascript},#{options})"
        end
        if @info_window
          "addInfoWindowToMarker(#{creation},#{javascriptify_variable(@info_window)})"
        elsif @tab_info_window
          "addInfoWindowTabsToMarker(#{creation},[#{@tab_info_window.collect{ |tab| tab.to_javascript}.join(",")}])"
        else
          creation
        end
      end
    end
    
    #Represents a tab to be displayed in a bubble when a marker is clicked on.
    class GInfoWindowTab < Struct.new(:tab,:content)
      include MappingObject
      def create
        "new GInfoWindowTab(#{javascriptify_variable(tab)},#{javascriptify_variable(content)})"
      end
    end
        
    #Represents a definition of an icon. You can pass rubyfied versions of the attributes detailed in the Google Maps API documentation. You can initialize global icons to be used in the application by passing a icon object, along with a variable name, to GMap#icon_init. If you want to declare an icon outside this, you will need to declare it first, since the JavaScript constructor does not accept any argument.
    class GIcon
      include MappingObject
      DEFAULT = Variable.new("G_DEFAULT_ICON")
      attr_accessor :options, :copy_base

      #Options can contain all the attributes (in rubyfied format) of a GIcon object (see Google's doc), as well as <tt>:copy_base</tt>, which indicates if the icon is copied from another one.
      def initialize(options = {})
        @copy_base = options.delete(:copy_base)
        @options = options
      end
      #Creates a GIcon.
      def create
        if @copy_base
          "new GIcon(#{@copy_base.to_javascript})"
        else
          "new GIcon()"
        end
      end
      #Declares a GIcon. It is necessary to declare an icon before using it, since it is the only way to set up its attributes.
      def declare(variable)
        decl = super(variable)
        @options.each do |key,value|
          decl << "#{variable}.#{javascriptify_method(key.to_s)} = #{javascriptify_variable(value)};\n"
        end
        decl
      end
    end
     
    #A polyline.
    class GPolyline
      include MappingObject
      attr_accessor :points,:color,:weight,:opacity
      #Can take an array of +GLatLng+ or an array of 2D arrays. A method to directly build a polyline from a GeoRuby linestring is provided in the helper.rb file.
      def initialize(points,color = nil,weight = nil,opacity = nil)
        if !points.empty? and points[0].is_a?(Array)
          @points = points.collect { |pt| GLatLng.new(pt) }
        else
          @points = points
        end
        @color = color
        @weight = weight
        @opacity = opacity
      end
      #Creates a new polyline.
      def create
        a = "new GPolyline([#{@points.collect{|pt| pt.to_javascript}.join(",")}]"
        a << ",#{javascriptify_variable(@color)}" if @color
        a << ",#{javascriptify_variable(@weight)}" if @weight
        a << ",#{javascriptify_variable(@opacity)}" if @opacity
        a << ")"
      end
      
    end

    #A basic Latitude/longitude point.
    class GLatLng 
      include MappingObject
      attr_accessor :lat,:lng,:unbounded
      
      def initialize(latlng,unbounded = nil)
        @lat = latlng[0]
        @lng = latlng[1]
        @unbounded = unbounded
      end
      def create
        unless @unbounded
          "new GLatLng(#{@lat},#{@lng})"
        else
          "new GLatLng(#{@lat},#{@lng},#{@unbounded})"
        end
      end
    end
    
    #A rectangular bounding box, defined by its south-western and north-eastern corners.
    class GLatLngBounds < Struct.new(:sw,:ne)
      include MappingObject
      def create
        "new GLatLngBounds(#{sw},#{ne})"
      end
    end

  end
end
