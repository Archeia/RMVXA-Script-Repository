=begin
#===============================================================================
 Title: Feature - Change Opacity
 Author: Hime
 Date: Dec 11, 2013
--------------------------------------------------------------------------------
 ** Change log
 Dec 11, 2013
   - opacity reverts to 255 if no features exist
 Nov 19, 2013
   - fixed bug where enemy turns white after disappearing
 Oct 3, 2013
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
 
 This script provides a "change opacity" feature to your feature objects.
 When the feature is applied, the opacity of a sprite is changed.
 
--------------------------------------------------------------------------------
 ** Required
 
 Feature Manager
 (http://himeworks.com/2012/10/13/feature-manager/)

--------------------------------------------------------------------------------
 ** Installation
 
 1. Open the script editor
 2. Place this script below Feature Manager and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 Note-tag feature objects with
 
   <feature: change_opacity>
     formula: YOUR_FORMULA
   </feature>
   
 where the formula evaluates to an integer.
 If the opacity is, then the sprite is invisible, while 255 is fully opaque.
 
 The following variables are available for your formula
 
     a - the current subject
   opc - the subject's current opacity
   
 Note that you cannot have spaces in your formula

--------------------------------------------------------------------------------
 ** Examples
 
 Straight numbers
 
   <feature: change_opacity>
     formula: 128
   </feature>
   
 Base it as a fraction of the subject's HP
 
   <feature: change_opacity>
     formula: a.hp / a.mhp.to_f
   </feature>
   
 Use the current opacity value
 
   <feature: change_opacity>
     formula: opc - 1
   </feature>
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_FtChangeOpacity"] = true
#===============================================================================
# ** Rest of Script
#===============================================================================
module Features
  module Change_Opacity
    FeatureManager.register(:change_opacity, 2.0)
  end
end

module RPG
  class BaseItem
    def add_feature_change_opacity(code, data_id, args)
      data_id = 0
      value = args[0]
      add_feature(code, data_id, value)
    end
    
    def add_feature_change_opacity_ext(code, data_id, args)
      data_id = 0
      value = args[:formula]
      add_feature(code, data_id, value)
    end
  end
end

class Game_Battler < Game_BattlerBase
  
  alias :ft_change_opacity_initialize :initialize
  def initialize
    ft_change_opacity_initialize
    @sprite_opacity = 255
  end
  
  def default_opacity
    255
  end
  
  def sprite_opacity
    formula = features_value_set(:change_opacity)[0]
    if formula
      @sprite_opacity = eval_sprite_opacity(formula, self, @sprite_opacity)
    else
      @sprite_opacity = default_opacity
    end
    return @sprite_opacity
  end
  
  def eval_sprite_opacity(formula, a, opc)
    eval(formula)
  end
end

class Sprite_Battler < Sprite_Base
  
  alias :ft_change_opacity_update_bitmap :update_bitmap
  def update_bitmap
    ft_change_opacity_update_bitmap
    self.opacity = @battler.sprite_opacity unless @battler.dead?
  end
end