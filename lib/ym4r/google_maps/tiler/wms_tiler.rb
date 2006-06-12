require 'open-uri'

module Ym4r
  module GoogleMaps
    module Tiler
      module WmsTiler
        #Contains LatLon coordinates
        class LatLng < Struct.new(:lat,:lng)
        end
        
        #Contain projected coordinates (in pixel or meter)
        class Point < Struct.new(:x,:y)
        end
        
        #Structure that contains configuration data for the WMS tiler
        class FurthestZoom < Struct.new(:ul_corner, :zoom, :tile_size)
        end
        
        #The size of a Google Maps tile. There are square so only one size.
        TILE_SIZE = 256
        
        #Defines a Simple Mercator projection for one level of Google Maps zoom.
        class MercatorProjection
          DEG_2_RAD = Math::PI / 180
          WGS84_SEMI_MAJOR_AXIS = 6378137.0
          WGS84_ECCENTRICITY = 0.0818191913108718138
          
          attr_reader :zoom, :size, :pixel_per_degree, :pixel_per_radian, :origin
          
          def initialize(zoom)
            @zoom = zoom
            @size = TILE_SIZE * (2 ** zoom)
            @pixel_per_degree = @size / 360.0
            @pixel_per_radian = @size / (2 * Math::PI)
            @origin = Point.new(@size / 2 , @size / 2)
          end
          
          def borne(number, inf, sup)
            if(number < inf)
              inf
            elsif(number > sup)
              sup
            else
              number
            end
          end
          
          #Transforms LatLon coordinate into pixel coordinates in the Google Maps sense
          #See http://www.math.ubc.ca/~israel/m103/mercator/mercator.html for details
          def latlng_to_pixel(latlng)
            answer = Point.new
            answer.x = (@origin.x + latlng.lng * @pixel_per_degree).round
            sin = borne(Math.sin(latlng.lat * DEG_2_RAD),-0.9999,0.9999)
            answer.y = (@origin.y + 0.5 * Math.log((1 + sin) / (1 - sin)) * -@pixel_per_radian).round
            answer
          end
          
          #Transforms pixel coordinates in the Google Maps sense to LatLon coordinates
          def pixel_to_latlng(point)
            answer = LatLng.new
            lng = (point.x - @origin.x) / @pixel_per_degree;
            answer.lng = lng - (((lng + 180)/360).round * 360)
            lat = (2 * Math.atan(Math.exp((point.y - @origin.y) / -@pixel_per_radian))- Math::PI / 2) / DEG_2_RAD
            answer.lat = borne(lat,-90,90)
            answer
          end
          
          #Projects LatLon coordinates in the WGS84 datum to meter coordinates using the Simple Mercator projection
          def self.latlng_to_meters(latlng)
            answer = Point.new
            answer.x = WGS84_SEMI_MAJOR_AXIS * latlng.lng * DEG_2_RAD
            lat_rad = latlng.lat * DEG_2_RAD
            answer.y = WGS84_SEMI_MAJOR_AXIS * Math.log(Math.tan((lat_rad + Math::PI / 2) / 2) * ( (1 - WGS84_ECCENTRICITY * Math.sin(lat_rad)) / (1 + WGS84_ECCENTRICITY * Math.sin(lat_rad))) ** (WGS84_ECCENTRICITY/2)) 
            answer
          end
        end
        
        #Get tiles from a WMS server 
        def self.get_tiles(output_dir, url, furthest_zoom, zooms, layers, geographic = false, epsg = 54004, styles = "", format = "png")
          
          unless geographic
            srs_str = epsg
          else
            srs_str = 4326 #Geographic WGS84
          end
          
          base_url = url << "?REQUEST=GetMap&SERVICE=WMS&VERSION=1.1&LAYERS=#{layers}&STYLES=#{styles}&BGCOLOR=0xFFFFFF&FORMAT=image/#{format}&TRANSPARENT=TRUE&WIDTH=#{TILE_SIZE}&HEIGHT=#{TILE_SIZE}&SRS=EPSG:#{srs_str}&reaspect=false"
          
          zooms.each do |zoom|
            next if zoom < furthest_zoom.zoom

            proj = MercatorProjection.new(zoom)
            
            #from mapki.com
            factor = 2 ** (zoom - furthest_zoom.zoom)
            
            #index of the upper left corner
            x_start = furthest_zoom.ul_corner.x * factor
            y_start = furthest_zoom.ul_corner.y * factor
            
            x_tiles = furthest_zoom.tile_size.x * factor
            y_tiles = furthest_zoom.tile_size.y * factor
            
            total_tiles = x_tiles * y_tiles
            
            x_counter = 0
            y_counter = 0
            
            x_tile = x_start
            y_tile = y_start
            
            1.upto(total_tiles) do |tile|
              #progress column by column
              if y_counter == y_tiles
                x_counter += 1
                y_counter = 0
                x_tile += 1
                y_tile = y_start
              end
              
              pt_sw = Point.new( (x_start + x_counter) * TILE_SIZE, (y_start + (y_counter + 1)) * TILE_SIZE) #y grows southbound
              pt_ne = Point.new((x_start + (x_counter + 1)) * TILE_SIZE, (y_start + y_counter) * TILE_SIZE)
              
              ll_sw = proj.pixel_to_latlng(pt_sw)
              ll_ne = proj.pixel_to_latlng(pt_ne)
              
              unless geographic
                pt_sw = MercatorProjection.latlng_to_meters(ll_sw)
                pt_ne = MercatorProjection.latlng_to_meters(ll_ne)
                bbox_str = "#{pt_sw.x},#{pt_sw.y},#{pt_ne.x},#{pt_ne.y}"
              else
                bbox_str = "#{ll_sw.lon},#{ll_sw.lat},#{ll_ne.lon},#{ll_ne.lat}"
              end
              
              request_url = "#{base_url}&BBOX=#{bbox_str}"
                    
              begin
                open("#{output_dir}/tile_#{zoom}_#{x_tile}_#{y_tile}.#{format}","wb") do |f|
                  f.write open(request_url).read
                end
              rescue Exception => e
                puts e
                raise
              end
              
              y_counter += 1
              y_tile += 1
              
            end
          end
        end
      end
    end
  end
end


