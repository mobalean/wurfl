require File.join(File.dirname(__FILE__), 'test_helper')
require 'wurfl/loader'

class LoaderTest < Test::Unit::TestCase

  class << self
    def should_have_correct_values(h)
      h.each do |wurfl_id, values|
        values.each do |key, value|
          should "have #{key} set to #{value} for #{wurfl_id}" do
            assert_equal value.to_s, @handsets[wurfl_id.to_s][key.to_s]
          end
        end
      end
    end
  
    def should_have_correct_user_agents(h)
      h.each do |wurfl_id, user_agent|
        should "have user agent '#{user_agent}' for #{wurfl_id}" do
          assert_equal user_agent, @handsets[wurfl_id.to_s].user_agent
        end
      end
    end
  end

  def setup
    @loader = Wurfl::Loader.new
  end

  context "loaded base wurfl" do
    setup do
      @handsets = @loader.load_wurfl(File.join(File.dirname(__FILE__), "data", "wurfl.simple.xml"))
    end
    should_have_correct_values(
      :apple_generic => { :columns => 20, :max_image_height => 300, :physical_screen_height => 27 },
      :generic_xhtml => { :columns => 11, :max_image_height => 92, :physical_screen_height => 27 },
      :generic => { :columns => 11, :max_image_height => 35, :physical_screen_height => 27 }
    )
    should_have_correct_user_agents(
      :generic => "",
      :apple_generic => "Mozilla/5.0 (iPhone;",
      :generic_xhtml => "Mozz"
    )

    context 'and patch' do
      setup do
        @handsets = @loader.load_wurfl(File.join(File.dirname(__FILE__), "data", "wurfl.generic.patch.xml"))
      end
      should_have_correct_values(:generic => { :columns => 200, :rows => 6 })
    end
  end

  context "loaded wurfl with handsets in reverse order" do
    setup do
      @handsets = @loader.load_wurfl(File.join(File.dirname(__FILE__), "data", "wurfl.reverse.xml"))
    end
    should_have_correct_values(
      :apple_generic => { :columns => 20, :max_image_height => 300, :physical_screen_height => 27 },
      :generic_xhtml => { :columns => 11, :max_image_height => 92, :physical_screen_height => 27 },
      :generic => { :columns => 11, :max_image_height => 35, :physical_screen_height => 27 }
    )
    should_have_correct_user_agents(
      :generic => "",
      :apple_generic => "Mozilla/5.0 (iPhone;",
      :generic_xhtml => "Mozz"
    )
  end

end

