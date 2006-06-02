require 'ym4r/google_maps/mapping'

module Ym4r
  module GoogleMaps
    class GSmallMapControl
      include MappingObject
      def create
        "new GSmallMapControl()"
      end
    end
    class GLargeMapControl
      include MappingObject
      def create
        "new GLargeMapControl()"
      end
    end
    class GSmallZoomControl
      include MappingObject
      def create
        "new GSmallZoomControl()"
      end
    end
    class GScaleControl
      include MappingObject
      def create
        "new GScaleControl()"
      end
    end
    class GMapTypeControl
      include MappingObject
      def create
        "new GMapTypeControl()"
      end
    end
    class GOverviewMapControl
      include MappingObject
      def create
        "new GOverviewMapControl()"
      end
    end

    #The first argument of the constructor is oneof the following : :top_right, :top_left, :bottom_right, :bottom_left
    class GControlPosition < Struct.new(:anchor,:offset)
      include MappingObject
      def create
        js_anchor = if anchor == :top_right
                      "G_ANCHOR_TOP_RIGHT"
                    elsif anchor == :top_left
                      "G_ANCHOR_TOP_LEFT"
                    elsif anchor == :bottom_right
                      "G_ANCHOR_BOTTOM_RIGHT"
                    else
                      "G_ANCHOR_BOTTOM_LEFT"
                    end
        "new GControlPosition(#{js_anchor},#{offset})"
      end
    end
  end
end
