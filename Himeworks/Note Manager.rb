=begin
#===============================================================================
 Title: Note Manager
 Author: Hime
 Date: Mar 11, 2014
 URL: http://www.himeworks.com/2012/10/14/note-manager/
--------------------------------------------------------------------------------
 ** Change log
 Mar 11, 2014
   - fixed bug where `note src` tag was not working properly
 Oct 28, 2012
   - added support for loading external notes.
   - changed name
 Oct 14, 2012
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
 
 This script adds various note-tagging functionality, including
   -Note Sections
   -Loading external notes stored in text files
 
 This script adds sections to your notebox, called "note sections"
 Note sections are of the form
 
 <note: name ex_data>
    note
 </note>
 
 Where
   name is the name of this note, as a string
   ex_data is some extra data that you might need, as a string
   note is the content of this note section, as a string
   
 Note sections are available in all objects that have notes by default,
 including all BaseItem classes, Map class, and Tileset class.
   
 Several note sections have been reserved and should not be used
   
   drop_item: note for an Enemy::DropItem
   action: note for an Enemy::Action object.
   event: note for an RPG::Event object on a map
   page: note for an RPG::Event::Page object for a particular event
   
 Notes can be stored in external files and referenced in note boxes.
 There are two ways to load external notes.
 
 1: Automatic reference.
 
 All classes that support notes will automatically search for an external
 note file and load it if it exists.
 
 2: Explicit reference
 
 To load an external note explicitly, add the tag to your note:
 
   <note_src: NOTE_PATH>
   
 Where NOTE_PATH is the filename of the desired note (eg: my_note.txt)
 The same rules apply to note sections.
 
 All external notes must be placed in the specific Notes folder, though you may
 have subfolders if needed.
 
 By default the notes folder is "Data/Notes/", and all notes are assumed to
 be at this location.  The reason why it is placed here is so that they will be
 encrypted if you choose to encrypt your project.
 
 To load notes that are inside subfolders, you would include the name of the
 subfolders. For example if your note path is
 
    "Data/Notes/Events/Map1/ev001.txt"
    
 You would tag this with
 
    <note_src: Events/Map1/ev001.txt>
 
--------------------------------------------------------------------------------
 ** Usage
 
 To add drop item notetags, first create a note section
 
 <note: drop_item 1>
    hello drop
 </note>

 This sets up a note box for the first drop item and creates a note with
 "hello drop"
 
 Now, alias the `load_notetag` method defined in Enemy::DropItem and add your
 own parsing logic
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_NoteManager] = true
#===============================================================================
# ** Configuration
#===============================================================================
module NoteManager
  
  # Creates notes for database objects automatically.
  # Set this to false if you don't need it
  Auto_Create_Notes = true
  
  # Where all database notes will be stored
  Note_Path = "Data/Notes/"

