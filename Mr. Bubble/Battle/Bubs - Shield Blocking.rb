# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Shield Blocking                                       │ v1.2 │ (4/28/13) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
#--------------------------------------------------------------------------
# The motivation for making this script came from the awkward infatuation 
# with newbie RM users and dual-weapon wielding. Maybe there needs to be a 
# better incentive for using a shield.
#
# With that, I chose to make a script that supports blocking in battle. 
# Shield block design mechanics are borrowed from World of Warcraft. This 
# includes the now obsolete 'block value' statistic and more recent
# 'critical block' mechanic. Users have a choice of using block value to 
# reduce damage, a simple percentage reduction of damage, or a mix of both.
#
# This script introduces four new battler parameters for both actors and
# enemies:
#
#   blv : BLock Value - reduces blocked damage by a flat amount
#   blr : BLock reduction Rate - reduces damage by a percentage
#   blc : BLock Chance - percentage chance to block normally
#   cbl : Critical BLock chance - percentage chance to block critically
#   
# Additional options include negating critical hits when they are blocked.
#--------------------------------------------------------------------------
#      Changelog   
#--------------------------------------------------------------------------
# v1.2 : Bugfix: Block chance is no longer always maxed.
#      : Bugfix: Having high amounts of block value will no longer 
#      : output large, inaccurate numbers in the battle log.
#      : Compatibility Update: YEA - Ace Battle Engine.
#      : Customization options added for YEA - Ace Battle Engine. 
#      : Blocking now prevents states and other hit effects
#      : if damage is reduced to 0. (4/28/2013)
#      : Custom sound files should no longer crash the game. (4/17/2013)
# v1.1 : Bugfix: Fixed typo with $imported variable. (7/09/2012)
# v1.0 : Initial release. (7/03/2012)
#--------------------------------------------------------------------------
#      Installation   
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#
# Install below YEA - Ace Status Menu if you also have that installed.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#      Notetags   
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following Notetags are for Actors, Classes, Weapons, Armors, Enemies, 
# and States:
#
# Note: Some tags are given shorter tags for typing convenience. You only
#       need to use one <tag> from a given group for a notebox.
#
# <blocking>
# <block>
#   This tag allows the ability to block. Blocking an attack reduces damage
#   taken depending on the battler's block value (BLV) and block reduction 
#   rate (BLR). This tag is not limited to shields. Any actor, class, or 
#   piece of equipment can provide the ability to block. Enemies can
#   block too.
#
# <critical blocking>
# <critical block>
# <crit block>
#   This tag allows the critical blocking ability. Critical blocks provide a 
#   bonus to block value and block reduction rate when critical blocks occur.
#   Critical blocks take precedence over normal blocks if both occur at the
#   same time. This tag is not limited to shields. Any actor, class, or 
#   piece of equipment can provide the ability to critical block. Enemies
#   can critical block too.
#
# <block value: +n>
# <block value: -n>
#   This tag modifies block value (BLV). Block value directly subtracts 
#   damage from an attack when a block occurs. For example, if an attacker
#   does 200 damage, and a defender has 50 block value, the defender can
#   potentially reduce the damage to 150 damage if the attack is blocked.
#   Block value stacks with block reduction rate (BLR).
#
# <block reduction rate: +n%>
# <block reduction rate: -n%>
# <block rate: +n%>
# <block rate: -n%>
#   This tag modifies block reduction rate (BLR) which reduces damage by a 
#   percentage rate. For example, if BLR is 30, damage will be reduced by
#   30% when blocked. This effect stacks with block value (BLV).
#   Do not mistake "block rate" with "block chance". They are different 
#   within this script.
#   
# <block chance: +n%>
# <block chance: -n%>
#   This tag modifies normal block chance (BLC). Normal block chance
#   affects how often normal blocks occur.
#
# <critical block chance: +n%>
# <critical block chance: -n%>
# <crit block chance: +n%>
# <crit block chance: -n%>
#   This tag modifies critical block chance (CBL). Critical block chance
#   affects how often critical blocks occur.
#--------------------------------------------------------------------------
# The following Notetags are for Skills and Items only:
#
# <unblockable>
#   Items and skills with this tag are rendered unblockable. This tag will
#   only affect blocking. It has no effect on evasion, etc.
#--------------------------------------------------------------------------
#      Blocking Formula   
#--------------------------------------------------------------------------
# This is a simplified internal formula used to calculate total block 
# damage reduction:
#
#   damage = (damage - block_value) * (1 - (block_reduction_rate))
#
# Rates in VXAce are generally kept as values between 0.0 and 1.0
#
# A bonus multiplier is applied to block_value and block_reduction_rate
# when a critical block occurs.
#--------------------------------------------------------------------------
#      Compatibility   
#--------------------------------------------------------------------------
# This script has built-in compatibility with the following scripts:
#     - Yanfly Engine Ace - Ace Status Menu
#     - Yanfly Engine Ace - Ace Battle Engine
#
# This script aliases the following default VXA methods:
#
#     Game_Battler#execute_damage
#     Game_Battler#make_damage_value
#     Game_Battler#apply_guard
#     Game_Battler#item_effect_apply
#
#     Game_ActionResult#clear_hit_flags
#     Game_ActionResult#clear_damage_values
#
#     Window_BattleLog#display_hp_damage
#    
# There are no default method overwrites.
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
#     Compatibility Notes
#--------------------------------------------------------------------------
# To add the various blocking parameters to the Ace Status Menu 
# "Properties" window, add the lines:
#
#             [:blv, "Block Value"],
#             [:blr, "Block Reduction Rate"],
#             [:blc, "Block Chance"],
#             [:cbl, "Critical Block Chance"],
# 
# Under any one of the three PROPERTIES_COLUMN under Properties Window 
# Settings.
#--------------------------------------------------------------------------
#      Terms and Conditions   
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. 
# Free for non-commercial use. For commercial use, contact me first.
#
# Newest versions of this script can be found at 
#                                           http://mrbubblewand.wordpress.com/
#==============================================================================

