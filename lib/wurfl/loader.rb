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
  
  attr_accessor :new_hands, :ttl_keys

  def initialize 
    @new_hands = 0
    @ttl_keys = 0  
    @handsets = Hash::new
    @fallbacks = Hash::new
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
      value.each { |key,value| 	puts "#{key} = #{value}" }
    end
  end

  private
  
  def parse_wurfl(doc)
    # read counter
    rcount = 0
    
    # iterate over all of the devices in the file
    doc.find("///devices/device").each do |element| 
      
      rcount += 1
      hands = nil # the reference to the current handset
      if element.attributes["id"] == "generic"
	# setup the generic Handset 
	
	if @handsets.key?("generic") then
	  hands = @handsets["generic"]
	else
	  # the generic handset has not been created.  Make it
	  hands = Wurfl::Handset.new "generic","generic"
	  @handsets["generic"] = hands
	end
	
      else
	# Setup an actual handset
	
	# check if handset already exists.
	wurflid = element.attributes["id"]	
	if @handsets.key?(wurflid)
	  # Must have been created by someone who named it as a fallback earlier.
	  hands = @handsets[wurflid]
	else
	  hands = Wurfl::Handset.new "",""
	end
	hands.wurfl_id = wurflid
	hands.user_agent = element.attributes["user_agent"]
	
	# get the fallback and copy it's values into this handset's hashtable
	fallb = element.attributes["fall_back"]
	
	# Now set the handset to the proper fallback reference
	if !@handsets.key?(fallb)
	  # We have a fallback that does not exist yet, create the reference.
	  @handsets[fallb] = Wurfl::Handset.new "",""
	end
	hands.fallback = @handsets[fallb]
      end
      
      # now copy this handset's specific capabilities into it's hashtable
      element.find("group/capability").each do |el2|
	hands[el2.attributes["name"]] = el2.attributes["value"]
      end
      @handsets[hands.wurfl_id] = hands
      
    end
  
    @handsets
  end

end

