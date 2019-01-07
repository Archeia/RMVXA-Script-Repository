=begin
================================================================================
 Title: Menu Command Manager
 Author: Hime
 Date: Sep 16, 2014
--------------------------------------------------------------------------------
 ** Change log 
 1.0 Sep 16, 2014
   -Initial release
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
 
 The Menu Command Manager adds additional functionality based on the
 Command Manager framework. It allows you to create and set up menu commands
 easily.
 
-------------------------------------------------------------------------------- 
 ** Required
 
 Command Manager
 (http://www.himeworks.com/2013/02/command-manager/)

-------------------------------------------------------------------------------- 
 ** Installation
 
 Place this script below Command Manager and above Main

-------------------------------------------------------------------------------- 
 ** Usage
 
 In the configuration, you can choose which menu commands you want.
================================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_MenuCommandManager"] = 1.0
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Command_Manager
    
    # Party Menu Commands that you want to have in your game
    Party_MenuCommands = [
      [:item, ""],
      [:skill, ""],
      [:equip, ""],
      [:status, ""],
      [:formation, ""],
      [:save, ""],
      [:game_end, ""]
    ]
  end
end

module CommandManager
  CommandRegex = /<cmd:\s*(\w+)(.*)\s*>/i
  
  class << self
    alias :th_menu_command_manager_register :register
    
    attr_reader :party_menu_command_table
  end
  
  #-----------------------------------------------------------------------------
  # Register a new command. Provide an idstring for your command, along with
  # the type of command.
  #-----------------------------------------------------------------------------
  def self.register(idstring, type, api_version=1.0)
    idstring = idstring.to_s
    key = idstring.to_sym 
    if type == :party_menu
      @party_menu_command_table.push(key)
    else
      th_menu_command_manager_register(idstring, type, api_version)
    end    
  end
  
  def self.init_menu_table
    @party_menu_command_table ||= []
  end
  
  def self.init_menu_commands
    register(:item, :party_menu)
    register(:skill, :party_menu)
    register(:equip, :party_menu)
    register(:status, :party_menu)
    register(:formation, :party_menu)
    register(:save, :party_menu)
    register(:game_end, :party_menu)
  end
  
  def self.party_menu_command?(sym)
    @party_menu_command_table.include?(sym)
  end
  
  init_menu_table
  init_menu_commands
end

#-------------------------------------------------------------------------------
# All units will store a list of commands
#-------------------------------------------------------------------------------
class Game_Unit

  alias :th_menu_command_manager_unit_init :initialize
  def initialize
    th_menu_command_manager_unit_init        
    init_menu_commands
  end
  
  def init_menu_commands
    @base_menu_commands = []
    @extra_menu_commands = []
  end
  
  def menu_commands
    @base_menu_commands + @extra_menu_commands
  end
  
  def add_menu_command(cmd)    
    @base_menu_commands.push(cmd)
  end
end

class Game_Party < Game_Unit
  
  def init_menu_commands
    super
    TH::Command_Manager::Party_MenuCommands.each do |cmd|
      if CommandManager.party_menu_command?(cmd[0])
        method_name = "add_menu_command_#{cmd[0]}"
        send(method_name, cmd[1..-1]) if respond_to?(method_name)
      end
    end
  end
end

class Window_MenuCommand < Window_Command
  
  #-----------------------------------------------------------------------------
  # Overwrite
  #-----------------------------------------------------------------------------
  def make_command_list    
    $game_party.menu_commands.each do |cmd|
      next unless cmd.enabled?($game_party)
      add_command(cmd.name, cmd.symbol, cmd.usable?($game_party), cmd.ext)
    end
  end
end

class Scene_Menu < Scene_MenuBase
  
  alias :th_command_manager_create_command_window :create_command_window
  def create_command_window
    th_command_manager_create_command_window
    CommandManager.party_menu_command_table.each do |cmd_sym|
      name = "command_#{cmd_sym}"
      @command_window.set_handler(cmd_sym, method(name)) if respond_to?(name)
    end
  end
end

class Game_Party < Game_Unit
  
  def add_menu_command_item(args)
    cmd = Game_Command.new(Vocab.item, :item)
    add_menu_command(cmd)
  end
  
  def add_menu_command_skill(args)
    cmd = Game_Command.new(Vocab.skill, :skill)
    add_menu_command(cmd)
  end
  
  def add_menu_command_equip(args)
    cmd = Game_Command.new(Vocab.equip, :equip)
    add_menu_command(cmd)
  end
  
  def add_menu_command_status(args)
    cmd = Game_Command.new(Vocab.status, :status)
    add_menu_command(cmd)
  end
  
  def add_menu_command_formation(args)
    cmd = MenuCommand_Formation.new(Vocab.formation, :formation)
    add_menu_command(cmd)
  end
  
  def add_menu_command_save(args)
    cmd = Game_Command.new(Vocab.save, :save)
    add_menu_command(cmd)
  end
  
  def add_menu_command_game_end(args)
    cmd = Game_Command.new(Vocab.game_end, :game_end)
    add_menu_command(cmd)
  end
end

#===============================================================================
# Party Menu Commands
#===============================================================================
class MenuCommand_Formation < Game_Command
  
  def usable?(party)
    party.members.size >= 2 && !$game_system.formation_disabled
  end
end