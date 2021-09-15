#
# EDOS/src/REI/Entity.rb
#   by IceDragon
#   dc 09/05/2013
#   dm 11/05/2013
# vr 0.0.1
require_relative 'entity/entity_base'
require_relative 'entity/entity_battler'
require_relative 'entity/entity'
require_relative 'entity/entity_ex'

module REI
  class EntityActor < Entity
    def base_entity
      return $data_actors[@entity_id]
    end

    def inventory
      $game.party #.inventory
    end
  end

  class EntityEnemy < Entity
    def base_entity
      return $data_enemies[@entity_id]
    end
  end

  class EntityTrap < Entity
    #
  end

  class EntityItem < EntityBase
    #
  end
end
