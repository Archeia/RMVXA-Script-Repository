module REI
  class EntitySystem

    attr_reader :entities

    def initialize
      @entities = []
    end

    def add_entity(&block)
      @entities << Entity.new(&block)
    end

    def remove_entity(entity)
      @entities.delete(entity)
    end

    def remove_entity_by_id(id)
      @entities.reject! { |e| e.id == id }
    end

    def remove_entity_by_type(type)
      @entities.reject! { |e| e.type == type }
    end

  end
end