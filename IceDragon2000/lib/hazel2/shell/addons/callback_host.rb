#
# EDOS/lib/shell/addons/callbackhost.rb
#   by IceDragon
#   dc 24/03/2013
#   dm 24/03/2013
# vr 1.0.0
module Hazel
  class Shell
    module Addons
      class CallbackHost
        include MACL::Mixin::Callback
       private
        def initialize
          init_callbacks
        end
       public
        alias :clear   :clear_callbacks
        alias :dispose :dispose_callbacks
        alias :add     :add_callback
        alias :remove  :remove_callback
        alias :try     :try_callback
        alias :call    :call_callback
        public :clear, :dispose, :add, :remove, :try, :call
      end
    end
  end
end
