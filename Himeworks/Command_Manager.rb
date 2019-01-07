=begin
================================================================================
 Title: Command Manager
 Author: Hime
 Date: Oct 5, 2014
--------------------------------------------------------------------------------
 ** Change log
 1.7 Oct 5, 2014
   - separated party commands into a separate add-on
 1.6 Sep 16, 2014
   - separated menu commands into a separate add-on
 1.5 Nov 18, 2013
   - exposed command name to plugin API
   - introduced "Game_BattlerCommand" as a type of command
 1.4 Nov 8, 2013
   - added API for party menu commands
 1.3 Aug 14, 2013
   -separated commands into base commands and extra commands
   -changing class will re-initialize base commands
 1.2 Apr 16, 2013
   -all commands are now defined as their own class
 1.1 Mar 31, 2013
   -integrated "use_skill" and "use_item" commands into this script
 1.0 Feb 18, 2013
   -added party command API
   -added initial class command note-tags
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
 
 The Command Manager provides an plugin API that allows you to easily add
 new commands to your game.
 
 The system provides a standard note-tag that will be used to set up your
 actors' commands.
 
-------------------------------------------------------------------------------- 
 ** Installation
 
 Place this script below Materials and above Main

-------------------------------------------------------------------------------- 
 ** Usage
 
 An actor's initial command list is the combination of its own
 commands, plus its class' commands.
 
 To set up an actor's commands, tag actor or class objects with
 
    <cmd: command_name args>
    
 Where
   `command_name` is the name of the command that the actor will use
   `args` are any arguments that the command requires
   
 The system comes with 5 commands built-in:
 
 <cmd: attack>       - adds the attack command
 <cmd: guard>        - adds the guard command
 <cmd: skill_list>   - adds all available skill types
 <cmd: skill id>     - adds a skill type command. You must specify the stype ID
 <cmd: item>         - adds the item command 
 <cmd: use_skill id> - use the specific skill directly
 <cmd: use_item id>  - use the specified item directly
 
 For developers, see the reference section for more information on
 what is available in this script.
   
-------------------------------------------------------------------------------- 
 ** Reference
 
 --- Command Types ---
 
 There are different types of commands in RM. You have commands that can be
 accessed in the party menu; actor battle commands; party battle commands;
 and possibly more. Thus, it would be convenient to distinguish between
 various commands.
 
 The following command types are supported
 
 * actor
 
   These are actor commands that appear during battle.
   You must define an `add_command_IDSTRING` method in Game_Actor.
   Scene_Battle provides a `command_IDSTRING` method that will be invoked
   when the player selects this command.
     
 * party
 
   There are party commands that appear during battle.
   You must define an `add_command_IDSTRING` method in Game_Party
   Scene_Battle provides a `command_IDSTRING` method that will be invoked
   when the player selects this command.
     
 ---Game_Command class---
 
 All command windows (supported by this system) will use instances of the
 Game_Command class.
 
 A command consists of three pieces of data
 
   1. Name
   2. Symbol
   3. Extended data
   
 - The name is the name of the command that will be displayed on the windows 
 - The symbol is the method that will be called when the command is selected.
 - The extended data is just extra data that comes with the command. You can
   access this data through any scene/window if necessary.

 Additionally, the command class provides two methods that you can overwrite
 if necessary:
 
   enabled?(user)
   
      This method determines whether the command should be shown or not.
      The user is the person that invokes it. It could be an actor, a party,
      an item, or basically anything that might affect whether the command
      should be shown or not.
      
   usable?(user)
   
      This method determines whether the command can be selected or not.
      For example, if this were a Skill command, then it is usable depending
      on whether the user can use the skill or not.

