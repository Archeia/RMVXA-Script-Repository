# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Auto-Life Effect                                      │ v1.9 │ (8/17/12) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
# Thanks:
#     Yanfly, script and design references
#     Mithran, regexp examples
#--------------------------------------------------------------------------
# This script is my attempt to replicate the well-known status effect
# "Auto-Life" a.k.a. "Reraise", "Life 3", "Lifeline", etc. in VX Ace.
# Auto-life automatically revives battlers when they are Incapacitated
# in battle.
#
# Be aware that the customization module in this script allows you to
# assign a Game Switch that disables all auto-life effects in-game. This
# is useful for evented battles.
#
# If you experience bug or oddities related to auto-life, please report 
# them to me.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.9 : Actors, Classes and Enemies can now have autolife tags. 
#      : Efficiency update. (8/17/2012)
# v1.8 : Removed debug remnant. (7/12/2012)
# v1.7 : Fixed F8 crash with YEA Battle Engine. (7/12/2012)
# v1.6 : Fixed a typo which caused an error. (7/12/2012)
# v1.5 : 'Attack Times+' issues should be fixed now. 
#      : New option added in customization module.
#      : Auto-life checks are now also done at the end of turn. (7/11/2012)
# v1.4 : Compatibility update for 'Guts Effects' (7/11/2012)
# v1.3 : Efficiency update. (7/11/2012)
# v1.2 : autolifeable flags are now reset before each battle. (7/10/2012)
# v1.1 : DISABLE_AUTOLIFE_SWITCH_ID should now work. (7/10/2012)
# v1.0 : Initial release. (7/10/2012)
#--------------------------------------------------------------------------
#   ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#
# Install this script below any scripts that modify the default 
# battle system in you script editor.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Notetags ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Note: Some tags are given shorter tags for typing convenience. You only
#       need to use one <tag> from a given group for a notebox.
#       Use common sense.
#
# The following Notetags are for Actors, Classes, States, Weapons, Armors,
# and Enemies:
#
# <autolife>
#   This tag provides an in-battle auto-life effect to the state or equipment. 
#   This tag will use all default auto-life values as defined in the 
#   customization module in this script.
#     
# <custom autolife>
# setting
# setting
# </custom autolife>
#   This tag allows you create auto-life equipment and states with custom
#   values. You can add as many settings between the <custom> tags as you
#   like. Any settings you do not include will use the default values
#   defined in the customization module. The following settings are available:
#   
#     chance: n%
#       This setting defines the chance of auto-life triggering when
#       the battler dies where n is a percentage value between 0.1 ~ 100.0.
#       
#     hp recovery: n%
#     hp: n%
#       This setting defines the amount of HP the battler recovers when
#       auto-life is triggered where n is the percentage rate recovered
#       based on MAX HP. If set to 0%, the battler will regain at least
#       1 HP.
#       
#     mp recovery: n%
#     mp: n%
#       This setting defines the amount of MP the battler recovers when
#       auto-life is triggered where n is the percentage rate recovered
#       based on MAX MP.
#       
#     animation id: id
#     ani id: id
#       This setting defines the database animation used on the battler
#       when auto-life is triggered where id is the animation ID number
#       found in your database.
#       
#     break: n%
#       This setting defines the chance of the piece of equipment breaking
#       when auto-life is triggered where n is a percentage value between 
#       0.0 ~ 100.0. This setting is only for equipment.
#       
# Here is an example of a custom autolife tag:
#
#   <custom autolife>
#   chance: 50%
#   hp: 5%
#   ani id: 41
#   </custom autolife>
#
# The settings "mp recovery" and "break" would use their default values 
# since they are not included in this example tag.
#--------------------------------------------------------------------------
#   ++ Compatibility ++
#--------------------------------------------------------------------------
# This script has built-in compatibility with the following scripts:
#
#     -Guts Effect
#     -YEA Battle Engine
#
# This script aliases the following default VXA methods:
#
#     BattleManager#judge_win_loss
#     Game_BattlerBase#initialize
#     Game_Battler#on_battle_end
#     Game_Battler#on_battle_start
#     Game_Battler#die
#     Scene_Battle#process_action
#     Scene_Battle#process_action_end
#     Scene_Battle#turn_end
#    
# There are no default method overwrites.
#
# Requests for compatibility with other scripts are welcome.
#--------------------------------------------------------------------------
#      Compatibility Notes
#--------------------------------------------------------------------------
# If 'Auto-Life Effects' and 'Guts Effects' are installed in the same
# project, auto-life effects will always take precdence over guts
# effects.
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
$imported["BubsAutoLife"] = true

