#===============================================================================
# Compatibility patch with Scene Interpreter and Yanfly Ace Menu Engine
# This script allows you to run common event commands in the menu
#
# Place this script below both required scripts
#===============================================================================
class Scene_Menu < Scene_MenuBase
  def command_common_event
    event_id = @command_window.current_ext
    return return_scene if event_id.nil?
    return return_scene if $data_common_events[event_id].nil?
    $game_temp.reserve_common_event(event_id)    
    return_scene unless $data_common_events[event_id].run_scene == :current
    @command_window.activate
  end
end