$imported = {} if $imported.nil?
$imported["BubsBlocking"] = true

#==========================================================================
#    START OF USER CUSTOMIZATION MODULE   
#==========================================================================
module Bubs
  #==========================================================================
  #    Blocking Settings
  #==========================================================================
  module Blocking
  #--------------------------------------------------------------------------
  #   Block Parameters Vocab
  #--------------------------------------------------------------------------
  BLV_VOCAB = "BLK Value"             # Block Value
  BLR_VOCAB = "BLK Reduction Rate"    # Block Reduction Rate
  BLC_VOCAB = "BLK Chance"            # Block Chance
  CBL_VOCAB = "Crit BLK Chance"   # Critical Block Chance
  
  #--------------------------------------------------------------------------
  #   Block Parameters Vocab Abbreviations
  #--------------------------------------------------------------------------
  BLV_VOCAB_A = "BLV"    # Block Value Abbr.
  BLR_VOCAB_A = "BLR"    # Block Reduction Rate Abbr.
  BLC_VOCAB_A = "BLC"    # Block Chance Abbr.
  CBL_VOCAB_A = "CBL"    # Critical Block Chance Abbr.
  
  #--------------------------------------------------------------------------
  #   Default Blocking Armor Types
  #--------------------------------------------------------------------------
  # This setting allows you to automatically set certain Armor Type IDs
  # with the Blocking trait. Armor Type IDs can be found under the "Terms"
  # tab in the database of your project. For example, this can be useful 
  # if you have shields as an Armor Type.
  BLOCKING_ARMOR_TYPES = [5,6]
  
  #--------------------------------------------------------------------------
  #   Default Critical Blocking Armor Types
  #--------------------------------------------------------------------------
  # This setting allows you to automatically set certain Armor Type IDs
  # with the Critical Blocking trait. Armor Type IDs can be found under the 
  # "Terms" tab in the database of your project.
  #
  # Critical blocking provides a higher damage reduction effect than normal
  # blocking.
  CRITICAL_BLOCKING_ARMOR_TYPES = [6]
  
  #--------------------------------------------------------------------------
  #   Unblockable Elements Setting
  #--------------------------------------------------------------------------
  # This setting allows you to have unblockable elements for any item
  # or skill that has an Element ID listed in the array. Element ID numbers
  # can be found under the "Terms" tab in the database of your project.
  UNBLOCKABLE_ELEMENTS = []
  #--------------------------------------------------------------------------
  #   Unblockable Skill Types Setting
  #--------------------------------------------------------------------------
  # This setting allows you to have unblockable Skill Type in the event
  # you choose to make such a skill category. Skill Type ID numbers
  # can be found under the "Terms" tab in the database of your project.
  UNBLOCKABLE_SKILL_TYPES = []
  
  #--------------------------------------------------------------------------
  #   Blockable Hit Types Setting
  #--------------------------------------------------------------------------
  # This setting allows you to decide what kind of hit types are blockable 
  # Add the hit type number into the array to allow that type to be blockable.
  # 
  # 0 : Certain hits
  # 1 : Physical attacks
  # 2 : Magical attacks
  BLOCKABLE_HIT_TYPES = [1]

  #--------------------------------------------------------------------------
  #   Block Value Variance
  #--------------------------------------------------------------------------
  # This value determines the variance range for Block Value when attacks
  # are blocked. This works similarly to the variance value for items and 
  # skills. This has no effect on Block Reduction Rate.
  BLV_VARIANCE = 10
  
  #--------------------------------------------------------------------------
  #   Block Sound Effects
  #--------------------------------------------------------------------------
  # These settings allow you to choose a sound effect for normal and critical
  # blocks.
  #                    "Filename", Volume, Pitch
  NORMAL_BLOCK_SE   = ["Parry",     90,   110]   # Normal Block SE
  CRITICAL_BLOCK_SE = ["Evasion2",     90,   110]   # Critical Block SE
    
  #--------------------------------------------------------------------------
  #   Actor Default Block Parameter Formulas
  #--------------------------------------------------------------------------
  # The following settings are formulas used for producing the base values 
  # for blocking parameters. The values produced by these formulas stack 
  # with any bonuses gained from equipped items, class, states, etc.
  #
  # Formulas are made within the scope of class Game_Battler. This means
  # parameters such as (but not limited to) atk, def, level, luk, etc. can
  # be used within formulas. If you wish to use the defense parameter
  # "def", you must use the term "self.def" instead.
  #
  # Blocking-specific battler parameters may also be used:
  #   blv : BLock Value               (value range: 0~max_blv)
  #   blr : BLock reduction Rate      (value range: 0.0~1.0)
  #   blc : BLock Chance              (value range: 0.0~1.0)
  #   cbl : Critical BLock chance     (value range: 0.0~1.0)
  #
  # A value of 1.0 means 100%.
  #
  # For these formulas, :base_blr, :base_blc, and :base_cbl should 
  # produce rate values between 0~100.
  ACTOR_BLOCK_SETTINGS = {
    :base_blv => "(self.def / 5)",     # Base Block Value Formula
    :base_blr => "0",                  # Base Block Reduction Rate Formula
    :base_blc => "5",                  # Base Block Chance Formula
    :base_cbl => "(blc * 100) / 3",    # Base Critical Block Chance Formula
  
  #--------------------------------------------------------------------------
  #   Actor Maximum Block Parameter Settings
  #--------------------------------------------------------------------------
  # The following settings allow you to set maximum values for any block
  # parameters for actors.
    :max_blv => 9999,    # Maximum Block Value
    :max_blr => 100,      # Maximum Block Reduction Rate (%)
    :max_blc => 75,       # Maximum Block Chance (%)
    :max_cbl => 50,       # Maximum Critical Block Chance (%)
    
  #--------------------------------------------------------------------------
  #   Actor Critical Block Multiplier Settings
  #--------------------------------------------------------------------------
  # You can set Block Value and Block Reduction Rate multiplier for
  # actor Critical Blocks here.
    :critical_blv_multiplier => 2.0, # Block Value Crit Multiplier
    :critical_blr_multiplier => 2.0, # Block Reduction Rate Crit Multiplier
    
  #--------------------------------------------------------------------------
  #   Actor TP Gain On Block Formula
  #--------------------------------------------------------------------------
  # You may specify the formula used for TP gain whenever a block is made
  # by an actor. This setting is for advanced users.
  #
  # Data included within the scope of Game_Battler is available which 
  # includes, but is not limited to, atk, mhp, mmp, tp, tcr, etc.
  #
  # "blocked_damage" is available as a variable which holds the total
  # amount of damage that was blocked by the actor.
    :tp_gain => "40 * (blocked_damage / mhp.to_f) * tcr",
    
  #--------------------------------------------------------------------------
  #   Actor Block - Cancel Critical Hits
  #--------------------------------------------------------------------------
  # true  : Prevent critical hits when an attack is blocked.
  # false : Critical hits are not prevented.
    :cancel_critical_hits => true,
    
  #--------------------------------------------------------------------------
  #   Actor Block - In-battle Text
  #--------------------------------------------------------------------------
  # These settings allow you to change the in-battle text when a normal 
  # or critical block occurs. The first %s is the actor's name while
  # the second %s is the amount of damage blocked.
    :block_text          => "%s blocked %s damage!",            # Normal block
    :critical_block_text => "%s critically blocked %s damage!", # Critical block
    
  } # <-- Do not delete
  
  #--------------------------------------------------------------------------
  #   Enemy Default Block Parameter Formulas
  #--------------------------------------------------------------------------
  # The following settings are formulas used for producing the base values 
  # for blocking parameters. The values produced by these formulas stack 
  # with any bonuses gained from states, etc.
  #
  # Formulas are made within the scope of class Game_Battler. This means
  # parameters such as (but not limited to) atk, def, level, luk, etc. can
  # be used within formulas. If you wish to use the defense parameter
  # "def", you must use the term "self.def" instead.
  #
  # Blocking-specific battler parameters may also be used:
  #   blv : BLock Value
  #   blr : BLock Reduction rate
  #   blc : BLock Chance
  #   cbl : Critical BLock chance
  #
  # :base_blr, :base_blc, and :base_cbl should produce rate values 
  # between 0~100.
  ENEMY_BLOCK_SETTINGS = {
    :base_blv => "(self.def / 5)",  # Base Block Value Formula
    :base_blr => "0",               # Base Block Reduction Rate Formula
    :base_blc => "5",               # Base Block Chance Formula
    :base_cbl => "(blc * 100) / 3", # Base Critical Block Chance Formula
    
  #--------------------------------------------------------------------------
  #   Enemy Maximum Block Parameter Settings
  #--------------------------------------------------------------------------
  # The following settings allow you to set maximum values for any block
  # parameters for enemies.
    :max_blv => 9999,    # Maximum Block Value
    :max_blr => 75,      # Maximum Block Reduction Rate (%)
    :max_blc => 75,       # Maximum Block Chance (%)
    :max_cbl => 50,       # Maximum Critical Block Chance (%)
    
  #--------------------------------------------------------------------------
  #   Enemy Critical Block Multiplier Settings
  #--------------------------------------------------------------------------
  # You can set Block Value and Block Reduction Rate multiplier for
  # enemy Critical Blocks here.
    :critical_blv_multiplier => 2.0, # Block Value Crit Multiplier
    :critical_blr_multiplier => 2.0, # Block Reduction Rate Crit Multiplier
    
  #--------------------------------------------------------------------------
  #   Enemy TP Gain On Block Formula
  #--------------------------------------------------------------------------
  # You may specify the formula used for TP gain whenever a block is made
  # by an enemy. This setting is for advanced users.
  #
  # Data included within the scope of Game_Battler is available which 
  # includes, but is not limited to, atk, mhp, mmp, tp, tcr, etc.
  #
  # "blocked_damage" is available as a variable which holds the total
  # amount of damage that was blocked by the enemy.
    :tp_gain => "40 * (blocked_damage / mhp.to_f) * tcr",

  #--------------------------------------------------------------------------
  #   Enemy Block - Cancel Critical Hits
  #--------------------------------------------------------------------------
  # true  : Prevent critical hits when an attack is blocked.
  # false : Critical hits are not prevented.
    :cancel_critical_hits => true,

  #--------------------------------------------------------------------------
  #   Enemy Block - In-battle Text
  #--------------------------------------------------------------------------
  # These settings allow you to change the in-battle text when a normal 
  # or critical block occurs. The first %s is the enemy's name while
  # the second %s is the amount of damage blocked.
    :block_text          => "%s blocked %s damage!",            # Normal block
    :critical_block_text => "%s critically blocked %s damage!", # Critical block

  } # <-- Do not delete
  
  #--------------------------------------------------------------------------
  #   YEA - Ace Battle Engine - Block Pop-up Text
  #--------------------------------------------------------------------------
  # These settings only apply when YEA - Ace Battle Engine is installed.
  BLOCK_POPUP_TEXT          = "Blocked!"
  CRITICAL_BLOCK_POPUP_TEXT = "Critical Blocked!"
  
  end # module Blocking
