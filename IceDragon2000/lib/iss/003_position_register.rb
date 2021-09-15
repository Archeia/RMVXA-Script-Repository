#encoding:UTF-8
# ISS003 - PositionRegister 1.7
#==============================================================================#
# ** ISS - Position Register
#==============================================================================#
# ** Date Created  : 04/28/2011
# ** Date Modified : 08/29/2011
# ** Created By    : IceDragon
# ** For Game      : S.A.R.A
# ** ID            : 003
# ** Version       : 1.6
# ** Requires      : ISS000 - Core 1.1 (or above)
#==============================================================================#
($imported ||= {})["ISS-PositionRegister"] = true
#==============================================================================#
# ** ISS
#==============================================================================#
module ISS
  install_script(3, :event)
#==============================================================================#
# ** ScreenStruct
#==============================================================================#
  class ScreenStruct

    #--------------------------------------------------------------------------#
    # * Public Instance Variables
    #--------------------------------------------------------------------------#
    attr_accessor :screen_x
    attr_accessor :screen_y
    attr_accessor :screen_z
    attr_accessor :real_x
    attr_accessor :real_y
    attr_accessor :display_x
    attr_accessor :display_y

    #--------------------------------------------------------------------------#
    # * method :initialize
    #--------------------------------------------------------------------------#
    def initialize(scx, scy, scz)
      @screen_x, @screen_y, @screen_z = scx, scy, scz
      @last_real_x, @last_real_y = 0, 0
      @last_display_x, last_display_y = 0, 0
    end

    #--------------------------------------------------------------------------#
    # * new-method :clear
    #--------------------------------------------------------------------------#
    def clear()
      @screen_x, @screen_y, @screen_z = -1, -1, -1
      @last_real_x, @last_real_y = -1, -1
      @last_display_x, last_display_y = -1, -1
    end

  end
#==============================================================================#
# ** PositionRegister
#==============================================================================#
  class PositionRegister

    #--------------------------------------------------------------------------#
    # * Constant(s)
    #--------------------------------------------------------------------------#
    SINGLE_DIMENSION = false

    #--------------------------------------------------------------------------#
    # * Public Instance Variable(s)
    #--------------------------------------------------------------------------#
    attr_accessor :setup_ready

    #--------------------------------------------------------------------------#
    # * method :initialize
    #--------------------------------------------------------------------------#
    def initialize( sizex = 1, sizey = 1, sizez = 1)
      @setup_ready = false
      resize(sizex, sizey, sizez)
    end

    #--------------------------------------------------------------------------#
    # * method :setup
    #--------------------------------------------------------------------------#
    def setup(gm) # // gm is a Game_Map class used for reference
      resize(gm.width+1, gm.height+1, 1)
    end

    #--------------------------------------------------------------------------#
    # * method :out_of_range?
    #--------------------------------------------------------------------------#
    def out_of_range?(pos)
      return !pos.x.between?(0, @xsize ) || !pos.y.between?( 0, @ysize) ||
       !pos.z.between?(0, @zsize)
    end

  if SINGLE_DIMENSION

    #--------------------------------------------------------------------------#
    # * method :resize
    #--------------------------------------------------------------------------#
    def resize(sizex, sizey, sizez)
      x = [sizex, 256 ** 4].min ; y = [sizey, 256 ** 4].min ;
      z = [sizez, 256 ** 4].min
      @data = Array.new(x*y*z).map! { [] }
      @xsize, @ysize, @zsize = x, y, z
    end

    #--------------------------------------------------------------------------#
    # * method :pos_to_index
    #--------------------------------------------------------------------------#
    def pos_to_index(pos)
      x = [pos.x, @xsize].min; y = [pos.y, @ysize].min; z = [pos.z, @zsize].min
      return x + y * @xsize + z * @xsize * @ysize
    end

    #--------------------------------------------------------------------------#
    # * method :get_at
    #--------------------------------------------------------------------------#
    def get_at(pos)
      return [] if out_of_range?(pos)
      return @data[ pos_to_index(pos) ]
    end

    #--------------------------------------------------------------------------#
    # * method :set_at
    #--------------------------------------------------------------------------#
    def set_at(pos, obj)
      return if out_of_range?(pos)
      @data[ pos_to_index(pos) ] |= [obj]
    end

    #--------------------------------------------------------------------------#
    # * method :delete_at
    #--------------------------------------------------------------------------#
    def delete_at(pos, obj)
      return if out_of_range?(pos)
      @data[ pos_to_index(pos) ] -= [obj]
    end

  else

    #--------------------------------------------------------------------------#
    # * method :resize
    #--------------------------------------------------------------------------#
    def resize(sizex, sizey, sizez)
      @data = Array.new(sizex).map! {   # // X
        Array.new(sizey).map! {       # // Y
        Array.new(sizez).map! {       # // Z
        [] } } }              # // Characters
      @xsize, @ysize, @zsize = sizex, sizey, sizez
    end

    #--------------------------------------------------------------------------#
    # * method :get_at
    #--------------------------------------------------------------------------#
    def get_at(pos)
      return [] if out_of_range?(pos)
      return @data[pos.x][pos.y][pos.z]
    end

    #--------------------------------------------------------------------------#
    # * method :set_at
    #--------------------------------------------------------------------------#
    def set_at(pos, obj)
      return if out_of_range?(pos)
      @data[pos.x][pos.y][pos.z] |= [obj]
    end

    #--------------------------------------------------------------------------#
    # * method :delete_at
    #--------------------------------------------------------------------------#
    def delete_at(pos, obj)
      return if out_of_range?(pos)
      @data[pos.x][pos.y][pos.z] -= [obj]
    end

  end # // Multi Dimension

  end

