# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Guts Effect                                           │ v1.3 │ (7/12/12) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
# Thanks:
#     Yanfly, script and design references
#--------------------------------------------------------------------------
# Those who have played games from the Breath of Fire console-RPG series 
# may be familiar with the uncommon "Guts" gameplay mechanic. Guts is a 
# hidden parameter that provides a chance to automatically revive 
# immediately after being incapacitated.
#
# This script provides minimal developer options for modifying the
# actual Guts stat in-game. For the most part, I expect people to just 
# use the <gain guts: n> tag and 'add_actor_guts' script call. But if 
# there is another way you'd like Guts to be modified, feel free
# to suggest it.
#
# Please report any odd behavior involving triggered guts effects 
# in-battle.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.3 : Fixed F8 crash with YEA Battle Engine. (7/12/2012)
# v1.2 : Fixed a typo which caused an error. (7/12/2012)
# v1.1 : 'Attack Times+' issues should be fixed now. 
#      : New option added in customization module.
#      : Guts checks are now also done at the end of turn. (7/11/2012)
# v1.0 : Initial release. (7/11/2012)
#--------------------------------------------------------------------------
#   ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#
# Install this script below any scripts that modify the default 
# battle system in you script editor.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Notetags ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Note: Some tags are given shorter tags for typing convenience. You only
#       need to use one <tag> from a given group for a notebox.
#
# The following Notetags are for Classes, Weapons, Armors, Enemies, 
# and States:
#
# <guts: +n>
# <guts: -n>
#   This tag lets classes, weapons, armors, and states modify guts parameter 
#   where n is a negative or positive value. This only affects battlers if 
#   they have the item equipped, state inflicted, etc. It will not permanently 
#   affect battler base guts similar to regular stats.
#--------------------------------------------------------------------------
# The following Notetags are for Skills and Items only:
#
# <grow guts: +n>
# <grow guts: -n>
#   This tag is only for items and skills. This will allow the item to 
#   permanently modify the target's guts parameter where n is a negative
#   or positive value. To avoid potential gameplay oddities, this effect
#   will not work on enemies.
#--------------------------------------------------------------------------
# The following Notetags are for Actors and Enemies only:
#
# <custom guts>
# setting
# setting
# </custom guts>
#   This tag allows you to define custom initial values for actor and 
#   enemy guts-related parameters. You can add as many settings between
#   the <custom guts> tags as you like. Any settings that are omitted 
#   will use the default values as defined in the customization module
#   in this script. The following settings are available:
#   
#     base: n
#       This setting defines the base guts value for the actor or enemy
#       at the start of the game where n is a positive number value.
#       
#     text: message
#     text: key
#       This setting defines the battler's personal in-battle guts text
#       where message is a string of characters. %s can be used within
#       the messages, but it is not required. %s is automatically
#       replaced by the battler's name.     
#
#       'text: key' is an alternative to 'text: message'. This setting 
#       defines the battler's personal in-battle guts text where key is 
#       the name of a key defined in PRESET_GUTS_MESSAGES which is found 
#       in the customization module of this script. 
#       
#     reduce: -n
#       This setting defines the amount of guts the battler will 
#       permanently lose when guts is triggered where n should be a 
#       negative number value. n can be positive, but it is not
#       recommended.
#       
#     animation id: id
#     ani id: id
#       This setting defines the database animation used on the battler
#       when guts is triggered where id is the animation ID number
#       found in your database.
#
#     hp recovery: n%
#     hp: n%
#       This setting defines the amount of HP the battler recovers when
#       guts is triggered where n is the percentage rate recovered
#       based on MAX HP. If set to 0%, the battler will regain at least
#       1 HP.
#
# Here are some examples of custom guts tags:
#
#   <custom guts>
#   base: 10
#   text: %s: I won't lose!
#   reduce: -40
#   ani id: 39
#   </custom guts>
#
# Since "hp recovery" is omitted from this example tag, it will instead
# use the default value as defined in the customization module of
# this script.
#
#   <custom guts>
#   base: 20
#   text: preset3
#   </custom guts>
#
# This tag is an example of how you can use pre-defined guts messages
# for the 'text' setting.
#
# If an actor is added to the party with the "Change Party Member" event 
# command and the "Initialize" box is checked, the actor's guts-related 
# parameters will reset to what is defined in this tag along with
# any other default values.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Script Calls ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following script calls are meant to be used in "Script..."
# event commands found under Tab 3 when adding a new event command.
#
# add_actor_guts(actor_id, value)
#   This script call permanently modifies an actor's guts parameter where 
#   actor_id is an actor ID number from your database. value can be negative 
#   or positive. Actor guts values cannot exceed the maximum defined guts 
#   value or drop below 0.
#--------------------------------------------------------------------------
#   ++ Compatibility ++
#--------------------------------------------------------------------------
# This script has built-in compatibility the following scripts:
#
#     -Auto-Life Effect
#     -YEA Battle Engine
#
# This script aliases the following default VXA methods:
#
#     BattleManager#judge_win_loss
#
#     Game_BattlerBase#initialize
#
#     Game_Battler#die
#     Game_Battler#on_battle_end
#     Game_Battler#on_battle_start
#     Game_Battler#item_apply
#
#     Scene_Battle#process_action
#     Scene_Battle#process_action_end
#     Scene_Battle#turn_end
#
#     Game_Interpreter#command_129
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

