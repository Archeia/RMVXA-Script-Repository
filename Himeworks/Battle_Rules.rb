=begin
#===============================================================================
 Title: Battle Rules
 Author: Hime
 Date: Jun 13, 2013
--------------------------------------------------------------------------------
 ** Change log
 Jun 13, 2013
   - implemented rule groups
 May 4, 2013
   - victory/defeat condition check methods dynamically generated now
   - added support for modifying default rules
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
 
 This script allows you to set up "battle rules" for victory or
 defeat. The default battle rules are
 
   default victory rules: all enemies are dead
   default defeat rules: all actors are dead
   
 There are four scopes for battle rules
 
 * Global battle rules
   These apply to all battles. These are the "default" rules.
 
 * Map battle rules
   These apply to all battles that occur on the current map
   
 * Troop battle rules
   These apply to any encounter with this troop.
   
 * Event battle rules
   These apply to encounters on a per-event basis
 
 There are two ways to specify rules for a battle
 
 1. Set rules. These overwrite any previous rules. So for example, if you had
    defined map rules and troop rules, but then have "set" event rules, then
    all of the map rules and troop rules will not apply for this battle.
 
 2. Add rules. These are added on top of any previous rules, so you can add
    event battle rules to any troop rules or map rules.
    
 Battle rules are grouped into "rule groups". A rule group contains one or
 more battle rules. A rule group is satisfied when all of the rules within
 the group is satisfied. A victory or defeat condition is met when any rule
 group has been satisfied.
 
 Using rule groups, you can provide players with the option of completing
 different tasks in order to finish a battle.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage

 All rules use the same syntax as follows:
 
   <victory rule: add>
     cond: some victory condition
     desc: some description
     group: some group number
   </victory rule>
   
   <defeat rule: set>
     cond: some defeat condition
     desc: some description
     group: some group number
   </defeat rule>
   
 `cond` is the condition of this rule, as a ruby statement that evaluates to
 true or false.
 
 `desc` is a description of this rule. This is not necessary, but maybe some
 other scripts will find some use for it.
 
 `group` is the rule group that the rule will be assigned to. If no group is
 given, then it will be assigned to group 1.
   
 Add and set types apply to both victory and defeat rules. They are just
 example syntax.
 
 For maps, they will be written in the note-box
 For troops and events they will be written as comments.
 
 In order for a victory or defeat condition to be met, you must complete all of
 the tasks listed in one rule group. However, it is not necessary to satisfy
 every rule group.
 
 For example, if group 1 contains two rules, and group 2 contains three rules,
 then you can choose to fulfill group 1's rules to finish the battle, or choose
 to fulfill group 2's rules to finish the battle.
 
 In the configuration, you can set up the default rules and their descriptions.
 Currently they are all assigned to group 1.
 
--------------------------------------------------------------------------------
 ** Compatibility
 
 This script overwrites the following method:
 
   BattleManager
     self.judge_win_loss
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_BattleRules"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Battle_Rules
    
    # You can set the default rules here. These will be treated as global
    # battle rules
    Default_Victory_Rules = {
      "$game_troop.all_dead?" => "All enemies defeated"
    }
    
    Default_Defeat_Rules = {
      "$game_party.all_dead?" => "All allies defeated"
    }
    
