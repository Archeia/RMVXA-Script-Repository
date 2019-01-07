=begin
#===============================================================================
 Title: Common Event Variables
 Author: Hime
 Date: Apr 8, 2014
--------------------------------------------------------------------------------
 ** Change log
 Apr 8, 2014
   - prevent game interpreter from clearing out variables
 Dec 3, 2013
   - added common event objects to Game_Temp
 Apr 24, 2013
   - initial release
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
 
 This script automatically updates a set of "common event variables" throughout
 the game. The purpose is to make it easier for developers to design events
 that rely on information such as who used a skill.
 
 The main purpose of this script is to provide a way to specify common event
 arguments. These arguments are stored in game variables, which makes it easy
 to use for the event editor and some script calls when necessary.
 
 The variables will be updated automatically whenever a skill or item is used,
 on the map or in a battle.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 The following objects are automatically set when a common event is used
 
   $game_temp.common_event_user
   $game_temp.common_event_target
   $game_temp.common_event_item
   $game_temp.common_event_skill
   
 You can access them in your script calls as required.
 
 -- Variable Designation --
 
 You can store the ID's of the common event objects in game variables if you
 prefer to work with the event editor.
 
 In the configuration, set the ID of the game variables to store the common
 event variables. The game automatically tracks the following data upon item
 or skill use:

   -the user (actor or enemy ID)
   -the target (actor or enemy ID)
   -the skill (skill ID)
   -the item (item ID)
   
 Note that the skill and item are stored in separate variables.
 You can reference these variables in your events or script calls.
 
 For common event effects, only the first common event will have this
 information available. The data is lost after the first common event
 finishes running. I have not figured out when is a good time to clear out
 temporary data.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CommonEventVariables"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Common_Event_Variables
    
    User_Variable   = 10   # Stores the user of an action
    Target_Variable = 11   # Stores the current target of an action 
    Skill_Variable  = 12   # stores the used skill
    Item_Variable   = 13   # Stores the used item
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_Temp
  
  attr_reader :common_event_user
  attr_reader :common_event_target
  attr_reader :common_event_item
  attr_reader :common_event_skill
  
  #-----------------------------------------------------------------------------
  # Clear all common event arguments
  #-----------------------------------------------------------------------------
  def clear_common_event_variables
    $game_variables[TH::Common_Event_Variables::User_Variable] = 0
    $game_variables[TH::Common_Event_Variables::Target_Variable] = 0
    $game_variables[TH::Common_Event_Variables::Item_Variable] = 0
    $game_variables[TH::Common_Event_Variables::Skill_Variable] = 0
    @common_event_user = nil
    @common_event_target = nil
    @common_event_item = nil
    @common_event_skill = nil
  end
  
    def set_user_common_event_variable(user)
    id = TH::Common_Event_Variables::User_Variable
    @common_event_user = user
    if user.actor?
      $game_variables[id] = user.instance_variable_get(:@actor_id)
    else
      $game_variables[id] = user.index
    end
  end
  
  def set_target_common_event_variable(target)
    id = TH::Common_Event_Variables::Target_Variable
    @common_event_target = target
    if target.actor?
      $game_variables[id] = target.instance_variable_get(:@actor_id)
    else
      $game_variables[id] = target.index
    end
  end
  
  def set_item_common_event_variable(item)
    if item.is_a?(RPG::Item)
      @common_event_item = item
      $game_variables[TH::Common_Event_Variables::Item_Variable] = item.id
    elsif item.is_a?(RPG::Skill)
      @common_event_skill = item
      $game_variables[TH::Common_Event_Variables::Skill_Variable] = item.id
    end
  end
end

class Game_Battler < Game_BattlerBase
  
  #-----------------------------------------------------------------------------
  # Set user, target, and skill/item used.
  #-----------------------------------------------------------------------------
  alias :th_common_event_variables_item_apply :item_apply
  def item_apply(user, item)
    $game_temp.set_user_common_event_variable(user)
    $game_temp.set_target_common_event_variable(self)
    $game_temp.set_item_common_event_variable(item)
    th_common_event_variables_item_apply(user, item)
    $game_temp.clear_common_event_variables unless $game_temp.common_event_reserved?
  end
  
  alias :th_common_event_variables_use_item :use_item
  def use_item(item)
    $game_temp.set_user_common_event_variable(self)
    $game_temp.set_item_common_event_variable(item)
    th_common_event_variables_use_item(item)
  end
end