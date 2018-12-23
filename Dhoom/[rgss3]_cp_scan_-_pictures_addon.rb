#===============================================================================
# CP Scan - Picture Addon
# by DrDhoom
# v1.0a - 9-22-14
#===============================================================================

module Dhoom
  module CPScan    
    #True : Use battler picture, False : Use picture in Pictures folder
    Use_Battler_Picture = true
    
    #If not using battler picture. Put picture in Pictures folder. 
    #No picture will be displayed if there is no matching filename.
    
    #"Filename_Prefix+Battler name"
    #Example: "CP_Slime", "CP_Bat"
    Filename_Prefix = "CP_"
    
    #Picture coordinate
    Pictures_XY = [0,208]
    #Picture starting point, 1-9
    Pictures_StartPoint = 4
  end
end

class Scene_Battle < Scene_Base
  alias dhoom_cpscan_battle_create_scan_windows create_scan_windows
  def create_scan_windows
    dhoom_cpscan_battle_create_scan_windows
    @scan_pict = Sprite.new(@scan_viewport)    
  end
  
  def refresh_cpscan_battler_picture
    enemy = $game_troop.alive_members[@scan_bio.index].enemy
    if Dhoom::CPScan::Use_Battler_Picture
      @scan_pict.bitmap = Cache.battler(enemy.battler_name, enemy.battler_hue)
    else
      file = Dhoom::CPScan::Filename_Prefix+enemy.name
      begin
        @scan_pict.bitmap = Cache.picture(file) 
      rescue
        @scan_pict.bitmap = Bitmap.new(32,32)
        return
      end
    end
    start = Dhoom::CPScan::Pictures_StartPoint
    @scan_pict.ox = 0 if [1,4,7].include?(start)
    @scan_pict.ox = @scan_pict.width if [3,6,9].include?(start)
    @scan_pict.ox = @scan_pict.width/2 if [2,5,8].include?(start)
    @scan_pict.oy = 0 if [7,8,9].include?(start)
    @scan_pict.oy = @scan_pict.height if [1,2,3].include?(start)
    @scan_pict.oy = @scan_pict.height/2 if [4,5,6].include?(start)
    @scan_pict.x = Dhoom::CPScan::Pictures_XY[0]
    @scan_pict.y = Dhoom::CPScan::Pictures_XY[1]
  end
  
  alias dhoom_cpscan_battle_next_enemy next_enemy
  def next_enemy
    dhoom_cpscan_battle_next_enemy
    refresh_cpscan_battler_picture
  end
  
  alias dhoom_cpscan_battle_last_enemy last_enemy
  def last_enemy
    dhoom_cpscan_battle_last_enemy
    refresh_cpscan_battler_picture
  end
  
  alias dhoom_cpscan_battle_open_scan_window open_scan_window
  def open_scan_window
    dhoom_cpscan_battle_open_scan_window
    @scan_pict.visible = true
    refresh_cpscan_battler_picture    
  end
  
  alias dhoom_cpscan_battle_close_scan_window close_scan_window
  def close_scan_window
    dhoom_cpscan_battle_close_scan_window
    @scan_pict.visible = false
  end
  
  alias dhoom_cpscan_battle_terminate terminate
  def terminate
    dhoom_cpscan_battle_terminate
    @scan_pict.dispose
  end
end