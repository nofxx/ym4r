$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'ym4r/google_maps/tiler/wms_tiler'
include Ym4r::GoogleMaps::Tiler

require 'optparse'
require 'ostruct'

OptionParser.accept(Range, /(\d+)\.\.(\d+)/) do |range,start,finish|
  Range.new(start.to_i,finish.to_i)
end

OptionParser.accept(WmsTiler::FurthestZoom, /(\d+),(\d+),(\d+),(\d+),(\d+)/) do |setting,l_corner, u_corner, zoom, width, height|
  WmsTiler::FurthestZoom.new(WmsTiler::Point.new(l_corner.to_i,u_corner.to_i),zoom.to_i,WmsTiler::Point.new(width.to_i,height.to_i))
end

options = OpenStruct.new
#set some defaults
options.format = "png"
options.zoom_range = 0..17
options.styles = ""
options.srs = 54004
options.geographic = false

opts = OptionParser.new do |opts|
  opts.banner = "WMS Tiler for Google Maps\nUsage: tile_wms.rb [options]\nExample: tile_wms.rb -o ./tiles -u http://localhost:8080/geoserver/wms -l \"topp:states\" -z 11..12 -g 602,768,11,3,3"
  opts.separator "" 
  opts.on("-o","--output OUTPUT_DIR","Directory where the tiles will be created") do |dir| 
    options.output_dir = dir
  end
  opts.on("-u","--url WMS_SERVICE","URL to the WMS server") do |url|
    options.url = url
  end
  opts.on("-l","--layers LAYERS","String of comma-separated layer names") do |layers|
    options.layers = layers
  end
  opts.on("-s","--styles STYLES","String of comma-separated style names. Is empty by default") do |styles|
    options.styles = styles
  end
  opts.on("-f","--format FORMAT","Image format in which to get the file (gif, jpeg, png...). Is png by default") do |format|
    options.format = format
  end
  opts.on("-z","--zooms ZOOM_RANGE",Range,"Range of zoom values at which the tiles must be generated. Is 0..17 by default") do |range|
    options.zoom_range = range
  end
  opts.on("-g","--gmap-setting SETTING",WmsTiler::FurthestZoom,"Corner coordinates, furthest zoom level, tile width and height") do |fz|
    options.furthest_zoom = fz
  end
  opts.on("-w","--[no-]geographic","Query the WMS server with LatLon coordinates isntead of using the Mercator projection") do |g|
    options.geographic = g
  end
  opts.on("-e", "--epsg SRS","SRS to query the WMS server. Should be a the SRS id of a Simple Mercator projection. Can vary between WMS servers. Is 54004 (Simple Mercator for Mapserver) by default") do |srs|
    options.srs = srs
                    
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
error << "No WMS URL defined (-u,--url)" if options.url.nil?
error << "No Google Maps setting defined (-g,--gmap-setting)" if options.furthest_zoom.nil?
error << "No WMS layer defined (-l,--layers)" if options.layers.nil?

unless error.empty?
  puts error * "\n" + "\n\n"
  puts opts
  exit
end

WmsTiler.get_tiles(options.output_dir,options.url,options.furthest_zoom,options.zoom_range,options.layers,options.geographic,options.srs,options.styles,options.format)

                      
