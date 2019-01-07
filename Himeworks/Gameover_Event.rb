=begin
#===============================================================================
 Title: Gameover Events
 Author: Hime
 Date: Jun 19, 2014
--------------------------------------------------------------------------------
 ** Change log
 Jun 19, 2014
   - needs to check if a troop actually exists
 Jun 17, 2014
   - fixed bug where troop game over event wasn't running
 Dec 21, 2013
   - fixed bug where game crashes on battle test
 Oct 1, 2013
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
 
 This script allows you to replace the default gameover scene with an event.
 This gives you more control over how the gameover scene should process.
 
 A gameover event is a common event and is assigned to different objects.
 There are several different scopes of gameover events.
 
 1. Troop gameover events. These occur when you gameover during battle.
 
 2. Map gameover events. These occur when you gameover on the map.
 
 3. System gameover events. If this is set, then it will run instead of the
    above
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this below Materials and above Main.

--------------------------------------------------------------------------------
 ** Usage 
 
 To create a troop gameover event, create a comment of the form
 
   <gameover event: event_id>
   
 To create a map gameover event, in the map's notebox, tag it with
 
   <gameover event: event_id>
   
 To set a system gameover event, make the script call
 
   set_gameover_event(event_id)
   
 Where the `event_id` is the ID of the common event that will run as the
 gameover event. If the system event is 0, then either the troop or map
 events will run. If you want to force the default gameover screen, set
 the ID to -1
 
 Note that you need to press the C button again after the event finishes
 to go back to the title screen (if your event does not handle this)
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_GameoverEvent"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Gameover_Event
    Regex = /<gameover[-_ ]event:\s*(\d+)\s*>/i
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class Troop
    def gameover_event_id
      load_gameover_event_id unless @gameover_event_id
      return @gameover_event_id
    end
    
    def load_gameover_event_id
      @gameover_event_id = 0
      @pages.each do |page|
        page.list.each do |cmd|
          if cmd.code == 108 && cmd.parameters[0] =~ TH::Gameover_Event::Regex
            @gameover_event_id = $1.to_i
            return
          end
        end
      end
    end
  end
  
  class Map
    def gameover_event_id
      load_gameover_event_id unless @gameover_event_id
      return @gameover_event_id
    end
    
    def load_gameover_event_id
      @gameover_event_id = 0
      res = self.note.match(TH::Gameover_Event::Regex)
      if res
        @gameover_event_id = res[1].to_i
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Sprites used during the game over screen
#-------------------------------------------------------------------------------
class Spriteset_Gameover
  def initialize
    create_viewports
    create_pictures
    create_timer
    update
  end
  
  def create_viewports
    @viewport1 = Viewport.new
    @viewport2 = Viewport.new
    @viewport3 = Viewport.new
    @viewport2.z = 50
    @viewport3.z = 100
  end
  
  def create_pictures
    @picture_sprites = []
  end
  
  def create_timer
    @timer_sprite = Sprite_Timer.new(@viewport2)
  end
  
  def dispose
    dispose_pictures
    dispose_timer
    dispose_viewports
  end
  
  def dispose_pictures
    @picture_sprites.compact.each {|sprite| sprite.dispose }
  end
  
  def dispose_timer
    @timer_sprite.dispose
  end
  
  def dispose_viewports
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  
  def update    
    update_pictures
    update_timer
    update_viewports
  end
  
  def update_pictures
    SceneManager.scene.screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport2, pic)
      @picture_sprites[pic.number].update
    end
  end
  
  def update_timer
    @timer_sprite.update
  end
  
  def update_viewports
    @viewport1.tone.set(SceneManager.scene.screen.tone)
    @viewport1.ox = SceneManager.scene.screen.shake
    @viewport2.color.set(SceneManager.scene.screen.flash_color)
    @viewport3.color.set(0, 0, 0, 255 - SceneManager.scene.screen.brightness)
    @viewport1.update
    @viewport2.update
    @viewport3.update
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_System
  
  attr_accessor :gameover_event_id
  
  alias :th_gameover_event_initialize :initialize
  def initialize
    th_gameover_event_initialize
    @gameover_event_id = 0
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_Troop < Game_Unit
  
  def gameover_event_id
		return 0 unless @troop_id
    troop.gameover_event_id
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Game_Map
  
  def gameover_event_id
    @map ? @map.gameover_event_id : 0
  end
end

class Game_Interpreter
  
  alias :th_gameover_event_screen :screen
  def screen
    return SceneManager.scene.screen if SceneManager.scene_is?(Scene_Gameover)
    th_gameover_event_screen
  end
  
  def set_gameover_event(event_id)
    $game_system.gameover_event_id = event_id
  end
end

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
class Scene_Gameover < Scene_Base
  
  attr_reader :screen
  
  alias :th_gameover_event_start :start
  def start
    @gameover_event = get_gameover_event
    @interpreter = Game_Interpreter.new
    @message_window = Window_Message.new
    @screen = Game_Screen.new
    @spriteset = Spriteset_Gameover.new
    if @gameover_event
      super
      @sprite = Sprite.new
      @sprite.bitmap = Bitmap.new(1,1)
      play_gameover_event 
    else
      th_gameover_event_start
    end
  end
  
  alias :th_gameover_event_update :update
  def update
    th_gameover_event_update
    if @gameover_event
      @spriteset.update
      @screen.update
      update_interpreter
    end
  end
  
  alias :th_gameover_event_terminate :terminate
  def terminate
    @spriteset.dispose 
    th_gameover_event_terminate
  end
  
  alias :th_gameover_event_goto_title :goto_title
  def goto_title
    @gameover_event = nil
    th_gameover_event_goto_title
  end
  
  def play_gameover_event
    @interpreter.setup(@gameover_event.list)
  end  
  
  #-----------------------------------------------------------------------------
  # Get gameover event depending on how gameover was triggered
  #-----------------------------------------------------------------------------
  def get_gameover_event
    if $game_system.gameover_event_id != 0
      if $game_system.gameover_event_id < 0
        return nil
      else
        return $data_common_events[$game_system.gameover_event_id]
      end  
    elsif $game_troop && $game_troop.gameover_event_id != 0
      if $game_troop.gameover_event_id < 0
        return nil
      else
        return $data_common_events[$game_troop.gameover_event_id]
      end
    elsif $game_map.gameover_event_id != 0
      if $game_map.gameover_event_id < 0
        return nil
      else
        return $data_common_events[$game_map.gameover_event_id]
      end
    else
      return nil
    end
  end
  
  def update_interpreter
    @interpreter.update
  end
end
