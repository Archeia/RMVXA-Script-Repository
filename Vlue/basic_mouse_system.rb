#Basic Mouse System v2.7h
#----------#
#Features: Provides a series of functions to find the current x, y position of
#           the mouse and whether it is being clicked or not (left or right click)
#
#Usage:   Script calls:
#           Mouse.pos?   - returns the x, y position as an array
#           Mouse.lclick?(repeat) - returns if left click is achieved
#                                   repeat = true for repeated checks
#           Mouse.rclick?(repeat) - same as above for right click
#           Mouse.within?(rect) - passes a Rect through to check if cursor
#                                 is within it, returns true if so
#
#         Events:
#          The following are placed in the name of an event:
#          &&  -  event can be triggered from afar by mouse click
#          I:# -  where # is the icon_index to change the cursor on hover
#  
#         Example: I:262
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    posted on the thread for the script
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
CPOS = Win32API.new 'user32', 'GetCursorPos', ['p'], 'v'
WINX = Win32API.new 'user32', 'FindWindowEx', ['l','l','p','p'], 'i'
ASKS = Win32API.new 'user32', 'GetAsyncKeyState', ['p'], 'i'
SMET = Win32API.new 'user32', 'GetSystemMetrics', ['i'], 'i'
WREC = Win32API.new 'user32', 'GetWindowRect', ['l','p'], 'v'
 
#MOUSE_ICON, set to the index of the icon to use as a cursor
$mouse_icon = 147
CURSOR_OFFSET_X = 0
CURSOR_OFFSET_Y = 0
 
#Keeps cursor sprite within the game window
MOUSE_KEEP_WINDOW = true
 
#Whether clicking requires cursor to be within window or not
MOUSE_CLICK_WITHIN = false
 
#Whether to use 8 directional movement or not
MOUSE_DIR8 = false
 
#Use the Mouse Button Overlay:
USE_MOUSE_BUTTONS = true
#And here is where you set up your buttons! Simple overlay:
#(Picture files are to be stored in System)
#
# [ x , y, "filename", "script call when left clicked" ]
MOUSE_BUTTONS = [
            [0,416-32,"Shadow.png","SceneManager.call(Scene_Equip)"],
            [32,416-32,"Shadow.png","SceneManager.call(Scene_Item)"], ]
 
SHOWMOUS = Win32API.new 'user32', 'ShowCursor', 'i', 'i'
SHOWMOUS.call(0)
 
#Switch option to enable/disable the script
USE_MOUSE_SWITCH = true
MOUSE_SWITCH = 1
 
module Mouse
  def self.setup
    @enabled = true
    @delay = 0
    bwap = true if SMET.call(23) != 0
    bwap ? @lmb = 0x02 : @lmb = 0x01
    bwap ? @rmb = 0x01 : @rmb = 0x02
  end
  def self.update
    return false unless @enabled
    return false if USE_MOUSE_SWITCH && $game_switches[MOUSE_SWITCH]
    self.setup if @lmb.nil?
    @delay -= 1
    @window_loc = WINX.call(0,0,"RGSS PLAYER",0)
    if ASKS.call(@lmb) == 0 then @l_clicked = false end
    if ASKS.call(@rmb) == 0 then @r_clicked = false end
    rect = '0000000000000000'
    cursor_pos = '00000000'
    WREC.call(@window_loc, rect)
    side, top = rect.unpack("ll")
    CPOS.call(cursor_pos)
    @m_x, @m_y = cursor_pos.unpack("ll")
    w_x = side + SMET.call(5) + SMET.call(45)
    w_y = top + SMET.call(6) + SMET.call(46) + SMET.call(4)
    @m_x -= w_x; @m_y -= w_y
    if MOUSE_KEEP_WINDOW
      @m_x = [[@m_x, 0].max,Graphics.width-5].min
      @m_y = [[@m_y, 0].max,Graphics.height-5].min
    end
    return true
  end
  def self.pos?
    return[-50,-50] unless self.update
    return [@m_x, @m_y]
  end
  def self.lclick?(repeat = false)
    return unless self.update
    return false if @l_clicked
    if ASKS.call(@lmb) != 0 then
      @l_clicked = true if !repeat
      return true end
  end
  def self.rclick?(repeat = false)
    return unless self.update
    return false if @r_clicked
    if ASKS.call(@rmb) != 0 then
      @r_clicked = true if !repeat
      return true end
  end
  def self.slowpeat
    return unless self.update
    return false if @delay > 0
    @delay = 120
    return true
  end
  def self.within?(rect)
    return unless self.update
    return false if @m_x < rect.x or @m_y < rect.y
    bound_x = rect.x + rect.width; bound_y = rect.y + rect.height
    return true if @m_x < bound_x and @m_y < bound_y
    return false
  end
  def self.disable
    @enabled = false
    SHOWMOUS.call(1)
  end
  def self.enable
    @enabled = true
    SHOWMOUS.call(0)
  end
