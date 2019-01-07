=begin
#===============================================================================
 Title: Party Command Manager
 Author: Hime
 Date: Oct 5, 2014
--------------------------------------------------------------------------------
 ** Change log
 Oct 5, 2014
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
 
 This script is an add-on to the Command Manager that allows you to define
 and add party commands.
--------------------------------------------------------------------------------
 ** Required
 
 Command Manager
 (http://www.himeworks.com/2013/02/command-manager/)
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Command Manager and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 In the configuration, you can set up party battle commands. These are the
 commands that are available before you pick individual actor commands during
 battle, if your battle system supports it.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_PartyCommandManager"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Command_Manager
    
    # Each command is a list consisting of the command symbol, followed by
    # some arguments. Check add-ons for instructions
    Party_BattleCommands = [
      [:fight, ""],
      [:escape, ""],
      [:common_event, "Party"],
      [:common_event, "Show Log"],
    ]
  end
end

module CommandManager
  class << self
    alias :th_party_command_manager_register :register
    
    attr_reader :party_battle_command_table
  end
  
  #-----------------------------------------------------------------------------
  # Register a new command. Provide an idstring for your command, along with
  # the type of command.
  #-----------------------------------------------------------------------------
  def self.register(idstring, type, api_version=1.0)
    idstring = idstring.to_s
    key = idstring.to_sym
    if type == :party_battle
      @party_battle_command_table.push(key)
    else
      th_party_command_manager_register(idstring, type, api_version)
    end
  end
  
  def self.init_party_tables
    @party_battle_command_table = []
  end
  
  def self.init_party_commands
    register(:fight, :party_battle)
    register(:escape, :party_battle)
  end
  
  def self.party_battle_command?(sym)
    @party_battle_command_table.include?(sym)
  end
  
  init_party_tables
  init_party_commands
end

#-------------------------------------------------------------------------------
# A command that is bound to a particular unit
#-------------------------------------------------------------------------------
class Game_UnitCommand < Game_Command
  attr_accessor :unit
end

#-------------------------------------------------------------------------------
# All units will store a list of commands
#-------------------------------------------------------------------------------
class Game_Unit

  alias :th_command_manager_unit_init :initialize
  def initialize
    th_command_manager_unit_init
    @base_battle_commands = []
    @extra_battle_commands = []
    init_commands
  end
  
  def init_commands
  end
  
  def battle_commands
    @base_battle_commands + @extra_battle_commands
  end
  
  #-----------------------------------------------------------------------------
  # New.
  #-----------------------------------------------------------------------------
  def add_battle_command(cmd)
    @base_battle_commands.push(cmd)
  end
end

class Game_Party < Game_Unit

  def init_commands
    super
    init_battle_commands
  end
  
  def init_battle_commands
    @base_battle_commands = []
    TH::Command_Manager::Party_BattleCommands.each do |cmd|
      if CommandManager.party_battle_command?(cmd[0])
        method_name = "add_battle_command_#{cmd[0]}"
        send(method_name, cmd[1..-1]) if respond_to?(method_name)
      end
    end
  end
  
  def add_battle_command_escape(args)
    cmd = Command_Escape.new(Vocab::escape, :escape)
    add_battle_command(cmd)
  end
  
  def add_battle_command_fight(args)
    cmd = Game_Command.new(Vocab::fight, :fight)
    add_battle_command(cmd)
  end
end

#-------------------------------------------------------------------------------
# Party command window pulls commands from the party, instead of hardcoding it
#-------------------------------------------------------------------------------
class Window_PartyCommand < Window_Command
  
  #-----------------------------------------------------------------------------
  # Overwrite
  #-----------------------------------------------------------------------------
  def make_command_list
    $game_party.battle_commands.each {|cmd|
      next unless cmd.enabled?($game_party)
      add_command(cmd.name, cmd.symbol, cmd.usable?($game_party), cmd.ext)
    }
  end
end

class Scene_Battle < Scene_Base
  alias :th_party_command_manager_create_party_command_window :create_party_command_window
  def create_party_command_window
    th_party_command_manager_create_party_command_window
    CommandManager.party_battle_command_table.each do |cmd_sym|
      name = "command_#{cmd_sym}"
      @party_command_window.set_handler(cmd_sym, method(name)) if respond_to?(name)
    end
  end
end

#===============================================================================
# Party Battle Commands
#===============================================================================
class Command_Escape < Game_UnitCommand
  def usable?(user)
    BattleManager.can_escape?
  end
end