#==========================================================================
# ++ START OF USER CUSTOMIZATION MODULE ++
#==========================================================================
module Bubs
  #==========================================================================
  # ++ Auto-Life Settings
  #==========================================================================
  module AutoLife
  #--------------------------------------------------------------------------
  #   Disable Auto-life Switch ID Setting     !! IMPORTANT SETTING !!
  #--------------------------------------------------------------------------
  # This setting defines the switch ID number used to determine if revival 
  # by auto-life is allowed in battle. This is useful for evented battles and
  # such. If the ID is set to 0, no game switches will be used.
  #
  # If the switch is ON, all auto-life effects are disabled.
  # If the switch is OFF, any auto-life effects are allowed.
  DISABLE_AUTOLIFE_SWITCH_ID = 0
  
  #--------------------------------------------------------------------------
  #   Default Auto-life Settings
  #--------------------------------------------------------------------------
  # These settings determine the default values for auto-life effects on
  # equipment and states.  
  AUTOLIFE_DEFAULTS = {
    :hp_rate  => 10.0,  # HP Recovery Rate (%)
    :mp_rate  => 10.0,  # MP Recovery Rate (%)
    :chance   => 100.0, # Auto-life chance (%)
    :break    => 100.0, # Item break chance, equipment only (%)
    :ani_id   => 42,    # Animation ID number
  } # <-- Do not delete.
  
  #--------------------------------------------------------------------------
  #   Check Auto-life Triggers After Each Action
  #--------------------------------------------------------------------------
  # true  : Auto-life checks can be done after each complete action.
  # false : Auto-life checks are done only at the end of turn.
  CHECK_AFTER_EACH_ACTION = true
  
  #--------------------------------------------------------------------------
  #   Auto-life Effect Text Setting
  #--------------------------------------------------------------------------
  # This setting defines the battle message that displays when auto-life 
  # successfuly triggers.
  #
  # %s is automatically replaced by the battler's name. 
  AUTOLIFE_EFFECT_TEXT = "%s resurrects!"
  
  #--------------------------------------------------------------------------
  #   Item Break Text Setting
  #--------------------------------------------------------------------------
  # This determines the message that displays when an item breaks after
  # triggering auto-life
  #
  # The first %s is automatically replaced by the battler's name. 
  # The second %s is automatically replaced by the item's name.
  ITEM_BREAK_TEXT = "%s's %s breaks!"
  
  #--------------------------------------------------------------------------
  #   Item Break Sound Effect Setting
  #--------------------------------------------------------------------------
  # This setting defines the sound effect used when the Item Break Text
  # is displayed in-battle.
  #
  #                "filename", Volume, Pitch
  ITEM_BREAK_SE = [ "Attack2",     80,   100]
  
  end # module AutoLife
end # module Bubs

#==========================================================================
# ++ END OF USER CUSTOMIZATION MODULE ++
#==========================================================================



#==============================================================================
# ++ Vocab
#==============================================================================
module Vocab
  AutoLifeItemBreak = Bubs::AutoLife::ITEM_BREAK_TEXT
  AutoLifeEffect = Bubs::AutoLife::AUTOLIFE_EFFECT_TEXT
end # module Vocab

#==============================================================================
# ++ Sound
#==============================================================================
module Sound
  def self.play_autolife_item_break
    file = Bubs::AutoLife::ITEM_BREAK_SE[0]
    volume = Bubs::AutoLife::ITEM_BREAK_SE[1]
    pitch = Bubs::AutoLife::ITEM_BREAK_SE[2]
    Audio.se_play("/Audio/SE/" + file, volume, pitch) 
  end
end # module Sound


