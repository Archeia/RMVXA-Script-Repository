=begin
 ■ Information      ╒═════════════════════════════════════════════════════════╛
#==============================================================================
# EST_CS2 - SCRIPT CONTROL
#==============================================================================
# Author  : Estriole & caitsith2
# Version : 2.0
#==============================================================================

  #==============================================================================
  # TDS - SCRIPT DISABLER
  #==============================================================================
  # Author  : TDS
  # Version : 1.0
  #==============================================================================

 ■ Changelog        ╒═════════════════════════════════════════════════════════╛
 v1.0 2014.06.14     >     Initial Release
 v1.1 2014.06.16     >     Add simple dumb encryption so the rvdata2 cannot read easily
 v1.2 2014.06.18     >     Improve the dumb encryption with reverse method. 
                     >     Add REAL encryption using cypher method.
                     >     Make the encryption and decryption as method.
                     >     Add support for having crypt key hidden inside the hidden script
                           so it's harder to crack. double encryption
 v1.3 2014.06.27     >     Fix script folder cannot be changed. thx to caitsith2 for pointing it out.
                     >     Add temp_key encryption to your hidden key. harder to crack
 v1.4 2014.06.30     >     Add Triple encryption using caitsith2 code. (scramble method)   
 v1.5 2014.07.04     >     Add Protection from write to file method. expert coder
                           might still able to crack it. but it will be difficult.
                           and if they can crack it... by logic. they're have the ability 
                           to create scripts better than what they want to steal anyway...
 v1.6 2014.07.05     >     Removed the dumb encryption and reverse method. because there's
                           potential it can ruin the scripts if it have trailing tokens.
                           thanks to killozapit to point it out. this script already
                           have better encryption anyway (cypher + scramble)
 v1.7 2014.07.06     >     Improve the write to file prevention method by LOTS!
                     >     Added protecion from script modification. so when this
                           script changed after people decrypt the project... 
                           it will fail the decryption.
                           coder that CAN crack this update only mean to test his/her 
                           skill not thinking on stealing your scripts :D
                           if anyone can crack this. share with me please so i can
 v1.8 - v1.9         >     Never released because can be cracked immediately
                           after i add extra security... but i still left the code
                           in 2.0 to make extra steps that thief have to do before
                           they can crack this script...
 v.2.0               >     Since any prevention method (in v.1.8 / v.1.9) can be
                           undone by the thief (not easily. but doable)... by
                           modifying the script control scripts... 
                           i decide to use dll (thanks to tsukihime for her tutorial...
                           this script can't use dll without her tutorial)
                           
 ■ License        ╒═════════════════════════════════════════════════════════╛
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE).
 
 I started writing this script. but then caitsith2 helps me a lot in improving
 this script. so i think this script already become collaboration between me and 
 him. so the second person need to credited is catsith2 !
 
 EDIT: policy change... game containing pornography ALLOWED to use this script.
 because i think it would be better so no more people can steal their scripts 
 and create ANOTHER pornography game. this exception is valid ONLY for this script
 and EST - ENCRYPTER script.
 
 This script written based (also take some code) from TDS SCRIPT DISABLER script.
 so you need to credit TDS too if you use this script.

 From v2.0 > this script use dll. using knowledge learned from tsukihime's tutorial
 about using dll in RPG MAKER VX ACE... so Added Tsukihime in the credit list...
 
 so in summary this is all people that you need to credit when using this script:
 1) Estriole
 2) caitsith2
 3) TDS
 4) Tsukihime
 
 ■ Introduction     ╒═════════════════════════════════════════════════════════╛
    This script created to give better control to the script. we can disable
 a single script, disable a group of scripts and import script from external files
 replacing marked script editor entry. the external scripts CAN be encrypted too.
 read the how to use on how to encrypt it.

 ■ Features     ╒═════════════════════════════════════════════════════════╛
 - v.2.0 >>> NOW use dll to avoid thief modification !!!
 - 99% guarantee to make script thief's head dizzy.
 - Disable single script
 - Disable group script
 - Import script from external .txt files
 - Encrypt your external script.
 - Hide your personal script from the decrypter program. they can access your
 project but cannot read the script easily. (yes... perhaps expert coder can 
 reverse the code and make it .txt but it will give them hell at least).
 - from v 1.2 > added real encryption and add double encryption support.
 - from v 1.4 > added triple encryption. OMG... this really mean bussiness.
 - from v 1.5 > added write to file protection
 - from v 1.7 > added script modification protection. so if people modify
                the script after decrypting your project. it will fail the decryption.
                people that can crack this protection only do that for testing
                their skill. i'm 100% sure they don't need your script because
                they can script better. :p.
 - from v 1.9 > add sc check that make thief harder to edit scripts.

 ■ Requirement     ╒═════════════════════════════════════════════════════════╛
 - RPG MAKER VX ACE program :D 
 - EST_CS2_SCRIPT_CONTROL.dll can be downloaded either from demo or from script page...
 put that dll file INSIDE your project folder.
 
 ■ Compatibility     ╒═════════════════════════════════════════════════════════╛
  1) MUST BE PLACED ABOVE ALL SCRIPTS you want disabled/imported
  2) TXT Files must use UTF-8 Encoding
  3) this script name MUST be: EST_CS2 - SCRIPT CONTROL for better security.
     you can have other name. but it won't as secure then.

 ■ How to Use     ╒═════════════════════════════════════════════════════════╛   
 0) DOWNLOAD EST_CS2_SCRIPT_CONTROL.dll either from demo or from script page...
 put that dll file INSIDE your project folder. (see demo for more info). 
 
 1) Disable single script
  add # at start of script name in script editor to disable single script
  example: #Victor Basic Module
  
  External script can also disabled using this feature
  example: #&Victor Basic Module
   
 2) Disable group scripts
  To disable a group of scripts make 2 new blank scripts and in their name
  add this:

  <Disabled_Scripts>

  </Disabled_Scripts>

  Any scripts put between these 2 new scripts will be disabled at the start
  of the game.

  External script can also disabled using this feature
  example: 
  <Disabled_Scripts>
  &Victor Basic Module
  &Yanfly Ace Battle Engine
  </Disabled_Scripts>
 
 3) Importing external script.
  - First create "Scripts" folder inside your project folder 
  (if no folder named "Script" this script will throw error print in console)
  - create/copy the txt files that contain your scripts. 
  (some scripters use strange character to make the scripts look neater. me included: ■ :D)
  so... MAKE SURE the txt files saved using UTF-8 Encoding. if you got error about unicode
  character. then your txt files not UTF-8 Encoding. just save as and choose the correct
  Encoding.
  
  - then add & at the start of the txt files name. (REQUIRED)
  example: &Victor Basic Module.txt
           &Yanfly Battle Engine.txt
           
  - open up your script editor. make new blank scripts in the position where you
  want the imported script placed. you can move it later too when you need to
  reorder your script list. rename the scripts name to the txt files name (without .txt).
  example according above: 
           &Victor Basic Module
           &Yanfly Battle Engine
  then the blank script with that name will automatically replaced with the external script.
  
  NOTE: do not use &cypher_key as script name for your script. 
        because it's reserved to use in double encryption...
        use it only for scripts containing your hidden key and recrypt process.
 
 4) Encrypting your game with the external scripts imported.
 just use step 5. it's safer.
 
 5) Encrypting your scripts. with the crypt key INSIDE the imported scripts.
 (double encryption)
 - finish your game first.
 
 - DOWNLOAD &cypher_key.txt from the topic page / GRAB it from demo Scripts folder.
 
 open the txt file and change mykey variable in CONFIGURATION section:
 
 ##################################################
 #                                                #
 #             CONFIGURATION                      #
 #                                                #
 ##################################################

 mykey = x
 
 change x any TEXT you want... (not unique array like v.1.9 or below)
  
 example:
 
 ##################################################
 #                                                #
 #             CONFIGURATION                      #
 #                                                #
 ##################################################
 
 mykey = "don't steal my script please... i'll buy you some candy... what flavour you like"
 
 some tips. you can cut and paste from the array to reorder your key.
 it save time.
 
 NOTE: Do not change anything else beside the config. to make sure your
 scripts protected.
 
 - SAVE the changes 
 
 - open up your script editor. make new blank scripts directly BELOW this script.
   name it &cypher_key
 - play test with DO_CONVERSION_TO_RVDATA = true
 - after that change DO_CONVERSION_TO_RVDATA = false (OPTIONAL)
 - delete your Scripts folder. encrypt the game using editor normally.
 
 WARNING: DO NOT PLAYTEST AGAIN WITH DO_CONVERSION_TO_RVDATA = true
 after you DELETE the SCRIPTS FOLDER !!! it will re-encrypt your project
 with no external SCRIPTS!!!
 
 EXTRA WARNING: IT WOULD BE WISE TO BACKUP YOUR SCRIPTS FOLDER SOMEWHERE
 IN CASE YOU WANT TO EDIT THE GAME AGAIN :D.
 
 ■ Future Plan     ╒═════════════════════════════════════════════════════════╛   
 - None at current time.  
      
