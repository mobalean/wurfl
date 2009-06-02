$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'wurfl/handset'
require 'test/unit'

class TestHandset < Test::Unit::TestCase
  def setup
    @handset = Wurfl::Handset.new("wurfl_id", "user_agent", nil)
  end

  def test_lookup
    assert_nil @handset["capability"]
  end

end
