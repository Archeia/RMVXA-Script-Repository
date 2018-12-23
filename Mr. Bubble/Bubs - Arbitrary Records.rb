# ╔══════════════════════════════════════════════════════╤═══════╤═══════════╗
# ║ Arbitrary Records                                    │ v1.00 │ (6/02/13) ║
# ╚══════════════════════════════════════════════════════╧═══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
#--------------------------------------------------------------------------
# This script provides the ability to store trivial information for
# other uses. For example, this saves the total amount of damage
# an actor has dealt in battle, the number of times an actor has been
# hit by a state, the number of times an actor has evaded, and so on.
#
# This script provides no visual changes. If you were told to
# install this script in your project for another script, then
# you can simply leave this script alone.
#
# Documentation is still currently under construction.
#--------------------------------------------------------------------------
#      Changelog   
#--------------------------------------------------------------------------
# v1.00 : Initial release. (6/01/2013)
#--------------------------------------------------------------------------
#      Installation & Requirements
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#      Script Calls   (UNDER CONSTRUCTION)
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#
#
#--------------------------------------------------------------------------
#      Compatibility   
#--------------------------------------------------------------------------
# This script aliases the following default VXA methods:
#
#      BattleManager#battle_end
#      Game_System#initialize
#      Game_Battler#initialize
#      Game_Battler#item_apply
#
# There are no default method overwrites.
#--------------------------------------------------------------------------
#      Terms and Conditions   
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. 
# Free for non-commercial use. For commercial use, contact me first.
#
# Newest versions of this script can be found at 
#                                           http://mrbubblewand.wordpress.com/
#=============================================================================

$imported ||= {}
$imported["BubsArbitraryRecords"] = 1.00

#==========================================================================
# ++ This script contains no customization module. ++
#==========================================================================

#==============================================================================
# ** BattleManager
#==============================================================================
module BattleManager
  #--------------------------------------------------------------------------
  # alias : battle_end
  #     result : Result (0: Win 1: Escape 2: Lose)
  #--------------------------------------------------------------------------
  class << self; alias battle_end_bubs_arb_records battle_end; end
  def self.battle_end(result)
    case result
    when 0 # win
      $game_party.members.each do |member| 
        member.records.total_battles_won += 1
      end
      $game_system.victory_count += 1
    when 1 # escape
      $game_party.members.each do |member| 
        member.records.total_battles_escaped += 1
      end
      $game_system.escape_count += 1
    when 2 # lose
      $game_party.members.each do |member| 
        member.records.total_battles_lost += 1
      end
      $game_system.lose_count += 1
    end
    battle_end_bubs_arb_records(result)
  end
  
end



#==============================================================================
# ** Game_System
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :victory_count
  attr_accessor :escape_count
  attr_accessor :lose_count
  
  attr_accessor :gold_gain_count
  attr_accessor :gold_lost_count
  
  attr_accessor :highest_gold_achieved
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  alias initialize_bubs_arb_records initialize
  def initialize
    initialize_bubs_arb_records # alias

    reset_arbitrary_records
  end
  #--------------------------------------------------------------------------
  # reset_arbitrary_records
  #--------------------------------------------------------------------------
  def reset_arbitrary_records
    @victory_count = 0
    @escape_count = 0
    @lose_count = 0
    
    @total_gold_gain = 0
    @total_gold_loss = 0
    
    @highest_gold_achieved = 0
  end

  
end



