#
# EDOS/src/levias/module/mapmanager.rb
#   by IceDragon
#   dc 30/03/2013
#   dm 30/03/2013
# vr 1.0.0
module Levias
  module MapManager

    extend MACL::Mixin::Callback

    class << self
      attr_accessor :state
    end

    def self.setup
      @state = :move
      init_callbacks
    end

    def self.toggle_state
      @state = @state == :move ? :look : :move
      try_callback(:state_changed)
    end

  end
end