#==========================================================================
# ++ DataManager
#==========================================================================
module DataManager
  #--------------------------------------------------------------------------
  # alias : load_database
  #--------------------------------------------------------------------------
  class << self; alias load_database_bubs_autolife load_database; end
  def self.load_database
    load_database_bubs_autolife # alias
    load_notetags_bubs_autolife
  end
  
  #--------------------------------------------------------------------------
  # new method : load_notetags_bubs_autolife
  #--------------------------------------------------------------------------
  def self.load_notetags_bubs_autolife
    groups = [$data_weapons, $data_armors, $data_states, $data_classes,
              $data_actors, $data_enemies]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_bubs_autolife
      end # for obj
    end # for group
  end # def
  
end # module DataManager


#==========================================================================
# ++ BattleManager
#==========================================================================
module BattleManager
  class << self; alias judge_win_loss_bubs_autolife judge_win_loss; end
  #--------------------------------------------------------------------------
  # alias : judge_win_loss
  #--------------------------------------------------------------------------
  def self.judge_win_loss
    if @phase
      return process_abort   if aborting?
      return false           if autolifeable_members
    end
    judge_win_loss_bubs_autolife # alias
  end
  
  #--------------------------------------------------------------------------
  # new method : autolifeable_members
  #--------------------------------------------------------------------------
  def self.autolifeable_members
    $game_party.battle_members.each do |actor|
      return true if actor.autolifeable
    end
    
    $game_troop.members.each do |enemy|
      return true if enemy.autolifeable
    end
    
    return false
  end # self
  
end # module BattleManager


#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp
    AUTOLIFE_TAG           = /<AUTO[\s-]?LIFE>/i
    AUTOLIFE_START_TAG     = /<CUSTOM[\s]?AUTO[\s-]?LIFE>/i
    AUTOLIFE_END_TAG       = /<\/CUSTOM[\s]?AUTO[\s-]?LIFE>/i
    AUTOLIFE_CHANCE_TAG    = /CHANCE:\s*([+]?\d+\.?\d*)[%％]?/i
    AUTOLIFE_BREAK_TAG     = /BREAK:\s*([+]?\d+\.?\d*)[%％]?/i
    AUTOLIFE_HP_TAG        = /HP\s*(?:RECOVERY)?:\s*([+]?\d+\.?\d*)[%％]?/i
    AUTOLIFE_MP_TAG        = /MP\s*(?:RECOVERY)?:\s*([+]?\d+\.?\d*)[%％]?/i
    AUTOLIFE_ANIMATION_TAG = /(?:ANIMATION|ANI)\s*(?:ID)?:\s*(\d+)/i
  end # module Regexp
end # module Bubs


#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
# A superclass of actor, class, skill, item, weapon, armor, enemy, and state.
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :autolife
  attr_accessor :autolife_chance
  attr_accessor :autolife_hp_recovery_rate
  attr_accessor :autolife_mp_recovery_rate
  attr_accessor :autolife_animation_id
  attr_accessor :autolife_break_chance
  #--------------------------------------------------------------------------
  # common cache : load_notetags_bubs_autolife
  #--------------------------------------------------------------------------
  def load_notetags_bubs_autolife
    @autolife = false
    @autolife_chance           = Bubs::AutoLife::AUTOLIFE_DEFAULTS[:chance]
    @autolife_break_chance     = Bubs::AutoLife::AUTOLIFE_DEFAULTS[:break]
    @autolife_hp_recovery_rate = Bubs::AutoLife::AUTOLIFE_DEFAULTS[:hp_rate]
    @autolife_mp_recovery_rate = Bubs::AutoLife::AUTOLIFE_DEFAULTS[:mp_rate]
    @autolife_animation_id     = Bubs::AutoLife::AUTOLIFE_DEFAULTS[:ani_id]
    
    autolife_tag = false

    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Bubs::Regexp::AUTOLIFE_TAG
        @autolife = true
        
      when Bubs::Regexp::AUTOLIFE_START_TAG
        @autolife = true
        autolife_tag = true
        
      when Bubs::Regexp::AUTOLIFE_END_TAG
        autolife_tag = false
        
      else
        next unless autolife_tag
        case line.upcase
        
        when Bubs::Regexp::AUTOLIFE_CHANCE_TAG
          @autolife_chance = $1.to_f
          
        when Bubs::Regexp::AUTOLIFE_BREAK_TAG
          @autolife_break_chance = $1.to_f
          
        when Bubs::Regexp::AUTOLIFE_HP_TAG
          @autolife_hp_recovery_rate = $1.to_f
          
        when Bubs::Regexp::AUTOLIFE_MP_TAG
          @autolife_mp_recovery_rate = $1.to_f
          
        when Bubs::Regexp::AUTOLIFE_ANIMATION_TAG
          @autolife_animation_id = $1.to_i

        end # case
      end # else
      
    } # self.note.split
  end # def
  
