#!/usr/bin/env ruby

# Copyright (c) 2003, Ubiquitous Business Technology (http://ubit.com)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#
#    * Redistributions in binary form must reproduce the above
#      copyright notice, this list of conditions and the following
#      disclaimer in the documentation and/or other materials provided
#      with the distribution.
#
#    * Neither the name of the WURFL nor the names of its
#      contributors may be used to endorse or promote products derived
#      from this software without specific prior written permission.
#
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# $Id: wurflcomparator.rb,v 1.1 2003/11/23 12:26:05 zevblut Exp $
# Authors: Zev Blut (zb@ubit.com)

require "getoptlong"
require "wurfl/wurflhandset"
require "wurfl/wurflutils"

include WurflUtils

def usage
  puts "Usage: wurflcomparator.rb wurfl_pstore1_db wurfl_pstore2_db  "
  exit 1
end

if ARGV.size != 2
  usage
end

# load the wurfl databases
wurfl1 = wurfl2 = nil
begin
  wurfl1, = load_wurfl_pstore(ARGV[0])
  wurfl2, = load_wurfl_pstore(ARGV[1])
rescue => err
  efile = ""
  if wurfl1.nil?
    efile = ARGV[0]
  else
    efile = ARGV[1]
  end
  STDERR.puts "Error with file #{efile}"
  STDERR.puts err.message
  exit 1
end

puts "Comparing files: #{ARGV[0]} and #{ARGV[1]}"
puts "-------------------------------------"

if wurfl1.size > wurfl2.size
  mwurfl = wurfl1
  lwurfl = wurfl2    
else
  mwurfl = wurfl2
  lwurfl = wurfl1
end

notfound = Array.new
different = Array.new
mwurfl.each do |key,handset|
  if lwurfl.key?(key)
    if handset != lwurfl[key]
      different<< [handset,lwurfl[key]]
    end
  else
    notfound<< handset
  end
end


puts "Comparision complete."

puts "Not Found Handsets: #{notfound.size}"
puts "||||||||||||||||||||||||||||||||||||"
notfound = notfound.sort { |x,y| y.wurfl_id <=> x.wurfl_id }
notfound.each { |hand| puts hand.wurfl_id }           
puts "||||||||||||||||||||||||||||||||||||"

puts "Different handsets: #{different.size}"
puts "||||||||||||||||||||||||||||||||||||"
different = different.sort { |x,y| y.first.wurfl_id <=> x.first.wurfl_id }
different.each do |hand1,hand2|
  puts "-------------------------------------"
  puts "Handset: #{hand1.user_agent} :ID: #{hand1.wurfl_id}"
  diffkeys = hand1.compare(hand2)
  diffkeys.each do |key,oval,oid|
    next if hand1[key].nil? || hand2[key].nil?
    puts "Key:#{key}"
    puts "h1>:#{hand1[key]}"
    puts "h2<:#{hand2[key]}"
  end
  puts "-------------------------------------"
end

puts "||||||||||||||||||||||||||||||||||||"

