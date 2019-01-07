=begin
#===============================================================================
 Title: Cover Targets
 Author: Hime
 Date: Dec 20, 2013
 URL: http://himeworks.com/2013/11/21/cover-targets/
--------------------------------------------------------------------------------
 ** Change log
 Dec 20, 2013
   - fixed bug where a user dies, but still covers its targets after it revives
 Nov 21, 2013
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
 
 This script provides a "cover target" effect for your states. When an actor
 uses a skill that adds a state with a special "cover target effect" to the
 target, the user will receive the state instead.
 
 A single battler can cover multiple targets at a time, and can cover both
 actors and enemies at the same time. For example, if you have a scope that
 allows you to target all battlers, then your battler can cover for everyone.

 While this state is active, the user will cover the target if the cover
 conditions are met. By default, this means that the target has less than
 25% of their max HP.
 
 When the state is removed, the targets will no longer be covered.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 To give a state the "cover target" effect, note-tag the state with
 
   <cover target>
   
 A single state can cover multiple targets, and you can have multiple
 states with the "cover target" effect to protect different battlers.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CoverTargets"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Cover_Targets
    Regex = /<cover[-_ ]target>/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class State < BaseItem
    
    def cover_target_effect?
      load_notetag_cover_target unless @cover_target_effect
      return @cover_target_effect
    end
    
    def load_notetag_cover_target
      @cover_target_effect = (self.note =~ TH::Cover_Targets::Regex)
    end
  end
end

class Game_BattlerBase
  
  attr_reader :cover_targets
  
  alias :th_cover_targets_initialize :initialize
  def initialize
    th_cover_targets_initialize
    clear_cover_targets
  end
  
  def clear_cover_targets
    @cover_targets = {}
  end
  
  def covers?(target)
    @cover_targets.values.any? {|arr| arr.include?(target) }
  end
end

class Game_Battler < Game_BattlerBase
  
  alias :th_cover_targets_remove_state :remove_state
  def remove_state(state_id)
    th_cover_targets_remove_state(state_id)
    @cover_targets.delete(state_id)
  end
  
  def add_cover_target_state(target, state_id)
    add_state(state_id)
    @cover_targets[state_id] ||= []
    @cover_targets[state_id] << target
  end
  
  alias :th_cover_targets_item_effect_add_state_normal :item_effect_add_state_normal
  def item_effect_add_state_normal(user, item, effect)
    if $data_states[effect.data_id].cover_target_effect?
      chance = effect.value1
      chance *= state_rate(effect.data_id) if opposite?(user)
      chance *= luk_effect_rate(user)      if opposite?(user)
      if rand < chance
        user.add_cover_target_state(self, effect.data_id)
        @result.success = true
      end
    else
      th_cover_targets_item_effect_add_state_normal(user, item, effect)
    end
  end
  
  alias :th_cover_targets_die :die
  def die
    th_cover_targets_die
    @cover_targets.clear
  end
end

class Game_Unit
  
  def cover_target_substitute(target)
    members.find {|mem| mem.covers?(target) }
  end
end

class Scene_Battle < Scene_Base
  
  def get_cover_target_substitute(target)
    all_battle_members.find {|battler| battler.covers?(target)}
  end
  
  alias :th_cover_target_apply_substitute :apply_substitute
  def apply_substitute(target, item)
    if check_substitute(target, item)
      substitute = get_cover_target_substitute(target)
      if substitute && target != substitute
        @log_window.display_substitute(substitute, target)
        return substitute
      end
    end
    th_cover_target_apply_substitute(target, item)
  end
end