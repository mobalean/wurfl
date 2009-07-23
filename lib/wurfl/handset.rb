require "singleton"

module Wurfl; end

=begin
A class that represents a handset based on information taken from the WURFL.
=end
class Wurfl::Handset

  extend Enumerable

  attr_accessor :wurfl_id, :user_agent
  attr_reader :fallback

  # Constructor
  # Parameters:
  # wurfl_id: is the WURFL ID of the handset
  # useragent: is the user agent of the handset
  # fallback: is the fallback handset that this handset
  #           uses for missing details.
  def initialize (wurfl_id, useragent, fallback = nil) 
    # A hash to hold keys and values specific to this handset
    @capabilityhash = Hash::new 
    @wurfl_id = wurfl_id
    @user_agent = useragent
    @fallback = fallback || NullHandset.instance
  end

  def fallback=(v)
    @fallback = v || NullHandset.instance
  end

  # Hash accessor
  # Parameters: 
  # key: the WURFL key whose value is desired
  # Returns:
  # The value of the key, nil if the handset does not have the key.
  def [] (key)
    @capabilityhash.key?(key) ? @capabilityhash[key] : @fallback[key]
  end

  # like the above accessor, but also to know who the value
  # comes from
  # Returns:
  # the value and the id of the handset from which the value was obtained
  def get_value_and_owner(key)
    if @capabilityhash.key?(key)
      [ @capabilityhash[key], @wurfl_id ]
    else
      @fallback.get_value_and_owner(key)
    end
  end

  # Setter, A method to set a key and value of the handset.
  def []= (key,val)
    @capabilityhash[key] = val
  end

  # A Method to iterate over all of the keys and values that the handset has.
  # Note: this will abstract the hash iterator to handle all the lower level
  # calls for the fallback values.
  def each
    self.keys.each do |key|
      # here is the magic that gives us the key and value of the handset
      # all the way up to the fallbacks end.  
      # Call the pass block with the key and value passed
      yield key, self[key]
    end
  end
  
  # A method to get all of the keys that the handset has.
  def keys
    @capabilityhash.keys | @fallback.keys
  end

  # A method to do a simple equality check against two handsets.
  # Parameter:
  # other: Is the another WurflHandset to check against.
  # Returns:
  # true if the two handsets are equal in all values.
  # false if they are not exactly equal in values, id and user agent.
  # Note: for a more detailed comparison, use the compare method.
  def ==(other)
    other.instance_of?(Wurfl::Handset) && 
      self.wurfl_id == other.wurfl_id && 
      self.user_agent == other.user_agent &&
      other.keys.all? {|key| other[key] == self[key] }
  end

  def differences(other)
    keys = (self.keys | other.keys)
    keys.find_all {|k| self[k] != other[k]}
  end

  class NullHandset
    include Singleton

    # In ruby 1.8.6 and before, this method is not public, and thus prevents
    # NullHandsets from being deserialized
    class << self
      public :_load
    end

    def [](key) nil end
    def get_value_and_owner(key) [ nil, nil ] end
    def keys; [] end
  end
end
