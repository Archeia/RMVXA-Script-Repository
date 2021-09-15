#encoding:UTF-8
# ISS000 - Core 2.5
#==============================================================================#
# ** ISS - Core
#==============================================================================#
# ** Date Created  : 04/28/2011
# ** Date Modified : 10/01/2011
# ** Created By    : IceDragon
# ** For Game      : S.A.R.A
# ** ID            : 000
# ** Version       : 2.5
#==============================================================================#
# // Features
#==============================================================================#
# // Object
# //   require(filename)
# //   deep_clone
# //
# // Graphics
# //   wait(frames)
# //   wait(frames) { |frame| do_stuff }
# //
# // ISS.dice(number, sides)
# // ISS.each_noteline(note) { |line| do_stuff_with_line }
# // ISS.each_comment(event.list) { |comment| do_stuff_with_comment }
# // ISS.event_list_export(event.list, filename, [writemode)]
# // ISS.color_to_tone(color)
# // ISS.tone_to_color(tone)
# // ISS.colors_to_tones(colors)
# // ISS.tones_to_colors(tones)
# // ISS.color_transition(color1, color2, frames)
# // ISS.tone_transition(tone1, tone2, frames)
# // ISS.log_imported
# // ISS.min(n1, n2, n3, nn)
# // ISS.max(n1, n2, n3, nn)
# // ISS.clamp(n, min, max)
# //
# // ISS::Circle
# //   .new(x, y, radius)
# //   get_angle_xy(angle)
# //   get_xy
# //   set_xy(x, y)
# //
# // ISS::Pos
# //   .new(x, y, z)
# //   == another_pos
# //   set(x, y, z)
# //   get
# //   to_a
# //   to_vector2
# //   to_pos
# //
# // EVTOOLS || ISS::EventTools
# //   pos_match?(obj1, obj2)
# //   in_line?(obj1, obj2)
# //   distance_from(obj1, obj2)
# //   adjacent?(obj1, obj2)
# //
# // Vector2
# //   .new(x, y)
# //   set(x, y)
# //   to_a
# //   to_pos
# //   to_vector2
# //
# // Vector4
# //   .new(x1, x2, y1, y2)
# //   set(x1, x2, y1, y2)
# //   to_a
# //   to_rect
# //   to_vector4
# //   in_range?(obj)
# //
# // Rect
# //   to_a
# //   to_vector4
# //   to_rect
# //
# // Game_Switches (all overwritten)
# //   reset(range)
# //   last_value(variable_id)
# //   changed?(variable_id)
# //
# // Game_Variables (all overwritten)
# //   reset(range)
# //   last_value(variable_id)
# //   changed?(variable_id)
# //
# // Game_Map
# //   get_event(map_id, event_id)
# //
# // Game_Character
# //   match_pos?(obj)
# //   get_xy_infront(distance, sway|offset)
# //   move_toward_xy(x, y)
# //   move_away_from_xy(x, y)
# //   move_toward_char(char)
# //   move_away_from_char(char)
# //   move_toward_event(event_id)
# //   move_away_from_event(event_id)
# //   turn_to_xy(x, y)
# //   jump_to_xy(x, y)
# //   jump_to_char(char)
# //   jump_to_event(event_id)
# //
# // Window
# //   to_a
# //   to_rect
# //   to_vector4
# //
#==============================================================================#
$simport.r 'iss/core', '2.5.0', 'ISS Core Library'
#==============================================================================#
# ** ISS
#==============================================================================#
module ISS

  DEBUG_MODE = $TEST

  INSTALLED_SCRIPTS = {}
  SCRIPT_TYPES = {}

  def self.install_script(id, *tags)
    INSTALLED_SCRIPTS[id] = tags
    tags.each { |t| SCRIPT_TYPES[t] ||= [] ; SCRIPT_TYPES[t] << id }
  end

  def self.get_scripts_of_type(type) ; return SCRIPT_TYPES[type] ; end

  install_script(0, :core)

  module MixIns ; end
  module REGEXP ; end

  module MixIns::ISS000 ; end

end

