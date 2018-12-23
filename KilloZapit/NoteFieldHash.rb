#==============================================================================
# ** Note Field Hash 
#------------------------------------------------------------------------------
#
# By Killo Zapit
#
# Partly based on, and compatible with, Syvkal's Notes Field System.
# Uses slightly different logic and has some new features.
# Most notably new methods to get note fields for Game_Actor, Game_Enemy,
# Game_Event, and Game_Map.
#
#------------------------------------------------------------------------------
#
# Basic syntax to put in notes should match ruby syntax:
# ":" followed by a identifier key, then "=>", then the value.
# Identifier keys should have no spaces, and values should be valid ruby
# code. If there is an error evaluating the value, it will be assumed to
# be a string. For compatibility's sake, if the line ends with a comma, 
# the comma will be ignored.
#
# Some examples:
# :one => 1
# :name => "Mighty Z Lord"
# :foo => :bar
# :array => [1, 2, 3, 4]
#
#------------------------------------------------------------------------------
# New feature: Loading from a file! Because sometimes the notebox is 
# just too cramped.
# 
# To do it put a line in the notes like this:
# <load_notes x>
# The path can be configured below and defaults as ./data/note/
# (where '.' is the current working directory, which should be where game.exe
# is)
#==============================================================================

$imported = {} if $imported == nil
$imported["Notes Field System"] = true # same as Syvkal's

#==============================================================================
# * Base module
#==============================================================================

module NoteHash
  
  NOTE_PATH = "./data/note/"
  HASH_REGEX = /\A\s*:([^\s:]*)\s*=>\s*(.*[^\s,])/
  LOAD_REGEX =  /^<\s*load_notes\s*(.*)\s*>/
  
  # Gets a full hash from a multi-line string
  def self.get_hash(note)
    notestr = ''+note
    hash = {}
    notestr.split(/[\r\n]+/).each do |line|
      read_hash_string(hash, line)
    end
    return hash
  end
  
  # Sets a hash key/value pair from a string (if it matches)
  def self.read_hash_string(hash, string)
    
    if string =~ LOAD_REGEX
      filename = NOTE_PATH+$1
      if File.exists?(filename)
        puts "Including notefile: " + filename
        lines = File.readlines(filename)
        lines.each do |line|
          read_hash_string(hash, line)
        end
      else
        puts "Can't find notefile: " + filename
      end
    elsif string =~ HASH_REGEX
      hash[$1.to_sym] = eval($2) rescue $2
    end
  end
  
end

#==============================================================================
# * Methods to gets the field off of notes
#==============================================================================

# "||=" is the best. "x ||= y" is basicly short for "x = y unless x; x"

class RPG::BaseItem

  def note_field
    @note_field ||= NoteHash.get_hash(note)
  end
  
end

class RPG::Map

  def note_field
    @note_field ||= NoteHash.get_hash(note)
  end
  
end

#==============================================================================
# * Redirection methods to get notes for Game_ objects
#==============================================================================

class Game_Actor < Game_Battler
  
  def note_field
    self.actor.note_field
  end

end

class Game_Enemy < Game_Battler
  
  def note_field
    self.enemy.note_field
  end

end

class Game_Map
  
  def note_field
    return @map.note_field
  end

end

#==============================================================================
# * Event comment hashes
#==============================================================================

class Game_Event < Game_Character
  
  # aliased method: Check a event page's comments for hash key/values
  alias_method :setup_page_note_base, :setup_page
  def setup_page(new_page)
    setup_page_note_base(new_page)
    hash = {}
    unless @page.nil?
      @page.list.each do |item|
        next unless item.code == 108 || item.code == 408
        NoteHash.read_hash_string(hash, item.parameters[0])
      end
    end
    @note_field = hash
  end
  
  # Did I mention I like "||="?  
  def note_field
    @note_field ||= {} 
  end
  
end