#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Kappa-FramePat
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon/Change (Change)
# ** Script Type   : Character Modify
# ** Date Created  : 03/29/2011
# ** Date Modified : 05/08/2011
# ** Script Tag    : IEO-034(Kappa-FramePat)
# ** Difficulty    : Easy, Medium, Hard
# ** Version       : 1.0
# ** IEO ID        : 023
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
#
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
# Breaks some character, and sprite methods.
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
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  03/25/2011 - V1.0  Started Script
#  04/08/2011 - V1.0  Finished Script
#  05/08/2011 - V1.1  Fixed the Scripted Move Route
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  Breaks stuff, lots of stuff with the menu and scene ties.
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
$imported['IEO-Kappa-FramePat'] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, 'ScriptName']]
$ieo_script = {} if $ieo_script == nil
$ieo_script[[23, 'Kappa-FramePat']] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# ** IEO::KAPPA
#==============================================================================#
module IEO
  module KAPPA

    PRESET_MOVEROUTES = {
      :door_sequence1 => [:direction_fix_off,
                         :turn_down, "wait: 3", :turn_left, "wait: 3",
                         :turn_right,"wait: 3", :turn_down, "wait: 3",
                         :direction_fix_on],
      :door_sequence2 => [:direction_fix_off,
                         :turn_left, "wait: 3", :turn_right,"wait: 3",
                         :direction_fix_on],
      :turn4          => [:turn_down, "wait: 3", :turn_left, "wait: 3",
                         :turn_right,"wait: 3", :turn_down, "wait: 3"],
    }

    module_function

    def convert_to_moveroute(list)
      mvr = RPG::MoveRoute.new
      list.each { |com|
        param = []
        code  = 0
        case com
        when :wait_for_completion    ; mvr.wait = true
        when :skippable              ; mvr.skippable = true
        when :repeat                 ; mvr.repeat = true
        when 1,  :move_down          ; code = 1    # Move Down
        when 2,  :move_left          ; code = 2    # Move Left
        when 3,  :move_right         ; code = 3    # Move Right
        when 4,  :move_up            ; code = 4    # Move Up
        when 5,  :move_lower_left    ; code = 5    # Move Lower Left
        when 6,  :move_lower_right   ; code = 6    # Move Lower Right
        when 7,  :move_upper_left    ; code = 7    # Move Upper Left
        when 8,  :move_upper_right   ; code = 8    # Move Upper Right
        when 9,  :move_random        ; code = 9    # Move at Random
        when 10, :move_toward_player ; code = 10   # Move toward Player
        when 11, :move_away_from_player; code = 11 # Move away from Player
        when 12, :move_forward       ; code = 12   # 1 Step Forward
        when 13, :move_move_backward ; code = 13   # 1 Step Backwards
        when /JUMP:[ ](\d+)[ ]*,[ ]*(\d+)/i  #14   # Jump
          code = 14 ; param = [$1.to_i, $2.to_i]
        when /WAIT:[ ](\d+)/i                #15   # Wait
          code = 15 ; param = [$1.to_i]
        when 16, :turn_down          ; code = 16   # Turn Down
        when 17, :turn_left          ; code = 17   # Turn Left
        when 18, :turn_right         ; code = 18   # Turn Right
        when 19, :turn_up            ; code = 19   # Turn Up
        when 20, :turn_right_90      ; code = 20   # Turn 90° Right
        when 21, :turn_left_90       ; code = 21   # Turn 90° Left
        when 22, :turn_180           ; code = 22   # Turn 180°
        when 23, :turn_right_or_left_90; code = 23 # Turn 90° Right or Left
        when 24, :turn_random        ; code = 24   # Turn at Random
        when 25, :turn_toward_player ; code = 25   # Turn toward Player
        when 26, :turn_away_from_player; code = 26 # Turn away from Player
        when /SWITCH_ON:[ ](\d+)/i           #27   # Switch ON
          code = 27 ; param = [$1.to_i]
        when /SWITCH_OFF:[ ](\d+)/i          #28   # Switch OFF
          code = 28 ; param = [$1.to_i]
        when /CHANGE_SPEED:[ ](\d+)/i        #29   # Change Speed
          code = 29 ; param = [$1.to_i]
        when /MOVE_FREQUENCY:[ ](\d+)/i      #30   # Change Frequency
          code = 30 ; param = [$1.to_i]
        when 31, :walk_anime_on      ; code = 31   # Walking Animation ON
        when 32, :walk_anime_off     ; code = 32   # Walking Animation OFF
        when 33, :step_anime_on      ; code = 33   # Stepping Animation ON
        when 34, :step_anime_off     ; code = 34   # Stepping Animation OFF
        when 35, :direction_fix_on   ; code = 35   # Direction Fix ON
        when 36, :direction_fix_off  ; code = 36   # Direction Fix OFF
        when 37, :through_on         ; code = 37   # Through ON
        when 38, :through_off        ; code = 38   # Through OFF
        when 39, :transparent_on     ; code = 39   # Transparent ON
        when 40, :transparent_off    ; code = 40   # Transparent OFF
        when /CHANGE_GRAPHIC:[ ](.*),[ ]*(\d+)/i#41# Change Graphic
          code = 41 ; param = [$1, $2.to_i]
        when /CHANGE_OPACITY:[ ](\d+)/i      #42   # Change Opacity
          code = 42 ; param = [$1.to_i]
        when /CHANGE_BLENDING:[ ](\d+)/i     #43   # Change Blending
          code = 43 ; param = [$1.to_i]
        when RPG::SE                         #44   # Play SE
          code = 44 ; param = [com]
        when /SCRIPT:[ ](.*)/i               #45   # Script
          code = 45 ; param = [$1]
        end
        mvr.list.push(RPG::MoveCommand.new(code, param))
      } # // End list.each
      return mvr
    end

  end