$imported = {} if $imported.nil?
$imported["BubsGuts"] = true

#==========================================================================
# ++ START OF USER CUSTOMIZATION MODULE ++
#==========================================================================
module Bubs
  #==========================================================================
  # ++ Guts Settings
  #==========================================================================
  module Guts
  #--------------------------------------------------------------------------
  #   Guts Parameter Vocab
  #--------------------------------------------------------------------------
  GUTS_VOCAB   = "Guts" # Guts full name
  GUTS_VOCAB_A = "GUT"  # Guts abbreviation
  
  #--------------------------------------------------------------------------
  #   Disable Guts Switch ID Setting     !! IMPORTANT SETTING !!
  #--------------------------------------------------------------------------
  # This setting defines the switch ID number used to determine if revival 
  # by guts is allowed in battle. This is useful for evented battles and
  # such. If the ID is set to 0, no game switches will be used.
  #
  # If the switch is ON, revival by guts is disabled.
  # If the switch is OFF, revival by guts is allowed.
  DISABLE_GUTS_SWITCH_ID = 0
  
  #--------------------------------------------------------------------------
  #   Check Guts Triggers After Each Action
  #--------------------------------------------------------------------------
  # true  : Guts checks can be done after each complete action.
  # false : Guts checks are done only at the end of turn.
  CHECK_AFTER_EACH_ACTION = true
  
  #--------------------------------------------------------------------------
  #   Maximum Guts Value
  #--------------------------------------------------------------------------
  # This setting defines the maximum amount of guts an actor or enemy
  # can absolutely obtain.
  GUTS_MAX = 255
  
  #--------------------------------------------------------------------------
  #   Guts Chance Formula
  #--------------------------------------------------------------------------
  # This setting determines the formula used when determining the chance
  # for guts to trigger. Available methods include, but is not limited to:
  #
  # guts : The battler's personal guts value.
  # guts_max : The maximum possible guts value as defined by GUTS_MAX.
  #
  # The value this formula produces should be between 0.0 and 1.0.
  GUTS_CHANCE_FORMULA = "guts / guts_max"
  
  #--------------------------------------------------------------------------
  #   Guts Effect Text
  #--------------------------------------------------------------------------
  # This setting defines the text that is displayed in the battle log when
  # a battler successfully triggers guts. This text is displayed before the 
  # actor's/enemy's personal message.
  #
  # %s is automatically replaced by the actor or enemy name (but is not
  # required).
  GUTS_EFFECT_TEXT = "%s recovers with willpower."
  
  #--------------------------------------------------------------------------
  #   Guts Sound Effect Settings
  #--------------------------------------------------------------------------
  # This sound effect plays when the general guts text is displayed.
  #                 "filename", Volume, Pitch
  GUTS_EFFECT_SE = ["Recovery",     80,  100]
  #--------------------------------------------------------------------------
  #   Guts Personal Text Sound Effect Settings
  #--------------------------------------------------------------------------
  # This sound effect plays when the actor's/enemy's personal text is 
  # displayed.
  #                       "filename", Volume, Pitch
  PERSONAL_GUTS_TEXT_SE = [    "Miss",    100,  130]

