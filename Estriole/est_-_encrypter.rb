=begin
 ■ Information      ╒═════════════════════════════════════════════════════════╛
#==============================================================================
# EST - [Z - ENCRYPTER]
#==============================================================================
# Author  : Estriole
# Version : 1.4
#==============================================================================

  #==============================================================================
  # OC AUDIO ENCRYPTION
  #==============================================================================
  # Author  : Ocedic
  # Version : 1.00
  #==============================================================================  
  #==============================================================================
  # Simple Audio Encryption
  #==============================================================================
  # Author  : Tsukihime
  # Version : 1.00
  #==============================================================================  
  
  
 ■ Changelog        ╒═════════════════════════════════════════════════════════╛
 v1.0 2014.06.19     >     Initial Release
 v1.1 2014.06.25     >     Add some rescue if files deleted. it will redecrypt it.
                           thanks to andar for pointing that out.
                     >     Automatically decrypt ALL files when the game FIRST
                           executed...
 v1.2 2014.06.30     >     prevent admin right error showing the location of the resource.                          
 v1.3 2014.07.19     >     upgrade the protection by making the path stored in private variable.
                           so it cannot be printed outside the module/class. also some
                           protection against thief that call script call from event
                           or using damage formula to print the private variable.
 v1.4 2014.07.21     >     fix error if you decide to not convert anything / partial

 ■ License        ╒═════════════════════════════════════════════════════════╛
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE).
  
 the encrypt code based from (also take some code) from Ocedic script.
 but i heavily modified it to able to encrypt graphic, sound, video (all playable format)
 the decrypt code based from (also take some code) from tsukihime script.
 so you need to credit both Ocedic and Tsukihime too if you use this script.
 
 so in summary... this is the list of people that you need to credit:
 1) Estriole
 2) Ocedic
 3) Tsukihime 

 ■ Introduction     ╒═════════════════════════════════════════════════════════╛
   This script written following my idea from EST - SCRIPT CONTROL. this script
 serialize the graphics/sounds/videos to rvdata2 files. so it can be encrypted too.
 
 this script will decrypt the files when the game needed it.
 
 like Ocedic said in his script. even with 100% encryption it would
 still possible to stole the graphic/sound/video. but i made some extra layer of security.
 which make it harder to stole. you can set WHERE you want the file placed.

 for example: C:/Windows/System32
 (i won't go that far though) :p. OR still use that folder but create folders
 with unique name. C:/Windows/System32/Est_Games
 
 if they don't know the path then it's almost impossible to know where the sound.
 since when first time opening the graphic/sound/video. it will decrypt it. place it inside
 the folder you set. with RANDOM NAME and with extension you can set inside the
 configuration (you can even left it "" to make it without extension. harder to search).
 to keep the game reference to the file. there's a special decrypt_list file with
 name you can set (it would be better to make it random and without extension).

 but of course people can see when they decrypt your project and peek at this script.
 THERE's EST_CS2 - SCRIPT CONTROL come to the rescue. so they cannot read this script(easily). :D.
 (using external script import feature) (or even double encryption feature)
 just call this script externally (read script control)
 
 ■ Features     ╒═════════════════════════════════════════════════════════╛
 - Encrypt graphic files
 - Encrypt sound files
 - Encrypt video files
 - Decrypt when the files needed in folder YOU set
 - Great Combo with EST_CS2 - SCRIPT CONTROL so the path cannot be read easily.
 
 ■ Requirement     ╒═════════════════════════════════════════════════════════╛
   Just RPG MAKER VX ACE program :D 
 
 ■ Compatibility     ╒═════════════════════════════════════════════════════════╛
 - Should work with most scripts. unless that scripts use Bitmap.new(path)
   directly (as far as i know no scripts use that approach yet)

   if there's scripts that overwrite Audio.bgm_play (or other method in Audio module)
   put this script below it.   
   
   Graphic / Sound / Video name should not contain . (period).
   wrong example: And.I.Love.You.png
   correct example: And I Love You.png
   correct example: And_I_Love_You.png
   
 - you cannot have same image / sound / video name in SAME FOLDER. even though
 they have different EXTENSION.

 - Put this script BELOW any scripts that OVERWRITE 
    >>  def eval 
   inside Game_Interpreter or RPG::UsableItem::Damage for better protection.
 
 -  when you use folder that not have write access for the windows username.
 after you test play the project. it will throw errors. it's fine. the file
 STILL encrypted. but you need to play using Game.exe WITH administrator access.
 (right click > run as administrator access). that means you need to tell your
 customer to play it using admininstrator access too.
 FYI: this information is for Windows vista and above. since they usually don't 
 have write access to system folders. Windows XP have no issues about this.
     
 ■ How to Use     ╒═════════════════════════════════════════════════════════╛   
 0) Finish your project first.
 1) Change the configuration as you like (read the configuration comment)
 2) Set this:
        CONVERT_GRAPHIC_TO_RVDATA2 = true
        CONVERT_SOUND_TO_RVDATA2 = true
        CONVERT_VIDEO_TO_RVDATA2 = true
    don't forget to save
 3) Play test once (Read compatibility section above if it throws error).
 4) delete Graphics, Audios, Movies folder (DO NOT EVER PLAY TEST with point 2 set
    to true AFTER you delete the Graphics/Audios/Movies. because it might throw error)
 5) Encrypt the game normally using the editor
 
 ■ Future Plan     ╒═════════════════════════════════════════════════════════╛   
 - method to delete all decrypted sounds. (when want to uninstall???) but still
   confused on how to execute the delete process.
 
 ■ Scripter Note     ╒═════════════════════════════════════════════════════════╛   
 - I think this could be the standard script for encrypting games. it took days
   writing this script. making some major changes in the process so it will be hard
   to crack. before i also try GaryCXJk marshal dumpable bitmap scripts to serialize 
   the graphic. it would prove a better encryption but too bad the resulting file become too large. 
   then i switch using Ocedic audio encryption and modify it heavily to able to 
   encrypt graphic and video too. and the file become smaller.
 - there's a slight delay when playing the sound for the first time (for that computer)
   if the file is too big(not too noticeable though). but the next time playing 
   the sound it will play fine because it's saved in the computer
   
