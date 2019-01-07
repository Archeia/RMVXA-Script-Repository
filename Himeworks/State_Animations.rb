=begin
#===============================================================================
 Title: State Animations
 Author: Hime
 Date: Mar 28, 2014
--------------------------------------------------------------------------------
 ** Change log
 Mar 28, 2014
   - fixed bug where remove animation was played out during next battle
 Aug 17, 2013
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
 
 This script provides some state-related animation effects.
 You can have custom animations play before a state is added, or before
 a state is removed.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 Note-tag states with
 
   <add anim: ID>
   <remove anim: ID>
   
 Where ID is the ID of the animation that you want to play.
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_StateAnimations"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module State_Animations
    
    Add_Regex = /<add[-_ ]anim:\s*(\d+)\s*>/i
    Remove_Regex = /<remove[-_ ]anim:\s*(\d+)\s*>/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class State < BaseItem
    
    def add_state_animation_id
      load_notetag_state_animations if @add_state_animation_id.nil?
      return @add_state_animation_id
    end
    
    def remove_state_animation_id
      load_notetag_state_animations if @remove_state_animation_id.nil?
      return @remove_state_animation_id
    end
    
    def load_notetag_state_animations
      @add_state_animation_id = 0
      @remove_state_animation_id = 0
      
      res = self.note.match(TH::State_Animations::Add_Regex)
      @add_state_animation_id = res[1].to_i if res
      
      res = self.note.match(TH::State_Animations::Remove_Regex)
      @remove_state_animation_id = res[1].to_i if res
    end
  end
end

#~ class Sprite_Battler
#~   def update_animation
#~   end
#~ end

class Game_BattlerBase
  
  alias :th_state_animations_erase_state :erase_state
  def erase_state(state_id)
    play_remove_state_animation(state_id)
    th_state_animations_erase_state(state_id)
  end
end

class Game_Battler < Game_BattlerBase
  
  alias :th_state_animations_add_new_state :add_new_state
  def add_new_state(state_id)
    play_add_state_animation(state_id)
    th_state_animations_add_new_state(state_id)
  end
  
  def play_add_state_animation(state_id)
    @animation_id = $data_states[state_id].add_state_animation_id
    perform_scene_animation_wait
  end
  
  def play_remove_state_animation(state_id)
    @animation_id = $data_states[state_id].remove_state_animation_id
    perform_scene_animation_wait
  end
  
  #-----------------------------------------------------------------------------
  # Tell the scene to wait for an animation to play, otherwise any
  # state animations that are assigned probably won't be played
  #-----------------------------------------------------------------------------
  def perform_scene_animation_wait
    SceneManager.scene.wait_for_animation if SceneManager.scene_is?(Scene_Battle)
  end
  
  alias :th_state_animations_remove_battle_states :remove_battle_states
  def remove_battle_states
    th_state_animations_remove_battle_states
    @animation_id = 0
  end
end