end
 
Mouse.setup
 
module DataManager
  class << self
    alias mouse_init init
  end
  def self.init
    mouse_init
    $cursor = Mouse_Cursor.new
  end
end
 
class Scene_Base
  alias cursor_update update_basic
  def update_basic
    cursor_update
    mouse_cursor
  end
  def mouse_cursor
    pos = Mouse.pos?
    $cursor.x = pos[0] + CURSOR_OFFSET_X
    $cursor.y = pos[1] + CURSOR_OFFSET_Y
  end
end
 
class Mouse_Cursor < Sprite_Base
  def initialize
    super
    @icon = $mouse_icon
    self.bitmap = Bitmap.new(24,24)
    draw_cursor
    self.z = 255
  end
  def set_icon(icon)
    return if @icon == icon
    @icon = icon
    draw_cursor
  end
  def draw_cursor
    self.bitmap.clear
    icon_bitmap = Cache.system("Iconset")
    rect = Rect.new(@icon % 16 * 24, @icon / 16 * 24, 24, 24)
    self.bitmap.blt(0, 0, icon_bitmap, rect)
  end
end
 
class Window_Selectable
  alias mouse_update update
  alias mouse_init initialize
  def initialize(x,y,w,h)
    mouse_init(x,y,w,h)
    @mouse_all_rects = []
    @timer = 0
  end
  def update
    mouse_update
    update_mouse if self.active
  end
  def update_mouse
    @timer -= 1
    @mouse_all_rects = []
    item_max.times {|i|
      rect = item_rect(i)
      rect.x += self.x + standard_padding - self.ox
      rect.y += self.y + standard_padding - self.oy
      if !self.viewport.nil?
        rect.x += self.viewport.rect.x - self.viewport.ox
        rect.y += self.viewport.rect.y - self.viewport.oy
      end
      @mouse_all_rects.push(rect) }
    item_max.times {|i|
      next if @timer > 0
      next unless Mouse.within?(@mouse_all_rects[i])
      @timer = 10 if i > top_row * 2 + page_item_max - 1
      @timer = 10 if i < top_row * 2
      self.index = i }
    process_cancel if Mouse.rclick? && cancel_enabled?
    return if MOUSE_CLICK_WITHIN && !within_index
    process_ok if Mouse.lclick? && ok_enabled?
  end
  def within_index
    item_max.times {|i|
      return true if Mouse.within?(@mouse_all_rects[i]) }
    return false
  end
end
 
class Window_NameInput
  alias mouse_process_handling process_handling
  def process_handling
    mouse_process_handling
    process_back if Mouse.rclick?
  end
  def item_max
    return 90
  end
end
 
class Window_Message < Window_Base
  def input_pause
    self.pause = true
    wait(10)
    Fiber.yield until Input.trigger?(:B) || Input.trigger?(:C) || Mouse.lclick? #if !SceneManager.scene_is?(Scene_Map))
    Input.update
    self.pause = false
  end
end
 
