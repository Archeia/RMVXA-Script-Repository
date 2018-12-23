# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Real-time Cooldowns                                   │ v1.3 │ (8/13/12) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
#--------------------------------------------------------------------------
# This script allows you to define real-time cooldowns for skills, 
# limiting the frequency of skill usage based on the Playtime timer.
# 
# Inspiration for creating this script comes from Breath of Fire 3's
# "Bonebreak" (テラブレイク) and "Celerity" skills which were known for 
# their 3-hour long cooldown timers.
#
# This script only affects Actor's skills. This has no effect on Enemies.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.3 : Compatibility: "XAS VX Ace" support added.
#      : reset_realtime_cooldowns script call removed.
#      : New script call: reset_realtime_cooldown
#      : New script call: activate_realtime_cooldown
#      : New script call: clear_all_realtime_cooldowns
#      : New notetag added that modifies skill cooldown times.
#      : Efficiency update. (8/13/2012)
# v1.2 : Added proper $imported variable. (7/31/2012)
# v1.1 : Efficiency update. (7/30/2012)
# v1.0 : Initial release. (7/30/2012)
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
# <realtime cooldown: hrs:min:sec>
# <rtcooldown: hrs:min:sec>
#   This tag defines the amount of real-life time the skill needs to
#   cooldown after being used once. All hours, minutes, and seconds 
#   values must be defined even if any one of them is zero. The cooldown 
#   uses the Playtime clock to determine time elapsed.
#
# Here is an example of a <realtime cooldown> tag:
#
#     <realtime cooldown: 02:30:00>
#
# A skill with this tag will have a 2 hour and 30 minute cooldown after
# being used once. Leading zeroes are not necessary, but can be used.
#
#--------------------------------------------------------------------------
# The following Notetag is for Actors, Classes, Weapons, Armors, 
# and States:
#
# <realtime cooldown skill id: +hrs:min:sec>
# <realtime cooldown skill id: -hrs:min:sec>
# <rtcooldown skill id: +hrs:min:sec>
# <rtcooldown skill id: -hrs:min:sec>
#   This tag will increase or decrease the cooldown time of a skill where
#   id is a skill ID number from your database. This will only affect
#   skills that already have a cooldown defined with the <realtime cooldown> 
#   tag. If the time has a + (plus) sign, it will increase the time of the 
#   skill's cooldown. If the time has a - (minus) sign, it will decrease the
#   time of the skill's cooldown. This tag will stack if multiple tags
#   are found for the same skill. This tag can be used multiple times
#   within the same Notebox for different skill IDs.
#
# Here is an example of a <realtime cooldown skill> tag:
#
#     <rtcooldown skill 26: -00:00:10>
#
# This tag will reduce Skill ID 26's cooldown by 10 seconds.
#
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Script Calls ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following script calls are meant to be used in "Script..." event 
# commands found under Tab 3 when creating a new event.
#
# activate_realtime_cooldown(actor_id, skill_id)
#   This script call allows you to manually activate the cooldown for
#   an actor's skill. actor_id is an Actor ID number from your database
#   and skill_id is a skill ID number the actor has learned. This has
#   no effect if the skill does not have a cooldown.
#
# reset_realtime_cooldown(actor_id, skill_id)
#   This script call allows you to manually reset the cooldown for
#   an actor's skill to 0. actor_id is an Actor ID number from your 
#   database and skill_id is a skill ID number the actor has learned.
#
# clear_all_realtime_cooldowns(actor_id)
#   This script call removes all current real-time cooldowns from the 
#   given Actor where actor_id is an actor ID number from your database.
#
#--------------------------------------------------------------------------
#   ++ Compatibility ++
#--------------------------------------------------------------------------
# This script aliases the following default VXA methods:
#
#     DataManager#load_database
#     Game_BattlerBase#initialize
#     Game_BattlerBase#skill_conditions_met?
#     Game_Battler#use_item
#
# There are no default method overwrites.
#
# This script has built-in compatibility with the following scripts:
#
#     -Xiderwong Action System (XAS) VX Ace
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
$imported["BubsRealtimeCooldown"] = true