=end
class Module
  def include_module_methods(mod)
    mod.singleton_methods.each do |m|
      (class << self; self; end).send :define_method, m, mod.method(m).to_proc
    end
  end
end

module ESTRIOLE
  module ENCRYPTER
  #>> Graphic + Sound + Video encryption settings
    # activator. set this to true to serialize graphic
    @@CONVERT_GRAPHIC_TO_RVDATA2 = true
    
    # activator. set this to true to serialize sound
    @@CONVERT_SOUND_TO_RVDATA2 = true
    
    # activator. set this to true to serialize video
    @@CONVERT_VIDEO_TO_RVDATA2 = true
    
    # crypt key for rvdata2 files (doesn't mean much because rvdata2 files
    # cannot be played anyway. but to prevent people reverse engineering it easily
    @@KEY = ""
    # the longer above string. it might increase the size of the encrypted files.
    
    # key for alias to protect write class. change to any string you like (required)
    MY_ALICIA_KEY = "to_make_sure_it_secure"
    # THIS IS MORE IMPORTANT THAN @@KEY !!!
    
    # folder where the decrypt list file and decrypted sound file placed
    # it would be better to specify STATIC path inside player computer.
    @@FOLDER = "#{ENV['APPDATA']}/EST_GAMES"
    # you can even set it in C:/Windows/System32 for example. but i won't go that far.
    # as long as the drive is exist it will create the folder if it's not exist
    # people that decrypt your project can see this. so use EST - SCRIPT CONTROL
    # to hide this script. :D.
    # if you want... you can use this to put decrypted files in %appdata%
    # @@FOLDER = "#{ENV['APPDATA']}/yourfoldername" 
    # like most games do... but it's not as secure as:
    # C:/Windows/System32/s/x/ccs/zlib/omg/wtf
    
    # WARNING. in playtest... if using folder that you cannot write too. 
    # it will throw error. ex: C:/Windows/System32 (in windows7 64 bit)
    # it's okay. the files still encrypted. you can tell the user to right click at Game.exe
    # then choose run with administrator right. it will load just fine.
    
    # file name of the decrypt list -> where the game will read the graphic/sound/video path reference
    # can be with or without EXTENSION
    @@DECRYPT_LIST_FILENAME = "AeWeLSeQRe"
    # "AeWeLSeQRe" => without extension. "AeWeLSeQRe.dll" => with extension
    
    # number of random char for the decrypted graphic/sound/video filename. 10 is enough i guess.
    @@CRYPT_FILENAME_NUMBER = 10
    
    # extension for the decrypted graphic/sound/video filename. if you don't want extension
    # just left it "" (HARDER TO SEARCH)
    @@CRYPT_EXTENSION = ".est_media"

  #====# DO NOT TOUCH BELOW THIS LINE # TOUCH AT YOUR OWN RISK #=================#
  #ENCRYPT DECRYPT METHOD
    def self.encrypt(filename)    
      arr = filename.split("/")
      arr[arr.size-1] = arr[arr.size-1].split(".")[0]
      sourcefile = File.open(filename, "rb")
      content = sourcefile.readlines
      sourcefile.close
      targetfile = File.new("Data/Z_EST_#{arr.join("_")}.rvdata2", "wb")
      for i in 0...content.size
        content[i] = @@KEY + content[i]
      end
      Marshal.dump(content, targetfile)
      targetfile.close      
    end
  
    def self.decrypt(filename)
      decrypt_list = Marshal.load(File.open("#{@@FOLDER}/#{@@DECRYPT_LIST_FILENAME}"))
      arr = filename.split("/")
      arr[arr.size-1] = arr[arr.size-1].split(".")[0]
      content = load_data("Data/Z_EST_#{arr.join("_")}.rvdata2")
      for i in 0...content.size
        value = content[i]
        content[i] = value[@@KEY.length, content[i].size]
      end

      samples = ('a'..'z').to_a + (0..9).to_a
      checking = false
      begin
        while !checking
          crypt = []
          @@CRYPT_FILENAME_NUMBER.times.each do |i|
            crypt.push(samples.sample)
          end
          checking = true if !decrypt_list.values.include?(crypt.join)
        end
        path = "#{@@FOLDER}/#{crypt.join}#{@@CRYPT_EXTENSION}"
        targetfile = File.open(path, "wb")
      rescue
        while !checking
          crypt = []
          @@CRYPT_FILENAME_NUMBER.times.each do |i|
            crypt.push(samples.sample)
          end
          checking = true if !decrypt_list.values.include?(crypt.join)
        end
        path = "#{@@FOLDER}/#{crypt.join}_clone#{@@CRYPT_EXTENSION}"
        targetfile = File.open(path, "wb")
      end
    
      for i in 0...content.size
        targetfile.write(content[i])
      end
      targetfile.close
      return path
    end
    
  # decrypt list preparation code
  def self.prepare_decrypt_list
    begin
      dirlist = @@FOLDER.split("/")
      dircheck = []
      dirlist.each_with_index do |dir, i|
        dircheck.push(dir)
        next if i == 0
        string = dircheck.join("/")
        Dir.mkdir(string) unless File.exist?(string)
      end
    
      path = "#{@@FOLDER}/#{@@DECRYPT_LIST_FILENAME}"
  
      if !File.exist?(path)  
        b = File.new(path, "wb")
        Marshal.dump({:key => path},b)
        b.close
      end
    rescue
      raise "Run Game.exe with Administrator right \n(right click > run with administrator right)" if !$TEST
      raise "You have no access to Folder... File still Encrypted though.\nTo play: Run Game.exe with Administrator right"
    end
  end

  def self.est_decrypt_all
    dpath = "#{@@FOLDER}/#{@@DECRYPT_LIST_FILENAME}"
    if !File.exist?(dpath)
      begin
        self.prepare_decrypt_list
        decrypt_list = Marshal.load(File.open(dpath))    
        list = load_data("Data/Z_ListGraphic.rvdata2")
        list.each do |file|
          path = self.decrypt(file)
          decrypt_list[file.split(".")[0]] = path
        end
      rescue
        p "no Z_ListGraphic.rvdata2 found"
      end
      begin
        list = load_data("Data/Z_ListAudio.rvdata2")
        list.each do |file|
          path = self.decrypt(file)
          decrypt_list[file.split(".")[0]] = path
        end
      rescue
        p "no Z_ListAudio.rvdata2 found"
      end
      begin
        list = load_data("Data/Z_ListMovie.rvdata2")
        list.each do |file|
          path = self.decrypt(file)
          decrypt_list[file.split(".")[0]] = path
        end
        b = File.open(dpath, "wb")
        Marshal.dump(decrypt_list,b)
        b.close
      rescue
        p "no Z_ListMovie.rvdata2 found"
      end
    end
  end

  # >> convert methods
  def self.convert_graphic_to_rvdata2
    return unless $TEST
    return unless @@CONVERT_GRAPHIC_TO_RVDATA2
    list = []
    pathlist = Dir["Graphics/**/*"].select{|x| !File.directory?(x)}
      pathlist.each do |path|
        self.encrypt(path)
        list.push(path).uniq!
      end  
    b = File.new("Data/Z_ListGraphic.rvdata2", "wb")
    Marshal.dump(list,b)
    b.close
  end

  # sound convert
  def self.convert_sound_to_rvdata2
    return unless $TEST
    return unless @@CONVERT_SOUND_TO_RVDATA2
    list = []
    pathlist = Dir["Audio/**/*"].select{|x| !File.directory?(x)}
      pathlist.each do |path|
        self.encrypt(path)
        list.push(path).uniq!
      end  
    b = File.new("Data/Z_ListAudio.rvdata2", "wb")
    Marshal.dump(list,b)
    b.close
  end

  # video convert
  def self.convert_video_to_rvdata2
    return unless $TEST
    return unless @@CONVERT_VIDEO_TO_RVDATA2
    list = []
    pathlist = Dir["Movies/**/*"].select{|x| !File.directory?(x)}
      pathlist.each do |path|
        self.encrypt(path)
        list.push(path).uniq!
      end  
    b = File.new("Data/Z_ListMovie.rvdata2", "wb")
    Marshal.dump(list,b)
    b.close
  end
  
  module PROTECT_EVAL
    @@KEY_ALIAS = ESTRIOLE::ENCRYPTER::MY_ALICIA_KEY.dup  
    @@FILE_ALIAS_NAME = "#{@@KEY_ALIAS}est_encrypter_eval".to_sym
    @@INSTANCE_METHODS_ALIAS_NAME = "#{@@KEY_ALIAS}_est_encrypter_instance_methods_protect".to_sym
    @@METHODS_ALIAS_NAME = "#{@@KEY_ALIAS}_est_encrypter_methods_protect".to_sym
  
    def check_eval(*args)
      script = args[0]
      return msgbox "Protected!!!" if script.include?("@@KEY")
      return msgbox "Protected!!!" if script.include?("@@FOLDER")
      return msgbox "Protected!!!" if script.include?("@@DECRYPT_LIST_FILENAME")
      return msgbox "Protected!!!" if script.include?("@@CRYPT_FILENAME_NUMBER")
      return msgbox "Protected!!!" if script.include?("@@CRYPT_EXTENSION")
      return msgbox "Protected!!!" if script.include?("@@KEY_ALIAS")
      return msgbox "Protected!!!" if script.include?("@@FILE_ALIAS_NAME")
