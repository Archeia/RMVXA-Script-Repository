#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Lotus Status
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Change (Status)
# ** Script Type   : Status Scene
# ** Date Created  : 03/28/2011
# ** Date Modified : 04/23/2011
# ** Script Tag    : IEO-034(Lotus Status)
# ** Difficulty    : Easy
# ** Version       : 1.0a
# ** IEO ID        : 034
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# ** CREDITS/USED STUFF/EDITING
#-*--------------------------------------------------------------------------*-#
# You may:
# Edit and Adapt this script as long you credit aforementioned author(s).
#
# You may not:
# Claim this as your own work, or redistribute without the consent of the author.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#-*--------------------------------------------------------------------------*-#
# 2 scripts in a row.
# Okay so this is a rewrite of the Status scene.
# Nothing much just added the element resistances.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTRUCTIONS
#-*--------------------------------------------------------------------------*-#
#
# Plug 'n' Play
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#-*--------------------------------------------------------------------------*-#
#
# Breaks a lot of the core methods in the Status Scene.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#-*--------------------------------------------------------------------------*-#
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
#
#-*--------------------------------------------------------------------------*-#
# Below
#   Materials
#
# Above
#   Main
#   Everything else
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# Classes
#   Game_Actor
#     new-method   :next_exp_r
#     new-method   :level_exp_r
#     new-method   :next_level_exp
#     new-method   :current_exp
#   Scene_Status
#     overwrite    :initialize
#     overwrite    :start
#     overwrite    :terminate
#     overwrite    :update
#     overwrite    :return_scene
#     overwrite    :next_actor
#     overwrite    :prev_actor
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  03/25/2011 - V1.0  Started Script
#  04/08/2011 - V1.0  Finished Script
#  04/23/2011 - V1.1a Added support for Aztile Menu's IPS
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  Breaks stuff, in the status scene.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
($imported ||= {})["IEO-LotusStatus"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
($ieo_script = {})[[34, "LotusStatus"]] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# IEO::LOTUS_STATUS
#==============================================================================#
module IEO
  module LOTUS_STATUS
#==============================================================================#
#                      Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  #--------------------------------------------------------------------------#
  # * DRAW_ELEMENTS
  #--------------------------------------------------------------------------#
  # An array of element ids that should be shown in the element window
  # You can use ranges (0..n) or single integers (1, 2, 3)
  # Eg.
  # DRAW_ELEMENTS = [1..16]
  # DRAW_ELEMENTS = [1, 2, 3, 4, 8..16]
  #--------------------------------------------------------------------------#
    DRAW_ELEMENTS = [1..16]
  #--------------------------------------------------------------------------#
  # * ALL_MEMBERS
  #--------------------------------------------------------------------------#
  # Allow scrolling through all party members, or only the active
  # This only works if you have the Aztile Menu with IPS on.
  #--------------------------------------------------------------------------#
    ALL_MEMBERS = true
#==============================================================================#
#                        End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  end
end

#==============================================================================#
# Vocab
#==============================================================================#
module Vocab
  #--------------------------------------------------------------------------#
  # * new private method :hit
  #--------------------------------------------------------------------------#
  def self.hit     ; return "HitRate" end
  #--------------------------------------------------------------------------#
  # * new private method :eva
  #--------------------------------------------------------------------------#
  def self.eva     ; return "Evasion" end
  #--------------------------------------------------------------------------#
  # * new private method :cri
  #--------------------------------------------------------------------------#
  def self.cri     ; return "Critical" end
  #--------------------------------------------------------------------------#
  # * new private method :exp
  #--------------------------------------------------------------------------#
  def self.exp     ; return "Exp"     end
end

#==============================================================================#
# IEO::Icon
#==============================================================================#
module IEO
  module Icon
    module_function
    def stat(command) ; return 0 end
    def element(elid) ; return 98 end
  end
end

#==============================================================================#
# IEO::LOTUS_STATUS
#==============================================================================#
module IEO::LOTUS_STATUS

  module_function
  # Credit to Yanfly for the range to array method
  #--------------------------------------------------------------------------
  # convert_integer_array
  #--------------------------------------------------------------------------
  def convert_integer_array(array)
    result = []
    array.each { |i|
      case i
      when Range; result |= i.to_a
      when Integer; result |= [i]
      end }
    return result
  end
  #--------------------------------------------------------------------------#
  # * Convert all Ranges to Integers
  #--------------------------------------------------------------------------#
  DRAW_ELEMENTS = convert_integer_array(DRAW_ELEMENTS)

end

#==============================================================================#
# Game_Actor
#==============================================================================#
class Game_System

  attr_accessor :status_all_members

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias ieo034_initialize initialize unless $@
  def initialize
    ieo034_initialize
    @status_all_members = IEO::LOTUS_STATUS::ALL_MEMBERS
  end

end

#==============================================================================#
# Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------#
  # * new method :next_exp_r
  #--------------------------------------------------------------------------#
  def next_exp_r
    return @exp_list[@level+1] - @exp_list[@level]
  end

  #--------------------------------------------------------------------------#
  # * new method :level_exp_r
  #--------------------------------------------------------------------------#
  def level_exp_r
    return @exp - @exp_list[@level]
  end

  #--------------------------------------------------------------------------#
  # * new method :next_level_exp
  #--------------------------------------------------------------------------#
  def next_level_exp
    return @exp_list[@level+1]
  end

  #--------------------------------------------------------------------------#
  # * new method :current_exp
  #--------------------------------------------------------------------------#
  def current_exp
    return @exp
  end

end

#==============================================================================#
# Window_STS_Status
#==============================================================================#
class Window_STS_Status < Window_Status

  attr_accessor :draw_mode
  attr_accessor :draw_mode_max

  #--------------------------------------------------------------------------#
  # * overwrite method :initialize
  #--------------------------------------------------------------------------#
  def initialize(actor)
    super(actor)
    self.width     = Graphics.width
    self.height    = Graphics.height
    @actor         = actor
    @draw_mode     = 0
    @draw_mode_max = 2
    @column_max    = 3
    @spacing       = 0
    refresh()
  end

  #--------------------------------------------------------------------------#
  # * new method :item_rect
  #--------------------------------------------------------------------------#
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = WLH
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = (index / @column_max * WLH)
    return rect
  end
  #--------------------------------------------------------------------------#
  # * overwrite method :refresh
  #--------------------------------------------------------------------------#
  def refresh
    create_contents
    #draw_actor_name(@actor, 4, 0)
    #draw_actor_class(@actor, 128, 0)
    #draw_actor_face(@actor, 8, 32)
    #draw_basic_info(128, 32)
    case @draw_mode
    when 0 # // Normal
      draw_parameters(4, 4)
      draw_exp_info(4, (WLH*7), 156)
      draw_equipments(self.contents.width/2, 32)
      if $imported["IEO-SkillLevelSystem"]
        rect = Rect.new(self.contents.width/2+32, 4, 96, 24)
        draw_actor_skl_p(@actor, rect)
      end
    when 1 # // Skills
      @actor.skills.size.times { |i|
        rect = item_rect(i)
        s = @actor.skills[i]
        if $imported["IEO-SkillLevelSystem"] or $imported["IEO-CustomSkillCosts"]
          draw_obj_name(s, rect, true)
        else
          draw_item_name(s, rect.x, rect.y, true)
        end
      }
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :draw_basic_info
  #--------------------------------------------------------------------------#
  def draw_basic_info(x, y)
    draw_actor_level(@actor, x, y + WLH * 0)
    draw_actor_state(@actor, x, y + WLH * 1)
    draw_actor_hp(@actor, x, y + WLH * 2)
    draw_actor_mp(@actor, x, y + WLH * 3)
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :draw_actor_parameter
  #--------------------------------------------------------------------------#
  def draw_actor_parameter(actor, x, y, type)
    case type
    when :atk, 0
      icon = IEO::Icon.stat(:atk_i)
      parameter_name = Vocab::atk
      parameter_value = actor.atk
    when :def, 1
      icon = IEO::Icon.stat(:def_i)
      parameter_name = Vocab::def
      parameter_value = actor.def
    when :spi, 2
      icon = IEO::Icon.stat(:spi_i)
      parameter_name = Vocab::spi
      parameter_value = actor.spi
    when :agi, 3
      icon = IEO::Icon.stat(:agi_i)
      parameter_name = Vocab::agi
      parameter_value = actor.agi
    when :hit
      icon = IEO::Icon.stat(:hitra)
      parameter_name = Vocab::hit
      parameter_value = actor.hit
    when :eva
      icon = IEO::Icon.stat(:evasi)
      parameter_name = Vocab::eva
      parameter_value = actor.eva
    when :cri
      icon = IEO::Icon.stat(:criti)
      parameter_name = Vocab::cri
      parameter_value = actor.cri
    end
    draw_icon(icon, x, y)
    if icon > 0
      x += 24
    end
    self.contents.font.size = 18
    self.contents.font.color = system_color
    self.contents.draw_text(x, y-4, 100, WLH, parameter_name)
    self.contents.font.size = 16
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 100, y, 36, WLH, parameter_value, 2)
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :draw_parameters
  #--------------------------------------------------------------------------#
  def draw_parameters(x, y)
    draw_actor_parameter(@actor, x, y + WLH * 0, :atk)
    draw_actor_parameter(@actor, x, y + WLH * 1, :def)
    draw_actor_parameter(@actor, x, y + WLH * 2, :spi)
    draw_actor_parameter(@actor, x, y + WLH * 3, :agi)
    draw_actor_parameter(@actor, x, y + WLH * 4, :hit)
    draw_actor_parameter(@actor, x, y + WLH * 5, :eva)
    draw_actor_parameter(@actor, x, y + WLH * 6, :cri)
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :draw_exp_info
  #--------------------------------------------------------------------------#
  def draw_exp_info(x, y, width)
    if $imported["ICY_WindowBase_Xtended"]
      self.contents.font.color = system_color
      self.contents.draw_text(x+16, y, 180, WLH, Vocab::exp)
      self.contents.font.color = normal_color
      y += 24
      icon = IEO::Icon.stat(:exp_i)
      oxz  = icon.eql?(0) ? 0 : 16
      rect = Rect.new(x+oxz, y+12, width-oxz, 8)
      draw_grad_bar(rect.clone, @actor.level_exp_r, @actor.next_exp_r,
        mp_gauge_color1, mp_gauge_color2, Color.new(20, 20, 20),
        2, true)
      rect.x = x ; rect.y = y ; rect.height = 24
      draw_icon(icon, rect.x, rect.y)

      s1 = @actor.current_exp.to_s
      s2 = @actor.next_level_exp.to_s
      st = sprintf("%s/%s", s1, s2)
      self.contents.draw_text(rect, st, 2)
    else
      s1 = sprintf("%s%s", @actor.exp_s, Vocab::exp)
      s2 = sprintf("%s%s", @actor.next_rest_exp_s, Vocab::exp)
      s_next = sprintf(Vocab::ExpNext, Vocab::level)
      self.contents.font.color = system_color
      self.contents.draw_text(x, y + WLH * 0, width, WLH, Vocab::ExpTotal)
      self.contents.draw_text(x, y + WLH * 1, width, WLH, s_next)
      self.contents.font.color = normal_color
      self.contents.draw_text(x, y + WLH * 0+8, width, WLH, s1, 2)
      self.contents.draw_text(x, y + WLH * 1+8, width, WLH, s2, 2)
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :draw_equipments
  #--------------------------------------------------------------------------#
  def draw_equipments(x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, WLH, Vocab::equip)
    for i in 0..4
      draw_item_name(@actor.equips[i], x + 16, y + WLH * (i + 1))
    end
  end

