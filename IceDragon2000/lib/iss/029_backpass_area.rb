#encoding:UTF-8
# ISS029 - Backpass Area
#==============================================================================#
# ** ISS - Backpass Area
#==============================================================================#
# ** Date Created  : 08/04/2011
# ** Date Modified : 11/12/2011
# ** Created By    : IceDragon
# ** For Game      : S.A.R.A
# ** ID            : 029
# ** Version       : 1.0
# ** Requires      : ISS000 - Core(2.1 or above)
#==============================================================================#
($imported ||= {})["ISS_BackpassArea"] = true
#==============================================================================#
# ** ISS
#==============================================================================#
module ISS
  install_script(29, :passage);
end
#==============================================================================#
# ** RPG::Area
#==============================================================================#
class RPG::Area

  #--------------------------------------------------------------------------#
  # * new-method :back_pass_area?
  #--------------------------------------------------------------------------#
  def back_pass_area?()
    @back_pass ||= @name =~ /<BACKPASS>/i ? true : false
    return @back_pass
  end

  #--------------------------------------------------------------------------#
  # * new-method :nofade?
  #--------------------------------------------------------------------------#
  def nofade?()
    @nofade ||= @name =~ /<NOFADE>/i ? true : false
    return @nofade
  end

  #--------------------------------------------------------------------------#
  # * new-method :valid_area?
  #--------------------------------------------------------------------------#
  def valid_area?(x, y)
    return (x.between?(@rect.x, @rect.x+@rect.width-1) &&
     y.between?(@rect.y, @rect.y+@rect.height-1))
  end

end
#==============================================================================#
$backpass_tables = {}
$nofade_tables = {}
#==============================================================================#
# ** Game_Map
#==============================================================================#
class Game_Map

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :iss029_gmmp_setup :setup unless $@
  def setup(*args, &block)
    iss029_gmmp_setup(*args, &block)
    create_back_passes()
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_back_passes
  #--------------------------------------------------------------------------#
  def create_back_passes()
    if $nofade_tables[@map_id].nil?() || $backpass_tables[@map_id].nil?()
      back_passes   = Table.new(@map.data.xsize, @map.data.ysize, 1)
      nofade_passes = Table.new(@map.data.xsize, @map.data.ysize, 2)
      for y in 0...self.height
        for x in 0...self.width
          nofade_passes[x, y, 0] = 0
          for aid in self.area_cache[@map_id]
            ar = $data_areas[aid]
            next unless ar.back_pass_area?()
            if ar.valid_area?(x, y)
              back_passes[x, y, 0] = 1
              nofade_passes[x, y, 0] = 1 if ar.nofade?()
              nofade_passes[x, y, 1] = ar.id
            end
          end
        end
      end
      $backpass_tables[@map_id] = back_passes
      $nofade_tables[@map_id]   = nofade_passes
    end
    @back_passes   = $backpass_tables[@map_id]
    @nofade_passes = $nofade_tables[@map_id]
  end

  #--------------------------------------------------------------------------#
  # * new-method :nofade_area?
  #--------------------------------------------------------------------------#
  def nofade_area?(x, y)
    return @nofade_passes[x, y, 0] == 1
  end

  #--------------------------------------------------------------------------#
  # * alias-method :passable?
  #--------------------------------------------------------------------------#
  alias :iss029_gmmp_passable? :passable? unless $@
  def passable?(x, y, flag = 0x01)
    return true if back_passable?(x, y)
    iss029_gmmp_passable?(x, y, flag)
  end

  #--------------------------------------------------------------------------#
  # * new-method :back_passable?
  #--------------------------------------------------------------------------#
  def back_passable?(x, y)
    create_back_passes() if @back_passes.nil?()
    return @back_passes[x, y, 0] == 1
  end

end

#==============================================================================#
# ** Game_Character
#==============================================================================#
class Game_Character

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_reader :old_opacity, :_backpassing
  attr_accessor :nofade_backpass

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :iss029_gmc_initialize :initialize unless $@
  def initialize(*args, &block)
    iss029_gmc_initialize(*args, &block)
    @old_opacity     = nil
    @nofade_backpass = false
    @_backpassing    = false
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :iss029_gmc_update :update unless $@
  def update(*args, &block)
    iss029_gmc_update(*args, &block)
    update_backpass()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update_backpass
  #--------------------------------------------------------------------------#
  def update_backpass()
    @_backpassing = $game_map.back_passable?(self.x, self.y)
    #!$game_map.nofade_area?(@x, @y)
    if @_backpassing
      @old_opacity ||= @opacity
      @opacity = [[@opacity - 255/60.0, 128].max, 255].min
    else
      unless @old_opacity.nil?()
        @opacity = [[@opacity + 255/60.0, 0].max, @old_opacity].min
        @old_opacity = nil if @opacity == @old_opacity
      end
    end unless @nofade_backpass
  end

  #--------------------------------------------------------------------------#
  # * alias-method :screen_z
  #--------------------------------------------------------------------------#
  alias :iss029_gmc_screen_z :screen_z unless $@
  def screen_z(*args, &block)
    if @_backpassing
      return 0
    else
      return iss029_gmc_screen_z(*args, &block)
    end
  end

end

#==============================================================================#
# ** Game_Event
#==============================================================================#
class Game_Event < Game_Character

  #--------------------------------------------------------------------------#
  # * ISS Event Cache Setup
  #--------------------------------------------------------------------------#
  iss_cachedummies :event, 29

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :iss029_ge_setup :setup unless $@
  def setup(*args, &block)
    iss029_ge_setup(*args, &block)
    iss029_eventcache()
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss029_eventcache_start
  #--------------------------------------------------------------------------#
  def iss029_eventcache_start()
    @nofade_backpass = nil
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss029_eventcache_check
  #--------------------------------------------------------------------------#
  def iss029_eventcache_check(comment)
    @nofade_backpass ||= (comment =~ /<NOFADE_BACKPASS>/i).eql?(0)
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss029_eventcache_start
  #--------------------------------------------------------------------------#
  def iss029_eventcache_end()
    @nofade_backpass ||= false
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
