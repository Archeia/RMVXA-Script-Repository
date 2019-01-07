=begin
#===============================================================================
 Title: Transparent Sprites
 Author: Hime
 Date: Sep 7, 2013
--------------------------------------------------------------------------------
 ** Change log
 Sep 7, 2013
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
 
 This script allows you to adjust the opacity of character sprites such as
 events or the player.
 
--------------------------------------------------------------------------------
 ** Required
 
 HimeBitmap.dll
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this below Materials and above Main.
 Place the DLL in your System folder

--------------------------------------------------------------------------------
 ** Usage
 
 To change the opacity of a character, use the script call
 
   set_opacity(character_id, opacity)
   
 If the character_id is 0, then the current event's opacity is changed.
 If the character_id is -1, then the player's character is changed, along with
 all followers.
 
 Any other number will be the event corresponding to that ID.
 
 For the opacity value, 0 is completely transparent, 255 is opaque, while
 anything in between is just partially transparent.
--------------------------------------------------------------------------------
 ** Example
 
 To set the player's opacity to 128 (half transparent), use
 
   set_opacity(-1, 128)
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_TransparentSprites"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Transparent_Sprites
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_Character < Game_CharacterBase
  
  attr_reader :opacity
  
  alias :th_transparent_sprites_init_public_members :init_public_members
  def init_public_members
    th_transparent_sprites_init_public_members
    @opacity = 255
  end
  
  #-----------------------------------------------------------------------------
  # 0 alpha causes problems with pixels that are supposed to be transparent so
  # I just set it to 1
  #-----------------------------------------------------------------------------
  def set_opacity(opc)
    opc = 1 if opc <= 0
    opc = 255 if opc > 255
    @opacity = opc
  end
end

class Sprite_Character < Sprite_Base
  
  @@fnSetOpacity = Win32API.new("System/HimeBitmap.dll", "setOpacity", ["L", "L"], "")
  
  alias :th_transparent_sprites_initialize :initialize
  def initialize(viewport, character = nil)
    @opacity = 255
    th_transparent_sprites_initialize(viewport, character)
  end
  
  alias :th_transparent_sprites_update :update
  def update
    th_transparent_sprites_update
    update_opacity
  end
  
  #-----------------------------------------------------------------------------
  # Update if required
  #-----------------------------------------------------------------------------
  def update_opacity
    if @character.opacity != @opacity
      @opacity = @character.opacity
      @@fnSetOpacity.call(bitmap.__id__, @opacity)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Need to make a copy of it otherwise we modify all characters using this
  # sheet
  #-----------------------------------------------------------------------------
  alias :th_transparent_sprites_set_character_bitmap :set_character_bitmap
  def set_character_bitmap
    th_transparent_sprites_set_character_bitmap
    bmp = Cache.character(@character_name)
    self.bitmap.blt(0, 0, bmp, bmp.rect)
  end
end

class Game_Interpreter
  
  #-----------------------------------------------------------------------------
  # Sets the opacity of the specified character
  #-----------------------------------------------------------------------------
  def set_opacity(event_id, opacity)
    get_character(event_id).set_opacity(opacity)
  end
end