###--------------------------------------------------------------------------###
#  Skill Costs script                                                          #
#  Version 1.1b                                                                #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neonblack                                                 #
#  Modified by:                                                                #
#                                                                              #
#  This work is licensed under the Creative Commons Attribution-NonCommercial  #
#  3.0 Unported License. To view a copy of this license, visit                 #
#  http://creativecommons.org/licenses/by-nc/3.0/.                             #
#  Permissions beyond the scope of this license are available at               #
#  http://cphouseset.wordpress.com/liscense-and-terms-of-use/.                 #
#                                                                              #
#      Contact:                                                                #
#  NeonBlack - neonblack23@live.com (e-mail) or "neonblack23" on skype         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Revision information:                                                   #
#  V1.1 - 7.19.2012                                                            #
#   Added more tags                                                            #
#  V1.0 - 7.15.2012                                                            #
#   Wrote and debugged main script                                             #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  Alias       - Scene_Battle: use_item                                        #
#                DataManager: load_database                                    #
#  Overwrites  - Game_BattlerBase: skill_wtype_ok?, skill_mp_cost,             #
#                                  skill_tp_cost, skill_cost_payable?,         #
#                                  pay_skill_cost                              #
#                Window_SkillList: draw_skill_cost                             #
#  New Objects - Game_BattlerBase: skill_hp_cost, skill_gold_cost,             #
#                                  item_cost_met, item_cost_pay,               #
#                                  state_cost_met, state_cost_pay,             #
#                                  switch_cost_met, variable_cost_met,         #
#                                  actor_cost_met, equip_cost_met              #
#                Scene_Battle: final_cost                                      #
#                RPG::UsableItem: set_new_costs                                #
#                DataManager: create_new_skill_costs                           #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script allows you to modify skill costs using not tags added to the    #
#  skills.  You can also define percentage based skill costs.  You may define  #
#  skill costs as seen below.                                                  #
#                                                                              #
#      cost[5 mp] - This is a basic skill cost.  The skill will cost exactly   #
#                   this amount of mp to use.  You can also replace mp with    #
#                   hp, tp, or gold and that much of each will be required     #
#                   and consumed.                                              #
#      cost[10% hp] - This is a percentage based skill cost.  The skill will   #
#                     require this percentage of hp to use.  You can also      #
#                     replace hp with mp or tp.  You can use this at the same  #
#                     time as a standard cost and it will add to the two       #
#                     together, for example, if you use both "cost[20 mp] and  #
#                     cost[15% mp], the skill will cost 20 + 15% of the        #
#                     party member's mp to use.                                #
#      cost[all tp] - This cost will require all of the particular stat to     #
#                     be used up when the skill is used.  There are two        #
#                     differences between using this and using cost[100% tp].  #
#                     first of all, this does not actually "require" the       #
#                     user to have any of the particular stat, meaning the     #
#                     user can have just 20 out of 100 TP currently and can    #
#                     still use the skill.  The second difference is that      #
#                     this cost waits until after ALL damage has been          #
#                     calculated to apply the reduction.  This allows you to   #
#                     use the current value in the damage calculation and      #
#                     still have the stat until after the skill is done.       #
#                     note that unlike the other cost values which cannot      #
#                     make HP go below 1, this cost can actually kill the      #
#                     user.                                                    #
#      cost[5 i4 item] - This will require 5 of item 4 be in the inventory     #
#                        for the skill to be used.  The items will be          #
#                        consumed upon use of the skill.  You can also change  #
#                        "i" to "a" or "w" to consume an armour or weapon      #
#                        instead.  You can use more than one of this tag at a  #
#                        time.                                                 #
#      cost[state 5] - This cost requires the user to be inflicted with a      #
#                      particular state in order to use.  This particular      #
#                      cost will also use up the state, removing it from the   #
#                      actor upon use.  You my have more than one of these on  #
#                      a single skill.                                         #
#      need[state 5] - The same as the one directly above, but does not        #
#                      remove the state on use.                                #
#      need[w 4] - Requires the user to be equipped with weapon number 4 for   #
#                  the skill to be used.  You can also replace "w" with "a"    #
#                  to require an armour instead.  More than one of these can   #
#                  be used at a time.                                          #
#      need[actor 2] - Requires actor 4 to be in the party before the skill    #
#                      can be used.                                            #
#      need[switch 6] - Requires switch 6 to be turned on.                     #
#      need[variable 6 5+] - Requires variable 6 to be greater than or equal   #
#                            to 5.  You can also use 5- to require the value   #
#                            be less than or equal to 5, or just use 5 and it  #
#                            has to be exactly equal to 5.                     #
#      need[type 4] - This one is a little different than the others.  This    #
#                     works exactly like the weapon type drop down boxes.  If  #
#                     you want the skill to be usable by 3 or more weapon      #
#                     types, you can use this tag.  In the example case, if    #
#                     the user is equipped with weapon type 4, the skill can   #
#                     be used.  If more than one of this type of tag is used,  #
#                     the weapon types will only need to match one.            #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Config:                                                                 #
#  These are the default values used by several of the functions in the        #
#  script.  You may change these values as you find your game requires in      #
#  order to give the player a better playing experience based on your game.    #
#                                                                              #
module CP         # Do not                                                     #
module SKILLCOSTS #  change these.                                             #
#                                                                              #
###-----                                                                -----###
# Since only one cost can be shown for a skill by default, this is the order   #
# of priority for costs.  The skill will check the requirements for each value #
# you place in this array in order and draw the first one it finds a           #
# requirement for.  You can use :mp, :hp, :tp, or :gold.                       #
SHOW_PRIORITY = [:mp, :hp, :tp, :gold] # Default = [:mp, :hp, :tp, :gold]      #
#                                                                              #
###-----                                                                -----###
end                        # Don't edit                                        #
end                        #  these 3                                          #
class Window_Base < Window #   lines.                                          #
#                                                                              #
###-----                                                                -----###
# Use these two lines to set the text colours used by the script.  You can     #
# change the number to use one of the window skin text colours or you can use  #
# Color.new(r, g, b) to set a custom colour.                                   #
def gold_cost_color;   text_color(17);  end;                                   #
def hp_cost_color;     text_color(2);  end;                                    #
#                                                                              #
###--------------------------------------------------------------------------###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###


