#After Battle Events v1.0
#----------#
#Features: Process Troop Events when the player wins, escapes, or is defeated by setting a page
#           with the appropriate switch as it's conditional.
#
#Usage:   Set your switches, set up your pages, run hog wild.
#
#          Victory is called after all enemies are dead and before exp/gold/etc
#          Escape is called when the escape command is chosen and before the result
#          Abort is called when successfully escaping or manual battle abort
#          Defeat is called when all allies are dead
#
#~ #----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
VICTORY_EVENT_SWITCH = 90
ESCAPE_EVENT_SWITCH = 91
ABORT_EVENT_SWITCH = 92
DEFEAT_EVENT_SWITCH = 93
 
module BattleManager
  class << self
    alias event_process_victory process_victory
    alias event_process_escape process_escape
    alias event_process_abort process_abort
    alias event_process_defeat process_defeat
  end
  def self.process_victory
    SceneManager.scene.play_victory_event
    return event_process_victory
  end
  def self.process_escape
    SceneManager.scene.play_escape_event
    return event_process_escape
  end
  def self.process_abort
    SceneManager.scene.play_abort_event
    return event_process_abort
  end
  def self.process_defeat
    SceneManager.scene.play_defeat_event
    return event_process_defeat
  end
end
 
class Scene_Battle
  def play_victory_event
    $game_switches[VICTORY_EVENT_SWITCH] = true
    process_end_event
  end
  def play_escape_event
    $game_switches[ESCAPE_EVENT_SWITCH] = true
    process_end_event
  end
  def play_abort_event
    $game_switches[ABORT_EVENT_SWITCH] = true
    process_end_event
  end
  def play_defeat_event
    $game_switches[DEFEAT_EVENT_SWITCH] = true
    process_end_event
  end
  def process_end_event
    while !scene_changing?
      $game_troop.interpreter.update
      $game_troop.setup_battle_event
      wait_for_message
      wait_for_effect if $game_troop.all_dead?
      process_forced_action
      break unless $game_troop.interpreter.running?
    end
  end
end