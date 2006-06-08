module Ym4r
  module GoogleMaps
    #Map types of the map
    class GMapType
      include MappingObject
      
      G_NORMAL_MAP = Variable.new("GMapType.G_NORMAL_MAP")
      G_SATELLITE_MAP = Variable.new("GMapType.G_SATELLITE_MAP")
      G_HYBRID_MAP = Variable.new("GMapType.G_HYBRID_MAP")
      
      attr_accessor :layers, :name, :projection
      
      def initialize(layers, name, projection = GMercatorProjection.new,options = {})
        @layers = layers
      end

      def create
        "new GMapType(#{javascriptify_variable(Array(layers))}, #{javascriptify_variable(projection)}, #{javascriptify_variable(name)}, #{javascriptify_variable(options)})"
      end
    end

    class GMercatorProjection
      include MappingObject
      
      attr_accessor :n
      
      def initialize(n = nil)
        @n = n
      end

      def create
        if n.nil?
          return "G_NORMAL_MAP.getProjection()"
        else
          "new GMercatorProjection(#{@n})"
        end
      end
    end
    
    class GTileLayer
      include MappingObject
            
      attr_accessor :opacity, :zoom_inter, :copyright

      def initialize(zoom_inter = 0..17, copyright= ['prefix' => '', 'copyright_texts' => [""]], opacity = 1.0)
        @opacity = opacity
        @zoom_inter = zoom_inter
        @copyright = copyright
      end

      def create
        "addPropertiesToLayer(new GTileLayer(new GCopyrightCollection(\"\"),#{zoom_inter.begin},#{zoom_inter.end}),#{get_tile_url}, function(a,b) {return #{MappingObject.javascriptify_variable(@copyright)};}, function() {return #{@opacity};})"
      end
      
      #for subclasses to implement
      def get_tile_url
      end
    end
    
    class PreTiledLayer < GTileLayer
      include MappingObject
      
      attr_accessor :base_url, :format
      
      def initialize(base_url, format = "png", zoom_inter = 0..17, copyright = ['prefix' => '', 'copyright_texts' => [""]], opacity = 1.0)
        super(zoom_inter, copyright, opacity)
        @base_url = base_url
        @format = format
      end
      
      #returns the code to determine the url to fetch the tile. Follows the convention adopted by the tiler: {base_url}/tile_{b}_{a.x}_{a.y}.{format}
      def get_tile_url
        "function(a,b,c) { return '#{@base_url}/tile_' + b + '_' + a.x + '_' + a.y + '.#{@format}';}"
      end 
    end
    
    #needs to modify the wms-gs.js script for this to work : check with the people who wrote it if it is ok
    #needs to include the JavaScript file wms-gs.js for this to work
    #see http://docs.codehaus.org/display/GEOSDOC/Google+Maps
    class WMSLayer < GTileLayer
      include MappingObject

      attr_accessor :base_url, :layers, :styles, :format

      def initialize(base_url, layers, styles = "", format= "png", zoom_inter = 0..17, copyright = ['prefix' => '', 'copyright_texts' => [""]], opacity = 1.0)
        super(zoom_inter, copyright, opacity)
        @base_url = base_url
        @layers = layers
        @styles = styles
        @format = format
      end
      
      def get_tile_url
        "CustomGetTileUrl"
      end
    end
  end
end
