require "pstore"

module Wurfl; end

=begin
A simple module to hold commonly used methods for the WURFL.
This is currently just loading and saving a WURFL PStore database.
=end
module Wurfl::Utils

  # Does not catch exception, but throws to the caller.  
  def load_wurfl_pstore(pstorefile)
    PStore.new(pstorefile).transaction {|ps| ps["handsets"]}
  end

  #Also throws exceptions to the caller.
  def save_wurfl_pstore(pstorefile,handsets)
    PStore.new(pstorefile).transaction {|ps| ps["handsets"] = handsets}
  end

end
