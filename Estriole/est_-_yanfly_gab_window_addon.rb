=begin
 ■ Information      ╒═════════════════════════════════════════════════════════╛
 EST - YANFLY GAB WINDOW ADDON v1.0
 by Estriole
 
 ■ License          ╒═════════════════════════════════════════════════════════╛
 Free to use in all project (except the one containing pornography)
 as long as i credited (ESTRIOLE). 
 
 ■ Extra Credit   ╒═════════════════════════════════════════════════════════╛ 
 if you use this script... also credit Tsukihime since she invented the idea 
 of creating gab window in scene base.
 
 ■ Support          ╒═════════════════════════════════════════════════════════╛
 While I'm flattered and I'm glad that people have been sharing and asking
 support for scripts in other RPG Maker communities, I would like to ask that
 you please avoid posting my scripts outside of where I frequent because it
 would make finding support and fixing bugs difficult for both of you and me.
   
 If you're ever looking for support, I can be reached at the following:
 ╔═════════════════════════════════════════════╗
 ║       http://www.rpgmakervxace.net/         ║
 ╚═════════════════════════════════════════════╝
 pm me : Estriole.
 
 ■ Requirement     ╒═════════════════════════════════════════════════════════╛
 -Gab Window
  (http://yanflychannel.wordpress.com/rmvxa/field-scripts/gab-window/)  
 put my script below yanfly script
  
 ■ Introduction     ╒═════════════════════════════════════════════════════════╛
 This script is addon for yanfly gab window script. this addon make the gab window
 can be used in any scenes. this addon also have ability to manipulate gab window
 position(x,y), height, z, base time, time per text, 
 
 this addon also add draw face and draw icon feature.
 
 draw face feature means we can draw face beside the gab window text.
 useful for character giving information in battle for example.
 draw icon features means we can draw icon beside the gab window text.
 useful for getting item popup for example.
 
 this addon make us able to show some actor saying in battle giving some hints
 like enemy weakness, etc. (originally written for that). but there might be
 something else can be done. the limit is your imagination.
 
 ■ Features         ╒═════════════════════════════════════════════════════════╛
 - gab window in any scenes
 - set the gab window position
 - set the gab window z value
 - set the gab window height
 - set the base time and time for text for the gab window
 - use different call for modded position etc so it won't break existing project
 - draw face feature
 - draw icon feature
 
 ■ Changelog        ╒═════════════════════════════════════════════════════════╛
 v1.0 2013.10.27           Initial Release
 
 ■ Compatibility    ╒═════════════════════════════════════════════════════════╛
 - if using this script. no need to install Tsukihime Gab Manager since some of
 the code already present in this script.
 
 ■ How to use     ╒═════════════════════════════════════════════════════════╛
 0) if you already use yanfly gab window in your project. don't worry. it will
 stay the same. it won't be affected by the modding you done since if calling
 the old script call provided by yanfly. it will reset gab window to default value.
 
 1) this is list of script call you can call before calling gab window
 to modify the gab window:
 -> gab_x(num)
 modify the gab window x value to num
 -> gab_y(num)
 modify the gab window y value to num
 -> gab_z(num)
 modify the gab window z value to num
 -> gab_h(row_num)
 change the height of the gab window. row_num is number of rows your text is.
 -> gab_h(pixel, false)
 change the height of the gab window. change pixel to how many pixel you want.
 -> gab_base_time(num)
 change the gab window base time to num (see yanfly explanation about time per text)
 -> gab_time_per_text(num)
 change the gab window time per text to num (see yanfly explanation about time per text)
 -> reset_gab
 reset all changes to gab window. better if called before any modification.
 
 after finish modifying the gab window as you want. call this script call:

 gabmod(string, actor_id / filename, char_index/face_index/icon_index, mode)
 
 string => your string here
 actor_id   => id of the actor if you want to use face set
            => this can be replaced by filename
            => if using :icon mode. change this to any string
 char_index => index of the char. if using face mode it will become face index.
 mode       => if not set it will use charset if there's actor specified.
               :face => will draw faceset instead of charset
               :icon => will draw icon based on char_index value
 
 note: if you use gab(string, actor_id / filename, char_index/face_index, mode)
 it will reset the gab window first. i do this so existing project don't break.
 
 note2: if using :face mode. you need to set the height of gab window to minimum
 three rows so it fit the face graphic.
 
 note3: changing scenes will reset gab window.
 
 example script call:
 1)
 ----------------------------------------------
  gab_x(100)
  gab_y(180)
  gab_h(3)
  txt = "i move the gab window to this pos\n"+
  "then i change to 3 rows height\n"+
  "then i also use face mode"
  gabmod(txt,3,nil,:face)
 -----------------------------------------------
 will place the gab window to [100, 180] position
 set the height to 3 rows
 then it will show actor 3 face

 2)
 ----------------------------------------------
  gab_base_time(10)
  gab_time_per_text(1)
  txt = "this is gab icon mode"
  gabmod(txt,"icon",10,:icon)
 -----------------------------------------------
 will set gab window base time to 10
 will set gab window time per text to 1
 then also draw icon 10 before the text
 
 3)
 -----------------------------------------------------
 txt = "if use gab(args) it will reset to default gab"
 gab(txt,1)
 -----------------------------------------------------
 since this use gab(args) instead of gabmon(args)
 it will reset all modification before this call.
 (if using gabmod. modification from other event could carry on if not resetted).
 also it will draw charset actor 1 beside the text
 
 if you're confused see the demo for example
 
 ■ Author's Notes   ╒═════════════════════════════════════════════════════════╛
 This script created because i want more control over gab window. any suggestion
 welcomed. 
