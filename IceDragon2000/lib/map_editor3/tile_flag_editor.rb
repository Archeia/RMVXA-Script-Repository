module MapEditor3
  class TileFlagEditor < TileSelector
    class FlagEditController
      include Activatable

      attr_accessor :on_toggle_flag
      attr_accessor :on_set_flag
      attr_accessor :on_unset_flag

      def initialize
        @on_toggle_flag = nil
        @on_set_flag = nil
        @on_unset_flag = nil
      end

      def toggle_flag(flag)
        @on_toggle_flag.call(flag)
      end

      def set_flag(flag)
        @on_set_flag.call(flag)
      end

      def unset_flag(flag)
        @on_unset_flag.call(flag)
      end

      def toggle_left
        toggle_flag(TileData::Flags::LEFT)
      end

      def toggle_right
        toggle_flag(TileData::Flags::RIGHT)
      end

      def toggle_top
        toggle_flag(TileData::Flags::TOP)
      end

      def toggle_bottom
        toggle_flag(TileData::Flags::BOTTOM)
      end

      def toggle_dirs
        toggle_flag(TileData::Flags::DIRS)
      end

      def set_dirs(state)
        # DIRS are inverted, so to set, you unset them ;3
        state ? unset_flag(TileData::Flags::DIRS) : set_flag(TileData::Flags::DIRS)
      end

      def process_handlers
        toggle_left   if Input.press?(:ALT) && Input.trigger?(:LEFT)
        toggle_right  if Input.press?(:ALT) && Input.trigger?(:RIGHT)
        toggle_top    if Input.press?(:ALT) && Input.trigger?(:UP)
        toggle_bottom if Input.press?(:ALT) && Input.trigger?(:DOWN)
        if Input.trigger?(:Y)
          set_dirs(false)
        elsif Input.trigger?(:Z)
          set_dirs(true)
        elsif Input.trigger?(:X)
          toggle_dirs
        end
      end

      def update
        if @active
          process_handlers
        end
      end
    end

    class TileHelper
      include TileData::Helper
    end

    class FlagHelper
      def toggle(a, b)
        a ^ b
      end

      def set(a, b)
        a | b
      end

      def unset(a, b)
        (a | b) ^ b
      end
    end

    def on_flags_change
      super
      @flags_layer.flags = @flags
    end

    def on_page_change
      super
      @flags_layer.tile_data = @tile_data
    end

    def apply_tile_group(tile_id, flag)
      if @tile_helper.is_a_autotile?(tile_id)
        norm = @tile_helper.normalize_tile_id(tile_id)
        TileData::AUTOTILE_COUNT.times do |ai|
          @flags[tile_id + ai] = flag
        end
      else
        @flags[tile_id] = flag
      end
      on_flags_change
    end

    def toggle_flag(value)
      apply_tile_group(tile_id, @flag_helper.toggle(@flags[tile_id], value))
    end

    def set_flag(value)
      apply_tile_group(tile_id, @flag_helper.set(@flags[tile_id], value))
    end

    def unset_flag(value)
      apply_tile_group(tile_id, @flag_helper.unset(@flags[tile_id], value))
    end

    def create_flags_layer
      @flags_layer = Sprite_FlagsLayer.new(@viewport)
      @flags_layer.flags = @flags
      @flags_layer.z = 201
    end

    def create_flag_controller
      @flag_controller = FlagEditController.new
      @flag_controller.on_toggle_flag = method(:toggle_flag)
      @flag_controller.on_set_flag = method(:set_flag)
      @flag_controller.on_unset_flag = method(:unset_flag)
      @flag_controller.activate
    end

    def create_graphics
      super
      create_flags_layer
    end

    def create_all
      super
      @tile_helper = TileHelper.new
      @flag_helper = FlagHelper.new
      create_flag_controller
    end

    def dispose_flags_layer
      @flags_layer.dispose
    end

    def dispose_graphics
      dispose_flags_layer
      super
    end

    def process_ok
      if @controller.active?
        @controller.deactivate
        @flag_controller.activate
      else
        @flag_controller.deactivate
        @controller.activate
      end
    end

    def update_controller
      if Input.press?(:ALT)
        @controller.toggle(false) do
          @controller.update
        end
      else
        @controller.update
      end
      @flag_controller.update
    end
  end
end
