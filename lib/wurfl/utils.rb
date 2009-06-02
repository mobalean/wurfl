require "pstore"

module Wurfl; end

=begin
A simple module to hold commonly used methods for the WURFL.
This is currently just loading and saving a WURFL PStore database.
=end
module Wurfl::Utils

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
