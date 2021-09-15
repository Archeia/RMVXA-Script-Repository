#
# EDOS/lib/shell/decorations/decoration.rb
#   by IceDragon
#   dc 27/06/2013
#   dm 28/06/2013
# vr 1.0.0
module Hazel
  class Shell
    module Decoration
      class DecorationBase

        include Mixin::SpaceBoxBody

        ### instance_attributes
        attr_accessor :parent # Object parent

        ##
        # initialize(Shell parent)
        def initialize(parent)
          @parent = parent
          @rel_x = 0
          @rel_y = 0
          @rel_z = 0
          @ticks = 0
          init
        end

        ##
        # init
        def init
          #
        end

        ##
        # disposed?
        def disposed?
          !!@disposed
        end

        ##
        # dispose
        def dispose
          @disposed = true
        end

        ##
        # update
        def update
          @ticks += 1
        end

        ##
        # ::register
        def self.register(name)
          Hazel::Shell::Decoration.register_decoration(name, self)
        end

      end
    end
  end
end