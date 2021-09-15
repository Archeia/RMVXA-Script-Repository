#
# EDOS/lib/mixin/visibility.rb
#   by IceDragon
#   dc 19/06/2013
#   dm 19/06/2013
# vr 1.0.0
#   Convience methods for using #visible=
module Mixin
  module Visibility
    def visible?
      !!self.visible
    end

    ##
    # show -> self
    def show
      self.visible = true
      self
    end

    ##
    # hide -> self
    def hide
      self.visible = false
      self
    end

    def toggle_visible
      self.visible = !visible
      self
    end
  end
end
