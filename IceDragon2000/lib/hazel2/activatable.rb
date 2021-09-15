#
# EDOS/lib/mixin/activatable.rb
#   by IceDragon
module Mixin
  module Activatable
    attr_accessor :active

    def active?
      active
    end

    def activate
      self.active = true
      self
    end

    def deactivate
      self.active = false
      self
    end

    def toggle_active
      self.active = !active
      self
    end
  end
end
