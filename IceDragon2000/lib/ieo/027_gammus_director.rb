#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Gammus Director
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Screen, Map)
# ** Script Type   : Screen Effects
# ** Date Created  : 03/29/2011
# ** Date Modified : 10/01/2011
# ** Script Tag    : IEO-027(Gammus Director)
# ** Difficulty    : Easy, Medium
# ** Version       : 1.3
# ** IEO ID        : 027
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# ** CREDITS/USED STUFF/EDITING
#-*--------------------------------------------------------------------------*-#
# You may:
# Edit and Adapt this script as long you credit aforementioned authors.
#
# You may not:
# Claim this as your own work, or redistribute without the consent of the author.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#-*--------------------------------------------------------------------------*-#
#
# *Pops out Camera*
# Alright take 27, action!
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
# Everything.... hopefully
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#-*--------------------------------------------------------------------------*-#
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ? Materials but above ? Main. Remember to save.
#
#-*--------------------------------------------------------------------------*-#
# Below
#  Materials
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
#   Game_Map
#     new-method   :gameviewrect
#   Game_Interpreter
#     new-method   :get_event
#     new-method   :jump_to
#     new-method   :jump_to_event
#     new-method   :scroll_with_event
#     new-method   :move_viewports
#     new-method   :gfreeze
#     new-method   :transition
#     new-method   :reset_viewports
#     new-method   :reset_director
#     new-method   :wait_for_animation
#   Sprite_Base
#     alias-method :dispose
#     alias-method :animation_set_sprites
#   Sprite_Character
#     alias-method :update
#   Sprite_Timer
#     overwrite    :initialize
#   Spriteset_Map
#     overwrite    :create_viewports
#   Spriteset_Battle
#     overwrite    :create_viewports
#   Window_Help
#     overwrite    :initialize
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  03/29/2011 - V1.0  Started and Finished Script
#  05/04/2011 - V1.1  Added Camera Class ***
#  07/16/2011 - V1.2  Fixed get_event method
#  10/01/2011 - V1.3  Fixed Viewport updates
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  Non
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FAQ
#-*--------------------------------------------------------------------------*-#
# Acronyms -
#  BEM - Battle Engine Melody
#  CBS - Custom Battle System
#  DBS - Default Battle System
#  GTBS- Gubid's Tactical Battle System
#  IEO - Icy Engine Omega
#  IEX - Icy Engine Xellion
#  OHM - IEO-005(Ohmerion)
#  SRN - IEX - Siren
#  YGG - IEX - Yggdrasil
#  ATB - Active Turn Battle
#  DTB - Default Turn Battle
#  PTB - Press Turn Battle
#  CTB - Charge Turn Battle
#
# Q. Whats up with the IDs?
# A. Well due to some naming issues, I ended up with 5 scripts in IEX
#    all having similar names, this causes some issues for updating
#    and sorting.
#    I have decided to add some IDS so I can sort and find script with EASE.
#
# Q. Where is the name from?
# A. Roman Alphabet, thanks to PentagonBuddy and Jalen by the way.
#
# Q. Where did you learn scripting?
# A. Yanfly's scripts, read almost everyone of them, so my scripting style
#    kinda looks like his.
#
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
$imported = {} if $imported == nil
$imported["IEO-GammusDirector"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
$ieo_script = {} if $ieo_script == nil
$ieo_script[[27, "GammusDirector"]] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# ** IEO
#==============================================================================#
module IEO

  class GammusCamera

    Bounds = Struct.new(:x1, :x2, :y1, :y2)

    attr_accessor :x
    attr_accessor :y
    attr_accessor :target_x
    attr_accessor :target_y
    attr_accessor :speed_x
    attr_accessor :speed_y

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
    def initialize
      @bounds                = Bounds.new(0.0, 0.0, 0.0, 0.0)
      @z                     = 0
      @x         = @y        = 0.0
      @target_x  = @target_y = 0.0
      @sc_width, @sc_height  = 32, 32

      @ox, @oy = 0.0, 0.0
      @target_ox, @target_oy = 0.0, 0.0
      @offset_amount = 0.0 #16.0
      @bounded = true
    end

  #--------------------------------------------------------------------------#
  # * new-method :config_bounds
  #--------------------------------------------------------------------------#
    def config_bounds(x1, x2, y1, y2)
      @bounds.x1, @bounds.x2, @bounds.y1, @bounds.y2 = x1, x2, y1, y2
    end

  #--------------------------------------------------------------------------#
  # * new-method :unbound
  #--------------------------------------------------------------------------#
    def unbound
      @bounded = false
    end

  #--------------------------------------------------------------------------#
  # * new-method :bound
  #--------------------------------------------------------------------------#
    def bound
      @bounded = true
    end

  #--------------------------------------------------------------------------#
  # * new-method :center
  #--------------------------------------------------------------------------#
    def center(x, y)
      set_target(x, y)
      @x, @y = @target_x, @target_y
    end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
    def update
      sync_with($game_player)
      movex = movey = 64/60.0
      if @x > @target_x
        @target_ox = inbound_x?(@target_x+1) ? @offset_amount : 0.0
        @x = [@x - movex, @target_x].max
      elsif @x < @target_x
        @target_ox = inbound_x?(@target_x-1) ? -@offset_amount : 0.0
        @x = [@x + movex, @target_x].min
      else
        @target_ox = 0.0
      end
      if @y > @target_y
        @target_oy = inbound_y?(@target_y+1) ? @offset_amount : 0.0
        @y = [@y - movey, @target_y].max
      elsif @y < @target_y
        @target_oy = inbound_y?(@target_y-1) ? -@offset_amount : 0.0
        @y = [@y + movey, @target_y].min
      else
        @target_oy = 0.0
      end
      movex = movey = 64/64.0
      if @ox > @target_ox
        @ox = [@ox - movex, @target_ox].max
      elsif @ox < @target_ox
        @ox = [@ox + movex, @target_ox].min
      end
      if @oy > @target_oy
        @oy = [@oy - movey, @target_oy].max
      elsif @oy < @target_oy
        @oy = [@oy + movey, @target_oy].min
      end
    end

  #--------------------------------------------------------------------------#
  # * new-method :offset_x
  #--------------------------------------------------------------------------#
    def offset_x
      return @ox# * @sc_width
    end

  #--------------------------------------------------------------------------#
  # * new-method :offset_y
  #--------------------------------------------------------------------------#
    def offset_y
      return @oy# * @sc_height
    end

  #--------------------------------------------------------------------------#
  # * new-method :clamp_screen_x
  #--------------------------------------------------------------------------#
    def clamp_screen_x(scrn_x)
      return scrn_x.clamp(@bounds.x1*@sc_width, (@bounds.x2*@sc_width)-(Graphics.width-@sc_width))
    end

  #--------------------------------------------------------------------------#
  # * new-method :clamp_screen_y
  #--------------------------------------------------------------------------#
    def clamp_screen_y(scrn_y)
      return scrn_y.clamp(@bounds.y1*@sc_height, (@bounds.y2*@sc_height)-(Graphics.height-@sc_height))
    end

  #--------------------------------------------------------------------------#
  # * new-method :screen_x
  #--------------------------------------------------------------------------#
    def screen_x
      return clamp_screen_x(Integer((@x * @sc_width) - offset_x))
    end

  #--------------------------------------------------------------------------#
  # * new-method :screen_y
  #--------------------------------------------------------------------------#
    def screen_y
      return clamp_screen_y(Integer((@y * @sc_height) - offset_y))
    end

  #--------------------------------------------------------------------------#
  # * new-method :screen_z
  #--------------------------------------------------------------------------#
    def screen_z ; return Integer(@z) ; end

  #--------------------------------------------------------------------------#
  # * new-method :sync_with
  #--------------------------------------------------------------------------#
    def sync_with(sync_object)
      set_target(sync_object.real_x / 256.0, sync_object.real_y / 256.0)
    end

  #--------------------------------------------------------------------------#
  # * new-method :set_target
  #--------------------------------------------------------------------------#
    def set_target(tx, ty)
      @target_x, @target_y = clamp_x(tx ), clamp_y( ty)
    end

  #--------------------------------------------------------------------------#
  # * new-method :inbound_x?
  #--------------------------------------------------------------------------#
    def inbound_x?(x)
      return x.between?(@bounds.x1, @bounds.x2)
    end

  #--------------------------------------------------------------------------#
  # * new-method :inbound_y?
  #--------------------------------------------------------------------------#
    def inbound_y?(y)
      return y.between?(@bounds.y1, @bounds.y2)
    end

  #--------------------------------------------------------------------------#
  # * new-method :clamp_x
  #--------------------------------------------------------------------------#
    def clamp_x(x)
      scrnsqWidth  = (Graphics.width / @sc_width)
      halfwidth  = scrnsqWidth / 2
      (x - halfwidth).clamp(
        @bounds.x1,
        (@bounds.x2 - @bounds.x2.min(scrnsqWidth - 1))
      )
    end

  #--------------------------------------------------------------------------#
  # * new-method :clamp_y
  #--------------------------------------------------------------------------#
    def clamp_y(y)
      scrnsqHeight = (Graphics.height / @sc_height)
      halfheight = scrnsqHeight / 2
      (y - halfheight).clamp(
        @bounds.y1,
        (@bounds.y2 - @bounds.y2.min(scrnsqHeight - 1))
      )
    end

  #--------------------------------------------------------------------------#
  # * new-method :clamp_xy
  #--------------------------------------------------------------------------#
    def clamp_xy(x, y)
      return clamp_x(x ), clamp_y( y)
    end

  end

end

#==============================================================================#
# ** Game_System
#==============================================================================#
class Game_System

  unless $imported["IEO-BugFixesUpgrades"]

    #--------------------------------------------------------------------------#
    # * Constants
    #--------------------------------------------------------------------------#
    GAMEVIEWX    = 0
    GAMEVIEWY    = 0
    GAMEWIDTH    = Graphics.width
    GAMEHEIGHT   = Graphics.height

    #--------------------------------------------------------------------------#
    # * new method :gameviewrect
    #--------------------------------------------------------------------------#
    def gameviewrect
      return Rect.new(GAMEVIEWX, GAMEVIEWY, GAMEWIDTH, GAMEHEIGHT)
    end

  end

end

$camera = ::IEO::GammusCamera.new

class Game_Map

  alias :ieo027_gmp_setup :setup unless $@
  def setup(*args, &block)
    ieo027_gmp_setup(*args, &block)
    $camera.config_bounds(0, width-1, 0, height-1)
  end

  def calc_parallax_x(bitmap)
    if bitmap == nil
      return 0
    elsif @parallax_loop_x
      return @parallax_x / 16
    elsif loop_horizontal?
      return 0
    else
      w1 = bitmap.width - Graphics.width
      w2 = @map.width * 32 - Graphics.width
      if w1 <= 0 or w2 <= 0
        return 0
      else
        return @parallax_x * w1 / w2 / 8
      end
    end
  end

  def calc_parallax_y(bitmap)
    if bitmap == nil
      return 0
    elsif @parallax_loop_y
      return @parallax_y / 16
    elsif loop_vertical?
      return 0
    else
      h1 = bitmap.height - Graphics.height
      h2 = @map.height * 32 - Graphics.height
      if h1 <= 0 or h2 <= 0
        return 0
      else
        return @parallax_y * h1 / h2 / 8
      end
    end
  end

  def update_parallax
    @parallax_x += @parallax_sx * 4 if @parallax_loop_x
    @parallax_y += @parallax_sy * 4 if @parallax_loop_y
  end

end

class Game_Character

  #--------------------------------------------------------------------------#
  # * new-method :offset_x
  #--------------------------------------------------------------------------#
  def offset_x ; return ($camera.nil? ? 0 : $camera.screen_x)-16 ; end

  #--------------------------------------------------------------------------#
  # * new-method :offset_y
  #--------------------------------------------------------------------------#
  def offset_y ; return ($camera.nil? ? 0 : $camera.screen_y)-32 ; end

  #--------------------------------------------------------------------------#
  # * new-method :screen_x
  #--------------------------------------------------------------------------#
  def screen_x
    return Integer(((@real_x/256.0) * 32) - offset_x)
  end

  #--------------------------------------------------------------------------#
  # * new-method :screen_y
  #--------------------------------------------------------------------------#
  def screen_y
    y = Integer(((@real_y/256.0) * 32) - offset_y) - (object? ? 0 : 4)
    n = (@jump_count >= @jump_peak) ? @jump_count - @jump_peak : @jump_peak - @jump_count
    return y - (@jump_peak * @jump_peak - n * n) / 2
  end

  #--------------------------------------------------------------------------#
  # * new-method :screen_z
  #--------------------------------------------------------------------------#
  #def screen_z ; return @z ; end

end

class Game_Player

  def update_scroll(last_real_x, last_real_y) ; end

  def center(x, y)
    $camera.center(x, y)
  end

end

class Spriteset_Map

  alias :ieo027_spm_update_tilemap :update_tilemap unless $@
  def update_tilemap
    @tilemap.ox = $camera.screen_x #$game_map.display_x / 8
    @tilemap.oy = $camera.screen_y #$game_map.display_y / 8
    @tilemap.update
  end

  def update_weather
    @weather.type = $game_map.screen.weather_type
    @weather.max = $game_map.screen.weather_max
    @weather.ox = $camera.screen_x
    @weather.oy = $camera.screen_y
    @weather.update
  end

end

#==============================================================================#
# ** Game_Interpreter
#==============================================================================#
class Game_Interpreter

  #--------------------------------------------------------------------------#
  # * new method :get_event
  #--------------------------------------------------------------------------#
  def get_event(event_id)
    return get_character(event_id)
  end

  #--------------------------------------------------------------------------#
  # * new method :jump_to
  #--------------------------------------------------------------------------#
  def jump_to(x, y, fadetype=0, fadetime=60)
    # // Prepare
    Graphics.fadeout(fadetime)    if fadetype == 1
    Graphics.freeze               if fadetype == 2
    # // Center display
    $game_player.center(x, y)
    $game_map.need_refresh = true
    $game_map.update
    if $scene.is_a?(Scene_Map)
      $scene.spriteset.force_update_characters ; $scene.spriteset.update
    end
    # // End
    Graphics.fadein(fadetime)     if fadetype == 1
    Graphics.transition(fadetime) if fadetype == 2
  end

  #--------------------------------------------------------------------------#
  # * new method :jump_to_event
  #--------------------------------------------------------------------------#
  def jump_to_event(event_id, fadetype=0, fadetime=60)
    ev = get_event(event_id)
    return if ev.nil?
    x, y = ev.x, ev.y
    jump_to(x, y, fadetype, fadetime)
  end

  #--------------------------------------------------------------------------#
  # * new method :scroll_with_event
  #--------------------------------------------------------------------------#
  def scroll_with_event(event_id)
    ev = get_event(event_id)
    return if ev.nil?
    jump_to_event(event_id)
    $scene.scroll_event = ev
    $scene.scroll_event = nil if $scene.scroll_event == $game_player
  end

  #--------------------------------------------------------------------------#
  # * new method :move_viewports
  #--------------------------------------------------------------------------#
  def move_viewports(movetype, amount=0, time=60, rate=240)
    case movetype
    when :x
      $scene.spriteset.viewtarget_x     = amount
      $scene.spriteset.viewtarget_xtime = time
      $scene.spriteset.viewrate_x       = rate
    when :y
      $scene.spriteset.viewtarget_y     = amount
      $scene.spriteset.viewtarget_ytime = time
      $scene.spriteset.viewrate_y       = rate
    when :width
      $scene.spriteset.viewtarget_width = amount
      $scene.spriteset.viewtarget_widthtime = time
      $scene.spriteset.viewrate_width       = rate
    when :height
      $scene.spriteset.viewtarget_height = amount
      $scene.spriteset.viewtarget_heighttime = time
      $scene.spriteset.viewrate_height       = rate
    # Reset
    when :reset
      df = $scene.spriteset.defaultview
      move_viewports(:x,     df[0], time, rate)
      move_viewports(:y,     df[1], time, rate)
      move_viewports(:width, df[2], time, rate)
      move_viewports(:height,df[3], time, rate)
    # // Disabled (Offset Changing is currently Disabled)
    when :ox
      $scene.spriteset.viewtarget_ox     = amount
      $scene.spriteset.viewtarget_oxtime = time
      $scene.spriteset.viewrate_ox       = rate
    when :oy
      $scene.spriteset.viewtarget_oy     = amount
      $scene.spriteset.viewtarget_oytime = time
      $scene.spriteset.viewrate_oy       = rate
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :gfreeze
  #--------------------------------------------------------------------------#
  def gfreeze ; Graphics.freeze end

  #--------------------------------------------------------------------------#
  # * new method :transition
  #--------------------------------------------------------------------------#
  def transition(name="", time=60, ambiguity = 40)
    Graphics.transition(time, name, ambiguity)
  end

  #--------------------------------------------------------------------------#
  # * new method :reset_viewports
  #--------------------------------------------------------------------------#
  def reset_viewports ; $scene.spriteset.reset_viewport_variables ; end

  #--------------------------------------------------------------------------#
  # * new method :reset_director
  #--------------------------------------------------------------------------#
  def reset_director ; $scene.spriteset.reset_director ; end

  #--------------------------------------------------------------------------#
  # * new method :wait_for_animation
  #--------------------------------------------------------------------------#
  def wait_for_animation(aid)
    frames = $data_animations[ aid ].frame_max
    if $imported["CoreFixesUpgradesMelody"]
      @wait_count = frames * Sprite_Base::RATE
    else
      @wait_count = frames * 4
    end
  end

end

#==============================================================================#
# ** Spriteset_Map
#==============================================================================#
class Spriteset_Map

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  # // Target Values
  attr_accessor :viewtarget_x
  attr_accessor :viewtarget_y
  attr_accessor :viewtarget_ox
  attr_accessor :viewtarget_oy
  attr_accessor :viewtarget_width
  attr_accessor :viewtarget_height
  # // Target Times
  attr_accessor :viewtarget_xtime
  attr_accessor :viewtarget_ytime
  attr_accessor :viewtarget_oxtime
  attr_accessor :viewtarget_oytime
  attr_accessor :viewtarget_widthtime
  attr_accessor :viewtarget_heighttime
  # // Rates
  attr_accessor :viewrate_x
  attr_accessor :viewrate_y
  attr_accessor :viewrate_ox
  attr_accessor :viewrate_oy
  attr_accessor :viewrate_width
  attr_accessor :viewrate_height
  # // Defaultview
  attr_accessor :defaultview

  VIEWPORT_VARIABLES = ['@viewport1', '@viewport2', '@viewport3']
  TARGET_VARIABLES = ['x', 'y', 'width', 'height']#, 'ox', 'oy']

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo027_spm_initialize :initialize unless $@
  def initialize
    # // Arrays
    @view_director      = []
    @defaultview = [$game_system.gameviewrect.x, $game_system.gameviewrect.y,
      $game_system.gameviewrect.width, $game_system.gameviewrect.height, 0, 0]
    reset_director
    # // Init
    ieo027_spm_initialize
  end

  #--------------------------------------------------------------------------#
  # * new method :reset_director
  #--------------------------------------------------------------------------#
  def reset_director
    # // Target Values
    @viewtarget_x       = nil
    @viewtarget_y       = nil
    @viewtarget_width   = nil
    @viewtarget_height  = nil
    @viewtarget_ox      = nil
    @viewtarget_oy      = nil
    # // Target Times
    @viewtarget_xtime   = nil
    @viewtarget_ytime   = nil
    @viewtarget_widthtime    = nil
    @viewtarget_heighttime   = nil
    @viewtarget_oxtime  = nil
    @viewtarget_oytime  = nil
    # // Rates
    @viewrate_x         = nil
    @viewrate_y         = nil
    @viewrate_width     = nil
    @viewrate_height    = nil
    @viewrate_ox        = nil
    @viewrate_oy        = nil
    # // Current_Variables
    reset_viewport_variables
  end

  #--------------------------------------------------------------------------#
  # * new method :reset_viewport_variables
  #--------------------------------------------------------------------------#
  def reset_viewport_variables
    # // Reset Current_Variables
    @viewcurrent_x      = @defaultview[0]
    @viewcurrent_y      = @defaultview[1]
    @viewcurrent_width  = @defaultview[2]
    @viewcurrent_height = @defaultview[3]
    @viewcurrent_ox     = @defaultview[4]
    @viewcurrent_oy     = @defaultview[5]
  end

  #--------------------------------------------------------------------------#
  # * new method :force_update_characters
  #--------------------------------------------------------------------------#
  def force_update_characters
    @character_sprites.compact.each { |sp| sp.update }
  end

  #--------------------------------------------------------------------------#
  # * alias method :update
  #--------------------------------------------------------------------------#
  alias :ieo027_spm_update :update unless $@
  def update
    ieo027_spm_update
    update_viewport_move
  end

  target_update = ""
  TARGET_VARIABLES.each { |n|
    target_update += %Q(
      unless @viewtarget_#{n}.nil?
        move = @viewrate_#{n} / @viewtarget_#{n}time.to_f
        if @viewtarget_#{n} > @viewcurrent_#{n}
          @viewcurrent_#{n} = [@viewcurrent_#{n}+move, @viewtarget_#{n}].min
        elsif @viewtarget_#{n} < @viewcurrent_#{n}
          @viewcurrent_#{n} = [@viewcurrent_#{n}-move, @viewtarget_#{n}].max
        end
        # // Reset Variables
        if @viewcurrent_#{n} == @viewtarget_#{n}
          @viewtarget_#{n}      = nil
          @viewtarget_#{n}time  = nil
        end
      end
    )
  }

  viewcode = ""
  VIEWPORT_VARIABLES.each { |v|
    viewcode += %Q(
      #{v}.rect.set( @viewcurrent_x, @viewcurrent_y,
          @viewcurrent_width, @viewcurrent_height ) unless #{v}.nil?
    )
  }

  module_eval(%Q(
  #--------------------------------------------------------------------------#
  # * new method :update_viewport_move
  #--------------------------------------------------------------------------#
  def update_viewport_move
    #{target_update}
    #{viewcode}
  end
  ), 'ieo/027_gammus_director/spriteset_map', 1)

  target_update = nil
  viewcode = nil

