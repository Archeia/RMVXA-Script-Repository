#┌──────────────────────────────────────────────────────────────────────────────
#│
#│                              *Simple HUD*
#│                              Version: 1.0
#│                            Author: Euphoria
#│                            Date: 4/18/2014
#│                        Euphoria337.wordpress.com
#│
#├──────────────────────────────────────────────────────────────────────────────
#│■ Important: None
#├──────────────────────────────────────────────────────────────────────────────
#│■ History: None
#├──────────────────────────────────────────────────────────────────────────────
#│■ Terms of Use: This script is free to use in non-commercial games only as 
#│                long as you credit me (the author). For commercial use contact
#│                me.
#├──────────────────────────────────────────────────────────────────────────────                           
#│■ Instructions: To change the icons that appear on the HUD go into the 
#│                editable region and change the number for each to an icon 
#│                index number of your choice.
#└──────────────────────────────────────────────────────────────────────────────
$imported ||= {}
$imported["EuphoriaSimpleHUD"] = true
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Editable Region Below
#└──────────────────────────────────────────────────────────────────────────────
module Euphoria
  module Icons
    
    ICON_NAME = 188     #Icon Index Number For Name
    
    ICON_HP   = 113     #Icon Index Number For HP
    
    ICON_MP   = 114     #Icon Index Number For MP
    
  end
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ DO NOT EDIT BELOW HERE
#└──────────────────────────────────────────────────────────────────────────────


#┌──────────────────────────────────────────────────────────────────────────────
#│■ Create HUD
#└──────────────────────────────────────────────────────────────────────────────
class Window_EuphoriaHUD < Window_Base
  
  def initialize
    super(0, 0, 544, 414)
    refresh
  end
  
  def refresh
    self.contents.clear
    actor = $game_party.leader
    draw_icon(Euphoria::Icons::ICON_NAME, 0, 25, enabled = true)
    draw_icon(Euphoria::Icons::ICON_HP, 0, 0, enabled = true)
    draw_icon(Euphoria::Icons::ICON_MP, 0, 50, enabled = true)
    draw_actor_name(actor, 32, 25, width = 112)
    draw_actor_hp(actor, 32, 0, width = 120)
    draw_actor_mp(actor, 32, 50, width = 120)
  end

end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ Display HUD
#└──────────────────────────────────────────────────────────────────────────────
class Scene_Map < Scene_Base
  
  alias euphoria_simplehud_scenemap_start_1 start
  def start
    euphoria_simplehud_scenemap_start_1
    create_hud_window
  end
  
  def create_hud_window
    @hud = Window_EuphoriaHUD.new
    @hud.opacity = 0
  end
  
  alias euphoria_simplehud_scenemap_update_1 update
  def update
    euphoria_simplehud_scenemap_update_1
    @hud.refresh
  end
  
end
#┌──────────────────────────────────────────────────────────────────────────────
#│■ End Script
#└──────────────────────────────────────────────────────────────────────────────