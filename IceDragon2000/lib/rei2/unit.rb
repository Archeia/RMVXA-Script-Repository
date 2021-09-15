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

    def initialize(entity, character=nil)
      @entity    = entity
      @character = character || entity.comp(:character)
      #@entity.unit    = self
      #@character.unit = self
    end

    ## wrapper
    def id
      @entity.id
    end

    def update
      @entity.update
    end

  end

  class Unit < UnitBase

    # name
    def name
      @entity.comp(:name).name
    end

    def title
      @entity.comp(:name).title_name
    end

    def hp
      @entity.comp(:health).value
    end

    def mhp
      @entity.comp(:health).max
    end

    def mp
      @entity.comp(:mana).value
    end

    def mmp
      @entity.comp(:mana).max
    end

    def wt
      @entity.comp(:wt).value
    end

    def mwt
      @entity.comp(:wt).max
    end

    def level
      @entity.comp(:level).level
    end

    def exp
      @entity.comp(:level).exp
    end

    def current_level_exp
      @entity.comp(:level).current_level_exp
    end

    def next_level_exp
      @entity.comp(:level).next_level_exp
    end

  end

end
