# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Load Notes from Text Files                            │ v0.2 │ (8/28/12) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
# Thanks:
#     Tsukihime, mentioning notebox management issues
#     Victor Sant, mentioning loading notes from txt files
#--------------------------------------------------------------------------
# This script allows you to use .txt files as an extension for database
# noteboxes in hopes that it will help make notebox management much 
# easier. This script only extends Noteboxes meaning you can 
# still use the database Noteboxes normally if you want. Database 
# objects can even share the same .txt files if desired.
#
# From what I heard, there is already an existing script that does what
# this script does. However, I couldn't find it so I wanted to see if I
# could make it myself with certain ideal options for developers. It 
# turned out pretty simple.
#
# Ironically, this script utilizes notetags.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v0.2 : Efficiency update. (8/28/2012)
# v0.1 : Testing release. (8/26/2012)
#--------------------------------------------------------------------------
#   ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
# 
# I recommend placing this script above all other custom scripts in 
# your script edtior.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Notetags ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Note: Some tags are given shorter tags for typing convenience. You only
#       need to use one <tag> from a given group for a notebox. 
#       Use common sense.
#
# The following Notetags are for Actors, Classes, Skills, Items,
# Weapons, Armors, Enemies, States, and Tilesets:
#
# <txtnote: filename>
# <txtnote: filename, path>
#   This tag will append the contents of a .txt file to the database
#   object's Notebox where filename is a .txt file name without an 
#   extension. The default directory that is searched is defined in the
#   customization module. You can use this tag as many times as you like 
#   in the same Notebox with different .txt files. The same .txt file can 
#   be used for multiple database objects. path is the directory path 
#   starting from the project's root folder and is optional in the tag. 
#
#   DO NOT USE THIS TAG WITHIN A LOADED .txt FILE!
#
#   Map noteboxes are not supported.
#
#--------------------------------------------------------------------------
#   ++ Text Files ++
#--------------------------------------------------------------------------
# .txt files do not require any special setup. You can treat them like
# a standard notebox.
#
# Word wrap in txt files is not recommended though.
#--------------------------------------------------------------------------
#   ++ Compatibility ++
#--------------------------------------------------------------------------
# This script aliases the following default VXA methods:
#
#     DataManager#load_normal_database
#     DataManager#load_battle_test_database
#
# There are no default method overwrites.
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
#   ++ Terms and Conditions ++
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission.
#
# Free for non-commercial and commercial use.
#
# Newest versions of this script can be found at 
#                                          http://mrbubblewand.wordpress.com/
#=============================================================================

$imported ||= {}
$imported["BubsTxtNote"] = true

#==========================================================================
# ++ START OF USER CUSTOMIZATION MODULE ++
#==========================================================================
module Bubs
  module TxtNote
  #--------------------------------------------------------------------------
  #   Default Text File Directory
  #--------------------------------------------------------------------------
  # This setting determines the default directory for .txt files.
  # The root is the root folder of the project.
  #
  # It is recommended that the folder be within a directory that is 
  # automatically encrypted when compressing game data.
  DIR_DEFAULT = "Data/Notes/"
  
  #--------------------------------------------------------------------------
  #   Error Message Setting
  #--------------------------------------------------------------------------
  # true  : Errors related to this script will appear in the console window.
  # false : Errors will not be shown in the console window.
  SHOW_ERROR_MESSAGES = true
  
  end # module TxtNote
end # module Bubs


#==========================================================================
# ++ END OF USER CUSTOMIZATION MODULE ++
#==========================================================================


#==========================================================================
# ++ TxtNoteAppend
#==========================================================================
module DataManager
  #--------------------------------------------------------------------------
  # alias : load_normal_database
  #--------------------------------------------------------------------------
  class << self; alias load_normal_database_bubs_txtnote load_normal_database; end;
  def self.load_normal_database
    load_normal_database_bubs_txtnote # alias
    load_bubs_txtnote
  end
  #--------------------------------------------------------------------------
  # alias : load_battle_test_database
  #--------------------------------------------------------------------------
  class << self; alias load_battle_test_database_bubs_txtnote load_battle_test_database; end;
  def self.load_battle_test_database
    load_battle_test_database_bubs_txtnote # alias
    load_bubs_txtnote
  end

  #--------------------------------------------------------------------------
  # new method : load_bubs_txtnote
  #--------------------------------------------------------------------------
  def self.load_bubs_txtnote
    groups = [$data_actors, $data_classes, $data_skills, $data_items,
              $data_weapons, $data_armors, $data_enemies, $data_states,
              $data_tilesets]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_bubs_txtnote
      end # for
    end # for
  end # def
  
end # module DataManager


#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp
    TXTNOTE_TAG = /<TXTNOTE:\s*(\w+),?\s*(.+)?\s*>/i
  end # module Regexp
end # module Bubs


#==========================================================================
# ++ TxtNoteAppend
#==========================================================================
module TxtNoteAppend
  #--------------------------------------------------------------------------
  # load_bubs_txtnote
  #--------------------------------------------------------------------------
  def load_bubs_txtnote
    self.note.split(/[\r\n]+/).each { |line|
      if line =~ Bubs::Regexp::TXTNOTE_TAG ? true : false
        begin
          File.open(get_txtfile($1, $2), "r") { |file| append_note(file) }
        rescue
          print_txtnote_error($1, $2) if Bubs::TxtNote::SHOW_ERROR_MESSAGES
        end
      end # if
    } # self.note
  end # def
  
  #--------------------------------------------------------------------------
  # append_note
  #--------------------------------------------------------------------------
  def append_note(file)
    self.note << "\r\n" << file.read
  end
  
  #--------------------------------------------------------------------------
  # get_txtfile
  #--------------------------------------------------------------------------
  def get_txtfile(filename, pathname = false)
    prepend_dir(pathname) << filename << txtnote_ext
  end
  
  #--------------------------------------------------------------------------
  # prepend_dir
  #--------------------------------------------------------------------------
  def prepend_dir(pathname)
    pathname ? pathname : txtnote_dir_default
  end
    
  #--------------------------------------------------------------------------
  # txtnote_dir_default
  #--------------------------------------------------------------------------
  def txtnote_dir_default
    Bubs::TxtNote::DIR_DEFAULT.clone
  end
  
  #--------------------------------------------------------------------------
  # ext_default
  #--------------------------------------------------------------------------
  def txtnote_ext
    return ".txt"
  end
  
  #--------------------------------------------------------------------------
  # print_txtnote_error
  #--------------------------------------------------------------------------
  def print_txtnote_error(filename, pathname = false)
    p "#{get_txtfile(filename, pathname)} not found. #{name} note append skipped."
  end
  
end # module DataManager


#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
class RPG::BaseItem
  include TxtNoteAppend
end


#==========================================================================
# ++ RPG::Tileset
#==========================================================================
class RPG::Tileset
  include TxtNoteAppend
end 