#==========================================================================
#   Guts Default Settings
#==========================================================================
# The default settings within the hash below will be used if a 
# <custom guts> tag is not found in the actor's or enemy's notebox.
  GUTS_DEFAULTS = {
  #--------------------------------------------------------------------------
  #   Default Base Guts Values
  #--------------------------------------------------------------------------
  # These settings define the base guts value for actors and enemies
  # at the start of the game
    :actor_guts_base => 5.0,  # Actor Base Guts
    :enemy_guts_base => 0.0,  # Enemy Base Guts
    
  #--------------------------------------------------------------------------
  #   Default Guts Reduction on Trigger (Actors only)
  #--------------------------------------------------------------------------
  # When an actor successfully triggers guts, you can reduce the actor's
  # guts stat permanently by a set amount. This will only reduce the actor's 
  # guts stat. This will not affect equipment, states, etc. on the actor.
  # This will not reduce an actor's guts stat to below 0.
    :guts_reduce => -32,
    
  #--------------------------------------------------------------------------
  #   Default Personal Guts Text on Trigger
  #--------------------------------------------------------------------------
  # This setting defines the default personal message used when guts is
  # triggered. If the string is empty, a personal quote will not
  # be displayed.
  #
  # %s is automatically replaced by the actor's name.
    :actor_guts_text => "%s: I won't lose!",  # Actor Text
    :enemy_guts_text => "",                   # Enemy Text
    
  #--------------------------------------------------------------------------
  #   Default Guts HP Recovery
  #--------------------------------------------------------------------------
    :hp_rate => 1.0, # HP Recovery Rate, 0.0 ~ 100.0 (%)
  #--------------------------------------------------------------------------
  #   Default Guts Animation ID
  #--------------------------------------------------------------------------
    :guts_ani => 42, # Animation ID number
    
  } # <-- Do not delete.
  
  #--------------------------------------------------------------------------
  #   Pre-set Guts Messages
  #--------------------------------------------------------------------------
  # This setting allows you to create custom pre-set text messages for use in
  # <custom guts> notetags. The standard format for a pre-set in this hash 
  # is:
  #
  #       :key => "string",
  #
  # :key can be any kind of name as long as it is preceeded by a colon (:)
  # 
  # %s will automatically be replaced by the battler's name (but is not
  # required).
  PRESET_GUTS_MESSAGES = {
    :preset1 => "%s: Heh, guess I slipped...",
    :preset2 => "%s: OK, now I'm angry!",
    :preset3 => "%s: Don't count me out yet!",
    :preset4 => "%s: Hey! That hurt!",
    :preset5 => "%s: Wheeeeeeeeep!",
    :preset6 => "%s: Was that supposed to hurt?",
    :nothing => "",
  # You can create more presets within this hash.
    
  } # <-- Do not delete.
  end # module Guts
end # module Bubs

#==========================================================================
# ++ END OF USER CUSTOMIZATION MODULE ++
#==========================================================================



#==============================================================================
# ++ Vocab
#==============================================================================
module Vocab
  GutsEffectText = Bubs::Guts::GUTS_EFFECT_TEXT
  
  def self.guts; Bubs::Guts::GUTS_VOCAB; end
  def self.guts_a; Bubs::Guts::GUTS_VOCAB_A; end
end # module Vocab

#==============================================================================
# ++ Sound
#==============================================================================
module Sound
  # General Guts Text SE
  def self.play_guts_effect
    Audio.se_play("/Audio/SE/" + Bubs::Guts::GUTS_EFFECT_SE[0], 
                  Bubs::Guts::GUTS_EFFECT_SE[1], 
                  Bubs::Guts::GUTS_EFFECT_SE[2]) 
  end
  # Battler Guts Text SE
  def self.play_guts_text
    Audio.se_play("/Audio/SE/" + Bubs::Guts::PERSONAL_GUTS_TEXT_SE[0], 
                  Bubs::Guts::PERSONAL_GUTS_TEXT_SE[1], 
                  Bubs::Guts::PERSONAL_GUTS_TEXT_SE[2]) 
  end
end # module Sound


#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp
    module BaseItem
      GUTS_START = /<CUSTOM\s*GUTS>/i
      GUTS_END   = /<\/CUSTOM\s*GUTS>/i
      
      GUTS_PLUS = /<(?:GAIN)?[\s_]?GUTS:\s*([-+]?\d+\.?\d*)>/i
    end # module BaseItem
  end # module Regexp
end # module Bubs


