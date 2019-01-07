=begin
#===============================================================================
 Title: Custom Page Conditions
 Author: Hime
 Date: Jun 30, 2014
--------------------------------------------------------------------------------
 ** Change log
 Jun 30, 2014
   - fixed bug where negated condition branch patch is outdated
 Mar 28, 2014
   - fixed bug where custom conditions crash on map transfer
 Dec 27, 2013
   - troop events no longer delete commands
   - each event now has their own "Page Interpreter" with the appropriate ID
 Dec 26, 2013
   - Page condition script calls are evaluated in the context of the interpreter
 Dec 17, 2013
   - removed the "delete page condition commands" functionality
 Oct 22, 2013
   - added support for negated conditional branches
 Jun 8, 2013
   - refactored script to be more compatible with others
 May 18, 2013
   - implemented custom conditions for parallel common events
 Mar 24, 2013
   - implemented custom conditions for auto-run common events
 Mar 23, 2013
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
 
 This script allows you to add custom page conditions using comments
 and conditional branches. You can add an unlimited number of custom page
 conditions as long as your event page has room for more commands.
 
 A page will only be selected if all page conditions and custom page
 conditions are satisfied.
 
 This allows you to easily set up complicated activation conditions
 using built-in functionality.
 
 This applies to events and troop events.
 Common events are currently not supported.
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 If you are using the "negated conditional branches" script, this script must
 be placed under it.
  
--------------------------------------------------------------------------------
 ** Usage
 
 To create a custom event condition, first create a comment with the string
 
   <page condition>
   
 Then create a conditional branch command after the comment.
 
 This conditional branch will be converted into a page condition, and will
 be deleted from the command list. Note that any commands inside conditional
 branch will also be deleted.
 
 For troop events, if you specify custom page conditions, they will be checked
 at the beginning of each turn (excluding turn 0) if no built-in condition
 has been applied. This is a workaround because the default engine does not
 check any conditions if no built-in condition is specified.  
 
 For common events, you must set the trigger to auto-run or parallel process.
 You can use a dummy switch that is always true.

--------------------------------------------------------------------------------
 ** Compatibility
 
 This script overwrites the following method:
 
   Game_Map 
     setup_autorun_common_event
     
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_CustomPageConditions"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Custom_Page_Conditions
    Regex = /<page[-_ ]condition>/i
    
#===============================================================================
# ** Rest of script
#===============================================================================
    def custom_conditions
      return @custom_conditions unless @custom_conditions.nil?
      parse_custom_conditions
      return @custom_conditions
    end
    
    #---------------------------------------------------------------------------
    # Get a list of all custom conditions for the page
    #---------------------------------------------------------------------------
    def parse_custom_conditions
      @custom_conditions = []
      index = 0
      cmd = @list[index]
      while cmd        
        if cmd.code == 108 && cmd.parameters[0] =~ TH::Custom_Page_Conditions::Regex
          @custom_conditions.push(@list[index+1]) if @list[index+1].code == 111
          #delete_page_condition_commands(index)
        end
        index += 1
        cmd = @list[index]
      end
    end
    
    #---------------------------------------------------------------------------
    # Deleted the commands related to the page condition, including all
    # nested commands. This is to avoid having the interpreter process them
    # unnecessarily.
    #---------------------------------------------------------------------------
    def delete_page_condition_commands(index)
      indent = @list[index].indent
      @list.delete_at(index) # delete comment
      @list.delete_at(index) # delete conditional branch
      while @list[index].indent != indent
        @list.delete_at(index) # delete any nested commands
      end
      if @list[index].code == 411
        @list.delete_at(index) # delete "else" command
        while @list[index].indent != indent
          @list.delete_at(index) # delete any nested commands
        end
      end
      @list.delete_at(index) # delete "branch end"
    end
  end
end

module RPG
  class Event
    def setup_custom_conditions
      @pages.each {|page| page.parse_custom_conditions}
    end
  end
  
  class Event::Page
    include TH::Custom_Page_Conditions
  end
  
  class CommonEvent
    include TH::Custom_Page_Conditions
  end
  
  class Troop
    def setup_custom_conditions
      @pages.each {|page| page.parse_custom_conditions}
    end
  end
  
  class Troop::Page
    include TH::Custom_Page_Conditions
    
    #---------------------------------------------------------------------------
    # Get a list of all custom conditions for the page
    #---------------------------------------------------------------------------
    def parse_custom_conditions
      @custom_conditions = []
      index = 0
      cmd = @list[index]
      while cmd        
        if cmd.code == 108 && cmd.parameters[0] =~ TH::Custom_Page_Conditions::Regex
          @custom_conditions.push(@list[index+1]) if @list[index+1].code == 111
          #delete_page_condition_commands(index)
          update_troop_condition
        end
        index += 1
        cmd = @list[index]
      end
    end
    
    #---------------------------------------------------------------------------
    # Since the engine doesn't check any conditions if none of the default
    # ones are set, we assume that if a custom condition is set, then
    # it should be checked at every the beginning of every turn.
    #---------------------------------------------------------------------------
    def update_troop_condition
      if !@turn_ending && !@turn_valid && !@enemy_valid &&
       !@actor_valid && !@switch_valid
        @condition.turn_valid = true
        @condition.turn_a = 0
        @condition.turn_b = 1
      end
    end
  end
