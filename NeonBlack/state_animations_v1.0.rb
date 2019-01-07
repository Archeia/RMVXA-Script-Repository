##-----------------------------------------------------------------------------
## Animated States v1.0
## Created by Neon Black
##
## For both commercial and non-commercial use as long as credit is given to
## Neon Black and any additional authors.  Licensed under Creative Commons
## CC BY 3.0 - http://creativecommons.org/licenses/by/3.0/.
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v1.0 - 8.18.2013
##  Wrote and debugged main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported ||= {}                                                              ##
$imported["Anim_States"] = 1.0                                                ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the script editor below "Materials" and above "Main".
## This allows tagged states to display battle animations on battlers with the
## state applied.  The animation will loop for as long as the state is applied
## and will stop once the state is removed.  The animation will stop while
## another animation is being played unless certain other scripts are used.
##
## state anim id[5]  -etc-
##  - This tag goes into the state's notebox.  As long as the state is applied
##    the animation will play on the battler applied with the state.
##----------------------------------------------------------------------------##
                                                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------


class Game_Battler < Game_BattlerBase
  def state_animation  ## A collection of the state animations.
    icons = states.collect {|state| state.animation_index }
    icons.delete(0)
    icons[0]
  end
end

## To prevent an error that would prevent combat from continuing while state
## animations played, this method checks if animations are playing MINUS
## animations related to states.
class Sprite_Battler < Sprite_Base
  def animation_minus_state?
    if ($imported["CP_BATTLEVIEW_2"] || 0) >= 1.3
      return @ani_array.size > 1 || (@ani_array.size == 1 &&
             @ani_array[0].animation.id != @battler.state_animation)
    else
      return @animation && @animation.id != @battler.state_animation
    end
  end
  
  ## Starts state animations playing again.
  alias :cp_animation_states_setup :setup_new_animation
  def setup_new_animation
    cp_animation_states_setup
    unless check_using_animation
      animation = $data_animations[@battler.state_animation]
      start_animation(animation)
      update_animation
    end
  end
  
  def check_using_animation
    return true if @battler.state_animation.nil? || !self.visible
    return true unless @battler.use_sprite?
    if ($imported["CP_BATTLEVIEW_2"] || 0) >= 1.3
      return @ani_array.any? { |ani| ani.animation.id == @battler.state_animation }
    else
      return animation?
    end
  end
end

class Spriteset_Battle
  def animation?
    battler_sprites.any? {|sprite| sprite.animation_minus_state? }
  end
end

class RPG::State < RPG::BaseItem
  def animation_index
    @animation_index || make_animation_state
  end
  
  def make_animation_state
    note.split(/[\r\n]+/).each do |line|
      @animation_index = 0
      case line
      when /state anim id\[(\d+)\]/i
        @animation_index = $1.to_i
      end
    end
    return @animation_index
  end
end


##-----------------------------------------------------------------------------
## End of script.
##-----------------------------------------------------------------------------