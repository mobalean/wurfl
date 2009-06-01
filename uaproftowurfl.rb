#!/usr/bin/env ruby

# Copyright (c) 2003, Zev Blut (zb@104.com)
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
#    * Neither the name of the UAProfToWURFL nor the names of its
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

require "rexml/document"

# A class to handle reading a UAProfile and generating an equivalent 
# WURFL entry.
# See http://wurfl.sourceforge.net/ for more details about the WURFL.
# Author: Zev Blut
# Version: 1.1 Additional mappings added from Andrea Trasatti
# Version: 1.2 More mappings added from Andrea Trasatti
# Version: 1.3 more mappings and a few changes for error handling.
class UAProfToWURLF

  def initialize
    # The WURFL is considered a hashtable of hashtables for all the
    # wurfl groups.
    @wurfl = Hash.new
    #Initialize all of the sub hashes
    @wurflgroups = [
      "product_info","wml_ui","chtml_ui","xhtml_ui",
      "markup","cache","display","image_format","bugs",
      "wta","security","storage","downloadfun","wap_push",
      "j2me","mms","sound_format"
    ]
    @wurflgroups.each do |key|
      @wurfl[key] = Hash.new
    end    
    @wurfl["user_agent"] = ""
  end

  # Takes a UAProfile file (in the future could also take a URL)
  # and then calls the method named after each UAProfile entry.
  # This then maps the UAProfile component entry to a WURFL entry.
  # This method can be called multiple times to create patched WURFL
  # entry.
  def parse_UAProf(uaproffile)
    file = File.new(uaproffile)
    begin
      doc = REXML::Document.new(file)
    rescue Exception => err
      $stderr.puts "Exception while parsing the UAProfile RDF file #{uaproffile}."
      $stderr.puts "This UAProfToWurfl instance is invalid."
      $stderr.puts err.class
      $stderr.puts err.message
      $stderr.puts err.backtrace
      return
    end

    #get rdf:Description ID as that says the profile of phone..?
    doc.elements.each("rdf:RDF/rdf:Description/prf:component/rdf:Description/*") do |element|
      #doc.elements.each("//rdf:Description/*") do |element|
      next if element.expanded_name == "rdf:type" #ignore the type value
      methodname = make_method_name(element.name)
      if self.respond_to?(methodname)
	begin
	  method = self.method(methodname)
	  method.call(element)
	rescue Exception => err
	  $stderr.puts "Uncaught exception calling #{element.name}"
	  $stderr.puts err.class
	  $stderr.puts err.message
	  $stderr.puts err.backtrace
	end
      else
	$stderr.puts "Undefined UAProf component: #{element.name}"
      end
    end
  end

  # Generates a WURFL entry.
  # For now simply outputs the XML to Standard Out.  
  def output_WURFL(filters=nil)
    puts "<device fall_back=\"generic\" id=\"UAProf\" user_agent=\"#{@wurfl["user_agent"]}\">"
    @wurflgroups.each do |group|
      next if @wurfl[group].size == 0 || (!filters.nil? && (@wurfl[group].keys & filters.to_a).size == 0)
      puts "  <group id=\"#{group}\">"
      @wurfl[group].sort.each do |key,value|
	next if !filters.nil? && !filters.include?(key)
	puts "    <capability name=\"#{key}\" value=\"#{value}\"/>"
      end
      puts "  </group>"
    end
    puts "</device>"
  end


  ######################################################################
  # UAProfile Mappings
  # Each entry below is an item in the UAProfile.
  # The element is the XML entry that contains the data about the 
  # UAProfile item.  It is used to then create a mappings to the WURFL.
  ######################################################################


  def BitsPerPixel(element)
    bits = element.text.to_i
    bits = 2 ** bits if bits !=2 
    @wurfl["image_format"]["colors"] = bits
  end

  def ColorCapable(element)
    if element.text == "No"
      if @wurfl["image_format"].key?("colors")
	if @wurfl["image_format"]["colors"] > 2      
	  @wurfl["image_format"]["greyscale"] = true
	end
      else
	$stderr.puts "ColorCapable called before BitsPerPixel, thus unable to determine if greyscale."
      end
    end
  end

  def CPU(element)
  end

  def ImageCapable(element)
  end
  
  def InputCharSet(element)
  end

  def Keyboard(element)
  end
  
  def Model(element)
    @wurfl["product_info"]["model_name"] = element.text
  end

  def NumberOfSoftKeys(element)
    num = element.text.to_i
    if num > 0
      @wurfl["wml_ui"]["softkey_support"] = true
      @wurfl["j2me"]["j2me_softkeys"] = num # in theory we should only check this if j2me support exists
    end
  end

  def OutputCharSet(element)
  end

  def PixelAspectRatio(element)
  end

  def PointingResolution(element)
  end

  def ScreenSize(element)
    width, height = break_num_x_num(element.text)
    @wurfl["display"]["resolution_width"] = width
    @wurfl["display"]["resolution_height"] = height
  end
  
  def ScreenSizeChar(element)
    columns,rows = break_num_x_num(element.text)
    @wurfl["display"]["columns"] = columns
    @wurfl["display"]["rows"] = rows
  end

  def StandardFontProportional(element)
  end

  def SoundOutputCapable(element)
  end

  def TextInputCapable(element)
  end
  
  def VoiceInputCapable(element)
  end

  def Vendor(element)
    @wurfl["product_info"]["brand_name"] = element.text
  end

  ########## SoftwarePlatform
  def AcceptDownloadableSoftware(element)
    #?good to know?
  end
  
  def AudioInputEncoder(element)
  end
 
  # This one does a large amount of mapping
  def CcppAccept(element)   
    items = get_items_from_bag(element)
    items.each do |type|
      # Use regular expression comparisons to deal with values
      # that sometimes contain q or Type that we do not need
      # to bother with.
      case type
      when /^image\/jpeg/,"image/jpg"
	@wurfl["image_format"]["jpg"] = true 
      when /^image\/gif/
	@wurfl["image_format"]["gif"] = true
      when /image\/vnd\.wap\.wbmp/
	@wurfl["image_format"]["wbmp"] = true
      when /^image\/bmp/,"image/x-bmp"
	@wurfl["image_format"]["bmp"] = true
      when /^image\/png/
	@wurfl["image_format"]["png"] = true
      when "application/smil"
	  ### Where is the SMAF in MMS of WURFL?###
      when "application/vnd.smaf","application/x-smaf","application/smaf"
	#how to determine mmf version?
	$stderr.puts "CcppAccept supports MMF but what number: #{type}"
      when "audio/amr","audio/x-amr"
	@wurfl["sound_format"]["amr"] = true
      when "audio/midi","audio/mid","audio/x-midi","audio/x-mid"
	@wurfl["sound_format"]["midi_monophonic"] = true
	# We can play it safe an say mono. what about poly?
      when "audio/sp-midi"
	@wurfl["sound_format"]["sp_midi"] = true  
      when "audio/wav","audio/x-wav","application/wav","application/x-wav"
	@wurfl["sound_format"]["wav"] = true  
      when "image/tiff"
	@wurfl["image_format"]["tiff"] = true
      when "audio/imelody","audio/x-imy","text/x-iMelody","text/iMelody","text/x-imelody","audio/iMelody"
	@wurfl["sound_format"]["imelody"] = true  
      when "application/vnd.nokia.ringing-tone"
	@wurfl["sound_format"]["nokia_ringtone"] = true  
      when "audio/mpeg3"
	@wurfl["sound_format"]["mp3"] = true  
      when "text/x-eMelody"
      when "text/x-vMel"
      when /^text\/plain/
      when "text/x-vCard"
      when "text/x-vCalendar"
      when "application/vnd.wap.mms-message"
      when "application/vnd.wap.multipart.mixed"
      when "application/vnd.wap.multipart.related"
      when "application/octet-stream"
      when "application/vnd.eri.thm"
      when "application/vnd.openwave.pp"
      when "application/vnd.phonecom.im"
      when "application/vnd.phonecom.mmc-wbxml"
      when "application/vnd.phonecom.mmc-wbxml;Type=4364"
      when "application/vnd.phonecom.mmc-xml"
      when "application/vnd.syncml-xml-wbxml"
      when "application/vnd.uplanet.alert"
      when "application/vnd.uplanet.alert-wbxml"
      when "application/vnd.uplanet.bearer-choice"
      when "application/vnd.uplanet.bearer-choice-wbxml"
      when "application/vnd.uplanet.cacheop"
      when "application/vnd.uplanet.cacheop-wbxml"
      when "application/vnd.uplanet.channel"
      when "application/vnd.uplanet.channel-wbxml"
      when "application/vnd.uplanet.list"
      when "application/vnd.uplanet.listcmd"
      when "application/vnd.uplanet.listcmd-wbxml"
      when "application/vnd.uplanet.list-wbxml"
      when "application/vnd.uplanet.provisioning-status-uri"
      when "application/vnd.uplanet.signal"
      when "application/vnd.wap.coc"
      when "application/vnd.wap.multipart.header-set"
      when "application/vnd.wap.sia"
      when "application/vnd.wap.sic"
      when "application/vnd.wap.slc"
      when "application/vnd.wap.si"
      when "application/vnd.wap.sl"
	#The si and sl are probably related to the sia/sic and slc?
      when "application/vnd.wap.wbxml"
      when /^application\/vnd\.wap\.wmlc/i
	#"application/vnd.wap.wmlc;Level=1.3"
	#"application/vnd.wap.wmlc;Type=1108"
	#"application/vnd.wap.wmlc;Type=4360"
	#"application/vnd.wap.wmlc;Type=4365"
      when /application\/vnd\.wap\.wml(.)?scriptc/i
      when "application/vnd.wap.wtls-ca-certificate"
      when "application/vnd.wap.wtls-user-certificate"
      when "application/vnd.wap.xhtml+xml","application/xhtml+xml",
	  "application/xhtml+xml;profile=\"http://www.wapforum.org/xhtml\""
      when "application/xml"
      when /application\/x-mmc\./
        @wurfl["downloadfun"]["downloadfun_support"] = true
        # There is much Download Fun logic to do here
        # A few examples of what we may get are included

        val = parse_download_fun_accept(type)
        if val.nil?
          next
          # Then we probably received one of these what to do about them?
          #  when "application/x-mmc.title;charset=us-ascii;size=255"
          #  when "application/x-mmc.title;charset=us-ascii;size=30"
          #  when "application/x-mmc.title;charset=UTF-8;size=80"
        end
        
        case val["object-type"]
        when "audio","ringtone"
          #application/x-mmc.audio;Content-Type=audio/midi;size=25600;voices=16
          #application/x-mmc.ringtone;Content-Type=audio/x-sagem1.0;size=1000
          #application/x-mmc.ringtone;Content-Type=audio/x-sagem2.0;size=5500
          #application/x-mmc.ringtone;Content-Type=audio/x-wav;codec=pcm;samp=8000;res=16;size=200000
          #application/x-mmc.ringtone;Content-Type=audio/x-wav;codec=pcm;samp=8000;res=8,16;size=200000
          @wurfl["downloadfun"]["ringtone"] = true
          case val["content-type"]
          when "audio/midi","audio/mid","audio/x-midi","audio/x-mid"
            @wurfl["downloadfun"]["ringtone_midi_monophonic"] = true
          when "audio/imelody","audio/x-imy","text/x-iMelody","text/iMelody","text/x-imelody"
            @wurfl["downloadfun"]["ringtone_imelody"] = true
          else
            $stderr.puts "CcppAccept unknown download fun audio Content-Type: #{val["content-type"]}"
          end

          if val.key?("voices")
            set_value_if_greater(@wurfl["sound_format"],"voices",val["voices"].to_i)
            # determine if it has multiple voices and does midi to set 
            # the polyphonic value
            if val["voices"].to_i > 1 && val["content-type"] =~ /midi/
              @wurfl["downloadfun"]["ringtone_midi_polyphonic"] = true
              @wurfl["sound_format"]["midi_polyphonic"] = true
            end
          end
          if val.key?("size")
            set_value_if_greater(@wurfl["downloadfun"],"ringtone_size_limit",val["size"].to_i)
          end
          
        when "picture"
          #application/x-mmc.picture;Content-Type=image/bmp;size=25600;color=8;h=120;w=136
          #application/x-mmc.picture;Content-Type=image/bmp;size=38000;color=16M;h=96;w=128
          #application/x-mmc.picture;Content-Type=image/gif;size=16000;color=256;h=96;w=128
          #application/x-mmc.picture;Content-Type=image/vnd.wap.wbmp;size=25600;gray=1;h=120;w=136
          #application/x-mmc.picture;Content-Type=image/wbmp;size=2000;gray=1;h=96;w=128
          @wurfl["downloadfun"]["picture"] = true
          case val["content-type"]
          when "image/bmp","image/x-bmp"
            @wurfl["downloadfun"]["picture_bmp"] = true
          when "image/gif"
            @wurfl["downloadfun"]["picture_gif"] = true
          when /wbmp/
            @wurfl["downloadfun"]["picture_wbmp"] = true
          when "image/jpeg","image/jpg"
            @wurfl["downloadfun"]["picture_jpg"] = true
          when "image/png"
            @wurfl["downloadfun"]["picture_png"] = true
          else
            $stderr.puts "CcppAccept unknown download fun picture content-type: #{val["content-type"]}"
          end

          if val.key?("gray")
            @wurfl["downloadfun"]["picture_greyscale"] = true
          end
          if val.key?("h")
            set_value_if_greater(@wurfl["downloadfun"],"picture_height",val["h"].to_i)
          end
          if val.key?("w")
            set_value_if_greater(@wurfl["downloadfun"],"picture_width",val["w"].to_i)
          end
          if val.key?("size")
            set_value_if_greater(@wurfl["downloadfun"],"picture_size_limit",val["size"].to_i)
          end
          if val.key?("color")
            val["color"]  = convert_download_fun_color(val["color"])
            set_value_if_greater(@wurfl["downloadfun"],"picture_colors",val["color"].to_i)
          end
        when "screensaver"
          #application/x-mmc.screensaver;Content-Type=image/png;size=25600;color=8;h=120;w=136
          #application/x-mmc.screensaver;Content-Type=image/png;size=32000;color=16M;h=96;w=128
          @wurfl["downloadfun"]["screensaver"] = true
          case val["content-type"]
          when "image/bmp","image/x-bmp"
            @wurfl["downloadfun"]["screensaver_bmp"] = true
          when "image/gif"
            @wurfl["downloadfun"]["screensaver_gif"] = true
          when /wbmp/
            @wurfl["downloadfun"]["screensaver_wbmp"] = true
          when "image/jpeg","image/jpg"
            @wurfl["downloadfun"]["screensaver_jpg"] = true
          when "image/png"
            @wurfl["downloadfun"]["screensaver_png"] = true
          else
            $stderr.puts "CcppAccept unknown download fun screensaver content-type: #{val["content-type"]}"
          end

          if val.key?("gray")
            @wurfl["downloadfun"]["screensaver_greyscale"] = true
          end
          if val.key?("h")
            set_value_if_greater(@wurfl["downloadfun"],"screensaver_height",val["h"].to_i)
          end
          if val.key?("w")
            set_value_if_greater(@wurfl["downloadfun"],"screensaver_width",val["w"].to_i)
          end
          if val.key?("size")
            set_value_if_greater(@wurfl["downloadfun"],"screensaver_size_limit",val["size"].to_i)
          end
          if val.key?("color")
            val["color"]  = convert_download_fun_color(val["color"])
            set_value_if_greater(@wurfl["downloadfun"],"screensaver_colors",val["color"].to_i)
          end
        when "wallpaper"
          #application/x-mmc.wallpaper;Content-Type=image/bmp;size=38000;color=16M;h=96;w=128
          #application/x-mmc.wallpaper;Content-Type=image/vnd.wap.wbmp;size=10240;gray=1;h=120;w=136
          #application/x-mmc.wallpaper;Content-Type=image/wbmp;size=2000;gray=1;h=96;w=128
          #application/x-mmc.wallpaper;type=image/bmp;size=2000;gray=1;w=101;h=64
          @wurfl["downloadfun"]["wallpaper"] = true
          case val["content-type"]
          when "image/bmp","image/x-bmp"
            @wurfl["downloadfun"]["wallpaper_bmp"] = true
          when "image/gif"
            @wurfl["downloadfun"]["wallpaper_gif"] = true
          when /wbmp/
            @wurfl["downloadfun"]["wallpaper_wbmp"] = true
          when "image/jpeg","image/jpg"
            @wurfl["downloadfun"]["wallpaper_jpg"] = true
          when "image/png"
            @wurfl["downloadfun"]["wallpaper_png"] = true
          else
            $stderr.puts "CcppAccept unknown download fun wallpaper content-type: #{val["content-type"]}"
          end

          if val.key?("gray")
            @wurfl["downloadfun"]["wallpaper_greyscale"] = true
          end
          if val.key?("h")
            set_value_if_greater(@wurfl["downloadfun"],"wallpaper_height",val["h"].to_i)
          end
          if val.key?("w")
            set_value_if_greater(@wurfl["downloadfun"],"wallpaper_width",val["w"].to_i)
          end
          if val.key?("size")
            set_value_if_greater(@wurfl["downloadfun"],"wallpaper_size_limit",val["size"].to_i)
          end
          if val.key?("color")
            val["color"]  = convert_download_fun_color(val["color"])
            set_value_if_greater(@wurfl["downloadfun"],"wallpaper_colors",val["color"].to_i)
          end

        else
          $stderr.puts "CcppAccept unknown download fun accept Object-Type: #{type}"
        end
        
      when "application/x-NokiaGameData"
      when "application/x-up-alert"
      when "application/x-up-cacheop"
      when "application/x-up-device"         
      when "image/vnd.nok-wallpaper"
      when "image/vnd.wap.wml" 
      when "image/vnd.wap.wmlscript"
        # the two above seem like errors
      when "image/x-MS-bmp"
      when "image/x-up-wpng"
      when "image/x-xbitmap"
      when "text/css"
      when "text/html"
      when "text/vnd.sun.j2me.app-descriptor"
	# Andrea: this means the device can download jad (J2ME)
      when "text/vnd.wap.co"
      when "text/vnd.wap.si"
      when "text/vnd.wap.sl"
        # can these be used to determine about WAP Push SI and SL styles?
	# Andrea: These should be valid to set the values for
	# Andrea: connectionoriented_<push>. I will need to check better,
	# Andrea: but from what I can remember, if connectionoriented is
	# Andrea: supported, connectionless should be supported too.
      when "text/vnd.wap.wml"
      when "text/vnd.wap.wmlc"
      when "text/vnd.wap.wmlscript"
      when "text/vnd.wap.wmlscriptc"
      when "text/x-co-desc"
      when "text/x-hdml"
      when "text/xml"
      when "text/x-wap.wml"
      when "video/x-mng"
      when "image/*"
      when "*/*"	
      else
	$stderr.puts "CcppAccept unknown accept type: #{type}"
      end
    end
  end

  def CcppAccept_Charset(element)
  end

  def CcppAccept_Encoding(element)
  end

  def CcppAccept_Language(element)
  end

  def DownloadableSoftwareSupport(element)
    #=> "bagMapping"
  end

  def JavaEnabled(element)
    #=> "j2me",
  end
  
  def JavaPlatform(element)
    items = get_items_from_bag(element)
    items.each do |platform|
      # Cheat and ignore the Versions for now
      case platform
      when /CLDC/i
	@wurfl["j2me"]["cldc_10"] = true
      when /MIDP/i
	@wurfl["j2me"]["midp_10"] = true
      when /Pjava/i
        @wurfl["j2me"]["personal_java"] = true
      else         
	$stderr.puts "JavaPlatform Mapping unknown for: #{platform}"
      end
    end
  end

  def JVMVersion(element)
  end

  def MExEClassmarks(element)
    #has some interesting possibilitesfor matching MIDP/WAP Java...
  end

  def MexeSpec(element)
  end
  
  def MexeSecureDomains(element)
  end

  def OSName(element)
  end
  
  def OSVendor(element)
  end

  def RecipientAppAgent(element)
  end

  def SoftwareNumber(element)
  end
  
  def VideoInputEncoder(element)
  end
  
  def Email_URI_Schemes(element)
  end

  def JavaPackage(element)
    $stderr.puts "JavaPackage:#{element.text}"
    # Would show the Motorola extension etc???
  end
  
  def JavaProtocol(element)
    # Perhaps details SMS support etc?
    $stderr.puts "JavaProtocol:#{element.text}"
  end

  def CLIPlatform(element)
  end

  ############### NetworkCharacteristics
  def SupportedBluetoothVersion(element)
  end

  def CurrentBearerService(element)
  end

  def SecuritySupport(element)
    items = get_items_from_bag(element)
    items.each do |secure|
      if /WTLS/.match(secure)
	#check and just assume that this means https?
	#@wurfl["security"]["https_support"] = true
      end
    end
  end

  def SupportedBearers(element)
  end

  ############### BrowserUA

  # These two can sometimes make the user agent?
  def BrowserName(element)
    @wurfl["user_agent"]<< element.text
  end

  def BrowserVersion(element)
    @wurfl["user_agent"]<< element.text
  end

  def DownloadableBrowserApps(element)
    # This might have some good information to work with
  end

  def HtmlVersion(element)
    version = element.text.to_i
    if version == 4
      @wurfl["markup"]["html4"] = true
    elsif version < 4 && version >= 3
      @wurfl["markup"]["html32"] = true      
    else
      $stderr.puts "HtmlVersion unknown version mapping:#{version}"
    end
  end

  def JavaAppletEnabled(element)
  end
  
  def JavaScriptEnabled(element)
  end

  def JavaScriptVersion(element)
  end

  def PreferenceForFrames(element)
  end

  def TablesCapable(element)
    value = convert_value(element.text)
    @wurfl["wml_ui"]["table_support"] = value
  end

  def XhtmlVersion(element)
    version = element.text.to_i
    if version >= 1
      if version != 1
	$stderr.puts "XhtmlVersion that might map to a new WURFL trait. Version:#{version}" 
      end
      @wurfl["markup"]["xhtml_basic"] = true
    end
  end

  def XhtmlModules(element)
    #What does the mobile profile module look like?
    $stderr.puts "XhtmlModules items are:"
    items = get_items_from_bag(element)
    items.each do |mods|
      $stderr.puts "XhtmlModules item: #{mods}"
      if mods =~ /mobile*profile/i
	#Wow this worked?!
	@wurfl["markup"]["xhtml_mobileprofile"] = true
      end
    end
  end
  
  ################# WapCharacteristics
  def SupportedPictogramSet(element)
    # There could be WAP ones, but no list?
    #=> "chtml_ui/emoji",
  end

  def WapDeviceClass(element)
  end

  def WapVersion(element)
  end

  def WmlDeckSize(element)
    @wurfl["storage"]["max_deck_size"] = element.text.to_i
  end

  def WmlScriptLibraries(element)
  end

  def WmlScriptVersion(element)
    items = get_items_from_bag(element)
    items.each do |version|
      case version
      when "1.0"
	@wurfl["markup"]["wmlscript10"] = true
      when "1.1"
	@wurfl["markup"]["wmlscript11"] = true
      when /1\.2/i
        @wurfl["markup"]["wmlscript12"] = true
      else
	$stderr.puts "WmlScriptVersion unknown version mapping: #{version}"
      end
    end
  end

  def WmlVersion(element)
    items = get_items_from_bag(element)
    items.each do |version|
      case version
      when "1.0"
	# It appears we do not care about this one
      when "1.1"
	@wurfl["markup"]["wml_11"] = true
      when "1.2"
	@wurfl["markup"]["wml_12"] = true
      when "1.3"
	@wurfl["markup"]["wml_13"] = true
      else
	$stderr.puts "WmlVersion unknown version mapping: #{version}"
      end
    end
  end

  #Conversions needed on Bag
  def WtaiLibraries(element)
    items = get_items_from_bag(element)
    items.each do |lib|
      case lib
      when "WTAVoiceCall"
	@wurfl["wta"]["wta_voice_call"] = true
      when "WTANetText"
	@wurfl["wta"]["wta_net_text"] = true
      when "WTAPhoneBook"
	@wurfl["wta"]["wta_phonebook"] = true
      when "WTACallLog"
	@wurfl["wta"]["wta_call_log"] = true
      when "WTAMisc"
	@wurfl["wta"]["wta_misc"] = true
      when "WTAGSM"
	@wurfl["wta"]["wta_gsm"] = true
      when "WTAIS136"
	@wurfl["wta"]["wta_is136"] = true
      when "WTAPDC"
	@wurfl["wta"]["wta_pdc"] = true
      when "AddPBEntry"
        @wurfl["wta"]["wta_phonebook"] = true
      when "MakeCall"
        @wurfl["wta"]["nokia_voice_call"] = true
      when "WTAIGSM"
        @wurfl["wta"]["wta_gsm"] = true
      when "WTAIPublic.makeCall"
        @wurfl["wta"]["nokia_voice_call"] = true
      when "WTA.Public.addPBEntry"
        @wurfl["wta"]["wta_phonebook"] = true
      when "WTA.Public.makeCall"
        @wurfl["wta"]["nokia_voice_call"] = true
      when "WTAPublic.makeCall"
        @wurfl["wta"]["nokia_voice_call"] = true
      when "SendDTMF","WTA.Public.sendDTMF"
        # Not in WURFL
      when "WTAPublic"
        # Not enough information      
      else
	$stderr.puts "WtaiLibraries unknown mapping: #{lib}"
      end
    end
  end

  def WtaVersion(element)
  end

  # add the proposals to WURFL for download methods
  def DrmClass(element)
    #=> ["drm/OMAv1_forward-lock","drm/OMAv1_combined_delivery","drm/OMAv1_separate_delivery"],
  end
  def DrmConstraints(element)
  end
  def OmaDownload(element)
    # "download_methods/OMAv1_download"
  end
  
  ############### PushCharacteristics
  def Push_Accept(element)
    set_wap_push
    items = get_items_from_bag(element)
    items.each do |type|
      $stderr.puts "Push_Accept unknown type: #{type}"
    end
  end

  def Push_Accept_Charset(element)
    set_wap_push
    items = get_items_from_bag(items)
    items.each do |charset|     
      if charset =~ /utf8/i
	@wurfl["wap_push"]["utf8_support"] = true
      elsif charset =~ /iso8859/i
	@wurfl["wap_push"]["iso8859_support"] = true
      end
    end
  end
  def Push_Accept_Encoding(element)
    set_wap_push
  end
  def Push_Accept_Language(element)
    set_wap_push
  end
  def Push_Accept_AppID(element)
    set_wap_push
    #!! maps to confirmed and unconfirmed service indication/loads? !!
  end
  def Push_MsgSize(element)
    set_wap_push
    # Feels like the WURFL PUSH data is lacking in some items
  end
  def Push_MaxPushReq(element)
    set_wap_push
  end

  #Need MMS Mappings taken from Siemens example
  ############MmsCharacteristics
  def MmsMaxMessageSize(element)
    size = element.text.to_i
    @wurfl["mms"]["mms_max_size"] = size
  end

  def MmsMaxImageResolution(element)
    width,height = break_num_x_num(element.text)
    @wurfl["mms"]["mms_max_width"] = width
    @wurfl["mms"]["mms_max_height"] = height
  end
  
  def MmsCcppAccept(element)
    items = get_items_from_bag(element)
    items.each do |type|
      case type
      when "image/jpeg","image/jpg"
	@wurfl["mms"]["mms_jpeg_baseline"] = true 
	#what about progressive?
	# Andrea: is there any way to determine from the content type?
      when "image/gif" 
	@wurfl["mms"]["mms_gif_static"] = true
	#animated?
      when "image/vnd.wap.wbmp" 
	@wurfl["mms"]["mms_wbmp"] = true
      when "image/bmp"
	@wurfl["mms"]["mms_bmp"] = true
      when "image/png"
	@wurfl["mms"]["mms_png"] = true
      when "application/smil"
      when "application/x-sms"
      when "application/vnd.3gpp.sms"
	  ### Where is the SMAF in MMS of WURFL?###
	  # Andrea: we had never found a device supporting SMAF and MMS
	  # Andrea: should be added
      when "application/vnd.smaf"
      when "application/x-smaf"
      when "audio/amr","audio/x-amr"
	@wurfl["mms"]["mms_amr"] = true
      when "audio/midi","audio/mid","audio/x-midi","audio/x-mid"
	@wurfl["mms"]["mms_midi_monophonic"] = true
	# We can play it safe an say mono. what about poly?
      when "audio/sp-midi"
	@wurfl["mms"]["mms_spmidi"] = true
      when "audio/wav","audio/x-wav","application/wav","application/x-wav"
        @wurfl["mms"]["mms_wav"] = true
      when "text/plain"
      when "text/x-vCard","text/x-vcard"
	@wurfl["mms"]["mms_vcard"] = true
      when "application/vnd.nokia.ringing-tone"
	@wurfl["mms"]["mms_nokia_ringingtone"] = true
      when "image/vnd.nok-wallpaper"
	@wurfl["mms"]["mms_nokia_wallpaper"] = true
      when "audio/x-beatnik-rmf","audio/x-rmf","audio/rmf"
	@wurfl["mms"]["mms_rmf"] = true
      when "application/vnd.symbian.install"
	@wurfl["mms"]["mms_symbian_install"] = true
      when "application/java-archive","application/x-java-archive"
	@wurfl["mms"]["mms_jar"] = true
      when "text/vnd.sun.j2me.app-descriptor"
	@wurfl["mms"]["mms_jad"] = true
      when "application/vnd.wap.wmlc"
	@wurfl["mms"]["mms_wmlc"] = true
      when "text/x-vCalendar"
      when "application/vnd.wap.mms-message"
      when "application/vnd.wap.multipart.mixed"
      when "application/vnd.wap.multipart.related"
      else
	$stderr.puts "MmsCcppAccept unknown accept type: #{type}"
      end
    end
  end

  def MmsCcppAcceptCharset(element)
  end
  
  def MmsVersion(element)
  end

  ############### Extra Components found from running on profs
  def BluetoothProfile(element)
  end

  def FramesCapable(element)
  end

  def OSVersion(element)
  end

  def MmsCcppAcceptEncoding(element)
  end

  def MmsCcppAcceptLanguage(element)
  end

  def MmsMaxAudio(element)
  end

  def MmsMaxComponents(element)
  end

  def MmsMaxImage(element)
    # examples have Values of -1...
  end

  def MmsMaxText(element)
  end

  def WapPushMsgPriority(element)
  end

  def WapPushMsgSize(element)
  end

  def WapSupportedApplications(element)
  end


  ############## Alias to methods already defined. 
  alias :AudioInputEncorder :AudioInputEncoder
  alias :MexeClassmark :MExEClassmarks
  alias :MexeClassmarks :MExEClassmarks
  alias :MmsCcppAccept_Charset :MmsCcppAcceptCharset
  alias :MmsCcppAcceptCharSet :MmsCcppAcceptCharset
  alias :OutputCharset :OutputCharSet
  alias :PixelsAspectRatio :PixelAspectRatio
  alias :SofwareNumber :SoftwareNumber
  alias :SupportedBearer :SupportedBearers
  alias :TableCapable :TablesCapable
  alias :WmlscriptLibraries :WmlScriptLibraries
  alias :wtaVersion :WtaVersion
 

  #############################################################
  # Utility methods
  #############################################################

  def set_wap_push
    # if Push items exist then set wap_push/wap_push_support = true
    @wurfl["wap_push"]["wap_push_support"] = true
  end

  # escape the passed method name to something valid for Ruby
  def make_method_name(method)
    # should do more, but will add them as errors occur
    method.gsub(/-/,"_")
  end

  def break_num_x_num(val)
    width = height = 0
    if m = /(\d*)x(\d*)/.match(val)
      width, height = m[1],m[2]
    end
    return width.to_i,height.to_i 
  end

  def get_items_from_bag(element)
    items = Array.new
    return items if element.nil?
    element.elements.each("rdf:Bag/rdf:li") do |se|
      items<< se.text
    end    
    return items
  end

  # used to convert Yes/No to true false
  def convert_value(value)
    if value =~ /Yes/i
      return true
    elsif value =~ /No/i
      return false 
    end
    begin
      # try to convert to an integer
      return value.to_i
    rescue
    end
    # just leave it alone
    return value
  end

  def set_value_if_greater(wurflhash,key,value)
    if wurflhash.key?(key)
      if value.is_a?(Fixnum)
        if wurflhash[key] < value
          wurflhash[key] = value
        end
      else
        # Should probably just overwrite the entry then.
        $stderr.puts "set_value_if_greater called with something that is not a number.Key:#{key};Value:#{value}"
      end
    else
      # it is not set so set it
      wurflhash[key] = value
    end
  end

  def convert_download_fun_color(color)
    res = color
    if color =~ /M$/i
      # multiply it by a million
      res = color.to_i * 1000000
    elsif color =~ /K$"/i
      # multiply it by ten thousand
      res = color.to_i * 10000
    end
    return res
  end

  def parse_download_fun_accept(accept)
    #application/x-mmc.object_type;content-type=format;size=n;other=y
    m = /application\/x-mmc\.(.*);(content-)?type=(.*);size=(\d*);(.*)/i.match(accept)
    return nil if m.nil? # no match

    res = Hash.new
    res["object-type"] = m[1]
    res["content-type"] = m[3]
    res["size"] = m[4]
    if m[5]
      others = m[5].split(";")
      others.each do |keypair|
        key,value = keypair.split("=")
        res[key] = value
      end
    end

    return res
  end
  
end


if $0 == __FILE__
  # The code below is called if this file is executed from the command line.

  def usage    
    puts "Usage: usaprofparser.rb uaprof_files"
    puts "No files passed to parse."
    exit 1
  end

  if ARGV.size == 0
    usage
  end

  uaprof = UAProfToWURLF.new
  
  # Parse all the files and merge them into one UAProf.
  # Following profs take precedence of previous ones
  ARGV.each do |file|
    uaprof.parse_UAProf(file)
  end

  # Now output the mapped WURFL to standard out
  uaprof.output_WURFL
  
end
