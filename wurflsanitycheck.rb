#!/usr/local/bin/ruby -w

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

# $Id: wurflsanitycheck.rb,v 1.1 2003/11/23 12:26:05 zevblut Exp $
# Authors: Zev Blut (zb@ubit.com)

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
