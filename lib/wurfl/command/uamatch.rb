require "wurfl/command"
require "wurfl/utils"
require "wurfl/handset"
require "wurfl/user_agent_matcher"
require "getoptlong"

=begin
  The uamatch command itself is based on the inspector command found in this
  library.
  
  Author:  Kai W. Zimmermann (kwz@kai-zimmermann.de)
=end
class Wurfl::Command::Uamatch < Wurfl::Command
  include Wurfl::Utils

  def usage
    puts "Usage: wurfltools.rb uamatch [-u user_agent [-q attributename]] -d pstorefile"
    puts "Examples:"
    puts "wurfltools.rb uamatch -d pstorehandsets.db -u SL55"
    puts "wurfltools.rb uamatch -d pstorehandsets.db -u SL55 -q wallpaper_jpg"
    exit 1
  end

  def execute
    pstorefile = nil
    useragent = nil
    query = nil
    begin
      opt = GetoptLong.new(
                           ["-d","--database", GetoptLong::REQUIRED_ARGUMENT],
                           ["-u","--useragent", GetoptLong::REQUIRED_ARGUMENT],
                           ["-q","--query", GetoptLong::REQUIRED_ARGUMENT]
                           )
      
      opt.each do |arg,val|
        case arg
        when "-d"
          pstorefile = val
        when "-u"
          useragent = val
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
      puts "Number of Handsets: #{handsets.length}"
      uamatch = Wurfl::UserAgentMatcher.new(handsets)
    rescue => err
      STDERR.puts "Error with file #{pstorefile}"
      STDERR.puts err.message
      exit 1
    end

    if useragent 
      matches, distance = uamatch.match_handsets(useragent)
      puts "Shortest distance #{distance}, #{matches.length} match#{'es' if (matches.length!=1)}" 
      matches.each do |handset|
        puts "Handset wurfl id: #{handset.wurfl_id}"
        puts "User_agent found: #{handset.user_agent}"
        if query
          puts "Result of handset query: #{query}"
          rez = handset.get_value_and_owner(query)
          puts "#{rez[0]} from #{rez[1]}"
        end
      end
      exit 0
    end
  end
end
