# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Blue Magic                                            │ v1.1 │ (4/27/13) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
#--------------------------------------------------------------------------
# This script is based off the concept of "Blue Magic" from the Final Fantasy 
# series. Blue Magic is the ability to use skills originally cast by enemies. 
# Those who have the talent to cast Blue Magic are called Blue Mages.
#
# This script is meant to serve a base script for future scripts also based
# off the concept of Blue Magic/Blue Mages.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.1 : Custom sound effects should no longer crash the game. (4/27/2013)
# v1.0 : Initial release. (7/29/2012)
#--------------------------------------------------------------------------
#   ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Notetags ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Note: Some tags are given shorter tags for typing convenience. You only
#       need to use one <tag> from a given group for a notebox. 
#       Use common sense.
#
# The following Notetag is for Skills only:
#
# <blue magic>
#   This tag flags the skill as Blue Magic. Actors capable of learning
#   Blue Magic will learn the skill when directly hit by it.
#
#--------------------------------------------------------------------------
# The following Notetag is for Actors, Classes, Weapons, Armors, and States:
#
# <blue magic: learning>
#   This tag allows an Actor to learn Blue Magic skills when hit by them.
#   If a Class has this tag, then an Actor must be that class to learn
#   Blue Magic. If a Weapon or Armor has this tag, an Actor must equip 
#   it to take effect. If a State has this tag then an Actor must be 
#   inflicted by that state. Any Blue Magic learning notifications in
#   battle are shown after an action is complete.
#
#--------------------------------------------------------------------------
#   ++ Compatibility ++
#--------------------------------------------------------------------------
# This script aliases the following default VXA methods:
#
#     DataManager#load_database
#     Game_ActionResult#clear
#     Game_Battler#item_apply
#     Scene_Battle#process_action_end
#     Scene_Battle#use_item
#    
# There are no default method overwrites.
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
#   ++ Terms and Conditions ++
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. 
# Free for non-commercial use. For commercial use, contact me first.
#
# Newest versions of this script can be found at 
#                                           http://mrbubblewand.wordpress.com/
#==============================================================================

$imported ||= {}
$imported["BubsBlueMagic"] = true

#==========================================================================
# ++ START OF USER CUSTOMIZATION MODULE ++
#==========================================================================
module Bubs
  #==========================================================================
  # ++ Blue Magic Settings
  #==========================================================================
  module BlueMagic
  #--------------------------------------------------------------------------
  #   Alternative Blue Magic Learning Methods
  #--------------------------------------------------------------------------
  # Be default, actors capable of learning Blue Magic will learn new spells
  # by being directly hit by Blue Magic spells cast by enemies. These 
  # settings determine the alternative methods in which actors can learn 
  # Blue Magic. 
  #
  # true  : Actors can learn Blue Magic regardless of who it hits.
  # false : Actors must be hit directly with Blue Magic to learn.
  LEARN_BY_SIGHT = false
  # true  : Actors can learn Blue Magic cast by other actors.
  # false : Actors can only learn Blue Magic from enemies.
  LEARN_BY_ALLIES = false
  
  #--------------------------------------------------------------------------
  #   Blue Magic Learned Battle Message
  #--------------------------------------------------------------------------
  # This defines the message displayed in battle when an actor learns a
  # Blue Magic skill.
  #
  # The first %s is automatically replaced by the actor's name.
  # The second %2 is automatically replaced by the skill's name.
  BLUE_MAGIC_LEARNED_MESSAGE = "%s learned %s."
  
  #--------------------------------------------------------------------------
  #   Blue Magic Learned Sound Effect
  #--------------------------------------------------------------------------
  # Sound effect played when the Blue Magic learned message is displayed.
  # Filename is a sound effect found in the Audio/SE/ folder.
  #
  #                        "filename", volume, pitch
  BLUE_MAGIC_LEARNED_SE = [  "Chime2",     80,   100]
  
  #--------------------------------------------------------------------------
  #   Blue Magic Message Wait
  #--------------------------------------------------------------------------
  # This setting determines how long the Blue Magic learned message is
  # displayed in battle. Higher values increase the wait time.
  BLUE_MAGIC_LEARNED_MESSAGE_WAIT = 3

  end # module BlueMagic
end # module Bubs

#==========================================================================
# ++ END OF USER CUSTOMIZATION MODULE ++
#==========================================================================




