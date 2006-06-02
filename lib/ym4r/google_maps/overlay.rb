require 'ym4r/google_maps/mapping'

module Ym4r
  module GoogleMaps
    class GMarker
      include MappingObject
      attr_accessor :point, :options, :info_window, :info_window_tabs
      #options keys can be : :icon, :clickable and :title: Defaults to G_DEFAULT_ICON, true and empty. :info_window can also be input. However in order to be taken into account, the marker has to be declared at some point
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
    
    class GInfoWindowTab < Struct.new(:tab,:content)
      include MappingObject
      def create
        "new GInfoWindowTab(#{javascriptify_variable(tab)},#{javascriptify_variable(content)})"
      end
    end
        
    #Icon class. You can pass rubyfied versions of the attributes detailed in the Google Maps API documentation. You can initialize global icons to be used in the application by passing a icon object, along with a variable name, to GMap#icon_init. If you want to declare an icon outside this, you will need to declare it first. 
    class GIcon
      include MappingObject
      DEFAULT = Variable.new("G_DEFAULT_ICON")
      attr_accessor :options, :copy_base

      #Options can contain all the attributes (in rubifiedformat) of an GIconobject (see Google's doc) + :copy_base, which indicates if the icon is copied from another one
      def initialize(options = {})
        @copy_base = options.delete(:copy_base)
        @options = options
      end
      def create
        if @copy_base
          "new GIcon(#{@copy_base.to_javascript})"
        else
          "new GIcon()"
        end
      end
      def declare(variable)
        decl = super(variable)
        @options.each do |key,value|
          decl << "#{variable}.#{javascriptify_method(key.to_s)} = #{javascriptify_variable(value)};\n"
        end
        decl
      end
    end
     
    #A polyline. Can take an array of GLatLng or an array of 2D arrays. A method to build a polyline from a GeoRuby linestring is provided in the helper.rb file.
    class GPolyline
      include MappingObject
      attr_accessor :points,:color,:weight,:opacity
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
    
    class GLatLngBounds < Struct.new(:sw,:ne)
      include MappingObject
      def create
        "new GLatLngBounds(#{sw},#{ne})"
      end
    end

  end
end
