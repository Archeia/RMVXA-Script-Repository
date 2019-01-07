=begin
#===============================================================================
 Title: Battle Reactions
 Author: Tsukihime
 Date: Nov 1, 2014
 URL: http://himeworks.com/2013/09/17/battle-reactions/
--------------------------------------------------------------------------------
 ** Change log
 Nov 1, 2014
   - added check to avoid creating a reaction if target cannot move and reaction
     is not forced
 May 13, 2014
   - implemented "pre-reactions"
 Mar 5, 2014
   - corrected element and skill type triggers
 Feb 7, 2014
   - added reaction conditions
   - reactions are handled uniformly now
   - "chance" is considered deprecated and should not be used
 Jan 22, 2014
   - updated to remove all dependencies on forced action
 Dec 6, 2013
   - fixed bug where using an item crashed on stype check
 Nov 23, 2013
   - react message is only shown if an actual reaction took place
   - fixed bug where the chance was not divided by 100
 Nov 15, 2013
   - refactored reaction note-tag loading
   - chance can now be specified as a formula
 Sep 22, 2013
   - fixed bug where battlers no longer performed any actions after reacting
 Sep 21, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Tsukihime in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script provides functionality for setting up "battle reactions", which are
 actions that are automatically invoked in response to certain actions.
 
 This script introduces the concept of "reaction objects", which is basically
 any object that supports reactions. Actors, Classes, Items, Skills, Weapons,
 Armors, Enemies, and States all support reaction objects.
 
 You can have multiple reactions occur simultaneously and all of them
 will be executed.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 

 -- Skill Triggers --
 
 To create a reaction that responds to skills, note-tag any reaction object with
 
   <skill reaction: skill_id react_id chance forced>
   
 Where
   `skill_id` is the ID of the skill to react to
   `react_id` is the ID of the skill to use in response
   `chance` is the probability that it is used. 100 is always, while 0 is never
   `forced` means it basically acts like a forced action (no MP/SP consumption)
   
 The chance can be specified as a formula, with the following variables
 available to use
 
   a - react user (ie: the battler that will react)
   b - react target
   p - game party
   t - game troop
   v - game variables
   s - game switches
   
 Note that you literally type in "forced" if you want the raction to be the\
 same as a "forced action".
 
 -- Skill Type Triggers --
 
 To create a reaction that responds to skill types, note-tag reaction objects
 with
 
   <stype reaction: stype_id react_id chance forced>
   
 Where the stype_id can be looked up in the terms database.
 When a skill with the specified skill type ID is used, the reaction will
 be triggered.
 
 -- Element Triggers --
 
 To create a reaction that responds to certain elements, note-tag any
 reaction object with
 
   <element reaction: element_id react_id chance forced>
   
 Where the element_id can be looked up in the Terms database.
 When a skill with the specified element is used, reaction will be triggered.
 Note that this only considers the element of the skill, not features.

 -- Reaction Condition --
 
 You can add conditions to your reactions. A reaction will only occur if the
 reaction condition has been met.
 
 Reaction conditions are specified as formulas. They can be any formula, and
 use the same formula variables that are available to battle reactions.
 
 To create a reaction condition, use the following note-tag
 
   <reaction condition: id1,id2, ... >
     FORMULA
   </reaction condition>
   
 The ID's are important: they are the reactions that the condition applies to,
 where each ID is separated by a comma.
 
 Each reaction has a unique ID, in the order that they are written in your note
 box. The first reaction is 1,  the second reaction is 2, and so on. Refer to
 the example to understand how reaction conditions can be used
 
 -- Reaction Timing --
 
 Reactions can occur before or after an action is executed. By default, a
 reaction occurs after, but you can set a reaction to occur when an action
 has been declared, but before it hits.
 
 So for example, if an enemy attacks you, you may react to this by putting up
 a shield, effectively increasing your defense, before the attack lands.

 To set a reaction to occur before an action hits, use the note-tag
 
   <pre react: id1, id2, ... >
   
 Where the ID's are the reactions that you want to apply this setting to.
 
