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
  end
end
