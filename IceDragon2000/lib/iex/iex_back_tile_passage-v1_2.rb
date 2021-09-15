#==============================================================================#
# ** IEX(Icy Engine Xelion) - Backtile Passage
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Area, Maps)
# ** Script Type   : Passage Edit
# ** Date Created  : ??/??/2010 (DD/MM/YYYY)
# ** Date Modified : 01/08/2011 (DD/MM/YYYY)
# ** Script Tag    : IEX - Backtile Passable
# ** Difficulty    : Easy
# ** Version       : 1.1a
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# Based off MoonMan's Wall Tile Extension script.
# This script acts to replicate the Back tile passage feature, with an added
# bonus.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# V1.0 - Tags - Areas - Place in area's name
#------------------------------------------------------------------------------#
# <BACKPASS> (or) <Back_Pass> (or) <back pass>
# All are case insensitive.
# This will treat, the area as a Backpass,
# A backpass is a x,y position which is always passable, but the character is
# dimmed to give an idea of going behind the object.
#
#------------------------------------------------------------------------------#
# V1.0 - Comments - Events
# V1.1 - Tags - Area - Name
#------------------------------------------------------------------------------#
# <NOFADE BACKPASS>
# The event will not dim when in a backpass.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# Do not use with Wall Tile Extension (By Moonman) with this script
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
#
# Below
#  Materials
#
# Above
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#------------------------------------------------------------------------------#
# Classes
#   RPG::Area
#     new-method :iex_back_pass_area?
#     new-method :iex_nofade?
#     new-method :iex_valid_area?
#   Game_Map
#     alias      :initialize
#     alias      :setup
#     alias      :passable?
#     new-method :iex_create_passes
#     new-method :nofade_area?
#     new-method :iex_back_passable?
#   Game_Character
#     alias      :initialize
#     alias      :update
#   Game_Event
#     alias      :setup
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  ??/??/2010 - V1.0  Finished Script
#  01/01/2011 - V1.0  Finished Docing
#  01/08/2011 - V1.1  Added <nofade backpass> to area's
#  01/08/2011 - V1.1a Small Changes
#  07/17/2011 - V1.2  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment.
#
#------------------------------------------------------------------------------#
$imported ||= {}
$imported["IEX_BackTilePassage"] = true
#==============================================================================#
# ** IEX::BACK_PASS
#==============================================================================#
module IEX
  module BACK_PASS
#==============================================================================#
#                           Start Customization
#------------------------------------------------------------------------------#
#==============================================================================#
    # Set this to nil if you don't wish to use it
    BACK_PASS_TILE_ID = 890
    DIMING_OPACITY = 128
    AREA_MODE_ON = true
#==============================================================================#
#                           End Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  end
end

#==============================================================================#
# ** IEX::REGEXP::BACK_PASS
#------------------------------------------------------------------------------#
#==============================================================================#
module IEX
  module REGEXP
    module BACK_PASS
      BACKPASS = /<(?:BACK_PASS|back pass|backpass)>/i
      NOFADE   = /<(?:NO_FADE_BACK_PASS|no fade back pass|nofadebackpass|nofade backpass)>/i
    end
  end
end

#==============================================================================#
# ** RPG::Area
#==============================================================================#
class RPG::Area

  #--------------------------------------------------------------------------#
  # * new-method :iex_back_pass_area?
  #--------------------------------------------------------------------------#
  def iex_back_pass_area?()
    @back_pass ||= @name =~ IEX::REGEXP::BACK_PASS::BACKPASS ? true : false
    return @back_pass
  end

  #--------------------------------------------------------------------------#
  # * new-method :iex_nofade?
  #--------------------------------------------------------------------------#
  def iex_nofade?()
    @nofade ||= @name =~ IEX::REGEXP::BACK_PASS::NOFADE ? true : false
    return @nofade
  end

  #--------------------------------------------------------------------------#
  # * new-method :iex_valid_area?
  #--------------------------------------------------------------------------#
  def iex_valid_area?( x_x, y_y )
    stack_ans = []
    bool_x = (x_x >= @rect.x and x_x < @rect.x + @rect.width)
      stack_ans.push(bool_x)
    bool_y = (y_y >= @rect.y and y_y < @rect.y + @rect.height)
      stack_ans.push(bool_y)
    return stack_ans
  end

end

