#
# EDOS/src/hazel/onyx/componentregistry.rb
#   by IceDragon
#   dm 03/04/2013
# vr 1.0.0
module Hazel::Onyx::ComponentRegistry

  def self.init
    @components = {}
  end

  def self.register(hazel_component, onyx_component)
    @components[hazel_component] = onyx_component
  end

  def self.get_onyx_component(hazel_component)
    unless @components.has_key?(hazel_component)
      raise(Hazel::Onyx::OnyxRegistryError,
        "unregistered component #{hazel_component}")
    end
    return @components[hazel_component]
  end

  class << self
    alias []= :register
    alias [] :get_onyx_component
  end

end