end # module Bubs

#==========================================================================
#    END OF USER CUSTOMIZATION MODULE   
#==========================================================================



#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp
    module BaseItem
      CAN_BLOCK = /<(?:BLOCKING|block)>/i
      CAN_CRIT_BLOCK = /<(?:CRITICAL|crit)[\s_](?:BLOCKING|block)>/i
      BLOCK_VALUE = /<(?:BLOCK_VALUE|block value):\s*([-+]?\d+\.?\d*)>/i
      
      BLOCK_REDUCTION_RATE = 
  /<(?:BLOCK[\s_]REDUCTION|block)[\s_]rate:\s*([-+]?\d+\.?\d*)[%％]>/i
     
      BLOCK_CHANCE = 
  /<(?:BLOCK_CHANCE|block chance):\s*([-+]?\d+\.?\d*)[%％]>/i
      
      CRITICAL_BLOCK_CHANCE = 
  /<(?:CRITICAL|crit)[\s_]block[\s_]chance:\s*([-+]?\d+\.?\d*)[%％]>/i
      
    end # module BaseItem

    module UsableItem
      UNBLOCKABLE = /<?:UNBLOCKABLE|unblockable>/i
    end # module UsableItem
  end # module Regexp
end # module Bubs



#==========================================================================
# ++ DataManager
#==========================================================================
module DataManager
  #--------------------------------------------------------------------------
  # alias : load_database
  #--------------------------------------------------------------------------
  class << self; alias load_database_bubs_blocking load_database; end
  def self.load_database
    load_database_bubs_blocking # alias
    load_notetags_bubs_blocking
  end
  
  #--------------------------------------------------------------------------
  # new method : load_notetags_bubs_blocking
  #--------------------------------------------------------------------------
  def self.load_notetags_bubs_blocking
    groups = [$data_actors, $data_classes, $data_skills, $data_items, 
      $data_weapons, $data_armors, $data_enemies, $data_states]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_bubs_blocking
      end # for obj
    end # for group
  end # def
  
