=begin
#===============================================================================
 ** Data Backup
 Author: Hime
 Date: Oct 30, 2012
--------------------------------------------------------------------------------
 ** Change log
 Oct 30
   - initial release
--------------------------------------------------------------------------------
 ** Terms of Use
 * Free to use in commercial and non-commercial projects
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script automatically creates a backup whenever you testplay your game.
 It copies all rvdata2 files in your Data folder into its own subfolder inside
 a Backup folder.
 
 Ideally, even if your system crashes or something happens, you should still
 have a recent copy available.
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage
 
 Plug and play
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_DataBackup"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module Tsuki
  module Data_Backup
    
    Run_Script = true
    Backup_Path = "Backup/"
    
#===============================================================================
# ** Rest of the script
#===============================================================================
   
    # Create a folder for your backup. Based on the time
    def self.make_folders(path)
      dir = path.split("/")
      for i in 0...dir.size
        unless dir == "."
          add_dir = dir[0..i].join("/")
          Dir.mkdir(add_dir) unless Dir.exist?(add_dir)
        end
      end
    end
    
    def self.make_backup_folder
      t = Time.now
      @dirName = sprintf("%sBackup %04d-%02d-%02d %02dh%02dm%02ds/", Backup_Path, t.year, t.month, t.day, t.hour, t.min, t.sec)
      make_folders(@dirName)
    end
    
    #---------------------------------------------------------------------------
    # TO-DO: improve file path handling
    #---------------------------------------------------------------------------
    def self.backup_file(path)
      outPath = @dirName + path
      make_folders(outPath.split("/")[0...-1].join("/"))
      File.open(outPath, 'wb') {|outFile|
        File.open(path, 'rb') {|inFile|
          outFile.write(inFile.read)
        }
      }
    end
    
    #---------------------------------------------------------------------------
    # TO-DO: recursively back up any folders as well
    #---------------------------------------------------------------------------
    def self.backup_data
      make_backup_folder
      Dir.glob("Data/*") {|path| backup_file(path) unless File.directory?(path) }
    end
    
    #---------------------------------------------------------------------------
    # Pretty much assumes you don't manually create your own folders or
    # change the names
    #---------------------------------------------------------------------------
    def self.compare_backup_time
      now = Time.now
      last = Dir.glob(Backup_Path + "*")[-1]
      return true unless last
      date = File.basename(last.gsub!("Backup", ""))
      year, month, day, hour, min, sec = [date[0..3], date[4..5], date[6..7], date[8..9], date[10..11], date[12..13]]
    end
    
    def self.needs_backup?
      true
      #return true if compare_backup_time
    end
    
    def self.run
      make_folders(Backup_Path)
      backup_data if needs_backup?
    end
    
    # run it
    run if $TEST && Run_Script
  end
end