=end

module ESTRIOLE
  #by default if you talk to same gab it won't show again.
  #unless you talk with another gab then talk again then it will shown.
  #set this to true so you can show the same gab again immediately
  GAB_REPEAT = true
end
                  
                  
class Scene_Base
#alias method start to create gab window  
  alias :est_gab_addon_start :start
  def start
    est_gab_addon_start
    create_gab_window
  end
#alias method terminate to clear gab window
  alias :est_gab_addon_terminate :terminate
  def terminate
    est_gab_addon_terminate
    clear_gab if @gab_window && !@gab_window.disposed?
  end  
  def create_gab_window
    @gab_window = Window_Gab.new
    @gab_window.z = 200
  end
  
# gab placement and z value manipulation
  def gab_x(num)
    @gab_window.x = num if @gab_window
  end
  def gab_y(num)
    @gab_window.y = num if @gab_window
  end
  def gab_z(num)
    @gab_window.z = num if @gab_window
  end

# set gab height
# had to dispose old gab and create new one for new height >.<.  
  def gab_h(num, fh = true)
    dx = @gab_window.x
    dy = @gab_window.y
    dz = @gab_window.z
    dbt = @gab_window.base_time
    dtpt = @gab_window.time_per_text
    @gab_window.dispose
    @gab_window = Window_Gab.new(num,fh)
    gab_x(dx)
    gab_y(dy)
    gab_z(dz)
    gab_base_time(dbt)
    gab_time_per_text(dtpt)
    @gab_window.refresh
  end
# set gab window base time  
  def gab_base_time(num)
    @gab_window.base_time = num
  end
# set gab time per text
  def gab_time_per_text(num)
    @gab_window.time_per_text = num
  end
# reset all gab modification to default value
  def reset_gab
    @gab_window.dispose
    @gab_window = Window_Gab.new
  end
# new method to make all scene can call gab window  
  def setup_gab_window(text, graphic = nil, index = nil, mode = nil)
    @gab_window.setup(text, graphic, index, mode)
  end
# new method to make all scene can clear gab window
  def clear_gab
    @gab_window.clear
  end
end

#compatibility patch so can pass mode in scene map too
class Scene_Map < Scene_Base
  def setup_gab_window(text, graphic = nil, index = nil, mode = nil)
    @gab_window.setup(text, graphic, index, mode)
  end
end

class Window_Gab < Window_Base
#overwriting initialization for different height value support
  def initialize(dh = nil, fh = nil)
    dx = -standard_padding
    dy = YEA::GAB_WINDOW::Y_LOCATION
    dh = fitting_height(2) if !dh
    dh = fitting_height(dh+1) if fh
    super(dx, dy, Graphics.width + standard_padding, dh)
    setup_message_font if $imported["YEA-MessageSystem"]
    clear
  end
