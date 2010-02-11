require File.join(File.dirname(__FILE__), 'test_helper')
require 'wurfl/utils'
require 'wurfl/loader'
require 'tempfile'

class TestLoader < Test::Unit::TestCase
  include Wurfl::Utils

  def test_save_and_load_wurfl_pstore
    loader = Wurfl::Loader.new
    handsets = loader.load_wurfl(File.join(File.dirname(__FILE__), "data", "wurfl.simple.xml"))
    tempfile = Tempfile.new("wurfl.pstore").path
    save_wurfl_pstore(tempfile,handsets)
    loaded_handsets = load_wurfl_pstore(tempfile)
    assert_equal handsets, loaded_handsets
  end

end