end # RPG::BaseItem


#==============================================================================
# ++ Window_BattleLog
#==============================================================================
class Window_BattleLog < Window_Selectable  
  #--------------------------------------------------------------------------
  # new method : display_guts_text
  #--------------------------------------------------------------------------
  def display_autolife_text(target)
    add_text(sprintf(Vocab::AutoLifeEffect, target.name))
    wait
  end # def display_guts_text
  
  #--------------------------------------------------------------------------
  # new method : display_autolife_item_break_text
  #--------------------------------------------------------------------------
  def display_autolife_item_break_text(target, item)
    Sound.play_autolife_item_break
    add_text(sprintf(Vocab::AutoLifeItemBreak, target.name, item.name))
    wait
  end # def display_guts_text
end # class Window_BattleLog


#==========================================================================
# ++ Game_BattlerBase
#==========================================================================
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :autolifeable         # autolife check flag
  attr_accessor :autolife_state_id    # save state id before actor dies
  #--------------------------------------------------------------------------
  # alias : initialize
  #--------------------------------------------------------------------------
  alias initialize_bubs_autolife initialize
  def initialize
    initialize_bubs_autolife # alias
    
    @autolifeable = false
    @autolife_state_id = 0
  end
end # class Game_BattlerBase


#==============================================================================
# ++ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # alias : die
  #--------------------------------------------------------------------------
  alias die_bubs_autolife die
  def die
    @autolifeable = true
    @autolife_state_id = determine_autolife_state_id
    
    die_bubs_autolife # alias
  end # def die
  
  #--------------------------------------------------------------------------
  # alias : on_battle_end
  #--------------------------------------------------------------------------
  alias on_battle_end_bubs_autolife on_battle_end
  def on_battle_end
    @autolifeable = false
    
    on_battle_end_bubs_autolife # alias
  end # def on_battle_end
  
  #--------------------------------------------------------------------------
  # alias : on_battle_start
  #--------------------------------------------------------------------------
  alias on_battle_start_bubs_autolife on_battle_start
  def on_battle_start
    @autolifeable = false
    
    on_battle_start_bubs_autolife # alias
  end # def on_battle_start

  #--------------------------------------------------------------------------
  # new method : determine_autolife_obj
  #--------------------------------------------------------------------------
  def determine_autolife_obj
    # States
    if @autolife_state_id != 0
      id = @autolife_state_id
      @autolife_state_id = 0
      return $data_states[id]
    end
    
    if actor?
      return self.actor if activate_autolife?(self.actor)
      return self.class if activate_autolife?(self.class)
      # Actor equips
      for equip in equips
        next if equip.nil?
        return equip if activate_autolife?(equip)
      end # for

    else
      return self.enemy if activate_autolife?(self.enemy)
    end
    
    return nil
  end # def determine_autolife_obj
  
  #--------------------------------------------------------------------------
  # new method : determine_autolife_state_id
  #--------------------------------------------------------------------------
  # All states are wiped out upon dying so this method returns
  # the id number of the state that successfully triggers autolife.
  def determine_autolife_state_id
    for state in states
      next if state.nil?
      return state.id if activate_autolife?(state)
    end # for
    return 0
  end
  
  #--------------------------------------------------------------------------
  # new method : apply_autolife_effects
  #--------------------------------------------------------------------------
  def apply_autolife_effects(item)
    revive
    autolife_recovery(item)
    remove_autolife_state(item)
  end
  
  #--------------------------------------------------------------------------
  # new method : remove_autolife_item
  #--------------------------------------------------------------------------
  def remove_autolife_item(item)
    return unless actor?
    discard_equip(item) if item.is_a?(RPG::EquipItem)
  end
  
  #--------------------------------------------------------------------------
  # new method : remove_autolife_state
  #--------------------------------------------------------------------------
  def remove_autolife_state(item)
    remove_state(item.id) if item.is_a?(RPG::State)
  end
  
  #--------------------------------------------------------------------------
  # new method : autolife_recovery
  #--------------------------------------------------------------------------
  def autolife_recovery(item)
    self.hp += (mhp * (item.autolife_hp_recovery_rate * 0.01)).to_i
    self.mp += (mmp * (item.autolife_mp_recovery_rate * 0.01)).to_i
  end

  #--------------------------------------------------------------------------
  # new method : autolife_disabled?
  #--------------------------------------------------------------------------
  def autolife_disabled?
    return false
  end
  
  #--------------------------------------------------------------------------
  # new method : activate_autolife?
  #--------------------------------------------------------------------------
  def activate_autolife?(item)
    return false unless item.autolife
    rand < (item.autolife_chance * 0.01)
  end

