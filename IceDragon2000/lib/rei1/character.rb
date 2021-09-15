#
# EDOS/src/REI/Character.rb
#   by IceDragon
#   dc 06/05/2013
#   dm 11/05/2013
# vr 0.0.1
module REI

  class CharacterBase

    attr_accessor :unit
    ##
    attr_accessor :face_name
    attr_accessor :face_index
    attr_accessor :face_hue
    ##
    attr_accessor :character_name
    attr_accessor :character_index
    attr_accessor :character_hue
    ##
    attr_accessor :portrait_name
    attr_accessor :portrait_hue

    def initialize
      @unit = nil
      @face_name       = ''
      @face_index      = 0
      @face_hue        = 0
      @character_name  = ''
      @character_index = 0
      @character_hue   = 0
      @portrait_name   = ''
      @portrait_hue    = 0
    end

    def entity
      unit.entity
    end

  end

  class Character < CharacterBase

    def setup(data_entity)
      @face_name  = data_entity.face_name
      @face_index = data_entity.face_index
      @face_hue   = data_entity.face_hue

      @character_name  = data_entity.character_name
      @character_index = data_entity.character_index
      @character_hue   = data_entity.character_hue

      @portrait_name = data_entity.portrait_name
      @portrait_hue  = data_entity.portrait_hue
    end

  end

  class CharacterActor < Character
    #
  end

  class CharacterEnemy < Character
    #
  end

  class CharacterTrap < Character
    #
  end

  class CharacterItem < Character
    #
  end

end