end

#==============================================================================#
# ** Game_Map
#==============================================================================#
class Game_Map

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :posRegister

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :iss003_gm_initialize :initialize unless $@
  def initialize() ; iss003_gm_initialize() ; create_posRegister() ; end

  #--------------------------------------------------------------------------#
  # * new-method :create_posRegister
  #--------------------------------------------------------------------------#
  def create_posRegister()
    @posRegister = ::ISS::PositionRegister.new(1, 1, 1)
  end

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :iss003_gmp_setup :setup unless $@
  def setup(map_id)
    create_posRegister() if self.posRegister.nil?()
    @posRegister.setup_ready = false
    iss003_gmp_setup(map_id)
    setup_iss003_map(0)
    @posRegister.setup_ready = true
    setup_iss003_map(1)
  end

  #--------------------------------------------------------------------------#
  # * new-method :posreg_panic!
  #--------------------------------------------------------------------------#
  def posreg_panic!()
    setup_iss003_map(2)
    @posRegister.setup_ready = false
    setup_iss003_map(0)
    @posRegister.setup_ready = true
    setup_iss003_map(1)
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup_iss003_map
  #--------------------------------------------------------------------------#
  def setup_iss003_map(part)
    case part
    when 0 ; @posRegister.setup(self)
    when 1 ; @events.values.each { |e| e.update_pos(:bypass) }
    when 2 ; @events.values.each { |e| e.update_pos(:clear) }
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :events_xy
  #--------------------------------------------------------------------------#
  def events_xy(x, y)
    return (@posRegister.get_at(::ISS::Pos.new(x, y)) - [$game_player])
  end

end

