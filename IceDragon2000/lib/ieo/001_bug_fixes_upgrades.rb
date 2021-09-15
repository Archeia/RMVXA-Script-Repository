#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - BugFix & Upgrade
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Fixes, Improvements
# ** Script Type   : Bug Fix and Upgrade
# ** Date Created  : 02/19/2011
# ** Date Modified : 09/18/2011
# ** Script Tag    : IEO001(BugFix & Upgrade)
# ** Difficulty    : Easy
# ** Version       : 2.5
# ** IEO ID        : 001
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
# *Munches on Carrot*
# Okay so this script has a couple things to it.
# 1 It allows you to change the game windows size (and the map size)
# 2 Font changes
# 3 An AntiLag (For animations and the Sprites)
# 4 Interpreter Fix
# 5 Plane Fix
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
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
#
#-*--------------------------------------------------------------------------*-#
# Below
#   Materials
#   YEM Core Fixes and Upgrades
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
#   Plane
#     alias-method :initialize
#     alias-method :viewport
#     alias-method :viewport=
#     overwrite    :viewport
#     overwrite    :viewport=
#   Tilemap
#     alias-method :map_data=
#   RPG::Animation
#     new-method   :ieo001_animationcache
#   Game_System
#     alias-method :initialize
#     new-method   :gameviewrect
#     new-method   :battleviewrect
#   Game_Map
#     alias-method :initialize
#     overwrite    :setup
#     overwrite    :setup_scroll
#     overwrite    :calc_parallax_x
#     overwrite    :calc_parallax_y
#     overwrite    :scroll_down
#     overwrite    :scroll_left
#     overwrite    :scroll_right
#     overwrite    :scroll_up
#     new-method   :map_name
#     new-method   :create_map_cache
#     new-method   :load_map_infos
#     new-method   :cache_areas
#   Game_Character
#     new-method   :out_of_screen?
#     overwrite    :collide_with_characters?
#     overwrite    :jump
#   Game_Player
#     overwrite    :center
#   Game_Interpreter
#     overwrite    :command_122
#   Sprite_Base
#     alias-method :dispose_animation
#     overwrite    :animation_set_sprites
#     overwrite    :start_animation
#     overwrite    :update_animation
#     new-method   :update_animation_position
#   Sprite_Character
#     overwrite    :update
#   Sprite_Timer
#     overwrite    :initialize
#   Spriteset_Map
#     overwrite    :create_pictures
#     overwrite    :create_viewports
#   Spriteset_Battle
#     overwrite    :create_viewports
#   Window_Selectable
#     alias-method :initialize
#     overwrite    :create_contents
#     overwrite    :update_cursor
#   Window_Command
#     overwrite    :item_rect
#     overwrite    :draw_item
#   Window_Help
#     overwrite    :initialize
#   Scene_Title
#     alias-method :load_database
#     alias-method :load_bt_database
#     new-method   :load_ieo001_cache
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  02/19/2011 - WIP  Started Script
#  03/29/2011 - V1.0 Finished Script
#  05/04/2011 - V1.1 Added Animation Fix
#  05/07/2011 - V1.2 Added Animation Anti Lag, and Adaptive Cells
#  05/08/2011 - V1.2 Added Picture Modding (change the number used 0..20)
#  05/16/2011 - V1.3 Added Smooth Cursor
#  05/20/2011 - V1.4 Added Map and Area Caching
#  06/09/2011 - V1.5 Added Options for Adjusting Smooth Cursor and Adaptive Cursor
#  06/16/2011 - V1.6 Fixed Animation Error
#  06/21/2011 - V1.7 Heavy Sprite Optimization
#  07/08/2011 - V1.8 Few Changes, added Font size
#  07/11/2011 - V1.9 Added Game Interpreter Fix
#  07/16/2011 - V2.0 New Map Caching Options, adding error handling for Tilemap
#  08/10/2011 - V2.1 Added timing_a for animations
#  08/27/2011 - V2.2 Added Full Wrap cursor
#  09/04/2011 - V2.3 Fixed a small cursor bug, added smooth page scrolling
#  09/15/2011 - V2.4 Improved Area Caching (Now caches all area's at start)
#  09/18/2011 - V2.5 Added new text shadowing
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
#    I have decided to add some IDs so I can sort and find script with EASE.
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
($imported ||= {})["IEO-BugFixesUpgrades"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
($ieo_script ||= {})[[1, "BugFixesUpgrades"]] = 2.3
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# ** IEO::UPGRADE
#==============================================================================#
module IEO
  module UPGRADE
#==============================================================================#
#                      Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
    ## This is the Game's Window (Graphics) size
    GAME_WIDTH  = 544+32
    GAME_HEIGHT = 416+32
    ## This is the actual sizes that are used ingame for the map
    INGAME_VIEWX = 0 #(640 - 544) / 2
    INGAME_VIEWY = 0 #(480 - 416) / 2
    INGAME_WIDTH = GAME_WIDTH
    INGAME_HEIGHT= GAME_HEIGHT
    ## Used for the battle spriteset
    BATTLE_VIEWX = 0
    BATTLE_VIEWY = 0
    BATTLE_WIDTH = GAME_WIDTH
    BATTLE_HEIGHT= GAME_HEIGHT
    ## AntiLag
    ANTI_LAG     = true
    ANTI_LAGRECT = Rect.new(INGAME_VIEWX-48, INGAME_VIEWY-48, INGAME_WIDTH+48, INGAME_HEIGHT+48)
    ## Fonts
    DEFAULT_FONTS    = ["Eurostile"]   # ["Corbel", "Consolas", "Cambria", "Adobe Gothic Std B"]
    DEFAULT_FONTSIZE = nil
    ## Text
    USE_NEW_SHADOW       = true
    DEFAULT_SHADOW_COLOR = Color.new(0, 0, 0)
    ## Animation
    ANIMATION_FIX     = true  ## When this is enabled the animation will not follow the screen like default
    ANIMATION_CELLS   = 5     ## Limited number of cells proccessed for animations
    ANIMATION_ANTILAG = true  ## Hide Animation when outside of screen?
    ## Picture 1..20 Default
    PICTURE_RANGE = 0..20
    ## Window_Selectable
    SMOOTH_CURSOR = true
    CURSOR_TIME   = 16.0
    ## Always wrap cursor in window?
    FULL_WRAP     = true
    ## Smooth scroll active window pages
    SMOOTH_PAGE   = true
    PAGE_TIME     = 30.0
    ## Window_Command
    ADAPTIVE_CURSOR = true
    WIDTH_ADD = 12
    ## Map Caching
    USE_MAP_CACHE      = true
    KEEP_AREA_CACHE    = false ## Should the area cache be saved with the Game_Map?
    KEEP_MAP_CACHE     = false ## Should the cache be saved with the Game_Map?
    KEEP_MAPINFO_CACHE = false ## Should the area cache be saved with the Game_Map?

#==============================================================================#
#                        End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  end
end
#==============================================================================#
#==============================================================================#
module IEO
  module Core
    def self.init
      ## Graphics
      Graphics.resize_screen(IEO::UPGRADE::GAME_WIDTH, IEO::UPGRADE::GAME_HEIGHT)
    ## Font
      Font.default_name = IEO::UPGRADE::DEFAULT_FONTS unless IEO::UPGRADE::DEFAULT_FONTS.empty?
      Font.default_size = IEO::UPGRADE::DEFAULT_FONTSIZE unless IEO::UPGRADE::DEFAULT_FONTSIZE.nil?
    ## Map Cache
      $area_cache = {} ## Used if KEEP_AREA_CACHE == false
      $map_cache  = {} ## Used if KEEP_MAP_CACHE == false
      $common_event_cache = nil
    end

    init
  end
end
## Plane viewport Fix
#==============================================================================#
# ** Plane
#==============================================================================#
class Plane
if defined?(RGSS2)
  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo001_plane_initialize :initialize unless $@
  def initialize(view=nil)
    @_ref_viewport = view ; ieo001_plane_initialize(view)
  end

  #--------------------------------------------------------------------------#
  # * alias-method :viewport
  #--------------------------------------------------------------------------#
  alias viewport= viewport unless $@
  def viewport ; return @_ref_viewport end

  #--------------------------------------------------------------------------#
  # * new/alias-method :viewport=
  #--------------------------------------------------------------------------#
  alias set_viewport viewport= unless $@
  def viewport=(newview)
    @_ref_viewport = newview ; set_viewport(newview)
  end
end
end

#==============================================================================#
# ** Tilemap
#==============================================================================#
class Tilemap
if defined?(RGSS2)
  #--------------------------------------------------------------------------#
  # * alias-method :map_data=
  #--------------------------------------------------------------------------#
  alias :ieo001_tmap_map_data_eq :map_data= unless $@
  def map_data=(*args, &block)
    if args[0].zsize != 3
      raise "Error: Tilemap Z size(#{args[0].zsize}) is invalid, a size of 3 is required"
      exit
    end
    ieo001_tmap_map_data_eq(*args, &block)
  end
end
end

if IEO::UPGRADE::USE_NEW_SHADOW
#==============================================================================#
# ** Font
#==============================================================================#
class Font

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :shadow_color

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo001_fnt_initialize :initialize unless $@
  def initialize(*args, &block)
    ieo001_fnt_initialize(*args, &block)
    @shadow_color = IEO::UPGRADE::DEFAULT_SHADOW_COLOR
  end

end

#==============================================================================#
# ** Bitmap
#==============================================================================#
class Bitmap

  #--------------------------------------------------------------------------#
  # * alias-method :draw_text
  #--------------------------------------------------------------------------#
  alias :ieo001_bmp_draw_text :draw_text unless $@
  def draw_text(*args, &block)
    if self.font.shadow
      self.font.shadow = false
      args2 = args.clone
      if args2[0].is_a?(Rect)
        args2[0] = args2[0].clone
        args2[0].x += 1 ; args2[0].y += 1
      else                      ; args2[0] += 1   ; args2[1] += 1   ; end
      old_color = self.font.color.clone
      self.font.color = self.font.shadow_color
      ieo001_bmp_draw_text(*args2, &block)
      self.font.color = old_color
      ieo001_bmp_draw_text(*args, &block)
      self.font.shadow = true
    else
      ieo001_bmp_draw_text(*args, &block)
    end
  end

end
end ## USE_NEW_SHADOW

#==============================================================================#
# ** RPG::Animation
#==============================================================================#
class RPG::Animation
  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :cell_count
  attr_accessor :timings_a

  #--------------------------------------------------------------------------#
  # * new-method :ieo001_animationcache
  #--------------------------------------------------------------------------#
  def ieo001_animationcache
    @cell_count = [IEO::UPGRADE::ANIMATION_CELLS, self.frame_max].min
    cells = @name =~ /<cell\[(\d+)\]>/i
    @cell_count = cells.to_i unless cells.nil?
    @timings_a  = Array.new(self.frame_max).map! { [] }
    @timings.each { |t| @timings_a[t.frame] << t }
  end

  #--------------------------------------------------------------------------#
  # * new-method :timings_a
  #--------------------------------------------------------------------------#
  def timings_a
    if @timings_a.nil?
      @timings_a = Array.new(self.frame_max).map! { [] }
      @timings.each { |t| @timings_a[t.frame] << t }
    end
    return @timings_a
  end
end

#==============================================================================#
# ** RPG::Map
#==============================================================================#
class RPG::Map
  #--------------------------------------------------------------------------#
  # * new-method :do_on_load
  #--------------------------------------------------------------------------#
  def do_on_load
  end
end

#==============================================================================#
# ** Game_System
#==============================================================================#
class Game_System
  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  GAMEVIEWX    = IEO::UPGRADE::INGAME_VIEWX
  GAMEVIEWY    = IEO::UPGRADE::INGAME_VIEWY
  GAMEWIDTH    = IEO::UPGRADE::INGAME_WIDTH
  GAMEHEIGHT   = IEO::UPGRADE::INGAME_HEIGHT
  BATVIEWX     = IEO::UPGRADE::BATTLE_VIEWX
  BATVIEWY     = IEO::UPGRADE::BATTLE_VIEWY
  BATWIDTH     = IEO::UPGRADE::BATTLE_WIDTH
  BATHEIGHT    = IEO::UPGRADE::BATTLE_HEIGHT
  ANTI_LAGRECT = IEO::UPGRADE::ANTI_LAGRECT
  ANIMATIONFIX = IEO::UPGRADE::ANIMATION_FIX
  ANIMATIONALG = IEO::UPGRADE::ANIMATION_ANTILAG

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :anim_cell_limit
  attr_accessor :picture_range
  attr_accessor :smooth_cursor_time
  attr_accessor :adapt_width_add

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo001_gsys_initialize :initialize unless $@
  def initialize
    ieo001_gsys_initialize
    @anim_cell_limit    = IEO::UPGRADE::ANIMATION_CELLS
    @picture_range      = IEO::UPGRADE::PICTURE_RANGE
    @smooth_cursor_time = IEO::UPGRADE::CURSOR_TIME
    @adapt_width_add    = IEO::UPGRADE::WIDTH_ADD
  end

  #--------------------------------------------------------------------------#
  # * new-method :gameviewrect
  #--------------------------------------------------------------------------#
  def gameviewrect
    return Rect.new(GAMEVIEWX, GAMEVIEWY, GAMEWIDTH, GAMEHEIGHT)
  end

  #--------------------------------------------------------------------------#
  # * new-method :battleviewrect
  #--------------------------------------------------------------------------#
  def battleviewrect
    return Rect.new(BATVIEWX, BATVIEWY, BATWIDTH, BATHEIGHT)
  end
end

#==============================================================================#
# ** Game_Map
#==============================================================================#
class Game_Map
  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  GAMEVIEWX    = Game_System::GAMEVIEWX
  GAMEVIEWY    = Game_System::GAMEVIEWY
  GAMEWIDTH    = Game_System::GAMEWIDTH
  GAMEHEIGHT   = Game_System::GAMEHEIGHT
  BATVIEWX     = Game_System::BATVIEWX
  BATVIEWY     = Game_System::BATVIEWY
  BATWIDTH     = Game_System::BATWIDTH
  BATHEIGHT    = Game_System::BATHEIGHT
  ANTI_LAGRECT = Game_System::ANTI_LAGRECT

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo001_gmp_initialize :initialize unless $@
  def initialize
    ieo001_gmp_initialize
    load_map_infos unless self.map_infos
    create_map_cache unless self.map_cache
    create_area_cache unless self.area_cache
  end

## Map Cache
if IEO::UPGRADE::USE_MAP_CACHE

  #--------------------------------------------------------------------------#
  # * overwrite-method :setup
  #--------------------------------------------------------------------------#
  def setup(map_id)
    load_map_infos if self.map_infos.nil?
    create_map_cache if self.map_cache.nil?
    create_area_cache if self.area_cache.nil?
    @map_id = map_id
    @map = get_map(@map_id)
    @display_x = 0
    @display_y = 0
    @passages = $data_system.passages
    referesh_vehicles
    setup_events
    setup_scroll
    setup_parallax
    @need_refresh = false
    cache_areas
  end

else

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :ieo001_gmp_setup :setup unless $@
  def setup(map_id)
    create_area_cache if self.area_cache.nil?
    ieo001_gmp_setup(map_id)
    cache_areas
  end

end

  #--------------------------------------------------------------------------#
  # * overwrite-method :setup_events
  #--------------------------------------------------------------------------#
  def setup_events
    setup_gm_events
    setup_cm_events
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup_gm_events
  #--------------------------------------------------------------------------#
  def setup_gm_events
    @events = {}          # Map event
    for i in @map.events.keys
      @events[i] = Game_Event.new(@map_id, @map.events[i])
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup_cm_events
  #--------------------------------------------------------------------------#
  def setup_cm_events
    @common_events = {}   # Common event
    for i in 1...$data_common_events.size
      ($common_event_cache ||= []) << i if $data_common_events[i].trigger > 0
    end if $common_event_cache.nil?
    $common_event_cache ||= []
    $common_event_cache.each { |i| @common_events[i] = Game_CommonEvent.new(i) }
  end

  #--------------------------------------------------------------------------#
  # * new-method :cache_areas
  #--------------------------------------------------------------------------#
  def cache_areas(map_id = @map_id)
    if self.area_cache[map_id].nil?
      self.area_cache[map_id] = []
      for i in 0..$data_areas.size
        next if $data_areas[i].nil?
        next unless $data_areas[i].map_id == map_id
        self.area_cache[map_id] << i
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :map_name
  #--------------------------------------------------------------------------#
  def map_name(map_id=@map_id)
    load_map_infos if self.map_infos.nil?
    return self.map_infos[map_id].name
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_area_cache
  #--------------------------------------------------------------------------#
  def create_area_cache
    IEO::UPGRADE::KEEP_AREA_CACHE ? @area_cache = {} : $area_cache = {}
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_map_cache
  #--------------------------------------------------------------------------#
  def create_map_cache
    IEO::UPGRADE::KEEP_MAP_CACHE ? @map_cache = {} : $map_cache = {}
  end

  #--------------------------------------------------------------------------#
  # * new-method :load_map_infos
  #--------------------------------------------------------------------------#
  def load_map_infos
    dat = load_data('Data/MapInfos.rvdata')
    IEO::UPGRADE::KEEP_MAPINFO_CACHE ? @map_infos = dat : $map_infos = dat
  end

  #--------------------------------------------------------------------------#
  # * new-method :area_cache/=
  #--------------------------------------------------------------------------#
  def area_cache
    return IEO::UPGRADE::KEEP_AREA_CACHE ? @area_cache : $area_cache
  end

  #--------------------------------------------------------------------------#
  # * new-method :map_cache/=
  #--------------------------------------------------------------------------#
  def map_cache
    return IEO::UPGRADE::KEEP_MAP_CACHE ? @map_cache : $map_cache
  end

  #--------------------------------------------------------------------------#
  # * new-method :map_infos/=
  #--------------------------------------------------------------------------#
  def map_infos
    return IEO::UPGRADE::KEEP_MAPINFO_CACHE ? @map_infos : $map_infos
  end

  #--------------------------------------------------------------------------#
  # * new-method :get_map
  #--------------------------------------------------------------------------#
  def get_map(map_id)
    create_map_cache if self.map_cache.nil? ; cac = self.map_cache
    if cac[map_id].nil?
      cac[map_id] = load_map(map_id)
      cac[map_id].do_on_load
    end
    return cac[map_id]
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :setup_scroll
  #--------------------------------------------------------------------------#
  def setup_scroll
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
    @margin_x = (width - Integer(GAMEWIDTH / 32)) * 256 / 2       # Screen non-display width /2
    @margin_y = (height - Integer(GAMEHEIGHT / 32)) * 256 / 2     # Screen non-display height /2
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :calc_parallax_x
  #--------------------------------------------------------------------------#
  def calc_parallax_x(bitmap)
    if bitmap == nil
      return 0
    elsif @parallax_loop_x
      return @parallax_x / 16
    elsif loop_horizontal?
      return 0
    else
      w1 = bitmap.width - GAMEWIDTH
      w2 = @map.width * 32 - GAMEWIDTH
      if w1 <= 0 or w2 <= 0
        return 0
      else
        return @parallax_x * w1 / w2 / 8
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :calc_parallax_y
  #--------------------------------------------------------------------------#
  def calc_parallax_y(bitmap)
    if bitmap == nil
      return 0
    elsif @parallax_loop_y
      return @parallax_y / 16
    elsif loop_vertical?
      return 0
    else
      h1 = bitmap.height - GAMEHEIGHT
      h2 = @map.height * 32 - GAMEHEIGHT
      if h1 <= 0 or h2 <= 0
        return 0
      else
        return @parallax_y * h1 / h2 / 8
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :scroll_down
  #--------------------------------------------------------------------------#
  def scroll_down(distance)
    if loop_vertical?
      @display_y += distance
      @display_y %= @map.height * 256
      @parallax_y += distance
    else
      last_y = @display_y
      @display_y = [@display_y + distance, (height - Integer(GAMEHEIGHT / 32)) * 256].min
      @parallax_y += @display_y - last_y
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :scroll_left
  #--------------------------------------------------------------------------#
  def scroll_left(distance)
    if loop_horizontal?
      @display_x += @map.width * 256 - distance
      @display_x %= @map.width * 256
      @parallax_x -= distance
    else
      last_x = @display_x
      @display_x = [@display_x - distance, 0].max
      @parallax_x += @display_x - last_x
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :scroll_right
  #--------------------------------------------------------------------------#
  def scroll_right(distance)
    if loop_horizontal?
      @display_x += distance
      @display_x %= @map.width * 256
      @parallax_x += distance
    else
      last_x = @display_x
      @display_x = [@display_x + distance, (width - Integer(GAMEWIDTH / 32)) * 256].min
      @parallax_x += @display_x - last_x
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :scroll_up
  #--------------------------------------------------------------------------#
  def scroll_up(distance)
    if loop_vertical?
      @display_y += @map.height * 256 - distance
      @display_y %= @map.height * 256
      @parallax_y -= distance
    else
      last_y = @display_y
      @display_y = [@display_y - distance, 0].max
      @parallax_y += @display_y - last_y
    end
  end
end

#==============================================================================#
# ** Game_Character
#==============================================================================#
class Game_Character
  #--------------------------------------------------------------------------#
  # * new-method :screen_rect
  #--------------------------------------------------------------------------#
  def screen_rect
    return Game_Map::ANTI_LAGRECT
  end

  #--------------------------------------------------------------------------#
  # * new-method :on_screen?
  #--------------------------------------------------------------------------#
  def on_screen?
    r = self.screen_rect
    return self.screen_x.between?(r.x, r.width ) && self.screen_y.between?( r.y, r.height)
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :collide_with_characters?
  #--------------------------------------------------------------------------#
  def collide_with_characters?(x, y)
    for event in $game_map.events_xy(x, y)          # Matches event position
      unless event.through                          # Passage OFF?
        #return true if self.is_a?(Game_Event)       # Self is event
        return true if event.priority_type == 1     # Target is normal char
      end
    end
    if @priority_type == 1                          # Self is normal char
      return true if $game_player.pos_nt?(x, y)     # Matches player position
      return true if $game_map.boat.pos_nt?(x, y)   # Matches boat position
      return true if $game_map.ship.pos_nt?(x, y)   # Matches ship position
    end
    return false
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :jump
  #--------------------------------------------------------------------------#
  def jump(x_plus, y_plus)
    if x_plus.abs > y_plus.abs            # Horizontal distance is longer
      x_plus < 0 ? turn_left : turn_right
    elsif y_plus.abs > x_plus.abs         # Vertical distance is longer
      y_plus < 0 ? turn_up : turn_down
    end
    @x += x_plus
    @y += y_plus
    distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
    @jump_peak = 10 + distance - @move_speed
    @jump_count = @jump_peak * 2
    @stop_count = 0
    straighten
  end
end

#==============================================================================#
# ** Game_Player
#==============================================================================#
class Game_Player < Game_Character
  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  CENTER_X = (Game_Map::GAMEWIDTH / 2 - 16) * 8      # Screen center X coordinate * 8
  CENTER_Y = (Game_Map::GAMEHEIGHT / 2 - 16) * 8     # Screen center Y coordinate * 8

  #--------------------------------------------------------------------------#
  # * overwrite-method :center
  #--------------------------------------------------------------------------#
  def center(x, y)
    display_x = x * 256 - CENTER_X                    # Calculate coordinates
    unless $game_map.loop_horizontal?                 # No loop horizontally?
      max_x = ($game_map.width - Integer(Game_Map::GAMEWIDTH / 32)) * 256            # Calculate max value
      display_x = [0, [display_x, max_x].min].max     # Adjust coordinates
    end
    display_y = y * 256 - CENTER_Y                    # Calculate coordinates
    unless $game_map.loop_vertical?                   # No loop vertically?
      max_y = ($game_map.height - Integer(Game_Map::GAMEHEIGHT / 32)) * 256           # Calculate max value
      display_y = [0, [display_y, max_y].min].max     # Adjust coordinates
    end
    $game_map.set_display_pos(display_x, display_y)   # Change map location
  end
end

#==============================================================================#
# ** Game_Interpreter
#==============================================================================#
class Game_Interpreter
  #--------------------------------------------------------------------------
  # * overwrite-method :command_122
  #--------------------------------------------------------------------------
  def command_122
    value = 0
    case @params[3]  # Operand
    when 0  # Constant
      value = @params[4]
    when 1  # Variable
      value = $game_variables[@params[4]]
    when 2  # Random
      value = @params[4] + rand(@params[5] - @params[4] + 1)
    when 3  # Item
      value = $game_party.item_number($data_items[@params[4]])
    when 4 # Actor
      actor = $game_actors[@params[4]]
      if actor != nil
        case @params[5]
        when 0  # Level
          value = actor.level
        when 1  # Experience
          value = actor.exp
        when 2  # HP
          value = actor.hp
        when 3  # MP
          value = actor.mp
        when 4  # Maximum HP
          value = actor.maxhp
        when 5  # Maximum MP
          value = actor.maxmp
        when 6  # Attack
          value = actor.atk
        when 7  # Defense
          value = actor.def
        when 8  # Spirit
          value = actor.spi
        when 9  # Agility
          value = actor.agi
        end
      end
    when 5  # Enemy
      enemy = $game_troop.members[@params[4]]
      if enemy != nil
        case @params[5]
        when 0  # HP
          value = enemy.hp
        when 1  # MP
          value = enemy.mp
        when 2  # Maximum HP
          value = enemy.maxhp
        when 3  # Maximum MP
          value = enemy.maxmp
        when 4  # Attack
          value = enemy.atk
        when 5  # Defense
          value = enemy.def
        when 6  # Spirit
          value = enemy.spi
        when 7  # Agility
          value = enemy.agi
        end
      end
    when 6  # Character
      character = get_character(@params[4])
      if character != nil
        case @params[5]
        when 0  # x-coordinate
          value = character.x
        when 1  # y-coordinate
          value = character.y
        when 2  # direction
          value = character.direction
        when 3  # screen x-coordinate
          value = character.screen_x
        when 4  # screen y-coordinate
          value = character.screen_y
        end
      end
    when 7  # Other
      case @params[4]
      when 0  # map ID
        value = $game_map.map_id
      when 1  # number of party members
        value = $game_party.members.size
      when 2  # gold
        value = $game_party.gold
      when 3  # steps
        value = $game_party.steps
      when 4  # play time
        value = Graphics.frame_count / Graphics.frame_rate
      when 5  # timer
        value = $game_system.timer / Graphics.frame_rate
      when 6  # save count
        value = $game_system.save_count
      end
    end
    for i in @params[0] .. @params[1]   # Batch control
      case @params[2]  # Operation
      when 0  # Set
        $game_variables[i] = value
      when 1  # Add
        $game_variables[i] += value
      when 2  # Sub
        $game_variables[i] -= value
      when 3  # Mul
        $game_variables[i] *= value
      when 4  # Div
        $game_variables[i] /= value if value != 0
      when 5  # Mod
        $game_variables[i] %= value if value != 0
      end
      if $game_variables[i] > 99999999    # Maximum limit check
        $game_variables[i] = 99999999
      end
      if $game_variables[i] < -99999999   # Minimum limit check
        $game_variables[i] = -99999999
      end
    end
    $game_map.need_refresh = true
    return true
  end
end

#==============================================================================#
# ** Sprite_Base
#==============================================================================#
class Sprite_Base < Sprite
  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  RATE = 3 unless $imported['CoreFixesUpgradesMelody']

  #--------------------------------------------------------------------------#
  # * overwrite-method :start_animation
  #--------------------------------------------------------------------------#
  def start_animation(animation, mirror = false)
    dispose_animation
    @animation = animation
    return if @animation.nil?
    @animation_mirror = mirror
    @animation_duration = @animation.frame_max * RATE + 1
    load_animation_bitmap
    @animation_sprites = []
    @cell_count = animation.cell_count
    @cell_count = $game_system.anim_cell_limit if @cell_count.nil?
    if @animation.position != 3 or not @@animations.include?(animation)
      if @use_sprite
        for i in 0...@cell_count
          sprite = ::Sprite.new(viewport)
          sprite.visible = false
          @animation_sprites.push(sprite)
        end
        unless @@animations.include?(animation)
          @@animations.push(animation)
        end
      end
    end
    update_animation_position
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update
  #--------------------------------------------------------------------------#
  def update
    super
    update_animation unless @animation.nil?
    @@animations.clear
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :animation_set_sprites
  #--------------------------------------------------------------------------#
  def animation_set_sprites(frame)
    cell_data = frame.cell_data
    for i in 0...@cell_count
      sprite = @animation_sprites[i]
      next if sprite == nil
      pattern = cell_data[i, 0]
      if pattern == nil or pattern == -1
        sprite.visible = false
        next
      end
      unless @character.nil?
        unless @character.on_screen?
          sprite.visible = false
          next
        end if Game_System::ANIMATIONALG
      end
      if pattern < 100
        sprite.bitmap = @animation_bitmap1
      else
        sprite.bitmap = @animation_bitmap2
      end
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192)
      if @animation_mirror
        sprite.x = @animation_ox - cell_data[i, 1]
        sprite.y = @animation_oy + cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x = @animation_ox + cell_data[i, 1]
        sprite.y = @animation_oy + cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      sprite.z = self.z + 300 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update_animation
  #--------------------------------------------------------------------------#
  def update_animation
    @animation_duration -= 1
    update_animation_position if Game_System::ANIMATIONFIX and @animation_duration > 0
    return unless @animation_duration % RATE == 0
    if @animation_duration > 0
      frame_index = @animation.frame_max
      frame_index -= (@animation_duration+RATE-1)/RATE
      animation_set_sprites(@animation.frames[frame_index])
      @animation.timings_a[frame_index].each { |t| animation_process_timing(t) }
      #for timing in @animation.timings
      #  next unless timing.frame == frame_index
      #  animation_process_timing(timing)
      #end
      return
    end
    dispose_animation
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :animation_process_timing
  #--------------------------------------------------------------------------#
  def animation_process_timing(timing)
    timing.se.play
    case timing.flash_scope
    when 1
      self.flash(timing.flash_color, timing.flash_duration * RATE)
    when 2
      if viewport != nil
        viewport.flash(timing.flash_color, timing.flash_duration * RATE)
      end
    when 3
      self.flash(nil, timing.flash_duration * RATE)
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_animation_position
  #--------------------------------------------------------------------------#
  def update_animation_position
    unless @character.on_screen?
      @animation_ox = -Graphics.width
      @animation_oy = -Graphics.height
      return
    end unless @character.nil?
    if @animation.position == 3
      if self.viewport.nil?
        @animation_ox = Integer(Graphics.width) / 2
        @animation_oy = Integer(Graphics.height) / 2
      else
        @animation_ox = viewport.rect.width / 2
        @animation_oy = viewport.rect.height / 2
      end
    else
      @animation_ox = x - ox + width / 2
      @animation_oy = y - oy + height / 2
      if @animation.position == 0
        @animation_oy -= height / 2
      elsif @animation.position == 2
        @animation_oy += height / 2
      end
    end
  end