end

#==============================================================================#
# ** IEO::REGEX::KAPPA
#==============================================================================#
module IEO
  module REGEXP
    module KAPPA
      module EVENT
        PAT_RATE   = /<(?:PATTERN_RATE|PATTERN RATE|PATTERNRATE):[ ]*(\d+)>/i
        ORIG_PAT   = /<(?:DEFAULT_FRAME|DEFAULT FRAME|DEFAULTFRAME):[ ]*(\d+)>/i
        ICON_INDEX = /<(?:ICON_INDEX|ICON INDEX|ICONINDEX):[ ]*(.*)>/i
        PATTERN    = /<PATTERN:[ ]*(.*)>/i
        ZOOM       = /<ZOOM[ ](.*):[ ]*(.*)>/i
      end
      module GENERAL
        FRAMES     = /\#\[(\d+)\]/i
      end
    end
  end
end

#==============================================================================#
# ** Game_Character
#==============================================================================#
class Game_Character

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :cwidth_div
  attr_accessor :cheight_div
  attr_accessor :icon_index
  # // ------------------------------------------------------ // #
  attr_accessor :zoom_x
  attr_accessor :zoom_y

  attr_accessor :spr_xo
  attr_accessor :spr_yo
  attr_accessor :spr_zo

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo023_gc_initialize :initialize unless $@
  def initialize(*args, &block)
    @defpattern = [0, 1, 2, 1]
    @patternbld = :bf # :bf (Back-Forth), :ln(Linear), :cus(Custom)
    @patpos     = 0   # The internal pattern counter
    @cwidth_div = 3
    @cheight_div= 4
    @icon_index = 0
    @patternrate= 2   # Default pattern rate is 2
    # // ------------------------------------------------------ // #
    @zoom_x = 1.00
    @zoom_y = 1.00
    # // ------------------------------------------------------ // #
    @spr_xo = 0
    @spr_yo = 0
    @spr_zo = 0
    # // ------------------------------------------------------ // #
    ieo023_gc_initialize(*args, &block)
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update_animation
  #--------------------------------------------------------------------------#
  def update_animation()
    speed = @move_speed + (dash? ? 1 : 0)
    if @anime_count > 18 - speed * @patternrate
      if not @step_anime and @stop_count > 0
        @pattern = @original_pattern
      else
        @patpos = (@patpos + 1) % @defpattern.size
        @pattern = @defpattern[@patpos]
      end
      @anime_count = 0
    end
  end

  #--------------------------------------------------------------------------#
  # * alias method :set_graphic
  #--------------------------------------------------------------------------#
  alias :ieo023_gc_set_graphic :set_graphic unless $@
  def set_graphic(character_name, character_index)
    ieo023_gc_set_graphic(character_name, character_index)
    setup_defpattern()
  end

  #--------------------------------------------------------------------------#
  # * new method :setup_defpattern
  #--------------------------------------------------------------------------#
  def setup_defpattern()
    framecount = 3
    # // ------------------------------------------------------------------ // #
    @character_name.scan(IEO::REGEXP::KAPPA::GENERAL::FRAMES).each { |fr| framecount = fr.to_s.to_i}
    @cwidth_div = framecount
    # // ------------------------------------------------------------------ // #
    case @patternbld
    when :bf # // Back-Forth
      @defpattern = []
      framecount.times { |i| @defpattern << i unless i == framecount }
      af = @defpattern.clone(); af.reverse!(); af.pop(); af.shift(); @defpattern += af
    when :ln # // Linear
      @defpattern = []
      framecount.times { |i| @defpattern << i unless i == framecount}
    end
    # // ------------------------------------------------------------------ // #
  end

  #--------------------------------------------------------------------------#
  # * new method :setup_kappa_moveroute
  #--------------------------------------------------------------------------#
  def setup_kappa_moveroute(setname, from=:event)
    set = IEO::KAPPA::PRESET_MOVEROUTES[setname]
    c0 = @move_route.list.pop()
    mv = IEO::KAPPA.convert_to_moveroute(set).list
    mv << c0
    force_move_route(mv)
  end

  #--------------------------------------------------------------------------#
  # * alias method :screen_x
  #--------------------------------------------------------------------------#
  alias :ieo023_gc_screen_x :screen_x unless $@
  def screen_x()
    return ieo023_gc_screen_x() + @spr_xo
  end

  #--------------------------------------------------------------------------#
  # * alias method :screen_y
  #--------------------------------------------------------------------------#
  alias :ieo023_gc_screen_y :screen_y unless $@
  def screen_y()
    return ieo023_gc_screen_y() + @spr_yo
  end

  #--------------------------------------------------------------------------#
  # * alias method :screen_z
  #--------------------------------------------------------------------------#
  alias :ieo023_gc_screen_z :screen_z unless $@
  def screen_z()
    return ieo023_gc_screen_z() + @spr_zo
  end

