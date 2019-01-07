=begin
 ■ Information      ╒═════════════════════════════════════════════════════════╛
 EST - Suikoden Save Scene
 by Estriole
 v.1.2
 
 ■ Changelog        ╒═════════════════════════════════════════════════════════╛
 v1.0 2013.07.02     >     Initial Release
 v1.1 2013.09.26     >     Add confirmation window (Yes / No)
                     >     Patch for moghunter adv_load bar. 
                           put this script below moghunter adv_load bar script.
 v1.2 2013.11.14     >     Compatibility with custom resolution script.
                           also add config for max save. if using resolution
                           640x480 it can fit 12 save slot.
                           
 ■ Introduction     ╒═════════════════════════════════════════════════════════╛
   This script recreate Suikoden II Save and Load Scene.
   
 ■ Requirement     ╒═════════════════════════════════════════════════════════╛
   This Script requires YANFLY Party Script to make it work flawlessly
 if not using YANFLY Party script. then the formation won't be listed.

 ■ How to Use     ╒═════════════════════════════════════════════════════════╛
 > put "savebackground" image (default... or whatever you set in configuration)
 in your Graphics/System/ folder. *required...
 > You can customize in module estriole whether you want to use party leader as
 save name (default set to false). if true it will use leader name instead of
 fixed actor. if false you can define which actor that used as the save name.
 > $$$ Profit $$$
 
=end
module ESTRIOLE
  module SUIKODEN
    module SAVE
      #if true it will use $game_party.leader name as the save file name
      SUIKODEN_SAVE_USE_LEADER = false
      #if use leader false. it will use $game_actor with above id instead
      SUIKODEN_SAVE_USE_ACTOR = 1
      #save background filename
      SUIKODEN_SAVE_BG_NAME = "savebackground"
      #maximum save slot. if using resolution 640x480 it fit 12 save slot
      MAX_SAVE = 9
    end
  end
end

# Save/Load Scene Hijack Patch
module SceneManager
  class << self; alias est_suikosave_menu_hijack_call call; end  
  def self.call(scene_class)
    scene_class = Scene_SuikoSave if scene_class == Scene_Save
    scene_class = Scene_SuikoLoad if scene_class == Scene_Load
    est_suikosave_menu_hijack_call(scene_class)
  end
end

module DataManager
  def self.savefile_max
    return ESTRIOLE::SUIKODEN::SAVE::MAX_SAVE
  end
end

class Window_SuikoConfirm < Window_Command 
include ESTRIOLE::SUIKODEN::SAVE
  def initialize
    dw = 100
    dh = fitting_height *2
    dx = Graphics.width/2 - dw/2
    dy = Graphics.height/2 - dh/2
    @window_width = dw
    @window_height = dh
    super(dx,dy)
    select_last
    deactivate
    hide
  end  
  def window_width; return @window_width ;end
  def window_height; return @window_height ;end
  def current_item_enabled?; true; end
  def command_enabled?(index); true; end
  def ok_enabled?; true; end
  def call_ok_handler
    current_data == "Yes" ? call_handler(:ok) : call_handler(:cancel)
    select_last
  end    
  def select_last
    select(0)
  end
  def make_command_list
    @list = ["Yes","No"]  
  end
  def command_name(index)
    @list[index]
  end 
end

class Scene_SuikoFile < Scene_Base
include ESTRIOLE::SUIKODEN::SAVE
  def start
    super
    draw_save_bg
    create_save_file_window
    create_save_confirm_window
    create_help_window
    create_info_window
  end
  def update
    super
    @info_window.set_file(@save_file_window.index) if @info_window
  end
  def draw_save_bg
    @background = Sprite.new
    @background.bitmap = Cache.system(SUIKODEN_SAVE_BG_NAME)
  end
  def create_save_file_window
    @save_file_window = Window_Suiko_SaveFile.new
    @save_file_window.set_handler(:ok,method(:on_save_ok))    
    @save_file_window.set_handler(:cancel,method(:return_scene))    
  end
  def create_save_confirm_window
    @save_confirm_window = Window_SuikoConfirm.new
    @save_confirm_window.set_handler(:ok,method(:on_confirm_ok))    
    @save_confirm_window.set_handler(:cancel,method(:on_confirm_cancel))    
  end
  def on_save_ok
    @help_window.set_text(confirm_window_text)
    @save_confirm_window.show.activate
    @save_file_window.deactivate
  end
  def on_confirm_ok
    @save_file_window.activate
  end
  def on_confirm_cancel
    @save_confirm_window.select_last
    @save_confirm_window.hide.deactivate
    @help_window.set_text(help_window_text)
    @save_file_window.activate
  end
  def help_window_text
    Vocab::SaveMessage
  end
  def create_help_window
    @help_window = Window_SuikoFileHelp.new(1)
    @help_window.set_text(help_window_text)
  end
  def create_info_window
    @info_window = Window_SuikoFileMember.new
    @info_window.y = Graphics.height - 120
    @info_window.set_file(0)
  end
  def terminate
    super
    @background.bitmap.dispose
    @background.dispose
  end