end

#==============================================================================#
# Window_STS_ActorStrip
#==============================================================================#
class Window_STS_ActorStrip < Window_Selectable

  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  ITEM_RECT = Rect.new(0, 0, 40, 40)
  CHARACTER_RECT = Rect.new(4, 4, 32, 32)

  #--------------------------------------------------------------------------#
  # * super method :initialize
  #--------------------------------------------------------------------------#
  def initialize(x, y)
    super(x, y, Graphics.width, CHARACTER_RECT.height+ITEM_RECT.height) # 64
    self.index = 0
    @spacing = 4 ; @item_max = 1 ; @column_max = 1
    refresh
  end

  #--------------------------------------------------------------------------#
  # * new method :actor
  #--------------------------------------------------------------------------#
  def actor ; return @data[self.index] end

  #--------------------------------------------------------------------------#
  # * overwrite method :item_rect
  #--------------------------------------------------------------------------#
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = ITEM_RECT.width
    rect.height = ITEM_RECT.height

    wd = (rect.width + @spacing) * @column_max
    ofx = (self.contents.width - wd) / 2

    rect.x = index % @column_max * (rect.width + @spacing) + ofx
    rect.y = (index / @column_max * rect.height)

    return rect
  end

  #--------------------------------------------------------------------------#
  # * new method :refresh
  #--------------------------------------------------------------------------#
  def refresh
    @data = $game_party.members.compact
    @item_max = @data.size
    @column_max = [[1, @item_max].max, 12].min
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index, enabled = true)
    irect = item_rect(index)
    crect = irect.dup
    crect.x    += CHARACTER_RECT.x     ; crect.y     += CHARACTER_RECT.y
    crect.width = CHARACTER_RECT.width ; crect.height = CHARACTER_RECT.height
    self.contents.clear_rect(irect)
    mem = @data[index]
    return if mem.nil?
    # ---------------------------------------------------- #
    draw_actor_sprite(mem, crect.x, crect.y, enabled)
    #crect.width = irect.width
    # ---------------------------------------------------- #
    #draw_actor_skl_p(mem, crect.clone)
    # ---------------------------------------------------- #
  end