#==============================================================================#
# ** Object
#==============================================================================#
class Object

  #--------------------------------------------------------------------------#
  # * new-method :require
  #--------------------------------------------------------------------------#
  #def require(filename)
  #  Kernel.require(filename)
  #end

  #--------------------------------------------------------------------------#
  # * new-method :deep_clone
  #--------------------------------------------------------------------------#
  def deep_clone
    return Marshal.load(Marshal.dump( self ))
  end unless method_defined? :deep_clone

end

#==============================================================================#
# ** Module
#==============================================================================#
class Module

  #--------------------------------------------------------------------------#
  # * new-method :iss_cachedummies
  #--------------------------------------------------------------------------#
  # // Special for the ISSS General Load dummies all the necessary methods
  #--------------------------------------------------------------------------#
  def iss_cachedummies(type, id)
    case type
    when :event
      define_method("iss#{"%03d"%id}_eventcache_start") {}
      define_method("iss#{"%03d"%id}_eventcache_check") { |comment| }
      define_method("iss#{"%03d"%id}_eventcache_end") {}
      module_eval %Q(
        def iss#{"%03d"%id}_eventcache
          iss#{"%03d"%id}_eventcache_start
          ISS.each_comment (@list ) { |comment| iss#{"%03d"%id}_eventcache_check( comment) } unless @list.nil?
          iss#{"%03d"%id}_eventcache_end
        end
      )
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :iss_nullcache
  #--------------------------------------------------------------------------#
  def iss_nullcache(type, id)
    case type
    when :event
      define_method("iss#{"%03d"%id}_eventcache") {}
    end
  end

end

#==============================================================================#
# ** Graphics
#==============================================================================#
module Graphics

  #--------------------------------------------------------------------------#
  # * overwrite-method :wait
  #--------------------------------------------------------------------------#
  def self.wait(frames)
    if block_given?
      frames.times { |i| Graphics.update ; yield i }
    else
      frames.times { Graphics.update }
    end
  end

end

#==============================================================================#
# ** ISS
#==============================================================================#
module ISS

  # Open Debug Console
  if DEBUG_MODE
    # // Credits to Cremno (HBGames)
    #Win32API.new("kernel32", "AllocConsole", "V", "L").call
    #$stdout.reopen("CONOUT$")
    #Win32API.new("user32", "SetForegroundWindow", "L", "L").call(Win32API.GetHwnd)
    ## what is debugging without tracing?
    #trace_var(:$scene) { |v| puts "Current scene: #{v}" }
  end

  #--------------------------------------------------------------------------#
  # * module-method :dice
  #--------------------------------------------------------------------------#
  def self.dice(number=1, sides=6)
    result = []
    number.times { |i| result << [i, rand(sides)] }
    return result
  end

  #--------------------------------------------------------------------------#
  # * module-method :each_noteline
  #--------------------------------------------------------------------------#
  def self.each_noteline(note)
    note.split(/[\r\n]+/).each { |line| yield line }
  end

  #--------------------------------------------------------------------------#
  # * module-method :each_comment
  #--------------------------------------------------------------------------#
  def self.each_comment(ev_list)
    ev_list.each { |c| yield c.parameters.to_s if [108, 408].include?(c.code) }
  end

  #--------------------------------------------------------------------------#
  # * module-method :event_list_export
  #--------------------------------------------------------------------------#
  def self.event_list_export(ev_list, filename, file_mode="w+")
    File.open(filename, file_mode) { |f|
      ev_list.each { |evc| # // EventCommand
        space = ""
        evc.indent.times { space += " " }
        f.puts("#{space}<#{evc.code}: #{evc.parameters}>")
      }
    }
  end

  #--------------------------------------------------------------------------#
  # * module-method :tone_to_color
  #--------------------------------------------------------------------------#
  def self.tone_to_color(tone)
    return Color.new(tone.red, tone.green, tone.blue, tone.gray)
  end

  #--------------------------------------------------------------------------#
  # * module-method :color_to_tone
  #--------------------------------------------------------------------------#
  def self.color_to_tone(color)
    return Tone.new(color.red, color.green, color.blue, color.alpha)
  end

  #--------------------------------------------------------------------------#
  # * module-method :tones_to_colors
  #--------------------------------------------------------------------------#
  def self.tones_to_colors(tones)
    return tones.build_from { |t| tone_to_color(t) }
  end

  #--------------------------------------------------------------------------#
  # * module-method :colors_to_tones
  #--------------------------------------------------------------------------#
  def self.colors_to_tones(colors)
    return colors.build_from { |c| color_to_tone(c) }
  end

  #--------------------------------------------------------------------------#
  # * module-method :color_transition
  #--------------------------------------------------------------------------#
  def self.color_transition(color1, color2, frames, type=0)
    result = []
    lastcolor = color1.clone
    if type == 0
      color_dif = [color1.red - color2.red, color1.green - color2.green,
                 color1.blue - color2.blue, color1.alpha - color2.alpha]
      a = [[:red, 0], [:green, 1], [:blue, 2], [:alpha, 3]]
    elsif type == 1
      color_dif = [color1.red - color2.red, color1.green - color2.green,
                 color1.blue - color2.blue, color1.gray - color2.gray]
      a = [[:red, 0], [:green, 1], [:blue, 2], [:gray, 3]]
    end
    color_dif.build_from! { |e| e.abs }
    frames.times { |i|
      a.each { |ca|
        if color1.send(ca[0]) > color2.send(ca[0])
          lastcolor.send( ca[0].to_s+"=",
           [lastcolor.send(ca[0]) - (color_dif[ca[1]] / frames.to_f),
            color2.send(ca[0])].max )
        elsif color1.send(ca[0]) < color2.send(ca[0])
          lastcolor.send( ca[0].to_s+"=",
           [lastcolor.send(ca[0]) + (color_dif[ca[1]] / frames.to_f),
            color2.send(ca[0])].min )
        end
      }
      result << lastcolor.clone
    }
    return result
  end

  #--------------------------------------------------------------------------#
  # * module-method :color_gradient_calc
  #--------------------------------------------------------------------------#
  def self.color_gradient_calc(color1, color2, frames, position)
    lastcolor = color1.clone
    color_dif = [color1.red - color2.red, color1.green - color2.green,
               color1.blue - color2.blue, color1.alpha - color2.alpha]
    a = [[:red, 0], [:green, 1], [:blue, 2], [:alpha, 3]]
    color_dif.build_from! { |e| e.abs }
    a.each { |ca|
      if color1.send(ca[0]) > color2.send(ca[0])
        lastcolor.send( ca[0].to_s+"=",
         [lastcolor.send(ca[0]) - (color_dif[ca[1]] / frames.to_f * position),
          color2.send(ca[0])].max )
      elsif color1.send(ca[0]) < color2.send(ca[0])
        lastcolor.send( ca[0].to_s+"=",
         [lastcolor.send(ca[0]) + (color_dif[ca[1]] / frames.to_f * position),
          color2.send(ca[0])].min )
      end
    }
    return lastcolor
  end

  #--------------------------------------------------------------------------#
  # * module-method :tone_transition
  #--------------------------------------------------------------------------#
  def self.tone_transition(tone1, tone2, frames)
    color_transition(tone1, tone2, frames, 1)
  end

  #--------------------------------------------------------------------------#
  # * module-method :log_imported
  #--------------------------------------------------------------------------#
  def self.log_imported
    File.open("ImportedScripts.log", "w+") { |f|
      $imported.keys.sort.each { |s| f.puts(s) } }
  end

  #--------------------------------------------------------------------------#
  # * module-method :min
  #--------------------------------------------------------------------------#
  def self.min(*args)
    return args.inject(args[0]) { |r, e| r = e if e < r ; r }
  end

  #--------------------------------------------------------------------------#
  # * module-method :max
  #--------------------------------------------------------------------------#
  def self.max(*args)
    return args.inject(args[0]) { |r, e| r = e if e > r ; r }
  end

  #--------------------------------------------------------------------------#
  # * module-method :clamp
  #--------------------------------------------------------------------------#
  def self.clamp(n, minv, maxv)
    return min(maxv, max( n, minv ))
  end

#==============================================================================#
# ** Circle
#==============================================================================#
  class Circle

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
    attr_accessor :x
    attr_accessor :y
    attr_accessor :radius

  #--------------------------------------------------------------------------#
  # * overwrite-method :initialize
  #--------------------------------------------------------------------------#
    def initialize(x, y, radius) ; @x, @y, @radius = x, y, radius end

  #--------------------------------------------------------------------------#
  # * new-method :get_angle_xy
  #--------------------------------------------------------------------------#
    def get_angle_xy (angle)
      rx = @x + @radius * Math.cos((angle/180.0)*Math::PI)
      ry = @y + @radius * Math.sin((angle/180.0)*Math::PI)
      return rx, ry
    end

  #--------------------------------------------------------------------------#
  # * new-method :set_xy / get_xy
  #--------------------------------------------------------------------------#
    def get_xy       ; return @x, @y ; end
    def set_xy(x, y) ; @x, @y = x, y ; end

  end

#==============================================================================#
# ** Counter
#==============================================================================#
  class Counter

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
    attr_accessor :count

  #--------------------------------------------------------------------------#
  # * overwrite-method :initialize
  #--------------------------------------------------------------------------#
    def initialize
      reset!
    end

  #--------------------------------------------------------------------------#
  # * new-method :reset!
  #--------------------------------------------------------------------------#
    def reset!
      @count = 0
    end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
    def update
      @count += 1
    end

  end

#==============================================================================#
# ** Timer
#==============================================================================#
  class Timer

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
    attr_accessor :time
    attr_accessor :time_max

  #--------------------------------------------------------------------------#
  # * overwrite-method :initialize
  #--------------------------------------------------------------------------#
    def initialize(time_max, bottom_cap=0, auto_reset=false)
      @bottom_cap = bottom_cap
      @auto_reset = auto_reset
      @time = @time_max = time_max
      reset!
    end

  #--------------------------------------------------------------------------#
  # * new-method :reset!
  #--------------------------------------------------------------------------#
    def reset! ; @time = @time_max ; end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
    def update
      reset! if @time == @bottom_cap if @auto_reset
      @time = [@time-1, @bottom_cap].max
    end

  #--------------------------------------------------------------------------#
  # * new-method :finished?
  #--------------------------------------------------------------------------#
    def finished? ; return @time == @bottom_cap ; end

  #--------------------------------------------------------------------------#
  # * new-method :now
  #--------------------------------------------------------------------------#
    def now ; return [@time, @time_max] ; end

  #--------------------------------------------------------------------------#
  # * new-method :now_to_s
  #--------------------------------------------------------------------------#
    def now_to_s; return sprintf("%s/%s", *self.now) ; end

  end

#==============================================================================#
# ** Pos
#==============================================================================#
  class Pos

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
    attr_accessor :x # // X
    attr_accessor :y # // Y
    attr_accessor :z # // Z

  #--------------------------------------------------------------------------#
  # * overwrite-method :initialize
  #--------------------------------------------------------------------------#
    def initialize(x=0, y=0, z=0 ) ; set( x, y, z) ; end

  #--------------------------------------------------------------------------#
  # * super-method :==
  #--------------------------------------------------------------------------#
    def ==(obj)
      return ( @x == obj.x &&
        @y == obj.y &&
        @z == obj.z ) if obj.kind_of?(self.class)
      return super(obj)
    end

  #--------------------------------------------------------------------------#
  # * new-method :set
  #--------------------------------------------------------------------------#
    def set(nx=@x, ny=@y, nz=@z) ; @x, @y, @z = nx, ny, nz ; end

  #--------------------------------------------------------------------------#
  # * new-method :get
  #--------------------------------------------------------------------------#
    def get ; return self.x, self.y, self.z ; end

  #--------------------------------------------------------------------------#
  # * new-method :to_a
  #--------------------------------------------------------------------------#
    def to_a ; return get ; end

  #--------------------------------------------------------------------------#
  # * overwrite-method :to_s
  #--------------------------------------------------------------------------#
    def to_s
      return sprintf("%s X%d:Y%d:Z%d", super, @x, @y, @z)
    end

  #--------------------------------------------------------------------------#
  # * new-method :to_vector2
  #--------------------------------------------------------------------------#
    def to_vector2 ; return ::Vector2.new(self.x, self.y) ; end

  #--------------------------------------------------------------------------#
  # * new-method :to_pos
  #--------------------------------------------------------------------------#
    def to_pos ; return self.clone ; end

  end

#==============================================================================#
# ** Pop_Handler # // XAS
#==============================================================================#
  class Pop_Handler

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
    attr_accessor :x
    attr_accessor :y
    attr_accessor :ox
    attr_accessor :oy

    attr_accessor :x_velocity
    attr_accessor :y_velocity
    attr_accessor :x_boost
    attr_accessor :y_boost
    attr_accessor :x_add
    attr_accessor :y_add

    attr_accessor :cap_duration
    attr_accessor :finished
    attr_accessor :pause_update
    attr_accessor :gravity
    attr_accessor :floor_val

    GRAVITY = 0.58
    TRANSEPARENT_START = 40
    TRANSEPARENT_X_SLIDE = 0

    def initialize(x, y)
      @start_settings = [x, y, 0, 0]
      @cap_duration = 80
      @x_velocity = 0.4
      @y_velocity = 1.5
      @x_boost    = 8
      @y_boost    = 4
      @x_add      = 0
      @y_add      = 4
      @gravity    = GRAVITY
      @floor_val  = 0
      reset
    end

    def reset
      @x, @y, @ox, @oy = *@start_settings
      @finished = false
      @pause_update = false
      prep_pop
    end

    def damage_x_init_velocity
      return @x_velocity * (rand(@x_boost) + @x_add)
    end

    def damage_y_init_velocity
      return @y_velocity * (rand(@y_boost) + @y_add)
    end

    def prep_pop
      @now_x_speed = damage_x_init_velocity
      @now_y_speed = damage_y_init_velocity
      @potential_x_energy = 0.0
      @potential_y_energy = 0.0
      @speed_off_x = rand(2)
      @pop_duration = @cap_duration
    end

    def update
      return if @finished or @pause_update
      if @pop_duration <= TRANSEPARENT_START
        @x += TRANSEPARENT_X_SLIDE if @speed_off_x == 0
        @x -= TRANSEPARENT_X_SLIDE if @speed_off_x == 1
      end
      n = @oy + @now_y_speed
      if n <= @floor_val #0
        @now_y_speed *= -1
        @now_y_speed /=  2
        @now_x_speed /=  2
      end
      @oy = [n, @floor_val].max
      @potential_y_energy += @gravity
      speed                = @potential_y_energy.floor
      @now_y_speed        -= speed
      @potential_y_energy -= speed
      @potential_x_energy += @now_x_speed
      speed                = @potential_x_energy.floor
      @ox                 += speed if @speed_off_x == 0
      @ox                 -= speed if @speed_off_x == 1
      @potential_x_energy -= speed
      @pop_duration       -= 1
      if @pop_duration == 0
        @finished = true
      end
    end

  end

end

#==============================================================================#
# ** ISS::EventTools
#==============================================================================#
module ISS::EventTools

  module_function

  #--------------------------------------------------------------------------#
  # * new-method :pos_match?
  #--------------------------------------------------------------------------#
  def pos_match?(obj, obj2)
    return (obj.x == obj2.x && obj.y == obj2.y)
  end

  #--------------------------------------------------------------------------#
  # * new-method :in_line?
  #--------------------------------------------------------------------------#
  def in_line?(obj, obj2, axis)
    case axis
    when :x ; return obj.x == obj2.x
    when :y ; return obj.y == obj2.y
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :distance_from
  #--------------------------------------------------------------------------#
  def distance_from(obj, obj2)
    return (obj.x - obj2.x).abs + (obj.y - obj2.y).abs
  end

  #--------------------------------------------------------------------------#
  # * new-method :adjacent?
  #--------------------------------------------------------------------------#
  def adjacent?(obj, obj2)
    return distance_from(obj, obj2) == 1
  end

end

#==============================================================================#
# ** System Shortcut - EVTOOLS
#==============================================================================#
EVTOOLS = ISS::EventTools

#==============================================================================#
# ** Vector2
#==============================================================================#
class Vector2

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(x=0, y=0 ) ; set( x, y) ; end

  #--------------------------------------------------------------------------#
  # * new-method :set
  #--------------------------------------------------------------------------#
  def set(new_x, new_y)
    self.x, self.y = new_x, new_y
  end

  #--------------------------------------------------------------------------#
  # * new-method :to_a
  #--------------------------------------------------------------------------#
  def to_a ; return self.x, self.y ; end

  #--------------------------------------------------------------------------#
  # * new-method :to_pos
  #--------------------------------------------------------------------------#
  def to_pos ; return ISS::Pos.new(self.x, self.y) ; end

  #--------------------------------------------------------------------------#
  # * new-method :to_pos
  #--------------------------------------------------------------------------#
  def to_vector2 ; return self.clone ; end

end

#==============================================================================#
# ** Vector4
#==============================================================================#
class Vector4

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :x1, :x2, :y1, :y2

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(x1=0, x2=0, y1=0, y2=0)
    set(x1, x2, y1, y2)
  end

  #--------------------------------------------------------------------------#
  # * new-method :set
  #--------------------------------------------------------------------------#
  def set(x1=@x1, x2=@x2, y1=@y1, y2=@y2)
    @x1, @x2, @y1, @y2 = x1, x2, y1, y2
  end

  #--------------------------------------------------------------------------#
  # * new-method :to_a
  #--------------------------------------------------------------------------#
  def to_a ; return self.x1, self.x2, self.y1, self.y2 ; end

  #--------------------------------------------------------------------------#
  # * new-method :to_rect
  #--------------------------------------------------------------------------#
  def to_rect
    return Rect.new(self.x1, self.y1, self.x2-self.x1, self.y2-self.y1)
  end

  #--------------------------------------------------------------------------#
  # * new-method :to_vector4
  #--------------------------------------------------------------------------#
  def to_vector4 ; return self.clone ; end

  #--------------------------------------------------------------------------#
  # * new-method :in_range?
  #--------------------------------------------------------------------------#
  def in_range?(obj)
    case obj
    when Vector2, ISS::Pos
      return obj.x.between?(self.x1, self.x2 ) && obj.y.between?( self.y1, self.y2)
    when Vector4
      return (obj.x1.between?(self.x1, self.x2 ) && obj.y1.between?( self.y1, self.y2)) ||
        (obj.x2.between?(self.x1, self.x2 ) && obj.y2.between?( self.y1, self.y2))
    when Rect
      return (obj.x.between?(self.x1, self.x2 ) && obj.y.between?( self.y1, self.y2) ||
        (obj.x+obj.width).between?(self.x1, self.x2 ) && (obj.y+obj.height).between?( self.y1, self.y2))
    end
    return false
  end

end

#==============================================================================#
# ** Rect
#==============================================================================#
class Rect

  #--------------------------------------------------------------------------#
  # * new-method :to_a
  #--------------------------------------------------------------------------#
  def to_a ; return self.x, self.y, self.width, self.height ; end

  #--------------------------------------------------------------------------#
  # * new-method :to_vector4
  #--------------------------------------------------------------------------#
  def to_vector4
    return Vector4.new(self.x, self.x+self.width, self.y, self.y+self.height)
  end

  #--------------------------------------------------------------------------#
  # * new-method :to_rect
  #--------------------------------------------------------------------------#
  def to_rect ; return self.clone ; end

end

#==============================================================================#
# ** Game_Switches
#==============================================================================#
class Game_Switches

  #--------------------------------------------------------------------------#
  # * overwrite-method :initialize
  #--------------------------------------------------------------------------#
  def initialize
    @data      = Array.new(5001, false)
    @last_data = Array.new(5001, false)
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :[]
  #--------------------------------------------------------------------------#
  def [](switch_id) ; @data[switch_id] ||= false ; end

  #--------------------------------------------------------------------------#
  # * overwrite-method :[]=
  #--------------------------------------------------------------------------#
  def []=(switch_id, value)
    @last_data[switch_id] = @data[switch_id]
    @data[switch_id] = value
  end

  #--------------------------------------------------------------------------#
  # * new-method :reset
  #--------------------------------------------------------------------------#
  def reset(rang=0..@data.size) ; rang.each { |i| self[i] = false } ; end

  #--------------------------------------------------------------------------#
  # * new-method :last_value
  #--------------------------------------------------------------------------#
  def last_value(switch_id) ; return @last_data[switch_id] ; end

  #--------------------------------------------------------------------------#
  # * new-method :changed?
  #--------------------------------------------------------------------------#
  def changed?(switch_id)
    return last_value(switch_id) != self[switch_id]
  end

end

#==============================================================================#
# ** Game_Variables
#==============================================================================#
class Game_Variables

  #--------------------------------------------------------------------------#
  # * overwrite-method :initialize
  #--------------------------------------------------------------------------#
  def initialize
    @data      = Array.new(5001, 0)
    @last_data = Array.new(5001, 0)
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :[]
  #--------------------------------------------------------------------------#
  def [](variable_id) ; return @data[variable_id] ||= 0 ; end

  #--------------------------------------------------------------------------#
  # * overwrite-method :[]=
  #--------------------------------------------------------------------------#
  def []=(variable_id, value)
    @last_data[variable_id] = @data[variable_id]
    @data[variable_id] = value
  end

  #--------------------------------------------------------------------------#
  # * new-method :reset
  #--------------------------------------------------------------------------#
  def reset(rang=0..@data.size) ; rang.each { |i| self[i] = 0 } ; end

  #--------------------------------------------------------------------------#
  # * new-method :last_value
  #--------------------------------------------------------------------------#
  def last_value(variable_id) ; return @last_data[variable_id] ; end

  #--------------------------------------------------------------------------#
  # * new-method :changed?
  #--------------------------------------------------------------------------#
  def changed?(variable_id)
    return last_value(variable_id) != self[variable_id]
  end

end

#==============================================================================#
# ** Game_Map
#==============================================================================#
class Game_Map

  #--------------------------------------------------------------------------#
  # * new-method :get_event
  #--------------------------------------------------------------------------#
  def get_event(map_id, event_id)
    return get_map(map_id).events[event_id] if $imported["IEO-BugFixesUpgrades"]
    return load_data(sprintf( "Data/Map%03d.rvdata", map_id )).events[event_id]
  end unless method_defined? :get_event

end

#==============================================================================#
# ** Game_Character
#==============================================================================#
class Game_Character

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :move_speed
  attr_accessor :opacity

  #--------------------------------------------------------------------------#
  # * new-method :pos
  #--------------------------------------------------------------------------#
  def pos
    return ::ISS::Pos.new(self.x, self.y)
  end

  #--------------------------------------------------------------------------#
  # * new-method :pos_to_a
  #--------------------------------------------------------------------------#
  def pos_to_a
    return self.x, self.y
  end

  #--------------------------------------------------------------------------#
  # * new-method :match_pos?
  #--------------------------------------------------------------------------#
  def match_pos?(obj)
    return (self.x == obj.x && self.y == obj.y)
  end

  #--------------------------------------------------------------------------#
  # * new-method :get_xy_infront
  #--------------------------------------------------------------------------#
  def get_xy_infront(dist, sway)
    case direction
    when 2 # // Down
      return [x+sway, y+dist]
    when 4 # // Left
      return [x-dist, y+sway]
    when 6 # // Right
      return [x+dist, y-sway]
    when 8 # // Up
      return [x-sway, y-dist]
    end
  end

  #--------------------------------------------------------------------------#
  # * Calculate X Distance From Target X
  #--------------------------------------------------------------------------#
  def distance_x_from_tx(tx)
    sx = @x - tx
    if $game_map.loop_horizontal?         # When looping horizontally
      if sx.abs > $game_map.width / 2     # Larger than half the map width?
        sx -= $game_map.width             # Subtract map width
      end
    end
    return sx
  end

  #--------------------------------------------------------------------------#
  # * Calculate Y Distance From Target Y
  #--------------------------------------------------------------------------#
  def distance_y_from_ty(ty)
    sy = @y - ty
    if $game_map.loop_vertical?           # When looping vertically
      if sy.abs > $game_map.height / 2    # Larger than half the map height?
        sy -= $game_map.height            # Subtract map height
      end
    end
    return sy
  end

  #--------------------------------------------------------------------------#
  # * Move toward XY
  #--------------------------------------------------------------------------#
  def move_toward_xy(x, y)
    move_8d = false
    sx = distance_x_from_tx(x)
    sy = distance_y_from_ty(y)
    if move_8d
      # // Need to work on it
    else
      if sx != 0 or sy != 0
        if sx.abs > sy.abs                  # Horizontal distance is longer
          sx > 0 ? move_left : move_right   # Prioritize left-right
          if @move_failed and sy != 0
            sy > 0 ? move_up : move_down
          end
        else                                # Vertical distance is longer
          sy > 0 ? move_up : move_down      # Prioritize up-down
          if @move_failed and sx != 0
            sx > 0 ? move_left : move_right
          end
        end
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * Move away from XY
  #--------------------------------------------------------------------------#
  def move_away_from_xy(x, y)
    move_8d = false
    sx = distance_x_from_tx(x)
    sy = distance_y_from_ty(y)
    if move_8d
      # // Need to work on it
    else
      if sx != 0 or sy != 0
        if sx.abs > sy.abs                  # Horizontal distance is longer
          sx > 0 ? move_right : move_left   # Prioritize left-right
          if @move_failed and sy != 0
            sy > 0 ? move_down : move_up
          end
        else                                # Vertical distance is longer
          sy > 0 ? move_down : move_up      # Prioritize up-down
          if @move_failed and sx != 0
            sx > 0 ? move_right : move_left
          end
        end
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * Move toward XY 2 (More Movement XD)
  #--------------------------------------------------------------------------#
  def move_toward_xy(x, y)
    move_8d = false
    sx = distance_x_from_tx(x)
    sy = distance_y_from_ty(y)
    if move_8d
      # // Need to work on it
    else
      if sx != 0 or sy != 0
        if sx.abs > sy.abs                  # Horizontal distance is longer
          sx > 0 ? move_left : move_right   # Prioritize left-right
          if @move_failed
            if sy != 0
              sy > 0 ? move_up : move_down
            else
              rand(2) == 1 ? move_up : move_down
            end
          end
        else                                # Vertical distance is longer
          sy > 0 ? move_up : move_down      # Prioritize up-down
          if @move_failed
            if sx != 0
              sx > 0 ? move_left : move_right
            else
              rand(2) == 1 ? move_left : move_right
            end
          end
        end
      end
    end
  end if false == true # // Disabled

  #--------------------------------------------------------------------------#
  # * Move toward Character
  #--------------------------------------------------------------------------#
  def move_toward_char(char)
    move_toward_xy(char.x, char.y)
  end

  #--------------------------------------------------------------------------#
  # * Move away from Character
  #--------------------------------------------------------------------------#
  def move_away_from_char(char)
    move_away_from_xy(char.x, char.y)
  end

  #--------------------------------------------------------------------------#
  # * Move toward Event
  #--------------------------------------------------------------------------#
  def move_toward_event(event_id)
    move_toward_char($game_map.events[event_id])
  end

  #--------------------------------------------------------------------------#
  # * Move away from Event
  #--------------------------------------------------------------------------#
  def move_away_from_event(event_id)
    move_away_from_char($game_map.events[event_id])
  end

  #--------------------------------------------------------------------------#
  # * Turn to XY
  #--------------------------------------------------------------------------#
  def turn_to_xy(x, y)
    turn_right if x > self.x
    turn_left if x < self.x
    turn_down if y > self.y
    turn_up if y < self.y
  end

  #--------------------------------------------------------------------------#
  # * Jump to XY
  #--------------------------------------------------------------------------#
  def jump_to_xy(tx, ty)
    jump(tx-self.x, ty-self.y)
  end

  #--------------------------------------------------------------------------#
  # * Jump to Character
  #--------------------------------------------------------------------------#
  def jump_to_char(char)
    jump_to_xy(char.x, char.y)
  end

  #--------------------------------------------------------------------------#
  # * Jump to Event
  #--------------------------------------------------------------------------#
  def jump_to_event(event_id)
    jump_to_char($game_map.events[event_id])
  end

end

#==============================================================================#
# ** Window
#==============================================================================#
class Window

  #--------------------------------------------------------------------------#
  # * new-method :to_a
  #--------------------------------------------------------------------------#
  def to_a
    return self.x, self.y, self.width, self.height
  end

  #--------------------------------------------------------------------------#
  # * new-method :to_rect
  #--------------------------------------------------------------------------#
  def to_rect
    return Rect.new(*to_a)
  end

  #--------------------------------------------------------------------------#
  # * new-method :to_vector4
  #--------------------------------------------------------------------------#
  def to_vector4
    return Vector4.new(self.x, self.x+self.width, self.y, self.y+self.height)
  end

end

#==============================================================================#
# ** Scene_Base
#==============================================================================#
class Scene_Base

  attr_accessor :input_disabled

end
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
