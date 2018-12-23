#==============================================================================
# Earthbound-ish Battle Backgrounds
#------------------------------------------------------------------------------
# Version: 1.0
# Author: cozziekuns 
# Date: February 15, 2013
#==============================================================================
# Description:
#------------------------------------------------------------------------------
# This script creates sinusodial-wave like background that resembles those
# from Earthbound.
#==============================================================================
# Instructions:
#------------------------------------------------------------------------------
# Paste this script into its own slot in the Script Editor, above Main but 
# below Materials.
#
# Edit only within the Battleback_Eff hash. The syntax is:
#
# :filename => {
#   Insert methods here,
# }
#  
# Where methods include:
# 
#   :blur => true/false 
#     Blurs the initial bitmap if true.
#   :radial_blur => [angle, division]
#     Applies a radial blur to the bitmap. angle is used to specify an angle 
#     from 0 to 360. The larger the number, the greater the roundness. Division 
#     is the division number (from 2 to 100). The larger the number, the 
#     smoother it will be. This process is very time consuming.
#   :wave_amp => value
#     Height of the wave.
#   :wave_length => value
#     Length of the wave.
#   :wave_speed => value
#     Speed of the wave.
#   :zoom_x => value
#     Horizontal stretch ratio of the sprite.
#   :zoom_y => value
#     Vertical stretch ratio of the sprite.
#   :mirror => true/false
#     Flips the sprite if true.
#   :opacity => value
#     Sets the opacity of the sprite. 255 = Opaque, 0 = Fully transparent.
#   :blend_type => value
#     (0: normal, 1: addition, 2: subtraction)
#   :color => Color.new(red, blue, green)
#      Sets the colour of the sprite.
#   :tone => Tone.new(red, blue, green)
#      Sets the tone of the sprite.
#
# If you do not make a settings hash for the filename, the battleback will have the default effect.
#==============================================================================

#==============================================================================
# ** Cozziekuns
#==============================================================================

module Cozziekuns
  
  module Earthboundish
    
    Battleback_Eff ={
    
      :default => { # Do not remove this
        :blur => true,
        :wave_amp => 32,
        :wave_length => 640,
        :wave_speed => 480,
      }, # Do not remove this
      
      :Eagleland => {
        :blur => true,
        :radial_blur => [180, 2],
        :wave_amp => 96,
        :wave_length => 1280,
        :wave_speed => 640,
        :zoom_x => 1.5,
        :zoom_y => 1.5,
      },
      
      :Fourside => {
        :blur => true,
        :radial_blur => [60, 10],
        :wave_amp => 96,
        :wave_length => 960,
        :wave_speed => 640,
        :zoom_x => 1.5,
        :zoom_y => 1.5,
      },

    }
    
  end
  
end

include Cozziekuns

#==============================================================================
# ** Spriteset_Battle
#==============================================================================

class Spriteset_Battle
  
  [1, 2].each { |val|
    alias_method("coz_ebishbs_sctbl_create_battleback#{val}".to_sym, "create_battleback#{val}".to_sym)
    define_method("create_battleback#{val}") {
      send("coz_ebishbs_sctbl_create_battleback#{val}".to_sym)
      bb_name = self.send("battleback#{val}_name")
      if bb_name
        if Earthboundish::Battleback_Eff.keys.include?(bb_name.to_sym)
          values = Earthboundish::Battleback_Eff[bb_name.to_sym]
        else
          values = Earthboundish::Battleback_Eff[:default]
        end
        str = "@back#{val}_sprite"
        instance_variable_get(str).bitmap.blur if values[:blur]
        instance_variable_get(str).bitmap.radial_blur(*values[:radial_blur]) if values[:radial_blur]
        (values.keys - [:blur, :radial_blur]).each { |method|
          instance_variable_get(str).send("#{method}=".to_sym, values[method])
        }
      end
    }
  }
  
end