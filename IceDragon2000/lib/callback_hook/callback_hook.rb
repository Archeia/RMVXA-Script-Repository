#
# EDOS/lib/mixin/callback_hook.rb
#   by IceDragon (mistdragon100@gmail.com)
#   dc ??/??/2013
#   dm 15/06/2013
# vr 1.1.0
#   CHANGELOG
#     vr 1.1.0
#       CallbackHook will now auto-include MACL::Mixin::Callback
#
#   Extension for Shell and Window, allows you to add callbacks to predefined
#   methods
#   All callbacks will pass the instance of the object as the first argument
#   followed by the parameters that where passed to the method and a block
#   if available
#   -> { |win, *args, &block| do_somthing }
#   USAGE:
#     class MyShell < Shell::Window
#
#        include Mixin::CallbackHook
#
#        add_callback_hook(:index=)
#
#        def initialize(*args)
#          super(*args)
#          add_callback(:index=) { |win, *a, &b| "when index= is called" }
#        end
#
#     end
$simport.r 'callback_hook', '1.0.0', 'Mixin for hooking methods'

module Mixin # :nodoc:
  module CallbackHook
    include MACL::Mixin::Callback

    module ClassMethods
      ##
      # ::add_callback_hook(Symbol sym)
      def add_callback_hook(sym)
        meth = instance_method(sym)
        define_method(sym) do |*args, &block|
          r = meth.bind(self).(*args, &block)
          try_callback(sym, self, *args, &block)
          r
        end
      end
    end

    ##
    # ::included(Module* mod)
    def self.included(mod)
      mod.extend ClassMethods
    end
  end
end