#==============================================================================#
# ** Game_Character
#==============================================================================#
class Game_Character

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :lastpos
  attr_accessor :multipos
  attr_accessor :mpp_dfx
  attr_accessor :mpp_direc
  attr_accessor :mpp_enabled

  USE_SCREEN_UPGRADE = false

  #--------------------------------------------------------------------------#
  # * Aliases
  #--------------------------------------------------------------------------#
  [:screen_x, :screen_y, :screen_z].each do |m|
    alias_method "iss003_gc_#{m.to_s}".to_sym, m
  end if USE_SCREEN_UPGRADE

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :iss003_gc_initialize :initialize unless $@
  def initialize(*args, &block)
    iss003_gc_initialize(*args, &block)
    @use_posreg = true
    @multipos   = [ ] # // Actual Pos
    @multipos_p = [ ] # // Preset
    @mpp_dfx    = false # // Multi Position Direction FIX?
    @mpp_direc  = 0
    @mpp_enabled= false
    @lastpos    = ::ISS::Pos.new(0, 0, 0)
    @screen_str = ::ISS::ScreenStruct.new(0, 0, 0) if USE_SCREEN_UPGRADE
    if $imported["IEO-BugFixesUpgrades"]
      @screenrect = Game_Map::ANTI_LAGRECT
    else
      @screenrect = Rect.new(-32, -32, Graphics.width+32, Graphics.height+32)
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :enable_posreg
  #--------------------------------------------------------------------------#
  def enable_posreg() ; @use_posreg = true ; update_pos(:bypass) ; end

  #--------------------------------------------------------------------------#
  # * new-method :disable_posreg
  #--------------------------------------------------------------------------#
  def disable_posreg() ; update_pos(:clear) ; @use_posreg = false ; end

  #--------------------------------------------------------------------------#
  # * new-method :setup_multipos
  #--------------------------------------------------------------------------#
  def setup_multipos(cover, direction_fix=false)
    return 1 unless @use_posreg
    clear_multipos()
    @multipos_p += cover ; @mpp_dfx = direction_fix
    @mpp_enabled = true
    cover.size.times { |i| @multipos << ::ISS::Pos.new(self.x, self.y, 0) }
    update_pos(:bypass) ; return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :clear_multipos
  #--------------------------------------------------------------------------#
  def clear_multipos()
    @mpp_enabled = false
    update_pos(:clear ) ; @multipos.clear() ; @multipos_p.clear() ; update_pos( :bypass)
  end

  #--------------------------------------------------------------------------#
  # * new-method :screen_reset
  #--------------------------------------------------------------------------#
  def screen_reset()
    @screen_str.clear() if USE_SCREEN_UPGRADE
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :screen_x
  #--------------------------------------------------------------------------#
  def screen_x()
    if @screen_str.real_x != @real_x || @screen_str.display_x != $game_map.display_x
      @screen_str.real_x = @real_x ; @screen_str.display_x = $game_map.display_x
      @screen_str.screen_x = iss003_gc_screen_x()
    end
    return @screen_str.screen_x
  end if USE_SCREEN_UPGRADE

  #--------------------------------------------------------------------------#
  # * overwrite-method :screen_y
  #--------------------------------------------------------------------------#
  def screen_y()
    if @screen_str.real_y != @real_y || @screen_str.display_y != $game_map.display_y
      @screen_str.real_y = @real_y ; @screen_str.display_y = $game_map.display_y
      @screen_str.screen_y = iss003_gc_screen_y()
    end
    return @screen_str.screen_y
  end if USE_SCREEN_UPGRADE

  #--------------------------------------------------------------------------#
  # * overwrite-method :screen_z
  #--------------------------------------------------------------------------#
  def screen_z()
    @screen_str.screen_z = iss003_gc_screen_z()
    return @screen_str.screen_z
  end if USE_SCREEN_UPGRADE

  #--------------------------------------------------------------------------#
  # * alias-method :moveto
  #--------------------------------------------------------------------------#
  alias :iss003_gc_moveto :moveto unless $@
  def moveto(x, y)
    iss003_gc_moveto(x, y)
    update_pos(:bypass)
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :iss003_gc_update :update unless $@
  def update
    iss003_gc_update()
    update_pos(:normal)
  end

  #--------------------------------------------------------------------------#
  # * new-method :posRegister
  #--------------------------------------------------------------------------#
  def posRegister() ; return $game_map.posRegister ; end

  #--------------------------------------------------------------------------#
  # * new-method :update_pos
  #--------------------------------------------------------------------------#
  def update_pos(type=:normal)
    return 1 unless self.posRegister.setup_ready
    con = false # // Continue?
    case type
    when :normal ; con = !(@lastpos.x == self.x && @lastpos.y == self.y)
    when :bypass ; con = true
    when :clear  ; con = true
    end
    con = true if (@mpp_direc != @direction) unless @mpp_dfx if @mpp_enabled
    if con
      self.posRegister.delete_at(@lastpos, self)
      @multipos.each { |ps| self.posRegister.delete_at(ps, self) }
      @lastpos.x = self.x ; @lastpos.y = self.y
      return if type == :clear || !@use_posreg
      if @mpp_dfx
        @multipos_p.each_with_index { |ps, i| @multipos[i].set(self.x + ps[0], self.y + ps[1]) }
      else
        @multipos_p.each_with_index { |ps, i| @multipos[i].set(*xy_by_direction(ps)) }
      end
      unless self.is_a?(Game_Vehicle)
        self.posRegister.set_at(@lastpos, self)
        @multipos.each { |ps| self.posRegister.set_at(ps, self)  } if @mpp_enabled
      end
    end
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :xy_by_direction
  #--------------------------------------------------------------------------#
  def xy_by_direction(pos_array=[0, 0])
    puts pos_array
    case self.direction
    when 2
      return self.x+pos_array[0], self.y+pos_array[1]
    when 4
      return self.x-pos_array[1], self.y-pos_array[0]
    when 6
      return self.x+pos_array[1], self.y+pos_array[0]
    when 8
      return self.x-pos_array[0], self.y-pos_array[1]
    end
    return self.x, self.y
  end

  #--------------------------------------------------------------------------#
  # * new-method :screen_rect
  #--------------------------------------------------------------------------#
  def screen_rect()
    return @screenrect
  end

  #--------------------------------------------------------------------------#
  # * new-method :onScreen?
  #--------------------------------------------------------------------------#
  def onScreen?()
    r = self.screen_rect
    return self.screen_x.between?(r.x, r.width ) && self.screen_y.between?( r.y, r.height)
  end

end

#==============================================================================#
# ** Game_Event
#==============================================================================#
class Game_Event < Game_Character

  #--------------------------------------------------------------------------#
  # * ISS Event Cache Setup
  #--------------------------------------------------------------------------#
  iss_cachedummies :event, 3

  #--------------------------------------------------------------------------#
  # * alias-method :erase
  #--------------------------------------------------------------------------#
  alias :iss003_ge_erase :erase unless $@
  def erase(*args, &block) ;
    iss003_ge_erase(*args, &block) ; disable_posreg()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :iss003_ge_setup :setup unless $@
  def setup(*args, &block)
    iss003_ge_setup(*args, &block)
    iss003_eventcache()
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss003_eventcache_start
  #--------------------------------------------------------------------------#
  def iss003_eventcache_start()
    @__mlt_pos = []
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss003_eventcache_check
  #--------------------------------------------------------------------------#
  def iss003_eventcache_check(comment)
    case comment
    when /<(?:MULTI_POS|MULTI POS|MULTIPOS|MLTPOS)[ ](\d+),[ ](\d+)>/i
      @__mlt_pos << [$1.to_i, $2.to_i]
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss003_eventcache_start
  #--------------------------------------------------------------------------#
  def iss003_eventcache_end()
    @__mlt_pos.empty? ? clear_multipos : setup_multipos(@__mlt_pos.uniq.compact)
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
