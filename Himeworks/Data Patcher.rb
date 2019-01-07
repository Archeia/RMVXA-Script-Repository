=begin
#===============================================================================
 ** Data Patcher
 Author: Hime
 Date: Jun 13, 2013
--------------------------------------------------------------------------------
 ** Change log
 Jun 13, 2013
   - patch directory structure is automatically generated now when you testplay
 Oct 28, 2012
   - added support for loading arbitrary files from encrypted archive
 Oct 20, 2012
   - initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script provides "patching" functionality for the game.
 This allows you to distribute updates to your game without asking
 the end user to download the entire game.
 
 This script is not suitable for providing DLC's or any sort of content
 that is "combined" with existing data since it basically overwrites existing
 data rather than add to it.
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
--------------------------------------------------------------------------------
 ** Usage 
 
 -- Setting up the patch folder --
 
 Set the patch folder in the configuration below. By default it is the "Patch"
 folder. 
 
 Testplay the game, and the patch directory structure will be created for you.
 Go to your project folder and look for the patch folder and open it. Inside,
 you will see something that resembles your own project folder.
 
 -- Creating patches --
 
 There is basically no work required. All you have to do is take your files
 and place them into the patch folder. The script will automatically load them
 when the game is running.
   
 For example, if you update some Actor information, then you will take the
 Actors.rvdata2 file from your data folder and copy it into the patch folder's
 Data folder. To see the effects of the data patcher, you will need to have
 a second project that is using the outdated files.
 
 -- Distributing patches --
 
 Pack up the patch folder using something like 7zip or your own setup file.
 You can then send it to your clients.

 -- Applying patches --
 
 Understand how to use this script and then figure out the best way to inform
 your clients. The way they will apply your patches is the same way you created
 them: just place them in the appropriate folders in the patch folder.
 
--------------------------------------------------------------------------------
 ** Credits
 
 Credits to Cremno for loading non-Marshal data from encrypted archive
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_DataPatcher"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Data_Patcher
    
    # Folder where all of the patch files will be loaded from. It is
    # located in the project's root.
    Patch_Folder = "Patch/"
    
#===============================================================================
# ** Rest of the script
#===============================================================================

    def self.make_dir(*args)
      path = File.join(args)
      Dir.mkdir(path) unless Dir.exist?(path)
    end

    def self.make_patch_directory
      make_dir("Patch")
      make_dir("Patch", "Audio")
      make_dir("Patch", "Audio", "BGM")
      make_dir("Patch", "Audio", "BGS")
      make_dir("Patch", "Audio", "ME")
      make_dir("Patch", "Audio", "SE")
      make_dir("Patch", "Data")
      make_dir("Patch", "Graphics")
      make_dir("Patch", "Graphics", "Animations")
      make_dir("Patch", "Graphics", "Battlebacks1")
      make_dir("Patch", "Graphics", "Battlebacks2")
      make_dir("Patch", "Graphics", "Battlers")
      make_dir("Patch", "Graphics", "Characters")
      make_dir("Patch", "Graphics", "Faces")
      make_dir("Patch", "Graphics", "Parallaxes")
      make_dir("Patch", "Graphics", "Pictures")
      make_dir("Patch", "Graphics", "System")
      make_dir("Patch", "Graphics", "Tilesets")
      make_dir("Patch", "Graphics", "Titles1")
      make_dir("Patch", "Graphics", "Titles2")
      make_dir("Patch", "Fonts")
      make_dir("Patch", "Movies")
      make_dir("Patch", "System")
    end
    
    # For (relative) paths that have an extension
    def self.patch_path(path)
      return Patch_Folder + path
    end
    
    # For filenames that do not require an extension.
    def self.get_patch_name(path)
      if !(res = Dir::glob("Patch/#{path}.*")).empty?
        return res[0]
      else
        return path
      end
    end
    
    # initialization routines
    make_patch_directory if $TEST
  end
end

# Change all bitmap loading to search patch folder
module Cache

  def self.load_bitmap(folder_name, filename, hue = 0)
    @cache ||= {}
    if filename.empty?
      empty_bitmap
    elsif hue == 0
      normal_bitmap(TH::Data_Patcher.get_patch_name(folder_name + filename))
    else
      hue_changed_bitmap(TH::Data_Patcher.get_patch_name(folder_name + filename), hue)
    end
  end
end

# Change audio files to search patch folder
module RPG
  class AudioFile
    def get_patch_name(path)
      TH::Data_Patcher.get_patch_name(path)
    end
  end
  
  class BGM < AudioFile
    def play(pos = 0)
      if @name.empty?
        Audio.bgm_stop
        @@last = RPG::BGM.new
      else
        Audio.bgm_play(get_patch_name('Audio/BGM/' + @name), @volume, @pitch, pos)
        @@last = self.clone
      end
    end
  end
  
  class BGS < AudioFile
    def play(pos = 0)
      if @name.empty?
        Audio.bgs_stop
        @@last = RPG::BGS.new
      else
        Audio.bgs_play(get_patch_name('Audio/BGS/' + @name), @volume, @pitch, pos)
        @@last = self.clone
      end
    end
  end
  
  class ME < AudioFile
    def play
      if @name.empty?
        Audio.me_stop
      else
        Audio.me_play(get_patch_name('Audio/ME/' + @name), @volume, @pitch)
      end
    end
  end
  
  class SE < AudioFile
    def play
      unless @name.empty?
        Audio.se_play(get_patch_name('Audio/SE/' + @name), @volume, @pitch)
      end
    end
  end
end

class Scene_Map < Scene_Base
  
  #-----------------------------------------------------------------------------
  # Overwrite. 
  #-----------------------------------------------------------------------------
  def perform_battle_transition
    Graphics.transition(60, TH::Data_Patcher.get_patch_name("Graphics/System/BattleStart"), 100)
    Graphics.freeze
  end
end

# load data from patch folder if it exists,
# otherwise load default data

alias :th_data_patcher_load_data :load_data
def load_data(path)
  
  if FileTest.exist?(TH::Data_Patcher.patch_path(path)) 
    th_data_patcher_load_data(TH::Data_Patcher.patch_path(path))
  else
    th_data_patcher_load_data(path)
  end
end

class << Marshal
  alias_method(:th_core_load, :load)
  def load(port, proc = nil)
    th_core_load(port, proc)
  rescue TypeError
    if port.kind_of?(File)
      port.rewind
      port.read
    else
      port
    end
  end
end unless Marshal.respond_to?(:th_core_load)