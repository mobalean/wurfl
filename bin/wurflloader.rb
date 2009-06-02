#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.dirname(__FILE__), '..',  'lib')

require "getoptlong"
require "rexml/document"
require "wurfl/handset"
require "wurfl/utils"

=begin
A class the handles the loading, debug printing and inserting of WURFL handsets into 
a handset DB.
=end
class WurflLoader
  
  attr_accessor :new_hands, :ttl_keys, :verbose

  def initialize 
    @new_hands = 0
    @ttl_keys = 0  
    @verbose = false
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
  def load_wurfl(wurflfile)
    file = File.new(wurflfile)
    doc = REXML::Document.new file
    
    # read counter
    rcount = 0
    
    # iterate over all of the devices in the file
    doc.elements.each("wurfl/devices/device") do |element| 
      
      rcount += 1
      hands = nil # the reference to the current handset
      if element.attributes["id"] == "generic"
	# setup the generic Handset 
	
	if @handsets.key?("generic") then
	  hands = @handsets["generic"]
	  puts "Updating the generic handset at count #{rcount}" if @verbose	
	else
	  # the generic handset has not been created.  Make it
	  hands = Wurfl::Handset.new "generic","generic"
	  @handsets["generic"] = hands
	  @fallbacks["generic"] = Array::new
	  puts "Made the generic handset at count #{rcount}" if @verbose	
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
	
	# for tracking of who has fallbacks
	if !@fallbacks.key?(fallb)
	  @fallbacks[fallb] = Array::new   
	end
	@fallbacks[fallb]<< hands.user_agent
	
	# Now set the handset to the proper fallback reference
	if !@handsets.key?(fallb)
	  # We have a fallback that does not exist yet, create the reference.
	  @handsets[fallb] = Wurfl::Handset.new "",""
	end
	hands.fallback = @handsets[fallb]
      end
      
      # now copy this handset's specific capabilities into it's hashtable
      element.elements.each("./*/capability") do |el2|
	hands[el2.attributes["name"]] = el2.attributes["value"]
      end
      @handsets[hands.wurfl_id] = hands
      
      # Do some error checking
      if hands.wurfl_id.nil? 
	puts "a handset with a nil id at #{rcount}" 
      elsif hands.user_agent.nil? 
	puts "a handset with a nil agent at #{rcount}"
      end           
    end
  
    return @handsets, @fallbacks
  end


  # Prints out WURFL handsets from a hashtable
  def print_wurfl(handsets)
    
    handsets.each do |key,value|
      puts "********************************************\n\n"
      puts "#{key}\n"
      value.each { |key,value| 	puts "#{key} = #{value}" }
    end
  end

end


include Wurfl::Utils

print = false
insert = false
verbose = false
wurflfile = nil
patchfile = nil
pstorefile = nil
pstoreload = false

def usage
  puts "Usage: wurflloader.rb [-p -v -h -e patchfile] -f wurflfile"
  puts "       --file, -f (wurflfile): The master WURFL file to load."
  puts "       --extension, -e (patchfile): A patch file to extend the traits of the master WURLF file."
  puts "       --print, -p : Prints out handsets."
  puts "       --verbose, -v : Verbose output."
  puts "       --help, -h : Prints this message."
  puts "       --database, -d (databasename): Makes a PStore database for quick loading of data with other tools."
  puts "       --load, -l (databasename): Loads handsets from a PStore database instead of XML file."
  exit 1
end

begin
  options = GetoptLong.new(
                           ["-p","--print", GetoptLong::NO_ARGUMENT],
                           ["-h","--help", GetoptLong::NO_ARGUMENT],
                           ["-v","--verbose", GetoptLong::NO_ARGUMENT],
                           ["-f","--file", GetoptLong::REQUIRED_ARGUMENT],
                           ["-e","--extension", GetoptLong::REQUIRED_ARGUMENT],
                           ["-d","--database", GetoptLong::REQUIRED_ARGUMENT],
                           ["-l","--load", GetoptLong::REQUIRED_ARGUMENT]
                           )
  
  options.each do |opt,arg|
    case opt
    when "-p"
      print = true
    when "-v" 
      verbose = true
    when "-h"
      usage
      exit 1
    when "-f"
      wurflfile = arg
    when "-e"
      patchfile = arg
    when "-d"
      pstorefile = arg
    when "-l"
      pstorefile = arg
      pstoreload = true
    else
      STDERR.puts "Unknown argument #{opt}"
      usage
    exit 1
    end    
  end
rescue => err
  STDERR.puts "Error: #{err}"
  usage
  exit 1
end

wurfll = WurflLoader.new
hands = nil
fallbacks = nil

if pstorefile && pstoreload
  begin
    puts "Loading  data from #{pstorefile}"
    hands, fallbacks = load_wurfl_pstore(pstorefile)
    puts "Loaded"
  rescue => err
    STDERR.puts "Error: Cannot load PStore file."
    STDERR.puts err.message
    exit 1
  end
else    
  if !wurflfile 
    STDERR.puts "You must pass a wurflfile if you want to do more."
    usage
    exit 1
  end
  
  starttime = Time.now
  puts "Loading wurfl file #{wurflfile}" 
  
  wurfll.verbose = verbose

  hands, fallbacks = wurfll.load_wurfl(wurflfile)
  restime = Time.now - starttime
  
  puts "Done loading wurfl.  Load took #{restime} seconds." 

  if patchfile
    starttime = Time.now
    puts "Loading Patch file #{patchfile}"
    hands, fallbacks = wurfll.load_wurfl(patchfile)
    restime = Time.now - starttime
    puts "Done loading patchfile.  Load took #{restime} seconds." 
  end
  
end

if pstorefile && !pstoreload
  begin
    puts "Saving data into #{pstorefile}"
    save_wurfl_pstore(pstorefile, hands, fallbacks)
    puts "Saved"
  rescue => err
    STDERR.puts "Error: Cannot creat PStore file."
    STDERR.puts err.message
  end
end

if print 
  wurfll.print_wurfl hands
end
  