end # module DataManager


#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
# A superclass of actor, class, skill, item, weapon, armor, enemy, and state.
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :blocking
  attr_accessor :critical_blocking
  attr_accessor :unblockable
  attr_accessor :block_value
  attr_accessor :block_reduction_rate
  attr_accessor :block_chance
  attr_accessor :critical_block_chance
  
  #--------------------------------------------------------------------------
  # common cache : load_notetags_bubs_blocking
  #--------------------------------------------------------------------------
  def load_notetags_bubs_blocking
    @blocking = false
    @critical_blocking = false
    @unblockable = false
    @block_value = 0.0
    @block_reduction_rate = 0.0
    @block_chance = 0.0
    @critical_block_chance = 0.0
    
    default_block_settings
    
    self.note.split(/[\r\n]+/).each { |line|
      case line

      when Bubs::Regexp::BaseItem::CAN_BLOCK
        @blocking = true
        
      when Bubs::Regexp::BaseItem::CAN_CRIT_BLOCK
        @critical_blocking = true
        
      when Bubs::Regexp::BaseItem::BLOCK_VALUE
        @block_value = $1.to_f
        
      when Bubs::Regexp::BaseItem::BLOCK_REDUCTION_RATE
        @block_reduction_rate = $1.to_f
        
      when Bubs::Regexp::BaseItem::BLOCK_CHANCE
        @block_chance = $1.to_f
        
      when Bubs::Regexp::BaseItem::CRITICAL_BLOCK_CHANCE
        @critical_block_chance = $1.to_f

      end
    } # self.note.split
    
  end # def
  
  #--------------------------------------------------------------------------
  # common cache : default_block_settings
  #--------------------------------------------------------------------------
  def default_block_settings
    if self.is_a?(RPG::Armor)
      @blocking = Bubs::Blocking::BLOCKING_ARMOR_TYPES.include?(@atype_id)
      @critical_blocking = Bubs::Blocking::CRITICAL_BLOCKING_ARMOR_TYPES.include?(@atype_id)
    elsif self.is_a?(RPG::Skill)
      @unblockable = Bubs::Blocking::UNBLOCKABLE_SKILL_TYPES.include?(@stype_id)
    end # self.is_a?(RPG::Armor)
  end # def default_block_settings