end

#==============================================================================#
# ** Sprite_Character
#==============================================================================#
class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------#
  # * overwrite-method :update
  #--------------------------------------------------------------------------#
  def update
    super
    if IEO::UPGRADE::ANTI_LAG
      self.visible = (!@character.transparent) && @character.on_screen?
    else
      self.visible = (!@character.transparent)
    end
    if self.visible
      update_bitmap
      update_src_rect
      self.x &&= @character.screen_x || 0
      self.y &&= @character.screen_y || 0
      self.z &&= @character.screen_z || 0
      self.opacity &&= @character.opacity || 255
      self.blend_type &&= @character.blend_type || 0
      self.bush_depth &&= @character.bush_depth || 0
    end
    update_balloon
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      start_animation(animation)
      @character.animation_id = 0
    end
    if @character.balloon_id != 0
      @balloon_id = @character.balloon_id
      start_balloon
      @character.balloon_id = 0
    end
  end
end

#==============================================================================#
# ** Sprite_Timer
#==============================================================================#
class Sprite_Timer < Sprite
  #--------------------------------------------------------------------------#
  # * overwrite-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(viewport)
    super(viewport)
    self.bitmap = Bitmap.new(88, 48)
    self.bitmap.font.name = 'Arial'
    self.bitmap.font.size = 32
    self.x = Graphics.width - self.bitmap.width
    self.y = 0
    self.z = 200
    update
  end
