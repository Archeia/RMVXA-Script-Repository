#
# EDOS/lib/shell/decorations/base.rb
#   by IceDragon
#   dc 27/06/2013
#   dm 27/06/2013
# vr 1.0.0
module Hazel
  class Shell
    module Decoration
      module HostBase

        ### mixins
        include Hazel::Shell::Addons::Base

        ##
        # init_decorations
        def init_decorations
          @decorations = []
          make_decorations
        end

        ##
        # make_decorations
        def make_decorations
          # add_decoration
        end

        ##
        # dispose_decorations
        def dispose_decorations
          @decorations.each(&:dispose)
          @decorations.clear
        end

        ##
        # update_decorations
        def update_decorations
          for obj in @decorations
            obj.update
          end
        end

        ##
        # add_decoration((Class* obj)* obj)
        def add_decoration(obj)
          klass = Hazel::Shell::Decoration.get_decoration(obj)
          obj = klass.new(self)
          @decorations.push(obj)
          return obj
        end

        ##
        # remove_decoration(Object* obj)
        def remove_decoration(obj)
          @decorations.delete(obj)
        end

      end
    end
  end
end