#
# EDOS/src/REI/Entity.rb
#   by IceDragon
#   dc 09/05/2013
#   dm 11/05/2013
# vr 0.0.1
module Mixin
  module FeatureConstants
  end
  module EffectConstants
  end
end

#require_relative 'leg-entity/EntityBase'
#require_relative 'leg-entity/EntityBattler'
#require_relative 'leg-entity/Entity'
#require_relative 'leg-entity/Entity_Ex'
require_relative 'entity/entity'

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
  end

  class EntityItem < EntityBase
  end

end
