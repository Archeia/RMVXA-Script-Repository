#
# EDOS/lib/shell/addons/handler_base.rb
#   by IceDragon
#   dc 24/03/2013
#   dm 24/03/2013
# vr 2.0.0
module Hazel
  module Shell::Addons::HandlerBase

    def init_shell_addons
      super
      init_handler
    end

    def init_handler
      @shell_register.register("Handler", version: "2.1.0".freeze)

      @handler = {}
      return self
    end

    def set_handler(symbol, meth=nil, &func)
      @handler[symbol] = meth || func
      return self
    end

    def remove_handler(symbol)
      return @handler.delete(symbol)
    end

    def handle?(symbol)
      return @handler.has_key?(symbol)
    end

    def call_handler(symbol)
      @handler[symbol].() if handle?(symbol)
    end

  end
end