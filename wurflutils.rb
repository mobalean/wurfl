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

# $Id: wurflutils.rb,v 1.1 2003/11/23 12:26:05 zevblut Exp $
# Authors: Zev Blut (zb@ubit.com)

require "pstore"

=begin
A simple module to hold commonly used methods for the WURFL.
This is currently just loading and saving a WURFL PStore database.
=end
module WurflUtils

  # Does not catch exception, but throws to the caller.  
  def load_wurfl_pstore(pstorefile)
    pstore = PStore.new(pstorefile)
    handsets = fallbacks = nil
    pstore.transaction do |ps|
      handsets = ps["handsets"]
      fallbacks = ps["fallback"]
    end      
    return handsets,fallbacks
  end

  #Also throws exceptions to the caller.
  def save_wurfl_pstore(pstorefile,handsets,fallbacks)
    store = PStore.new(pstorefile)
    store.transaction do |ps|
      ps["handsets"] = handsets
      ps["fallback"] = fallbacks
    end
  end

end
