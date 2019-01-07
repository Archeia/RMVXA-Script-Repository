=begin
#==============================================================================
 ** End Phase Triggers
 Author: Hime
 Date: Sep 26, 2012
------------------------------------------------------------------------------
 ** Change log
 Sep 26
   - initial release
------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Preserve this header
------------------------------------------------------------------------------
 This script abstracts the win/loss processing into three steps.
 
 The first step checks whether we are in the "end phase", which is defined
 to be after a unit has won or lost.
 
 The second step is end phase event processing. This allows additional
 events to be executed if necessary when, for example, all enemies have been
 defeated.
 
 The third step is the usual end phase processing, which executes the
 victory/defeat/abort processes.
#==============================================================================
=end
$imported = {} if $imported.nil?
$imported["Tsuki_EndPhaseTriggers"] = true
#==============================================================================
# ** Configuration
#==============================================================================
module Tsuki
  module End_Phase_Triggers
  end
end
#==============================================================================
# ** Rest of the script
#==============================================================================

module BattleManager
  
  class << self
    alias :th_ep_triggers_judge_win_loss :judge_win_loss
  end
  
  # special "end phase" phase
  def self.end_phase
    return @end_phase
  end
  
  # Overwritten. Change this to return a particular end-phase
  def self.judge_win_loss
    if @phase
      if $game_party.members.empty? || aborting?
        return @end_phase = :abort
      elsif $game_party.all_dead?
        return @end_phase = :lose
      elsif $game_troop.all_dead?
        return @end_phase = :win
      else
        return @end_phase = nil
      end
    else
      # not really sure why
      process_win_loss
    end
    return false
  end
  
  # moving the actual win/loss processing here
  def self.process_win_loss
    th_ep_triggers_judge_win_loss
  end
end

class Scene_Battle
  
  alias :th_ep_triggers_process_act_end :process_action_end
  def process_action_end
    th_ep_triggers_process_act_end
    process_end_phase_events
  end
  
  alias :th_ep_triggers_update :update
  def update
    th_ep_triggers_update
    process_end_phase_events
  end
  
  # overwrite. Can't do much here because end phase processing must occur
  # after judging win/loss, or at least inside the loop
  def process_event
    while !scene_changing?
      $game_troop.interpreter.update
      $game_troop.setup_battle_event
      wait_for_message
      wait_for_effect if $game_troop.all_dead?
      process_forced_action
      BattleManager.judge_win_loss
      process_end_phase_events # new
      break unless $game_troop.interpreter.running?
      update_for_wait
    end
  end
  
  # new method. Same as process event except without judging win/loss
  def process_end_phase_events
    if BattleManager.end_phase
      while !scene_changing?
        $game_troop.interpreter.update
        $game_troop.setup_battle_event
        wait_for_message
        wait_for_effect if $game_troop.all_dead?
        process_forced_action
        break unless $game_troop.interpreter.running?
        update_for_wait
      end
      BattleManager.process_win_loss
    end
  end
end