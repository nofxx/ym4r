$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'ym4r'
require 'test/unit'

include Ym4r::YahooMaps::Flash

class TestMaps< Test::Unit::TestCase

  def test_simple_map
  end

end
