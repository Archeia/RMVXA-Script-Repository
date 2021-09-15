#
# src/hazel/onyx/spriteset_component.rb
#   by IceDragon
# vr 0.1
class Hazel::Onyx::Spriteset_Components

  attr_reader :components

  def initialize(components)
    @components = components
    @onyx_components = []
  end

  def dispose
    dispose_onyx_components
  end

  def dispose_onyx_components
    @onyx_components.each(&:dispose)
    @onyx_components.clear
  end

  def update
    for comp in @onyx_components
      comp.update
    end
  end

  def refresh
    dispose_onyx_components

    registry = Hazel::Onyx::ComponentRegistry
    @components.each do |component|
      onyx_klass = registry.get_onyx_component(component.class)
      @onyx_components.push(onyx_klass.new(component))
    end

    return self
  end

end