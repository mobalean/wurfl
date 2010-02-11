require File.join(File.dirname(__FILE__), 'test_helper')
require 'wurfl/handset'

class HandsetTest < Test::Unit::TestCase
  def setup
    @fallback = Wurfl::Handset.new("fallback_id", "f", nil)
    @handset = Wurfl::Handset.new("handset_id", "h", @fallback)
  end

  should("not be equal to nil") { assert_not_equal @handset, nil }
  should("not be equal to 1") { assert_not_equal @handset, 1 }
  should("not be equal to fallback") { assert_not_equal @handset, @fallback }
  should("equal self") { assert_equal @handset, @handset }
  should("not have differences") { assert @handset.differences(@fallback).empty? }

  context "key not set" do
    should("not have value") { assert_nil @handset["k"] }
    should("not have owner") { assert_equal nil, @handset.owner("k") }
  end

  context "fallback key set" do
    setup { @fallback["k"] = "v" }

    should("fetch value from fallback") { assert_equal "v", @handset["k"] }
    should("have fallback as owner") { assert_equal "fallback_id", @handset.owner("k") }

    context "and handset overwrites key" do
      setup { @handset["k"] = nil }

      should("fetch value from handset") { assert_nil @handset["k"] }
      should("have handset as owner") { assert_equal "handset_id", @handset.owner("k") }
    end
  end

  context "fallback and handset set different keys" do
    setup do
      @handset["k1"] = "v1"
      @fallback["k2"] = "v2"
    end

    should("have keys from handset and fallback") { assert_equal(["k1", "k2"], @handset.keys) }
  end

  context "another handset with same wurfl_id and fallback" do
    setup { @another_handset = Wurfl::Handset.new("handset_id","h", @fallback) }

    should("equal handset") { assert_equal @handset, @another_handset}

    context "and the other handset sets a key" do
      setup { @another_handset["k"] = "v" }

      should("not equal handset") { assert_not_equal @handset, @another_handset }

      context "and the fallback sets identical key" do
        setup { @fallback["k"] = "v" }

        should("equal handset") { assert_equal @handset, @another_handset }
      end
    end
  end
  
  context "another handset with different wurfl_id and fallback" do
    setup do
      @another_fallback = Wurfl::Handset.new("f2", "f2_ua", nil)
      @another_handset = Wurfl::Handset.new("h2","h2_ua", @another_fallback)
    end

    context "and no keys set" do
      should('have no differences') {assert @handset.differences(@another_fallback).empty? }
    end

    context "and the other handset has a key set" do
      setup { @another_handset["k"] = "v" }

      should('have the key as a difference') do
        assert_equal ["k"], @handset.differences(@another_handset)
      end
    end

    context "and handset has a key set" do
      setup { @handset["k"] = "v" }

      should('have the key as a difference') do
        assert_equal ["k"], @handset.differences(@another_handset)
      end
    end

    context "and both handsets have different values for same key" do
      setup do
        @handset["k"] = "v"
        @another_handset["k"] = "v2"
      end

      should 'have the key as a difference' do
        assert_equal ["k"], @handset.differences(@another_handset)
      end
    end

    context "and fallbacks have different values for same key" do
      setup do
        @fallback["j"] = "1"
        @another_fallback["j"] = "2"
      end

      should 'have the key as a difference' do
        assert_equal ["j"], @handset.differences(@another_handset)
      end
    end
  end
end
