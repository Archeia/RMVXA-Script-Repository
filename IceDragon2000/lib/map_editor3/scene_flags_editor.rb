module MapEditor3
  class SceneFlagsEditor < Scene_Base
    def start
      super
      @keyboard = Win32::Keyboard.new
      @tileset = $data_tilesets[2]
      create_all_windows
    end

    def create_tile_flag_editor
      @tile_flag_editor = TileFlagEditor.new
      @tile_flag_editor.bitmaps = @tileset.tileset_names.map { |s| Cache.tileset(s) }
      @tile_flag_editor.flags = @tileset.flags
      @tile_flag_editor.page = 0
      @tile_flag_editor.y = 0
      @tile_flag_editor.viewport.rect.height = Graphics.height
      @tile_flag_editor.controller.activate
    end

    def create_all_windows
      create_tile_flag_editor
    end

    def dispose_tile_flag_editor
      @tile_flag_editor.dispose
    end

    def terminate
      dispose_tile_flag_editor
      super
    end

    def update_tile_flag_editor
      @tile_flag_editor.update
    end

    def update_basic
      super
      @keyboard.update
    end

    def update
      super
      return return_scene if @keyboard.press?(:F10)
      update_tile_flag_editor
    end
  end
end