#      return msgbox "Protected!!!" if script.include?("module ")
      
      send(@@FILE_ALIAS_NAME,args[0]) if args.size == 1
      send(@@FILE_ALIAS_NAME,*args) if args.size > 1
    end
    
   end #end module PROTECT EVAL
  end #end module ENCRYPTER
end #end module ESTRIOLE

# audio decrypt code
module Audio
  include ESTRIOLE::ENCRYPTER
  include_module_methods ESTRIOLE::ENCRYPTER
  class << self
    alias :est_encrypter_bgm_play :bgm_play
    alias :est_encrypter_bgm_stop :bgm_stop
    alias :est_encrypter_bgs_play :bgs_play
    alias :est_encrypter_me_play :me_play
    alias :est_encrypter_se_play :se_play
  end
  def self.est_play_audio(symbol,*args)
    self.prepare_decrypt_list if !File.exist?("#{@@FOLDER}/#{@@DECRYPT_LIST_FILENAME}")
    decrypt_list = Marshal.load(File.open("#{@@FOLDER}/#{@@DECRYPT_LIST_FILENAME}"))
    arr = args[0].split("/")
    arr[arr.size-1] = arr[arr.size-1].split(".")[0]       
    sound = load_data("Data/Z_EST_#{arr.join("_")}.rvdata2") rescue nil
    return send(symbol,*args) if !sound

    if !decrypt_list[args[0]]
    path = self.decrypt(args[0]) 
    decrypt_list[args[0]] = path
    else
      if File.exist?(decrypt_list[args[0]])
        path = decrypt_list[args[0]]
      else
        path = self.decrypt(args[0]) 
        decrypt_list[args[0]] = path
      end
    end
      begin
      list = "#{@@FOLDER}/#{@@DECRYPT_LIST_FILENAME}"
      b = File.open(list, "wb")
      Marshal.dump(decrypt_list,b)
      b.close
      rescue
      raise "Run Game.exe with Administrator right \n(right click > run with administrator right)" if !$TEST
      raise "You have no access to Folder... File still Encrypted though.\nTo play: Run Game.exe with Administrator right" 
      end
      
    args[0] = path
    send(symbol,*args)    
  end
  def self.bgm_play(*args)
    est_play_audio(:est_encrypter_bgm_play,*args)
  end
  def self.bgs_play(*args)
    est_play_audio(:est_encrypter_bgs_play,*args)
  end
  def self.me_play(*args)
    est_play_audio(:est_encrypter_me_play,*args)
  end
  def self.se_play(*args)
    est_play_audio(:est_encrypter_se_play,*args)
  end
  
