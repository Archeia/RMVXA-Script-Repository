=begin
#===============================================================================
 Title: Full-sized Animation
 Author: Hime
 Date: Apr 19, 2013
--------------------------------------------------------------------------------
 ** Change log
 Apr 19, 2013
   - distinguished first bitmap from second bitmap
   - fixed bug with rotating animation
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
 
 This script allows you to use a full animation sheet as a sprite instead
 of the default 192x192 cells.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 In the configuration below, type in the ID's of all animations that should
 use the full-sized sheet. Then set up your animation as usual.
 
 When an animation is full-sized, the second picture will be treated as a
 full sheet, while the first picture is treated normally.
 
 Note that the editor only shows the top-left corner of the image, so you
 will need to do some trial-and-error to get it right.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_Fullsized_Animation"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Fullsized_Animation
    
    # Place list of full-sized animations here
    Animations = [24, 45, 112]

#===============================================================================
# ** Rest of Script
#===============================================================================
    def self.table
      @table
    end
    
    #---------------------------------------------------------------------------
    # Use a hash with the animation ID's as keys for fast look-up compared to
    # array search
    #---------------------------------------------------------------------------
    def self.build_table
      @table = Hash[Animations.map {|id| [id,1]}]
    end
    
    build_table
  end
end

module RPG
  class Animation
    def full_sized?
      TH::Fullsized_Animation.table.include?(@id)
    end
  end
end

class Sprite_Base < Sprite
  
  alias :th_fullsize_animation_animation_set_sprites :animation_set_sprites
  def animation_set_sprites(frame)
    th_fullsize_animation_animation_set_sprites(frame)
    if @animation.full_sized?
      @ani_sprites.each_with_index do |sprite, i|
        next unless sprite && sprite.bitmap && frame.cell_data[i, 0] && frame.cell_data[i, 0] >= 100
        sprite.src_rect.set(0, 0, sprite.bitmap.width, sprite.bitmap.height)
      end
    end
  end
end