--------------------------------------------------------------------------------
 ** Example
 
 Suppose we have two reactions. The first is a skill reaction that reacts to
 the attack skill (skill 1), and responds with a triple attack (skill 23).
 
 The second is a skill type reaction that reacts to all "magic" skills
 (stype 2) with a heal spell (skill 51).
 
 Both reactions will only occur if state 23 is applied.
 
 You can begin by writing the reactions, and then write the reaction condition

   <skill reaction: 1 23>
   <stype reaction: 2 51>
   
   <reaction condition: 1,2>
     a.state?(23)
   </reaction condition>

 If you want the stype reaction to occur before the skill lands, you can simply
 add the following to your note
 
   <pre react: 2>
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_BattleReactions"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Battle_Reactions
    
    # Message to display when a battler reacts to a skill.
    Skill_React_Vocab = "%s reacts to %s" 
    
    Skill_Regex = /<skill[-_ ]reaction(\s*\d+\s*)?:\s*(\d+)\s*(\d+)\s*(.*?)?\s*(forced)?\s*>/i
    Stype_Regex = /<stype[-_ ]reaction(\s*\d+\s*)?:\s*(\d+)\s*(\d+)\s*(.*?)?\s*(forced)?\s*>/i
    Element_Regex = /<element[-_ ]reaction(\s*\d+\s*)?:\s*(\d+)\s*(\d+)\s*(.*?)?\s*(forced)?\s*>/i
    
    Cond_Regex = /<reaction[-_ ]condition:(.*?)>(.*?)<\/reaction[-_ ]condition>/im
    
    Pre_Regex = /<pre[-_ ]react:\s*(.*)\s*>/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class BaseItem
    
    def reactions(skill)
      return [] unless skill.is_a?(RPG::Skill)
      load_notetag_battle_reactions unless @reactions
      @reactions.select {|data|
        (data.trigger_type == :skill && data.trigger_id == skill.id) ||
        (data.trigger_type == :stype && data.trigger_id == skill.stype_id) ||
        (data.trigger_type == :element && data.trigger_id == skill.damage.element_id)
      }
    end
    
    def load_notetag_battle_reactions
      @reactions = []
      
      reactions = load_data_battle_reaction(TH::Battle_Reactions::Skill_Regex, Data_SkillReaction)
      @reactions.concat(reactions)
      
      reactions = load_data_battle_reaction(TH::Battle_Reactions::Stype_Regex, Data_StypeReaction)
      @reactions.concat(reactions)
      
      reactions = load_data_battle_reaction(TH::Battle_Reactions::Element_Regex, Data_ElementReaction)
      @reactions.concat(reactions)
      
      # Assign conditions to reactions
      load_notetag_reaction_conditions
      load_notetag_prereactions
    end
    
    def load_data_battle_reaction(regex, dataClass)
      reactions = []
      res = self.note.scan(regex)
      res.each do |data|
        reaction_id = data[0].to_i
        trigger_id = data[1].to_i
        reaction = dataClass.new(trigger_id)
        reaction.react_id = data[2].to_i
        reaction.chance = data[3] if data[3] && !data[3].empty?
        reaction.forced = data[4].downcase == "forced" if data[4]
        reactions << reaction
      end
      return reactions
    end
    
    def load_notetag_reaction_conditions
      results = self.note.scan(TH::Battle_Reactions::Cond_Regex)
      results.each do |res|
        ids = res[0].split(",").map {|id| id.to_i - 1 }
        condition = res[1].strip
        ids.each do |id|
          next unless @reactions[id]
          @reactions[id].condition = condition
        end
      end
    end
    
    def load_notetag_prereactions
      results = self.note.scan(TH::Battle_Reactions::Pre_Regex)
      results.each do |res|
        ids = res[0].split(",").map {|id| id.to_i - 1 }
        ids.each do |id|
          next unless @reactions[id]
          @reactions[id].pre_reaction = true
        end
      end
    end
  end
end

module BattleManager
  
  class << self
    attr_accessor :reaction_processing
    
    alias :th_battle_reactions_setup :setup
    alias :th_battle_reactions_action_forced? :action_forced?
  end
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def self.setup(troop_id, can_escape = true, can_lose = false)
    @reaction_processing = false
    th_battle_reactions_setup(troop_id, can_escape, can_lose)
  end
  
  def self.reaction_forced?
    @reaction_processing
  end
  
  def self.clear_reaction_processing
    @reaction_forced = nil
    @reaction_processing = false
  end
  
  def self.force_reaction(battler)
    @reaction_forced = battler
  end
end

module Vocab
  Skill_Reaction = TH::Battle_Reactions::Skill_React_Vocab
end

class Data_Reaction
  attr_accessor :id
  attr_accessor :trigger_type
  attr_accessor :trigger_id
  attr_accessor :react_type
  attr_accessor :react_id
  attr_accessor :chance       # probability that the reaction occurs
  attr_accessor :forced
  attr_accessor :condition
  attr_accessor :pre_reaction
  
  def initialize
    @id = 0
    @condition = "true"
    @forced = false
    @chance = "100"
    @pre_reaction = false
  end
  
  def pre_react?
    @pre_reaction
  end
  
  def chance(react_user, react_target)
    eval_chance(react_user, react_target)
  end
  
  def eval_chance(a, b, p=$game_party, t=$game_troop, v=$game_variables, s=$game_switches)
    eval(@chance) / 100.0
  end
  
  def condition_met?(a, b, p=$game_party, t=$game_troop, v=$game_variables, s=$game_switches)
    eval(@condition)
  end
