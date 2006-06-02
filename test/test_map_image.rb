$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'ym4r'
require 'test/unit'

include Ym4r::YahooMaps::BuildingBlock

class TestMapImage< Test::Unit::TestCase

  def test_apple
    result = MapImage::get(:street => "1 Infinite Loop",
                            :city => "Cupertino",
                            :state => "CA",
                            :zip => "95014",
                            :image_type => "png")
    assert(result.exact_match?)
    apple_image = "apple.png"
    result.download_to(apple_image)
    assert(File.exist?(apple_image))
    File.delete(apple_image)
  end

  def test_no_location
    assert_raise(MissingParameterException) {MapImage::get(:image_type => "gif")}
  end

  def test_bad_parameter
    assert_raise(BadRequestException) do
      MapImage::get(:street => "1 Infinite Loop",
                   :city => "Cupertino",
                   :state => "CA",
                   :zip => "95014",
                   :image_type => "jpg") #jpg is not a valid image type
    end
  end
  
end
