#
# EDOS/src/hazel/mixin/mouse_event.rb
# vr 1.1.0
module Hazel::Mixin
  module MouseEvent

    def init_mouse_event
      @hover_frame_count = 0
      @hover_frame_cap = 45 # How long does it take to consider a mouse hover
    end

    def handle_mouse_event
      if pos_in_area?(Mouse.x, Mouse.y)
        on_event(:mouse_over)
        if Mouse.left_click?      then on_event(:mouse_left_click)
        elsif Mouse.right_click?  then on_event(:mouse_right_click)
        elsif Mouse.middle_click? then on_event(:mouse_middle_click)
        end
        on_event(:mouse_start_over) if @hover_frame_count == 0
        if @hover_frame_count >= @hover_frame_cap
          on_event(:mouse_start_hover) if @hover_frame_count == @hover_frame_cap
          on_event(:mouse_hover)
        end
        @hover_frame_count += 1
      else
        if @hover_frame_count > 0
          on_event(:mouse_stop_over)
          on_event(:mouse_stop_hover) if @hover_frame_count >= @hover_frame_cap
          @hover_frame_count = 0
        end
        on_event(:mouse_not_over)
      end
    end

    def hover?
      return @hover_frame_count >= @hover_frame_cap
    end

    def self.included(mod)
      [:mouse_left_click, :mouse_right_click, :mouse_middle_click,
       :mouse_start_over, :mouse_start_hover, :mouse_stop_over, :mouse_stop_hover,
       :mouse_hover, :mouse_not_over, :mouse_over].each do |sym|
        mod.register_event(sym)
      end
    end

  end
end