#==============================================================================
# ** ArbitraryRecords
#==============================================================================
class ArbitraryRecords
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :skill_use_count
  attr_accessor :item_use_count
  attr_accessor :element_hurt_count
  
  attr_accessor :enemy_kill_count
  
  attr_accessor :added_state_count
  attr_accessor :removed_state_count
  
  attr_accessor :total_battles_won
  attr_accessor :total_battles_lost
  attr_accessor :total_battles_escaped
  
  attr_accessor :total_hp_damage_taken
  attr_accessor :total_hp_damage_dealt
  
  attr_accessor :total_mp_damage_taken
  attr_accessor :total_mp_damage_dealt
  
  attr_accessor :total_hp_healing_taken
  attr_accessor :total_hp_healing_dealt
  
  attr_accessor :total_hp_drained
  attr_accessor :total_mp_drained
  
  attr_accessor :total_hit_count
  attr_accessor :total_miss_count
  attr_accessor :total_critical_count
  attr_accessor :total_evade_count
  
  attr_accessor :highest_hp_damage_taken
  attr_accessor :highest_hp_damage_dealt
  attr_accessor :highest_hp_healing_taken
  attr_accessor :highest_hp_healing_dealt
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(battler)
    @battler = battler
    
    @skill_use_count = Array.new($data_skills.size, 0)
    @item_use_count  = Array.new($data_items.size, 0)
    @element_hurt_count = Array.new($data_system.elements.size, 0)
    
    @enemy_kill_count = Array.new($data_enemies.size, 0)
    
    @added_state_count = Array.new($data_states.size, 0)
    @removed_state_count = Array.new($data_states.size, 0)
    
    @total_battles_won = 0
    @total_battles_lost = 0
    @total_battles_escaped = 0
    
    @total_hp_damage_taken = 0
    @total_hp_damage_dealt = 0
    
    @total_mp_damage_taken = 0
    @total_mp_damage_dealt = 0
    
    @total_hp_healing_taken = 0
    @total_hp_healing_dealt = 0
    
    @total_hp_drained = 0
    @total_mp_drained = 0
    
    @total_hit_count = 0
    @total_miss_count = 0
    @total_critical_count = 0
    @total_evade_count = 0
    
    @highest_hp_damage_taken = 0
    @highest_hp_damage_dealt = 0
    @highest_hp_healing_taken = 0
    @highest_hp_healing_dealt = 0

  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update(user, item, result)
    @total_evade_count += 1 if result.evaded
    
    @total_hp_damage_taken += result.hp_damage if result.hp_damage > 0
    @total_mp_damage_taken += result.mp_damage if result.mp_damage > 0
    
    @total_hp_healing_taken += result.hp_damage if result.hp_damage < 0
    @total_mp_healing_taken += result.mp_damage if result.mp_damage < 0
    
    if result.hp_damage > 0 && result.hp_damage > @highest_hp_damage_taken
      @highest_hp_damage_taken = result.hp_damage 
    end
    
    if result.hp_damage < 0 && (-result.hp_damage) > @highest_hp_healing_taken
      @highest_hp_healing_taken = (-result.hp_damage) 
    end
    
    if item.damage.element_id >= 0
      @element_hurt_count[item.damage.element_id] += 1 
    end

    update_state_records(user, item, result)
    update_user_records(user, item, result)
  end
  
  #--------------------------------------------------------------------------
  # update_state_records
  #--------------------------------------------------------------------------
  def update_state_records(user, item, result)
    for state_id in result.added_states
      @added_state_count[state_id] += 1
    end

    for state_id in result.removed_states
      @removed_state_count[state_id] += 1
    end
  end
  
  #--------------------------------------------------------------------------
  # update_user_records
  #--------------------------------------------------------------------------
  # Update records of the user
  def update_user_records(user, item, result)
    user.records.total_hit_count += 1 if result.hit?
    user.records.total_miss_count += 1 if !result.hit?
    
    user.records.total_critical_count += 1 if result.critical
    
    user.records.skill_use_count[item.id] += 1 if item.is_a?(RPG::Skill)
    user.records.item_use_count[item.id]  += 1 if item.is_a?(RPG::Item)
  
    user.records.total_hp_damage_dealt += result.hp_damage if result.hp_damage > 0
    user.records.total_mp_damage_dealt += result.mp_damage if result.mp_damage > 0
    
    user.records.total_hp_healing_dealt += result.hp_damage if result.hp_damage < 0
    user.records.total_mp_healing_dealt += result.mp_damage if result.mp_damage < 0
    
    user.records.total_hp_drained += result.hp_drain
    user.records.total_mp_drained += result.mp_drain
    
    if result.hp_damage > 0 && result.hp_damage > user.records.highest_hp_damage_dealt
      user.records.highest_hp_damage_dealt = result.hp_damage 
    end
    
    if result.hp_damage < 0 && (-result.hp_damage) > user.records.highest_hp_healing_dealt
      user.records.highest_hp_healing_dealt = (-result.hp_damage) 
    end
    
    if user.actor? && @battler.enemy? && result.added_states.include?(1)
      user.records.enemy_kill_count[@battler.enemy.id] += 1
    end
  end
  #--------------------------------------------------------------------------
  # update_battle_records
  #--------------------------------------------------------------------------
  def update_battle_records(symbol = :none)
    case symbol
    when :win
      @total_battles_won += 1
    when :lose
      @total_battles_lost += 1
    when :escape
      @total_battles_escaped += 1
    end
  end

end # class ArbitraryRecords



#==============================================================================
# ** Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :records
  #--------------------------------------------------------------------------
  # 
  #--------------------------------------------------------------------------
  alias initialize_bubs_arb_records initialize
  def initialize #(actor_id)
    initialize_bubs_arb_records #(actor_id) # alias
    
    @records = ArbitraryRecords.new(self)
  end
  #--------------------------------------------------------------------------
  # 
  #--------------------------------------------------------------------------
  alias item_apply_bubs_arb_records item_apply
  def item_apply(user, item)
    item_apply_bubs_arb_records(user, item) # alias

    update_records(user, item, @result)
  end
  #--------------------------------------------------------------------------
  # 
  #--------------------------------------------------------------------------
  def update_records(user, item, result)
    @records.update(user, item, result)
  end
  
end # class Game_Battler < Game_BattlerBase



