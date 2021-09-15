#
# EDOS/lib/shell/addons/registry.rb
#   by IceDragon
#   dc 24/03/2013
#   dm 24/03/2013
# vr 1.0.0
module Hazel
  class Shell
    module Addons
      class Registry

        class RegistryError < RuntimeError
        end

        def initialize
          @registered = {}
        end

        def unregister(name)
          raise(RegistryError,
                "This name(#{name}) was not registered"
                ) unless registered?(name)
          @registered.delete(name)
          self
        end

        def register(name, meta={})
          raise(RegistryError,
                "This name(#{name}) has already been registered"
                ) if registered?(name)
          @registered[name] = meta
          self
        end

        def registered?(name)
          @registered.include?(name)
        end

      end
    end
  end
end