#===============================================================================
# ** Rest of Script
#===============================================================================
    
    Victory_Regex = /<victory rule: (\w+)>(.*?)<\/victory rule>/im
    Defeat_Regex = /<defeat rule: (\w+)>(.*?)<\/defeat rule>/im
    
    #---------------------------------------------------------------------------
    # Returns all battle rules
    #---------------------------------------------------------------------------
    def battle_rules
      return @battle_rules unless @battle_rules.nil?
      parse_battle_rules
      return @battle_rules
    end
    
    #---------------------------------------------------------------------------
    # Go through each set of options and store them appropriately
    #---------------------------------------------------------------------------
    def parse_battle_rule_options(rule, data)
      rule.group = 1
      data.each do |tag|
        name, value = tag.split(":")
        case name.downcase
        when "cond"
          rule.condition = value
        when "desc"
          rule.description = value
        when "group"
          rule.group = value.to_i
        end
      end
    end
    
    #---------------------------------------------------------------------------
    # Adds new rule to the battle rules based on the rule category and rule type
    #---------------------------------------------------------------------------
    def add_battle_rule(rule, category, type)
      case category
      when :victory
        case type.downcase
        when "set"
          @battle_rules.set_victory_rule(rule)
        when "add"
          @battle_rules.add_victory_rule(rule)
        end
      when :defeat
        case type.downcase
        when "set"
          @battle_rules.set_defeat_rule(rule)
        when "add"
          @battle_rules.add_defeat_rule(rule)
        end
      end
    end
    
    def parse_battle_rule_comments(comments)
      comments.each do |comment|
        # check victory rules
        if comment =~ Victory_Regex
          rule = Game_BattleRule.new
          data = $2.strip.split("\r\n")
          parse_battle_rule_options(rule, data)
          add_battle_rule(rule, :victory, $1)
        end
        # check defeat rules
        if comment =~ Defeat_Regex
          rule = Game_BattleRule.new
          data = $2.strip.split("\r\n")
          parse_battle_rule_options(rule, data)
          add_battle_rule(rule, :defeat, $1)
        end
      end
    end
    
    #---------------------------------------------------------------------------
    # Collect all comments from an event page. Only applies to events.
    #---------------------------------------------------------------------------
    def comments
      coms = []
      comment = ""
      @list.each do |cmd|
        if cmd.code == 108
          coms << comment unless comment.empty?
          comment = cmd.parameters[0]
        elsif cmd.code == 408
          comment << "\r\n" << cmd.parameters[0]
        end
      end
      coms << comment
      coms
    end
  end
end

module RPG
  
  #-----------------------------------------------------------------------------
  # Assign map-scope rules
  #-----------------------------------------------------------------------------
  class Map
    include TH::Battle_Rules
    
    def parse_battle_rules
      @battle_rules = Game_BattleRules.new
      victory_rules = self.note.scan(Victory_Regex)
      victory_rules.each do |res|
        rule = Game_BattleRule.new
        data = res[1].strip.split("\r\n")        
        parse_battle_rule_options(rule, data)
        add_battle_rule(rule, :victory, res[0])
      end
      
      defeat_rules = self.note.scan(Defeat_Regex)
      defeat_rules.each do |res|
        rule = Game_BattleRule.new
        data = res[1].strip.split("\r\n")        
        parse_battle_rule_options(rule, data)
        add_battle_rule(rule, :defeat, res[0])
      end
    end 
  end
  
  #-----------------------------------------------------------------------------
  # Assign troop-scope rules
  #-----------------------------------------------------------------------------
  class Troop
    include TH::Battle_Rules
    
    #---------------------------------------------------------------------------
    # Search all pages for battle rules
    #---------------------------------------------------------------------------
    def parse_battle_rules
      @battle_rules = Game_BattleRules.new
      all_comments = []
      @pages.each do |page|
        all_comments << page.comments
      end
      all_comments.flatten!
      parse_battle_rule_comments(all_comments)
    end
  end
  
  class Troop::Page
    include TH::Battle_Rules
  end
  
  #-----------------------------------------------------------------------------
  # Assign event-scope rules
  #-----------------------------------------------------------------------------
  class Event::Page
    include TH::Battle_Rules
    def parse_battle_rules
      @battle_rules = Game_BattleRules.new
      parse_battle_rule_comments(comments)
    end
  end
end