#===============================================================================
# ** Rest of the script
#===============================================================================
  # Convert the filename to the appropriate path rooted under the Note Path
  Note_Table = {
    :actor        => Note_Path + "Actors/actor%d.txt",
    :class        => Note_Path + "Classes/class%d.txt",
    :learn        => Note_Path + "Classes/class%d_learn%d.txt",
    :skill        => Note_Path + "Skills/skill%d.txt",
    :item         => Note_Path + "Items/item%d.txt",  
    :weapon       => Note_Path + "Weapons/weapon%d.txt",
    :armor        => Note_Path + "Armors/armor%d.txt",
    :enemy        => Note_Path + "Enemies/enemy%d.txt",
    :state        => Note_Path + "States/state%d.txt",
    :troop        => Note_Path + "Troops/troop%d.txt",
    :tileset      => Note_Path + "Tilesets/tileset%d.txt",
    :animation    => Note_Path + "Animations/animation%d.txt",
    :map          => Note_Path + "Maps/Map%d/map.txt",
    :event        => Note_Path + "Maps/map%d/event%d.txt",
    :vehicle      => Note_Path + "Vehicles/vehicle%d.txt",
    :page         => Note_Path + "Maps/map%d/event%d_page%d.txt",
    :drop_item    => Note_Path + "Enemies/enemy%d_drop%d.txt",
    :enemy_action => Note_Path + "Enemies/enemy%d_action%d.txt"
  }
  
  Section_Regex = /<note:? (\w+)(.*?)>(.*?)<\/note>/im
  Note_Regex = /<note[-_ ]src:\s*(.*?)\s*>/i
  
  # Note Directory Struture construction
  
  def self.make_dir(path)
    Dir.mkdir(path) unless Dir.exist?(path)
  end
  
  def self.make_file(path)
    File.open(path, 'w') unless File.exist?(path)
  end
  
  def self.make_notes(type, path, prefix, suffix="")
    data = load_data(path)
    data.size.times {|id|
      make_file(sprintf(Note_Table[type], id + 1, prefix, suffix))
    }
  end
  
  def self.make_map_dirs
    mapinfo = load_data("Data/MapInfos.rvdata2")
    mapinfo.each {|id, map|
      make_dir(Note_Path + "Maps/" + "Map%d" %id)
      make_event_notes(id)
    }
  end
  
  def self.make_event_notes(map_id)
    map = load_data("Data/Map%03d.rvdata2" %map_id)
    map.events.each {|id, event|
      make_file(sprintf(Note_Table[:event], map_id, id))
      make_page_notes(event.pages, map_id, id)
    }
  end
  
  def self.make_page_notes(pages, map_id, id)
    pages.each_with_index {|page, i|
      make_file(sprintf(Note_Table[:page], map_id, id, i+1))
    }
  end
  
  def self.make_note_files
    make_map_dirs
    make_notes(:actor, "Data/Actors.rvdata2", "actor")
    make_notes(:enemy, "Data/Enemies.rvdata2", "enemy")
    make_notes(:class, "Data/Classes.rvdata2", "class")
    make_notes(:weapon, "Data/Weapons.rvdata2", "weapon")
    make_notes(:armor, "Data/Armors.rvdata2", "armor")
    make_notes(:item, "Data/Items.rvdata2", "item")
    make_notes(:skill, "Data/Skills.rvdata2", "skill")
    make_notes(:state, "Data/States.rvdata2", "state")
    make_notes(:tileset, "Data/Tilesets.rvdata2", "tileset")
    make_notes(:troop, "Data/Troops.rvdata2", "troop")
    make_notes(:animation, "Data/Animations.rvdata2", "animation")
  end
  
  def self.make_note_directory
    
    make_dir(Note_Path)
    make_dir(Note_Path + "Actors")
    make_dir(Note_Path + "Classes")
    make_dir(Note_Path + "Items")
    make_dir(Note_Path + "Skills")
    make_dir(Note_Path + "Weapons")
    make_dir(Note_Path + "Armors")
    make_dir(Note_Path + "States")
    make_dir(Note_Path + "Enemies")
    make_dir(Note_Path + "Troops")
    make_dir(Note_Path + "Tilesets")
    make_dir(Note_Path + "Animations")
    make_dir(Note_Path + "Vehicles")
    make_dir(Note_Path + "Maps")
    make_note_files
  end
  
  # Load the appropriate note file and return its contents
  def self.load_note(type, *args)
    load_data(sprintf(Note_Table[type], *args)) rescue ""
  end

  # Returns an array of Note Section objects with the given name
  def note_sections(name)
    return @note_sections[name.to_s] || [] unless @note_sections.nil?
    load_note_sections
    return @note_sections[name.to_s] || []
  end
  
  def load_note_sections
    @note = self.note || ""
    @note_sections = {}
    @note.scan(Section_Regex).each {|name, args, note|
      @note_sections[name] ||= []
      @note_sections[name] << NoteSection.new(name, note, args)
    }
  end
  
  # Directly mutate the note
  def self.load_external_notes(note, type, *args)
    note ||= ""
    note << "\n" << load_note(type, *args) << "\n"
    paths = note.scan(Note_Regex).flatten
    paths.each do |path|
      note << "\n" << load_data(Note_Path + path) << "\n"
    end
  end
  
  # Construct the note directory structure
  make_note_directory if $TEST && Auto_Create_Notes 
end

# A note section object
class NoteSection
  
  attr_accessor :name         # the name of this section
  attr_accessor :ex_data      # extra data that you might need, as a string
  attr_accessor :note         # the contents of the note
  
  def initialize(name, note, data="")
    @name = name
    @ex_data = data.strip
    @note = note.strip
  end
end

# Load files from non-RM files
class << Marshal
  alias_method(:___load, :load)
  def load(port, proc = nil)
    ___load(port, proc)
  rescue TypeError
    if port.kind_of?(File)
      port.rewind 
      port.read
    else
      port
    end
  end
end unless Marshal.respond_to?(:___load)

# Load external note file
def load_note(type, *args)
  NoteManager.load_note(type, *args)
end