end

#==============================================================================
# ** Spriteset_Map
#==============================================================================#
class Spriteset_Map
  #--------------------------------------------------------------------------#
  # * overwrite-method :create_pictures
  #--------------------------------------------------------------------------#
  def create_pictures
    @picture_sprites = []
    for i in $game_system.picture_range
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_map.screen.pictures[i]))
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :create_viewports
  #--------------------------------------------------------------------------#
  def create_viewports
    rect = $game_system.gameviewrect
    @viewport1 = Viewport.new(rect)
    @viewport2 = Viewport.new(rect)
    @viewport3 = Viewport.new(rect)
    @viewport2.z = 50
    @viewport3.z = 100
  end
end

#==============================================================================#
# ** Spriteset_Battle
#==============================================================================#
class Spriteset_Battle
  #--------------------------------------------------------------------------#
  # * overwrite-method :create_viewports
  #--------------------------------------------------------------------------#
  def create_viewports
    rect = $game_system.battleviewrect
    @viewport1 = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport2 = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport3 = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport2.z = 50
    @viewport3.z = 100
  end
end

#==============================================================================#
# ** Window_Selectable
#==============================================================================#
class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo001_wds_initialize :initialize unless $@
  def initialize(*args, &block)
    @__target_rect = Rect.new(0, 0, 0, 0)
    @__scrollheight = WLH
    @__current_oy = 0
    ieo001_wds_initialize(*args, &block)
    @__current_oy = @__target_oy = self.oy
  end
