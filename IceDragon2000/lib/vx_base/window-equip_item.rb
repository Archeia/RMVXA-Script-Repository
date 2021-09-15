#encoding:UTF-8
# Window_EquipItem
#==============================================================================
# ** Window_EquipItem
#------------------------------------------------------------------------------
#  This window displays choices when opting to change equipment on the
# equipment screen.
#==============================================================================

class Window_EquipItem < Window_Item
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x          : sindow X coordinate
  #     y          : sindow Y corrdinate
  #     width      : sindow width
  #     height     : sindow height
  #     actor      : actor
  #     equip_type : equip region (0-4)
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, actor, equip_type)
    @actor = actor
    if equip_type == 1 and actor.two_swords_style
      equip_type = 0                              # Change shield to weapon
    end
    @equip_type = equip_type
    super(x, y, width, height)
  end
  #--------------------------------------------------------------------------
  # * Whether to include item in list
  #     item : item
  #--------------------------------------------------------------------------
  def include?(item)
    return true if item == nil
    if @equip_type == 0
      return false unless item.is_a?(RPG::Weapon)
    else
      return false unless item.is_a?(RPG::Armor)
      return false unless item.kind == @equip_type - 1
    end
    return @actor.equippable?(item)
  end
  #--------------------------------------------------------------------------
  # * Whether to display item in enabled state
  #     item : item
  #--------------------------------------------------------------------------
  def enable?(item)
    return true
  end
end