end

# movie decrypt code
module Graphics  
  include ESTRIOLE::ENCRYPTER
  include_module_methods ESTRIOLE::ENCRYPTER
  class << self; alias :est_encrypter_play_movie :play_movie ; end
  def self.play_movie(*args)
    self.prepare_decrypt_list if !File.exist?("#{@@FOLDER}/#{@@DECRYPT_LIST_FILENAME}")
    decrypt_list = Marshal.load(File.open("#{@@FOLDER}/#{@@DECRYPT_LIST_FILENAME}"))
    arr = args[0].split("/")
    arr[arr.size-1] = arr[arr.size-1].split(".")[0]       
    sound = load_data("Data/Z_EST_#{arr.join("_")}.rvdata2") rescue nil
    return send(:est_encrypter_play_movie,*args) if !sound

    if !decrypt_list[args[0]]
    path = self.decrypt(args[0]) 
    decrypt_list[args[0]] = path
    else
      if File.exist?(decrypt_list[args[0]])
        path = decrypt_list[args[0]]
      else
        path = self.decrypt(args[0]) 
        decrypt_list[args[0]] = path
      end
    end
    
      begin
      list = "#{@@FOLDER}/#{@@DECRYPT_LIST_FILENAME}"
      b = File.open(list, "wb")
      Marshal.dump(decrypt_list,b)
      b.close
      rescue
      raise "Run Game.exe with Administrator right \n(right click > run with administrator right)" if !$TEST
      raise "You have no access to Folder... File still Encrypted though.\nTo play: Run Game.exe with Administrator right" 
      end
      
    args[0] = path
    send(:est_encrypter_play_movie,*args)    
  end
