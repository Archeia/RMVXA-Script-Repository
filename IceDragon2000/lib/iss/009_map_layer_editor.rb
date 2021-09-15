#encoding:UTF-8
# ISS009 - Map Layer Editor
# // 05/10/2011
# // 05/13/2011
module ISS

  class Game_MapLayerEditor

    attr_accessor :passages

    def initialize
      @data_layer = []
      @used_layer = 0
      @data_layer[0] = Table.new(1, 1, 1)
      @data_layer[1] = Table.new(1, 1, 1)
      @data_layer[2] = Table.new(1, 1, 1)
    end

    def reset_data
      @passages = $game_map.passages.clone
      @data_layer[0] = Table.new($game_map.data.xsize, $game_map.data.ysize, $game_map.data.zsize)
      @data_layer[1] = Table.new($game_map.data.xsize, $game_map.data.ysize, $game_map.data.zsize)
      @data_layer[2] = Table.new($game_map.data.xsize, $game_map.data.ysize, $game_map.data.zsize)
      for x in 0...$game_map.data.xsize
        for y in 0...$game_map.data.ysize
          @data_layer[0][x, y, @used_layer] = $game_map.data[x, y, 0]
          @data_layer[1][x, y, @used_layer] = $game_map.data[x, y, 1]
          @data_layer[2][x, y, @used_layer] = $game_map.data[x, y, 2]
        end
      end
    end

    def burn_data(n1, n2)
      for x in 0...$game_map.data.xsize
        for y in 0...$game_map.data.ysize
          if @data_layer[n1][x, y, @used_layer] > 0 and @data_layer[n2][x, y, @used_layer] > 0
            @data_layer[n1][x, y, @used_layer] = 0
          end
        end
      end
    end

    def migrate_data(n1, n2)
      for x in 0...$game_map.data.xsize
        for y in 0...$game_map.data.ysize
          if @data_layer[n1][x, y, @used_layer] == 0 and @data_layer[n2][x, y, @used_layer] > 0
            @data_layer[n1][x, y, @used_layer] = @data_layer[n2][x, y, @used_layer]
            @data_layer[n2][x, y, @used_layer] = 0
          end
        end
      end
    end

    def decimate_passage(n)
      @passages.xsize.times { |i| @passages[i] = n }
    end

    def get_data(n)
      return @data_layer[n]
    end

  end

  class Spriteset_MultiLayerMap < Spriteset_Map

    attr_accessor :viewport1
    attr_accessor :viewport2
    attr_accessor :viewport3
    attr_accessor :viewport4
    attr_accessor :tilemaps
    #--------------------------------------------------------------------------
    # * Object Initialization
    #--------------------------------------------------------------------------
    def initialize
      create_viewports
      create_tilemap
      create_characters
      @dedug_sprites = []
      @dedug_sprites
      update
    end

    def dispose
      dispose_characters
      dispose_tilemaps
      dispose_viewports
    end

    def dispose_viewports
      @viewport1.dispose
      @viewport2.dispose
      @viewport3.dispose
      @viewport4.dispose
    end

    def dispose_tilemaps
      @tilemaps.each { |t| t.dispose }
      @tilemaps.clear
    end
    #--------------------------------------------------------------------------
    # * Create Character Sprite
    #--------------------------------------------------------------------------
    def create_characters
      @character_sprites = []
      for i in $game_map.events.keys.sort
        sprite = Sprite_Character.new(@viewport4, $game_map.events[i])
        @character_sprites.push(sprite)
      end
      for vehicle in $game_map.vehicles
        sprite = Sprite_Character.new(@viewport4, vehicle)
        @character_sprites.push(sprite)
      end
      @character_sprites.push(Sprite_Character.new(@viewport4, $game_player))
    end
    #--------------------------------------------------------------------------
    # * Create Viewport
    #--------------------------------------------------------------------------
    def create_viewports
      @viewport1 = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport2 = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport3 = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport4 = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport1.z = 0
      @viewport2.z = 1
      @viewport3.z = 2
      @viewport4.z = 5
    end

    def clone_tilemap(tilemap)
      t = Tilemap.new(tilemap.viewport)
      t.bitmaps[0] = tilemap.bitmaps[0]
      t.bitmaps[1] = tilemap.bitmaps[1]
      t.bitmaps[2] = tilemap.bitmaps[2]
      t.bitmaps[3] = tilemap.bitmaps[3]
      t.bitmaps[4] = tilemap.bitmaps[4]
      t.bitmaps[5] = tilemap.bitmaps[5]
      t.bitmaps[6] = tilemap.bitmaps[6]
      t.bitmaps[7] = tilemap.bitmaps[7]
      t.bitmaps[8] = tilemap.bitmaps[8]
      t.map_data = tilemap.map_data
      t.passages = tilemap.passages
      return t
    end

    #--------------------------------------------------------------------------
    # * Create Tilemap
    #--------------------------------------------------------------------------
    def create_tilemap
      super()
      @tilemaps = []
      t1 = clone_tilemap(@tilemap)
      t1.viewport = @viewport1
      t1.map_data = $game_mapLayerEditor.get_data(0)
      @tilemaps << t1
      t2 = clone_tilemap(@tilemap)
      t2.viewport = @viewport2
      t2.map_data = $game_mapLayerEditor.get_data(1)
      @tilemaps << t2
      t3 = clone_tilemap(@tilemap)
      t3.viewport = @viewport3
      t3.map_data = $game_mapLayerEditor.get_data(2)
      @tilemaps << t3
      @tilemaps.each { |t| t.passages = $game_mapLayerEditor.passages }
      @tilemap.dispose
      @tilemap = nil
    end

    def hide_layer(com)
      case com
      when 0 ; @viewport1.visible = !@viewport1.visible
      when 1 ; @viewport2.visible = !@viewport2.visible
      when 2 ; @viewport3.visible = !@viewport3.visible
      when :all
        3.times { |i| hide_layer(i) }
      end
    end

    def update
      @character_sprites.each { |c| c.update }
      @tilemaps.each { |t|
        t.ox = $game_map.display_x / 8
        t.oy = $game_map.display_y / 8
        t.update
      }
      @viewport1.update
      @viewport2.update
      @viewport3.update
      @viewport4.update
    end

  end

