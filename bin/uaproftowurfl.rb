#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.dirname(__FILE__), '..',  'lib')
require "wurfl/uaproftowurfl"

# The code below is called if this file is executed from the command line.

def usage    
  puts "Usage: usaprofparser.rb uaprof_files"
  puts "No files passed to parse."
  exit 1
end

if ARGV.size == 0
  usage
end

uaprof = Wurfl::UAProfToWURLF.new

# Parse all the files and merge them into one UAProf.
# Following profs take precedence of previous ones
ARGV.each do |file|
  uaprof.parse_UAProf(file)
end

# Now output the mapped WURFL to standard out
uaprof.output_WURFL
  