end

module CP
module SKILLCOSTS

COST = /cost\[(\d+*)[ ]?(%|i|w|a?)(\d+*)[ ]?(hp|mp|tp|gold|item|state)[ ]?(\d+*)\]/i
NEED = /need\[(w|a|switch|actor|variable|state|type)[ ](\d+)[, ]*(\d*)(\+|-)*\]/i
ALL = /cost\[all[ ](mp|tp|hp)\]/i  ## All the fancy regexps.

end
end

$imported = {} if $imported.nil?
$imported["CP_SKILLCOSTS"] = 1.1

class Game_BattlerBase
  def skill_wtype_ok?(skill)  ## Replaces the weapon type check.
    return true if enemy?
    wtype_id1 = skill.required_wtype_id1
    wtype_id2 = skill.required_wtype_id2
    wtype_ide = skill.req_type  ## Sets up the added weapon types.
    return true if wtype_id1 == 0 && wtype_id2 == 0 && wtype_ide.empty?
    return true if wtype_id1 > 0 && wtype_equipped?(wtype_id1)
    return true if wtype_id2 > 0 && wtype_equipped?(wtype_id2)
    wtype_ide.each do |type|  ## Checks all weapon types.
      return true if wtype_equipped?(type)
    end
    return false
  end
  
  def skill_mp_cost(skill)  ## Skill cost with added percentage support.
    ((skill.mp_cost + (mmp * skill.mpp_cost).to_i) * mcr).to_i
  end
  
  def skill_tp_cost(skill)  ## TP with percentage.
    skill.tp_cost + (max_tp * skill.tpp_cost).to_i
  end
  
  def skill_hp_cost(skill)  ## HP with percentage.
    skill.hp_cost + (mhp * skill.hpp_cost).to_i
  end
  
  def skill_gold_cost(skill)  ## A skill's gold cost.
    skill.gold_cost
  end
  
  def item_cost_met(skill)  ## Check if the inventory contains the items.
    result = true
    return true if enemy?  ## Ignore this if it's an enemy.
    return result if skill.item_cost.empty?
    skill.item_cost.each do |item|
      case item.kind
      when 1
        req = $data_items[item.id]
      when 2
        req = $data_weapons[item.id]
      when 3
        req = $data_armors[item.id]
      end
      next if $game_party.item_number(req) >= item.cost
      result = false
    end
    return result
  end
  
  def item_cost_pay(skill)
    return if enemy?  ## Prevents enemies from using the party's inventory.
    return if skill.item_cost.empty?
    skill.item_cost.each do |item|
      case item.kind
      when 1
        req = $data_items[item.id]
      when 2
        req = $data_weapons[item.id]
      when 3
        req = $data_armors[item.id]
      end
      $game_party.lose_item(req, item.cost)  ## Removes the items.
    end
  end
  
  def state_cost_met(skill)
    result = true  ## Used to check if the player has the conditions.
    return result if skill.req_state.empty?
    skill.req_state.each do |state|
      next if state?(state)
      result = false
    end
    return result
  end
  
  def state_cost_pay(skill)  ## Removes states if needed.
    return if skill.state_cost.empty?
    skill.state_cost.each do |state|
      remove_state(state)
    end
  end
  
  def switch_cost_met(skill)
    result = true  ## Checks switches.
    return result if skill.req_switch.empty?
    skill.req_switch.each do |switch|
      next if $game_switches[switch]
      result = false
    end
    return result
  end
  
  def variable_cost_met(skill)
    result = true  ## Performs the checks for variables.
    return result if skill.req_variable.empty?
    skill.req_variable.each do |variable|
      if variable[2] == '+'
        next if $game_variables[variable[0]] >= variable[1]
      elsif variable[2] == '-'
        next if $game_variables[variable[0]] <= variable[1]
      else
        next if $game_variables[variable[0]] == variable[1]
      end
      result = false
    end
    return result
  end
  
  def actor_cost_met(skill)
    result = true  ## Checks if an actor is in the battle party.
    return result if skill.req_actor.empty?
    skill.req_actor.each do |actor|
      next if $game_party.battle_members.include?($game_actors[actor])
      result = false
    end
    return result
  end
  
  def equip_cost_met(skill)
    result = true  ## Checks if the required items are equipped.
    return result if enemy?
    return result if (skill.req_w.empty? && skill.req_a.empty?)
    skill.req_w.each do |wep|
      next if weapons.include?($data_weapons[wep])
      result = false
    end
    skill.req_a.each do |arm|
      next if armors.include?($data_armors[arm])
      result = false
    end
    return result
  end
  
  def skill_cost_payable?(skill)  ## Adds all the other conditions.
    tp >= skill_tp_cost(skill) && mp >= skill_mp_cost(skill) &&
    hp > skill_hp_cost(skill) && $game_party.gold >= skill_gold_cost(skill) &&
    item_cost_met(skill) && state_cost_met(skill) && switch_cost_met(skill) &&
    variable_cost_met(skill) && actor_cost_met(skill) && equip_cost_met(skill)
  end
  
  def pay_skill_cost(skill)  ## Adds a few more pay costs.
    self.mp -= skill_mp_cost(skill)
    self.tp -= skill_tp_cost(skill)
    self.hp -= skill_hp_cost(skill)
    $game_party.lose_gold(skill_gold_cost(skill))
    item_cost_pay(skill)
    state_cost_pay(skill)
  end
