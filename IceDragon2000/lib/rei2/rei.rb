#
# EDOS/src/REI/REI.rb
#   by IceDragon
#   dc 11/05/2013
#   dm 11/05/2013
module REI

  VERSION = "2.0.0".freeze

  def self.create_unit_by_type(type)
    entity = REI::Entity.new do |ent|
      case type
      when :actor
        ent.add_component(:position)
        ent.add_component(:position_ease)
        ent.add_component(:health)
        ent.add_component(:mana)
        ent.add_component(:level)
        ent.add_component(:size)
        ent.add_component(:motion)
        ent.add_component(:character)
        ent.add_component(:event_server)
        ent.add_component(:name).setup_name(:entity, "entity/base").setup_title(:title, "no-title")
      else
        raise ArgumentError, "invalid unit type #{type}"
      end
      yield ent if block_given?
    end
    unit = REI::Unit.new(entity)
    return unit
  end

end