end

$game_mapLayerEditor = ISS::Game_MapLayerEditor.new

class Scene_MapLayerEditor < Scene_Map

  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    $game_map.refresh
    $game_mapLayerEditor.reset_data
    @spriteset.dispose
    @spriteset = ISS::Spriteset_MultiLayerMap.new
    #@message_window = Window_Message.new
  end

  def update
    #super
    $game_map.interpreter.update      # Update interpreter
    $game_map.update                  # Update map
    $game_player.update               # Update player
    $game_system.update               # Update timer
    @spriteset.update                 # Update sprite set
    @message_window.update            # Update message window
    unless $game_message.visible      # Unless displaying a message
      update_transfer_player
      update_encounter
      update_call_menu
      update_call_debug
      update_scene_change
    end
    if Input.trigger?(Input::NUMBERS[1])
      Sound.play_cursor
      @spriteset.hide_layer(0)
    elsif Input.trigger?(Input::NUMBERS[2])
      Sound.play_cursor
      @spriteset.hide_layer(1)
    elsif Input.trigger?(Input::NUMBERS[3])
      Sound.play_cursor
      @spriteset.hide_layer(2)
    elsif Input.trigger?(Input::NUMBERS[4])
      Sound.play_cursor
      @spriteset.hide_layer(:all)
    elsif Input.trigger?(Input::LETTERS['B'])
      Sound.play_enemy_collapse
      $game_mapLayerEditor.burn_data(0, 1)
    elsif Input.trigger?(Input::LETTERS['N'])
      Sound.play_actor_collapse
      $game_mapLayerEditor.decimate_passage(0)
    elsif Input.trigger?(Input::LETTERS['M'])
      Sound.play_use_skill
      $game_mapLayerEditor.migrate_data(0, 1)
    end
  end

end
