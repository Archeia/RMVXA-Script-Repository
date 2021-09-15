#
# EDOS/src/levias/spriteset/ui.rb
#   by IceDragon
#   dc 30/03/2013
#   dm 30/03/2013
# vr 1.0.0
module Levias
  class Scene
    class Map < Scene

      def start
        super
        MapManager.setup
        MapManager.add_callback(:state_changed, &method(:on_state_change))

        @spriteset = Levias::Spriteset::Map.new
        @spriteset_ui = Levias::Spriteset::UI.new
      end

      def terminate
        @spriteset.dispose
        @spriteset_ui.dispose
        super
      end

      def update
        super
        @spriteset_ui.update
        if Input.trigger?(:A)
          MapManager.toggle_state
        end
      end

      def on_state_change
        @spriteset_ui.refresh
      end

    end
  end
end
