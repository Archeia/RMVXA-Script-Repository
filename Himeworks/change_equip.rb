=begin
#===============================================================================
 Title: Command - Change Equip
 Author: Hime
 Date: Mar 31, 2013
--------------------------------------------------------------------------------
 ** Change log
 Mar 31, 2013
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
 ** Required
 
 Command Manager
 (http://himeworks.com/2013/02/19/command-manager/)
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to add a "change equip" command for your actors in
 battle so that you can change equips during battle.
 
 You can specify a cooldown in between equip changing.

--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Command Manager and above main.
 
--------------------------------------------------------------------------------
 ** Usage 
 
 Tag actors with the following note-tag to give them the change equip command:
 
   <cmd: change_equip cooldown>
   
 Where the `cooldown` is an integer that indicates how many turns you must
 wait before you can change equips again in battle. If it is not specified,
 then it is 0.
 
 In the configuration, you can set the text to display for the command.
 
 You can also specify whether the actor will pass a turn if the actor changes
 equips.
 
 You can also specify that certain states will disable equip changing.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["Command_ChangeEquip"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module Commands
  module Change_Equip
    
    # Set the name to be displayed
    Equip_Text = "Equip"
    
    # If you change your equips, your actor must pass this turn
    Requires_Turn = true
    
    # List of state ID's that will prevent actor from changing equips in battle
    Seal_Command_States = []
    
#===============================================================================
# ** Rest of script
#===============================================================================    
    CommandManager.register(:change_equip, :actor)
  end
end

class Command_ChangeEquip < Game_BattlerCommand
  
  #-----------------------------------------------------------------------------
  # Command is usable only if the user can equip in battle
  #-----------------------------------------------------------------------------
  def usable?(user)
    super(user) && user.battle_equippable?
  end
end


class Game_Actor < Game_Battler
  #-----------------------------------------------------------------------------
  # Add the command to the actor
  #-----------------------------------------------------------------------------
  def add_command_change_equip(args)
    cooldown_time = args[0] ? args[0].to_i : 0
    name = Commands::Change_Equip::Equip_Text
    cmd = Command_ChangeEquip.new(name, :change_equip, cooldown_time)
    add_command(cmd)
  end
  
  alias :th_cmd_change_equip_initialize :initialize
  def initialize(actor_id)
    th_cmd_change_equip_initialize(actor_id)
    @equip_cooldown = 0
  end
  
  #-----------------------------------------------------------------------------
  # Reset equip cooldown
  #-----------------------------------------------------------------------------
  def reset_equip_cooldown
    @equip_cooldown = 0
  end
  
  #-----------------------------------------------------------------------------
  # Reset equip cooldown when battle begins
  #-----------------------------------------------------------------------------
  alias :th_cmd_change_equip_on_battle_start :on_battle_start
  def on_battle_start
    th_cmd_change_equip_on_battle_start
    reset_equip_cooldown
  end
  
  alias :th_cmd_change_equip_on_battle_end :on_battle_end
  def on_battle_end
    th_cmd_change_equip_on_battle_end
    reset_equip_cooldown
  end
  
  alias :th_cmd_change_equip_on_turn_end :on_turn_end
  def on_turn_end
    th_cmd_change_equip_on_turn_end
    update_equip_cooldown
  end
  
  #-----------------------------------------------------------------------------
  # Decrease the cooldown time
  #-----------------------------------------------------------------------------
  def update_equip_cooldown
    @equip_cooldown = [@equip_cooldown - 1, 0].max
  end
  
  #-----------------------------------------------------------------------------
  # Set the cooldown time
  #-----------------------------------------------------------------------------
  def set_equip_cooldown(turns)
    @equip_cooldown = turns
  end
  
  #-----------------------------------------------------------------------------
  # Returns true if no cooldown is required anymore
  #-----------------------------------------------------------------------------
  def battle_equippable?
    return false unless (@states & Commands::Change_Equip::Seal_Command_States).empty?
    return false if @equip_cooldown > 0
    return true
  end
end

#-------------------------------------------------------------------------------
# Battle-scene specific logic
#-------------------------------------------------------------------------------
class Scene_BattleEquip < Scene_Equip
  
  #-----------------------------------------------------------------------------
  # No actor scrolling
  #-----------------------------------------------------------------------------
  def create_command_window
    wx = @status_window.width
    wy = @help_window.height
    ww = Graphics.width - @status_window.width
    @command_window = Window_EquipCommand.new(wx, wy, ww)
    @command_window.viewport = @viewport
    @command_window.help_window = @help_window
    @command_window.set_handler(:equip,    method(:command_equip))
    @command_window.set_handler(:optimize, method(:command_optimize))
    @command_window.set_handler(:clear,    method(:command_clear))
    @command_window.set_handler(:cancel,   method(:return_scene))
  end
end

class Scene_Battle < Scene_Base
  
  #-----------------------------------------------------------------------------
  # Process equip scene
  #-----------------------------------------------------------------------------
  def command_change_equip
    Graphics.freeze
    @info_viewport.visible = false
    hide_extra_gauges if $imported["YEA-BattleEngine"]
    SceneManager.snapshot_for_background
    actor = $game_party.battle_members[@status_window.index]
    $game_party.menu_actor = actor
    previous_equips = actor.equips.clone
    index = @actor_command_window.index
    oy = @actor_command_window.oy
    #---
    SceneManager.call(Scene_BattleEquip)
    SceneManager.scene.main
    #---
    show_extra_gauges if $imported["YEA-BattleEngine"]
    @info_viewport.visible = true
    @status_window.refresh
    @actor_command_window.setup(actor)
    @actor_command_window.select(index)
    @actor_command_window.oy = oy
    perform_transition
    
    # pass turn if actor must wait after changing equips
    if actor.equips != previous_equips
      actor.set_equip_cooldown(@actor_command_window.current_ext)
      next_command if Commands::Change_Equip::Requires_Turn
    end
  end
end