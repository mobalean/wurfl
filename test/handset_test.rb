$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'wurfl/handset'
require 'test/unit'

class TestHandset < Test::Unit::TestCase
  def setup
    @f = Wurfl::Handset.new("f", "f", nil)
    @h = Wurfl::Handset.new("h", "h", @f)
  end

  def test_f
    assert_nil @h["capability"]
    @f["k"] = "v"
    assert_equal "v", @h["k"]
    @h["k"] = nil
    assert_nil @h["k"]
  end

  def test_get_value_and_owner
    assert_equal [nil, nil], @h.get_value_and_owner("k")
    @f["k"] = "v"
    assert_equal ["v", "f"], @h.get_value_and_owner("k")
    @h["k"] = nil
    assert_equal [nil, "h"], @h.get_value_and_owner("k")
  end

  def test_keys
    @h["k1"] = "v1"
    @f["k2"] = "v2"
    assert_equal(["k1", "k2"], @h.keys)
  end

  def test_each
    @h["k1"] = "v1"
    @f["k2"] = "v2"
    a = []
    @h.each {|k,v| a << [k,v]}
    assert_equal [["k1","v1"], ["k2","v2"]], a
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

  def test_compare
    f2 = Wurfl::Handset.new("f2", "f2", nil)
    h2 = Wurfl::Handset.new("h2","h2", f2)
    assert @h.compare(@f).empty?
    @h["k"] = "v"

    assert_equal [["k", nil, nil]], @h.compare(h2)

    h2["k"] = "v2"
    assert_equal [["k", "v2", "h2"]], @h.compare(h2)

    @f["j"] = "1"
    f2["j"] = "2"
    assert_equal [["k", "v2", "h2"], ["j", "2", "f2"]], @h.compare(h2)
  end

end
