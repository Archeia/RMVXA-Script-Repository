#  -------------------------------------------------
#  Script Name : Player Invisibility
#  Owner : efeberk
#  Date : 30.07.2013
#  Compatible : RPG Maker VX Ace(RGSS3)
#  Version : v1.0
#  ------------------------------------------------

# Functions:

# - Enable/Disable System
# - Input Function
# - Encounter Enable/Disable while player invisible
# - Duration Mode
# - Can be used with Items/Armors

# Script calls:

# EFEBERK::hidden? - returns true if player is invisible
# EFEBERK::hide - Make invisible player
# EFEBERK::visualize - Make visible player
# Note : 'visualize' method won't active when using with Armors.
# EFEBERK::duration_mode(frame)
# if frame = 0, frame will be default value which set by User below.
# if frame > 0, 60 frames = 1 second.

# Item notetag : 
# <dur: 4ever> - it means player will be invisible forever.
#   (Player can be visible back with Key func)
# <dur: 360> - it means player will be invisible for 360 frames(6 seconds)

# Important Notes : 

# - Player can't be visible back if an invisible armor be using.
# - Player can't use Key func if duration_mode be used.
# - Player can be visible back with Key function even <dur: 4ever> tag used.

module EFEBERK
  
  INVISIBILITY_SWITCH = 10 #If 0, it means this script will be active forever.
  
  INVISIBILITY_VARIABLE = false #if true, VISIBILITY LEVEL should be variable id.
  INVISIBILITY_LEVEL = 100  # This is opacity level.
                            # minimum 0 and maximum 255
  KEY_FUNC = 5 
  INVISIBILITY_KEY = :CTRL
  
  ENCOUNTER_DISABLE_SWITCH = 11 #If 0, it means it will be active forever.
  
  USE_VARIABLE = true #if false, INVISIBILITY_DURATION should be integer
                      #if true, INVISIBILITY_DURATION should be variable id
  INVISIBILITY_DURATION = 3
  
  
  ARMORS = [61,2] #Insert armor IDs if you wanna to make invisible it.
  
  def self.hidden?
    $efe
  end
  
  def self.hide
    $hide_perma = true
    $efe = true
  end
  
  def self.visualize
    if EFEBERK::check_armors == false
      $hide_perma = false
      $efe = false
      $dur_enabled = false
    end
  end
  
  def self.encounter(boo)
    if boo
      $game_system.encounter_disabled = true
      $game_player.make_encounter_count
    else
      $game_system.encounter_disabled = false
    end
  end
  
  def self.duration_mode(frames = 0)
    frames = frames.to_i
    if frames == 0
      if USE_VARIABLE
        $duration = $game_variables[INVISIBILITY_DURATION]
      else
        $duration = INVISIBILITY_DURATION
      end
    else
      $duration = frames
    end
    $dur_enabled = true
  end
  
  def self.check_armors
    for i in ARMORS
      if $game_actors[1].armor_equipped?(i)
        return true
      end
    end
    return false
  end
  
  def self.init
    $efe = false
    $active = false
    $hide_perma = false
    $duration = INVISIBILITY_DURATION
    $dur_enabled = false
    $encount_switch = ENCOUNTER_DISABLE_SWITCH
  end
  def self.update
    if INVISIBILITY_SWITCH != 0
      if $dur_enabled && $game_switches[INVISIBILITY_SWITCH]
        if $duration == 0
          $efe = false unless $hide_perma
          $dur_enabled = false
        else
          $efe = true
          $duration -= 1
        end
      elsif Input.trigger?(INVISIBILITY_KEY) && $game_switches[INVISIBILITY_SWITCH] && EFEBERK::check_armors == false
        if KEY_FUNC == 0
          if $efe then EFEBERK::visualize else EFEBERK::hide end
        elsif $game_switches[KEY_FUNC]
          if $efe then EFEBERK::visualize else EFEBERK::hide end
        end
      elsif EFEBERK::check_armors && $game_switches[INVISIBILITY_SWITCH]
        $efe = true
      elsif EFEBERK::check_armors == false && $game_switches[INVISIBILITY_SWITCH]
        $efe = false  unless $hide_perma
      end
    else
      if $dur_enabled
        if $duration == 0
          $efe = false unless $hide_perma
          $dur_enabled = false
        else
          $efe = true
          $duration -= 1
        end
      elsif Input.trigger?(INVISIBILITY_KEY)  && EFEBERK::check_armors == false
        if KEY_FUNC == 0
          if $efe then EFEBERK::visualize else EFEBERK::hide end
        elsif $game_switches[KEY_FUNC]
          if $efe then EFEBERK::visualize else EFEBERK::hide end
        end
      elsif EFEBERK::check_armors
        $efe = true
      elsif EFEBERK::check_armors == false
        $efe = false unless $hide_perma
      end
    end
  end    
end
EFEBERK::init
class Sprite_Character < Sprite_Base
  alias visibility_sprite_update update unless $@
  def update
    visibility_sprite_update
    if @character.is_a?(Game_Player)
      if $efe
        self.opacity = 150
        if $encount_switch == 0 
          EFEBERK::encounter(true) 
        else
          EFEBERK::encounter(true) if $game_switches[$encount_switch] == true
          EFEBERK::encounter(false) if $game_switches[$encount_switch] == false
        end
      else
        self.opacity = 255
        if $encount_switch == 0 
          EFEBERK::encounter(false) 
        else
          EFEBERK::encounter(false)
        end
      end
      EFEBERK::update
    end
  end
end


class RPG::Item < RPG::UsableItem  
  def vis_duration
    @note.scan(/<(?:DUR|dur):\s(\w+)>/i)
    return $1.to_s
  end
  
end

class Scene_ItemBase < Scene_MenuBase
  alias efeberk_scene_itembase_use_item use_item
  def use_item
    p "1"
    if item.vis_duration != "4ever"
      EFEBERK::duration_mode(item.vis_duration) unless item.vis_duration.empty?
    else
      EFEBERK::hide
    end
    efeberk_scene_itembase_use_item
  end
end

class Game_Actor < Game_Battler
  def armor_equipped?(id)
    armors.any? {|weapon| weapon.id == id }
  end
end