end

class Scene_Battle < Scene_Base
  alias cp_sc_use_item use_item unless $@
  def use_item  ## Adds the final cost.
    cp_sc_use_item
    return if @subject.current_action.nil?
    item = @subject.current_action.item
    final_cost(@subject, item)
  end
  
  def final_cost(user, item)  ## The final cost for removing all of a stat.
    user.tp = 0 if item.all_tp
    user.mp = 0 if item.all_mp
    user.hp = 0 if item.all_hp
  end
end

class Window_SkillList < Window_Selectable
  def draw_skill_cost(rect, skill)
    CP::SKILLCOSTS::SHOW_PRIORITY.each do |type|
      case type  ## Draws skill type based on priority.
      when :hp
        if @actor.skill_hp_cost(skill) > 0
          change_color(hp_cost_color, enable?(skill))
          draw_text(rect, @actor.skill_hp_cost(skill), 2)
          break
        end
      when :mp
        if @actor.skill_mp_cost(skill) > 0
          change_color(mp_cost_color, enable?(skill))
          draw_text(rect, @actor.skill_mp_cost(skill), 2)
          break
        end
      when :tp
        if @actor.skill_tp_cost(skill) > 0
          change_color(tp_cost_color, enable?(skill))
          draw_text(rect, @actor.skill_tp_cost(skill), 2)
          break
        end
      when :gold
        if @actor.skill_gold_cost(skill) > 0
          change_color(gold_cost_color, enable?(skill))
          draw_text(rect, @actor.skill_gold_cost(skill), 2)
          break
        end
      end
    end
  end
