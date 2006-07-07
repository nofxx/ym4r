$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'ym4r/google_maps/geocoding'
require 'test/unit'

include Ym4r::GoogleMaps

class TestGmGeocoding< Test::Unit::TestCase
  def test_google_maps_geocoding
    placemarks = Geocoding.get("Rue Clovis Paris")
    assert_equal(Geocoding::GEO_SUCCESS,placemarks.status)
    assert_equal(1,placemarks.length)
    placemark = placemarks[0]
    assert_equal("FR",placemark.country_code)
    assert_equal("Paris",placemark.locality)
    assert_equal("75005",placemark.postal_code)
  end

  def test_google_maps_pakistan
    placemarks = Geocoding.get("Lahore PK")
    assert_equal(Geocoding::GEO_SUCCESS,placemarks.status)
    assert_equal(1,placemarks.length)
    placemark = placemarks[0]
    assert_equal("PK",placemark.country_code)
    assert_equal("Lahore",placemark.locality)
    assert_equal("",placemark.thoroughfare)
  end