end # module RPG::BaseItem



#==========================================================================
# ++ RPG::UsableItem
#==========================================================================
# The Superclass of Skill and Item.
class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # common cache : load_notetags_bubs_blocking
  #--------------------------------------------------------------------------
  def load_notetags_bubs_blocking
    @unblockable = false
    
    default_block_settings
  
    self.note.split(/[\r\n]+/).each { |line|
      case line

      when Bubs::Regexp::UsableItem::UNBLOCKABLE
        @unblockable = true
        
      end
    } # self.note.split
  end # def

end # class RPG::UsableItem



#==============================================================================
# ++ Vocab
#==============================================================================
module Vocab
  # Actor Blocking Text
  ActorBlock = Bubs::Blocking::ACTOR_BLOCK_SETTINGS[:block_text] 
  ActorCritBlock = Bubs::Blocking::ACTOR_BLOCK_SETTINGS[:critical_block_text] 
  
  # Actor Blocking Text
  EnemyBlock = Bubs::Blocking::ENEMY_BLOCK_SETTINGS[:block_text] 
  EnemyCritBlock = Bubs::Blocking::ENEMY_BLOCK_SETTINGS[:critical_block_text] 
  
  ABE_Block = Bubs::Blocking::BLOCK_POPUP_TEXT
  ABE_CritBlock =  Bubs::Blocking::CRITICAL_BLOCK_POPUP_TEXT
  
  # Block Value
  def self.blv; Bubs::Blocking::BLV_VOCAB; end
  def self.blv_a; Bubs::Blocking::BLV_VOCAB_A; end
  # Block Reduction Rate
  def self.blr; Bubs::Blocking::BLR_VOCAB; end
  def self.blr_a; Bubs::Blocking::BLR_VOCAB_A; end
  # Block Chance
  def self.blc; Bubs::Blocking::BLC_VOCAB; end
  def self.blc_a; Bubs::Blocking::BLC_VOCAB_A; end
  # Critical Block Chance
  def self.cbl; Bubs::Blocking::CBL_VOCAB; end
  def self.cbl_a; Bubs::Blocking::CBL_VOCAB_A; end
end # module Vocab
  


#==============================================================================
# ++ Sound
#==============================================================================
module Sound
  # Normal Block SE
  def self.play_block
    Audio.se_play("Audio/SE/" + Bubs::Blocking::NORMAL_BLOCK_SE[0], 
                  Bubs::Blocking::NORMAL_BLOCK_SE[1], 
                  Bubs::Blocking::NORMAL_BLOCK_SE[2]) 
  end
  # Critical Block SE
  def self.play_critical_block
    Audio.se_play("Audio/SE/" + Bubs::Blocking::CRITICAL_BLOCK_SE[0], 
                  Bubs::Blocking::CRITICAL_BLOCK_SE[1], 
                  Bubs::Blocking::CRITICAL_BLOCK_SE[2]) 
  end
end # module Sound