#==========================================================================
# ++ DataManager
#==========================================================================
module DataManager
  #--------------------------------------------------------------------------
  # alias : load_database
  #--------------------------------------------------------------------------
  class << self; alias load_database_bubs_guts load_database; end
  def self.load_database
    load_database_bubs_guts # alias
    load_notetags_bubs_guts
  end
  
  #--------------------------------------------------------------------------
  # new method : load_notetags_bubs_guts
  #--------------------------------------------------------------------------
  def self.load_notetags_bubs_guts
    groups = [$data_actors, $data_classes, $data_items, $data_skills,
      $data_weapons, $data_armors, $data_enemies, $data_states]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_bubs_guts
      end # for obj
    end # for group
  end # def
  
end # module DataManager


#==========================================================================
# ++ BattleManager
#==========================================================================
module BattleManager
  class << self; alias judge_win_loss_bubs_guts judge_win_loss; end
  #--------------------------------------------------------------------------
  # alias : judge_win_loss
  #--------------------------------------------------------------------------
  def self.judge_win_loss
    if @phase
      return process_abort   if aborting?
      return false           if gutsable_members
    end
    judge_win_loss_bubs_guts # alias
  end
  
  #--------------------------------------------------------------------------
  # new method : gutsable_members
  #--------------------------------------------------------------------------
  def self.gutsable_members
    $game_party.battle_members.each do |actor|
      return true if actor.gutsable
    end
    
    $game_troop.members.each do |enemy|
      return true if enemy.gutsable
    end
    
    return false
  end
  
end # module BattleManager


#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
# A superclass of actor, class, skill, item, weapon, armor, enemy, and state.
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :guts_param
  attr_accessor :guts_text
  attr_accessor :guts_reduce
  attr_accessor :guts_animation
  attr_accessor :guts_hp_recovery_rate
  
  #--------------------------------------------------------------------------
  # common cache : load_notetags_bubs_guts
  #--------------------------------------------------------------------------
  def load_notetags_bubs_guts
    @guts_param = 0.0
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      
      when Bubs::Regexp::BaseItem::GUTS_PLUS
        @guts_param = $1.to_f
        
      end # case
    } # self
    
    load_battler_notetags_bubs_guts if self.is_a?(RPG::Actor) || self.is_a?(RPG::Enemy)
  end 
  
  #--------------------------------------------------------------------------
  # common cache : load_battler_notetags_bubs_guts
  #--------------------------------------------------------------------------
  def load_battler_notetags_bubs_guts
    @guts_text             = ""
    @guts_reduce           = Bubs::Guts::GUTS_DEFAULTS[:guts_reduce]
    @guts_animation        = Bubs::Guts::GUTS_DEFAULTS[:guts_ani]
    @guts_hp_recovery_rate = Bubs::Guts::GUTS_DEFAULTS[:hp_rate]
    
    guts_tag = false
    
    if self.is_a?(RPG::Actor)
      @guts_param          = Bubs::Guts::GUTS_DEFAULTS[:actor_guts_base] 
      @guts_text           = Bubs::Guts::GUTS_DEFAULTS[:actor_guts_text]
    elsif self.is_a?(RPG::Enemy)
      @guts_param          = Bubs::Guts::GUTS_DEFAULTS[:enemy_guts_base] 
      @guts_text           = Bubs::Guts::GUTS_DEFAULTS[:enemy_guts_text]
    end
    
    self.note.split(/[\r\n]+/).each { |line|
      case line

      when Bubs::Regexp::BaseItem::GUTS_START
        guts_tag = true
        
      when Bubs::Regexp::BaseItem::GUTS_END
        guts_tag = false
      
      else
        next unless guts_tag
        case line
        
        when /BASE:\s*[+]?(\d+)/i
          @guts_param = $1.to_f
          
        when /TEXT:\s*(.*)\s*/i
          if Bubs::Guts::PRESET_GUTS_MESSAGES[$1.to_sym]
            @guts_text = Bubs::Guts::PRESET_GUTS_MESSAGES[$1.to_sym]
          else
            @guts_text = $1
          end
        when /REDUCE:\s*([-+]?\d+\.?\d*)/i
          @guts_reduce = $1.to_f
          
        when /(?:ANIMATION|ANI)\s*id:\s*(\d+)/i
          @guts_animation = $1.to_i
          
        when /HP\s*(?:RECOVERY)?:\s*([+]?\d+\.?\d*)[%％]?/i
          @guts_hp_recovery_rate = $1.to_f
          
        end # case
      end # case
    } # self.note.split
  end # def
end # RPG::BaseItem


