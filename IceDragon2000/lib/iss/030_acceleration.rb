#encoding:UTF-8
# ISS030 - Acceleration
class Game_Character

  alias :iss030_gmc_initialize :initialize unless $@
  def initialize(*args, &block)
    iss030_gmc_initialize(*args, &block)
    @accel = 0
    @accel_hold = 0
  end

  def move_speed()
    return @move_speed + @accel
  end

  alias :iss030_gmc_update :update unless $@
  def update(*args, &block)
    iss030_gmc_update(*args, &block)
    #@accel_hold = [[@accel_hold-1, 0].max, 40].min

  end

  def update_move
    distance = 2 ** self.move_speed   # Convert to movement distance
    distance *= 2 if dash?        # If dashing, double it
    @real_x = [@real_x - distance, @x * 256].max if @x * 256 < @real_x
    @real_x = [@real_x + distance, @x * 256].min if @x * 256 > @real_x
    @real_y = [@real_y - distance, @y * 256].max if @y * 256 < @real_y
    @real_y = [@real_y + distance, @y * 256].min if @y * 256 > @real_y
    update_bush_depth unless moving?
    if @walk_anime
      @anime_count += 1.5
    elsif @step_anime
      @anime_count += 1
    end
  end

end

class Game_Player

  def move_by_input()
    return if $game_map.interpreter.running?
    @accel_hold = 0
    case Input.dir4
    when 2;
      @accel_hold = 1
      move_down if movable?
    when 4;
      @accel_hold = 1
      move_left if movable?
    when 6;
      @accel_hold = 1
      move_right if movable?
    when 8;
      @accel_hold = 1
      move_up if movable?
    end
    if @accel_hold == 0
      @accel = [@accel - 0.1, -2].max
    else
      @accel = [@accel + 0.1, 0].min
    end
  end

end
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
