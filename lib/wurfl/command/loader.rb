require "wurfl/command"

require "getoptlong"
require "wurfl/utils"
require "wurfl/loader"

class Wurfl::Command::Loader < Wurfl::Command
  include Wurfl::Utils

  def usage
    puts "Usage: wurfltools.rb loader [-p -v -h -e patchfile] -f wurflfile"
    puts "       --file, -f (wurflfile): The master WURFL file to load."
    puts "       --extension, -e (patchfile): A patch file to extend the traits of the master WURLF file."
    puts "       --print, -p : Prints out handsets."
    puts "       --help, -h : Prints this message."
    puts "       --database, -d (databasename): Makes a PStore database for quick loading of data with other tools."
    puts "       --load, -l (databasename): Loads handsets from a PStore database instead of XML file."
    exit 1
  end

  def execute
    print = false
    insert = false
    wurflfile = nil
    patchfile = nil
    pstorefile = nil
    pstoreload = false

    begin
      options = GetoptLong.new(
                               ["-p","--print", GetoptLong::NO_ARGUMENT],
                               ["-h","--help", GetoptLong::NO_ARGUMENT],
                               ["-f","--file", GetoptLong::REQUIRED_ARGUMENT],
                               ["-e","--extension", GetoptLong::REQUIRED_ARGUMENT],
                               ["-d","--database", GetoptLong::REQUIRED_ARGUMENT],
                               ["-l","--load", GetoptLong::REQUIRED_ARGUMENT]
                               )
      
      options.each do |opt,arg|
        case opt
        when "-p"
          print = true
        when "-h"
          usage
          exit 1
        when "-f"
          wurflfile = arg
        when "-e"
          patchfile = arg
        when "-d"
          pstorefile = arg
        when "-l"
          pstorefile = arg
          pstoreload = true
        else
          STDERR.puts "Unknown argument #{opt}"
          usage
        exit 1
        end    
      end
    rescue => err
      STDERR.puts "Error: #{err}"
      usage
      exit 1
    end

    wurfll = Wurfl::Loader.new
    hands = nil
    fallbacks = nil

    if pstorefile && pstoreload
      begin
        puts "Loading  data from #{pstorefile}"
        hands, fallbacks = load_wurfl_pstore(pstorefile)
        puts "Loaded"
      rescue => err
        STDERR.puts "Error: Cannot load PStore file."
        STDERR.puts err.message
        exit 1
      end
    else    
      if !wurflfile 
        STDERR.puts "You must pass a wurflfile if you want to do more."
        usage
        exit 1
      end
      
      starttime = Time.now
      puts "Loading wurfl file #{wurflfile}" 
      
      hands, fallbacks = wurfll.load_wurfl(wurflfile)
      restime = Time.now - starttime
      
      puts "Done loading wurfl.  Load took #{restime} seconds." 

      if patchfile
        starttime = Time.now
        puts "Loading Patch file #{patchfile}"
        hands, fallbacks = wurfll.load_wurfl(patchfile)
        restime = Time.now - starttime
        puts "Done loading patchfile.  Load took #{restime} seconds." 
      end
      
    end

    if pstorefile && !pstoreload
      begin
        puts "Saving data into #{pstorefile}"
        save_wurfl_pstore(pstorefile, hands, fallbacks)
        puts "Saved"
      rescue => err
        STDERR.puts "Error: Cannot creat PStore file."
        STDERR.puts err.message
      end
    end

    if print 
      wurfll.print_wurfl hands
    end
      
  end
end
