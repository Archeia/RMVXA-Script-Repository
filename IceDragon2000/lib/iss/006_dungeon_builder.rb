#encoding:UTF-8
# ISS006 - DungeonBuilder
$tile_markers = []
module ISS

  module Dungeon ; end

  class Dungeon::ObjectHandler

    attr_accessor :character
    attr_accessor :resource

    def initialize(character)
      @character    = character
      @home_x, @home_y = character.x, character.y
    end

    def get_next_tile
      return $tile_markers[0]
    end

    def home_xy
      return @home_x, @home_y
    end

    def change_tile
      x, y = @character.x, @character.y
      $game_map.data[x, y, 0] = 1568
      ::ISS::Dungeon.correct_autotile($game_map.data, x, y, 0)
      return
      case @character.direction
      when 2 # // Down
        $game_map.data[x, y+1, 0] = 1568
        ISS::Dungeon.correct_autotile($game_map.data, x, y+1, 0)
      when 4 # // Left
        $game_map.data[x-1, y, 0] = 1568
        ISS::Dungeon.correct_autotile($game_map.data, x-1, y, 0)
      when 6 # // Right
        $game_map.data[x+1, y, 0] = 1568
        ISS::Dungeon.correct_autotile($game_map.data, x+1, y, 0)
      when 8 # // Up
        $game_map.data[x, y-1, 0] = 1568
        ISS::Dungeon.correct_autotile($game_map.data, x, y-1, 0)
      end
    end

    def update()
    end

  end

  class Dungeon::Handler_Shroud
  end

  class Dungeon::Handler_Highlight
  end

  module Dungeon

    module_function

    def round_x(x ) ; return $game_map.round_x( x) end
    def round_y(y ) ; return $game_map.round_y( y) end

    def correct_autotile2(data, x, y, z)
      auto_tile_id = 0
      if round_y(y - 1) >= 0 and
         data[x, round_y(y-1), 2] != Ex_Field_Tile::ID[index]
        auto_tile_id = 20
      end
      if round_x(x - 1) >= 0 and
         data[round_x(x-1), y, 2] != Ex_Field_Tile::ID[index]
        case auto_tile_id
        when 0  ; auto_tile_id = 16
        when 20 ; auto_tile_id = 34
        end
      end
      if round_x(x + 1) < width and
         data[round_x(x+1), y, 2] != Ex_Field_Tile::ID[index]
        case auto_tile_id
        when 0  ; auto_tile_id = 24
        when 16 ; auto_tile_id = 32
        when 20 ; auto_tile_id = 36
        when 34 ; auto_tile_id = 42
        end
      end
      if round_x(y + 1) < height and
         data[x, round_y(y+1), 2] != Ex_Field_Tile::ID[index]
        case auto_tile_id
        when 0  ; auto_tile_id = 28
        when 16 ; auto_tile_id = 40
        when 20 ; auto_tile_id = 33
        when 24 ; auto_tile_id = 38
        when 32 ; auto_tile_id = 44
        when 34 ; auto_tile_id = 43
        when 36 ; auto_tile_id = 45
        when 42 ; auto_tile_id = 46
        end
      end
      if round_x(x - 1) >= 0 and round_y(y - 1) >= 0 and
         data[round_x(x-1), round_y(y-1), 2] != Ex_Field_Tile::ID[index]
        case auto_tile_id
        when 0  ; auto_tile_id = 1
        when 24 ; auto_tile_id = 26
        when 28 ; auto_tile_id = 29
        when 38 ; auto_tile_id = 39
        end
      end
      if round_x(x + 1) < width and round_y(y - 1) >= 0 and
         data[round_x(x+1), round_y(y-1), 2] != Ex_Field_Tile::ID[index]
        case auto_tile_id
        when 0  ; auto_tile_id = 2
        when 1  ; auto_tile_id = 3
        when 16 ; auto_tile_id = 17
        when 28 ; auto_tile_id = 30
        when 29 ; auto_tile_id = 31
        when 40 ; auto_tile_id = 41
        end
      end
      if round_x(x - 1) >= 0 and round_x(y + 1) < height and
         data[round_x(x-1), round_y(y+1), 2] != Ex_Field_Tile::ID[index]
        case auto_tile_id
        when 0  ; auto_tile_id = 8
        when 1  ; auto_tile_id = 9
        when 2  ; auto_tile_id = 10
        when 3  ; auto_tile_id = 11
        when 20 ; auto_tile_id = 22
        when 24 ; auto_tile_id = 25
        when 26 ; auto_tile_id = 27
        when 36 ; auto_tile_id = 37
        end
      end
      if round_x(x + 1) < width and round_x(y + 1) < height and
         data[round_x(x+1), round_y(y+1), 2] != Ex_Field_Tile::ID[index]
        case auto_tile_id
        when 0  ; auto_tile_id = 4
        when 1  ; auto_tile_id = 5
        when 2  ; auto_tile_id = 6
        when 3  ; auto_tile_id = 7
        when 8  ; auto_tile_id = 12
        when 9  ; auto_tile_id = 13
        when 10 ; auto_tile_id = 14
        when 11 ; auto_tile_id = 15
        when 16 ; auto_tile_id = 18
        when 17 ; auto_tile_id = 19
        when 20 ; auto_tile_id = 21
        when 22 ; auto_tile_id = 23
        when 34 ; auto_tile_id = 35
        end
      end
      return auto_tile_id
    end

    # // 1568 Floor
    # // 5936 Ceiling
    # // 6320 Wall
    def correct_autotile(data, x, y, z)
      ceil = 5936
      flor = 1568
      wall = 6320
      wallr= 6320...6320+4
      ceilr= 5936...5936+4

      if data[x, y, z] == flor
        if (ceilr).include?(data[x, y-2, z])
          data[x, y-1, z] = wall if (ceilr).include?(data[x, y-1, z])
        end
        if (ceilr.to_a + wallr.to_a).include?(data[x, y+1, z])
          if [flor].include?(data[x, y+2, z])
            data[x, y+1, z] = flor
          end
        end
        if (ceilr.to_a + wallr.to_a).include?(data[x, y-1, z])
          if [flor].include?(data[x, y-2, z])
            data[x, y-1, z] = flor
          end
        end
      end
    end

  end

