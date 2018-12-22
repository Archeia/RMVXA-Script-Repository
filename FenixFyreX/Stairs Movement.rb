#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
# Stairs Movement v 1.0
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
#
# FenixFyreX
#
# Final Fantasy VI had stairs that the player actually walked up. Their direction
# became two way on these stairs, left or right. This script replicates that
# feature.
#
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#

StairsRegionID = 60   # The region ID to use for designating staircases
StairsOffset   = 4    # The height of one tileset staircase plank (about 4px)
CharAnimSpeed  = 2    # The speed at which a sprite cycles through frames

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
# End of Config. Do not edit below.
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#

class Game_Map
  def stairs?(x,y)
    region_id(x,y) == StairsRegionID
  end
end

class Game_CharacterBase
  
  # give other coders access to checking stairs status
  attr_reader :on_stairs
  alias on_stairs? on_stairs
  
  # check whether character is on stairs
  def check_stairs
    @on_stairs = stairs?(0)
  end
  
  # Checks if there are any sets of stairs in the given direction
  def stairs?(d)
    return case d
    when 0
      $game_map.stairs?(@x,@y)
    when 2
      $game_map.stairs?(@x-1,@y+1) || $game_map.stairs?(@x+1,@y+1)
    when 4
      $game_map.stairs?(@x-1,@y-1) || $game_map.stairs?(@x-1,@y+1)
    when 6
      $game_map.stairs?(@x+1,@y-1) || $game_map.stairs?(@x+1,@y+1)
    when 8
      $game_map.stairs?(@x-1,@y-1) || $game_map.stairs?(@x+1,@y-1)
    else
      false
    end
  end
  
  # Checks passability in the given direction for stairs
  def stairs_passable?(x, y, d)
    x2 = $game_map.round_x_with_direction(x, d)
    y2 = $game_map.round_y_with_direction(y, d)
    return false unless $game_map.valid?(x2, y2)
    return true if @through || debug_through?
    return false unless map_passable?(x, y, d)
    return false if collide_with_characters?(x2, y2)
    return true
  end
  
  # Moves the character in the given direction diagonally up or down stairs
  def move_diag_stairs(d, horz, vert, turn_ok)
    x,y = @x+horz,@y+vert
    horz = [4,6][[-1,1].index(horz)]
    vert = [8,2][[-1,1].index(vert)]
    @move_succeed = stairs_passable?(x,y,d)
    d = [4,6][[[4,8],[6,8],[4,2],[6,2]].index([horz,vert])%2]
    set_direction(d) if turn_ok
    if @move_succeed
      @x = $game_map.round_x_with_direction(@x, horz)
      @y = $game_map.round_y_with_direction(@y, vert)
      @real_x = $game_map.x_with_direction(@x, reverse_dir(horz))
      @real_y = $game_map.y_with_direction(@y, reverse_dir(vert))
      increase_steps
    end
  end
  
  # Returns the stair vector for the given direction
  def stair_vector(d)
    x,y = 0,0
    case d
    when 4,6
      x = [-1,1][[4,6].index(d)]
      y = $game_map.stairs?(@x+x,@y-1) ? -1 : 1
    when 2,8
      y = [-1,1][[8,2].index(d)]
      x = $game_map.stairs?(@x-1,@y+y) ? -1 : 1
    end
    [x,y]
  end
  
  # Checks whether or not the character is not getting on or off stairs
  def midstairs?
    @on_stairs && stairs?(reverse_dir(@direction))
  end
  
  # Alters original move method to put stairs into effect
  alias move_straight_no_stairs move_straight
  def move_straight(d, turn_ok = true)
    if on_stairs? && stairs?(d)
      move_diag_stairs(d, *stair_vector(d), turn_ok)
    else
      d = @direction if @on_stairs && [2,8].include?(d)
      move_straight_no_stairs(d, turn_ok)
    end
    check_stairs
  end
  
  # Shift the y coordinate of the character's sprite to compensate for stairs
  alias shift_y_for_stairs shift_y
  def shift_y(*a,&bl)
    shift_y_for_stairs(*a,&bl) + (midstairs? ? StairsOffset : 0)
  end
  
  # Update the sprite more to create pace-per-step effect on stairs
  alias update_anime_count_for_stairs update_anime_count
  def update_anime_count(*a,&bl)
    ac = @anime_count
    update_anime_count_for_stairs(*a,&bl)
    @anime_count += CharAnimSpeed if midstairs?
  end
end

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
# End of Script
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#