end

#==============================================================================#
# ** Scene_Map
#==============================================================================#
class Scene_Map < Scene_Base

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :spriteset
  attr_accessor :scroll_event

  #--------------------------------------------------------------------------#
  # * alias method :update
  #--------------------------------------------------------------------------#
  alias :ieo027_scmp_update :update unless $@
  def update
    $camera.update
    unless @scroll_event.nil?
      last_real_x = @scroll_event.real_x
      last_real_y = @scroll_event.real_y
    end
    ieo027_scmp_update
    unless @scroll_event.nil?
      update_event_scroll(last_real_x, last_real_y)
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :update_event_scroll
  #--------------------------------------------------------------------------#
  def update_event_scroll(last_real_x, last_real_y)
    return if @scroll_event.nil?
    return if last_real_x.nil?
    return if last_real_y.nil?
    ax1 = $game_map.adjust_x(last_real_x)
    ay1 = $game_map.adjust_y(last_real_y)
    ax2 = $game_map.adjust_x(@scroll_event.real_x)
    ay2 = $game_map.adjust_y(@scroll_event.real_y)
    if ay2 > ay1 and ay2 > Game_Player::CENTER_X
      $game_map.scroll_down(ay2 - ay1)
    end
    if ax2 < ax1 and ax2 < Game_Player::CENTER_X
      $game_map.scroll_left(ax1 - ax2)
    end
    if ax2 > ax1 and ax2 > Game_Player::CENTER_Y
      $game_map.scroll_right(ax2 - ax1)
    end
    if ay2 < ay1 and ay2 < Game_Player::CENTER_Y
      $game_map.scroll_up(ay1 - ay2)
    end
  end

end
#==============================================================================#
IEO::REGISTER.log_script(27, "GammusDirector", 1.3) if $imported["IEO-Register"]
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
