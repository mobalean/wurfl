$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'wurfl/user_agent_matcher'
require 'wurfl/loader'
require 'test/unit'

class UserAgentMatcherTest < Test::Unit::TestCase
  def setup
    loader = Wurfl::Loader.new
    handsets = loader.load_wurfl(File.join(File.dirname(__FILE__), "data", "wurfl.simple.xml"))
    @matcher = Wurfl::UserAgentMatcher.new(handsets)
  end

  def test_empty_user_agent
    a, shortest_distance = @matcher.match_handsets("")
    assert_equal 1, a.size
    assert_equal "generic", a.first.wurfl_id
    assert_equal 0, shortest_distance
  end

  def test_matching_user_agent
    a, shortest_distance = @matcher.match_handsets("Mozz")
    assert_equal 1, a.size
    assert_equal "generic_xhtml", a.first.wurfl_id
    assert_equal 0, shortest_distance
  end

  def test_iphone
    s = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)"
    a, shortest_distance = @matcher.match_handsets(s)
    assert_equal 1, a.size
    assert_equal "apple_generic", a.first.wurfl_id
    assert_equal 26, shortest_distance
  end
end