class Scene_File < Scene_MenuBase
  alias mouse_update update
  def update
    mouse_update
    mouse_input
  end
  def mouse_input
    xx = 0
    yy = 56
    width = Graphics.width
    rectcm1 = Rect.new(xx, yy, width, savefile_height)
    rectcm2 = Rect.new(xx, yy + rectcm1.height, width, savefile_height)
    rectcm3 = Rect.new(xx, yy + rectcm1.height * 2, width, savefile_height)
    rectcm4 = Rect.new(xx, yy + rectcm1.height * 3, width, savefile_height)
    rectttl = Rect.new(xx, yy, width, rectcm1.height * 4)
    rectcmA = Rect.new(0, yy - 12, Graphics.width, 24)
    rectcmB = Rect.new(0, Graphics.height - 12, Graphics.width, 24)
    @scroll = self.top_index
    last_index = @index
    @index = (0 + @scroll) if Mouse.within?(rectcm1)
    @index = (1 + @scroll) if Mouse.within?(rectcm2)
    @index = (2 + @scroll) if Mouse.within?(rectcm3)
    @index = (3 + @scroll) if Mouse.within?(rectcm4)
    cursor_down(false) if Mouse.within?(rectcmB) and Mouse.slowpeat
    cursor_up(false) if Mouse.within?(rectcmA) and Mouse.slowpeat
    if @index != last_index
      Sound.play_cursor
      @savefile_windows[last_index].selected = false
      @savefile_windows[@index].selected = true
    end
    on_savefile_ok if Mouse.lclick? and Mouse.within?(rectttl)
    on_savefile_cancel if Mouse.rclick? and Mouse.within?(rectttl)
  end
end
 
class Scene_Gameover
  alias mouse_update update
  def update
    mouse_update
    goto_title if Mouse.lclick? or Mouse.rclick?
  end
end
 
class Game_Player < Game_Character
  alias mouse_move_update update
  def update
    mouse_move_update
    mouse_input
  end
  def mouse_input
    begin      
    return if USE_MOUSE_BUTTONS && SceneManager.scene.mouse_overlay.update
    rescue
    return
    end
    return if !movable? || $game_map.interpreter.running?
    if !Mouse.lclick?(true) then return end
    if moving? then return end
    Graphics.width / 32 % 2 == 0 ? xxx = 16 : xxx = 0
    Graphics.height / 32 % 2 == 0 ? yyy = 16 : yyy = 0
    x = $game_map.display_x + (Mouse.pos?[0] + xxx) / 32
    y = $game_map.display_y + (Mouse.pos?[1] + yyy) / 32
    x -= 0.5 if Graphics.width / 32 % 2 == 0
    y -= 0.5 if Graphics.height / 32 % 2 == 0
    return if start_map_event_mouse(x, y, [0,1,2], false)
    if MOUSE_DIR8
      x = $game_map.display_x * 32 + Mouse.pos?[0]
      y = $game_map.display_y * 32 + Mouse.pos?[1]
      x -= @x * 32 + 16
      y -= @y * 32 + 16
      angle = Math.atan(x.abs/y.abs) * (180 / Math::PI)
      angle = (90 - angle) + 90 if x > 0 && y > 0
      angle += 180 if x < 0 && y > 0
      angle = 90 - angle + 180 + 90 if x < 0 && y < 0
      move_straight(8) if angle >= 337 || angle < 22
      move_diagonal(6,8) if angle >= 22 && angle < 67
      move_straight(6) if angle >= 67 && angle < 112
      move_diagonal(6,2) if angle >= 112 && angle < 157
      move_straight(2) if angle >= 157 && angle < 202
      move_diagonal(4,2) if angle >= 202 && angle < 247
      move_straight(4) if angle >= 247 && angle < 292
      move_diagonal(4,8) if angle >= 292 && angle < 337
    else
      x = $game_map.display_x + Mouse.pos?[0] / 32
      y = $game_map.display_y + Mouse.pos?[1] / 32
      sx = distance_x_from(x)
      sy = distance_y_from(y)
      if sx.abs > sy.abs
        move_straight(sx > 0 ? 4 : 6)
        move_straight(sy > 0 ? 8 : 2) if !@move_succeed && sy != 0
      elsif sy != 0
        move_straight(sy > 0 ? 8 : 2)
        move_straight(sx > 0 ? 4 : 6) if !@move_succeed && sx != 0
      end
    end
  end
  def start_map_event_mouse(x, y, triggers, normal)
    return false if $game_map.interpreter.running?
    $game_map.events_xy(x, y).each do |event|
      next unless event.trigger_from_afar
      if event.trigger_in?(triggers)
        event.start
        return true
      end
    end
    return false
  end
end
 