end

class Scene_SuikoSave < Scene_SuikoFile
  def on_confirm_ok
    if DataManager.save_game(@save_file_window.index)
      on_save_success
    else
      Sound.play_buzzer
    end    
    @save_confirm_window.select_last
    @save_confirm_window.hide.deactivate
    @save_file_window.activate
  end
  def on_save_success
    Sound.play_save
    @save_file_window.refresh
    @info_window.refresh
  end    
  def help_window_text
    Vocab::SaveMessage
  end
  def confirm_window_text
    "Okay to Save to this slot?"
  end
end
class Scene_SuikoLoad < Scene_SuikoFile
  def on_save_ok
    if DataManager.load_game(@save_file_window.index)
      super
    else
    Audio.se_stop 
    Sound.play_buzzer
    @save_file_window.activate    
    end
  end
  def on_confirm_ok
    if DataManager.load_game(@save_file_window.index)
      on_load_success
    else
      Sound.play_buzzer
    end
    @save_confirm_window.select_last
    @save_confirm_window.hide.deactivate
    @save_file_window.activate
  end
  def on_load_success
    Sound.play_load
    fadeout_all
    $game_system.on_after_load
    SceneManager.goto(Scene_Map)
  end      
  def help_window_text
    Vocab::LoadMessage
  end
  def confirm_window_text
    "Okay to Load from this slot?"
  end
end

class Window_SuikoFileMember < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(line_number = 4)
    super(10, line_height, Graphics.width-20, fitting_height(line_number))
    @level = "--"
    @area  = "--------"
    @formation = [0,0,0,0,0,0]
  end
  def set_file(index)
    return if @index == index
    @index = index
    refresh
  end
  def refresh
    contents.clear
    draw_info
  end
  def get_info
    header = DataManager.load_header(@index)
    @level = header ? header[:leader_level] : "--"
    @area  = header ? header[:map_name] : "--------"
    @formation = header ? header[:formation] ? header[:formation] : [0,0,0,0,0,0] : [0,0,0,0,0,0]
  end
  def draw_info
    get_info
    actors = @formation.collect{|pos|
    pos == 0 ? "----------" : $game_actors[pos].name
    }
    change_color(system_color)
    draw_text(0,0,width,line_height,"Level")
    draw_text(0,line_height,width,line_height,"Area")
    change_color(normal_color)
    draw_text(70,0,width-50,line_height,"#{@level}")
    draw_text(70,line_height,width-50,line_height,"#{@area}")
    reset_font_settings
    #draw_formation
    change_color(system_color)
    draw_text(0,2*line_height,width,line_height,"1. ")
    draw_text(150,2*line_height,width,line_height,"2. ")
    draw_text(300,2*line_height,width,line_height,"3. ")
    draw_text(0,3*line_height,width,line_height,"4. ")
    draw_text(150,3*line_height,width,line_height,"5. ")
    draw_text(300,3*line_height,width,line_height,"6. ")
    change_color(normal_color)
    draw_text(0+20,2*line_height,width-20,line_height,"#{actors[0]}")
    draw_text(150+20,2*line_height,width-20,line_height,"#{actors[1]}")
    draw_text(300+20,2*line_height,width-20,line_height,"#{actors[2]}")
    draw_text(0+20,3*line_height,width-20,line_height,"#{actors[3]}")
    draw_text(150+20,3*line_height,width-20,line_height,"#{actors[4]}")
    draw_text(300+20,3*line_height,width-20,line_height,"#{actors[5]}")
    
  end
end
  
class Window_SuikoFileHelp < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(line_number = 1)
    super(50, line_height, Graphics.width-100, fitting_height(line_number))
  end
  #--------------------------------------------------------------------------
  # ● テキスト設定
  #--------------------------------------------------------------------------
  def set_text(text)
    if text != @text
      @text = text
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● クリア
  #--------------------------------------------------------------------------
  def clear
    set_text("")
  end
  #--------------------------------------------------------------------------
  # ● アイテム設定
  #     item : スキル、アイテム等
  #--------------------------------------------------------------------------
  def set_item(item)
    set_text(item ? item.description : "")
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_text_ex(4, 0, @text)
  end