-------------------------------------------------------------------------------- 
 ** Developer Guide
 
 The Command Manager API allows you to quickly define a command and add it to
 the game. Developing a new command can be done in 4 easy steps.
 
 1. Register your command plugin
 
      CommandManager.register(idstring, type, api_version)
      
    The idstring is a symbol that will be associated with your command.
    It is important to pick a unique idstring.
    
    The type refers to the type of command you are writing. Please refer to
    the reference section for a list of available command types.
    
    If you are writing a plugin that requires a later version of this API,
    you can specify one. It is optional.
    
 2. Define your Command class.
 
    This API provides a Game_Command class which
    is used by all command windows to uniformly process commands. There are 
    cases where a simple Game_Command object just isn't enough.
    
 3. Define an add_command method. 
 
    You must define an add_command method in order to tell the system how to
    process your command.
    
 4. Write the command handling logic
 
    The appropriate scenes have already associated your idstring with your
    command. The method you are given uses the format
    
       def command_IDSTRING
         #
       end
       
    You can do basically anything you want with this method.
 
================================================================================
=end
$imported = {} if $imported.nil?
$imported["CommandManager"] = 1.5
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Command_Manager
    
    # Each command is a list consisting of the command symbol, followed by
    # some arguments.
    Party_BattleCommands = [
      [:fight, ""],
      [:escape, ""],
      [:common_event, "1"]
    ]
  end
end
#===============================================================================
# ** Rest of the script. 
#===============================================================================
#-------------------------------------------------------------------------------
# The Command Manager handles all plugin-related functionality. It allows you
# to register new commands.
#-------------------------------------------------------------------------------
module CommandManager
  CommandRegex = /<cmd:\s*(\w+)(.*)\s*>/i
  
  class << self
    attr_reader :actor_command_table
  end
  
  #-----------------------------------------------------------------------------
  # Register a new command. Provide an idstring for your command, along with
  # the type of command.
  #-----------------------------------------------------------------------------
  def self.register(idstring, type, api_version=1.0)
    idstring = idstring.to_s
    key = idstring.to_sym
    if type == :actor
      @actor_command_table.push(key)
    end
  end
  
  def self.init_tables
    @actor_command_table = []
  end
  
  def self.init_basic_commands
    register(:attack, :actor)
    register(:guard, :actor)
    register(:skill, :actor)
    register(:skill_list, :actor)
    register(:item, :actor)

    # Extra commands
    register(:use_skill, :actor)
    register(:use_item, :actor)
  end
  
  def self.actor_command?(sym)
    @actor_command_table.include?(sym)
  end
  init_tables
  init_basic_commands
end

module RPG
  
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  class Actor    
    def initial_commands
      return @init_commands unless @init_commands.nil?
      load_notetag_initial_commands
      return @init_commands
    end
    
    #---------------------------------------------------------------------------
    # Load any valid commands
    #---------------------------------------------------------------------------
    def load_notetag_initial_commands
      @init_commands = []
      res = self.note.scan(CommandManager::CommandRegex)
      res.each {|(idstring, args)|
        idstring = idstring.downcase
        if CommandManager.actor_command?(idstring.to_sym)
          @init_commands.push([idstring].concat(args.split))
        end
      }
    end
  end
  
  #-----------------------------------------------------------------------------
  # Classes also have commands.
  #-----------------------------------------------------------------------------
  class Class
    def initial_commands
      return @init_commands unless @init_commands.nil?
      load_notetag_initial_commands
      return @init_commands
    end
    
    def load_notetag_initial_commands
      @init_commands = []
      res = self.note.scan(CommandManager::CommandRegex)
      res.each {|(idstring, args)|
        idstring = idstring.downcase
        if CommandManager.actor_command?(idstring.to_sym)
          @init_commands.push([idstring].concat(args.split))
        end
      }
    end
  end
end

