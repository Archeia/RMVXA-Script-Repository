#
# EDOS/src/REI/component/motion.rb
#
module REI
  module Component
    class Motion

      UP    = Vector3( 0,  0,  1).freeze
      DOWN  = Vector3( 0,  0, -1).freeze
      NORTH = Vector3( 0, -1,  0).freeze
      SOUTH = Vector3( 0,  1,  0).freeze
      EAST  = Vector3( 1,  0,  0).freeze
      WEST  = Vector3(-1,  0,  0).freeze

      extend REI::Mixin::REIComponent
      include Ygg4::Component

      def initialize
        init_component
        @_last_pos_ = Vector3(0, 0, 0)
      end

      def on_move
        if evs = comp(:event_server)
          if @_last_pos_ != (pos = comp(:position))
            evs.add(:motion, :move, pos.dup, @_last_pos_) # to, from
            @_last_pos_ = pos.dup
          end
        end
      end

      ##
      # move_straight(Numeric step, Vector3f d)
      def move_straight(step, x)
        comp(:position).add!(x * step)
        on_move
      end

      ##
      # move_up(Numeric step)
      def move_up(step)
        move_straight(step, UP)
      end

      ##
      # move_down(Numeric step)
      def move_down(step)
        move_straight(step, DOWN)
      end

      ##
      # move_north(Numeric step)
      def move_north(step)
        move_straight(step, NORTH)
      end

      ##
      # move_south(Numeric step)
      def move_south(step)
        move_straight(step, SOUTH)
      end

      ##
      # move_east(Numeric step)
      def move_east(step)
        move_straight(step, EAST)
      end

      ##
      # move_west(Numeric step)
      def move_west(step)
        move_straight(step, WEST)
      end

      ##
      # move_north_east(Numeric step)
      def move_north_east(step)
        move_straight(step, NORTH + EAST)
      end

      ##
      # move_north_west(Numeric step)
      def move_north_west(step)
        move_straight(step, NORTH + WEST)
      end

      ##
      # move_south_east(Numeric step)
      def move_south_east(step)
        move_straight(step, SOUTH + EAST)
      end

      ##
      # move_south_west(Numeric step)
      def move_south_west(step)
        move_straight(step, SOUTH + WEST)
      end

      def move_straight_dir(dir, step)
        case dir
        when 1 then move_south_west(step)
        when 2 then move_south(step)
        when 3 then move_south_east(step)
        when 4 then move_west(step)
        when 6 then move_east(step)
        when 7 then move_north_west(step)
        when 8 then move_north(step)
        when 9 then move_north_east(step)
        end
      end

      dep :position
      opt :event_server
      rei_register :motion

    end
  end
end