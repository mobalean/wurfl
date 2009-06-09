require "wurfl/command"
require "wurfl/uaproftowurfl"

class Wurfl::Command::Uaproftowurfl
  def execute
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

  def usage    
    puts "Usage: wurfltools.rb uaproftowurfl uaprof_files"
    puts "No files passed to parse."
    exit 1
  end
end

