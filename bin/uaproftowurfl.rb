#!/usr/bin/env ruby

# Copyright (c) 2003, Zev Blut (zb@104.com)
# All rights reserved.
#
# Copyright (c) 2009, mobalean (http://www.mobalean.com/)
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
#    * Neither the name of the UAProfToWURFL nor the names of its
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

$LOAD_PATH << File.join(File.dirname(__FILE__), '..',  'lib')
require "wurfl/uaproftowurfl"

if $0 == __FILE__
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
  
end
