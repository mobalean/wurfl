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

  def display_differences(hand1, hand2)
    puts "-------------------------------------"
    puts "WURFL_ID: #{hand1.wurfl_id}" 
    puts "Handset 1: #{hand1.user_agent}"
    puts "Handset 2: #{hand2.user_agent}"
    hand1.differences(hand2).each do |key|
      v1, v2 = hand1[key], hand2[key]
      puts "Key:#{key}"
      puts "h1>:#{hand1[key]}"
      puts "h2<:#{hand2[key]}"
    end
    puts "-------------------------------------"
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

    wurfl1_unknown, wurfl2_unknown, different = [],[],[]
    (wurfl1.keys | wurfl2.keys).each do |key|
      handset1, handset2 = wurfl1[key], wurfl2[key]
      if !handset1
        wurfl1_unknown << key
      elsif !handset2
        wurfl2_unknown << key
      elsif handset1 != handset2
        display_differences(handset1,handset2)
      end
    end


    puts "Comparision complete."

    puts "Handsets not found in wurfl1: #{wurfl1_unknown.inspect}"
    puts "Handsets not found in wurfl2: #{wurfl2_unknown.inspect}"
  end
end