=begin
  #--------------------------------------------------------------------------#
  # * overwrite-method : create_contents
  #--------------------------------------------------------------------------#
  def create_contents
    self.contents.dispose
    maxbitmap = 8192
    dw = [width - 32, maxbitmap].min
    dh = [[height - 32, row_max * WLH].max, maxbitmap].min
    bitmap = Bitmap.new(dw, dh)
    self.contents = bitmap
    self.contents.font.color = normal_color
  end
=end
if IEO::UPGRADE::SMOOTH_CURSOR
  #--------------------------------------------------------------------------#
  # * overwrite-method :update_cursor
  #--------------------------------------------------------------------------#
  def update_cursor
    if @index < 0                   # If the cursor position is less than 0
      self.cursor_rect.empty      # Empty cursor
    else                            # If the cursor position is 0 or more
      row = @index / @column_max    # Get current row
      if row < top_row              # If before the currently displayed
        self.top_row = row          # Scroll up
      end
      if row > bottom_row           # If after the currently displayed
        self.bottom_row = row       # Scroll down
      end
      rect = item_rect(@index)      # Get rectangle of selected item
      rect.y -= self.oy             # Match rectangle to scroll position
      @__target_rect = rect         # Set Target Rect
      self.cursor_rect.width = rect.width
      self.cursor_rect.height = rect.height
      if self.active
        movespeed = $game_system.smooth_cursor_time
        xmvamt = self.width / movespeed
        ymvamt = self.height / movespeed
        if self.cursor_rect.x > @__target_rect.x
          self.cursor_rect.x = [ self.cursor_rect.x - xmvamt, @__target_rect.x ].max
        elsif self.cursor_rect.x < @__target_rect.x
          self.cursor_rect.x = [ self.cursor_rect.x + xmvamt, @__target_rect.x ].min
        end
        if self.cursor_rect.y > @__target_rect.y
          self.cursor_rect.y = [ self.cursor_rect.y - ymvamt, @__target_rect.y ].max
        elsif self.cursor_rect.y < @__target_rect.y
          self.cursor_rect.y = [ self.cursor_rect.y + ymvamt, @__target_rect.y ].min
        end
      else
        self.cursor_rect.x = @__target_rect.x
        self.cursor_rect.y = @__target_rect.y
      end
    end
  end
