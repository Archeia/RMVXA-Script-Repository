#==============================================================================
# [ACE] Caterpillar Jump Fix v1.0 by Wecoc
#==============================================================================
# On RPG Maker VX Ace default caterpillar when the player jumps the followers 
# don't jump with him, they walk magically through the wall or over the swamp...
#==============================================================================
This script is a partial rewrite of the Caterpillar system to avoid this type of bugs.
class Game_Player < Game_Character
 
  attr_accessor :player_route
  def init_private_members
    super
    @player_route = []
  end

  def move_straight(d, turn_ok = true)
    push_straight_route(d) if passable?(@x, @y, d)
    super
  end

  def move_diagonal(horz, vert)
    push_diagonal_route(horz, vert) if diagonal_passable?(@x, @y, horz, vert)
    super
  end
 
  def push_straight_route(d)
    case d
      when 1 then @player_route.push([ROUTE_MOVE_LOWER_L])
      when 2 then @player_route.push([ROUTE_MOVE_DOWN])
      when 3 then @player_route.push([ROUTE_MOVE_LOWER_R])
      when 4 then @player_route.push([ROUTE_MOVE_LEFT])
      when 6 then @player_route.push([ROUTE_MOVE_RIGHT])
      when 7 then @player_route.push([ROUTE_MOVE_UPPER_L])
      when 8 then @player_route.push([ROUTE_MOVE_UP])
      when 9 then @player_route.push([ROUTE_MOVE_UPPER_R])
    end
  end
 
  def push_diagonal_route(horz, vert)
    d = case [horz, vert]
      when [4, 2] then 1
      when [6, 2] then 3
      when [4, 8] then 7
      when [6, 8] then 9
    end
    push_straight_route(d)
  end
 
  alias wecoc_fix_jump jump unless $@
  def jump(x_plus, y_plus)
    wecoc_fix_jump(x_plus, y_plus)
    @player_route.push([ROUTE_JUMP, x_plus, y_plus])
  end
end

class Game_Follower < Game_Character

  attr_accessor :player_route
  def init_private_members
    super
    @player_route = []
  end

  def move_straight(d, turn_ok = true)
    push_straight_route(d) if passable?(@x, @y, d)
    super
  end

  def move_diagonal(horz, vert)
    push_diagonal_route(horz, vert) if diagonal_passable?(@x, @y, horz, vert)
    super
  end
 
  def push_straight_route(d)
    case d
      when 1 then @player_route.push([ROUTE_MOVE_LOWER_L])
      when 2 then @player_route.push([ROUTE_MOVE_DOWN])
      when 3 then @player_route.push([ROUTE_MOVE_LOWER_R])
      when 4 then @player_route.push([ROUTE_MOVE_LEFT])
      when 6 then @player_route.push([ROUTE_MOVE_RIGHT])
      when 7 then @player_route.push([ROUTE_MOVE_UPPER_L])
      when 8 then @player_route.push([ROUTE_MOVE_UP])
      when 9 then @player_route.push([ROUTE_MOVE_UPPER_R])
    end
  end
 
  def push_diagonal_route(horz, vert)
    array = [horz, vert]
    d = case array
      when [4, 2] then 1
      when [6, 2] then 3
      when [4, 8] then 7
      when [6, 8] then 9
    end
    push_straight_route(d)
  end
 
  alias wecoc_fix_jump jump unless $@
  def jump(x_plus, y_plus)
    wecoc_fix_jump(x_plus, y_plus)
    @player_route.push([ROUTE_JUMP, x_plus, y_plus])
  end
 
  alias wecoc_fix_upd update unless $@
  def update
    unless self.moving? or self.jumping?
      if @preceding_character.moving? or @preceding_character.jumping?
        if @preceding_character.player_route.size != 0
          movement = @preceding_character.player_route[0]
          new_x = @x
          new_y = @y
          case movement[0]
          when ROUTE_MOVE_LOWER_L
            new_x -= 1
            new_y += 1
          when ROUTE_MOVE_DOWN
            new_y += 1
          when ROUTE_MOVE_LOWER_R
            new_x += 1
            new_y += 1
          when ROUTE_MOVE_LEFT
            new_x -= 1
          when ROUTE_MOVE_RIGHT
            new_x += 1
          when ROUTE_MOVE_UPPER_L
            new_x -= 1
            new_y -= 1
          when ROUTE_MOVE_UP
            new_y -= 1
          when ROUTE_MOVE_UPPER_R
            new_x += 1
            new_y -= 1
          when ROUTE_JUMP
            new_x += movement[1]
            new_y += movement[2]
          end
          p_cords = [@preceding_character.x, @preceding_character.y]
          if  p_cords != [new_x, new_y]
            case movement[0]
              when ROUTE_MOVE_LOWER_L then move_diagonal(4, 2)
              when ROUTE_MOVE_DOWN    then move_straight(2)
              when ROUTE_MOVE_LOWER_R then move_diagonal(6, 2)
              when ROUTE_MOVE_LEFT    then move_straight(4)
              when ROUTE_MOVE_RIGHT  then move_straight(6)
              when ROUTE_MOVE_UPPER_L then move_diagonal(4, 8)
              when ROUTE_MOVE_UP      then move_straight(8)
              when ROUTE_MOVE_UPPER_R then move_diagonal(6, 8)
              when ROUTE_JUMP then jump(movement[1], movement[2])
            end
            @preceding_character.player_route.shift
          end
        end
      end
    end
    wecoc_fix_upd
  end
end

class Game_Followers
  alias wecoc_syn synchronize unless $@
  def synchronize(x, y, d)
    wecoc_syn(x, y, d)
    restore_route
  end
 
  def restore_route
    each do |follower|
      follower.player_route = []
    end
    $game_player.player_route = []
  end
end

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Gather Followers
  #--------------------------------------------------------------------------
  alias wecoc_command_217 command_217 unless $@
  def command_217
    wecoc_command_217
    $game_player.followers.restore_route
  end
end