end

class Skill_Cost  ## Small class that holds item type and cost.
  attr_accessor :kind
  attr_accessor :id
  attr_accessor :cost
  
  def initialize(kind = 1, id = 1, cost = 0)
    @kind = kind
    @id = id
    @cost = cost
  end
end

class RPG::UsableItem < RPG::BaseItem  ## All the new skill costs.
  attr_accessor :gold_cost
  attr_accessor :hp_cost
  attr_accessor :item_cost
  attr_accessor :hpp_cost
  attr_accessor :mpp_cost
  attr_accessor :tpp_cost
  attr_accessor :state_cost
  attr_accessor :all_hp
  attr_accessor :all_mp
  attr_accessor :all_tp
  attr_accessor :req_a
  attr_accessor :req_w
  attr_accessor :req_state
  attr_accessor :req_switch
  attr_accessor :req_variable
  attr_accessor :req_actor
  attr_accessor :req_type
  
  def set_new_costs
    return if @new_cost_set; @new_cost_set = true
    @gold_cost = 0  ## Sets up the basic costs.
    @hp_cost = 0
    @item_cost = []
    @hpp_cost = 0
    @mpp_cost = 0
    @tpp_cost = 0
    @state_cost = []
    @all_hp = false
    @all_mp = false
    @all_tp = false
    @req_a = []
    @req_w = []
    @req_state = []
    @req_switch = []
    @req_variable = []
    @req_actor = []
    @req_type = []
    self.note.split(/[\r\n]+/).each do |line|
      case line  ## Basic costs.
      when CP::SKILLCOSTS::COST
        cost_type = $4.to_s
        case cost_type.downcase
        when 'mp'
          if $2.to_s == '%'  ## Checks percentage or not.
            @mpp_cost = $1.to_f * 0.01
          else
            @mp_cost = $1.to_i
          end
        when 'hp'
          if $2.to_s == '%'
            @hpp_cost = $1.to_f * 0.01
          else
            @hp_cost = $1.to_i
          end
        when 'tp'
          if $2.to_s == '%'
            @tpp_cost = $1.to_f * 0.01
          else
            @tp_cost = $1.to_i
          end
        when 'gold'  ## Adds gold cost.
          @gold_cost = $1.to_i
        when 'item'  ## Item usage check.
          case $2.to_s
          when 'i', 'I'
            kind = 1
          when 'w', 'W'
            kind = 2
          when 'a', 'A'
            kind = 3
          else
            kind = 1
          end  ## Pushes the item cost to an array.
          @item_cost.push(Skill_Cost.new(kind, $3.to_i, $1.to_i))
        when 'state'  ## Pushes a use state to the need array for checking.
          @state_cost.push($5.to_i)
          @req_state.push($5.to_i)
        end
      when CP::SKILLCOSTS::ALL
        cost_type = $1.to_s
        case cost_type.downcase
        when 'mp'  ## Checks if all usage is true.
          @all_mp = true
        when 'hp'
          @all_hp = true
        when 'tp'
          @all_tp = true
        end
      when CP::SKILLCOSTS::NEED
        cost_type = $1.to_s  ## Simple pushes for requirements.
        case cost_type.downcase
        when 'a'
          @req_a.push($2.to_i)
        when 'w'
          @req_w.push($2.to_i)
        when 'state'
          @req_state.push($2.to_i)
        when 'switch'
          @req_switch.push($2.to_i)
        when 'variable'
          @req_variable.push([$2.to_i, $3.to_i, $4.to_s])
        when 'actor'
          @req_actor.push($2.to_i)
        when 'type'
          @req_type.push($2.to_i)
        end
      end #when
    end #split
  end
end

module DataManager
  class << self
    
  alias cp_sc_load_database load_database unless $@
  def load_database
    cp_sc_load_database
    create_new_skill_costs
  end

  def create_new_skill_costs  ## Adds requirements to all skills.
    groups = [$data_skills]
    for group in groups
      for obj in group
        next if obj == nil
        obj.set_new_costs if obj.is_a?(RPG::Skill)
      end
    end
  end
  
  end
end