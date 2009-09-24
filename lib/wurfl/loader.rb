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
    fallbacks = {}
    doc = XML::Document.file(wurflfilepath)
    doc.find("///devices/device").each do |element| 
      wurfl_id = element.attributes["id"]  
      h = @handsets[wurfl_id] ||= Wurfl::Handset.new(wurfl_id, element.attributes["user_agent"], nil, element.attributes["actual_device_root"])
      fall_back_id = element.attributes["fall_back"]
      fallbacks[wurfl_id] = fall_back_id unless fall_back_id == "root"
      
      element.find("group/capability").each do |capability|
        h[capability.attributes["name"]] = capability.attributes["value"]
      end
    end

    fallbacks.each {|k,v| @handsets[k].fallback = @handsets[v]}
  
    @handsets
  end
end