=end

($imported ||= {})["EST_CS2 - SCRIPT CONTROL"] = true

module ESTRIOLE
  module SCRIPT_CONTROL
  # >> SETTINGS
    # Would you like to convert all .txt files in the "Scripts" folder to a
    # .rvdata data file which can be encrypted with the game
    DO_CONVERSION_TO_RVDATA = true
    # play test first so your scripts got converted to EST_Scripts.rvdata2. 
    # after that. set DO_CONVERSION_TO_RVDATA to false
    # then encrypt your game. then delete the Scripts folder.
    SCRIPTS_FOLDER = "Scripts/" # Folder where you put your scripts as txt 
    #SCRIPTS_FOLDER = "Scripts/" -> this means at your project folder/Scripts/
    
  # >> CYPHER ENCRYPTION
    # TEMPORARY crypt key name (you can create another txt files that contain
    # your REAL crypt key. set this to nil to not using temporary crypt key
    CRYPT_KEY = "cFZuhSVFMDMl2ZM3HYmtN0T1W6v3LZSQVpqaqsqVEpGk6XFBsWxEGFx4IcrgSeO"
    # from 2.0 you can use any text you like... it would be better strange unpredicted text though 
    
    #DO NOT CHANGE BELOW. change at your own risk.
    CRYPT_KEY_NAME = "&cypher_key"    
    CRYPT_KEY = CRYPT_KEY.split(//) if CRYPT_KEY.is_a?(String)
  end
end

def control_scripts
  for i in 0 ... $RGSS_SCRIPTS.size
    $RGSS_SCRIPTS[i][2] = $RGSS_SCRIPTS[i][3] = "" if $RGSS_SCRIPTS[i][1] =~ /^#/
  end
  delete_active =  false
  $RGSS_SCRIPTS.each_with_index {|data, i|
    delete_active = true  if data.at(1) =~ /<Disabled_Scripts>/i
    if data.at(1) =~ /<\/Disabled_Scripts>/i
      delete_active = false 
      $RGSS_SCRIPTS.at(i)[2] = $RGSS_SCRIPTS.at(i)[3] = "" 
    end
    next unless delete_active
    $RGSS_SCRIPTS.at(i)[2] = $RGSS_SCRIPTS.at(i)[3] = "" 
  }#do not remove this
end

begin
EST_CS2_add_entropy =  Win32API.new("EST_CS2_SCRIPT_CONTROL.dll", "add_entropy", "", "P")
EST_CS2_cipher =  Win32API.new("EST_CS2_SCRIPT_CONTROL.dll", "cipher", "", "P")
EST_CS2_prepare_scramble_key =  Win32API.new("EST_CS2_SCRIPT_CONTROL.dll", "prepare_scramble_key", "", "P")
EST_CS2_convert_scripts_to_rvdata =  Win32API.new("EST_CS2_SCRIPT_CONTROL.dll", "convert_scripts_to_rvdata", "", "P")
EST_CS2_decrypt_rvdata_to_scripts =  Win32API.new("EST_CS2_SCRIPT_CONTROL.dll", "decrypt_rvdata_to_scripts", "", "P")
EST_CS2_recrypt_script =  Win32API.new("EST_CS2_SCRIPT_CONTROL.dll", "recrypt_script", "", "P")
EST_CS2_execute =  Win32API.new("EST_CS2_SCRIPT_CONTROL.dll", "execute", "", "P")

eval(EST_CS2_add_entropy.call())
eval(EST_CS2_cipher.call())
eval(EST_CS2_prepare_scramble_key.call())
eval(EST_CS2_convert_scripts_to_rvdata.call())
eval(EST_CS2_decrypt_rvdata_to_scripts.call())
eval(EST_CS2_recrypt_script.call())
eval(EST_CS2_execute.call())
rescue
  puts "EST_CS2_SCRIPT_CONTROL.dll missing...\nPlace it inside your project folder (same location as Game.exe)"
  puts "The Project will continue but only with script control function.\nIt will not load your encrypted script."
end
control_scripts