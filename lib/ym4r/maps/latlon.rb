require 'ym4r/maps/mapping'

module Ym4r
  module Maps
    class LatLon < Struct.new(:lat,:lon)
      include MappingObject
      
      def create
        "new LatLon(#{lat},#{lon})"
      end
    end

    class LatLonRect < Struct.new(:min_lat, :min_lon, :max_lat, :max_lon)
      include MappingObject
      
      def create
        "new LatLonRect(#{min_lat},#{min_lon},#{max_lat},#{max_lon})"
      end
    end
  end
end
