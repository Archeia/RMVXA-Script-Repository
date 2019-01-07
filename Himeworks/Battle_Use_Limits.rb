=begin
#===============================================================================
 Title: Battle Use Limits
 Author: Hime
 Date: May 6, 2015
--------------------------------------------------------------------------------
 ** Change log
 May 6, 2015
   - improved error-checking to avoid cases where commands are still being
     accepted after the input phase
 Jun 30, 2013
   - bug fix: crashes when nil item selected
 Jun 12, 2013
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
 
 This script allows you to limit the number of times a skill or item can
 be used in a single battle. The use counts are reset at the end of each battle.
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage

 Note-tag items or skills with

   <battle use limit: x>
   
 For some integer x. Once you've used a skill or item that many times in a
 single battle you can't use it again until the next battle.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_BattleUseLimits"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Battle_Use_Limits
    
    Regex = /<battle[-_ ]use[-_ ]limit:\s*(\d+)>/i
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class UsableItem < BaseItem
    def battle_use_limit
      return @battle_use_limit unless @battle_use_limit.nil?
      load_notetag_battle_use_limit
      return @battle_use_limit
    end
    
    def load_notetag_battle_use_limit
      res = self.note.match(TH::Battle_Use_Limits::Regex)
      @battle_use_limit = res ? res[1].to_i : 999999999 # you'll never reach it
    end
  end
end

class Game_BattlerBase
  
  #-----------------------------------------------------------------------------
  # New. Returns true if skill use limit has exceeded
  #-----------------------------------------------------------------------------
  def battle_skill_use_exceeded?(skill)
    @skill_use_counts[skill.id] >= skill.battle_use_limit
  end
  
  #-----------------------------------------------------------------------------
  # New. Returns true if item use limit has exceeded
  #-----------------------------------------------------------------------------
  def battle_item_use_exceeded?(item)
    @item_use_counts[item.id] >= item.battle_use_limit
  end
  
  alias :th_battle_use_limits_skill_conditions_met? :skill_conditions_met?
  def skill_conditions_met?(skill)
    return false if battle_skill_use_exceeded?(skill)
    th_battle_use_limits_skill_conditions_met?(skill)
  end
  
  #-----------------------------------------------------------------------------
  # Can't use item if use count exceeded
  #-----------------------------------------------------------------------------
  alias :th_battle_use_limits_item_conditions_met? :item_conditions_met?
  def item_conditions_met?(item)
    return false if battle_item_use_exceeded?(item)
    th_battle_use_limits_item_conditions_met?(item)
  end
end

class Game_Battler < Game_BattlerBase
  
  alias :th_battle_use_limits_initialize :initialize
  def initialize
    th_battle_use_limits_initialize
    @skill_use_counts = {}
    @item_use_counts = {}
    clear_battle_use_counts
  end
  
  def clear_battle_use_counts
    $data_skills.size.times {|i| @skill_use_counts[i] = 0 }
    $data_items.size.times {|i| @item_use_counts[i] = 0 }
  end
  
  #-----------------------------------------------------------------------------
  # Reset use counts at the start of the battle
  #-----------------------------------------------------------------------------
  alias :th_battle_use_limits_on_battle_start :on_battle_start
  def on_battle_start
    th_battle_use_limits_on_battle_start
    clear_battle_use_counts
  end
  
  alias :th_battle_use_limits_on_battle_end :on_battle_end
  def on_battle_end
    th_battle_use_limits_on_battle_end
    clear_battle_use_counts
  end
  
  #-----------------------------------------------------------------------------
  # Add one to the use count
  #-----------------------------------------------------------------------------
  alias :th_battle_use_limits_use_item :use_item
  def use_item(item)
    if item.is_a?(RPG::Skill)
      @skill_use_counts[item.id] += 1
    elsif item.is_a?(RPG::Item)
      @item_use_counts[item.id] += 1
    end
    th_battle_use_limits_use_item(item)
  end
end

#-------------------------------------------------------------------------------
# Properly disables item if current actor can't use it...but item is still
# hidden if no one can use it
#-------------------------------------------------------------------------------
class Window_BattleItem < Window_ItemList
  
  alias :th_battle_use_limits_enable? :enable?
  def enable?(item)
    return false if item && BattleManager.actor != nil && BattleManager.actor.battle_item_use_exceeded?(item)
    th_battle_use_limits_enable?(item)
  end
end