end

#==============================================================================#
# ** Game_Event
#==============================================================================#
class Game_Event < Game_Character

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :move_route

  #--------------------------------------------------------------------------#
  # * alias method :setup
  #--------------------------------------------------------------------------#
  alias ieo023_setup setup unless $@
  def setup(new_page)
    ieo023_setup(new_page)
    ieo023_eventcache
  end

  #--------------------------------------------------------------------------#
  # * new method :ieo023_eventcache
  #--------------------------------------------------------------------------#
  def ieo023_eventcache
    return if @list == nil
    for i in 0..@list.size
      next if @list[i] == nil
      if @list[i].code == 108
        @list[i].parameters.to_s.split(/[\r\n]+/).each { |line|
        case line
        when IEO::REGEXP::KAPPA::EVENT::ICON_INDEX
          val = $1
          case val
          when /(?:ITE|I):[ ](\d+)/i
            @icon_index = $data_items[$1.to_i]
          when /(?:WEP|W):[ ](\d+)/i
            @icon_index = $data_weapons[$1.to_i]
          when /(?:ARM|A):[ ](\d+)/i
            @icon_index = $data_armors[$1.to_i]
          when /(?:SKI|S):[ ](\d+)/i
            @icon_index = $data_skills[$1.to_i]
          when /(?:STE|T):[ ](\d+)/i
            @icon_index = $data_states[$1.to_i]
          else
            @icon_index = val.to_i
          end
        when IEO::REGEXP::KAPPA::EVENT::PATTERN
          val = $1
          case val.upcase
          when "LINEAR", "LN"
            @patternbld = :ln
          when "BACKFORTH", "BF"
            @patternbld = :bf
          else
            @patternbld = :cus ; @defpattern = []
            val.scan(/\d+/).each { |n| @defpattern << n.abs }
          end
        when IEO::REGEXP::KAPPA::EVENT::ORIG_PAT
          @original_pattern = $1.to_i
        when IEO::REGEXP::KAPPA::EVENT::PAT_RATE
          @patternrate = $1.to_i
        when IEO::REGEXP::KAPPA::EVENT::ZOOM
          val = $2.to_f * 1.00
          case $1.upcase
          when "X"
            @zoom_x = val
          when "Y"
            @zoom_y = val
          end
        end
        }
      end
    end
    setup_defpattern
  end