#==========================================================================
# ++ Game_BattlerBase
#==========================================================================
class Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # new method : actor_block_settings
  #--------------------------------------------------------------------------
  def actor_block_settings(key)
    Bubs::Blocking::ACTOR_BLOCK_SETTINGS[key]
  end
  
  #--------------------------------------------------------------------------
  # new method : enemy_block_settings
  #--------------------------------------------------------------------------
  def enemy_block_settings(key)
    Bubs::Blocking::ENEMY_BLOCK_SETTINGS[key]
  end
  
  #--------------------------------------------------------------------------
  # new method : can_block?
  #--------------------------------------------------------------------------
  def can_block?
    blocking? && movable?
  end
  
  #--------------------------------------------------------------------------
  # new method : can_critical_block?
  #--------------------------------------------------------------------------
  def can_critical_block?
    critical_blocking? && movable?
  end

  #--------------------------------------------------------------------------
  # new method : blocking?
  #--------------------------------------------------------------------------
  def blocking?
    if actor?
      return true if self.actor.blocking
      return true if self.class.blocking
      for equip in equips
        next if equip.nil?
        return true if equip.blocking
      end
    else
      return true if self.enemy.blocking
    end
    for state in states
      next if state.nil?
      return true if state.blocking
    end
    return false
  end # def blocking?
  
  #--------------------------------------------------------------------------
  # new method : critical_blocking?
  #--------------------------------------------------------------------------
  def critical_blocking?
    if actor?
      return true if self.actor.critical_blocking
      return true if self.class.critical_blocking
      for equip in equips
        next if equip.nil?
        return true if equip.critical_blocking
      end
    else
      return true if self.enemy.critical_blocking
    end
    for state in states
      next if state.nil?
      return true if state.critical_blocking
    end
    return false
  end # def critical_blocking?
  
  #--------------------------------------------------------------------------
  # new method : unblockable?        # this method is not used by default
  #--------------------------------------------------------------------------
  def unblockable?
    if actor?
      return true if self.actor.unblockable
      return true if self.class.unblockable
      for armor in armors
        next if armor.nil?
        return true if armor.unblockable
      end
    else
      return true if self.enemy.unblockable
    end
    for state in states
      next if state.nil?
      return true if state.unblockable
    end
    return false
  end # def unblockable?
  
  #--------------------------------------------------------------------------
  # new method : blv        # BLock Value
  #--------------------------------------------------------------------------
  def blv 
    n = 0.0
    if actor?
      n += Float(eval(actor_block_settings(:base_blv)))
      n += self.actor.block_value
      n += self.class.block_value
      for equip in equips
        next if equip.nil?
        n += equip.block_value
      end
    else
      n += Float(eval(enemy_block_settings(:base_blv)))
      n += self.enemy.block_value
    end
    for state in states
      next if state.nil?
      n += state.block_value
    end
    # determine maximum block value
    n = [n, blv_max].min
    n = [n, 0].max
    
    return n
  end # def blv
  #--------------------------------------------------------------------------
  # new method : blr        # BLock reduction Rate
  #--------------------------------------------------------------------------
  def blr
    n = 0.0
    if actor?
      n += Float(eval(actor_block_settings(:base_blr)))
      n += self.actor.block_reduction_rate
      n += self.class.block_reduction_rate
      for equip in equips
        next if equip.nil?
        n += equip.block_reduction_rate
      end
    else
      n += Float(eval(enemy_block_settings(:base_blr)))
      n += self.enemy.block_reduction_rate
    end
    for state in states
      next if state.nil?
      n += state.block_reduction_rate
    end
    n *= 0.01
    # determine maximum block rate
    n = [n, blr_max].min    
    n = [n, 0].max
    
    return n
  end # def blr
  
  #--------------------------------------------------------------------------
  # new method : blc        # BLock Chance
  #--------------------------------------------------------------------------
  def blc
    n = 0.0
    if actor?
      n += Float(eval(actor_block_settings(:base_blc)))
      n += self.actor.block_chance
      n += self.class.block_chance
      for equip in equips
        next if equip.nil?
        n += equip.block_chance
      end
    else
      n += Float(eval(enemy_block_settings(:base_blc)))
      n += self.enemy.block_chance
    end
    for state in states
      next if state.nil?
      n += state.block_chance
    end
    n *= 0.01
    # determine maximum block chance
    n = [n, blc_max].min
    n = [n, 0].max
    
    return n
  end # def blc
  
  #--------------------------------------------------------------------------
  # new method : cbl        # Critical BLock chance
  #--------------------------------------------------------------------------
  def cbl
    n = 0.0
    if actor?
      n += Float(eval(actor_block_settings(:base_cbl)))
      n += self.actor.critical_block_chance
      n += self.class.critical_block_chance
      for equip in equips
        next if equip.nil?
        n += equip.critical_block_chance
      end
    else
      n += Float(eval(enemy_block_settings(:base_cbl)))
      n += self.enemy.critical_block_chance
    end
    for state in states
      next if state.nil?
      n += state.critical_block_chance
    end
    n *= 0.01
    # determine maximum critical block chance
    n = [n, cbl_max].min
    n = [n, 0].max
    
    return n
  end # def cbl

  #--------------------------------------------------------------------------
  # new method : blv_max        # BLock Value
  #--------------------------------------------------------------------------
  def blv_max
    return actor_block_settings(:max_blv) if actor?
    return enemy_block_settings(:max_blv)
  end
  
  #--------------------------------------------------------------------------
  # new method : blr_max        # BLock reduction Rate
  #--------------------------------------------------------------------------
  def blr_max
    return actor_block_settings(:max_blr) * 0.01 if actor?
    return enemy_block_settings(:max_blr) * 0.01
  end
  
  #--------------------------------------------------------------------------
  # new method : blc_max        # BLock Chance
  #--------------------------------------------------------------------------
  def blc_max
    return actor_block_settings(:max_blc) * 0.01 if actor?
    return enemy_block_settings(:max_blc) * 0.01
  end
  
  #--------------------------------------------------------------------------
  # new method : cbl_max        # Critical BLock chance
  #--------------------------------------------------------------------------
  def cbl_max
    return actor_block_settings(:max_cbl) * 0.01 if actor?
    return enemy_block_settings(:max_cbl) * 0.01
  end
  
end # class Game_BattlerBase