end ## Smooth Cursor

if IEO::UPGRADE::FULL_WRAP
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if cursor_movable?
      last_index = @index
      if Input.repeat?(Input::DOWN)
        cursor_down(true)
      end
      if Input.repeat?(Input::UP)
        cursor_up(true)
      end
      if Input.repeat?(Input::RIGHT)
        cursor_right(true)
      end
      if Input.repeat?(Input::LEFT)
        cursor_left(true)
      end
      if Input.repeat?(Input::R)
        cursor_pagedown
      end
      if Input.repeat?(Input::L)
        cursor_pageup
      end
      if @index != last_index
        Sound.play_cursor
      end
    end
    update_cursor
    call_update_help
  end
end ## Full Wrap Cursor

if IEO::UPGRADE::SMOOTH_PAGE

  def top_row=(row)
    row = 0 if row < 0
    row = row_max - 1 if row > row_max - 1
    if self.active
      @__target_oy = row * @__scrollheight
    else
      self.oy = @__current_oy = @__target_oy = row * @__scrollheight
    end
  end

  alias :ieo001_wds_update :update unless $@
  def update(*args, &block)
    ieo001_wds_update(*args, &block)
    if @__current_oy > @__target_oy
      mvrate = self.height / IEO::UPGRADE::PAGE_TIME
      @__current_oy = [ @__current_oy - mvrate, @__target_oy ].max
    elsif @__current_oy < @__target_oy
      mvrate = self.height / IEO::UPGRADE::PAGE_TIME
      @__current_oy = [ @__current_oy + mvrate, @__target_oy ].min
    end
    self.oy = @__current_oy.to_i
  end