#-------------------------------------------------------------------------------
# Update battle manager to use the custom rules
#-------------------------------------------------------------------------------
module BattleManager
  
  class << self
    alias :th_battle_rules_setup :setup
    
    attr_reader :victory_conditions
    attr_reader :defeat_conditions
  end
  
  #-----------------------------------------------------------------------------
  # Setup battle rules
  #-----------------------------------------------------------------------------
  def self.setup(troop_id, can_escape = true, can_lose = false)
    th_battle_rules_setup(troop_id, can_escape, can_lose)
    setup_battle_rules
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite. Now we have more conditions available.
  #-----------------------------------------------------------------------------
  def self.judge_win_loss
    if @phase
      return process_abort   if $game_party.members.empty?
      return process_defeat  if defeat_conditions_met?
      return process_victory if victory_conditions_met?
      return process_abort   if aborting?
    end
    return false
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def self.setup_battle_rules
    setup_victory_conditions
    setup_defeat_conditions
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def self.setup_victory_conditions
    
    # If event has "set" rules, then overwrite base rules
    if !$game_temp.battle_rules.set_victory_rules.empty?
      @victory_conditions = $game_temp.battle_rules.set_victory_rules.values
    # If troop has "set" rules, then overwrite map rules
    elsif !$game_troop.battle_rules.set_victory_rules.empty?
      @victory_conditions = $game_troop.battle_rules.set_victory_rules.values
    # If map has "set" rules, then overwrite default rules
    elsif !$game_map.battle_rules.set_victory_rules.empty?
      @victory_conditions = $game_map.battle_rules.set_victory_rules.values
    # Otherwise just use default rules
    else
      @victory_conditions = $game_system.battle_rules.default_victory_rules.values
    end
    # now add the "add" rule
    @victory_conditions.concat($game_map.battle_rules.add_victory_rules.values)
    @victory_conditions.concat($game_troop.battle_rules.add_victory_rules.values)
    @victory_conditions.concat($game_temp.battle_rules.add_victory_rules.values)
    
    # Generate the victory condition checking method
    define_method_victory_check
  end
  
  #-----------------------------------------------------------------------------
  # New. Analogous to victory rules.
  #-----------------------------------------------------------------------------
  def self.setup_defeat_conditions
    if !$game_temp.battle_rules.set_defeat_rules.empty?
      @defeat_conditions = $game_temp.battle_rules.set_defeat_rules.values
    elsif !$game_troop.battle_rules.set_defeat_rules.empty?
      @defeat_conditions = $game_troop.battle_rules.set_defeat_rules.values
    elsif !$game_map.battle_rules.set_defeat_rules.empty?
      @defeat_conditions = $game_map.battle_rules.set_defeat_rules.values
    else
      @defeat_conditions = $game_system.battle_rules.default_defeat_rules.values
    end
    @defeat_conditions.concat($game_map.battle_rules.add_defeat_rules.values)
    @defeat_conditions.concat($game_troop.battle_rules.add_defeat_rules.values)
    @defeat_conditions.concat($game_temp.battle_rules.add_defeat_rules.values)
    define_method_defeat_check
  end
  
  #-----------------------------------------------------------------------------
  # Dynamically define the victory checking method to speed up performance.
  # Separate groups are joined with OR logic, while rules within each group are
  # joined with AND logic.
  #-----------------------------------------------------------------------------
  def self.define_method_victory_check
    stmt = "def self.victory_conditions_met?;"
    @victory_conditions.each_with_index do |group, i|
      stmt << " || " unless i == 0
      group.rules.each_with_index do |rule, j|
        if j == 0
          stmt << "#{rule.condition}"
        else
          stmt << " && #{rule.condition}"
        end
      end
    end
    stmt << ";end"
    p stmt
    eval(stmt)
  end
  
  #-----------------------------------------------------------------------------
  # Dynamically define the defeat checking method to speed up performance
  #-----------------------------------------------------------------------------
  def self.define_method_defeat_check
    stmt = "def self.defeat_conditions_met?;"
    @defeat_conditions.each_with_index do |group, i|
      stmt << " || " unless i == 0
      group.rules.each_with_index do |rule, j|
        if j == 0
          stmt << "#{rule.condition}"
        else
          stmt << " && #{rule.condition}"
        end
      end
    end
    stmt << ";end"
    eval(stmt)
  end
end

#-------------------------------------------------------------------------------
# Event battle rules are stored as temporary data and only used by the
# Battle Manager to set things up
#-------------------------------------------------------------------------------
class Game_Temp
  
  attr_accessor :battle_rules
  
  alias :th_battle_rules_initialize :initialize
  def initialize
    th_battle_rules_initialize
    clear_battle_rules
  end
  
  def clear_battle_rules
    @battle_rules = Game_BattleRules.new
  end
