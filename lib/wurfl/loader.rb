require "wurfl/handset"
require "rexml/document"
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

  # A simple debuging method to print all user agents in a WURFL file
  def print_handsets_in_wurfl(wurflfile)
    file = File.new(wurflfile)
    doc = REXML::Document.new file
    doc.elements.each("wurfl/devices/device") do |element| 
      puts element.attributes["user_agent"] 
    end
  end
  
  # Returns a Hashtable of handsets and a hashtable of Fallback id and agents
  def load_wurfl(wurflfilepath)
    parse_wurfl(XML::Document.file(wurflfilepath))
  end

  def parse_xml(s)
    parse_wurfl(XML::Document.string(s))
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
      hands = nil
      wurfl_id = element.attributes["id"]  
      if wurfl_id == "generic"
        hands = @handsets[wurfl_id] ||= Wurfl::Handset.new("generic","generic")
      else
        hands = @handsets[wurfl_id] ||= Wurfl::Handset.new(wurfl_id, element.attributes["user_agent"])
        
        hands.fallback = @handsets[element.attributes["fall_back"]
] ||= Wurfl::Handset.new("","")
      end
      
      element.find("group/capability").each do |el2|
        hands[el2.attributes["name"]] = el2.attributes["value"]
      end
    end
  
    @handsets
  end

end

