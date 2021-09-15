#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Custom Battle Actions
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Battle Actions)
# ** Script Type   : Battle Actions
# ** Date Created  : 02/17/2011
# ** Date Modified : 05/29/2011
# ** Script Tag    : IEO-004(Custom Battle Actions)
# ** Difficulty    : Lunatic
# ** Version       : 1.0
# ** IEO ID        : 004
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# ** CREDITS/USED STUFF/EDITING
#-*--------------------------------------------------------------------------*-#
#
# You may:
# Edit and Adapt this script as long you credit aforementioned author(s).
#
# You may not:
# Claim this as your own work, or redistribute without the consent of the author.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#-*--------------------------------------------------------------------------*-#
# Well this script or rather reference script, is more of a help yourself
# sort of thing.
# Its its not really useful on its own without IEO-002(Custom Actor Command)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#-*--------------------------------------------------------------------------*-#
#
# Well has only been tested with the DBS, and Ohmerion.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#-*--------------------------------------------------------------------------*-#
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
#
#-*--------------------------------------------------------------------------*-#
# Below
#   Materials
#   CBS
#
# Above
#   Main
#   Anything that makes changes to:
#   execute_action (Scene_Battle)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# Classes
#   Game_BattleAction
#     new-method :set_custom
#     new-method :custom_action?
#     overwrite  :clear
#     overwrite  :valid?
#     overwrite  :make_speed
#   Window_ActorCommand
#     new-method :draw_command
#     overwrite  :initialize
#     overwrite  :setup
#     overwrite  :refresh
#     overwrite  :draw_item
#   Scene_Battle
#     new-method :execute_action_custom
#     overwrite  :wait
#     overwrite  :execute_action
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  05/29/2011 - V1.0 Finished Script
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  This script breaks the Battle Actions a lot so take caution.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
$imported ||= {}
$imported["IEO-CustomBattleAction"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
$ieo_script = {} if $ieo_script == nil
$ieo_script[[4, "CustomBattleAction"]] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# Game_BattleAction
#==============================================================================#
class Game_BattleAction

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :custom_action
# // You start editing here
  #--------------------------------------------------------------------------#
  # * overwrite method :clear
  #--------------------------------------------------------------------------#
  def clear
    @speed = 0
    @kind = 0
    @basic = -1
    @skill_id = 0
    @item_id = 0
    @target_index = -1
    @forcing = false
    @value = 0

    @custom_action = nil
  end

  #--------------------------------------------------------------------------#
  # * new method :set_custom
  #--------------------------------------------------------------------------#
  def set_custom(action)
    @kind = 3
    @custom_action = action
    case action
    when :mp_recharge
      @speed = 9999
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :custom_action?
  #--------------------------------------------------------------------------#
  def custom_action?(action) ; return @custom_action.eql?(action) end

  #--------------------------------------------------------------------------#
  # * overwrite method :valid?
  #--------------------------------------------------------------------------#
  def valid?
    return false if nothing?                      # Do nothing
    return true if @forcing                       # Force to act
    return false unless battler.movable?          # Cannot act
    if skill?                                     # Skill
      return false unless battler.skill_can_use?(skill)
    elsif item?                                   # Item
      return false unless friends_unit.item_can_use?(item)
    end
    return true
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :make_speed
  #--------------------------------------------------------------------------#
  def make_speed
    @speed = battler.agi + rand(5 + battler.agi / 4)
    @speed += skill.speed if skill?
    @speed += item.speed if item?
    @speed += 2000 if guard?
    @speed += 1000 if attack? and battler.fast_attack
    @speed += 2000 if custom_action?(:mp_recharge)
  end

end

#==============================================================================#
# Scene_Battle
#==============================================================================#
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------#
  # * overwrite method :wait
  #--------------------------------------------------------------------------#
  def wait(duration, no_fast=false)
    duration = duration * 50 / 100
    for i in 0...duration
      update_basic
      break if not no_fast and i >= duration / 2 and show_fast?
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :execute_cusaction_mprecharge
  #--------------------------------------------------------------------------#
  def execute_cusaction_mprecharge
    oldmp = @active_battler.mp
    @active_battler.mp += @active_battler.maxmp * 5 / 100
    newmp = (@active_battler.mp-oldmp).abs
    text = sprintf("%s Recovered %d%s", @active_battler.name, newmp, Vocab.mp)
    display_animation([@active_battler], 38)
    Sound.play_recovery
    @message_window.add_instant_text(text)
    wait(45)
  end

  #--------------------------------------------------------------------------#
  # * new method :execute_action_custom
  #--------------------------------------------------------------------------#
  def execute_action_custom
    case @active_battler.action.custom_action
    when :mp_recharge
      execute_cusaction_mprecharge
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :execute_action
  #--------------------------------------------------------------------------#
  def execute_action
    case @active_battler.action.kind
    when 0  # Basic
      case @active_battler.action.basic
      when 0  # Attack
        execute_action_attack
      when 1  # Guard
        execute_action_guard
      when 2  # Escape
        execute_action_escape
      when 3  # Wait
        execute_action_wait
      end
    when 1  # Skill
      execute_action_skill
    when 2  # Item
      execute_action_item
    when 3  # Custom Actions
      execute_action_custom
    end
  end

end
#==============================================================================#
IEO::REGISTER.log_script(4, "CustomBattleAction", 1.0) if $imported["IEO-Register"]
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
