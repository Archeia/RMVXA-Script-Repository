#==============================================================================#
# ** IEX(Icy Engine Xelion) - Equipment Skills
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Equipment)
# ** Script Type   : Skills from Equipment
# ** Date Created  : 10/22/2010
# ** Date Modified : 07/24/2011
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# The script is a bit primitive, once a an item is equipped the wielder/equipee
# will have access to whatever skill is stated.
# If the item is removed, the skills go with it.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# V1.0
#  Notetags! Can be placed in Equipment noteboxes
#------------------------------------------------------------------------------#
#  <EQUIP_SKILL: id, id, id> (or) <equip skill: id, id, id>
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE
#------------------------------------------------------------------------------#
#  In an equipments notebox (Weapon or Armor)
#  put <EQUIP_SKILL: id, id, id> or <equip skill: id, id, id>
#  The actor will gain the skills marked by Id while that piece of equipment
#  is equipped.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# (DD/MM/YYYY)
#  10/22/2010 - V1.0  Finished Script
#  01/24/2011 - V1.0a Fixed disabled skills problem when using the DBS
#  07/24/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment.
#
#------------------------------------------------------------------------------#
$imported ||= {}
$imported["IEX_Equipment_Skills"] = true
#==============================================================================#
# ** IEX::REGEXP::EQUIPMENT_SKILLS
#==============================================================================#
module IEX
  module REGEXP
    module EQUIPMENT_SKILLS
      EQUIPMENT_SKILL = /<(?:EQUIP_SKILL|equip skill)s?:?[ ]*(\d+(?:\s*,\s*\d+)*)>/i
    end
  end
end

#==============================================================================#
# ** RPG::BaseItem
#==============================================================================#
class RPG::BaseItem

  #--------------------------------------------------------------------------#
  # * new-method :iex_skill_equipment_cache
  #--------------------------------------------------------------------------#
  def iex_skill_equipment_cache
    @iex_equip_skills = []
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when IEX::REGEXP::EQUIPMENT_SKILLS::EQUIPMENT_SKILL
        $1.scan(/\d+/).each { |skill_id|
        @iex_equip_skills.push(skill_id.to_i) }
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :iex_equip_skills
  #--------------------------------------------------------------------------#
  def iex_equip_skills
    iex_skill_equipment_cache if @iex_equip_skills.nil?
    return @iex_equip_skills
  end

end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------#
  # * alias-method :skill_learn?
  #--------------------------------------------------------------------------#
  alias :iex_esk_skill_learn? :skill_learn? unless $@
  def skill_learn?( skill )
    return true if equipment_skills.include?( skill )
    return iex_esk_skill_learn?( skill )
  end unless $imported["BattleEngineMelody"]

  #--------------------------------------------------------------------------#
  # * new-method :equipment_skills
  #--------------------------------------------------------------------------#
  def equipment_skills
    equips.compact.each_with_object([]) do |eq, result|
      result.concat(eq.iex_equip_skills.compact.map do |ski_id|
        $data_skills[ski_id]
      end)
    end.uniq
  end

  #--------------------------------------------------------------------------#
  # * alias-method :skills
  #--------------------------------------------------------------------------#
  alias :iex_equipment_skilss_ga_skills :skills unless $@
  def skills( *args, &block )
    result = iex_equipment_skilss_ga_skills( *args, &block )
    result |= equipment_skills()
    return result
  end

end

#==============================================================================#
# ** END OF FILE
#==============================================================================#
