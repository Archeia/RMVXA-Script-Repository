#==============================================================================#
# ** IEX(Icy Engine Xelion) - Spr_Char Monitor
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Debug Tool
# ** Script Type   : Sprite Character Count Viewer
# ** Date Created  : 10/27/2010
# ** Date Modified : 10/27/2010
# ** Version       : ??
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# *This script should be removed when publishing finished games.
#  This script shows the total number of sprite characters on the current map.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# 
# 10/27/2010 - Started, Base Script
# 12/07/2010 - Ressurected and Finished
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment
#
#------------------------------------------------------------------------------#
$imported = {} if $imported == nil
$imported["IEX_Spr_Char_Monitor"] = true

module IEX
  module SPR_CHAR_MONITOR
    USE_MONITOR = false
    POSITION = [0, 168, 200]
  end
end

class Spriteset_Map
  
  def characters_size
    return @character_sprites.size
  end
  
end

class Scene_Map < Scene_Base
  
  alias iex_spr_character_monitor_initialize initialize unless $@ 
  def initialize(*args)
    iex_spr_character_monitor_initialize(*args)
    if IEX::SPR_CHAR_MONITOR::USE_MONITOR
      @iex_spr_character_monitor = Sprite.new
      @iex_spr_character_monitor.visible = false
      @iex_spr_character_monitor.bitmap = Bitmap.new(320, 32)
      @iex_mon_old_spr_character_size = 0
      @iex_spr_character_monitor.bitmap.clear
      @iex_spr_character_monitor.bitmap.font.color = ICY::Colors::LimeGreen
      size = 0#@spriteset.characters_size
      mon_text = sprintf("%s : %s", "Current # of Characters on map", size)
      @iex_spr_character_monitor.bitmap.draw_text(0, 0, 320, 32, mon_text)
      @iex_mon_old_spr_character_size = 0
      @iex_spr_character_monitor.x = IEX::SPR_CHAR_MONITOR::POSITION[0]
      @iex_spr_character_monitor.y = IEX::SPR_CHAR_MONITOR::POSITION[1]
      @iex_spr_character_monitor.z = IEX::SPR_CHAR_MONITOR::POSITION[2]
    end  
  end
  
  alias iex_spr_character_monitor_start start unless $@ 
  def start(*args)
    iex_spr_character_monitor_start(*args)
    if @iex_spr_character_monitor != nil
      @iex_spr_character_monitor.visible = true
    end  
  end
  
  alias iex_spr_character_monitor_terminate terminate unless $@ 
  def terminate(*args)
    iex_spr_character_monitor_terminate(*args)
    if @iex_spr_character_monitor != nil
      @iex_spr_character_monitor.dispose
      @iex_spr_character_monitor = nil
    end  
  end
  
  alias iex_spr_character_monitor_update update unless $@ 
  def update(*args)
    iex_spr_character_monitor_update(*args)
    return if @iex_spr_character_monitor == nil
    return if @spriteset == nil
    @iex_spr_character_monitor.visible = $saver == nil 
    if @spriteset.characters_size != @iex_mon_old_spr_character_size
      @iex_spr_character_monitor.bitmap.clear
      size = @spriteset.characters_size
      mon_text = sprintf("%s : %s", "Current # of Characters on map", size)
      @iex_spr_character_monitor.bitmap.draw_text(0, 0, 320, 32, mon_text)
      @iex_mon_old_spr_character_size = @spriteset.characters_size
    end  
  end
  
end

  