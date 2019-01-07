=begin
#===============================================================================
 Title: Scene Event Animations
 Author: Hime
 Date: Mar 31, 2015
--------------------------------------------------------------------------------
 ** Change log
 Mar 31, 2015
   - fixed bug where game crashes while trying to update weather
 Nov 19, 2014
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to HimeWorks in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script is an add-on for the Scene Interpreter. It allows you to display
 various screen effects such as
 
 - pictures
 - weather
 - tone change
 - screen flash
 - fade in, fade out
 
 This allows you to display animations in your scenes using basic eventing.
 If you can call a common event, you can take advantage of the event system.
 
 It does not support character-based animations, however, since there are no
 characters outside of the map. 
 
--------------------------------------------------------------------------------
 ** Required
 
 Scene Interpreter
 - http://www.himeworks.com/2013/03/scene-interpreter/
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this below Scene Interpreter and above Main. 

--------------------------------------------------------------------------------
 ** Usage 
 
 See the instructions for Scene Interpreter for running events in scenes other
 than the map.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_SceneEventAnimations] = true
#===============================================================================
# ** Rest of Script
#===============================================================================
module SceneManager
  
  class << self
    alias :th_scene_event_animations_init_interpreter :init_interpreter
  end
  
  def self.init_interpreter
    th_scene_event_animations_init_interpreter
    @screen = Game_Screen.new
    @spriteset = Spriteset_Scene.new
  end
  
  def self.screen
    @screen
  end
  
  def self.spriteset
    @spriteset
  end
end

#-------------------------------------------------------------------------------
# Scene spriteset for displaying pictures and tone changes
#-------------------------------------------------------------------------------
class Spriteset_Scene
  def initialize
    create_sprites
    update
  end
  
  def create_sprites
    create_viewports
    create_weather
    create_pictures
  end
  
  def create_pictures
    @picture_sprites = []
  end
  
  def create_weather
    @weather = Spriteset_Weather.new(@viewport2)
  end
  
  def create_viewports
    @viewport2 = Viewport.new
    @viewport3 = Viewport.new
    
    @viewport2.z = 250
    @viewport3.z = 300
  end

  def dispose
    @disposed = true
    dispose_weather
    dispose_pictures
    dispose_viewports
  end
  
  def dispose_weather
    @weather.dispose
  end
  
  def dispose_pictures
    @picture_sprites.compact.each {|sprite| sprite.dispose }
  end
  
  def dispose_viewports
    @viewport2.dispose
    @viewport3.dispose
  end
  
  def update
    update_weather
    update_pictures
    update_viewports
  end
  
  def update_pictures
    SceneManager.screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport2, pic)
      @picture_sprites[pic.number].update
    end
  end
  
  def update_weather
    return unless $game_map
    @weather.type = SceneManager.screen.weather_type
    @weather.power = SceneManager.screen.weather_power
    @weather.ox = $game_map.display_x * 32
    @weather.oy = $game_map.display_y * 32
    @weather.update
  end
  
  def update_viewports
    @viewport2.tone.set(SceneManager.screen.tone)
    @viewport3.color.set(SceneManager.screen.flash_color)
    @viewport3.color.set(0, 0, 0, 255 - SceneManager.screen.brightness)
    @viewport2.update
    @viewport3.update
  end
end

class Scene_Base
  
  alias :th_scene_event_animations_update :update
  def update
    th_scene_event_animations_update
    SceneManager.spriteset.update
    SceneManager.screen.update
  end
end

class Game_SceneInterpreter
  
  #----------------------------------------------------------------------------=
  # Return the scene manager's screen for any other scene
  #----------------------------------------------------------------------------=
  def screen
    scr = super
    if scr == $game_map.screen && !SceneManager.scene_is?(Scene_Map)
      return SceneManager.screen
    else
      return scr
    end
  end
end