#overwriting setup so it can support mode like face and icon
#also modify it to support gab repeat (talk to same gab once again and gab execute again)
  def setup(text, graphic, index, mode = nil)
    return if settings_match?(text, graphic, index) && !ESTRIOLE::GAB_REPEAT
    @text = text
    @graphic = graphic
    @index = index
    @mode = mode
    @opacity_timer = base_time
    @opacity_timer += time_per_text * @text.size
    refresh
  end
#attr reader for base time
  def base_time
    @base_time = YEA::GAB_WINDOW::BASE_TIME if !@base_time
    return @base_time
  end
#attr writer for base time
  def base_time=(time)
    return if @base_time == time
    @base_time = time
  end
#attr reader for time_per_text
  def time_per_text
    @time_per_text = YEA::GAB_WINDOW::TIME_PER_TEXT if !@time_per_text
    return @time_per_text
  end
#attr writer for time_per_text
  def time_per_text=(time)
    return if @time_per_text == time
    @time_per_text = time
  end
#overwrite refresh method to support mode like face or icon. if you have
#new mode you want just add it here
  def refresh
    contents.clear
    draw_background_colour
    case @mode
    when :face
      gab_draw_face
      draw_text_ex(100, line_height / 2, @text) #100 get from 96(face width) + 4 pixel space
    when :icon
      gab_draw_icon
      draw_text_ex(48, line_height / 2, @text)
    else
      draw_graphic
      draw_text_ex(48, line_height / 2, @text)
    end
  end  
#new method gab_draw_icon to draw icon before gab text
  def gab_draw_icon
    dx = 12
    dy = 12
    icon_index = @index
    draw_icon(icon_index, dx, dy)
  end
#new method gab_draw_face to draw face before gab text
  def gab_draw_face
    face_name = @graphic
    face_index = @index
    dx = 0
    dy = 0
    draw_face(face_name, face_index, dx, dy)
  end
end

#game interpreter method for shorter call
class Game_Interpreter
  #new method change gab x value
  def gab_x(num)
    SceneManager.scene.gab_x(num)
  end
  #new method change gab y value
  def gab_y(num)
    SceneManager.scene.gab_y(num)
  end
  #new method change gab z value
  def gab_z(num)
    SceneManager.scene.gab_z(num)
  end
  #new method change gab height
  def gab_h(num, fh = true)
    SceneManager.scene.gab_h(num, fh)
  end
  #new method change gab base time value
  def gab_base_time(num)
    SceneManager.scene.gab_base_time(num)
  end
  #new method change gab time per text value
  def gab_time_per_text(num)
    SceneManager.scene.gab_time_per_text(num)
  end
  #new method to reset gab to default settings
  def reset_gab
    SceneManager.scene.reset_gab
  end
  #overwrite yanfly method so can call gab in any scene
  #if use gab(args) then it will reset gab first (so it works like original yanfly gab)
  #so all modification will reseted back to default value.
  #i do it this way so people who already set their project using yanfly gab window
  #didn't have to add reset_gab to all his already made gab(args) :D
  def gab(text, case1 = nil, case2 = nil, case3 = nil)
    reset_gab
    gabmod(text, case1, case2, case3)
  end
  #new method. gabmod(args). then all modification will be used.
  def gabmod(text, case1 = nil, case2 = nil, case3 = nil)
    if case1.is_a?(Integer)
      case1 = $game_party.members[case1.abs].id if case1 <= 0
      actor = $game_actors[case1]
      if !actor.nil?
        case1 = case3 ? actor.character_name : actor.face_name
        case2 = case3 ? actor.character_index : actor.face_index
      end
    elsif case1.is_a?(String)
      case2 = 0 if case2.nil?
    end
    SceneManager.scene.setup_gab_window(text, case1, case2, case3)
  end
  #overwrite yanfly method so can clear gab in any scene
  def clear_gab
    SceneManager.scene.clear_gab
  end
end # Game_Interpreter