#==============================================================================
# ++ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # alias : item_effect_apply
  #--------------------------------------------------------------------------
  alias item_effect_apply_bubs_blocking item_effect_apply
  def item_effect_apply(user, item, effect)
    return if @result.blocked? && @result.hp_damage == 0
    item_effect_apply_bubs_blocking(user, item, effect)
  end
  #--------------------------------------------------------------------------
  # alias : make_damage_value
  #--------------------------------------------------------------------------
  alias make_damage_value_bubs_blocking make_damage_value
  def make_damage_value(user, item)
    check_block(user, item)
    make_damage_value_bubs_blocking(user, item) # alias
  end
  
  #--------------------------------------------------------------------------
  # alias : apply_guard
  #--------------------------------------------------------------------------
  alias apply_guard_bubs_blocking apply_guard
  def apply_guard(damage)
    apply_block(apply_guard_bubs_blocking(damage)) # alias
  end
  
  
  #--------------------------------------------------------------------------
  # alias : execute_damage
  #--------------------------------------------------------------------------
  alias execute_damage_bubs_blocking execute_damage
  def execute_damage(user)
    execute_damage_bubs_blocking(user)
    on_block(user, @result.blocked_damage) if @result.blocked_damage > 0
  end

  #--------------------------------------------------------------------------
  # new method : apply_block
  #--------------------------------------------------------------------------
  def apply_block(damage)
    return damage unless @result.blocked || @result.critical_blocked
    damage = apply_block_value(damage)
    damage = apply_block_reduction_rate(damage)
  end
  
  #--------------------------------------------------------------------------
  # new method : blockable_hit_types
  #--------------------------------------------------------------------------
  def blockable_hit_types
    Bubs::Blocking::BLOCKABLE_HIT_TYPES
  end
  
  #--------------------------------------------------------------------------
  # new method : check_block
  #--------------------------------------------------------------------------
  def check_block(user, item)
    # Avoids block checking more than once
    return if @result.block_checked
    return unless item.damage.to_hp?
    @result.block_checked = true

    # Check for unblockable flag
    return if check_unblockable(user, item)
    
    # Do block checks and rolls
    @result.blocked = (can_block? && block?)
    @result.critical_blocked = (can_critical_block? && critical_block?)
    
    # Cancel out critical if blocked
    if @result.blocked || @result.critical_blocked
      @result.critical = false if cancel_critical_hits?
    end
  end
  
  #--------------------------------------------------------------------------
  # new method : unblockable_elements
  #--------------------------------------------------------------------------
  def unblockable_elements(element_id)
    Bubs::Blocking::UNBLOCKABLE_ELEMENTS.include?(element_id)
  end
  
  #--------------------------------------------------------------------------
  # new method : unblockable_skill_types
  #--------------------------------------------------------------------------
  def unblockable_skill_types(stype_id)
    Bubs::Blocking::UNBLOCKABLE_SKILL_TYPES.include?(stype_id)
  end
  
  #--------------------------------------------------------------------------
  # new method : check_unblockable
  #--------------------------------------------------------------------------
  def check_unblockable(user, item)
    # Unblockable attack check
    return true if item.unblockable
    # Blockable hit type check
    return true unless blockable_hit_types.include?(item.hit_type)
    # Unblockable element check
    return true if unblockable_elements(item.damage.element_id)
    # Unblockable skill type check
    return true if item.is_a?(RPG::Skill) && unblockable_skill_types(item.stype_id)
    return false
  end
  
  #--------------------------------------------------------------------------
  # new method : block?
  #--------------------------------------------------------------------------
  def block?
    rand < blc # Block roll
  end
  
  #--------------------------------------------------------------------------
  # new method : critical_block?
  #--------------------------------------------------------------------------
  def critical_block?
    rand < cbl # Critical block roll
  end
  
  #--------------------------------------------------------------------------
  # new method : apply_block_value
  #--------------------------------------------------------------------------
  def apply_block_value(damage)
    block_variance = Bubs::Blocking::BLV_VARIANCE
    block_value = apply_block_value_variance(blv, block_variance)
    return damage if block_value <= 0
    
    # Apply critical block multiplier
    block_value *= blv_multiplier if @result.critical_blocked
    # Determine min/max block value
    block_value = [[0, block_value].max, blv_max].min
    
    old_damage = damage
    damage = [damage - block_value, 0].max
    # Keep track of amount of damage blocked
    @result.blocked_damage += (old_damage - damage).to_i
    return damage
  end
  
  #--------------------------------------------------------------------------
  # new method : apply_block_reduction_rate
  #--------------------------------------------------------------------------
  def apply_block_reduction_rate(damage)
    block_rate = blr
    return damage if block_rate <= 0
    
    # Apply critical block multiplier
    block_rate *= blr_multiplier if @result.critical_blocked
    # Determine min/max block rate
    block_rate = [[0, block_rate].max, blr_max].min
    # Calculate damage rate
    block_rate = (1 - block_rate)
    old_damage = damage
    # Scale the damage
    damage *= block_rate
    # Keep track of amount of damage blocked
    @result.blocked_damage += (old_damage - damage).to_i
    
    return damage
  end
  
  #--------------------------------------------------------------------------
  # new method : apply_block_value_variance
  #--------------------------------------------------------------------------
  def apply_block_value_variance(block_value, variance)
    amp = [block_value.abs * variance / 100, 0].max.to_i
    var = rand(amp + 1) + rand(amp + 1) - amp
    block_value = block_value + var
  end
  
  #--------------------------------------------------------------------------
  # new method : blv_multiplier     # For critical blocks
  #--------------------------------------------------------------------------
  def blv_multiplier
    return actor_block_settings(:critical_blv_multiplier) if actor? 
    return enemy_block_settings(:critical_blv_multiplier)
  end
  
  #--------------------------------------------------------------------------
  # new method : blr_multiplier     # For critical blocks
  #--------------------------------------------------------------------------
  def blr_multiplier
    return actor_block_settings(:critical_blr_multiplier) if actor? 
    return enemy_block_settings(:critical_blr_multiplier)
  end
  
  #--------------------------------------------------------------------------
  # new method : cancel_critical_hits?
  #--------------------------------------------------------------------------
  def cancel_critical_hits?
    return actor_block_settings(:cancel_critical_hits) if actor? 
    return enemy_block_settings(:cancel_critical_hits)
  end
  
  #--------------------------------------------------------------------------
  # new method : tp_gain_on_block_formula
  #--------------------------------------------------------------------------
  def tp_gain_on_block_formula
    return actor_block_settings(:tp_gain) if actor? 
    return enemy_block_settings(:tp_gain)
  end
  
  #--------------------------------------------------------------------------
  # new method : charge_tp_by_block          # Charge TP by Damage Blocked
  #--------------------------------------------------------------------------
  def charge_tp_by_block(blocked_damage)
    self.tp += Float(eval(tp_gain_on_block_formula))
  end
  
  #--------------------------------------------------------------------------
  # new method : on_block            # Executes whenever damage is blocked
  #--------------------------------------------------------------------------
  def on_block(user, blocked_damage)
    charge_tp_by_block(blocked_damage)
  end

