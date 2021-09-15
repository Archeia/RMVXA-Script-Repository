#
# EDOS/src/REI/AI.rb
#   by IceDragon
#   dc 12/05/2013
#   dm 12/05/2013
# vr 0.0.1
module REI

  class AI

    attr_accessor :parent

    def initialize(parent)
      @parent = parent
    end

  end

  class EntityAI < AI
  end

end
