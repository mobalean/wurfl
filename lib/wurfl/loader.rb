require "wurfl/handset"
begin
  require "xml"
rescue LoadError
  require "rubygems"
  require "xml"
end

module Wurfl; end

# Handles the loading of WURFL handsets
class Wurfl::Loader
  
  def initialize 
    @handsets = Hash::new
  end
  
  # Returns a Hash of loaded handsets.
  def load_wurfl(wurflfilepath)
    doc = XML::Document.file(wurflfilepath)
    doc.find("///devices/device").each do |element| 
      wurfl_id = element.attributes["id"]  
      h = @handsets[wurfl_id] ||= Wurfl::Handset.new(wurfl_id, element.attributes["user_agent"])
      fall_back_id = element.attributes["fall_back"]
      if fall_back_id != "root"
        h.fallback = @handsets[fall_back_id] ||= Wurfl::Handset.new("","")
      end
      
      element.find("group/capability").each do |capability|
        h[capability.attributes["name"]] = capability.attributes["value"]
      end
    end
  
    @handsets
  end
end

