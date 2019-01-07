=begin
#===============================================================================
 Title: Untargetable State
 Author: Hime
 Date: Sep 25, 2015
--------------------------------------------------------------------------------
 ** Change log
 Sep 25, 2015
   - when selecting actors, the correct actor index needs to be provided
 Oct 17, 2013
   - compatiblity patch with yanfly's Ace Battle Engine
 Jun 7, 2013
   - bug fix: game crashes when there are no valid targets
 May 29, 2013
   - fixed bug where enemies that are hidden appear in the target window
 May 25, 2013
   - added support for untargetable actors
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
 
 This script allows you to create a state that prevents you from targeting
 a battler. When the state is applied, the battler cannot be targeted or
 affected by any skills or items.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 In the configuration below, enter the ID's of all states that should have the
 untargetable property
 
--------------------------------------------------------------------------------
 ** Compatibility
 
 This script overwrites the following
 
   Window_BattleEnemy
     item_max
     enemy
     draw_item
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_UntargetableState"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Untargetable_State
    
    # List of state ID's that will have untargetable effect
    States = [25]
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
class Game_Action
  
  alias :th_untargetable_state_make_targets :make_targets
  def make_targets
    th_untargetable_state_make_targets.select {|target| target && target.can_target? }
  end
end

class Game_Battler < Game_BattlerBase
  def can_target?
    return false if untargetable_state?
		return false unless exist?
    return true
  end
  
  #-----------------------------------------------------------------------------
  # Check if untargetable state is applied
  #-----------------------------------------------------------------------------
  def untargetable_state?
    !(@states & TH::Untargetable_State::States).empty?
  end
end

class Game_Enemy < Game_Battler
  
  #-----------------------------------------------------------------------------
  # Lots of hardcoded conditions based on default scripts
  #-----------------------------------------------------------------------------
  alias :th_untargetable_state_can_target? :can_target?
  def can_target?
    return false if dead?
    th_untargetable_state_can_target?
  end
end

class Game_Unit
  
  #-----------------------------------------------------------------------------
  # New. Return an array of battlers that can be targeted
  #-----------------------------------------------------------------------------
  def targetable_members
    members.select {|member| member.can_target? }
  end
end

#-------------------------------------------------------------------------------
# Updated to only draw enemies that can be selected.
# Basically replaces everything
#-------------------------------------------------------------------------------
class Window_BattleEnemy < Window_Selectable
  def item_max
    $game_troop.targetable_members.size
  end
  
  def enemy
    $game_troop.targetable_members[@index]
  end
  
  def draw_item(index)
    change_color(normal_color)
    name = $game_troop.targetable_members[index].name
    draw_text(item_rect_for_text(index), name)
  end
  
  alias :th_untargetable_state_current_item_enabled? :current_item_enabled?
  def current_item_enabled?
    return false if $game_troop.targetable_members[@index].nil?
    th_untargetable_state_current_item_enabled?
  end
end

#-------------------------------------------------------------------------------
# Updated to only draw actors that can be selected.
# Basically replaces everything
#-------------------------------------------------------------------------------
class Window_BattleActor < Window_BattleStatus
  
  def actor_index
    $game_party.targetable_members[@index].name
  end
  
  def item_max
    $game_party.targetable_members.size
  end
  
  def draw_item(index)
    actor = $game_party.targetable_members[index]
    draw_basic_area(basic_area_rect(index), actor)
    draw_gauge_area(gauge_area_rect(index), actor)
  end
  
  alias :th_untargetable_state_current_item_enabled? :current_item_enabled?
  def current_item_enabled?
    return false if $game_party.targetable_members[index].nil?
    th_untargetable_state_current_item_enabled?
  end
end


class Scene_Battle < Scene_Base
  
  # Overwrite. Need the proper index of the selected actor.
  def on_actor_ok
    BattleManager.actor.input.target_index = @actor_window.actor_index
    @actor_window.hide
    @skill_window.hide
    @item_window.hide
    next_command
  end
end

if $imported["YEA-BattleEngine"]
  class Window_BattleActor < Window_BattleStatus
    def draw_item(index)
      return if index.nil?
      clear_item(index)
      actor = $game_party.targetable_members[index]
      rect = item_rect(index)
      return if actor.nil?
      draw_actor_face(actor, rect.x+2, rect.y+2, actor.alive?)
      draw_actor_name(actor, rect.x, rect.y, rect.width-8)
      draw_actor_action(actor, rect.x, rect.y)
      draw_actor_icons(actor, rect.x, line_height*1, rect.width)
      gx = YEA::BATTLE::BATTLESTATUS_HPGAUGE_Y_PLUS
      contents.font.size = YEA::BATTLE::BATTLESTATUS_TEXT_FONT_SIZE
      draw_actor_hp(actor, rect.x+2, line_height*2+gx, rect.width-4)
      if draw_tp?(actor) && draw_mp?(actor)
        dw = rect.width/2-2
        dw += 1 if $imported["YEA-CoreEngine"] && YEA::CORE::GAUGE_OUTLINE
        draw_actor_tp(actor, rect.x+2, line_height*3, dw)
        dw = rect.width - rect.width/2 - 2
        draw_actor_mp(actor, rect.x+rect.width/2, line_height*3, dw)
      elsif draw_tp?(actor) && !draw_mp?(actor)
        draw_actor_tp(actor, rect.x+2, line_height*3, rect.width-4)
      else
        draw_actor_mp(actor, rect.x+2, line_height*3, rect.width-4)
      end
    end
  end
end