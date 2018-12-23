# ╔═══════════════════════════════════════════════════════╤══════╤═══════════╗
# ║ Lose Battle on Actor Death                            │ v1.0 │ (7/12/12) ║
# ╚═══════════════════════════════════════════════════════╧══════╧═══════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
# Thanks:
#     Mithran, regexp lessons
#--------------------------------------------------------------------------
# Some RPGs out there are arbitrarily increased in difficulty by the simple 
# rule that if the lead character dies, it is considered a Game Over.
#
# This small script provides that same functionality to VX Ace projects with 
# the added flexibility of flagging any actor you want. This only affects
# battles. Deaths on the map scene are not checked.
#--------------------------------------------------------------------------
#   ++ Changelog ++
#--------------------------------------------------------------------------
# v1.0 : Initial release. (7/12/2012)
#--------------------------------------------------------------------------
#   ++ Installation ++
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ++ Notetag ++
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# The following Notetag is for Actors only:
#
# <lose on death>
#   Actors with this tag will cause a battle loss if they are  
#   Incapacitated in battle.
#--------------------------------------------------------------------------
#   ++ Compatibility ++
#--------------------------------------------------------------------------
# This script has built-in compatibility with the following scripts:
#
#     -Auto-Life Effect
#     -Guts Effect
#
# This script aliases the following default VXA methods:
#
#     BattleManager#judge_win_loss
#     Game_Actor#setup
#
# There are no default method overwrites.
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
$imported["BubsLoseOnDeath"] = true

#==============================================================================
# ++ BattleManager
#==============================================================================
module BattleManager
  #--------------------------------------------------------------------------
  # alias : judge_win_loss
  #--------------------------------------------------------------------------
  class << self; alias judge_win_loss_bubs_lose_on_death judge_win_loss; end
  def self.judge_win_loss
    if @phase
      return process_abort    if aborting?
      return process_defeat   if actor_lose_on_death?
    end
    judge_win_loss_bubs_lose_on_death # alias
  end # def self.judge_win_loss
  
  #--------------------------------------------------------------------------
  # new method : actor_lose_on_death?
  #--------------------------------------------------------------------------
  def self.actor_lose_on_death?
    return false if $imported["BubsGuts"] && gutsable_members
    return false if $imported["BubsAutoLife"] && autolifeable_members
    return lose_on_death_actor_dead?
  end # def self.actor_lose_on_death?
  
  #--------------------------------------------------------------------------
  # new method : lose_on_death_actor_dead?
  #--------------------------------------------------------------------------
  def self.lose_on_death_actor_dead?
    $game_party.battle_members.each do |actor|
      return true if actor.lose_on_death && actor.dead?
    end
    return false
  end
end # module BattleManager


#==============================================================================
# ++ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :lose_on_death     # lose on actor death flag
  #--------------------------------------------------------------------------
  # alias : setup
  #--------------------------------------------------------------------------
  alias setup_bubs_lose_on_death setup
  def setup(actor_id)
    setup_bubs_lose_on_death(actor_id) # alias
    
    @lose_on_death ||= lose_on_death_noteread
  end
  
  #--------------------------------------------------------------------------
  # new method : lose_on_death_noteread
  #--------------------------------------------------------------------------
  def lose_on_death_noteread
    actor.note =~ /<(?:LOSE[\s_]?ON[\s_]?DEATH)>/i ? true : false
  end
end # class Game_Actor