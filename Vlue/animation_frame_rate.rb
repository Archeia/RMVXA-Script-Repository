#Animation Frame Rate v1.1
#----------#
#Features: Make animations play at a faster rate allowing smoother animations
#           and now allowing animations to play behind their targets.
#
#Usage:    Place #number in the name of any animation you want to change the
#           frame rate of (i.e. #1)
#          Place @ in the name of any animation you want to have play behind 
#           it's target.
#          Place NM in the name if FLIP_ANIMATIONS is true and you don't wish
#           an animation to be mirrored.
#        
#Customization: DEFAULT_RATE below for animations without # in their name
#               FLIP_ANIMATIONS is for Side View Battle Systems that don't
#                automatically mirror animations on enemies.
#
#Examples: Sword Slash #3
#          Aura Boost @
#          Combination! #1 @
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
class Sprite_Base
 
  #Change the default frame_rate for all animations here:
  DEFAULT_RATE = 4
  FLIP_ANIMATIONS = false
  
  alias new_asp animation_set_sprites 
 
  def set_animation_rate
    name = @animation.name
    index = name.index("#")
    index.nil? ? rate = DEFAULT_RATE : rate = name[index+1,1].to_i
    index = name.index("@")
    index.nil? ? z = 300 : z = -20
    index = name.index("NM")
    if index.nil? && FLIP_ANIMATIONS && @battler
      @ani_mirror = true if @battler.is_a?(Game_Enemy)
    end
    @ani_z = z
    @ani_rate = rate
  end
  
  def animation_set_sprites(frame)
    new_asp(frame)
    @ani_sprites.each_with_index do |sprite, i|
      next unless sprite
      sprite.z = self.z + @ani_z + i
    end
  end
  
end