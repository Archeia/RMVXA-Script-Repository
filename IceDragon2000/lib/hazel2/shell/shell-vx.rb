#
# EDOS/lib/hazel2/shell/shell-vx.rb
#   by IceDragon
# These are addons to the standard shell class for emulating RMVX/A like
# attributes
module Hazel
  class Shell

    attr_accessor :openness
    attr_accessor :viewport
    attr_accessor :padding
    attr_accessor :padding_bottom

    alias :no_vxa_initialize :initialize
    def initialize(*args, &block)
      @viewport = nil
      @openness = 255
      @padding = 0
      @padding_bottom = 0
      no_vxa_initialize(*args, &block)
    end

    def openness=(n)
      @openness = [[n, 0].max, 255].min.to_i
    end

  end
end