#-------------------------------------------------------------------------------
# This object represents an arbitrary "command". It stores information that
# are used by command windows
#-------------------------------------------------------------------------------
class Game_Command
  
  attr_reader :name       # name of the command
  attr_reader :symbol     # method to call, as a symbol
  attr_reader :ext        # extended data
  
  def initialize(name, symbol, ext=nil)
    @name = name
    @symbol = symbol
    @ext = ext
  end
  
  def name
    @name
  end
  
  #-----------------------------------------------------------------------------
  # Whether the command should be shown
  #-----------------------------------------------------------------------------
  def enabled?(user)
    true
  end
  
  #-----------------------------------------------------------------------------
  # Whether the command is usable
  #-----------------------------------------------------------------------------
  def usable?(user)
    true
  end
  
  #-----------------------------------------------------------------------------
  # Commands objects are used as hash keys, so we hash on the name, symbol,
  # and ext data
  #-----------------------------------------------------------------------------
  def hash
    [@name, @symbol, @ext].hash
  end
  
  #-----------------------------------------------------------------------------
  # Used for hash comparison
  #-----------------------------------------------------------------------------
  def eql?(cmd)
    @name == cmd.name && @symbol == cmd.symbol && @ext == cmd.ext
  end
end

class Game_BattlerCommand < Game_Command
  attr_accessor :battler  # who owns this command
end

#-------------------------------------------------------------------------------
# All battlers will store a list of commands
#-------------------------------------------------------------------------------
class Game_BattlerBase

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  alias :th_command_manager_init :initialize
  def initialize
    th_command_manager_init
    @base_commands = []
    @extra_commands = []
  end
  
  def base_commands
    @base_commands
  end
  
  def extra_commands
    @extra_commands
  end
  
  def commands
    base_commands + extra_commands
  end
  
  #-----------------------------------------------------------------------------
  # Define built-in command methods according to the API specs
  #-----------------------------------------------------------------------------
  def add_command(cmd)
    cmd.battler = self
    @base_commands.push(cmd)
  end
end

class Game_Actor < Game_Battler

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  alias :th_command_manager_setup :setup
  def setup(actor_id)
    th_command_manager_setup(actor_id)
    init_commands
  end
  
  #-----------------------------------------------------------------------------
  # Setup initial commands. The commands are the actor's commands, plus the
  # class commands, in that order.
  #-----------------------------------------------------------------------------
  def init_commands
    @base_commands = []
    initial_commands = actor.initial_commands + self.class.initial_commands
    if initial_commands.empty?
      add_command_attack([])
      add_command_guard([])
      add_command_skill_list([])
      add_command_item([])
    else
      initial_commands.each {|cmd|
        method_name = "add_command_#{cmd[0]}"
        send(method_name, cmd[1..-1]) if respond_to?(method_name)
      }
    end
  end
  
  alias :th_command_manager_change_class :change_class
  def change_class(class_id, keep_exp=false)
    th_command_manager_change_class(class_id, keep_exp)
    init_commands
  end
end

#-------------------------------------------------------------------------------
# Actor command window pulls commands from the actor, instead of hardcoding it
#-------------------------------------------------------------------------------
class Window_ActorCommand < Window_Command

  #-----------------------------------------------------------------------------
  # Overwrite if actor has custom commands
  #-----------------------------------------------------------------------------
  alias :th_command_manager_make_command_list :make_command_list
  def make_command_list
    return unless @actor
    if @actor.commands.empty?
      th_command_manager_make_command_list
    else
      @actor.commands.each do |cmd|
        next unless cmd.enabled?(@actor)
        add_command(cmd.name, cmd.symbol, cmd.usable?(@actor), cmd.ext)
      end
    end
  end
end

class Scene_Battle < Scene_Base
  
  #-----------------------------------------------------------------------------
  # Set handlers for all actor commands
  #-----------------------------------------------------------------------------
  alias :th_command_manager_create_actor_command_window :create_actor_command_window
  def create_actor_command_window
    th_command_manager_create_actor_command_window
    CommandManager.actor_command_table.each do |cmd_sym|
      name = "command_#{cmd_sym}"
      @actor_command_window.set_handler(cmd_sym, method(name)) if respond_to?(name)
    end
  end
end