module RPG
  
  #-----------------------------------------------------------------------------
  # * Set up note section for map class
  #-----------------------------------------------------------------------------
  class Map
    include NoteManager
    
    alias :note_sections_events :events
    def events
      note_sections(:event).each {|noteSect| load_event_note(noteSect) }
      @events.each {|key, event| event.load_notetag}
      note_sections_events
    end
    
    def load_event_note(noteSect)
      id = (noteSect.ex_data[0].to_i)
      event = @events[id]
      return unless event
      event.note = noteSect.note
    end
    
    def note
      @note ||= ""
      return @note if @path_checked
      NoteManager.load_external_notes(@note, :map, $game_map.map_id)
      @path_checked = true
      return @note
    end
  end
  
  #----------------------------------------------------------------------------
  # * load notetag for events
  #----------------------------------------------------------------------------
  class Event
    include NoteManager
    
    attr_accessor :note
    def note
      @note ||= ""
      return @note if @path_checked
      NoteManager.load_external_notes(@note, :event, $game_map.map_id, @id)
      @path_checked = true
      return @note
    end
    
    alias :note_sections_pages :pages
    def pages
      unless @pages_checked
        note_sections(:page).each {|noteSect| load_page_note(noteSect) }
        @pages.each_with_index {|page, i|
          page.event_id = @id
          page.page_id = i + 1
          page.load_notetag
        }
        @pages_checked = true
      end
      note_sections_pages
    end
    
    def load_page_note(noteSect)
      page_number = (noteSect.ex_data[0].to_i)
      page = @pages[page_number - 1]
      return unless page
      page.note = noteSect.note
    end
    
    # reserved for aliasing
    def load_notetag
    end
  end
  
  # Event page note tags
  class Event::Page
    attr_accessor :note
    attr_accessor :event_id
    attr_accessor :page_id
    
    def note
      @note ||= ""
      return @note if @path_checked
      
      NoteManager.load_external_notes(@note, :page, $game_map.map_id, @event_id, @page_id)
      @path_checked = true
      return @note
    end
    
    # reserved for aliasing
    def load_notetag
    end
  end

  
  #----------------------------------------------------------------------------
  # * Set up note section for Tileset class
  #----------------------------------------------------------------------------
  class Tileset
    include NoteManager
    
    def note
      @note ||= ""
      return @note if @path_checked
      NoteManager.load_external_notes(@note, :tileset)
      @path_checked = true
      return @note
    end
  end
  
  #----------------------------------------------------------------------------
  # * Set up note section for all BaseItem classes
  #----------------------------------------------------------------------------
  
  class BaseItem
    include NoteManager
    def obj_type
    end
    
    def note
      @note ||= ""
      return @note if @path_checked
      NoteManager.load_external_notes(@note, obj_type, @id)
      @path_checked = true
      return @note
    end
  end
  
  class Actor
    def obj_type
      :actor
    end
  end
  
  class Class
    
    def obj_type
      :class
    end
  end
  
  class Skill
    
    def obj_type
      :skill
    end
  end
  
  class Item
    
    def obj_type
      :item
    end
  end
  
  class Weapon
    
    def obj_type
      :weapon
    end
  end
  
  class Armor
    
    def obj_type
      :armor
    end
  end
  
  class State
    
    def obj_type
      :state
    end
  end  

  #----------------------------------------------------------------------------
  # * Set up enemy drop items and actions notes
  #----------------------------------------------------------------------------
  class Enemy
    
    def obj_type
      :enemy
    end
    
    alias :note_sections_drop_items :drop_items
    def drop_items
      unless @drop_notes_loaded
        note_sections(:drop_item).each {|noteSect| load_drop_note(noteSect)}
        @drop_items.each_with_index {|drop, i|
          drop.enemy_id = @id
          drop.id = i + 1
          drop.load_notetag
        }
        @drop_notes_loaded = true
      end
      note_sections_drop_items
    end
    
    alias :note_sections_actions :actions
    def actions
      unless @action_notes_loaded
        note_sections(:action).each {|noteSect| load_action_note(noteSect)}
        
        @actions.each_with_index {|action, i|
          action.enemy_id = @id
          action.id = i + 1
          action.load_notetag
        }
        @action_notes_loaded = true
      end
      note_sections_actions
    end

    # Parses the note section and passes the note to the proper drop item
    # Creates additional drop items as needed
    def load_drop_note(noteSect)
      index = (noteSect.ex_data[0].to_i) - 1
      
      # create drop item as needed
      @drop_items[index] = DropItem.new if @drop_items[index].nil?
      
      # pass in the note and load notetags
      di = @drop_items[index]
      di.note = noteSect.note
    end
    
    # Parses the note section and passes the note to the proper action item
    # Creates additional actions as needed
    def load_action_note(noteSect)
      index = (noteSect.ex_data[0].to_i) - 1
      
      # create action if it doesn't exist
      @actions[index] = Action.new if @actions[index].nil?
      action = @actions[index]
      action.note = noteSect.note
      
    end
  end
  
  #----------------------------------------------------------------------------
  # * Load enemy drop item note tags
  #----------------------------------------------------------------------------
  class Enemy::DropItem
    attr_accessor :id
    attr_accessor :enemy_id
    attr_accessor :note
    
    def note
      @note ||= ""
      return @note if @path_checked
      NoteManager.load_external_notes(@note, :drop_item, @enemy_id, @id)
      @path_checked = true
      return @note
    end

    # reserved for aliasing
    def load_notetag
    end
  end
  
  #----------------------------------------------------------------------------
  # * Load enemy action note tags
  #----------------------------------------------------------------------------
  
  class Enemy::Action
    attr_accessor :id
    attr_accessor :enemy_id
    attr_accessor :note
    
    def note
      @note ||= ""
      return @note if @path_checked
      NoteManager.load_external_notes(@note, :enemy_action, @enemy_id, @id)
      @path_checked = true
      return @note
    end

    # reserved for aliasing
    def load_notetag
    end
  end
end