#==============================================================================
# ++ Window_BattleLog
#==============================================================================
class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # new method : display_guts_effect_text
  #--------------------------------------------------------------------------
  def display_guts_effect_text(target)
    Sound.play_guts_effect
    add_text(sprintf(Vocab::GutsEffectText, target.name))
  end
  
  #--------------------------------------------------------------------------
  # new method : display_guts_text
  #--------------------------------------------------------------------------
  def display_guts_text(target)
    Sound.play_guts_text
    add_text(sprintf(target.personal_guts_text, target.name))
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
  attr_accessor :gutsable       # guts check flag
  #--------------------------------------------------------------------------
  # alias : initialize
  #--------------------------------------------------------------------------
  alias initialize_bubs_guts initialize
  def initialize
    @gutsable = false

    initialize_bubs_guts # alias    
  end
  
  #--------------------------------------------------------------------------
  # new method : gut
  #--------------------------------------------------------------------------
  def gut
    n = 0.0
    if actor?
      n += self.actor.guts_param
      n += self.class.guts_param
      for equip in equips
        next if equip.nil?
        n += equip.guts_param
      end
    else
      n += self.enemy.guts_param
    end
    for state in states
      next if state.nil?
      n += state.guts_param
    end
    # determine min/max guts value
    n = [n, 0].max
    n = [n, guts_max].min
    
    return n
  end # def gut
  alias guts gut
  
  #--------------------------------------------------------------------------
  # new method : gut_max
  #--------------------------------------------------------------------------
  def gut_max
    Bubs::Guts::GUTS_MAX.to_f
  end # def gut_max
  alias guts_max gut_max
  
  #--------------------------------------------------------------------------
  # new method : add_guts
  #--------------------------------------------------------------------------
  def add_guts(user, item)
    return
  end
end # class Game_BattlerBase


#==============================================================================
# ++ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # alias : die
  #--------------------------------------------------------------------------
  alias die_bubs_guts die
  def die
    @gutsable = true
    
    die_bubs_guts # alias
  end # def die
  
  #--------------------------------------------------------------------------
  # alias : on_battle_end
  #--------------------------------------------------------------------------
  alias on_battle_end_bubs_guts on_battle_end
  def on_battle_end
    @gutsable = false
    
    on_battle_end_bubs_guts # alias
  end # def on_battle_end
  
  #--------------------------------------------------------------------------
  # alias : on_battle_start
  #--------------------------------------------------------------------------
  alias on_battle_start_bubs_guts on_battle_start
  def on_battle_start
    @gutsable = false
    
    on_battle_start_bubs_guts # alias
  end
  
  #--------------------------------------------------------------------------
  # alias : item_apply
  #--------------------------------------------------------------------------
  alias item_apply_bubs_guts item_apply
  def item_apply(user, item)
    item_apply_bubs_guts(user, item) # alias
    
    if @result.hit? && item.guts_param != 0
      add_guts(item.guts_param)
    end
  end
  
  #--------------------------------------------------------------------------
  # new method : add_guts
  #--------------------------------------------------------------------------
  def add_guts(value)
    if actor?
      actor_guts = self.actor.guts_param
      self.actor.guts_param = [[actor_guts + value, 0].max, guts_max].min.to_f
    end
  end

  #--------------------------------------------------------------------------
  # new method : guts_chance
  #--------------------------------------------------------------------------
  def guts_chance
    [[eval(Bubs::Guts::GUTS_CHANCE_FORMULA).to_f, 0.0].max, 1.0].min
  end
  
  #--------------------------------------------------------------------------
  # new method : activate_guts?
  #--------------------------------------------------------------------------
  def activate_guts?
    rand < guts_chance
  end
  
  #--------------------------------------------------------------------------
  # new method : guts_hp_recovery
  #--------------------------------------------------------------------------
  def guts_hp_recovery
    if actor?
      self.hp += (mhp * (self.actor.guts_hp_recovery_rate * 0.01)).to_i
    else
      self.hp += (mhp * (self.enemy.guts_hp_recovery_rate * 0.01)).to_i
    end
  end
  
  #--------------------------------------------------------------------------
  # new method : apply_guts_reduction
  #--------------------------------------------------------------------------
  def apply_guts_reduction
    if actor?
      guts_value = self.actor.guts_param
      # Value here should be subtracted
      guts_value += self.actor.guts_reduce
      self.actor.guts_param = [[guts_value, 0.0].max, guts_max].min
    end
  end # def apply_guts_reduction
  
  #--------------------------------------------------------------------------
  # new method : guts_animation_id
  #--------------------------------------------------------------------------
  def guts_animation_id
    if actor?
      self.actor.guts_animation
    else
      self.enemy.guts_animation
    end
  end # def guts_animation_id
  
  #--------------------------------------------------------------------------
  # new method : personal_guts_text
  #--------------------------------------------------------------------------
  def personal_guts_text
    if actor?
      self.actor.guts_text
    else
      self.enemy.guts_text
    end
  end # def personal_guts_text
  
  #--------------------------------------------------------------------------
  # new method : apply_guts_effects
  #--------------------------------------------------------------------------
  def apply_guts_effects(battler)
    # Remove death state
    revive
    # Apply hp recovery value to battler
    guts_hp_recovery
    # Reduce actor's guts
    apply_guts_reduction
  end # def apply_guts_effects