class Game_Event
  def trigger_from_afar
    return @event.name.include?("&&")
  end
  def mouse_icon?
    @event.name =~ /I:(\d+)/ ? $1.to_i : false
  end
end
 
class Scene_Map
  attr_accessor   :mouse_overlay
  alias mouse_update update
  alias mouse_overlay_init start
  alias mouse_pre_battle pre_battle_scene
  def start(*args)
    mouse_overlay_init(*args)
    @mouse_overlay = Mouse_Overlay.new if USE_MOUSE_BUTTONS
    @last_mouse_x = -1
    @last_mouse_y = -1
  end
  def update
    mouse_update
    mouse_input_events
    update_mouse_icon
  end
  def mouse_input_events
    xx = $game_player.screen_x
    yy = $game_player.screen_y
    xx -= 16;
    recttop = Rect.new(xx - 6, yy - 80, 44, 48)
    rectrit = Rect.new(xx + 32, yy - 36, 48, 44)
    rectbot = Rect.new(xx - 6, yy, 44, 48)
    rectleft = Rect.new(xx - 48, yy - 38, 48, 44)
    mouse_action(8) if Mouse.within?(recttop)
    mouse_action(6) if Mouse.within?(rectrit)
    mouse_action(2) if Mouse.within?(rectbot)
    mouse_action(4) if Mouse.within?(rectleft)
    call_menu if Mouse.rclick? and !$game_map.interpreter.running?
  end
  def update_mouse_icon
    Graphics.width / 32 % 2 == 0 ? xxx = 16 : xxx = 0
    Graphics.height / 32 % 2 == 0 ? yyy = 16 : yyy = 0
    x = $game_map.display_x + (Mouse.pos?[0] + xxx) / 32
    y = $game_map.display_y + (Mouse.pos?[1] + yyy) / 32
    x -= 0.5 if Graphics.width / 32 % 2 == 0
    y -= 0.5 if Graphics.height / 32 % 2 == 0
    return if x == @last_mouse_x && y == @last_mouse_y
    @last_mouse_x = x
    @last_mouse_y = y
    events = $game_map.events_xy(x,y)
    icon = $mouse_icon
    events.each do |event|
      icon = event.mouse_icon? if event.mouse_icon?
    end
    $cursor.set_icon(icon)
  end
  def mouse_action(d)
    return if !Mouse.rclick?(true) || $game_map.interpreter.running?
    $game_player.set_direction(d)
    $game_player.check_action_event
  end
  def pre_battle_scene
    mouse_pre_battle
    @mouse_overlay.dispose
  end
end
 
class Window_NumberInput
  OFS = 12
  WLH = 24
  alias mouse_update update
  def update
    mouse_update
    mouse_input if SceneManager.scene_is?(Scene_Map) and self.active
  end
  def mouse_input
    hold_rect = []
    xx = self.x + OFS
    yy = self.y + OFS
    width = 20
    rectttl = Rect.new(xx, yy, self.contents.width, WLH)
    for i in Range.new(0, @digits_max - 1)
      hold_rect.push(Rect.new(xx, yy, width, WLH))
      xx += width
    end
    for i in Range.new(0, @digits_max - 1)
      @index = i if Mouse.within?(hold_rect[i])
    end
    rectok = Rect.new(xx, yy, 34, 24)
    rectnum = Rect.new(self.x + OFS, yy, @digits_max * 20, WLH)
    self.process_ok if Mouse.within?(rectok) and Mouse.lclick?
    process_mouse_change if Mouse.within?(rectnum)
  end
  def refresh
    contents.clear
    change_color(normal_color)
    s = sprintf("%0*d", @digits_max, @number)
    @digits_max.times do |i|
      rect = item_rect(i)
      rect.x += 1
      draw_text(rect, s[i,1], 1)
    end
    draw_text(self.contents.width - 24, 0, 34, WLH, "OK")
  end
  def update_placement
    self.width = @digits_max * 20 + padding * 2 + 34
    self.height = fitting_height(1)
    self.x = (Graphics.width - width) / 2
    if @message_window.y >= Graphics.height / 2
      self.y = @message_window.y - height - 8
    else
      self.y = @message_window.y + @message_window.height + 8
    end
  end
  def process_mouse_change
    return unless active
    place = 10 ** (@digits_max - 1 - @index)
    n = @number / place % 10
    @number -= n * place
    if Mouse.lclick?
      n = (n + 1) % 10
      Sound.play_cursor
    end
    if Mouse.rclick?
      n = (n + 9) % 10
      Sound.play_cursor
    end
    @number += n * place
    refresh
  end