$iex_backpass_tables = {}
$iex_nofade_tables = {}
#==============================================================================#
# ** Game_Map
#==============================================================================#
class Game_Map

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  #alias :iex_back_pass_initialize :initialize unless $@
  #def initialize( *args, &block )
  #  iex_back_pass_initialize( *args, &block )
  #  # // Um Errr?
  #end

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :iex_back_pass_setup :setup unless $@
  def setup( *args, &block )
    iex_back_pass_setup( *args, &block )
    iex_create_passes
  end

  #--------------------------------------------------------------------------#
  # * new-method :iex_create_passes
  #--------------------------------------------------------------------------#
  def iex_create_passes()
    if $iex_nofade_tables[@map_id].nil?() || $iex_backpass_tables[@map_id].nil?()
      iex_back_passes   = Table.new(@map.data.xsize, @map.data.ysize, 3)
      iex_nofade_passes = Table.new(@map.data.xsize, @map.data.ysize, 2)
      for y in 0...self.height
        for x in 0...self.width
          if @map.data[x, y, 2] == IEX::BACK_PASS::BACK_PASS_TILE_ID
            iex_back_passes[x, y, 2] = IEX::BACK_PASS::BACK_PASS_TILE_ID
            @map.data[x, y, 2] = 0
          end unless IEX::BACK_PASS::BACK_PASS_TILE_ID.nil?
          iex_nofade_passes[x, y, 0] = 0
          for ar in $data_areas.values.compact
            next if ar.map_id != @map_id
            next unless ar.iex_back_pass_area?
            set_ans = ar.iex_valid_area?(x, y)
            if set_ans.all?
              iex_back_passes[x, y, 2] = IEX::BACK_PASS::BACK_PASS_TILE_ID
              iex_nofade_passes[x, y, 0] = 1 if ar.iex_nofade?()
              iex_nofade_passes[x, y, 1] = ar.id
            end
          end if IEX::BACK_PASS::AREA_MODE_ON
        end
      end
      $iex_backpass_tables[@map_id] = iex_back_passes
      $iex_nofade_tables[@map_id]   = iex_nofade_passes
    end
    @iex_back_passes   = $iex_backpass_tables[@map_id]
    @iex_nofade_passes = $iex_nofade_tables[@map_id]
  end

  #--------------------------------------------------------------------------#
  # * new-method :nofade_area?
  #--------------------------------------------------------------------------#
  def nofade_area?( x, y )
    return @iex_nofade_passes[x, y, 0] == 1
  end

  #--------------------------------------------------------------------------#
  # * alias-method :passable?
  #--------------------------------------------------------------------------#
  alias :iex_back_pass_passable :passable? unless $@
  def passable?( x, y, flag = 0x01 )
    return true if iex_back_passable?( x, y )
    iex_back_pass_passable( x, y, flag )
  end

  #--------------------------------------------------------------------------#
  # * new-method :iex_back_passable?
  #--------------------------------------------------------------------------#
  def iex_back_passable?( x, y )
    iex_create_passes if @iex_back_passes.nil?()
    return true if @iex_back_passes[x, y, 2] == IEX::BACK_PASS::BACK_PASS_TILE_ID
    return false
  end

end

#==============================================================================#
# ** Game_Character
#==============================================================================#
class Game_Character

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :iex_back_pass_gc_initialize :initialize unless $@
  def initialize( *args, &block )
    iex_back_pass_gc_initialize( *args, &block )
    @old_opacity = nil
    @iex_can_fade = true
    @_backpassing = false
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :iex_back_pass_gc_update :update unless $@
  def update( *args, &block )
    iex_back_pass_gc_update( *args, &block )
    @_backpassing = ( $game_map.iex_back_passable?(@x, @y) &&
     @iex_can_fade && !$game_map.nofade_area?( @x, @y ) )
    if @_backpassing
      @old_opacity = @opacity if @old_opacity == nil
      @opacity = IEX::BACK_PASS::DIMING_OPACITY
    else
      @opacity = @old_opacity unless @old_opacity.nil?()
      @old_opacity = nil
    end
  end

  #--------------------------------------------------------------------------#
  # * alias-method :screen_z
  #--------------------------------------------------------------------------#
  alias :iex_back_pass_gc_screen_z :screen_z unless $@
  def screen_z( *args, &block )
    if @_backpassing
      return 0
    else
      return iex_back_pass_gc_screen_z( *args, &block )
    end
  end

end

#==============================================================================#
# ** Game_Event
#==============================================================================#
class Game_Event < Game_Character

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :iex_back_pass_ge_setup :setup unless $@
  def setup( *args, &block )
    iex_back_pass_ge_setup( *args, &block )
    return if @list.nil?()
    for i in 0...@list.size
      if @list[i].code == 108
        @list[i].parameters.to_s.split(/[\r\n]+/).each { |line|
          case line
          when IEX::REGEXP::BACK_PASS::NOFADE
            @iex_can_fade = false
          end
        }
      end
    end

  end

end

#==============================================================================#
# ** END OF FILE
#==============================================================================#
