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

# $Id: wurflinspector.rb,v 1.1 2003/11/23 12:26:05 zevblut Exp $
# Authors: Zev Blut (zb@ubit.com)

require "getoptlong"
require "wurfl/wurflhandset"
require "wurfl/wurflutils"

=begin
A class that lists wurfl handsets that match user specified search 
criteria.
=end
class WurflInspector

  # Constructor
  # Parameters:
  # handsets: A hashtable of wurfl handsets indexed by wurfl_id.
  def initialize(handsets)
    @handsets = handsets
  end
  
  # A method to get the WurflHandset that matches the passed wurfl_id.
  # Parameters:
  # id: is the wurfl_id of the WurflHandset to get.
  # Returns:
  # The WurflHandset that has the requested wurfl_id.  If the wurfl_id
  # is not found, then nil is returned.
  def get_handset(id)
    return @handsets[id]
  end

  # A method to retrieve a list of the inspector's handsets that match
  # the passed search criteria.
  # Parameters:
  # proc: is a Proc object that defines a function that returns 
  # true or false from an evaluattion with a WurflHandset.
  # Returns:
  # An Array of all WurflHandsets that match the proc evaluation.
  def search_handsets(proc)
    rez = @handsets.values.select do |hand|  
      x = proc.call(hand)       
    end
    return rez if rez != nil
    return Array::new
  end

end


if __FILE__ == $0 then
  include WurflUtils

  def usage
    puts "Usage: wurflinspector.rb  [-s rubyblock] [-i handsetid [-q attributename]]  -d pstorefile"
    puts "Examples:"
    puts "wurflinspector.rb -d pstorehandsets.db -s '{ |hand| hand[\"colors\"].to_i > 2 }'"
    puts "wurflinspector.rb -d pstorehandsets.db -i sonyericsson_t300_ver1"
    puts "wurflinspector.rb -d pstorehandsets.db -i sonyericsson_t300_ver1 -q backlight"
    exit 1
  end

  pstorefile = nil
  procstr = nil 
  handset = nil
  query = nil
  begin
    opt = GetoptLong.new(
			 ["-d","--database", GetoptLong::REQUIRED_ARGUMENT],
			 ["-s","--search", GetoptLong::REQUIRED_ARGUMENT],
			 ["-i","--id", GetoptLong::REQUIRED_ARGUMENT],
			 ["-q","--query", GetoptLong::REQUIRED_ARGUMENT]
			 )
    
    opt.each do |arg,val|
      case arg
      when "-d"
	pstorefile = val
      when "-s"
	procstr = val.strip
      when "-i"
	handset = val
      when "-q"
	query = val
      else
	usage
      end
    end

  rescue => err
    usage
  end

  if !pstorefile
    puts "You must specify a Wurfl PStore db"
    usage
  end
  
  begin
    handsets, = load_wurfl_pstore(pstorefile)    
    insp = WurflInspector.new(handsets)
  rescue => err
    STDERR.puts "Error with file #{pstorefile}"
    STDERR.puts err.message
    exit 1
  end

  if procstr
    pr = nil
    eval("pr = proc#{procstr}")
    
    if pr.class != Proc
      puts "You must pass a valid ruby block!"
      exit 1
    end
    
    puts "--------- Searching handsets -----------"
    res = insp.search_handsets(pr)
    puts "Number of results: #{res.size}"
    
    res.each { |handset| puts handset.wurfl_id }
    exit 0
  end


  if handset
    handset = insp.get_handset(handset)
    puts "Handset user agent: #{handset.user_agent}"
    if query
      puts "Result of handset query: #{query}"
      rez = handset.get_value_and_owner(query)
      puts "#{rez[0]} from #{rez[1]}"
    else
      puts "Attributes of handset"
      keys = handset.keys
      keys.each do |key|
	rez = handset.get_value_and_owner(key)
	puts "Attr:#{key} Val:#{rez[0]} from #{rez[1]}"
      end
    end
    exit 0
  end

end
