#==============================================================================
#
# • Dhoom Regional Spells v1.0
# -- Last Updated: 2014.09.30
# -- Level: Easy
# -- Requires: None
#
#==============================================================================
 
$imported = {} if $imported.nil?
$imported["DHRegional_Spells"] = true
 
#==============================================================================
# ¥ Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2014.09.30 - Started and Finished Script.
#==============================================================================
# ¥ Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script change how spells works based on regional id.
#==============================================================================
# ▼ Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials and Required Scripts but above ▼ Main.
#
# -----------------------------------------------------------------------------
# Skill Notetags - These notetags go in the skill notebox in the database.
# -----------------------------------------------------------------------------
# <reg_type: x>
# Set skill's regional type with x. Example: <reg_type: fire>
#
# -----------------------------------------------------------------------------
# Region[Region Type] = {
#   :region_id => Region ID for this region type (Array)     
#   :weak => Region type that weaken this region type (Array)
#   :strong => Region type that strengthen this region type (Array)
#   :weak_powerrate => Multiply this spell damage with value specified 
#                      when weaken (Float)
#   :strong_powerrate => Multiply this spell damage with value specified
#                        when strengthen (Float)
#   :weak_hitrate =>  The same with :weak_powerrate but affect hit rate (Float)
#   :strong_hitrate =>  The same with :strong_powerrate but affect hit rate (Float)
#   :weak_staterate => The same with :weak_powerrate but affect state rate (Float)
#   :strong_staterate =>  The same with :strong_powerrate but affect state rate (Float)
# } <---- Don't forget to put this
#
# -----------------------------------------------------------------------------
# Script call method. For advanced users.
# -----------------------------------------------------------------------------
# BattleManager.set_region(x)
#   Set region type with x, set x to nil to set based on region id in player 
#   coordinate. Will be changed in battle transition if didnt locked.
#
# BattleManager.lock_region(true/false)
#   Lock or unlock region. If locked, region only can be changed manually.
#
# BattleManager.region_locked?
#   Return true or false.
#
# BattleManager.region
#   Return current region.
#
#==============================================================================
# ▼ Configuration
#==============================================================================


module Dhoom
  module RegionalSpells
    Region = {}   #-------- Don't delete this!
    
    Region[:fire] = {
      :region_id => [1,9],
      :weak => [:ice, :water],
      :strong => [:wood, :dessert],
      :weak_powerrate => 0.2,
      :strong_powerrate => 1.5,
      :weak_hitrate => 0.5,
      :strong_hitrate => 1.5,
      :weak_staterate => 0.5,
      :strong_staterate => 1.2,
    }
    
    Region[:ice] = {
      :region_id => [2],
      :weak => [:dessert, :wood],
      :strong => [:fire],
      :weak_powerrate => 0.2,
      :strong_powerrate => 1.5,
      :weak_hitrate => 0.5,
      :strong_hitrate => 1.5,
      :weak_staterate => 0.5,
      :strong_staterate => 1.2,
    }
  end

#==============================================================================
# End of Configuration
#==============================================================================

  module REGEXP
    module Skill
      Region_Type = /<(?:reg_type|REG_TYPE|reg type):[ ]*(\w+)>/i
    end   
  end
end

class RPG::Skill < RPG::UsableItem
 
  attr_reader :region_type
 
  def load_notetags_region_type
    self.note.split(/[\r\n]+/).each { |line|    
      case line
      when Dhoom::REGEXP::Skill::Region_Type
        @region_type = $1.to_sym        
      end
    }
  end  
end

module DataManager
 
  class <<self; alias load_database_dregional_spells load_database; end
  def self.load_database
    load_database_dregional_spells
    load_notetags_region_type
  end
 

  def self.load_notetags_region_type
    for obj in $data_skills
      next if obj.nil?
      obj.load_notetags_region_type
    end
  end 
end

module BattleManager

  def self.region
    return @region
  end
  
  def self.set_region(region = nil)
    region = map_region if region.nil?
    @region = region
  end
  
  def self.map_region
    region_id = $game_map.region_id($game_player.x, $game_player.y)
    Dhoom::RegionalSpells::Region.each do |key, value|
      return key if value[:region_id].include?(region_id)
    end
  end
  
  def self.region_locked?
    return @lock_region
  end
  
  def self.lock_region(lock=true)
    @lock_region = lock
  end
end

class Game_Battler < Game_BattlerBase
  alias dhoom_regional_spells_gmbattler_make_damage_value make_damage_value
  def make_damage_value(user, item)
    if item.is_a?(RPG::Skill) && item.region_type && BattleManager.region
      value = item.damage.eval(user, self, $game_variables)
      value *= item_element_rate(user, item)
      value *= pdr if item.physical?
      value *= mdr if item.magical?
      value *= rec if item.damage.recover?
      region = Dhoom::RegionalSpells::Region[item.region_type]
      value *= region[:strong_powerrate] if region[:strong].include?(BattleManager.region)
      value *= region[:weak_powerrate] if region[:weak].include?(BattleManager.region)
      value = apply_critical(value) if @result.critical
      value = apply_variance(value, item.damage.variance)
      value = apply_guard(value)
      @result.make_damage(value.to_i, item)
    else
      dhoom_regional_spells_gmbattler_make_damage_value(user, item)
    end    
  end
  
  alias dhoom_regional_spells_gmbattler_item_effect_add_state_normal item_effect_add_state_normal
  def item_effect_add_state_normal(user, item, effect)
    if item.is_a?(RPG::Skill) && item.region_type && BattleManager.region
      chance = effect.value1
      region = Dhoom::RegionalSpells::Region[item.region_type]
      chance *= region[:strong_staterate] if region[:strong].include?(BattleManager.region)
      chance *= region[:weak_staterate] if region[:weak].include?(BattleManager.region)
      chance *= state_rate(effect.data_id) if opposite?(user)
      chance *= luk_effect_rate(user)      if opposite?(user)
      if rand < chance
        add_state(effect.data_id)
        @result.success = true
      end
    else
      dhoom_regional_spells_gmbattler_item_effect_add_state_normal(user, item, effect)
    end
  end
  
  alias dhoom_regional_spells_gmbattler_item_hit item_hit
  def item_hit(user, item)
    if item.is_a?(RPG::Skill) && item.region_type && BattleManager.region
      rate = item.success_rate * 0.01
      rate *= user.hit if item.physical?
      region = Dhoom::RegionalSpells::Region[item.region_type]
      rate *= region[:strong_hitrate] if region[:strong].include?(BattleManager.region)
      rate *= region[:weak_hitrate] if region[:weak].include?(BattleManager.region)
      return rate
    else
      dhoom_regional_spells_gmbattler_item_hit(user, item)
    end
  end
end

class Scene_Map < Scene_Base
  alias dhoom_regionspells_scmap_pre_battle_scene pre_battle_scene
  def pre_battle_scene
    dhoom_regionspells_scmap_pre_battle_scene
    BattleManager.set_region if !BattleManager.region_locked?
  end
end