#==============================================================================
# ++ Sound
#==============================================================================
module Sound
  #--------------------------------------------------------------------------
  # new method : play_blue_magic_learned
  #--------------------------------------------------------------------------
  def self.play_blue_magic_learned
    filename = Bubs::BlueMagic::BLUE_MAGIC_LEARNED_SE[0]
    volume = Bubs::BlueMagic::BLUE_MAGIC_LEARNED_SE[1]
    pitch = Bubs::BlueMagic::BLUE_MAGIC_LEARNED_SE[2]
    Audio.se_play("Audio/SE/" + filename, volume, pitch) 
  end
  
end # module Sound


#==========================================================================
# ++ DataManager
#==========================================================================
module DataManager
  #--------------------------------------------------------------------------
  # alias : load_database
  #--------------------------------------------------------------------------
  class << self; alias load_database_bubs_bluemagic load_database; end
  def self.load_database
    load_database_bubs_bluemagic # alias
    load_notetags_bubs_bluemagic
  end
  
  #--------------------------------------------------------------------------
  # new method : load_notetags_bubs_bluemagic
  #--------------------------------------------------------------------------
  def self.load_notetags_bubs_bluemagic
    groups = [$data_skills, $data_weapons, $data_armors, $data_actors,
              $data_states, $data_classes, $data_enemies, $data_items]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_bubs_bluemagic
      end # for obj
    end # for group
  end # def
  
end # module DataManager


#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp
    BLUE_MAGIC_SKILL_TAG = /<BLUE[_\s]?MAGIC>/i
    BLUE_MAGIC_LEARNING_TAG = /<BLUE[_\s]?MAGIC:\s*LEARNING>/i
    
  end # module Regexp
end # module Bubs


#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :blue_magic
  attr_accessor :blue_magic_learning
  #--------------------------------------------------------------------------
  # common cache : load_notetags_bubs_bluemagic
  #--------------------------------------------------------------------------
  def load_notetags_bubs_bluemagic
    @blue_magic = false if self.is_a?(RPG::UsableItem)
    @blue_magic_learning = false unless self.is_a?(RPG::UsableItem)

    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Bubs::Regexp::BLUE_MAGIC_SKILL_TAG
        next unless self.is_a?(RPG::Skill)
        @blue_magic = true
        
      when Bubs::Regexp::BLUE_MAGIC_LEARNING_TAG
        next if self.is_a?(RPG::UsableItem)
        @blue_magic_learning = true
        
      end # case
    } # self.note.split
  end # def load_notetags_bubs_bluemagic
end # class RPG::BaseItem


#==============================================================================
# ++ Window_BattleLog
#==============================================================================
class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # new method : display_learned_blue_magic
  #--------------------------------------------------------------------------
  def display_learned_blue_magic(actor)
    id = actor.result.blue_magic_skill_to_learn
    fmt = Bubs::BlueMagic::BLUE_MAGIC_LEARNED_MESSAGE
    add_text( sprintf(fmt, actor.name, $data_skills[id].name) )
    Sound.play_blue_magic_learned
    
    Bubs::BlueMagic::BLUE_MAGIC_LEARNED_MESSAGE_WAIT.times do wait end
    wait_for_effect
  end
end


#==============================================================================
# ++ Game_ActionResult
#==============================================================================
class Game_ActionResult
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :blue_magic_skill_to_learn
  #--------------------------------------------------------------------------
  # alias : clear
  #--------------------------------------------------------------------------
  alias clear_bubs_bluemagic clear
  def clear
    clear_bubs_bluemagic # alias
    
    @blue_magic_skill_to_learn = 0
  end
end


