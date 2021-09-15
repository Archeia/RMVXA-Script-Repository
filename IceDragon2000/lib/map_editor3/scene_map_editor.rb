# TODO:
#   Preview the tile_palette values
#   Allow hard copy and draw (draw without casuing an autotile remap)
#   Add tools.
module MapEditor3
  class SceneMapEditor < Scene_Base
    def start
      super
      @keyboard = Win32::Keyboard.new
      optz = MapDataOptimizer.new
      optz.run $game_map.data

      @background = Sprite.new
      @background.bitmap = Bitmap.new(Graphics.width, 32)
      @background.bitmap.fill Color.new(255, 255, 255, 96)
      @editor = Editor.new
      @editor.map = $game_map
      @editor.player = $game_player
      @editor.refresh
      @editor.cursor.moveto $game_player.x, $game_player.y
      @map_cursor_controller = Game_CharacterController.new
      @map_cursor_controller.character = @editor.cursor
      @display = Rect.new(32 * 8, 32, Graphics.width, Graphics.height - 32)
      @editor.map.display = @display
      create_gui_viewport
      create_spriteset
      create_all_windows

      # underlying cameras need not be updated, as the parent cam will take
      # care of the tracking instead.
      @player_camera = Game_CharacterCamera.new $game_player
      @cursor_camera = Game_CharacterCamera.new @editor.cursor
      @camera = Game_FollowCamera.new @cursor_camera
      @camera.display = @display
      @camera.view = $game_map
      @camera.center_on_client

      @editor.cursor.on_move = method(:on_cursor_move)

      hide_tile_selector
      on_cursor_move
    end

    def on_cursor_move
      @info_window.on_cursor_move
      @spriteset.on_cursor_move
    end

    def set_tile_palette
      @editor.tile_palette.tile = @tile_selector.tile_id
    end

    def set_tile_palette_alt
      @editor.tile_palette.tile_alt = @tile_selector.tile_id
    end

    def refresh_map_viewports
      [@spriteset.viewport1, @spriteset.viewport2, @spriteset.viewport3].each do |v|
        v.rect.set(@display)
      end
      @tile_selector.x = @display.x - 32 * 8
    end

    def show_tile_selector
      @map_cursor_controller.deactivate
      @tile_selector.controller.activate
      @tile_selector.show
      @display.set(32 * 8, 32, Graphics.width - 32 * 8, Graphics.height - 32)
      refresh_map_viewports
    end

    def hide_tile_selector
      @tile_selector.controller.deactivate
      @map_cursor_controller.activate
      @tile_selector.hide
      @display.set(0, 32, Graphics.width, Graphics.height - 32)
      refresh_map_viewports
    end

    def create_gui_viewport
      @gui_viewport = Viewport.new
      @gui_viewport.z = 1000
      @gui_viewport.tag 'gui'
    end

    def create_spriteset
      @spriteset = Spriteset_MapEditor.new(@editor)
      @spriteset.highlight_characters
    end

    def create_message_window
      @message_window = Window_Message.new
    end

    def create_info_window
      @info_window = Window_EditorInfo.new(@editor, @gui_viewport)
    end

    def create_tile_selector
      @tile_selector = TileSelector.new
      @tile_selector.bitmaps = @spriteset.tilemap.bitmaps
      @tile_selector.flags = @spriteset.tilemap.flags
      @tile_selector.page = 0
      @tile_selector.y = 32
    end

    def create_all_windows
      create_message_window
      create_info_window
      create_tile_selector
    end

    def dispose_background
      @background.dispose_bitmap
      @background.dispose
    end

    def dispose_gui_viewport
      @gui_viewport.dispose
    end

    def dispose_spriteset
      @spriteset.dispose
    end

    def terminate
      super
      dispose_background
      @info_window.dispose
      @tile_selector.dispose
      dispose_spriteset
      dispose_gui_viewport
    end

    def update_basic
      super
      @keyboard.update
    end

    def update_gui
      @info_window.update
      @tile_selector.update
    end

    def update_graphics
      @spriteset.update
      update_gui
    end

    def update
      super
      return return_scene if @keyboard.press?(:F10)
      @map_cursor_controller.update
      @editor.update true
      @camera.update
      $game_timer.update
      update_graphics
      if @map_cursor_controller.active?
        if Input.trigger?(:A)
          show_tile_selector
        # draw
        elsif Input.trigger?(:X)
          @editor.write_current_tile
        # erase
        elsif Input.trigger?(:Y)
          @editor.erase_current_tile
        # copy
        elsif Input.trigger?(:Z)
          @editor.copy_current_tile
        # swap palette
        elsif Input.trigger?(:B)
          @editor.swap_palette
        end
      elsif @tile_selector.controller.active?
        if Input.trigger?(:A)
          hide_tile_selector
        elsif Input.trigger?(:Y)
          set_tile_palette_alt
        elsif Input.trigger?(:X)
          set_tile_palette
        end
      end
    end
  end
end
