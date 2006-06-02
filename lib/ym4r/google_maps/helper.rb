
Ym4r::GoogleMaps::GPolyline.class_eval do
  def self.from_georuby(line_string,color = nil,weight = nil,opacity = nil)
    GPolyline.new(line_string.points.collect { |point| GLatLng.new([point.y,point.x])},color,weight,opacity)
  end
end

Ym4r::GoogleMaps::GMarker.class_eval do
  def self.from_georuby(point,options = {})
    GMarker.new([point.y,point.x],options)
  end
end

Ym4r::GoogleMaps::GLatLng.class_eval do
  def self.from_georuby(point,unbounded = nil)
    GLatLng.new([point.y,point.x],unbounded)
  end
end