end

#-------------------------------------------------------------------------------
# Global battle rules are stored with the game system.
#-------------------------------------------------------------------------------
class Game_System
  
  attr_reader :battle_rules
  
  alias :th_battle_rules_initialize :initialize
  def initialize
    th_battle_rules_initialize
    clear_battle_rules
  end
  
  def clear_battle_rules
    @battle_rules = Game_BattleRules.new
  end
end

#-------------------------------------------------------------------------------
# A wrapper containing battle rules
#-------------------------------------------------------------------------------
class Game_BattleRules
  
  attr_reader :set_victory_rules
  attr_reader :add_victory_rules
  attr_reader :set_defeat_rules
  attr_reader :add_defeat_rules
  
  def initialize
    @set_victory_rules = {}
    @add_victory_rules = {}
    @set_defeat_rules = {}
    @add_defeat_rules = {}
  end
  
  def add_victory_rule(rule)
    @add_victory_rules[rule.group] ||= Game_BattleRuleGroup.new
    @add_victory_rules[rule.group].add(rule)
  end
  
  def set_victory_rule(rule)
    @set_victory_rules[rule.group] ||= Game_BattleRuleGroup.new
    @set_victory_rules[rule.group].add(rule)
  end
  
  def add_defeat_rule(rule)
    @add_defeat_rules[rule.group] ||= Game_BattleRuleGroup.new
    @add_defeat_rules[rule.group].add(rule)
  end
  
  def set_defeat_rule(rule)
    @set_defeat_rules[rule.group] ||= Game_BattleRuleGroup.new
    @set_defeat_rules[rule.group].add(rule)
  end
  
  def default_victory_rules
    rules = {}
    rules[1] = Game_BattleRuleGroup.new
    TH::Battle_Rules::Default_Victory_Rules.each do |cond, desc|
      rules[1].add(Game_BattleRule.new(cond, desc, 1))
    end
    return rules
  end
  
  def default_defeat_rules
    rules = {}
    rules[1] = Game_BattleRuleGroup.new
    TH::Battle_Rules::Default_Defeat_Rules.each do |cond, desc|
      rules[1].add(Game_BattleRule.new(cond, desc, 1))
    end
    return rules
  end
end

#-------------------------------------------------------------------------------
# A group of battle rules. A battle consists of multiple groups of rules. All
# rules within a group must be satisfied in order for the group to be met, but
# it is only necessary to satisfy one group of rules for victory or defeat to
# occur
#-------------------------------------------------------------------------------
class Game_BattleRuleGroup
  attr_accessor :rules
  
  def initialize
    @rules = []
  end
  
  def add(rule)
    @rules << rule
  end
end

#-------------------------------------------------------------------------------
# A battle rule object. Contains a condition, as well as a description of the
# rule
#-------------------------------------------------------------------------------
class Game_BattleRule
  
  attr_accessor :condition
  attr_accessor :description
  attr_accessor :group
  
  def initialize(condition="true", description="", group=1)
    @condition = condition
    @description = description
    @group = group
  end
end

#-------------------------------------------------------------------------------
# Store the event's battle rules in game temp
#-------------------------------------------------------------------------------
class Game_Interpreter
  
  alias :th_battle_rules_command_301 :command_301
  def command_301
    $game_temp.battle_rules = $game_map.events[@event_id].battle_rules
    th_battle_rules_command_301
  end
end

#-------------------------------------------------------------------------------
# Retrieve map-level battle rules from the current map
#-------------------------------------------------------------------------------
class Game_Map
  def battle_rules
    @map ? @map.battle_rules : Game_BattleRules.new
  end
end

#-------------------------------------------------------------------------------
# Retrieve troop-level battle rules from the current map
#-------------------------------------------------------------------------------
class Game_Troop
  def battle_rules
    troop.battle_rules
  end
end

#-------------------------------------------------------------------------------
# Retrieve event-level battle rules from the current map
#-------------------------------------------------------------------------------
class Game_Event
  def battle_rules
    @page ? @page.battle_rules : Game_BattleRules.new
  end
end