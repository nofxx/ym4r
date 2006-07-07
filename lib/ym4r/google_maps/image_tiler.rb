require 'RMagick'

module Ym4r
  module GoogleMaps
    module Tiler
      module ImageTiler
        class Point < Struct.new(:x,:y)
          def -(point)
            Point.new(x - point.x , y - point.y)
          end
          def +(point)
            Point.new(x + point.x , y + point.y)
          end
          def *(scale)
            Point.new(scale * x,scale * y)
          end
          def to_s
            "Point #{x} #{y}"
          end
        end
        
        class TileParam < Struct.new(:ul_corner,:zoom,:padding,:scale)
        end
        
        TILE_SIZE = 256
        
        def self.get_tiles(output_dir, input_files, tile_param, zooms, bg_color = Magick::Pixel.new(255,255,255,0), format = "png")
          #order the input files: string order.
          sorted_input_files = input_files.sort

          #Whatever the zoom level, the tiles must cover the same surface : we get the surface of the furthest zoom. 
          furthest_dimension_tiles = get_dimension_tiles(sorted_input_files[0],tile_param)
          puts furthest_dimension_tiles.to_s

          zooms.each do |zoom|
            next if zoom < tile_param.zoom
            return if (input_file = sorted_input_files.shift).nil?
            
            image = Magick::ImageList::new(input_file)
            image.scale!(tile_param.scale)
            image_size = Point.new(image.columns , image.rows)
            
            factor = 2 ** (zoom - tile_param.zoom)
                        
            #index of the upper left corner for the current zoom
            start = tile_param.ul_corner * factor
            dimension_tiles = furthest_dimension_tiles * factor
            dimension_tiles_pixel = dimension_tiles * TILE_SIZE
            padding = tile_param.padding * factor
            
            puts "Padding" + padding.to_s
            puts "Size " + image_size.to_s
            puts "Dimension " + dimension_tiles_pixel.to_s

            #create an image at dimension_tiles_pixel ; copy the current image there  (a bit inefficient memory wise even if it simplifies )
            image_with_padding = Magick::Image.new(dimension_tiles_pixel.x, dimension_tiles_pixel.y) do 
              self.background_color = bg_color
            end
                
            image_with_padding.import_pixels(padding.x,padding.y,image_size.x,image_size.y,"RGBA",image.export_pixels(0,0,image_size.x,image_size.y,"RGBA"))

            image_with_padding.write(output_dir + "/tile_glob_#{zoom}.png")

            total_tiles = dimension_tiles.x * dimension_tiles.y
            
            counter = Point.new(0,0)
            
            cur_tile = Point.new(start.x,start.y)
            
            1.upto(total_tiles) do |tile|
              #progress column by column
              if counter.y == dimension_tiles.y
                counter.x += 1
                counter.y = 0
                cur_tile.x += 1
                cur_tile.y = start.y
              end
              
              pt_nw = counter * TILE_SIZE
              
              tile_image = Magick::Image.new(TILE_SIZE,TILE_SIZE)
              tile_image.import_pixels(0,0,TILE_SIZE,TILE_SIZE,"RGBA",image_with_padding.export_pixels(pt_nw.x,pt_nw.y,TILE_SIZE,TILE_SIZE,"RGBA"))
              tile_image.write("#{output_dir}/tile_#{zoom}_#{cur_tile.x}_#{cur_tile.y}.#{format}")
              
              counter.y += 1
              cur_tile.y += 1
              
            end
          end
        end

        
        def self.get_dimension_tiles(file,tile_param)
          #Get the size of the first input_file
          image = Magick::ImageList::new(file)
          image.scale!(tile_param.scale)
          image_size = Point.new(image.columns , image.rows)
          puts "ISize " + image_size.to_s
          ending = tile_param.padding + image_size
          puts "Ending " + ending.to_s
          Point.new((ending.x / TILE_SIZE.to_f).ceil,(ending.y / TILE_SIZE.to_f).ceil)
        end
        
      end
    end
  end
end
