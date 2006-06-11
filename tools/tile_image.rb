$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'ym4r/google_maps/tiler/image_tiler'
include Ym4r::GoogleMaps::Tiler

require 'optparse'
require 'ostruct'

OptionParser.accept(Range, /(\d+)\.\.(\d+)/) do |range,start,finish|
  Range.new(start.to_i,finish.to_i)
end

OptionParser.accept(ImageTiler::TileParam, /(\d+),(\d+),(\d+),(\d+),(\d+),([\d.]+)/) do |setting,l_corner, u_corner, zoom, padding_x, padding_y, scale|
  ImageTiler::TileParam.new(ImageTiler::Point.new(l_corner.to_i,u_corner.to_i),zoom.to_i,ImageTiler::Point.new(padding_x.to_i,padding_y.to_i),scale.to_f)
end

OptionParser.accept(Magick::Pixel,/(\d+),(\d+),(\d+),(\d+)/) do |pixel, r,g,b,a|
  Magick::Pixel.new(r.to_f,g.to_f,b.to_f,a.to_f)
end

options = OpenStruct.new
#set some defaults
options.format = "png"
options.zoom_range = 0..17
options.bg_color = Magick::Pixel.new(255,255,255,255)

opts = OptionParser.new do |opts|
  opts.banner = "Image Tiler for Google Maps\nUsage: tile_image.rb [options]\nExample: tile_image.rb -o ./tiles -z 11..12 -p 602,768,11,78,112,1.91827348 ./input_files/*.jpg"
  opts.separator "" 
  opts.on("-o","--output OUTPUT_DIR","Directory where the tiles will be created") do |dir| 
    options.output_dir = dir
  end
  opts.on("-f","--format FORMAT","Image format in which to get the file (gif, jpeg, png...). Is png by default") do |format|
    options.format = format
  end
  opts.on("-z","--zooms ZOOM_RANGE",Range,"Range of zoom values at which the tiles must be generated. Is 0..17 by default") do |range|
    options.zoom_range = range
  end
  opts.on("-p","--tile-param PARAM",ImageTiler::TileParam,"Corner coordinates, furthest zoom level, padding in X and Y, scale") do |tp|
    options.tile_param = tp
  end
  opts.on("-b","--background COLOR",Magick::Pixel,"Background color components. Is fully transparent par default") do |bg|
    options.bg_color = bg
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end

opts.parse!(ARGV)

#test the presence of all the options and exit with an error message
error = []
error << "No output directory defined (-o,--output)" if options.output_dir.nil?
error << "No tile parameter defined (-p,--tile-param)" if options.tile_param.nil?
error << "No input files defined" if ARGV.empty?

unless error.empty?
  puts error * "\n" + "\n\n"
  puts opts
  exit
end

ImageTiler.get_tiles(options.output_dir,ARGV,options.tile_param,options.zoom_range,options.bg_color,options.format)

                      