end

#-------------------------------------------------------------------------------
# Skill reaction object
#-------------------------------------------------------------------------------
class Data_SkillReaction < Data_Reaction
  
  def initialize(skill_id)
    @trigger_type = :skill
    @react_type = :skill
    @trigger_id = skill_id
    @react_id = 0
    super()
  end
end

#-------------------------------------------------------------------------------
# Skill Type reaction object.
#-------------------------------------------------------------------------------
class Data_StypeReaction < Data_Reaction
  def initialize(stype_id)
    @trigger_type = :stype
    @react_type = :skill
    @trigger_id = stype_id
    @react_id = 0
    super()
  end
end

#-------------------------------------------------------------------------------
# Element reaction object
#-------------------------------------------------------------------------------
class Data_ElementReaction < Data_Reaction
  def initialize(element_id)
    @trigger_type = :element
    @react_type = :skill
    @trigger_id = element_id
    @react_id = 0
    super()
  end
end

class Game_BattlerBase
  
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def reaction_objects
    states
  end
end

class Game_Battler < Game_BattlerBase
  
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def skill_reactions(item)
    reaction_objects.inject([]) do |r, obj|
      r.concat(obj.skill_reactions(item))
    end
  end
  
  def get_reactions(item)
    res = []
    reaction_objects.each do |obj|
      res.concat(obj.reactions(item))
    end
    return res
  end
  
  #-----------------------------------------------------------------------------
  # adds a reaction object
  #-----------------------------------------------------------------------------
  def make_reaction(user, reaction)
    return unless reaction.condition_met?(self, user)
    return unless movable? || reaction.forced
    chance = reaction.chance(self, user)    
    return if chance < rand
    skill = $data_skills[reaction.react_id]
    action = Game_Action.new(self, reaction.forced)
  
    if skill.for_opponent?
      action.target_index = user.index
    elsif skill.for_friend?
      action.target_index = self.index
    end
    action.set_skill(reaction.react_id)
    action.make_targets
    @actions.push(action)
    BattleManager.force_reaction(self)
  end
  
  #-----------------------------------------------------------------------------
  # adds a reaction object
  #-----------------------------------------------------------------------------
  def backup_actions
    @reaction_backup = @actions.dup
  end
  
  def restore_actions
    @actions = @reaction_backup.dup
  end
end

class Game_Actor < Game_Battler
  
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def reaction_objects
    super + [actor] + [self.class] + equips.compact
  end
end

class Game_Enemy < Game_Battler
  
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def reaction_objects
    super + [enemy]
  end
end

class Scene_Battle < Scene_Base
  
  alias :th_skill_reactions_invoke_item :invoke_item
  def invoke_item(target, item)
    invoke_pre_reactions(target, item)
    th_skill_reactions_invoke_item(target, item)
    invoke_post_reactions(target, item)
  end
  
  def invoke_pre_reactions(target, item)
    return if BattleManager.reaction_processing
    reactions = target.get_reactions(item).select{|react| react.pre_react? }
    invoke_reactions(reactions, target, item)
  end
  
  def invoke_post_reactions(target, item)
    return if BattleManager.reaction_processing
    reactions = target.get_reactions(item).select{|react| !react.pre_react? }
    invoke_reactions(reactions, target, item)
  end
  
  #-----------------------------------------------------------------------------
  # Create reaction actions
  #-----------------------------------------------------------------------------
  def invoke_reactions(reactions, target, item)
    return if reactions.empty?
    # back up existing actions
    target.backup_actions
    target.clear_actions
    reactions.each do |reaction|
      target.make_reaction(@subject, reaction)
    end
    perform_reactions(target, item) if target.current_action
    target.restore_actions
  end
  
  #-----------------------------------------------------------------------------
  # Perform all skill reactions
  #-----------------------------------------------------------------------------
  def perform_reactions(target, item)
    @log_window.display_reaction(target, item)
    BattleManager.reaction_processing = true
    last_subject = @subject
    @subject = target
    while @subject.current_action
      process_action
    end
    @subject = last_subject
    BattleManager.clear_reaction_processing
  end
end

class Window_BattleLog < Window_Selectable
  
  #-----------------------------------------------------------------------------
  # Informs the player that a reaction occurred
  #-----------------------------------------------------------------------------
  def display_reaction(target, item)
    add_text(sprintf(Vocab::Skill_Reaction, target.name, item.name))
    wait
  end
end 