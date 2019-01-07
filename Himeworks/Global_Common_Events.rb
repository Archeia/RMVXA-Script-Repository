=begin
#===============================================================================
 Title: Global Common Events
 Author: Hime
 Date: May 26, 2015
--------------------------------------------------------------------------------
 ** Change log
 May 26, 2015
   - refresh global common events on load
 Jul 3, 2013
   - bug fix: game crashed when loading a saved game
 Apr 29, 2013
   - fixed typo that prevented global common events from being non-blocked
 Apr 17, 2013
   - added non-blocked global common events
 Apr 13, 2013
   - added scene whitelist
   - added scene blacklist
   - added saving/loading
   - Initial release
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
 
 This script allows you to assign certain common events as "global" common
 events. These are common events that will be run in any scene, as long as
 the conditions for running are met.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 -- Setting up global common events --
 
 To set a common event as a global common event, create a comment with the
 following string
 
   <global common event>
   
 If you would like the common events to continue running even if the message
 window is open, use the comment
 
   <global common event: non-blocking>
   
 In the configuration section, there is a list of scenes that should not
 update global common events.
 
 -- Filtering scenes --
 
 You may not want all global common events to run in every scene, but you may
 want to run certain global common events in certain scenes, but not others.
 
 You can control which scenes global common events run in using a set of
 filters, organized into two types of filters: whitelists, and blacklists.
 
 Whitelists determine which scenes allow global common events to update.
 If the whitelist is empty, then all scenes will update events.
 If the whitelist is not empty, then only those scenes will update events.
 
 Blacklists determine which scenes disallow global common events to update.
 The blacklist is used to prevent updating in certain scenes, while allowing
 all other scenes to update events.
 
 Note that by this definition, whitelists are more restrictive. For example,
 if you put Scene_Map on the whitelist, then global common events will
 ONLY run on the map and nowhere else.

 -- Universal filters --
 
 In the configuration section, there is a whitelist and a blacklist. These
 are universal filter lists: they apply to all global common events.
 
 -- Local filters --
   
 Each global common event can have its own whitelist and blacklist.
 To specify filters, create a comment of the form
 
   <global scene blacklist: scene_name1, scene_name2, ... >
   <global scene whitelist: scene_name3, scene_name4, ... >
   
 You must specify the exact scene name (eg: Scene_Title), each scene separated
 by a single comma.
 
 Local filters only apply to the events that they are defined in and do not
 affect other events.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_GlobalCommonEvents"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Global_Common_Events
    
    # list of scenes that global common events can only run in.
    # Leave this empty if you want global common events to run in all scenes
    Scene_Whitelist = []
    
    # list of scenes that global common events cannot run in
    Scene_Blacklist = [:Scene_Title, :Scene_Gameover]
    
#===============================================================================
# ** Rest of Script
#===============================================================================
    Regex = /<global common event(:\s*(.*))?>/i
    Blacklist_Regex = /<global scene blacklist: (.*)>/im
    Whitelist_Regex = /<global scene whitelist: (.*)>/im
  end
end

module RPG
  class CommonEvent
    
    alias :th_global_common_event_trigger :trigger
    def trigger
      parse_global_trigger unless @is_global_trigger_checked
      th_global_common_event_trigger
    end
    
    def parse_global_trigger
      @global_scene_blacklist = []
      @global_scene_whitelist = []
      @list.each do |cmd|
        if cmd.code == 108
          case cmd.parameters[0] 
          when TH::Global_Common_Events::Regex
            @trigger = :global 
            @non_blocking_common_event = $2 ? $2.downcase.eql?("non-blocking") : false
          when TH::Global_Common_Events::Blacklist_Regex
            @global_scene_blacklist << $1.split(",").map {|name| name.strip.to_sym}
          when TH::Global_Common_Events::Whitelist_Regex
            @global_scene_whitelist << $1.split(",").map {|name| name.strip.to_sym}
          end
        end
      end
      @global_scene_blacklist.flatten!
      @global_scene_whitelist.flatten!
      @is_global_trigger_checked = true
    end
    
    def global_scene_blacklist
      return @global_scene_blacklist unless @global_scene_blacklist.nil?
      parse_global_trigger
      return @global_scene_blacklist
    end
    
    def global_scene_whitelist
      return @global_scene_whitelist unless @global_scene_whitelist.nil?
      parse_global_trigger
      return @global_scene_whitelist
    end
    
    def global?
      self.trigger == :global
    end
    
    def non_blocking_common_event?
      return @non_blocking_common_event unless @non_blocking_common_event.nil?
      parse_global_trigger
      return @non_blocking_common_event
    end
  end
