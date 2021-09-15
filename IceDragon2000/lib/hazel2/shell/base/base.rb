#
# EDOS/lib/shell/base.rb
#   by IceDragon
# vr 2.0.0
module Hazel
  class Shell::Base < Hazel::Shell

    include MACL::Mixin::Surface2Bang
    include Mixin::Ajar
    include Mixin::Visibility
    include Mixin::Activatable
    include Mixin::Automatable
    include Mixin::WindowClient
    include Hazel::Shell::Addons::Base
    include Hazel::Shell::Decoration::HostBase
    include Hazel::Widget::HostBase

    attr_reader :shell_callback

    def init_internal
      super
      @shell_callback = Hazel::Shell::Addons::CallbackHost.new
      self.padding = standard_padding
      init_automations  # Automatable
      init_shell_addons # Shell::Addons
      init_decorations  # Shell::Decoration::HostBase
      init_widgets      # Hazel::Widget::HostBase
    end

    def post_init
      super
      @shell_callback.add(:update_position) do
        [:x=, :y=, :z=].each do |sym|
          @shell_callback.try(sym)
        end
      end
      @shell_callback.add(:update_all) do
        [:padding=, :width=, :height=,
         :x=, :y=, :z=, :on_move, :on_set,
         :ox=, :oy=, :opacity=, :viewport=,
         :openness=, :active=, :visible=].each do |sym|
          @shell_callback.try(sym)
        end
      end
      @shell_callback.add(:refresh_all) do
        _redraw!
      end
      @shell_callback.(:refresh_all)
    end

    def dispose
      dispose_automations
      dispose_shell_addons
      dispose_decorations
      dispose_widgets
      super
    end

    def update
      super
      update_automations
      update_shell_addons
      update_decorations
      update_widgets
    end

    def handle_event(event)
      widgets_handle_event(event)
    end

    def standard_padding
      Metric.padding
    end

    # // Window Addon Win Busy method patch :D
    def win_busy?
      automating?
    end unless method_defined?(:win_busy?)

    def mouse_in_window?
      Mouse.in_area?(self.to_rect)
    end

    def line_height
      24
    end

    def fitting_height(line_number)
      line_number * line_height + standard_padding * 2
    end

    ### callbacks
    ##
    # ox=(int new_ox)
    def ox=(new_ox)
      super(new_ox)
      @shell_callback.try(:ox=)
      @shell_callback.try(:offset=) # sub callback
    end

    ##
    # oy=(int new_oy)
    def oy=(new_oy)
      super(new_oy)
      @shell_callback.try(:oy=)
      @shell_callback.try(:offset=) # sub callback
    end

    ##
    # x=(int new_x)
    def x=(new_x)
      super(new_x)
      @shell_callback.try(:x=)
      @shell_callback.try(:pos=) # sub callback
    end

    ##
    # y=(int new_y)
    def y=(new_y)
      super(new_y)
      @shell_callback.try(:y=)
      @shell_callback.try(:pos=) # sub callback
    end

    ##
    # z=(int new_z)
    def z=(new_z)
      super(new_z)
      @shell_callback.try(:z=)
      @shell_callback.try(:pos=) # sub callback
    end

    ##
    # width=(int new_width)
    def width=(new_width)
      super(new_width)
      @shell_callback.try(:width=)
      @shell_callback.try(:size=) # sub callback
    end

    ##
    # height=(int new_height)
    def height=(new_height)
      super(new_height)
      @shell_callback.try(:height=)
      @shell_callback.try(:size=) # sub callback
    end

    ##
    # depth=(int new_depth)
    def depth=(new_depth)
      super(new_depth)
      @shell_callback.try(:depth=)
      @shell_callback.try(:size=)
    end

    ##
    # viewport=(Viewport new_viewport)
    def viewport=(new_viewport)
      super(new_viewport)
      @shell_callback.try(:viewport=)
    end

    ##
    # opacity=(int new_opacity)
    def opacity=(new_opacity)
      super(new_opacity)
      @shell_callback.try(:opacity=)
    end

    ##
    # openness=(int new_openness)
    def openness=(new_openness)
      super(new_openness)
      @shell_callback.try(:openness=)
    end

    ##
    # visible=(bool new_visible)
    def visible=(new_visible)
      super(new_visible)
      @shell_callback.try(:visible=)
    end

    ##
    # active=(bool new_active)
    def active=(new_active)
      super(new_active)
      @shell_callback.try(:active=)
    end

    ##
    # padding=(int new_padding)
    def padding=(new_padding)
      super(new_padding)
      @shell_callback.try(:padding=)
    end

    ##
    # set(*args, &block)
    def set(*args, &block)
      res = super(*args, &block)
      @shell_callback.try(:on_set)
      return res
    end

    ##
    # move(*args, &block)
    def move(*args, &block)
      res = super(*args, &block)
      @shell_callback.try(:on_move)
      return res
    end

    ##
    # _redraw(*args, &block)
    def _redraw
      @shell_callback.try(:redraw)
    end

    ##
    # _redraw!(*args, &block)
    def _redraw!
      @shell_callback.try(:pre_redraw)
      _redraw
      @shell_callback.try(:update_all)
      @shell_callback.try(:post_redraw)
    end

  end
end