#==========================================================================
# ++ START OF USER CUSTOMIZATION MODULE ++
#==========================================================================
module Bubs
  #==========================================================================
  # ++ Realtime Cooldown Settings
  #==========================================================================
  module RealtimeCooldowns
  #--------------------------------------------------------------------------
  #   Xiderwong Action System (XAS) VX Ace Settings
  #--------------------------------------------------------------------------
  # The following settings are only for XAS VX Ace. They have no effect
  # in this script by itself or with other custom scripts.  
  #--------------------------------------------------------------------------
  POPUP_TEXT = "On Cooldown" # Cooldown Pop-up Text
  
  end # module RealtimeCooldowns
end # module Bubs

#==========================================================================
# ++ END OF USER CUSTOMIZATION MODULE ++
#==========================================================================


#==========================================================================
# ++ DataManager
#==========================================================================
module DataManager
  #--------------------------------------------------------------------------
  # alias : load_database
  #--------------------------------------------------------------------------
  class << self; alias load_database_bubs_rtcooldown load_database; end
  def self.load_database
    load_database_bubs_rtcooldown # alias
    load_notetags_bubs_rtcooldown
  end
  
  #--------------------------------------------------------------------------
  # new method : load_notetags_bubs_rtcooldown
  #--------------------------------------------------------------------------
  def self.load_notetags_bubs_rtcooldown
    groups = [$data_skills, $data_weapons, $data_armors, $data_actors,
              $data_states, $data_classes, $data_items]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_bubs_rtcooldown
      end # for obj
    end # for group
  end # def
  
end # module DataManager



#==========================================================================
# ++ Bubs::Regexp
#==========================================================================
module Bubs
  module Regexp
    REALTIME_COOLDOWN_TAG = 
      /<(?:REAL[_\s\-]?TIME|rt)[_\s]?COOLDOWN:\s*(\d+):(\d+):(\d+)\s*>/i
    REALTIME_COOLDOWN_MODIFIER_TAG = 
      /<(?:REAL[_\s\-]?TIME|rt)[_\s]?COOLDOWN[_\s]?SKILL[_\s]?(\d+):\s*([-+])(\d+):(\d+):(\d+)\s*>/i
  end # module Regexp
end # module Bubs



#==========================================================================
# ++ RPG::BaseItem
#==========================================================================
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :realtime_cooldown_modifier
  #--------------------------------------------------------------------------
  # common cache : load_notetags_bubs_rtcooldown
  #--------------------------------------------------------------------------
  def load_notetags_bubs_rtcooldown
    @realtime_cooldown_modifier = {}
    @realtime_cooldown_modifier.default = 0
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Bubs::Regexp::REALTIME_COOLDOWN_MODIFIER_TAG
        hour = $3.to_i * 60 * 60
        min = $4.to_i * 60
        sec = $5.to_i
        sign = $2 == "+" ? 1 : -1
        @realtime_cooldown_modifier[$1.to_i] = (hour + min + sec) * sign
      end # case
      
    } # self.note.split
  end
  
end # class RPG::BaseItem



#==========================================================================
# ++ RPG::Skill
#==========================================================================
class RPG::Skill
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :realtime_cooldown
  #--------------------------------------------------------------------------
  # common cache : load_notetags_bubs_rtcooldown
  #--------------------------------------------------------------------------
  def load_notetags_bubs_rtcooldown
    @realtime_cooldown = 0
    return unless note =~ Bubs::Regexp::REALTIME_COOLDOWN_TAG ? true : false
    hour = $1.to_i * 60 * 60
    min = $2.to_i * 60
    sec = $3.to_i
    @realtime_cooldown = hour + min + sec
  end
  
end # class RPG::Skill



#==============================================================================
# ++ Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # new method : activate_realtime_cooldown
  #--------------------------------------------------------------------------
  def activate_realtime_cooldown(actor_id, skill_id)
    return unless $game_actors[actor_id]
    skill = $data_skills[skill_id]
    $game_actors[actor_id].set_realtime_cooldown(skill)
  end
  
  #--------------------------------------------------------------------------
  # new method : reset_realtime_cooldown
  #--------------------------------------------------------------------------
  def reset_realtime_cooldown(actor_id, skill_id)
    return unless $game_actors[actor_id]
    $game_actors[actor_id].realtime_cooldowns.delete(skill_id)
  end
  
  #--------------------------------------------------------------------------
  # new method : clear_all_realtime_cooldowns
  #--------------------------------------------------------------------------
  def clear_all_realtime_cooldowns(actor_id)
    return unless $game_actors[actor_id]
    $game_actors[actor_id].realtime_cooldowns.clear
  end