end

#==============================================================================#
# Window_STS_ActorStatus
#==============================================================================#
class Window_STS_ActorStatus < Window_Base

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :actor

  #--------------------------------------------------------------------------#
  # * super method :initialize
  #--------------------------------------------------------------------------#
  def initialize(actor, x, y)
    super(x, y, Graphics.width-x, 128)
    @actor      = actor
    refresh
  end

  #--------------------------------------------------------------------------#
  # * new method :refresh
  #--------------------------------------------------------------------------#
  def refresh
    draw_actor_face(@actor, 0, 0)
    self.contents.font.size = 18
    draw_actor_name(@actor, 108, 4)
    draw_actor_class(@actor, 168, 4)
    draw_actor_hp(@actor, 168, 44)
    draw_actor_mp(@actor, 168, 64)
    draw_actor_level(@actor, 0, 72)
  end

end

#==============================================================================#
# Window_STS_ElementResist
#==============================================================================#
class Window_STS_ElementResist < Window_Selectable

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :actor

  #--------------------------------------------------------------------------#
  # * super method :initialize
  #--------------------------------------------------------------------------#
  def initialize(actor, x, y)
    super(x, y, 168, Graphics.height-y)
    @actor = actor
    @item_max   = 1
    @column_max = 1
    refresh
    self.active = false
    self.index  = -1
  end

  #--------------------------------------------------------------------------#
  # * new method :refresh
  #--------------------------------------------------------------------------#
  def refresh
    @elements = IEO::LOTUS_STATUS::DRAW_ELEMENTS
    @item_max = @elements.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index, enabled=true)
    rect = item_rect(index)
    ele = @elements[index]
    val = @actor.element_rate(ele)
    nm  = $data_system.elements[ele]
    draw_icon(IEO::Icon.element(ele), rect.x, rect.y)
    self.contents.font.size = 16
    rect.x += 24 ; rect.width -= 24
    self.contents.draw_text(rect, nm)
    self.contents.draw_text(rect, sprintf("%s%", val), 2)
  end

