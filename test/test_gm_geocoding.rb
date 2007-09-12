$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'ym4r/google_maps/geocoding'
require 'test/unit'

include Ym4r::GoogleMaps

class TestGmGeocoding< Test::Unit::TestCase
  def test_google_maps_geocoding
    placemarks = Ym4r::GoogleMaps::Geocoding.get("Rue Clovis Paris")
    assert_equal(Ym4r::GoogleMaps::Geocoding::GEO_SUCCESS,placemarks.status)
    assert_equal(1,placemarks.length)
    placemark = placemarks[0]
    assert_equal("FR",placemark.country_code)
    assert_equal("Paris",placemark.locality)
    assert_equal("75005",placemark.postal_code)
  end

  def test_google_maps_pakistan
    placemarks = Ym4r::GoogleMaps::Geocoding.get("Lahore PK")
    assert_equal(Ym4r::GoogleMaps::Geocoding::GEO_SUCCESS,placemarks.status)
    assert_equal(1,placemarks.length)
    placemark = placemarks[0]
    assert_equal("PK",placemark.country_code)
    assert_equal("Lahore",placemark.locality)
    assert_equal("",placemark.thoroughfare)
  end	
	
  def test_google_maps_multiple_matches
    placemarks = Ym4r::GoogleMaps::Geocoding.get("gooseberry")
    assert_equal(Ym4r::GoogleMaps::Geocoding::GEO_SUCCESS,placemarks.status)
    assert_equal(4,placemarks.length)
    
    placemark = placemarks[0]
    assert_equal("US",placemark.country_code)
    assert_equal("UT", placemark.administrative_area)
    assert_equal("Blanding",placemark.locality)
    assert_equal("Gooseberry",placemark.thoroughfare)
    assert_equal("84511",placemark.postal_code)
    
    placemark = placemarks[1]
    assert_equal("US",placemark.country_code)
    assert_equal("OR", placemark.administrative_area)
    assert_equal("",placemark.locality)
    assert_equal("",placemark.thoroughfare)
    assert_equal("",placemark.postal_code)
    
    placemark = placemarks[2]
    assert_equal("US",placemark.country_code)
    assert_equal("UT", placemark.administrative_area)
    assert_equal("Salina",placemark.locality)
    assert_equal("",placemark.thoroughfare)
    assert_equal("",placemark.postal_code)
    
    placemark = placemarks[3]
    assert_equal("US",placemark.country_code)
    assert_equal("CA", placemark.administrative_area)
    assert_equal("",placemark.locality)
    assert_equal("Gooseberry",placemark.thoroughfare)
    assert_equal("93651",placemark.postal_code)
  
  end
end