end

#-------------------------------------------------------------------------------
# Global common events should be created at the start of the game
#-------------------------------------------------------------------------------
module DataManager
  class << self
    alias :th_global_common_events_create_game_objects :create_game_objects
    alias :th_global_common_events_make_save_contents :make_save_contents
    alias :th_global_common_events_extract_save_contents :extract_save_contents
  end
  
  #-----------------------------------------------------------------------------
  # Set up our global common events
  #-----------------------------------------------------------------------------
  def self.create_game_objects
    th_global_common_events_create_game_objects
    $game_global_common_events = Game_GlobalCommonEvents.new
  end
  
  def self.make_save_contents
    contents = th_global_common_events_make_save_contents
    contents[:global_common_events] = $game_global_common_events
    contents
  end
  
  def self.extract_save_contents(contents)
    th_global_common_events_extract_save_contents(contents)
    if contents[:global_common_events]
      $game_global_common_events = contents[:global_common_events]
      $game_global_common_events.refresh
    else
      $game_global_common_events = Game_GlobalCommonEvents.new
    end    
  end
end

class Game_Interpreter
  
  attr_accessor :non_blocking_common_event
  
  alias :th_global_interpreter_wait_for_message :wait_for_message
  def wait_for_message
    return if @non_blocking_common_event
    th_global_interpreter_wait_for_message
  end
end

#-------------------------------------------------------------------------------
# A wrapper for our global common events.
#-------------------------------------------------------------------------------
class Game_GlobalCommonEvents
  
  def initialize
    @data = []
    setup_global_common_events
  end
  
  def setup_global_common_events
    $data_common_events.each do |event|
      if event && event.global?
        @data.push(Game_GlobalCommonEvent.new(event.id))
      end
    end
  end
  
  def update
    @data.each do |ev|
      ev.update
    end
  end
  
  def refresh
    @data.each do |ev|
      ev.refresh
    end
  end
end

#-------------------------------------------------------------------------------
# The global common event class. Same as a regular common event, except it is
# always active
#-------------------------------------------------------------------------------
class Game_GlobalCommonEvent < Game_CommonEvent
  
  def scene_blacklist
    @event.global_scene_blacklist
  end
  
  def scene_whitelist
    @event.global_scene_whitelist
  end
  
  def refresh
    super
    @interpreter.non_blocking_common_event = @event.non_blocking_common_event? if @interpreter
  end
  
  def active?
    true
  end
  
  #-----------------------------------------------------------------------------
  # Only does anything if the switch is active though
  #-----------------------------------------------------------------------------
  def update
    return unless conditions_met?
    super
  end
  
  #-----------------------------------------------------------------------------
  # All conditions must be met before the common event will update
  #-----------------------------------------------------------------------------
  def conditions_met?
    class_name = SceneManager.scene.class.name.to_sym
    return false unless scene_whitelist.empty? || scene_whitelist.include?(class_name)
    return false if scene_blacklist.include?(class_name)
    return false unless $game_switches[@event.switch_id]
    return true
  end
end

#-------------------------------------------------------------------------------
# Update our global common events in every scene
#-------------------------------------------------------------------------------
class Scene_Base
    
  alias :th_global_common_events_update_basic :update_basic
  def update_basic
    th_global_common_events_update_basic
    update_global_common_events
  end
  
  #-----------------------------------------------------------------------------
  # Update global common events
  #-----------------------------------------------------------------------------
  def update_global_common_events
  end
end

#-------------------------------------------------------------------------------
# These scenes can update global common events
#-------------------------------------------------------------------------------
if TH::Global_Common_Events::Scene_Whitelist.empty?
  # every scene should check for updates
  class Scene_Base
    def update_global_common_events
      $game_global_common_events.update
    end
  end
else
  # only the selected scenes should check for updates
  TH::Global_Common_Events::Scene_Whitelist.each do |classname|
    parent = eval("#{classname}.superclass")
    eval(
      "class #{classname} < #{parent}
        def update_global_common_events
          $game_global_common_events.update
        end
      end"
    )
  end
end
#-------------------------------------------------------------------------------
# These scenes should not update global common events
#-------------------------------------------------------------------------------
TH::Global_Common_Events::Scene_Blacklist.each do |classname|
  parent = eval("#{classname}.superclass")
  eval(
  "class #{classname} < #{parent}
    def update_global_common_events
    end
  end")
end