end # class Game_Battler


#==============================================================================
# ++ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # alias : process_action
  #--------------------------------------------------------------------------
  alias process_action_bubs_autolife process_action
  def process_action
    process_action_bubs_autolife # alias
    
    # process_action_end never gets called if the last party member is
    # killed by an enemy with more Action Time+ actions in queue.
    # This clears all actions of all battlers 
    if !@subject.nil? 
      if @subject.current_action && $game_party.all_dead?
        all_battle_members.each do |battler|
          battler.clear_actions
        end
      end
    end
  end # def process_action

  #--------------------------------------------------------------------------
  # alias : process_action_end
  #--------------------------------------------------------------------------
  alias process_action_end_bubs_autolife process_action_end
  def process_action_end
    if Bubs::AutoLife::CHECK_AFTER_EACH_ACTION
      process_autolife_check
    end
    
    process_action_end_bubs_autolife # alias
  end # def process_action_end
  
  #--------------------------------------------------------------------------
  # alias : turn_end
  #--------------------------------------------------------------------------
  alias turn_end_bubs_autolife turn_end
  def turn_end
    process_autolife_check
    
    turn_end_bubs_autolife # alias
  end # def turn_end
   
  #--------------------------------------------------------------------------
  # new method : process_autolife_check
  #--------------------------------------------------------------------------
  def process_autolife_check
    all_battle_members.each do |battler|
      determine_autolife(battler)
      determine_guts(battler) if $imported["BubsGuts"]
    end
  end # def process_autolife_check
  
  #--------------------------------------------------------------------------
  # new method : determine_autolife
  #--------------------------------------------------------------------------
  def determine_autolife(battler)
    return unless battler.autolifeable
    battler.autolifeable = false
    return if $game_switches[Bubs::AutoLife::DISABLE_AUTOLIFE_SWITCH_ID]
    return unless battler.dead?
    return if battler.autolife_disabled?
    obj = battler.determine_autolife_obj
    return if obj.nil?
    
    @log_window.clear
    # Display general autolife text
    @log_window.display_autolife_text(battler)
    # Heal battler
    battler.apply_autolife_effects(obj)
    @status_window.refresh
    # Play animation on battler
    show_animation([battler], obj.autolife_animation_id)
    determine_autolife_item_break(battler, obj)
    
    wait(35)
    @log_window.clear
  end # def apply_guts_effects
  
  #--------------------------------------------------------------------------
  # new method : determine_autolife_item_break
  #--------------------------------------------------------------------------
  def determine_autolife_item_break(battler, item)
    return unless item.is_a?(RPG::EquipItem) 
    return unless (rand < (item.autolife_break_chance * 0.01))
    @log_window.display_autolife_item_break_text(battler, item)
    battler.discard_equip(item)
  end
  
  #--------------------------------------------------------------------------
  # new method : clear_all_autolifeable_flags
  #--------------------------------------------------------------------------
  def clear_all_autolifeable_flags
    all_battle_members.each do |member|
      member.autolifeable = false
    end
  end

  if $imported["YEA-BattleEngine"]
  #--------------------------------------------------------------------------
  # alias : debug_kill_all
  #--------------------------------------------------------------------------
  alias debug_kill_all_bubs_autolife debug_kill_all
  def debug_kill_all
    debug_kill_all_bubs_autolife # alias
    
    clear_all_autolifeable_flags
  end
  end # if $imported["YEA-BattleEngine"]
  
end # class Scene_Battle