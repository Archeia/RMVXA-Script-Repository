#==============================================================================
# 
# • Dhoom Petrified State v1.3a
# -- Last Updated: 2015.07.08
# -- Level: Easy
#
# Aditional Credit :
#   - joeyjoejoe (Commission requester)
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["DHPetrifiedState"] = true

#==============================================================================
# ¥ Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2015.07.08 - Fixed error when using item.
# 2015.01.14 - Change how the script works. Now it's based on skill type.
# 2015.01.14 - Fixed minor typo and actor selection.
# 2015.01.13 - Started and finished the script.
# 
#==============================================================================
# ¥ Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This will add ability to state, which is when applied to actor or enemy, the
# actor or enemy can't be selected by any attack, and immune to slip damage or 
# area skills or items. This state can be ignored with notetag in items or 
# skills.
#==============================================================================
# ▼ Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials. Remember to save.
#
# -----------------------------------------------------------------------------
# State Notetags - These notetags go in the state notebox in the database.
# -----------------------------------------------------------------------------
# <petrified: type>
# type : all - Total immunity from all skills type.
#      : skill type ID, 0 : none.
# If skill type ID is specified, only negate that skill type. 
# Skill type ID could be more than one. Item can only be negated with "all".
#
# -----------------------------------------------------------------------------
# Skill and Item Notetags - These notetags go in the item or skill notebox in 
# the database.
# -----------------------------------------------------------------------------
# <ignore petrified>
# Ignore petrified state.
#
#==============================================================================

module Dhoom
  module Petrified
    SLIP_DAMAGE_STYPE = [1]
  end
  
  module REGEXP
    module UsableItem
      IgnorePetrified = /<(?:IGNORE PETRIFIED|ignore petrified)>/i
    end
    
    module State
      Petrified = /<(?:PETRIFIED|petrified):[ ]*(.*)>/i
    end
  end
end

class RPG::UsableItem < RPG::BaseItem
  
  attr_reader :ignore_petrified
  
  def load_notetags_dhpetrified
    @ignore_petrified = false
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Dhoom::REGEXP::UsableItem::IgnorePetrified
        @ignore_petrified = true
      end
    }
  end 
end

class RPG::State < RPG::BaseItem
  
  attr_reader :petrified
  attr_reader :petrified_stype
  
  def load_notetags_dhpetrified
    @petrified = false
    @petrified_stype = []
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Dhoom::REGEXP::State::Petrified
        @petrified = true
        r = $1.split(",")
        r.each do |v|
          (v == "all" || v == "ALL") ? @petrified_stype.push(:all) : @petrified_stype.push(v.to_i)
        end
      end
    }
  end 
end

module DataManager
  
  class <<self; alias load_database_dhpetrified load_database; end
  def self.load_database
    load_database_dhpetrified
    load_notetags_dhpetrified
  end
  
  def self.load_notetags_dhpetrified
    groups = [$data_items, $data_skills, $data_states]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_dhpetrified
      end
    end
  end  
end

class Game_Battler < Game_BattlerBase
  def petrified?(stype)
    states.each do |state|
      return true if state.petrified && state.petrified_stype.include?(:all)
      return true if state.petrified && state.petrified_stype.include?(stype)
    end
    return false
  end
  
  alias dhoom_ptrfd_gmbat_max_slip_damage max_slip_damage
  def max_slip_damage
    return 0 if petrified?(:all) 
    Dhoom::Petrified::SLIP_DAMAGE_STYPE.each do |i|
      return 0 if petrified?(i)
    end
    dhoom_ptrfd_gmbat_max_slip_damage
  end
  
  def set_target_size(item)
    return opponents_unit.alive_members(false,item.ignore_petrified).size if item.for_opponent?
    return friends_unit.dead_members.size    if item.for_dead_friend?
    return friends_unit.alive_members(false,item.ignore_petrified).size   if item.for_friend?
    return 1
  end
end

