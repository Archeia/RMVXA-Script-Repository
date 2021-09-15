#
# EDOS/src/REI/Team.rb
#   by IceDragon
#   dc 11/05/2013
#   dm 11/05/2013
# vr 0.0.1
module REI

  class TeamBase

    DIPLOMACY_NEUTRAL  = 0x0
    DIPLOMACY_HOSTILE  = 0x1
    DIPLOMACY_FRIENDLY = 0x2

    attr_accessor :squads
    attr_accessor :id
    attr_accessor :diplomacy_table # Hash<Integer id, DIPLOMACY>

  end

  class Team < TeamBase
    #
  end

end