end

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
class Game_Map
  
  #-----------------------------------------------------------------------------
  # Overwrite. Need to check custom conditions
  #-----------------------------------------------------------------------------
  def setup_autorun_common_event
    event = $data_common_events.find do |event|
      event && event.autorun? && $game_switches[event.switch_id] && !event.custom_conditions.any? {|cond| !TH::Custom_Page_Conditions.custom_condition_met?(cond) }
    end
    @interpreter.setup(event.list) if event
    event
  end
end

#-------------------------------------------------------------------------------
# When timer is active, refresh events everytime the time changes.
# Seems like a bad idea in general.
#-------------------------------------------------------------------------------
class Game_Timer
  
  alias :th_event_page_conditions_update :update
  def update
    th_event_page_conditions_update
    $game_map.need_refresh = true if @working && @count > 0
  end
  
  alias :th_event_page_conditions_on_expire :on_expire
  def on_expire
    th_event_page_conditions_on_expire
    $game_map.need_refresh = true
  end
end

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
class Game_Battler < Game_BattlerBase
  
  alias :th_event_page_conditions_add_state :add_state
  def add_state(state_id)
    th_event_page_conditions_add_state(state_id)
    $game_map.need_refresh = true
  end
  
  alias :th_event_page_conditions_remove_state :remove_state
  def remove_state(state_id)
    th_event_page_conditions_remove_state(state_id)
    $game_map.need_refresh = true
  end
end

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
class Game_Actor < Game_Battler
  
  alias :th_event_page_conditions_name= :name=
  def name=(name)
    self.th_event_page_conditions_name=(name)
    $game_map.need_refresh = true
  end
  
  alias :th_event_page_conditions_change_exp :change_exp
  def change_exp(exp, show)
    th_event_page_conditions_change_exp(exp, show)
    $game_map.need_refresh = true
  end
  
  alias :th_event_page_conditions_change_class :change_class
  def change_class(class_id, keep_exp = false)
    th_event_page_conditions_change_class(class_id, keep_exp)
    $game_map.need_refresh = true
  end
  
  alias :th_event_page_conditions_change_equip :change_equip
  def change_equip(slot_id, item)
    th_event_page_conditions_change_equip(slot_id, item)
    $game_map.need_refresh = true
  end
  
  alias :th_event_page_conditions_release_unequippable_items :release_unequippable_items
  def release_unequippable_items(item_gain = true)
    th_event_page_conditions_release_unequippable_items(item_gain)
    $game_map.need_refresh = true
  end
  
  alias :th_event_page_conditions_learn_skill :learn_skill
  def learn_skill(skill_id)
    th_event_page_conditions_learn_skill(skill_id)
    $game_map.need_refresh = true
  end
  
  alias :th_event_page_conditions_forget_skill :forget_skill
  def forget_skill(skill_id)
    th_event_page_conditions_forget_skill(skill_id)
    $game_map.need_refresh = true
  end
end

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
class Game_Party < Game_Unit
  
  alias :th_event_page_conditions_gain_gold :gain_gold
  def gain_gold(amount)
    th_event_page_conditions_gain_gold(amount)
    $game_map.need_refresh = true
  end
end

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
class Game_Event < Game_Character
  include TH::Custom_Page_Conditions
  
  alias :th_event_page_conditions_init :initialize
  def initialize(map_id, event)
    @page_interpreter = Game_PageInterpreter.new(event.id)
    event.setup_custom_conditions
    th_event_page_conditions_init(map_id, event)
  end
  
  alias :th_custom_page_conditions_refresh :refresh
  def refresh
    @page_interpreter.setup(@id)
    th_custom_page_conditions_refresh
  end
  
  alias :th_event_page_conditions_conditions_met? :conditions_met?
  def conditions_met?(page)
    return false unless th_event_page_conditions_conditions_met?(page)
    page.custom_conditions.each {|cond|
      return false unless @page_interpreter.custom_condition_met?(cond)
    }
    return true
  end
end

class Game_CommonEvent
  include TH::Custom_Page_Conditions
  
  alias :th_custom_page_conditions_initialize :initialize
  def initialize(common_event_id)
		@page_interpreter = Game_PageInterpreter.new(common_event_id)
    th_custom_page_conditions_initialize(common_event_id)    
  end
  
  alias :th_event_page_conditions_active? :active?
  def active?
    th_event_page_conditions_active? && @event.custom_conditions.all? {|cond|
      @page_interpreter.custom_condition_met?(cond)
    }
  end