end

class Game_Character

  attr_accessor :dungeon_obj

  def setup_dungeon()
    @dungeon_obj = ::ISS::Dungeon::ObjectHandler.new(self)
  end

  def iss_posarray() ; return [self.x, self.y] end
  def pos_array()    ; return iss_posarray() end

  alias iss006_gc_update update unless $@
  def update()
    iss006_gc_update()
    @dungeon_obj.update() unless @dungeon_obj.nil?()
  end

end

class Scene_Map < Scene_Base

  alias iss006_scmp_update update unless $@
  def update()
    unless $tile_markers[0].nil?
      d = $tile_markers[0]
      if $game_map.data[d[0], d[1], 0] == 1568
        $game_map.data[d[0], d[1], 1] = 0
        $tile_markers.shift
      end
    end
    iss006_scmp_update()
    if Input.trigger?(Input::NUMBERS[1])
      x, y = *$game_player.get_xy_infront(1, 0)
      $tile_markers << [x, y, false, 0]
      $game_map.data[x, y, 1] = 1537
    elsif Input.trigger?(Input::NUMBERS[2])
      coords = []
      coords.push [ 1,  0], [ 1,  1], [ 1, -1]
      coords.push [ 2,  0], [ 2,  1], [ 2, -1]
      coords.push [ 3,  0], [ 3,  1], [ 3, -1]
      coords.each { |arr|
        x, y = *arr
        xi, yi = *$game_player.get_xy_infront(x, y)
        $tile_markers << [xi, yi, false, 0]
        $game_map.data[xi, yi, 1] = 1537 }
    elsif Input.trigger?(Input::LETTERS['M'])
      $game_map.events[1].start
    end
  end

end
