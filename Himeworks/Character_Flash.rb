=begin
#===============================================================================
 Title: Character Flash
 Author: Hime
 Date: Sep 13, 2013
--------------------------------------------------------------------------------
 ** Change log
 Sep 13, 2013
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
 
 This script allows you to have characters on your map start flashing.
 You can choose how long the flash should be and the color of the flash.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main.
 
--------------------------------------------------------------------------------
 ** Usage
 
 To make a character flash, make the script call
 
   character_flash(id, duration)
   character_flash(id, duration, loopCount)
   character_flash(id, duration, loopCount, color)
   
 Where ID is
   -1 for the player
   0 for the current event
   1 or higher is the specified event ID
   
 The duration is the number of frames that you want it to flash.
 
 LoopCount is a number that specifies how many times it should loop.
 By default, it only loops once (1), but you can have it loop infinitely by
 passing in 0.
 
 If the flash is supposed to loop, you will need to manually turn off the 
 flashing by making the script call
 
   end_character_flash(id)
 
 The color of the flash is a Color object.
 If the color is not specified, it defaults to the color that is specified
 in the configuration.
 
 
 
--------------------------------------------------------------------------------
 ** Example
 
  To have event 3 flash red (RGB value 255,0,0), for 60 frames, make the
  script call
  
    color = Color.new(255, 0, 0)
    character_flash(3, 60, 0, color)
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CharacterFlash"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Character_Flash
    
    # The default flash color if you don't specify one. Takes an RGBA value.
    Default_Color = Color.new(255, 255, 255, 255)
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_Interpreter
  
  def character_flash(id, duration, loop=1, color=TH::Character_Flash::Default_Color)
    get_character(id).begin_flash(duration, loop, color)
  end
  
  def end_character_flash(id)
    get_character(id).clear_flash_settings
  end
end

class Game_CharacterBase
  
  attr_reader :flash_on
  attr_reader :flash_duration
  attr_reader :flash_color
  attr_reader :flash_loop
  
  alias :th_character_flash_init_public_members :init_public_members
  def init_public_members
    th_character_flash_init_public_members
    clear_flash_settings
  end
  
  def clear_flash_settings
    @flash_loop = 1
    @flash_on = false
    @flash_duration = 0
    @flash_color = TH::Character_Flash::Default_Color
  end
  
  def begin_flash(duration, loop, color)
    @flash_on = true
    @flash_loop = loop
    @flash_duration = duration
    @flash_color = color
  end
  
  def end_flash
    if @flash_loop == 0
      @flash_on = false
    else
      clear_flash_settings
    end
  end
  
  alias :th_character_flash_update :update
  def update
    update_flash
    th_character_flash_update
  end
  
  def update_flash
    if @flash_loop == 0 && !@flash_on
      @flash_on = true
    end
  end
end

class Sprite_Character < Sprite_Base
  
  @@flash_color = Color.new(255, 255, 255)
  
  alias :th_character_flash_initialize :initialize
  def initialize(viewport, character = nil)
    @flash_duration = 0
    @flashing = false
    th_character_flash_initialize(viewport, character)
  end
  
  alias :th_character_flash_update :update
  def update
    th_character_flash_update
    update_flashing
  end
  
  def update_flashing
    if !@flashing
      if @character.flash_on
        @flashing = true
        color = @character.flash_color || @@flash_color
        flash(color, @character.flash_duration)
        @character.end_flash
      end
    else
      @flash_duration += 1  
      if @flash_duration >= @character.flash_duration
        @flash_duration = 0
        @flashing = false
      end
    end    
  end
end