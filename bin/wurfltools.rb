#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.dirname(__FILE__), '..',  'lib')

def usage
  puts "usage: wurfltools.rb command options"
  exit
end

usage if ARGV.size < 1

command = ARGV.shift

require "wurfl/command/#{command}"

c = Wurfl::Command.const_get(command.capitalize).new
c.execute
