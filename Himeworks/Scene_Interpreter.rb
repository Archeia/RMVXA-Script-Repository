=begin
#===============================================================================
 Title: Scene Interpreter
 Author: Hime
 Date: Nov 21, 2015
--------------------------------------------------------------------------------
 ** Change log
 Nov 21, 2015
   - fixed bug where item menu crashes when using common event
 Nov 17, 2015
   - create scene message windows, not normal windows
 Oct 24, 2015
   - implement callback function for scene interpreter
 Sep 18, 2015
   - fixed major memory leak issues reported by Sixth
 May 26, 2015 
   - fixed issue with common events called by scene interpreter
 Jan 27, 2015
   - experimental cross-scene common events
 Nov 19, 2014
   - Interpreter is re-created on reset so commands don't continue to run from
     the previous session
 Oct 13, 2014
   - added support for disabling other windows when interpreter takes control
   - moved interpreter into SceneManager as a global scene interpreter
 Sep 5, 2013
   - fixed bug where common events returning to map did not execute properly
 Apr 24, 2013
   - fixed bug where game crashed when no common events were reserved
 Apr 3, 2013
   - Added comment to determine scene to run common event
 Mar 30, 2013
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
 
 This script adds an interpreter and message window to every scene so that
 you can run common events in any scene.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this below Materials and above Main. You should place this above other
 custom scripts.

--------------------------------------------------------------------------------
 ** Usage 
 
 If you would like a common event to run in the current scene, create a
 comment in the common event command list with this string
 
   <run scene: current>
  
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_SceneInterpreter"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Scene_Interpreter
    
    # Run common events directly in scene without going to map
    No_Return_Scene = true
    
    Run_Regex = /<run[-_ ]scene:\s*(\w+)/i
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
module RPG
  class CommonEvent
    
    #---------------------------------------------------------------------------
    # Which scene to run this common event
    #---------------------------------------------------------------------------
    def run_scene
      return @run_scene unless @run_scene.nil?
      parse_comments_scene_interpreter
      return @run_scene
    end
    
    #---------------------------------------------------------------------------
    # Parse the commands for a Run Scene comment
    #---------------------------------------------------------------------------
    def parse_comments_scene_interpreter
      # just an arbitrary default value
      @run_scene = :map 
      @list.each do |cmd|
        if cmd.code == 108 && cmd.parameters[0] =~ TH::Scene_Interpreter::Run_Regex
          @run_scene = $1.downcase.to_sym
        end
      end
    end
  end
end

module SceneManager
  
  class << self
    alias :th_scene_interpreter_run :run
  end
  
  def self.run    
    init_interpreter
    th_scene_interpreter_run
  end
  
  def self.init_interpreter
    @interpreter = Game_SceneInterpreter.new    
  end
  
  def self.interpreter
    @interpreter
  end
end

#-------------------------------------------------------------------------------
# A special interpreter for scenes
#-------------------------------------------------------------------------------
class Game_SceneInterpreter < Game_Interpreter
  attr_accessor :callback
  
  def pause_windows
    SceneManager.scene.store_active_windows
  end
  
  def unpause_windows
    SceneManager.scene.restore_active_windows
  end
  
  def update
    @fiber.resume if @fiber
  end
  
  alias :th_scene_interpreter_run :run
  def run
    th_scene_interpreter_run
    if @callback
      @callback.call
      @callback = nil
    end
  end
end

class Scene_Base 
  
  alias :th_scene_interpreter_start :start
  def start
    @active_windows = []
    @windows = []
    th_scene_interpreter_start
    create_message_window
  end
  
  alias :th_scene_interpreter_post_start :post_start
  def post_start
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      if !ivar.is_a?(Window_SceneMessage) && ivar.is_a?(Window)
        @windows << ivar
      end
    end
    th_scene_interpreter_post_start
  end
  
  #-----------------------------------------------------------------------------
  # Create message window
  #-----------------------------------------------------------------------------
  def create_message_window
    @message_window = Window_SceneMessage.new
  end
  
  alias :th_scene_interpreter_update :update
  def update
    th_scene_interpreter_update
    update_interpreter
  end
  
  #-----------------------------------------------------------------------------
  # Run any common events
  #-----------------------------------------------------------------------------
  def update_interpreter
    
    loop do      
      SceneManager.interpreter.update      
      return if SceneManager.interpreter.running?
      
      # Don't setup the common event if it doesn't run in the current scene
      return if $game_temp.common_event_reserved? && $data_common_events[$game_temp.common_event_id].run_scene != :current
      
      if SceneManager.interpreter.setup_reserved_common_event
        store_active_windows
      else
        restore_active_windows
        return
      end
    end    
  end
  
  #-----------------------------------------------------------------------------
  # Go through all windows and store them if they're active
  #-----------------------------------------------------------------------------
  def store_active_windows
    restore_active_windows
    @windows.each do |win|
      if win.active
        @active_windows.push(win) 
        win.deactivate
      end
    end    
  end
  
  def restore_active_windows
    @active_windows.each do |win|
      win.activate
    end
    @active_windows = []
  end
end

class Scene_ItemBase < Scene_MenuBase
  alias :th_scene_interpreter_check_common_event :check_common_event
  def check_common_event
    return if !$game_temp.common_event_reserved? || ($game_temp.common_event_reserved? && $data_common_events[$game_temp.common_event_id].run_scene == :current)
    SceneManager.interpreter.callback = Proc.new { @actor_window.refresh unless @actor_window.disposed? }
    th_scene_interpreter_check_common_event
  end
end

class Window_SceneMessage < Window_Message
  
  #-----------------------------------------------------------------------------
  # These are all random z values
  #-----------------------------------------------------------------------------
  alias :th_scene_interpreter_initialize :initialize
  def initialize
    super
    self.z = 500
    @gold_window.z = 500
    @item_window.z = 500
    @number_window.z = 500
    @choice_window.z = 500
  end
end

class Game_Interpreter
  attr_reader :index
  
  alias :th_scene_interpreter_command_117 :command_117
  def command_117
    common_event = $data_common_events[@params[0]]
    if common_event && common_event.run_scene == :current      
      # hack solution. When a common event is called, we check whether
      # it should run in the current scene or not. If it should, we delegate
      # it to the scene interpreter. However, common events from the
      # scene interpreter run into problems
      if self.is_a?(Game_SceneInterpreter)
        child = Game_SceneInterpreter.new(@depth + 1)
        child.setup(common_event.list, same_map? ? @event_id : 0)
        child.run
      else
        SceneManager.interpreter.setup(common_event.list)
        Fiber.yield while SceneManager.interpreter.running?
      end
    else
      th_scene_interpreter_command_117
    end
  end
end

# Memory leak situation is created when the following scenes create their own
# message windows, overwriting the one created when the scene started. Issue reported and
# fix provided by Sixth
class Scene_Map
  def create_message_window
    @message_window = Window_SceneMessage.new unless @message_window && !@message_window.disposed?
  end
end

class Scene_Battle
  def create_message_window
    @message_window = Window_SceneMessage.new unless @message_window && !@message_window.disposed?
  end
end