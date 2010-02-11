require File.join(File.dirname(__FILE__), 'test_helper')
require 'wurfl/handset'

class TestHandset < Test::Unit::TestCase
  def setup
    @f = Wurfl::Handset.new("f", "f", nil)
    @h = Wurfl::Handset.new("h", "h", @f)
    
    @f2 = Wurfl::Handset.new("f2", "f2_ua", nil)
    @h2 = Wurfl::Handset.new("h2","h2_ua", @f2)
  end

  def test_f
    assert_nil @h["capability"]
    @f["k"] = "v"
    assert_equal "v", @h["k"]
    @h["k"] = nil
    assert_nil @h["k"]
  end

  def test_owner
    assert_equal nil, @h.owner("k")
    @f["k"] = "v"
    assert_equal "f", @h.owner("k")
    @h["k"] = nil
    assert_equal "h", @h.owner("k")
  end

  def test_keys
    @h["k1"] = "v1"
    @f["k2"] = "v2"
    assert_equal(["k1", "k2"], @h.keys)
  end

  def test_equivalence
    assert @h != nil
    assert @h != 1
    assert @h != @f
    assert @h == @h
    h2 = Wurfl::Handset.new("h","h", @f)
    assert @h == h2
    h2["k"] = "v"
    assert @h != h2
    @f["k"] = "v"
    assert @h == h2
  end

  def test_differences_handset_with_unmodified_fallback
    assert @h.differences(@f).empty?
  end

  def test_differences_handset_with_identical_handset
    assert @h.differences(@h2).empty?
  end

  def test_differences_handset_that_has_extra_key
    @h["k"] = "v"
    assert_equal ["k"], @h.differences(@h2)
  end

  def test_differences_other_handset_that_has_extra_key
    @h2["k"] = "v"
    assert_equal ["k"], @h.differences(@h2)
  end

  def test_differences_handset_that_has_differing_key_value
    @h["k"] = "v"
    @h2["k"] = "v2"
    assert_equal ["k"], @h.differences(@h2)
  end

  def test_differences_handsets_with_differening_fallback_key_value
    @f["j"] = "1"
    @f2["j"] = "2"
    assert_equal ["j"], @h.differences(@h2)
  end

end
