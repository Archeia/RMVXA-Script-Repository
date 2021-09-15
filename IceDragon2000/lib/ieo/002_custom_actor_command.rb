#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Custom Actor Command
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Change (Actor, Battle)
# ** Script Type   : ActorBattleCommand
# ** Date Created  : 02/15/2011
# ** Date Modified : 02/15/2011
# ** Script Tag    : IEO-002(Custom Actor Command)
# ** Difficulty    : Easy, Lunatic
# ** Version       : 1.0
# ** IEO ID        : 002
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# ** CREDITS/USED STUFF/EDITING
#-*--------------------------------------------------------------------------*-#
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
# Adding new commands to your actors has never been this fun, you can rearrange
# the defaults, or crack out your scripting skills, and make some of your own.
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#-*--------------------------------------------------------------------------*-#
#
# Well has only been tested with the DBS. No need for this with BEM.
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
#   execute_action_skill (Scene_Battle), and skill_can_use? (Game_Battler)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# Classes
#   Game_Actor
#     new-method :battle_vocab
#     new-method :battle_commands
#   Window_ActorCommand
#     new-method :draw_command
#     overwrite  :initialize
#     overwrite  :setup
#     overwrite  :refresh
#     overwrite  :draw_item
#   Scene_Battle
#     overwrite  :execute_action_skill
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  02/14/2011 - V1.0  Started Script and Finished Script
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  The Actor Command has been totally rewritten so, if you had any fancy
#  ones, then your screwed here.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
$imported ||= {}
$imported["IEO-CustomActorCommand"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
$ieo_script = {} if $ieo_script == nil
$ieo_script[[2, "CustomActorCommand"]] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# IEO::CUSTOM_ACTOR_COMMAND
#==============================================================================#
module IEO
  module CUSTOM_ACTOR_COMMAND
#==============================================================================#
#                      Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
    module_function
  #--------------------------------------------------------------------------#
  # * battle_command
  #--------------------------------------------------------------------------#
    def battle_command(actor)
      case actor.id
      when 0  ; return []
      when 2  ; return [:attack, :skill, :item, :guard]
      else    ; return [:attack, :skill, :item, :guard, :mp_recharge]
      end
    end
#==============================================================================#
#                        End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  end
end

#==============================================================================#
# Game_Actor IEO002-Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler
#==============================================================================#
#                      Start Lunatic Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :last_command

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias ieo002_lun_initialize initialize unless $@
  def initialize(actor_id)
    @last_command = nil
    ieo002_lun_initialize(actor_id)
  end

  #--------------------------------------------------------------------------#
  # * new method :battle_vocab
  #--------------------------------------------------------------------------#
  def battle_vocab(command)
    case command
    # Default
    when :attack ; return Vocab::attack
    when :guard  ; return Vocab::guard
    when :item   ; return Vocab::item
    when :skill  ; return self.class.skill_name_valid ? self.class.skill_name : Vocab::skill
    # Custom
    when :mp_recharge ; return "Recharge"
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :battle_commands
  #--------------------------------------------------------------------------#
  def battle_commands
    return IEO::CUSTOM_ACTOR_COMMAND.battle_command(actor)
  end

end

#==============================================================================#
# Scene_Battle IEO002-Scene_Battle
#==============================================================================#
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------#
  # * new method :custom_actor_command
  #--------------------------------------------------------------------------#
  def custom_actor_command(command)
    case command
    when :mp_recharge
      Sound.play_decision
      @active_battler.action.set_custom(:mp_recharge)
      next_actor
    end
  end
#==============================================================================#
#                       End Lunatic Customization
#------------------------------------------------------------------------------#
#==============================================================================#
end

#==============================================================================#
# IEO::Icon
#==============================================================================#
module IEO
  module Icon
    module_function ; def actor_command(actor, command) ; return 0 end
  end
end

#==============================================================================#
# Game_System
#==============================================================================#
class Game_System

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :wac_displaymode

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo002_gs_initialize :initialize unless $@
  def initialize
    ieo002_gs_initialize
    @wac_displaymode = 1
  end

end

#==============================================================================#
# Window_ActorCommand
#==============================================================================#
Object.send :remove_const, :Window_ActorCommand
class Window_ActorCommand < Window_Selectable
  include ICY_Window_MiniCommand

  attr_accessor :actor

  def initialize
    super(128, [], 1, 4)
    self.active = false
  end

  def setup(actor)
    s1 = Vocab::attack
    s2 = Vocab::skill
    s3 = Vocab::guard
    s4 = Vocab::item
    if actor.class.skill_name_valid     # Skill command name is valid?
      s2 = actor.class.skill_name       # Replace command name
    end
    @commands = [s1, s2, s3, s4]
    @item_max = 4
    refresh
    self.index = 0
  end

  def display_mode
    $game_system.wac_displaymode
  end

  def setup_commands(type)
    @commands = []
    case type
    when :standard
      @commands = @actor.battle_commands unless @actor.nil?
    end
    @last_setup   = type
    @item_max = @commands.size
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :setup
  #--------------------------------------------------------------------------#
  def setup(actor)
    @actor       = actor
    setup_commands(:standard)
    @column_max = 1
    @column_max = 3 if display_mode == 1
    refresh
    self.index = 0
  end

  #--------------------------------------------------------------------------#
  # * new method :get_icon
  #--------------------------------------------------------------------------#
  def get_icon(obj) ; return IEO::Icon.actor_command(@actor, obj) end
  #--------------------------------------------------------------------------#
  # * new method :get_vocab
  #--------------------------------------------------------------------------#
  def get_vocab(obj); return @actor.battle_vocab(obj) end
  #--------------------------------------------------------------------------#
  # * new method :lastindex_command
  #--------------------------------------------------------------------------#
  def lastindex_command ; return @actor.nil? ? :nil : @actor.last_command end
  #--------------------------------------------------------------------------#
  # * new method :set_lastcommand
  #--------------------------------------------------------------------------#
  def set_lastcommand ; @actor.last_command = command unless @actor.nil? end

end

#==============================================================================#
# Scene_Battle
#==============================================================================#
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------#
  # * overwrite method :start_actor_command_selection
  #--------------------------------------------------------------------------#
  def start_actor_command_selection
    @party_command_window.active = false
    @actor_command_window.setup(@active_battler)
    @actor_command_window.active = true
    @actor_command_window.index = 0
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update_actor_command_selection
  #--------------------------------------------------------------------------#
  def update_actor_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      prior_actor
    elsif Input.trigger?(Input::C)
      actor_command_case
    elsif Input.trigger?(Input::L)
      Sound.play_cursor
      prior_actor
    elsif Input.trigger?(Input::R)
      Sound.play_cursor
      next_actor
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :actor_command_case
  #--------------------------------------------------------------------------#
  def actor_command_case
    case @actor_command_window.command
    when :attack
      Sound.play_decision
      if $imported["IEO-Handy"]
        return if start_weapon_selection == :cancel
      else
        @active_battler.action.set_attack
      end
      start_target_enemy_selection
    when :skill
      Sound.play_decision
      start_skill_selection
    when :guard
      Sound.play_decision
      @active_battler.action.set_guard
      next_actor
    when :item
      Sound.play_decision
      start_item_selection
    else
      custom_actor_command(@actor_command_window.command)
    end
  end

end
#==============================================================================#
IEO::REGISTER.log_script(2, "CustomActorCommand", 1.0) if $imported["IEO-Register"]
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
