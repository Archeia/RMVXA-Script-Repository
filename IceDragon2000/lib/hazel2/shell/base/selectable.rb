require_relative 'window'

module Hazel
  class Shell::WindowSelectable < Shell::Window
    include Shell::Addons::SelectableBase
    include Shell::Addons::CursorBase
    include Mixin::MouseSelectable
    include Mixin::SmoothCursor

    alias :update_cursor :smooth_update_cursor # overwrite original

    def initialize(*args, &block)
      super(*args, &block)
      init_smooth_cursor
      select(-1)
    end

    def update
      super
      update_smooth_cursor
    end

    add_callback_hook :index=
  end
end
