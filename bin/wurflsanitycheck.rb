#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.dirname(__FILE__), '..',  'lib')

# A simple command line tool to make sure that a wurfl file properly parses.
# Used to make sure changes to Wurfl/Patch files are OK.
if ARGV.size != 1
   puts "Must have the path of the wurfl file to check"
   exit 1
end
lines = File.open(ARGV[0],"r").readlines

curdev = nil
c = 0

lines.each do |line|
  line = line.strip
  if line =~ /^(<d)evice.*[^\/]>$/
    curdev = line
  elsif line =~ /^(<d)evice.*\/>$/
    if curdev
      puts "#{c}:A device was not closed and we got a new device! #{curdev}"
    end
    curdev = nil
  elsif line =~ /^(<\/d)evice>$/
    if curdev.nil?
      puts "#{c}:A closing device with no opening! #{curdev}"
    end
    curdev=nil
  end
  c += 1
end

if curdev
  puts "The curent device was not closed #{curdev}"
end


puts "Done"
