module Mixin
  module CursorState
    class Cursor
      attr_accessor :ticks
      attr_accessor :opacity
      attr_accessor :easer
      attr_accessor :style

      def initialize
        @ticks   = 0
        @aticks  = 0
        @opacity = 255
        @easer   = MACL::Easer.get_easer :sine_in
        @active_style   = 3
        @inactive_style = 0
        @athreshold  = 255
        @athresholdh = 96
        @ithreshold  = 96
        @ithresholdh = 64
      end

      def do_tick(active = true)
        frm_r = Graphics.frame_rate
        style  = active ? @active_style : @inactive_style
        thres  = active ? @athreshold   : @ithreshold
        thresh = active ? @athresholdh  : @ithresholdh
        case style
        when 0 # Solid
          @opacity = thres
        when 1 # Flicker
          @opacity = @ticks % (frm_r / 2) <= (frm_r / 4) ? thres : thresh
        when 2 # Pulse
          (n = thresh * (@ticks % (frm_r / 2)) / (frm_r.to_f / 2));@opacity = @ticks % frm_r < (frm_r / 2) ? (thresh + n) : (thres - n)
        when 3 # Eased
          @opacity = thresh + @easer.ease((@ticks % (frm_r * 2)).wall(frm_r).to_f, 0, thresh, frm_r.to_f)
        end
        @aticks += 1 if active
        @ticks += 1
      end
    end

    def init_cursor_state
      @_cursor = Cursor.new
    end

    def _update_cursor_state
      init_cursor_state unless @_cursor
      @_cursor.do_tick active
      @_cursor_ticks = @_cursor.ticks
      @_cursor_opacity = @_cursor.opacity
    end
  end
end
