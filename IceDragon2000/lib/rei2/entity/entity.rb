#
# EDOS/src/REI/entity/entity.rb
#
module REI
  class Entity

    @@entity_id = 0

    include Ygg4::EntityBase

    attr_accessor :type
    attr_reader :id

    def initialize(&block)
      init_entity(&block)
      @id = @@entity_id += 1
    end

    def add_component(obj)
      obj = REI::Mixin::REIComponent[obj] if obj.is_a?(Symbol)
      super(obj)
    end

    def remove_component(obj)
      obj = REI::Mixin::REIComponent[obj] if obj.is_a?(Symbol)
      super(obj)
    end

    def update
      update_components
    end

  end
end