end

#==============================================================================#
# Scene_Status
#==============================================================================#
class Scene_Status < Scene_Base

  include IEX::SCENE_ACTIONS if $imported["IEX_SceneActions"]

  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  SLIDY_WINDOWS = false
  SLIDY_WINDOWS = ($imported["IEX_SceneActions"] && SLIDY_WINDOWS)

  #--------------------------------------------------------------------------#
  # * overwrite method :initialize
  #--------------------------------------------------------------------------#
  def initialize(actor, called = :menu, return_index=3)
    super()
    # ---------------------------------------------------- #
    @calledfrom = called
    @return_index = return_index
    # ---------------------------------------------------- #
    @actor = nil
    @actor_index = 0
    @index_call = false
    # ---------------------------------------------------- #
    if actor.kind_of?(Game_Battler)
      @actor = actor
    elsif actor != nil
      if $game_system.status_all_members
        @actor = $game_party.all_members[actor]
      else
        @actor = $game_party.members[actor]
      end
      @actor_index = actor
      @index_call = true
    end
    # ---------------------------------------------------- #
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :start
  #--------------------------------------------------------------------------#
  def start
    # ---------------------------------------------------- #
    super()
    create_menu_background
    # ---------------------------------------------------- #
    @iwps = [Graphics.width / 2, Graphics.height / 2,
      Graphics.width, Graphics.height]
    iwps  = @iwps
    # ---------------------------------------------------- #
    @windows = { }
    # ---------------------------------------------------- #
    #@windows["Party"]        = Window_STS_ActorStrip.new(0, 0)
    #@windows["Party"].active = false
    #@windows["Party"].index  = @actor_index
    #@windows["Party"].update_cursor
    # ---------------------------------------------------- #
    @windows["EleList"]        = Window_STS_ElementResist.new(@actor, 0, 0)
    # ---------------------------------------------------- #
    @windows["AStatus"]        = Window_STS_ActorStatus.new(
                                   @actor, @windows["EleList"].width, 0)
    @windows["Status"]         = Window_STS_Status.new(@actor)
    @windows["Status"].x       = @windows["EleList"].width
    @windows["Status"].width  -= @windows["EleList"].width
    @windows["Status"].y       = @windows["AStatus"].height
    @windows["Status"].height -= @windows["AStatus"].height
    @windows["Status"].refresh
    @status_window = @windows["Status"]
    # ---------------------------------------------------- #
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :terminate
  #--------------------------------------------------------------------------#
  def terminate
    # ---------------------------------------------------- #
    super()
    # ---------------------------------------------------- #
    dispose_menu_background
    # ---------------------------------------------------- #
    for win in @windows.values.compact ; win.dispose end
    # ---------------------------------------------------- #
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :return_scene
  #--------------------------------------------------------------------------#
  def return_scene
    if SLIDY_WINDOWS
      # ---------------------------------------------------- #
      #pull_windows_right(["SStat"], @windows["SStat"].width)
      #pull_windows_left(["Level", "Skill"], @windows["Skill"].width)
      #pull_windows_up(["Party"], @windows["Party"].height)
      # ---------------------------------------------------- #
    end
    case @calledfrom
    when :map
      $scene = Scene_Map.new
    when :menu
      $scene = Scene_Menu.new(@return_index)
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :next_actor
  #--------------------------------------------------------------------------#
  def next_actor
    @actor_index += 1
    if $game_system.status_all_members
      @actor_index %= $game_party.all_members.size
    else
      @actor_index %= $game_party.members.size
    end
    $scene = Scene_Status.new(@actor_index)
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :prev_actor
  #--------------------------------------------------------------------------#
  def prev_actor
    @actor_index += $game_party.members.size - 1
    if $game_system.status_all_members
      @actor_index %= $game_party.all_members.size
    else
      @actor_index %= $game_party.members.size
    end
    $scene = Scene_Status.new(@actor_index)
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update
  #--------------------------------------------------------------------------#
  def update
    super()
    update_menu_background
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::R)
      Sound.play_cursor
      next_actor
    elsif Input.trigger?(Input::L)
      Sound.play_cursor
      prev_actor
    elsif Input.trigger?(Input::LEFT)
      Sound.play_cursor
      @windows["Status"].draw_mode -= 1
      @windows["Status"].draw_mode %= @windows["Status"].draw_mode_max
      @windows["Status"].refresh
    elsif Input.trigger?(Input::RIGHT)
      Sound.play_cursor
      @windows["Status"].draw_mode += 1
      @windows["Status"].draw_mode %= @windows["Status"].draw_mode_max
      @windows["Status"].refresh
    end
    # ---------------------------------------------------- #
    for win in @windows.values.compact ; win.update if win.active end
    # ---------------------------------------------------- #
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