end

# graphic decrypt code
module Cache
  include ESTRIOLE::ENCRYPTER
  include_module_methods ESTRIOLE::ENCRYPTER
  class << self; alias :est_encrypter_normal_bitmap normal_bitmap; end
  def self.normal_bitmap(*args)
    self.prepare_decrypt_list if !File.exist?("#{@@FOLDER}/#{@@DECRYPT_LIST_FILENAME}")
    decrypt_list = Marshal.load(File.open("#{@@FOLDER}/#{@@DECRYPT_LIST_FILENAME}"))
    arr = args[0].split("/")
    arr[arr.size-1] = arr[arr.size-1].split(".")[0]       
    sound = load_data("Data/Z_EST_#{arr.join("_")}.rvdata2") rescue nil
    return send(:est_encrypter_normal_bitmap,*args) if !sound

    if !decrypt_list[args[0]]
    path = self.decrypt(args[0]) 
    decrypt_list[args[0]] = path
    else
      if File.exist?(decrypt_list[args[0]])
        path = decrypt_list[args[0]]
      else
        path = self.decrypt(args[0]) 
        decrypt_list[args[0]] = path
      end
    end
      begin
      list = "#{@@FOLDER}/#{@@DECRYPT_LIST_FILENAME}"
      b = File.open(list, "wb")
      Marshal.dump(decrypt_list,b)
      b.close
      rescue
      raise "Run Game.exe with Administrator right \n(right click > run with administrator right)" if !$TEST
      raise "You have no access to Folder... File still Encrypted though.\nTo play: Run Game.exe with Administrator right" 
      end
    args[0] = path
    send(:est_encrypter_normal_bitmap,*args)    
  end  