end # class Game_Battler



#==============================================================================
# ++ Game_ActionResult
#==============================================================================
class Game_ActionResult
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :blocked                  # block flag
  attr_accessor :critical_blocked         # critical block flag
  attr_accessor :blocked_damage           # total damage blocked
  attr_accessor :block_checked            # block chance check determined flag
  #--------------------------------------------------------------------------
  # alias : clear_hit_flags
  #--------------------------------------------------------------------------
  alias clear_hit_flags_bubs_blocking clear_hit_flags
  def clear_hit_flags
    clear_hit_flags_bubs_blocking # alias
    
    @blocked = false
    @critical_blocked = false
    @block_checked = false
  end
  
  #--------------------------------------------------------------------------
  # alias : clear_damage_values
  #--------------------------------------------------------------------------
  alias clear_damage_values_bubs_blocking clear_damage_values
  def clear_damage_values
    clear_damage_values_bubs_blocking # alias
    
    @blocked_damage = 0
  end
  
  #--------------------------------------------------------------------------
  # new method : blocked?
  #--------------------------------------------------------------------------
  def blocked?
    @blocked || @critical_blocked
  end
  
  #--------------------------------------------------------------------------
  # new method : block_damage_text
  #--------------------------------------------------------------------------
  def block_damage_text
    if @critical_blocked # Critical blocks
      if @battler.actor?
        fmt = Vocab::ActorCritBlock
      else
        fmt = Vocab::EnemyCritBlock
      end
      sprintf(fmt, @battler.name, @blocked_damage.to_i)
    elsif @blocked # Normal blocks
      if @battler.actor?
        fmt = Vocab::ActorBlock
      else
        fmt = Vocab::EnemyBlock
      end
      sprintf(fmt, @battler.name, @blocked_damage.to_i)
    else
      ""
    end
  end # def block_damage_text
  
end # class Game_ActionResult



#==============================================================================
# ++ Window_BattleLog
#==============================================================================
class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # alias : display_hp_damage
  #--------------------------------------------------------------------------
  alias display_hp_damage_bubs_blocking display_hp_damage
  def display_hp_damage(target, item)
    return if item && !item.damage.to_hp?
    
    display_blocked_damage(target, item)
    
    display_hp_damage_bubs_blocking(target, item) # alias
  end
  
  #--------------------------------------------------------------------------
  # alias : display_blocked_damage
  #--------------------------------------------------------------------------
  def display_blocked_damage(target, item)
    if target.result.blocked || target.result.critical_blocked
      # Play SE
      Sound.play_block if target.result.blocked
      Sound.play_critical_block if target.result.critical_blocked
      return if $imported["YEA-BattleEngine"]
      # Block battle text
      add_text(target.result.block_damage_text)
      wait
    end
  end
  
end # class Window_BattleLog



if $imported["YEA-StatusMenu"]
#==============================================================================
# ++ Window_StatusItem
#==============================================================================
class Window_StatusItem < Window_Base
  #--------------------------------------------------------------------------
  # alias : draw_property
  #--------------------------------------------------------------------------
  alias draw_property_bubs_blocking draw_property
  def draw_property(property, dx, dy, dw)
    fmt = "%1.2f%%"
    case property[0]
    #---
    when :blv
      return dy unless $imported["BubsBlocking"]
      fmt = "%d"
      value = sprintf(fmt, @actor.blv)
    when :blr
      return dy unless $imported["BubsBlocking"]
      value = sprintf(fmt, @actor.blr * 100)
    when :blc
      return dy unless $imported["BubsBlocking"]
      value = sprintf(fmt, @actor.blc * 100)
    when :cbl
      return dy unless $imported["BubsBlocking"]
      value = sprintf(fmt, @actor.cbl * 100)
    #---
    else
      return draw_property_bubs_blocking(property, dx, dy, dw) # alias
    end
    colour = Color.new(0, 0, 0, translucent_alpha/2)
    rect = Rect.new(dx+1, dy+1, dw-2, line_height-2)
    contents.fill_rect(rect, colour)
    change_color(system_color)
    draw_text(dx+4, dy, dw-8, line_height, property[1], 0)
    change_color(normal_color)
    draw_text(dx+4, dy, dw-8, line_height, value, 2)
    return dy + line_height
  end
end # class Window_StatusItem

end # if $imported["YEA-StatusMenu"]



if $imported["YEA-BattleEngine"]
#==============================================================================
# ++ Game_BattlerBase
#==============================================================================
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # compatibility alias : make_miss_popups
  #--------------------------------------------------------------------------
  alias make_miss_popups_bubs_blocking make_miss_popups
  def make_miss_popups(user, item)
    make_miss_popups_bubs_blocking(user, item) # alias
    
    if @result.hit? && @result.blocked?
      text = Vocab::ABE_Block
      text = Vocab::ABE_CritBlock if @result.critical_blocked
      rules = "DEFAULT"
      create_popup(text, rules)
    end
  end
end # class Game_BattlerBase

end # if $imported["YEA-BattleEngine"]