#==============================================================================#
# ** IEX(Icy Engine Xelion) - Event Monitor
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Debug Tool
# ** Script Type   : Event Count Viewer
# ** Date Created  : 10/18/2010
# ** Date Modified : 07/24/2010
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# *This script should be removed when publishing finished games.
#  This script shows the total number of events on the current map.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  10/18/2010 - V1.0  Started, Base Script
#  12/07/2010 - V1.0  Ressurected and Finished
#  07/17/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment
#
#------------------------------------------------------------------------------#
$imported ||= {}
$imported["IEX_Event_Monitor"] = true

#==============================================================================#
# ** IEX::EVENT_MONITOR
#==============================================================================#
module IEX
  module EVENT_MONITOR
    USE_MONITOR = false
    POSITION = [0, 128, 200]
  end
end

#==============================================================================#
# ** Scene_Map
#==============================================================================#
class Scene_Map < Scene_Base
  
  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------# 
  alias :iex_event_monitor_initialize :initialize unless $@ 
  def initialize( *args, &block )
    iex_event_monitor_initialize( *args, &block )
    if IEX::EVENT_MONITOR::USE_MONITOR
      @iex_event_monitor = Sprite.new
      @iex_event_monitor.visible = false
      @iex_event_monitor.bitmap = Bitmap.new(320, 32)
      @iex_mon_old_event_size = 0
      @iex_event_monitor.bitmap.clear
      @iex_event_monitor.bitmap.font.color = ICY::Colors::LimeGreen
      mon_text = sprintf("%s : %s", "Current # of Events on map", $game_map.events.size.to_s)
      @iex_event_monitor.bitmap.draw_text(0, 0, 320, 32, mon_text)
      @iex_mon_old_event_size = $game_map.events.size
      @iex_event_monitor.x = IEX::EVENT_MONITOR::POSITION[0]
      @iex_event_monitor.y = IEX::EVENT_MONITOR::POSITION[1]
      @iex_event_monitor.z = IEX::EVENT_MONITOR::POSITION[2]
    end  
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :start
  #--------------------------------------------------------------------------#
  alias :iex_event_monitor_start :start unless $@ 
  def start( *args, &block )
    iex_event_monitor_start( *args, &block )
    if @iex_event_monitor != nil
      @iex_event_monitor.visible = true
    end  
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :terminate
  #--------------------------------------------------------------------------#
  alias :iex_event_monitor_terminate :terminate unless $@ 
  def terminate( *args, &block )
    iex_event_monitor_terminate( *args, &block )
    if @iex_event_monitor != nil
      @iex_event_monitor.dispose()
      @iex_event_monitor = nil
    end  
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :iex_event_monitor_update :update unless $@ 
  def update( *args, &block )
    iex_event_monitor_update( *args, &block )
    return if @iex_event_monitor == nil
    @iex_event_monitor.visible = $saver == nil 
    if $game_map.events.size != @iex_mon_old_event_size
      @iex_event_monitor.bitmap.clear
      mon_text = sprintf("%s : %s", "Current # of Events on map", $game_map.events.size.to_s)
      @iex_event_monitor.bitmap.draw_text(0, 0, 320, 32, mon_text)
      @iex_mon_old_event_size = $game_map.events.size
    end  
  end
  
end

#==============================================================================#
# ** END OF FILE
#==============================================================================#  