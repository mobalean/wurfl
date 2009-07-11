$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'wurfl/utils'
require 'wurfl/loader'
require 'test/unit'
require 'tempfile'

class TestLoader < Test::Unit::TestCase
  include Wurfl::Utils

  def test_save_and_load_wurfl_pstore
    loader = Wurfl::Loader.new
    handsets, fallbacks = loader.load_wurfl(File.join(File.dirname(__FILE__), "data", "wurfl.simple.xml"))
    tempfile = Tempfile.new("wurfl.pstore").path
    save_wurfl_pstore(tempfile,handsets,fallbacks)
    loaded_handsets, loaded_fallbacks = load_wurfl_pstore(tempfile)
    assert_equal handsets, loaded_handsets
    assert_equal fallbacks, loaded_fallbacks
  end

end
