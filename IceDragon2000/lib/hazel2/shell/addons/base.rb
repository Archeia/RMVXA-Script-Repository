#
# EDOS/lib/shell/addons/base.rb
# vr 2.0.0
module Hazel
  class Shell
    module Addons
      module Base
       private
        def init_shell_addons
          @shell_register = Hazel::Shell::Addons::Registry.new
        end

        def dispose_shell_addons
          #
        end

        def update_shell_addons
          #
        end
      end
    end
  end
end
