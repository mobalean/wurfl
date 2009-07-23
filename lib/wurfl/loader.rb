require "wurfl/handset"
begin
  require "xml"
rescue LoadError
  require "rubygems"
  require "xml"
end

module Wurfl; end

=begin
A class the handles the loading, debug printing and inserting of WURFL 
handsets into a handset DB.
=end
class Wurfl::Loader
  
  def initialize 
    @handsets = Hash::new
  end
  
  # Returns a Hashtable of handsets and a hashtable of Fallback id and agents
  def load_wurfl(wurflfilepath)
    parse_wurfl(XML::Document.file(wurflfilepath))
  end

  # Prints out WURFL handsets from a hashtable
  def print_wurfl(handsets)
    handsets.each do |key,value|
      puts "********************************************\n\n"
      puts "#{key}\n"
      value.each { |key,value|   puts "#{key} = #{value}" }
    end
  end

  private
  
  def parse_wurfl(doc)
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

