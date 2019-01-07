=begin
#===============================================================================
 Title: Troop Event Spans
 Author: Hime
 Date: Mar 6, 2014
--------------------------------------------------------------------------------
 ** Change log
 Mar 6, 2014
   - Fixed bug where forced actions caused battle end processing to run twice
 Mar 14, 2013
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
 
 This script adds some more troop spans.
 The following spans are available

    Action - called after an action is performed (by any battler)
 
--------------------------------------------------------------------------------
 ** Usage
 
 Create a comment in the troop page of the following form
 
   <page span: action>
   
 To make the event page run after every action.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_TroopEventSpans"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Troop_Event_Spans
    
    Action_Regex = /<page span: action>/
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module RPG
  class Troop::Page
    
    alias :th_troop_event_spans_span :span
    def span
      parse_page_span unless @page_span_checked
      th_troop_event_spans_span
    end
    
    def parse_page_span
      @list.each {|cmd|
        if cmd.code == 108 && cmd.parameters[0] =~ TH::Troop_Event_Spans::Action_Regex
          @span = 3
          break
        end
      }
      @page_span_checked = true
    end
  end
end

module BattleManager
  
  class << self
    alias :th_troop_event_spans_judge_win_loss :judge_win_loss
  end
  #-----------------------------------------------------------------------------
  # Checks whether an action has ended
  #-----------------------------------------------------------------------------
  def self.action_end?
    @phase == :action_end
  end
  
  #-----------------------------------------------------------------------------
  # Back to the turn
  #-----------------------------------------------------------------------------
  def self.next_action_start
    @phase = :turn
  end
  
  #-----------------------------------------------------------------------------
  # Action end processes
  #-----------------------------------------------------------------------------
  def self.action_end
    @phase = :action_end
    $game_troop.increase_action
  end
  
  def self.judge_win_loss
    return false if action_end?
    th_troop_event_spans_judge_win_loss
  end
end

class Game_Troop < Game_Unit
  
  alias :th_troop_event_spans_clear :clear
  def clear
    th_troop_event_spans_clear
    @action_count = 0
  end
  
  alias :th_troop_event_spans_conditions_met? :conditions_met?
  def conditions_met?(page)
    return false if page.span == 3 && !BattleManager.action_end?
    res = th_troop_event_spans_conditions_met?(page)
    check_page_span(page) if res
    return res
  end
  
  def check_page_span(page)
    @event_flags[page] = true if page.span == 3
  end
  
  #-----------------------------------------------------------------------------
  # Total number of actions
  #-----------------------------------------------------------------------------
  def increase_action
    troop.pages.each {|page| @event_flags[page] = false if page.span == 3 }
    @action_count += 1
  end
end

class Scene_Battle < Scene_Base
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  alias :th_troop_event_spans_process_action_end :process_action_end
  def process_action_end
    if !BattleManager.action_end?
      BattleManager.action_end
      process_event
      BattleManager.next_action_start
    else
      th_troop_event_spans_process_action_end
    end
  end
end