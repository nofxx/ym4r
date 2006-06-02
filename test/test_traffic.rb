$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'ym4r'
require 'test/unit'

include Ym4r::YahooMaps::BuildingBlock

class TestTraffic< Test::Unit::TestCase

  def test_apple
    results = Traffic::get(:street => "1 Infinite Loop",
                          :city => "Cupertino",
                          :state => "CA",
                          :zip => "95014",
                          :include_map => true)
    
    #since it changes according to time, difficult to test..
    assert(! results.nil?)
    assert(results.exact_match?)
    
    if(!results.empty?)
      result = results[0]
      apple_traffic_image = "apple_traffic.png"
      result.download_to(apple_traffic_image)
      assert(File.exist?(apple_traffic_image))
      File.delete(apple_traffic_image)
    end
    

  end

  
end