end

class Window_Suiko_SaveFile < Window_Command 
include ESTRIOLE::SUIKODEN::SAVE
  def initialize
    dx = 0
    dy = 80
    dw = Graphics.width
    dh = Graphics.height - 80
    @window_width = dw
    @window_height = dh
    @border_window = {}
    super(dx,dy)
    self.opacity = 0
    select_last
  end
  def dispose
    super
    @border_window.each_value do |window|
      window.dispose if window && !window.disposed?
    end
  end
  def item_max
    DataManager.savefile_max
  end
  
  def col_max
    3
  end
  def item_width
    (@window_width - 2 * standard_padding)/ 3 - 2 * standard_padding
  end
  def item_height
    3*line_height-2*standard_padding
  end  
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing)
    rect.y = index / col_max * (item_height + spacing/2)
    rect
  end
  
  def window_width; return @window_width ;end
  def window_height; return @window_height ;end
  def current_item_enabled?; true; end
  def command_enabled?(index); true; end
  def ok_enabled?; true ; end
  def call_ok_handler; call_handler(:ok); end
  def select_last
    select(0)
  end
  def make_command_list
    @list = Array.new(item_max) do |i|
      @list[i] = "#{Vocab::File} #{i+1}"
    end
    return @list
  end
  def command_name(index)
    @list[index]
  end 
  def draw_item(index)
    @border_window[index].dispose if @border_window[index] && !@border_window[index].disposed? 
    #@border_window[index] = Window_Base.new(self.x+item_rect(index).x+3,self.y+item_rect(index).y + 5,168,63)
    dw = item_width + 1.25 * standard_padding
    dh = item_height + 1.25 * standard_padding
    @border_window[index] = Window_Base.new(self.x+item_rect(index).x+3,self.y+item_rect(index).y + 5,dw,dh)
    @border_window[index].z = self.z - 10
    header = DataManager.load_header(index)
    return draw_text(item_rect(index).x,item_rect(index).y,item_width,item_height,"No Save File", 1) if !header
    contents.font.bold = true
    contents.font.size = 14
    change_color(normal_color)
    draw_text(10 + item_rect(index).x,item_rect(index).y,item_width,line_height,"#{header[:leader]}", 3)
    change_color(system_color)
    draw_text(10 + item_rect(index).x,item_rect(index).y + line_height,item_width,line_height,"Playtime", 3)
    change_color(normal_color)
    draw_text(10 + item_rect(index).x+item_width/2,item_rect(index).y + line_height,item_width/2,line_height,"#{header[:playtime_s]}", 3)
    reset_font_settings
  end
end

module DataManager
include ESTRIOLE::SUIKODEN::SAVE
  class << self; alias est_sksave_saveload_make_save_header make_save_header; end
  def self.make_save_header
      header = est_sksave_saveload_make_save_header
      header[:leader] = $game_actors[SUIKODEN_SAVE_USE_ACTOR].name
      header[:leader] = $game_party.leader.name rescue $game_actors[SUIKODEN_SAVE_USE_ACTOR].name if SUIKODEN_SAVE_USE_LEADER
      header[:leader_level] = $game_actors[SUIKODEN_SAVE_USE_ACTOR].level
      header[:leader_level] = $game_party.leader.level rescue $game_actors[SUIKODEN_SAVE_USE_ACTOR].level if SUIKODEN_SAVE_USE_LEADER
      header[:map_name] = $game_map.display_name
      header[:formation] = $game_party.battle_members_array if $imported["YEA-PartySystem"] == true
      header
  end  
end  

#moghunter adv_load_bar patch
if $mog_rgss3_advanced_load_bar
class Scene_SuikoSave < Scene_SuikoFile
  
 #--------------------------------------------------------------------------
 # ● On Save Sucess
 #--------------------------------------------------------------------------                
  alias mog_advloadbar_on_save_success on_save_success
  def on_save_success
      mog_advloadbar_on_save_success
      $game_temp.loadbar_type = 1
      SceneManager.call(Scene_Load_Bar)    
  end
  
end

#=============================================================================
# ■ Scene Load
#=============================================================================
class Scene_SuikoLoad < Scene_SuikoFile
  
  #--------------------------------------------------------------------------
  # ● On Load Success
  #--------------------------------------------------------------------------
  alias mog_advloadbar_on_load_success on_load_success
  def on_load_success
      mog_advloadbar_on_load_success
      $game_system.save_bgm      
      RPG::BGM.stop
      $game_temp.loadbar_type = 0
      SceneManager.call(Scene_Load_Bar)              
  end
end
end