#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.dirname(__FILE__), '..',  'lib')

def usage
  puts "usage: wurfltools.rb command options"
  path = "#{File.dirname(__FILE__)}/../lib/wurfl/command/*"
  a = Dir.glob(path).map {|s| File.basename(s,".rb")}
  puts "available commands:"
  puts a
  exit
end

usage if ARGV.size < 1

command = ARGV.shift

require "wurfl/command/#{command}"

c = Wurfl::Command.const_get(command.capitalize).new
c.execute
