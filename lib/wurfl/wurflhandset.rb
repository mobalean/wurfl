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

# $Id: wurflhandset.rb,v 1.1 2003/11/23 12:26:05 zevblut Exp $
# Authors: Zev Blut (zb@ubit.com)

=begin
A class that represents a handset based on information taken from the WURFL.
=end
class WurflHandset

  extend Enumerable

  attr_accessor :wurfl_id, :user_agent, :fallback

  # Constructor
  # Parameters:
  # wurfl_id: is the WURFL ID of the handset
  # useragent: is the user agent of the handset
  # fallback: is the fallback handset that this handset
  #           uses for missing details.
  def initialize (wurfl_id,useragent,fallback=nil) 
    # A hash to hold keys and values specific to this handset
    @capabilityhash = Hash::new 
    @wurfl_id = wurfl_id
    @user_agent = useragent
    @fallback = fallback
  end

  # Hash accessor
  # Parameters: 
  # key: the WURFL key whose value is desired
  # Returns:
  # The value of the key, nil if the handset does not have the key.
  def [] (key)
    # Check if the handset actually has the key
    if @capabilityhash.key?(key)
      return @capabilityhash[key]
    else
      # The handset does not so check if the fallback handset does
      # Note: that this is actually a recursive call.
      if @fallback != nil
	return @fallback[key]
      end
    end
    # if it gets this far then no one has the key
    return nil
  end

  # like the above accessor, but also to know who the value
  # comes from
  # Returns:
  # the value and the id of the handset from which the value was obtained
  def get_value_and_owner(key)
    return @capabilityhash[key],@wurfl_id if @capabilityhash.key?(key)
    return @fallback.get_value_and_owner(key) if @fallback != nil
    return nil,nil
  end

  # Setter, A method to set a key and value of the handset.
  def []= (key,val)
    @capabilityhash[key] = val
  end

  # A Method to iterate over all of the keys and values that the handset has.
  # Note: this will abstract the hash iterator to handle all the lower level
  # calls for the fallback values.
  def each
    keys = self.keys
    keys.each do |key|
      # here is the magic that gives us the key and value of the handset
      # all the way up to the fallbacks end.  
      # Call the pass block with the key and value passed
      yield key, self[key]
    end
  end
  
  # A method to get all of the keys that the handset has.
  def keys
    # merge the unique keys of the handset and it's fallback
    return @capabilityhash.keys | @fallback.keys if @fallback != nil
    # no fallback so just return the handset's keys
    return @capabilityhash.keys
  end

  # A method to do a simple equality check against two handsets.
  # Parameter:
  # other: Is the another WurflHandset to check against.
  # Returns:
  # true if the two handsets are equal in all values.
  # false if they are not exactly equal in values, id and user agent.
  # Note: for a more detailed comparison, use the compare method.
  def ==(other)
    return false if other.nil? || other.class != WurflHandset
    if (self.wurfl_id == other.wurfl_id) && (self.user_agent == other.user_agent)
      other.each do |key,value|
        return false if value != self[key]
      end
      return true
    end
    return false
  end

  # A method to compare a handset's values against another handset.
  # Parameters:
  # other: is the another WurflHandset to compare against
  # Returns:
  # An array of the different values.
  # Each entry in the Array is an Array of three values.
  # The first value is the key in which both handsets have different values.
  # The second is the other handset's value for the key.
  # The third is the handset id from where the other handset got it's value.
  def compare(other)
    differences = Array.new
    self.keys.each do |key|
      oval,oid = other.get_value_and_owner(key)
      if @capabilityhash[key].to_s != oval.to_s
	differences<< [key,oval,oid]
      end
    end
    return differences
  end

end