#==============================================================================
# ++ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # alias : item_apply
  #--------------------------------------------------------------------------
  alias item_apply_bubs_bluemagic item_apply
  def item_apply(user, item)
    item_apply_bubs_bluemagic(user, item) # alias
    
    if blue_magic_learning_ok?(user, item)
      @result.blue_magic_skill_to_learn = item.id
    end
  end
  
  #--------------------------------------------------------------------------
  # new method : blue_magic_learning_ok?
  #--------------------------------------------------------------------------
  def blue_magic_learning_ok?(user, item)
    item.blue_magic && blue_magic_learning? && @result.hit? &&
    blue_magic_learn_by_allies?(user)
  end
  
  #--------------------------------------------------------------------------
  # new method : blue_magic_learning?
  #--------------------------------------------------------------------------
  def blue_magic_learning?
    if actor?
      return true if self.actor.blue_magic_learning
      return true if self.class.blue_magic_learning
      for equip in equips
        next if equip.nil?
        return true if equip.blue_magic_learning
      end
      for state in states
        next if state.nil?
        return true if state.blue_magic_learning
      end
    end
    return false
  end # def blue_magic_learning?
  
  #--------------------------------------------------------------------------
  # new method : blue_magic_learn_by_allies?
  #--------------------------------------------------------------------------
  def blue_magic_learn_by_allies?(user)
    if user.actor?
      return Bubs::BlueMagic::LEARN_BY_ALLIES
    else
      return true
    end
  end # def

end # class Game_Battler


#==============================================================================
# ++ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # new method : new_blue_magic_skill_learned?
  #--------------------------------------------------------------------------
  def new_blue_magic_skill_learned?
    skill_id = @result.blue_magic_skill_to_learn
    return false unless blue_magic_learning?
    return false unless skill_id > 0
    return false if skill_learn?($data_skills[skill_id])
    learn_skill(skill_id)
    return true
  end
  
  #--------------------------------------------------------------------------
  # new method : blue_magic_skills
  #--------------------------------------------------------------------------
  # returns an array of Blue Magic skill ids learned by the battler
  def blue_magic_skills
    @skills.select { |id| $data_skills[id].blue_magic }
  end
  
  #--------------------------------------------------------------------------
  # new method : learnable_blue_magic_from_target
  #--------------------------------------------------------------------------
  def learnable_blue_magic_from_target(target)
    target.blue_magic_skills.select { |id| !@skills.include?(id) }
  end

end # class Game_Actor


#==============================================================================
# ++ Game_Enemy
#==============================================================================
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # new method : blue_magic_skills
  #--------------------------------------------------------------------------
  # returns an array of Blue Magic skill ids learned by the battler
  def blue_magic_skills
    skill_ids = enemy.actions.collect { |action| action.skill_id }
    skill_ids.uniq!.select! { |id| $data_skills[id].blue_magic }
  end

end # class Game_Enemy


#==============================================================================
# ++ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # alias : process_action_end
  #--------------------------------------------------------------------------
  # Checks all Blue Magic learn flags and displays message if found
  alias process_action_end_bubs_bluemagic process_action_end
  def process_action_end
    $game_party.members.each do |actor|
      if actor.new_blue_magic_skill_learned?
        @log_window.display_learned_blue_magic(actor)
        @log_window.clear
      end
    end
    process_action_end_bubs_bluemagic # alias
  end
  
  #--------------------------------------------------------------------------
  # alias : use_item
  #--------------------------------------------------------------------------
  alias use_item_bubs_bluemagic use_item
  def use_item
    use_item_bubs_bluemagic # alias
        
    item = @subject.current_action.item 
    determine_blue_magic_learn_by_sight(@subject, item)
  end # def

  #--------------------------------------------------------------------------
  # new method : determine_blue_magic_learn_by_sight
  #--------------------------------------------------------------------------
  def determine_blue_magic_learn_by_sight(subject, item)
    return unless Bubs::BlueMagic::LEARN_BY_SIGHT
    return unless item.blue_magic && subject
    return unless blue_magic_learn_by_allies?(subject)
    all_battle_members.each do |member|
      if member.result.hit?
        set_blue_magic_skill_to_learn_flags(item)
        break
      end # if
    end # do
  end # def
    
  #--------------------------------------------------------------------------
  # new method : set_blue_magic_skill_to_learn_flags
  #--------------------------------------------------------------------------
  def set_blue_magic_skill_to_learn_flags(item)
    $game_party.members.each do |actor|
      if actor.blue_magic_learning?
        actor.result.blue_magic_skill_to_learn = item.id
      end # if
    end # do
  end # def
    
  #--------------------------------------------------------------------------
  # new method : blue_magic_learn_by_allies?
  #--------------------------------------------------------------------------
  def blue_magic_learn_by_allies?(subject)
    if subject.actor?
      return Bubs::BlueMagic::LEARN_BY_ALLIES
    else
      return true
    end
  end # def
  
end # class Scene_Battle