end

class Game_Troop < Game_Unit
  include TH::Custom_Page_Conditions
  
  alias :th_event_page_conditions_setup :setup
  def setup(troop_id)
	  @page_interpreter = Game_PageInterpreter.new(troop_id)
    th_event_page_conditions_setup(troop_id)
    troop.setup_custom_conditions
  end
  
  alias :th_event_page_conditions_conditions_met? :conditions_met?
  def conditions_met?(page)
    return false unless th_event_page_conditions_conditions_met?(page)
    page.custom_conditions.each {|cond|
      return false unless @page_interpreter.custom_condition_met?(cond)
    }
    return true
  end
end

class Game_PageInterpreter < Game_Interpreter
  
  alias :th_custom_page_conditions_initialize :initialize
  def initialize(event_id)
    th_custom_page_conditions_initialize()    
    @event_id = event_id
    @map_id = $game_map.map_id
  end
  
  alias :th_custom_page_conditions_clear :clear
  def clear
    old_event_id = @event_id
    th_custom_page_conditions_clear
    @event_id = old_event_id
  end
  
  def setup(event_id = 0)
    @map_id = $game_map.map_id
    @event_id = event_id
  end
  
  def custom_condition_met?(c)
    result = false
    params = c.parameters
    case params[0]
    when 0  # Switch
      result = ($game_switches[params[1]] == (params[2] == 0))
    when 1  # Variable
      value1 = $game_variables[params[1]]
      if params[2] == 0
        value2 = params[3]
      else
        value2 = $game_variables[params[3]]
      end
      case params[4]
      when 0  # value1 is equal to value2
        result = (value1 == value2)
      when 1  # value1 is greater than or equal to value2
        result = (value1 >= value2)
      when 2  # value1 is less than or equal to value2
        result = (value1 <= value2)
      when 3  # value1 is greater than value2
        result = (value1 > value2)
      when 4  # value1 is less than value2
        result = (value1 < value2)
      when 5  # value1 is not equal to value2
        result = (value1 != value2)
      end
    when 2  # Self switch
      if @event_id > 0
        key = [@map_id, @event_id, params[1]]
        result = ($game_self_switches[key] == (params[2] == 0))
      end
    when 3  # Timer
      if $game_timer.working?
        if params[2] == 0
          result = ($game_timer.sec >= params[1])
        else
          result = ($game_timer.sec <= params[1])
        end
      end
    when 4  # Actor
      actor = $game_actors[params[1]]
      if actor
        case params[2]
        when 0  # in party
          result = ($game_party.members.include?(actor))
        when 1  # name
          result = (actor.name == params[3])
        when 2  # Class
          result = (actor.class_id == params[3])
        when 3  # Skills
          result = (actor.skill_learn?($data_skills[params[3]]))
        when 4  # Weapons
          result = (actor.weapons.include?($data_weapons[params[3]]))
        when 5  # Armors
          result = (actor.armors.include?($data_armors[params[3]]))
        when 6  # States
          result = (actor.state?(params[3]))
        end
      end
    when 5  # Enemy
      enemy = $game_troop.members[params[1]]
      if enemy
        case params[2]
        when 0  # appear
          result = (enemy.alive?)
        when 1  # state
          result = (enemy.state?(params[3]))
        end
      end
    when 6  # Character
      character = get_character(params[1])
      if character
        result = (character.direction == params[2])
      end
    when 7  # Gold
      case params[2]
      when 0  # Greater than or equal to
        result = ($game_party.gold >= params[1])
      when 1  # Less than or equal to
        result = ($game_party.gold <= params[1])
      when 2  # Less than
        result = ($game_party.gold < params[1])
      end
    when 8  # Item
      result = $game_party.has_item?($data_items[params[1]])
    when 9  # Weapon
      result = $game_party.has_item?($data_weapons[params[1]], params[2])
    when 10  # Armor
      result = $game_party.has_item?($data_armors[params[1]], params[2])
    when 11  # Button
      result = Input.press?(params[1])
    when 12  # Script
      result = eval(params[1])
    when 13  # Vehicle
      result = ($game_player.vehicle == $game_map.vehicles[params[1]])
    end
    return result
  end
end

#===============================================================================
# Using negated conditional branches. This script must be placed under the
# negated conditional branches script.
#===============================================================================
if $imported["TH_NegateConditionalBranch"]
  class Game_PageInterpreter
    alias :th_negate_conditional_branch_custom_condition_met? :custom_condition_met?
    def custom_condition_met?(c)
      result = th_negate_conditional_branch_custom_condition_met?(c)
      if c.negate_condition
        return !result
      else
        return result
      end
    end
  end
end