end # class Game_Battler


#==============================================================================
# ++ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # alias : process_action
  #--------------------------------------------------------------------------
  alias process_action_bubs_guts process_action
  def process_action
    process_action_bubs_guts # alias
    
    
    return if $imported["BubsAutoLife"]
    # process_action_end never gets called if the last party member is
    # killed by an enemy with more Action Time+ actions in queue.
    if !@subject.nil? 
      if @subject.current_action && $game_party.all_dead?
        process_guts_check 
      end
    end
  end # def process_action

  #--------------------------------------------------------------------------
  # alias : process_action_end
  #--------------------------------------------------------------------------
  alias process_action_end_bubs_guts process_action_end
  def process_action_end
    if Bubs::Guts::CHECK_AFTER_EACH_ACTION
      process_guts_check unless $imported["BubsAutoLife"]
    end
    
    process_action_end_bubs_guts # alias
  end # def process_action_end
  
  #--------------------------------------------------------------------------
  # alias : turn_end
  #--------------------------------------------------------------------------
  alias turn_end_bubs_guts turn_end
  def turn_end
    process_guts_check unless $imported["BubsAutoLife"]
    
    turn_end_bubs_guts
  end
  
  #--------------------------------------------------------------------------
  # new method : process_guts_check
  #--------------------------------------------------------------------------
  def process_guts_check
    all_battle_members.each do |battler|
      determine_guts(battler)
    end
  end # def process_guts_check
  
  #--------------------------------------------------------------------------
  # new method : determine_guts
  #--------------------------------------------------------------------------
  def determine_guts(battler)
    return unless battler.gutsable
    # Set the battler guts flag off
    battler.gutsable = false
    
    return if $game_switches[Bubs::Guts::DISABLE_GUTS_SWITCH_ID]
    return unless battler.dead? && battler.activate_guts?
    
    @log_window.clear
    # Display general revive text
    @log_window.display_guts_effect_text(battler)
    
    battler.apply_guts_effects(battler)
    @status_window.refresh
    show_animation([battler], battler.guts_animation_id)
    # Display personal guts text
    @log_window.display_guts_text(battler)
    wait(35)
    @log_window.clear
  end # def apply_guts_effects
  
  #--------------------------------------------------------------------------
  # new method : clear_all_gutsable_flags
  #--------------------------------------------------------------------------
  def clear_all_gutsable_flags
    all_battle_members.each do |member|
      member.gutsable = false
    end
  end

  if $imported["YEA-BattleEngine"]
  #--------------------------------------------------------------------------
  # alias : debug_kill_all
  #--------------------------------------------------------------------------
  alias debug_kill_all_bubs_guts debug_kill_all
  def debug_kill_all
    debug_kill_all_bubs_guts # alias

    clear_all_gutsable_flags    
  end
  end # if $imported["YEA-BattleEngine"]
  
end # class Scene_Battle


#==============================================================================
# ++ Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # new method : gain_actor_guts
  #--------------------------------------------------------------------------
  def gain_actor_guts(actor_id, value)
    $game_actors[actor_id].add_guts(value)
  end
  
  #--------------------------------------------------------------------------
  # alias : command_129                     # Change Party Member
  #--------------------------------------------------------------------------
  alias command_129_bubs_guts command_129
  def command_129
    command_129_bubs_guts # alias
    
    actor = $game_actors[@params[0]]
    if actor
      if @params[1] == 0    # Add
        if @params[2] == 1  # Initialize
          $game_actors[@params[0]].load_notetags_bubs_guts
        end
      end
    end
  end

end # class Game_Interpreter