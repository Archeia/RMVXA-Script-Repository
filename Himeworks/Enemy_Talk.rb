=begin
#===============================================================================
 Title: Command - Enemy Talk
 Author: Hime
 Date: Apr 19, 2013
--------------------------------------------------------------------------------
 ** Change log
 Apr 19, 2013
   - added support for accessing currently talking actor
   - initial release
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
 
 This script allows you to set up enemy talk events during battle and use
 a talk command to interact with enemies.

 --------------------------------------------------------------------------------
 ** Required
 
 Command Manager
 (http://himeworks.com/2013/02/19/command-manager/)
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Command Manager and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 To add the talk command, tag actors with

   <cmd: enemy_talk>
  
 Enemy talk events are set up as troop event pages.
 To create an enemy talk event page, create a comment of the form
 
   <enemy talk event: x>
   
 Where x is the index of the enemy that this will apply to. The first enemy
 has an index of 1.
 
 To trigger this talk event, you must use the "talk" command on the enemy
 during battle. The event will run once the action is executed.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["Command_EnemyTalk"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Command_EnemyTalk
    
    # Command name to display
    Name = "Talk"
    
    # Message to display in battle log when talk action executed
    Format = "%s talked to %s"
#===============================================================================
# ** Rest of Script
#===============================================================================    
    Regex = /<enemy talk event: (\d+)>/i
    CommandManager.register(:enemy_talk, :actor)
  end
end

#-------------------------------------------------------------------------------
# Parse talk events from troop event pages
#-------------------------------------------------------------------------------
module RPG
  class Troop
    def talk_event_pages
      return @talk_event_pages unless @talk_event_pages.nil?
      parse_talk_event_pages
      return @talk_event_pages
    end
    
    def parse_talk_event_pages
      @talk_event_pages = {}
      @pages.each do |page|
        page.list.each do |cmd|
          if cmd.code == 108 && cmd.parameters[0] =~ TH::Command_EnemyTalk::Regex
            @talk_event_pages[$1.to_i - 1] = page
            next
          end
        end
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Enemy talk command
#-------------------------------------------------------------------------------
class Command_EnemyTalk < Game_BattlerCommand
end

#-------------------------------------------------------------------------------
# Store currently talking actor somewhere
#-------------------------------------------------------------------------------
class Game_Temp
  
  attr_accessor :talking_actor
end

#-------------------------------------------------------------------------------
# Add "talk" action
#-------------------------------------------------------------------------------
class Game_Action
  
  attr_reader :talk_to_enemy
  
  alias :th_cmd_enemy_talk_clear :clear
  def clear
    th_cmd_enemy_talk_clear
    @talk_to_enemy = false
  end
  
  def set_enemy_talk
    @talk_to_enemy = true
    self
  end
  
  alias :th_cmd_enemy_talk_valid? :valid?
  def valid?
    @talk_to_enemy || th_cmd_enemy_talk_valid?
  end
end

#-------------------------------------------------------------------------------
# Add "talk" to actor commands
#-------------------------------------------------------------------------------
class Game_Actor < Game_Battler
  
  def add_command_enemy_talk(args)
    cmd = Command_EnemyTalk.new(TH::Command_EnemyTalk::Name, :enemy_talk)
    add_command(cmd)
  end
end

#-------------------------------------------------------------------------------
# Handle talk event pages
#-------------------------------------------------------------------------------
class Game_Troop < Game_Unit
  
  def talk_event_pages
    troop.talk_event_pages
  end
  
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def setup_talk_event(index)
    page = talk_event_pages[index]
    return unless page
    @interpreter.setup(page.list)
  end
end

#-------------------------------------------------------------------------------
# Display messages related to talk actions
#-------------------------------------------------------------------------------
class Window_BattleLog < Window_Selectable
  
  def display_talk_action(subject, target)
    add_text(sprintf(TH::Command_EnemyTalk::Format, subject.name, target.name))
  end
end

#-------------------------------------------------------------------------------
# Battle logic for handling talk command
#-------------------------------------------------------------------------------
class Scene_Battle < Scene_Base
  
  def command_enemy_talk
    BattleManager.actor.input.set_enemy_talk
    select_enemy_selection
  end
  
  alias :th_cmd_enemy_talk_on_enemy_cancel :on_enemy_cancel
  def on_enemy_cancel
    th_cmd_enemy_talk_on_enemy_cancel
    case @actor_command_window.current_symbol
    when :enemy_talk
      @actor_command_window.activate
    end
  end
  
  alias :th_cmd_enemy_talk_execute_action :execute_action
  def execute_action
    if @subject.current_action.talk_to_enemy
      execute_enemy_talk_action
      refresh_status
    else    
      th_cmd_enemy_talk_execute_action
    end
  end
  
  #-----------------------------------------------------------------------------
  # Perform enemy talk execution logic
  #-----------------------------------------------------------------------------
  def execute_enemy_talk_action
    $game_temp.talking_actor = @subject
    target_index = @subject.current_action.target_index
    target = $game_troop.members[target_index]
    @log_window.display_talk_action(@subject, target)
    $game_troop.setup_talk_event(@subject.current_action.target_index)
    while !scene_changing?
      $game_troop.interpreter.update
      target.sprite_effect_type = :whiten if target.alive?
      break unless $game_troop.interpreter.running?
      update_for_wait
    end
    $game_temp.talking_actor = nil
  end
end