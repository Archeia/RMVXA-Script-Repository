#
# EDOS/lib/shell/decorations.rb
#   by IceDragon
#   dc 27/06/2013
#   dm 27/06/2013
# vr 1.0.0
module Hazel
  class Shell
    module Decoration

      VERSION = "1.0.0".freeze

      @decoration_klasses = {}

      def self.get_decoration(obj)
        if obj.is_a?(Symbol) || obj.is_a?(String)
          return @decoration_klasses[obj.to_sym]
        else
          return obj
        end
      end

      def self.register_decoration(name, obj)
        @decoration_klasses[name] = obj
      end

    end
  end
end

require_relative "decorations/decoration_base"
require_relative "decorations/host_base"
require_relative "decorations/title"
require_relative "decorations/scroll_bar"