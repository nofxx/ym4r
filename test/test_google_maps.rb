$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'ym4r/google_maps'
require 'test/unit'

include Ym4r::GoogleMaps

class TestGoogleMaps< Test::Unit::TestCase
  def test_js_export
    map = GMap.new("map_div")
    var = Variable.new("hello")
    yuo = Variable.new("salam")
    poi = Variable.new("poi")
    map.record_init map.add_overlay(GMarker.new([123.5,123.56]))
    map.record_init map.dummy_method(var.other_dummy_method(yuo.kaka_boudin),poi)
    map.control_init(:small_map => true)
    puts map.to_html
  end
end
