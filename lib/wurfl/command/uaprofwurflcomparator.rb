require "wurfl/command"
require "getoptlong"
require "net/http"

require "wurfl/uaproftowurfl"
require "wurfl/handset"
require "wurfl/utils"
include Wurfl::Utils

# An addition to the UAProf to Wurfl to generate a WurflHandset from the UAProf.      
class Wurfl::UAProfToWURLF
  def make_wurfl_handset
    hand = Wurfl::Handset.new("UAProf",@wurfl["user_agent"])
    @wurflgroups.each do |group|
      @wurfl[group].sort.each do |key,value|
	hand[key] =  value
      end
    end
    return hand
  end
end


class Wurfl::Command::Uaprofwurflcomparator
  def parse_mapping_file(file)
    if !File.exist?(file)
      $stderr.puts "Mapping File does not exist.  File passed was #{file}."
      return Array.new
    end
    mappings = Array.new
    f = File.new(file)
    f.each do |line|
      if m = /^"(.*)" "(.*)"$/.match(line.strip)
        uaprof = m[1]
        useragent = m[2]
        mappings<< [uaprof,useragent]
      else
        $stderr.puts "Irregular format for line: #{line}" if line.strip != ""
      end
    end
    f.close

    return mappings
  end

  def get_uaprofile(uaprof,profiledir,check=false)
    file = strip_uaprof(uaprof)
    if File.exists?("#{profiledir}/#{file}") && check
      return file
    end
    
    get_and_save_uaprof_file(uaprof,profiledir)
    return file
  end

  def strip_uaprof(uaprof)
    uaprof_file = nil
    if m = /([^\/]*)$/.match(uaprof)
      uaprof_file = m[1]
    else
      $stderr.puts "Cannot find the base UAProf file in URI: #{uaprof}"
    end
    return uaprof_file
  end

  def load_pstore(pstorefile)
    hands = Hash.new
    begin
      handsid, = load_wurfl_pstore(pstorefile)
      handsid.each { |id,val| hands[val.user_agent] = val }
    rescue => err
      $stderr.puts "Error: Cannot load PStore file. #{pstorefile}"
      $stderr.puts err.message
      exit 1
    end
    return hands
  end

  def get_and_save_uaprof_file(uaprof_url,savedirectory,limit=0)
    base,path,port = parse_url(uaprof_url)
    
    raise "Too many redirects from original url" if limit > 3
    raise "Unparseable URL: #{url}" if base.nil?

    port = 80 if port.nil?
    http = Net::HTTP.new(base,port)
    begin
      resp, data = http.get(path)
      if resp.code == "301"
        # get location and call self again
        http.finish
        limit += 1
        get_and_save_uaprof_file(resp['location'],savedirectory,limit)
        return
      elsif resp.code != "200"
        raise "Unexpected HTTP Response code:#{resp.code} for #{uaprof_url}"
      end
    rescue => err
      raise
    end

    f = File.new("#{savedirectory}/#{strip_uaprof(path)}","w")
    f.write(data)  
    f.close
    
  end

  def parse_url(url)
    m = /(http:\/\/)?(.*?)(:(\d*))?\/(.*)/i.match(url.strip)
    
    return nil if m.nil?
    return m[2],"/#{m[5]}",m[4]
  end

  def usage
    puts "Usage: wurfltools.rb uaprofwurflcomparator -d profiledirectory -f mappingfile [-w wurfldb] [-c] [-h | --help]"
    puts "Examples:"
    puts "wurfltools.rb uaprofwurflcomparator -d ./profiles -f all-profile.2003-08.log -c -w wurfl.db"
    exit 1
  end

  def help
    puts "-d --directory : The directory to store the UA Profiles found in the log file."
    puts "-f --file : The log file that has a UAProfile to User-Agent mapping per line."
    puts "-c --check : A flag that will make sure to check if the profile is already in the directory or not.  If it is not then it will download it."
    puts "-w --wurfldb : A Ruby PStore Database of the WURFL, that is used to compare against the UAProfiles."
    puts "-h --help : This message."
    exit 1
  end

  def execute
    profiledirectory = mappingfile = pstorefile = nil
    existancecheck = false
    begin
      opt = GetoptLong.new(
                           ["-d","--directory", GetoptLong::REQUIRED_ARGUMENT],
                           ["-f","--file", GetoptLong::REQUIRED_ARGUMENT],
                           ["-c","--check", GetoptLong::NO_ARGUMENT],
                           ["-h","--help", GetoptLong::NO_ARGUMENT],
                           ["-w","--wurfldb", GetoptLong::REQUIRED_ARGUMENT]
                           )
      
      opt.each { |arg,val|
        case arg
        when "-d"
          profiledirectory = val.strip
        when "-f"
          mappingfile = val.strip
        when "-c"
          existancecheck = true
        when "-h"
          help
        when "-w"
          pstorefile = val.strip
        else
          usage
        end
      }
      usage if mappingfile.nil? || profiledirectory.nil?
    rescue => err
      usage
    end

    profiles = Hash.new
    duplicates = Hash.new
    mappings = parse_mapping_file(mappingfile)
    mappings.each do |uaprof,useragent|
      begin
        prof_file = get_uaprofile(uaprof,profiledirectory,existancecheck)
        uaprof_mapper = UAProfToWURLF.new
        if profiles.key?(useragent)
          duplicates[useragent] = Array.new if !duplicates.key?(useragent)
          duplicates[useragent]<<uaprof
          next
        end
        uaprof_mapper.parse_UAProf("#{profiledirectory}/#{prof_file}")
        profiles[useragent] = uaprof_mapper
      rescue => err
        $stderr.puts "Error: File #{prof_file}; User-Agent:#{useragent}"
        $stderr.puts "Error:#{err.message}"      
      end  
    end

    duplicates.each do |key,profs|
      $stderr.puts "Duplicates exist for #{key}"
      profs.each {|prof| $stderr.puts "-- #{prof}" }
    end

    exit 0 if !pstorefile

    wurflhandsets = load_pstore(pstorefile)

    puts "Comparing WURFL Handsets"
    profiles.each do |key,val|
      puts "",""
      
      if !wurflhandsets.key?(key)
        puts "UAProf has a new Handset: #{key}"
        puts "--------------------------------"
        val.output_WURFL
        puts "--------------------------------"
      else
        uahand = val.make_wurfl_handset                   
        res = uahand.compare(wurflhandsets[key])
        if res.size > 0
          puts "#{key} : For UAProf and WURFL differ"
          res.each do |dkey,dval,did|
            next if did == "generic"
            #Key UAPROF Value WURFL Value WURFL source id
            puts "  Key:#{dkey}; UVAL:#{uahand[dkey]}; WVAL:#{dval}; WSRCID:#{did}"
          end
          #val["user_agent"] = key
          puts ""
          puts "WURFL Changes are:"
          puts ""	  
          val.output_WURFL(res.map {|entry| entry[0]})
        else
          puts "#{key} : For UAProf and WURFL match"
        end
      end
    end
  end
end
 
