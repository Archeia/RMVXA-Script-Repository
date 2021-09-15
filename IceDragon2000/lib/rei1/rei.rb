#
# EDOS/src/REI/REI.rb
#   by IceDragon
#   dc 11/05/2013
#   dm 11/05/2013
module REI
  def self.create_unit(entity, character = REI::Character.new)
    REI::Unit.new(entity, character)
  end
end