end # class Game_Interpreter



#==============================================================================
# ++ Game_BattlerBase
#==============================================================================
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :realtime_cooldowns
  #--------------------------------------------------------------------------
  # alias : initialize
  #--------------------------------------------------------------------------
  alias initialize_bubs_rtcooldown initialize
  def initialize
    initialize_bubs_rtcooldown # alias
    
    @realtime_cooldowns = {}
  end
  
  #--------------------------------------------------------------------------
  # alias : skill_conditions_met?
  #--------------------------------------------------------------------------
  alias skill_conditions_met_bubs_rtcooldown skill_conditions_met?
  def skill_conditions_met?(skill)
    return false if realtime_cooldown?(skill)
    return skill_conditions_met_bubs_rtcooldown(skill) # alias
  end
  
  #--------------------------------------------------------------------------
  # new method : realtime_cooldown?
  #--------------------------------------------------------------------------
  def realtime_cooldown?(skill)
    return false unless skill.realtime_cooldown > 0
    return false unless actor?
    return false if @realtime_cooldowns[skill.id].nil?
    
    elapsed = $game_system.playtime - @realtime_cooldowns[skill.id]
    if elapsed > skill.realtime_cooldown
      @realtime_cooldowns.delete(skill.id)
      return false
    else
      return true
    end
  end

end # class Game_BattlerBase



#==============================================================================
# ++ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # alias : use_item
  #--------------------------------------------------------------------------
  alias use_item_bubs_rtcooldown use_item
  def use_item(item)
    set_realtime_cooldown(item)
    
    use_item_bubs_rtcooldown(item) # alias
  end
  
  #--------------------------------------------------------------------------
  # new method : set_realtime_cooldown
  #--------------------------------------------------------------------------
  def set_realtime_cooldown(item)
    return unless item.is_a?(RPG::Skill)
    return unless item.realtime_cooldown > 0
    return unless actor?
    return unless skill_learn?(item)
    
    @realtime_cooldowns[item.id] = determine_realtime_cooldown(item)
  end
  
  #--------------------------------------------------------------------------
  # new method : determine_realtime_cooldown
  #--------------------------------------------------------------------------
  def determine_realtime_cooldown(item)
    time = $game_system.playtime
    time += get_realtime_cooldown_modifier(item)
    return time
  end
  
  #--------------------------------------------------------------------------
  # new method : get_realtime_cooldown_modifier
  #--------------------------------------------------------------------------
  def get_realtime_cooldown_modifier(item)
    id = item.id
    n = 0
    if actor?
      n += self.actor.realtime_cooldown_modifier[id]
      n += self.class.realtime_cooldown_modifier[id]
      for equip in equips
        next if equip.nil?
        n += equip.realtime_cooldown_modifier[id]
      end
      for state in states
        next if state.nil?
        n += state.realtime_cooldown_modifier[id]
      end
    end
    return n
  end
  
end # class Game_Battler



if defined?(XAS_ACTION)
#===============================================================================
# ++ XAS ACTION
#===============================================================================
module XAS_ACTION
  #--------------------------------------------------------------------------
  # compatibility alias : enough_skill_cost?
  #--------------------------------------------------------------------------
  alias enough_skill_cost_bubs_rtcooldown enough_skill_cost?
  def enough_skill_cost?(skill)
    return false unless realtime_cooldown?(skill)
    return enough_skill_cost_bubs_rtcooldown(skill) # alias
  end
  
  #--------------------------------------------------------------------------
  # compatibility method : realtime_cooldown?
  #--------------------------------------------------------------------------
  def realtime_cooldown?(skill)
    return false unless self.battler.actor?
    if @force_action_times > 0
      return true if @force_action == "All Shoot" 
      return true if @force_action == "Four Shoot"  
      return true if @force_action == "Three Shoot" 
      return true if @force_action == "Two Shoot" 
    end
    if self.battler.realtime_cooldown?(skill)
      self.battler.damage = Bubs::RealtimeCooldowns::POPUP_TEXT
      self.battler.damage_pop = true
      return false
    else
      self.battler.set_realtime_cooldown(skill)
      return true
    end
  end

end # module XAS_ACTION

end # defined?(XAS_ACTION)