#===============================================================================
# Some built-in stuff to work with the default engine
#===============================================================================
class Game_Actor < Game_Battler
  def add_command_attack(args)
    cmd = Command_Attack.new(Vocab.attack, :attack)
    add_command(cmd)
  end
  
  def add_command_guard(args)
    cmd = Command_Guard.new(Vocab.guard, :guard)
    add_command(cmd)
  end
  
  def add_command_skill(args)
    return if args.empty?
    stype_id = args[0].to_i
    name = $data_system.skill_types[stype_id]
    cmd = Command_Skill.new(name, :skill, stype_id)
    add_command(cmd)
  end
  
  def add_command_item(args)
    cmd = Command_Item.new(Vocab.item, :item)
    add_command(cmd)
  end
  
  def add_command_skill_list(args)
    added_skill_types.sort.each do |stype_id|
      name = $data_system.skill_types[stype_id]
      cmd = Command_Skill.new(name, :skill, stype_id)
      add_command(cmd)
    end
  end
end

#===============================================================================
# Actor Battle Commands
#===============================================================================
class Command_Attack < Game_BattlerCommand
  def usable?(user)
    user.attack_usable?
  end
end

class Command_Guard < Game_BattlerCommand
  def usable?(user)
    user.guard_usable?
  end
end

class Command_Skill < Game_BattlerCommand
end

class Command_Item < Game_BattlerCommand
end

#===============================================================================
# Use Item command
#===============================================================================
class Command_UseItem < Game_BattlerCommand
  
  # The command is only usable if the user can use it
  def usable?(user)
    user.usable?($data_items[@ext])
  end
end

class Game_Actor < Game_Battler
  
  def add_command_use_item(args)
    id = args[0].to_i
    name = $data_items[id].name
    cmd = Command_UseItem.new(name, :use_item, id)
    add_command(cmd)
  end
end

class Scene_Battle < Scene_Base
  
  def command_use_item
    id = @actor_command_window.current_ext
    @item = $data_items[id]
    BattleManager.actor.input.set_item(id)
    if !@item.need_selection?
      @item_window.hide
      next_command
    elsif @item.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
    $game_party.last_item.object = @item
  end
  
  alias :th_use_item_on_enemy_cancel :on_enemy_cancel
  def on_enemy_cancel
    th_use_item_on_enemy_cancel
    @actor_command_window.activate if @actor_command_window.current_symbol == :use_item
  end
  
  alias :th_use_item_on_actor_cancel :on_actor_cancel
  def on_actor_cancel
    th_use_item_on_actor_cancel
    @actor_command_window.activate if @actor_command_window.current_symbol == :use_item
  end
end

#===============================================================================
# Use Skill Command
#===============================================================================
class Command_UseSkill < Game_BattlerCommand
  
  # The command is only usable if the user can use it
  def usable?(user)
    user.usable?($data_skills[@ext])
  end
end

class Game_Actor < Game_Battler
  
  # This method defines how the command should be set up
  def add_command_use_skill(args)
    id = args[0].to_i
    name = $data_skills[id].name
    cmd = Command_UseSkill.new(name, :use_skill, id)
    
    # now add the command to the list of actor commands
    add_command(cmd)
  end
end

class Scene_Battle < Scene_Base
  
  # This method handles the scene logic when the 
  # player selects this command
  def command_use_skill
    id = @actor_command_window.current_ext
    @skill = $data_skills[id]
    BattleManager.actor.input.set_skill(id)
    BattleManager.actor.last_skill.object = @skill
    if !@skill.need_selection?
      next_command
    elsif @skill.for_opponent?
      select_enemy_selection
    else
      select_actor_selection
    end
  end
  
  alias :th_use_skill_on_enemy_cancel :on_enemy_cancel
  def on_enemy_cancel
    th_use_skill_on_enemy_cancel
    @actor_command_window.activate if @actor_command_window.current_symbol == :use_skill
  end
  
  alias :th_use_skill_on_actor_cancel :on_actor_cancel
  def on_actor_cancel
    th_use_skill_on_actor_cancel
    @actor_command_window.activate if @actor_command_window.current_symbol == :use_skill
  end
end