require "wurfl/command"
require "getoptlong"
require "wurfl/handset"
require "wurfl/utils"

class Wurfl::Command::Comparator < Wurfl::Command
  include Wurfl::Utils

  def usage
    puts "Usage: wurfltools.rb comparator wurfl_pstore1_db wurfl_pstore2_db  "
    exit 1
  end

  def execute
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
  end
end
