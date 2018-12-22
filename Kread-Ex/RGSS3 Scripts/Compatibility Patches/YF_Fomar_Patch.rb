#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Ace Equip Engine/Individual Equipment Patch
#  Author: Kread-EX
#  Version 1.02
#  Release date: 27/12/2012
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#------------------------------------------------------------------------------
#  ▼ UPDATES
#------------------------------------------------------------------------------
# # 15/03/2013. Bug fixes.
# # 09/01/2013. Bug fixes.
#------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # rpgmakerweb.com
#------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#------------------------------------------------------------------------------
# # Fixes compatibility errors between Yanfly Ace Equip Engine and
# # Fomar's Individual Equipment.
# #
# # Order of the scripts:
# # Ace Equip Engine
# # Individual Equipment
# # Actor Inventory
# # Asagi's Gun License
# # Runic Enchantment + Patch
# # This patch
#------------------------------------------------------------------------------

if $imported.nil? || !$imported["YEA-AceEquipEngine"]
	
msgbox('You need Ace Equip Engine for this patch. Loading aborted.')

elsif not defined?(Game_CustomEquip)
  
msgbox('You need Individual Equipment for this patch. Loading aborted.')

else

#===========================================================================
# ■ Game_Actor
#===========================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Anti crash equips
  #--------------------------------------------------------------------------
  def anti_crash_equips
    for i in 0...@equips.size
      next unless @equips[i].nil? || @equips[i].is_a?(RPG::Item)
      if @equips[i].nil?
        @equips[i] = Game_CustomEquip.new
      else
        old = @equips[i]
        @equips[i] = Game_BaseItem.new
        @equips[i].object = old
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Determine if an item can be equipped
  #--------------------------------------------------------------------------
  def equippable?(item)
    # Actor Inventory
    if $imported['KRX-ActorInventory']
    if item.is_a?(RPG::Item)
      return false if item.c_locks != nil && !item.c_locks.include?(class_id)
      return false if item.itype_id == 2
      return false unless item.battle_ok?
      return true
    end
    end # Actor Inventory
    # Asagi's Gun License
    if $imported['KRX-AsagisGunLicense']
    if self.class.ammo_user? && item.is_a?(Game_CustomEquip) &&
    item.object.is_a?(RPG::Weapon)
      return true if item.wtype_id == self.class.ammo_type_id
    end
    end # Asagi's Gun License
    if item.is_a?(Game_CustomEquip)
      return equip_wtype_ok?(item.wtype_id) if item.object.is_a?(RPG::Weapon)
      return equip_atype_ok?(item.atype_id) if item.object.is_a?(RPG::Armor)
    end
    return false unless item.is_a?(RPG::EquipItem)
    return false if equip_type_sealed?(item.etype_id)
    return equip_wtype_ok?(item.wtype_id) if item.is_a?(RPG::Weapon)
    return equip_atype_ok?(item.atype_id) if item.is_a?(RPG::Armor)
    return false
  end
  #--------------------------------------------------------------------------
  # ● Returns the list of traits
  #--------------------------------------------------------------------------
  if $imported['KRX-Enchantment'] # Runic Enchantment only
  def feature_objects
    runes = []
    @equips.compact.each do |equip|
      next if equip.object.is_a?(RPG::Item) || equip.object.nil?
      container = equip.object.is_a?(RPG::Weapon) ? $game_party.enchants_w :
      $game_party.enchants_a
      next if container[equip.unique_id].nil?
      ids = container[equip.unique_id]
      ids.each do |id|
        next if id.nil?
        runes.push($data_armors[id])
      end
    end
    krx_sandal_ga_fo + runes.compact
  end
  end # Runic Enchantment
  #--------------------------------------------------------------------------
  # ● Rewrites force_change_equip
  #--------------------------------------------------------------------------
  def force_change_equip(slot_id, item)
    if item.nil?
      @equips[slot_id] = Game_CustomEquip.new
    else
      @equips[slot_id] = item
    end
    release_unequippable_items(true)
    refresh
  end
end

#===========================================================================
# ■ Window_EquipItem
#===========================================================================

class Window_EquipItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● Include the item in the list
  #--------------------------------------------------------------------------
  alias_method(:krx_yfomar_wei_include?, :include?)
  def include?(item)
    return false if item.is_a?(Game_BaseItem) && item.object.nil?
    return krx_yfomar_wei_include?(item)
  end
  #--------------------------------------------------------------------------
  # ● Displays the actual item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    rect = item_rect(index)
    rect.width -= 4
    if item.nil?
      draw_remove_equip(rect)
      return
    end
    dw = contents.width - rect.x - 24
    draw_item_name(item, rect.x, rect.y, enable?(item), dw)
  end
end

end