class Game_Action
  def confusion_target
    type = item.is_a?(RPG::Item) ? :all : item.stype_id 
    case subject.confusion_level
    when 1
      opponents_unit.random_target(item && item.ignore_petrified, type)
    when 2
      if rand(2) == 0
        opponents_unit.random_target(item && item.ignore_petrified, type)
      else
        friends_unit.random_target(item && item.ignore_petrified, type)
      end
    else
      friends_unit.random_target(item && item.ignore_petrified, type)
    end
  end

  def targets_for_opponents
    type = item.is_a?(RPG::Item) ? :all : item.stype_id 
    if item.for_random?
      Array.new(item.number_of_targets) { opponents_unit.random_target(item && item.ignore_petrified, type) }
    elsif item.for_one?
      num = 1 + (attack? ? subject.atk_times_add.to_i : 0)
      if @target_index < 0
        [opponents_unit.random_target(item && item.ignore_petrified, type)] * num
      else
        [opponents_unit.smooth_target(@target_index, item && item.ignore_petrified, type)] * num
      end
    else
      opponents_unit.alive_members(false, item && item.ignore_petrified, type)
    end
  end

  def targets_for_friends
    type = item.is_a?(RPG::Item) ? :all : item.stype_id
    if item.for_user?
      [subject]
    elsif item.for_dead_friend?
      if item.for_one?
        [friends_unit.smooth_dead_target(@target_index)]
      else
        friends_unit.dead_members
      end
    elsif item.for_friend?
      if item.for_one?
        [friends_unit.smooth_target(@target_index, item && item.ignore_petrified, type)]
      else
        friends_unit.alive_members(false, item && item.ignore_petrified, type)
      end
    end
  end
end

class Game_Unit
  def alive_members(all = true, ignore = false, stype = 0)
    if all
      members.select {|member| member.alive?}
    else
      members.select {|member| member.alive? && (ignore == member.petrified?(stype) || ignore)}
    end
  end
  
  def random_target(ignore = false, stype = 0)
    tgr_rand = rand * tgr_sum
    alive_members.each do |member|
      tgr_rand -= member.tgr
      return member if tgr_rand < 0 && (ignore == member.petrified?(stype) || ignore)
    end
    alive_members[0] if !alive_members[0].petrified?(stype)
  end
  
  def smooth_target(index, ignore = false, stype = 0)
    member = members[index]
    target = nil
    alive_members.each do |member|
      target = member
      break if (ignore == target.petrified?(stype) || ignore)
    end
    (member && member.alive?  && (ignore == member.petrified?(stype) || ignore)) ? member : target
  end
end

class Window_BattleEnemy < Window_Selectable  
  alias dhoom_ptrfd_wndbaten_current_item_enabled? current_item_enabled?
  def current_item_enabled?
    if BattleManager.actor && BattleManager.actor.input.item
      if BattleManager.actor.input.item.is_a?(RPG::Item)
        return false if enemy.petrified?(:all) && !BattleManager.actor.input.item.ignore_petrified
      else
        return false if enemy.petrified?(BattleManager.actor.input.item.stype_id) && !BattleManager.actor.input.item.ignore_petrified
      end            
    end
    dhoom_ptrfd_wndbaten_current_item_enabled?
  end
end

class Window_BattleActor < Window_BattleStatus
  alias dhoom_ptrfd_wndbatact_current_item_enabled? current_item_enabled?
  def current_item_enabled?    
    if BattleManager.actor && BattleManager.actor.input.item
      if BattleManager.actor.input.item.is_a?(RPG::Item)        
        if $game_party.battle_members[@index].petrified?(:all) && 
           !BattleManager.actor.input.item.ignore_petrified
          return false
        end
      else
        if $game_party.battle_members[@index].petrified?(BattleManager.actor.input.item.stype_id) && 
           !BattleManager.actor.input.item.ignore_petrified
          return false
        end
      end
    end
    dhoom_ptrfd_wndbatact_current_item_enabled?
  end
end