end

class RPG::BGM < RPG::AudioFile
  def replay
    Audio.bgm_stop
    play(@pos)
  end
end

# disabling Event script command to write variable to file / console / msgbox
class Game_Interpreter
  include ESTRIOLE::ENCRYPTER::PROTECT_EVAL
  
  class << self 
    alias_method "#{@@INSTANCE_METHODS_ALIAS_NAME}".to_sym , :instance_methods
    alias_method "#{@@METHODS_ALIAS_NAME}".to_sym , :methods
  end    
  
  alias_method "#{@@FILE_ALIAS_NAME}".to_sym, :eval
  def eval(script)
    check_eval(script)
  end
  def self.instance_methods
    return eval("#{@@INSTANCE_METHODS_ALIAS_NAME.to_s}") - [@@FILE_ALIAS_NAME]
  end
  def self.methods
    return eval("#{@@METHODS_ALIAS_NAME.to_s}") - [@@INSTANCE_METHODS_ALIAS_NAME, @@METHODS_ALIAS_NAME]
  end
end

# disabling damage formula command to write variable to file / console / msgbox
class RPG::UsableItem::Damage
  include ESTRIOLE::ENCRYPTER::PROTECT_EVAL
  
  class << self 
    alias_method "#{@@INSTANCE_METHODS_ALIAS_NAME}".to_sym , :instance_methods
    alias_method "#{@@METHODS_ALIAS_NAME}".to_sym , :methods
  end    
  
  alias_method "#{@@FILE_ALIAS_NAME}".to_sym, :eval
  def eval(*args)
    check_eval(@formula,*args)
  end
  def self.instance_methods
    return eval("#{@@INSTANCE_METHODS_ALIAS_NAME.to_s}") - [@@FILE_ALIAS_NAME]
  end
  def self.methods
    return eval("#{@@METHODS_ALIAS_NAME.to_s}") - [@@INSTANCE_METHODS_ALIAS_NAME, @@METHODS_ALIAS_NAME]
  end
end

#code run
ESTRIOLE::ENCRYPTER.convert_graphic_to_rvdata2
ESTRIOLE::ENCRYPTER.convert_sound_to_rvdata2
ESTRIOLE::ENCRYPTER.convert_video_to_rvdata2

ESTRIOLE::ENCRYPTER.est_decrypt_all

ESTRIOLE.send(:remove_const, :ENCRYPTER)