#===============================================================================
#
#                             *Variable HUD*
#                              Version: 1.1
#                            Author: Euphoria
#                            Date: 4/19/2014
#                        Euphoria337.wordpress.com
#                        
#===============================================================================
#Important:
#==============================================================================
#History: 1.1) ON/OFF Switch Added                        
#==============================================================================
#Terms of Use: This script is free to use in non-commercial games only as long
#              as you credit me (the author). For Commercial use contact me.
#==============================================================================                           
#Instructions: To change the icons that appear on the HUD go into the editable
#              region and change the number for each to an icon index number of
#              your choice. The HUD is turned on or off with game switch number
#              1, or change it below in the editable region.
#===============================================================================
# Editable Region Below  <><><><><><><><><><><><><><><><><><><><><><><><><><><>
#===============================================================================
module Euphoria
  module Variable_Icons
    
    VAR1_ICON = 125       #Variable 1 Icon Index Number
    
    VAR2_ICON = 338       #Variable 2 Icon Index Number
    
    SWITCH    = 1         #Switch To Turn HUD On
    
  end
end
#===============================================================================
# DO NOT EDIT BELOW HERE <><><><><><><><><><><><><><><><><><><><><><><><><><><>
#===============================================================================
$imported ||= {}
$imported["EuphoriaVariableHUD"] = true
#===============================================================================
# Create Variable HUD  <><><><><><><><><><><><><><><><><><><><><><><><><><><><>
#===============================================================================
class Window_Variable < Window_Base
  
  def initialize(x, y, width, height)
    super(0, 0, 544, 414)
    refresh_and_draw
  end
  
  def refresh_and_draw
    self.contents.clear
    draw_icon(Euphoria::Variable_Icons::VAR1_ICON, 0, 0, enabled = true)
    draw_icon(Euphoria::Variable_Icons::VAR2_ICON, 0, 25, enabled = true)
    draw_text(0, 0, 90, 25, $game_variables[1], 1) 
    draw_text(0, 25, 90, 25, $game_variables[2], 1) 
  end
end
#===============================================================================
# Show Variable HUD  <><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
#===============================================================================
class Scene_Map < Scene_Base
  
  alias euphoria_variableehud_scenemap_start_3 start
  def start
    euphoria_variableehud_scenemap_start_3
    create_varhud_window
  end
  
  def create_varhud_window
    @hud = Window_Variable.new(0, 0, 544, 414)
    @hud.opacity = 0
    if $game_switches[Euphoria::Variable_Icons::SWITCH]
    @hud.visible = true
    else @hud.visible = false
    end
  end
  
  alias euphoria_variableehud_scenemap_update_3 update
  def update
    if $game_switches[Euphoria::Variable_Icons::SWITCH]
    @hud.visible = true
    else
    @hud.visible = false
    end
    euphoria_variableehud_scenemap_update_3
    @hud.refresh_and_draw
  end
  
end