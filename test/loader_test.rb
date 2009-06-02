$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'wurfl/loader'
require 'test/unit'

class TestLoader < Test::Unit::TestCase

  def setup
    @loader = Wurfl::Loader.new
  end

  def test_load_wurfl
    handsets, fallbacks = @loader.load_wurfl(File.join(File.dirname(__FILE__), "data", "wurfl.simple.xml"))
    assert_equal("20", handsets["apple_generic"]["columns"])
    assert_equal("11", handsets["generic_xhtml"]["columns"])
    assert_equal("11", handsets["generic"]["columns"])

    assert_equal("300", handsets["apple_generic"]["max_image_height"])
    assert_equal("92", handsets["generic_xhtml"]["max_image_height"])
    assert_equal("35", handsets["generic"]["max_image_height"])
  end

end