end

end

#==============================================================================#
# ** Window_Command
#==============================================================================#
class Window_Command < Window_Selectable

if IEO::UPGRADE::ADAPTIVE_CURSOR
  #--------------------------------------------------------------------------#
  # * overwrite-method :item_rect
  #--------------------------------------------------------------------------#
  def item_rect(index, adapt=true)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = (contents.width + @spacing) / @column_max - @spacing
    rect.height = WLH
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = (index / @column_max * WLH)
    rect.width = self.contents.text_size(@commands[index]).width+$game_system.adapt_width_add if adapt
    return rect
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index, enabled = true)
    rect = item_rect(index, false)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(rect, @commands[index])
  end
end ## Adaptive Cursor

end

#==============================================================================#
# ** Window_Help
#==============================================================================#
class Window_Help < Window_Base
  #--------------------------------------------------------------------------#
  # * overwrite-method :initialize
  #--------------------------------------------------------------------------#
  def initialize
    super(0, 0, Graphics.width, WLH + 32)
  end
end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------#
  # * alias-method :load_database
  #--------------------------------------------------------------------------#
  alias :ieo001_sct_load_database :load_database unless $@
  def load_database
    ieo001_sct_load_database
    load_ieo001_cache
  end

  #--------------------------------------------------------------------------#
  # * alias-method :load_bt_database
  #--------------------------------------------------------------------------#
  alias :ieo001_sct_load_bt_database :load_database unless $@
  def load_bt_database
    ieo001_sct_load_bt_database
    load_ieo001_cache
  end

  #--------------------------------------------------------------------------#
  # * new-method :load_ieo001_cache
  #--------------------------------------------------------------------------#
  def load_ieo001_cache
    objs = [$data_animations]
    objs.each do |group|
      group.compact.each do |obj|
        obj.ieo001_animationcache if obj.is_a?(RPG::Animation)
      end
    end
  end
end
#==============================================================================#
IEO::REGISTER.log_script(1, 'BugFixesUpgrades', 2.5) if $imported['IEO-Register']
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
