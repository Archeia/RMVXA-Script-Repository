#
# EDOS/src/REI/Unit.rb
#   by IceDragon
#   dc 06/05/2013
#   dm 12/05/2013
# vr 0.0.2
#
# CHANGELOG
#   vr 0.0.2
#     Added UnitActor, UnitEnemy, UnitTrap, UnitItem
module REI
  class UnitBase
    attr_accessor :entity
    attr_accessor :character

    def initialize(entity, character)
      @entity    = entity
      @character = character
      @entity.unit    = self
      @character.unit = self
    end

    ## wrapper
    # name
    def name
      @entity.name
    end

    def id
      @entity.id
    end

    def title
      @entity.title
    end
  end

  class Unit < UnitBase
    def setup(data_entity)
      @entity.setup(data_entity)
      @character.setup(data_entity)
    end
  end

  class UnitActor < Unit
    def initialize
      super(EntityActor.new, CharacterActor.new)
    end
  end

  class UnitEnemy < Unit
    def initialize
      super(EntityEnemy.new, CharacterEnemy.new)
    end
  end

  class UnitTrap < Unit
    def initialize
      super(EntityTrap.new, CharacterTrap.new)
    end
  end

  class UnitItem < Unit
    def initialize
      super(EntityItem.new, CharacterItem.new)
    end
  end
end