end
 
class Mouse_Overlay
  def initialize
    @mouse_buttons = []
    MOUSE_BUTTONS.size.times do |i|
      @mouse_buttons[i] = Mouse_Button.new
      @mouse_buttons[i].x = MOUSE_BUTTONS[i][0]
      @mouse_buttons[i].y = MOUSE_BUTTONS[i][1]
      @mouse_buttons[i].bitmap = Bitmap.new("Graphics/System/" + MOUSE_BUTTONS[i][2])
      @mouse_buttons[i].on_lclick = MOUSE_BUTTONS[i][3]
    end
  end
  def update
    @mouse_buttons.size.times do |i| @mouse_buttons[i].update end
    if Mouse.lclick?(true)
      @mouse_buttons.size.times do |i|
        if Mouse.within?(@mouse_buttons[i].current_rect?)
          @mouse_buttons[i].on_lclick_eval
          return true
        end
      end
    end
    return false
  end
  def dispose
    @mouse_buttons.each do |sprite|
      sprite.dispose
    end
  end
end
 
class Mouse_Button < Sprite_Base
  attr_accessor   :on_lclick
  def current_rect?
    Rect.new(x,y,width,height)
  end
  def on_lclick_eval
    eval(on_lclick)
  end
end
 
class Window_Base
  def rect
    Rect.new(self.x,self.y,self.width,self.height)
  end
end
 
class Scene_Options < Scene_MenuBase
  alias mouse_update update
  def update
    mouse_update
    update_mouse
  end
  def update_mouse
    create_rects unless @rects
    @rects.size.times do |i|
      @index = i if Mouse.within?(@rects[i])
    end
    if Mouse.lclick?
      if audio_index(@index)
        x = Mouse.pos?[0]
        return if x < 48+4
        return if x > 48+4+400
        value = (x - 48).to_f / 400
        $game_options.preset_volume(:master, value) if @window_index[@index] == :master
        $game_options.preset_volume(:bgm, value) if @window_index[@index] == :bgm
        $game_options.preset_volume(:se, value) if @window_index[@index] == :se
        @window_masterbar.refresh($game_options.master_volume)
        @window_bgmbar.refresh($game_options.bgm_volume)
        @window_sebar.refresh($game_options.se_volume)
        Sound.play_cursor
        $game_map.autoplay if $game_map && $game_map.map_id > 0
      end
    end
  end
  def create_rects
    @rects = []
    WINDOW_ORDER.each do |sym|
      @rects.push(@window_masterbar.rect) if sym == :master
      @rects.push(@window_bgmbar.rect) if sym == :bgm
      @rects.push(@window_sebar.rect) if sym == :se
      @rects.push(@window_resolution.rect) if sym == :resolution
      @rects.push(@window_message.rect) if sym == :message_se
      @rects.push(@window_switch.rect) if sym == :switch
    end
    @rects.push(@window_command.rect)
  end
end
 
class Window_RecipeConfirm < Window_Selectable
  alias mouse_rec_update update
  def update
    mouse_rec_update
    update_mouse if self.active
  end
  def update_mouse
    @timer -= 1
    @mouse_all_rects = []
    @mouse_all_rects.push(Rect.new(self.x,self.y,self.contents.width*0.85,self.height))
    @mouse_all_rects.push(Rect.new(self.x + self.contents.width*0.85,self.y,self.contents.width*0.25,self.height))
    if Mouse.rclick?
      if Mouse.within?(@mouse_all_rects[1])
        change_amount(-1)
      else
        process_cancel if cancel_enabled?
      end
    elsif Mouse.lclick?
      process_ok if ok_enabled? && Mouse.within?(@mouse_all_rects[0])
      change_amount(1) if Mouse.within?(@mouse_all_rects[1])
    end
  end
  def within_index
    item_max.times {|i|
      return true if Mouse.within?(@mouse_all_rects[i]) }
    return false
  end
end