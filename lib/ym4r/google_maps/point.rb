require 'ym4r/google_maps/mapping'

module Ym4r
  module GoogleMaps
    class GPoint < Struct.new(:x,:y)
      include MappingObject
      def create
        "new GPoint(#{x},#{y})"
      end
    end
    class GBounds
      include MappingObject
      attr_accessor :points
      
      def initialize(points)
        if !points.empty? and points[0].is_a?(Array)
          @points = points.collect { |pt| GPoint.new(pt[0],pt[1]) }
        else
          @points = points
        end
      end
      def create
        "new GBounds([#{@points.map { |pt| pt.to_javascript}.join(",")}])"
      end
    end
    class GSize < Struct.new(:width,:height)
      include MappingObject
      def create
        "new GSize(#{width},#{height})"
      end

    end
  end
end