end

#==============================================================================#
# Sprite_Character
#==============================================================================#
class Sprite_Character < Sprite_Base

  #--------------------------------------------------------------------------#
  # * new method :iconset_bitmap
  #--------------------------------------------------------------------------#
  def iconset_bitmap(iconindex)
    return Cache.system("Iconset")
  end

  #--------------------------------------------------------------------------#
  # * alias method :update
  #--------------------------------------------------------------------------#
  alias ieo023_update update unless $@
  def update()
    ieo023_update()
    update_zoom()
  end

  #--------------------------------------------------------------------------#
  # * new method :update_zoom
  #--------------------------------------------------------------------------#
  def update_zoom
    unless @character.nil?
      self.zoom_x = @character.zoom_x
      self.zoom_y = @character.zoom_y
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update_src_rect
  #--------------------------------------------------------------------------#
  def update_src_rect
    if @tile_id == 0 && @icon_index == 0
      index = @character.character_index
      pattern = @character.pattern < @character.cwidth_div ? @character.pattern : 1
      sx = (index % 4 * @character.cwidth_div + pattern) * @cw
      sy = (index / 4 * @character.cheight_div + (@character.direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :update_bitmap
  #--------------------------------------------------------------------------#
  def update_bitmap
    if (@tile_id != @character.tile_id ||
        @icon_index != @character.icon_index ||
        @character_name  != @character.character_name ||
        @character_index != @character.character_index)
      # //
      @character.setup_defpattern
      @tile_id         = @character.tile_id
      @icon_index      = @character.icon_index
      @character_name  = @character.character_name
      @character_index = @character.character_index
      if @tile_id > 0
        sx = (@tile_id / 128 % 2 * 8 + @tile_id % 8) * 32;
        sy = @tile_id % 256 / 8 % 16 * 32;
        self.bitmap = tileset_bitmap(@tile_id)
        self.src_rect.set(sx, sy, 32, 32)
        self.ox = 16
        self.oy = 32
      elsif @icon_index > 0
        irect = Rect.new(@icon_index % 16 * 24, @icon_index / 16 * 24, 24, 24)
        self.bitmap = iconset_bitmap(@icon_index)
        self.src_rect.set(irect.x, irect.y, irect.width, irect.height)
        self.ox = irect.width / 2
        self.oy = irect.height + (32 - irect.height) / 2
      else
        self.bitmap = Cache.character(@character_name)
        sign = @character_name[/^[\!\$]./]
        if sign != nil and sign.include?('$')
          @cw = bitmap.width / @character.cwidth_div
          @ch = bitmap.height / @character.cheight_div
        else
          @cw = bitmap.width / (@character.cwidth_div*4)
          @ch = bitmap.height / (@character.cheight_div*2)
        end
        self.ox = @cw / 2
        self.oy = @ch
      end
    end
  end

end
#==============================================================================#
IEO::REGISTER.log_script(23, "Kappa-FramePat", 1.0) if $imported["IEO-Register"]
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
