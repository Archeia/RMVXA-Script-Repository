#encoding:UTF-8
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# Classes
#   Game_BattleAction
#     new-method :battle_vocab
#     new-method :battle_commands
#   Window_ActorCommand
#     new-method :draw_command
#     overwrite  :initialize
#     overwrite  :setup
#     overwrite  :refresh
#     overwrite  :draw_item
#   Scene_Battle
#     overwrite  :execute_action_skill
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
($imported ||= {})["IEO-RivieraMapNavi"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
($ieo_script = {})[[25, "RivieraMapNavi"]] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# IEO::RIVIERA_MAPNAVIGATION
#==============================================================================#
module IEO
  module RIVIERA_MAPNAVIGATION

  end
end

#==============================================================================#
# IEO::Icon
#==============================================================================#
module IEO
  module Icon
    module_function ; def navi(key) ; return 0 end
  end
end

#==============================================================================#
# IEO::REGEX::RIVIERA_MAPNAVIGATION
#==============================================================================#
module IEO
  module REGEXP
    module RIVIERA_MAPNAVIGATION
      module EVENT
        #        Modes        : Button
        NAVI      = /<NAVI[ ](MOVE|EXPLORE|LOOK):[ ]*(.*)>/i
        POINTCOST = /<LPCOST:[ ]*(\d+)>/i
        NAVITEXT  = /<NAVITEXT:[ ]*(.*)>/i
        NAVIICON  = /<NAVIICON:[ ]*(.*)>/i
      end
    end
  end
end

#==============================================================================#
# Bitmap
#==============================================================================#
class Bitmap

  #--------------------------------------------------------------------------
  # * Draw Icon
  #     icon_index : Icon number
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     enabled    : Enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  def draw_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    self.blt(x, y, bitmap, rect, enabled ? 255 : 128)
  end

end

#==============================================================================#
# Game_Party
#==============================================================================#
class Game_Party < Game_Unit

  LP_VARIABLE    = 1
  MAXLP_VARIABLE = 2

  attr_accessor :lp_changed

  alias ieo025_initialize initialize unless $@
  def initialize
    ieo025_initialize
    @lp_changed = true
  end

  def lp
    return $game_variables[LP_VARIABLE]
  end

  def lp=(val)
    oldval = $game_variables[LP_VARIABLE]
    $game_variables[LP_VARIABLE] = [[val, $game_variables[MAXLP_VARIABLE]].min, 0].max
    @lp_changed = true if oldval != $game_variables[LP_VARIABLE]
  end

  def maxlp
    return $game_variables[MAXLP_VARIABLE]
  end

  def maxlp=(val)
    oldval = $game_variables[MAXLP_VARIABLE]
    $game_variables[MAXLP_VARIABLE] = [val, 0].max
    @lp_changed = true if oldval != $game_variables[MAXLP_VARIABLE]
    self.lp = $game_variables[LP_VARIABLE]
  end

end

#==============================================================================#
# Game_Map
#==============================================================================#
class Game_Map

  MOVE_MODE_SWITCH   = 1
  LOOK_MODE_SWITCH   = 2
  HIDE_NAVI_SWITCH   = 3

  alias ieo025_setup setup unless $@
  def setup(map_id)
    create_navipoint_list
    @navipoint_current.clear unless @navipoint_current.nil?
    ieo025_setup(map_id)
  end

  def create_navipoint_list
    @navipoint_checklist = {} if @navipoint_checklist.nil?
    # Key == key, Value == event
    @navipoint_current = {} if @navipoint_current.nil?
  end

  def create_current_navi(type)
    create_navipoint_list
    @navipoint_current[type] = {} if @navipoint_current[type].nil?
  end

  def register_current_navi(event, type)
    create_current_navi(type)
    @navipoint_current[type][event.navipoint[1]] = event
  end

  def unregister_current_navi(event, type)
    create_current_navi(type)
    @navipoint_current[type][event.navipoint[1]] = nil
    @navipoint_current[type].delete(event.navipoint[1])
  end

  def activate_navipoint(event_id, map_id=@map_id)
    create_navipoint_list
    @navipoint_checklist[[map_id, event_id]] = true
  end

  def deactivate_navipoint(event_id, map_id=@map_id)
    create_navipoint_list
    @navipoint_checklist[[map_id, event_id]] = false
  end

  def active_navipoint?(eid, mid=@map_id)
    create_navipoint_list
    @navipoint_checklist[[mid, eid]] = false if @navipoint_checklist[[mid, eid]].nil?
    return @navipoint_checklist[[mid, eid]]
  end

  def hide_navipoints?
    return $game_switches[HIDE_NAVI_SWITCH]
  end

  def move_mode?
    return $game_switches[MOVE_MODE_SWITCH]
  end

  def look_mode?
    return $game_switches[LOOK_MODE_SWITCH]
  end

  alias ieo025_update update unless $@
  def update
    ieo025_update
    update_navimode
  end

  def update_navimode
    return unless $scene.is_a?(Scene_Map)
    return unless (move_mode? || look_mode?)
    return if @interpreter.running?
    return if $scene.swapping_mapmodes
    type = :look if look_mode?
    type = :move if move_mode?
    if Input.trigger?(Input::RIGHT)
      trigger_navi(type, "RIGHT")
    elsif Input.trigger?(Input::LEFT)
      trigger_navi(type, "LEFT")
    elsif Input.trigger?(Input::UP)
      trigger_navi(type, "UP")
    elsif Input.trigger?(Input::DOWN)
      trigger_navi(type, "DOWN")
    end
  end

  def trigger_navi(type, key)
    #Sound.play_decision
    create_current_navi(type)
    unless @navipoint_current[type][key].nil?
      return unless @navipoint_current[type][key].used_navipoint?
      @navipoint_current[type][key].start
    end
  end

end

#==============================================================================#
# Game_Character
#==============================================================================#
class Game_Character
  def navievent? ; return false end
end

#==============================================================================#
# Game_Event
#==============================================================================#
class Game_Event < Game_Character

  attr_accessor :navipoint
  attr_accessor :naviicon
  attr_accessor :navitext
  attr_accessor :event
  attr_accessor :lpcost

  alias ieo025_initialize initialize unless $@
  def initialize(map_id, event)
    @navipoint = []
    @navitext  = ""
    @naviicon  = 0
    @lpcost    = 0
    ieo025_initialize(map_id, event)
  end

  alias ieo025_setup setup unless $@
  def setup(new_page)
    ieo025_setup(new_page)
    ieo025_eventcache
  end

  def ieo025_eventcache
    @navipoint = []
    @navitext = ""
    @naviicon = 0
    @lpcost = 0
    $game_map.unregister_current_navi(self, :move)
    $game_map.unregister_current_navi(self, :look)
    return if @list == nil
    for i in 0..@list.size
      next if @list[i] == nil
      if @list[i].code == 108
        @list[i].parameters.to_s.split(/[\r\n]+/).each { |line|
        case line
        when IEO::REGEXP::RIVIERA_MAPNAVIGATION::EVENT::NAVI
          type = $1
          key = $2
          case type.upcase
          when "MOVE"
            @navipoint = [:move, key]
            $game_map.register_current_navi(self, :move)
          when "LOOK", "EXPLORE"
            @navipoint = [:look, key]
            $game_map.register_current_navi(self, :look)
          end
        when IEO::REGEXP::RIVIERA_MAPNAVIGATION::EVENT::POINTCOST
          @lpcost = $1.to_i
        when IEO::REGEXP::RIVIERA_MAPNAVIGATION::EVENT::NAVITEXT
          @navitext = $1
        when IEO::REGEXP::RIVIERA_MAPNAVIGATION::EVENT::NAVIICON
          case $1
          when /NAVI:[ ]*(.*)/i
            @naviicon = IEO::Icon.navi($1)
          when /CUS:[ ]*(\d+)/i
            @naviicon = $1.to_i
          end
        end
        }
      end
    end
  end

  def navievent? ; return !@navipoint.empty? end

  def unchecked_navi?
    return !$game_map.active_navipoint?(@id)
  end

  def navi_active?
    return false if $game_map.hide_navipoints?
    case @navipoint[0]
    when :move
      return true if $game_map.move_mode?
    when :look
      return true if $game_map.look_mode?
    end
    return false
  end

  def used_navipoint?
    if @lpcost > 0
      return false if @lpcost > $game_party.lp and unchecked_navi?
    end
    return true
  end

end

#==============================================================================#
# Game_Player
#==============================================================================#
class Game_Player < Game_Character

  DISABLE_PLAYERMOVE = 4
  DISABLE_ACTIONBUTN = 4

  alias ieo025_check_action_event check_action_event unless $@
  def check_action_event
    return if $game_switches[DISABLE_ACTIONBUTN]
    ieo025_check_action_event
  end

  alias ieo025_move_by_input move_by_input unless $@
  def move_by_input
    return if $game_switches[DISABLE_PLAYERMOVE]
    ieo025_move_by_input
  end

  def navievent? ; return false end

end

#==============================================================================#
# Game_Interpreter
#==============================================================================#
class Game_Interpreter

  def activate_navipoint(event_id, map_id=$game_map.map_id)
    $game_map.activate_navipoint(event_id, map_id)
  end

  def deactivate_navipoint(event_id, map_id=$game_map.map_id)
    $game_map.deactivate_navipoint(event_id, map_id)
  end

  def active_navipoint?(eid, mid=$game_map.map_id)
    return $game_map.active_navipoint?(eid, mid)
  end

  def change_params(new_param) ; @params = new_param end

end

#==============================================================================#
# Sprite_Character
#==============================================================================#
class Sprite_Character < Sprite_Base

  alias ieo025_initialize initialize unless $@
  def initialize(viewport, character = nil)
    ieo025_initialize(viewport, character)
    if character.is_a?(Game_Event)
      @sprite_navibox = Sprite_Navibox.new(self.viewport, character) if character.navievent?
    end
  end

  alias ieo025_dispose dispose unless $@
  def dispose
    @sprite_navibox.dispose unless @sprite_navibox.nil?
    ieo025_dispose
  end

  alias ieo025_update update unless $@
  def update
    if @character.navievent?
      @sprite_navibox = Sprite_Navibox.new(self.viewport, character) if @sprite_navibox.nil?
    else
      @sprite_navibox.dispose unless @sprite_navibox.nil?
    end
    unless @sprite_navibox.nil?
      @sprite_navibox.update unless @sprite_navibox.disposed?
    end
    ieo025_update
  end

end

#==============================================================================#
# Sprite_Navibox
#==============================================================================#
class Sprite_Navibox < Sprite_Base

  COLOR1_1  = Color.new(255, 255, 255)
  COLOR1_2  = Color.new(255, 0, 0)
  COLOR2    = Color.new(20, 20, 20)

  X_OFFSET  = -(128 - 32) / 2
  Y_OFFSET  = -64
  Z_OFFSET  = 32

  BOXRECT   = Rect.new(0, 0, 128, 18)
  TEXTRECT  = Rect.new(16, 2, 96, 14)
  TEXTCOLOR1= Color.new(255, 255, 255)
  TEXTCOLOR2= Color.new(255, 0, 0)

  FONT_SIZE = 14

  attr_accessor :x_offset
  attr_accessor :y_offset
  attr_accessor :z_offset

  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    @unchecked_navi = @character.unchecked_navi?
    create_bitmap
    @x_offset = X_OFFSET
    @y_offset = Y_OFFSET
    @z_offset = Z_OFFSET
    update_visibility
    update_position
    set_popup
  end

  def set_popup
    self.zoom_x = 0.0
    self.zoom_y = 0.0
  end

  def create_bitmap
    self.bitmap.dispose unless self.bitmap.nil?
    self.bitmap = Bitmap.new(BOXRECT.width, BOXRECT.height+10)
    rect1 = Rect.new(0, 0, BOXRECT.width, BOXRECT.height)
    rect2 = rect1.clone
    rect2.x += 2
    rect2.y += 2
    rect2.width -= 4
    rect2.height -= 4
    self.bitmap.fill_rect(rect1, @unchecked_navi ? COLOR1_2 : COLOR1_1)
    self.bitmap.fill_rect(rect2, COLOR2)
    self.bitmap.font.size = FONT_SIZE
    self.bitmap.font.color = @unchecked_navi ? TEXTCOLOR2 : TEXTCOLOR1
    if @character.navitext.empty?
      self.bitmap.draw_text(TEXTRECT, @character.event.name)
      trect1 = TEXTRECT.clone
      trect1.width -= 24 if @character.naviicon > 0
      self.bitmap.draw_text(trect1, @character.navipoint[1].to_s, 2)
    else
      self.bitmap.draw_text(TEXTRECT, @character.navitext)
    end
    if @character.lpcost > 0 and !@character.used_navipoint?
      trectx = TEXTRECT.clone
      trectx.width -= 24
      self.bitmap.draw_text(trectx, sprintf("LP%d", @character.lpcost), 2)
    end
    self.bitmap.draw_icon(@character.naviicon.to_i, rect1.x+rect1.width-24, rect1.y-4)
  end

  def update
    super
    update_visibility
    update_position
    update_bitmap
    chg = 1.0 / 10.0
    self.zoom_x = [self.zoom_x+chg, 1].min unless Integer(self.zoom_x) == 1
    if self.zoom_x > 0.5 and Integer(self.zoom_y) != 1
      self.zoom_y = [self.zoom_y+chg, 1].min
    end
  end

  def update_visibility
    self.visible = @character.navi_active?
  end

  def update_position
    return if @character.nil?
    self.x = @character.screen_x + @x_offset
    self.y = @character.screen_y + @y_offset
    self.z = @character.screen_z + @z_offset
  end

  def update_bitmap
    if @unchecked_navi != @character.unchecked_navi?
      @unchecked_navi = @character.unchecked_navi?
      create_bitmap
    end
  end

  def visible=(val)
    set_popup if val != self.visible
    super(val)
  end

end

#==============================================================================#
# Window_Base
#==============================================================================#
class Window_Base < Window

end

#==============================================================================#
# LP_Window
#==============================================================================#
class LP_Window < Window_Base

  def initialize(x, y)
    super(x, y, 156, 56)
    refresh
  end

  def refresh
    self.contents.clear
    rect = Rect.new(0, 10, self.contents.width, 12)
    lp = $game_party.lp ; lp_max = $game_party.maxlp
    draw_grad_bar(rect.clone, lp, lp_max, normal_color, normal_color, nil, 2)
    self.contents.font.size = 18
    rect.y = 0 ; rect.height = WLH
    self.contents.draw_text(rect, "LP")
    self.contents.draw_text(rect, lp, 2)
  end

  def update
    super
    if $game_party.lp_changed
      refresh
      $game_party.lp_changed = false
    end
  end

  def nil?
    return true if self.disposed?
    super
  end

end

#==============================================================================#
# Scene_Map
#==============================================================================#
class Scene_Map < Scene_Base

  attr_accessor :swapping_mapmodes

  include IEX::SCENE_ACTIONS if $imported["IEX_SceneActions"]

  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  SLIDY_WINDOWS = true
  SLIDY_WINDOWS = ($imported["IEX_SceneActions"] && SLIDY_WINDOWS)

  alias ieo025_initialize initialize unless $@
  def initialize
    ieo025_initialize
    @windows = {} if @windows.nil?
    @swapping_mapmodes = false
  end

  alias ieo025_start start unless $@
  def start
    ieo025_start
    create_lp_window if $game_switches[2]
  end

  def iex_update_basic
    update_basic
  end

  def create_lp_window
    @swapping_mapmodes = true
    if @lp_window.nil?
      @lp_window = LP_Window.new(0, 0)
      @windows["LP"] = @lp_window
      if SLIDY_WINDOWS
        @lp_window.y = -@lp_window.height
        pull_windows_down(["LP"], @lp_window.height)
      end
      @swapping_mapmodes = false
      return true
    else
      @lp_window.refresh
      @swapping_mapmodes = false
      return false
    end
  end

  def dispose_lp_window
    @swapping_mapmodes = true
    unless @lp_window.nil?
      if SLIDY_WINDOWS
        pull_windows_up(["LP"], @lp_window.height)
      end
      @lp_window.dispose
      @swapping_mapmodes = false
      return true
    else
      @swapping_mapmodes = false
      return false
    end
  end

  alias ieo025_terminate terminate unless $@
  def terminate
    dispose_lp_window
    ieo025_terminate
  end

  alias ieo025_update update unless $@
  def update
    ieo025_update
    @lp_window.update unless @lp_window.nil?
    if Input.trigger?(Input::X)
      $game_map.interpreter.change_params([1])
      $game_map.interpreter.command_117
    end
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
