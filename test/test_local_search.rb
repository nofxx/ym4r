$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'ym4r'
require 'test/unit'

include Ym4r::YahooMaps::BuildingBlock

class TestLocalSearch< Test::Unit::TestCase

  def test_apple
    results = LocalSearch::get(:street => "1 Infinite Loop",
                              :city => "Cupertino",
                              :state => "CA",
                              :zip => "95014",
                              :query => "chinese")
    assert(! results.nil?)
    results.each do |result|
      assert(!result.id.nil?)
      assert(!result.title.nil?)
      assert(!result.address.nil?)
      assert(!result.city.nil?)
      assert(!result.state.nil?)
      assert(!result.phone.nil?)
      assert(!result.latitude.nil?)
      assert(!result.longitude.nil?)
      assert(!result.rating.nil?)
      assert(result.rating.is_a?(LocalSearch::Rating))
      assert(!result.url.nil?)
      assert(!result.click_url.nil?)
      assert(!result.map_url.nil?)
      assert(!result.business_url.nil?)
      assert(!result.business_click_url.nil?)
      assert(!result.categories.nil?)
      assert(result.categories.is_a?(Array))
    end
  end

  def test_no_query
    assert_raise(MissingParameterException) do
      LocalSearch::get(:street => "1 Infinite Loop",
                       :city => "Cupertino",
                       :state => "CA",
                       :zip => "95014")
    end
  end

  def test_random_query
    results = LocalSearch::get(:street => "1 Infinite Loop",
                               :city => "Cupertino",
                               :state => "CA",
                               :zip => "95014",
                               :query => "AZEAEAEZAEAEAE")
    assert(!results.nil?)
    
    assert_equal(0,results.length)
    
  end

  def test_ooo
    results = LocalSearch::get(:query => 'Daily Grind', :city => 'Portland',:state  => 'OR')
    assert(!results.nil?)
  end

end
