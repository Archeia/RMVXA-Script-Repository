#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Runic Enchantment - Individual Equipment Patch
#  Author: Kread-EX
#  Version 1.01
#  Release date: 17/03/2012
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#-------------------------------------------------------------------------------------------------
#  ▼ UPDATES
#-------------------------------------------------------------------------------------------------
# # 02/06/2012. Now lists equipped items.
#-------------------------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#-------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # rpgmakerweb.net
# # rpgrevolution.com
#-------------------------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#-------------------------------------------------------------------------------------------------
# # Allows compatibility with Fomar0153' Individual Equipment. ITT: all equipment
# # pieces are unique.
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#-------------------------------------------------------------------------------------------------
# # Put this script below both Individual Equipment and Runic Enchantment.
# #
# # Due to the nature of Fomar's script, despite his best efforts, this will
# # most likely clash with other scripts, so compatibility is overall low.
#-------------------------------------------------------------------------------------------------

if $imported.nil? || $imported['KRX-Enchantment'].nil?
	
msgbox('You need Runic Enchantment for this patch. Loading aborted.')

elsif not defined?(Game_CustomEquip)
  
msgbox('You need Individual Equipment for this patch. Loading aborted.')

else
  
#==========================================================================
# ■ Game_CustomEquip
#==========================================================================

class Game_CustomEquip < Game_BaseItem
	#--------------------------------------------------------------------------
	# ● Class variables
	#--------------------------------------------------------------------------
  @@count = 0
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader   :unique_id
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------  
  alias_method(:krx_sandal_gce_init, :initialize)
  def initialize
    krx_sandal_gce_init
    hash = 'sandal'.hash
    @unique_id = hash + @@count
    @@count += 1
  end
	#--------------------------------------------------------------------------
	# ● Determine if the item can be enchanted
	#--------------------------------------------------------------------------
  def can_enchant
    object.is_a?(RPG::EquipItem) && object.can_enchant
  end
	#--------------------------------------------------------------------------
	# ● Determine the number of rune slots
	#--------------------------------------------------------------------------
  def rune_slots
    object.is_a?(RPG::EquipItem) ? object.rune_slots : 0
  end
	#--------------------------------------------------------------------------
	# ● Determine if the item is a rune
	#--------------------------------------------------------------------------
  def is_rune?
    object.is_rune?
  end
end

#==========================================================================
# ■ Window_EnchantList
#==========================================================================
	
class Window_EnchantList < Window_ItemList
	#--------------------------------------------------------------------------
	# ● Creates the list based on the recipes
	#--------------------------------------------------------------------------
	def make_item_list
		@data = []
    ($game_party.all_items + $game_party.equipped_items).each do |itm|
      @data.push(itm) if itm.is_a?(Game_CustomEquip) && itm.can_enchant
    end
	end
end

#==========================================================================
# ■ Window_RuneList
#==========================================================================
	
class Window_RuneList < Window_ItemList
	#--------------------------------------------------------------------------
	# ● Enable
	#--------------------------------------------------------------------------
	def enable?(item)
    return true if item.nil?
    if item.rune_unique
      ti = SceneManager.scene.target_item
      container = ti.object.class == RPG::Weapon ? $game_party.enchants_w :
      $game_party.enchants_a
      slots = container[ti.unique_id] || []
      return !slots.include?(item.id)
    end
    if item.rune_type == :weapon
      return SceneManager.scene.target_item.object.class == RPG::Weapon
    elsif item.rune_type == :armor
      return SceneManager.scene.target_item.object.class == RPG::Armor
    end
		return true
	end
end

#==========================================================================
# ■ Window_ViewRunes
#==========================================================================
	
class Window_ViewRunes < Window_Selectable
	#--------------------------------------------------------------------------
	# ● Refresh the contents
	#--------------------------------------------------------------------------
	def set_item(item = nil)
		contents.clear
		return if item.nil?
    container = item.is_a?(Game_CustomEquip) && item.object.is_a?(RPG::Weapon) ?
    $game_party.enchants_w : $game_party.enchants_a
    container[item.unique_id] = [] if container[item.unique_id].nil?
    @data = container[item.unique_id]
    filler = item.rune_slots - @data.size
    filler.times {@data.push(nil)} if filler > 0
		draw_item_runes(item)
	end
end

#==========================================================================
# ■ Scene_Enchant
#==========================================================================
	
class Scene_Enchant < Scene_ItemBase
	#--------------------------------------------------------------------------
	# ● Validates the rune selection
	#--------------------------------------------------------------------------
  def on_rune_ok
    e_type = @enchant_window.item.object.class
    e_id = @enchant_window.item.unique_id
    r_index = @rune_window.index
    r_id = @runelist_window.item != nil ? @runelist_window.item.id : nil
    $game_party.inscribe_rune(e_type, e_id, r_id, r_index)
    @rune_window.set_item(@enchant_window.item)
    @rune_window.activate
    @runelist_window.hide.refresh
    @runelist_window.unselect
    @enchant_window.show
  end
end

#===========================================================================
# ■ Game_Party
#===========================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● Initializes all items
  #--------------------------------------------------------------------------
  alias_method(:krx_sandal_patch_gp_iai, :init_all_items)
  def init_all_items
    krx_sandal_patch_gp_iai
    @runes = {}
  end
	#--------------------------------------------------------------------------
	# ● Returns the items equipped by all actors
	#--------------------------------------------------------------------------
  def equipped_items
    result = []
    members.each {|actor| result.push(actor.custom_equips)}
    return result.flatten
  end
	#--------------------------------------------------------------------------
	# ● Inscribes a rune
	#--------------------------------------------------------------------------
  def inscribe_rune(e_type, e_id, r_id, r_index)
    container = e_type == RPG::Weapon ? @enchants_w : @enchants_a
    container[e_id] = [] if container[e_id].nil?
    if container[e_id][r_index] != nil
      item = $data_armors[container[e_id][r_index]]
      gain_item(item, 1)
    end
    lose_item($data_armors[r_id], 1) unless r_id.nil?
    container[e_id][r_index] = r_id
  end
  #--------------------------------------------------------------------------
  # ● Adds an item
  #--------------------------------------------------------------------------
  alias_method(:krx_sandal_patch_gp_gi, :gain_item)
  def gain_item(item, amount, include_equip = false)
    if item.is_a?(RPG::Armor) && item.is_rune?
      last_number = item_number(item)
      new_number = last_number + amount
      @runes[item.id] = [[new_number, 0].max, max_item_number(item)].min
      @runes.delete(item.id) if @runes[item.id] == 0
      return
    end
    krx_sandal_patch_gp_gi(item, amount, include_equip)
  end
  #--------------------------------------------------------------------------
  # ● Determine the possessed number of items
  #--------------------------------------------------------------------------
  alias_method(:krx_sandal_patch_gp_in, :item_number)
  def item_number(item)
    if item.is_a?(RPG::Armor) && item.is_rune?
      return @runes[item.id] ? @runes[item.id] || 0 : 0
    end
    krx_sandal_patch_gp_in(item)
  end
  #--------------------------------------------------------------------------
  # ● Determine the maximum number of items (Fomar's method)
  #--------------------------------------------------------------------------
  alias_method(:krx_sandal_patch_gp_min, :max_item_number)
  def max_item_number(item)
    if item.is_a?(RPG::Armor) && item.is_rune?
      return 99
    end
    krx_sandal_patch_gp_min(item)
  end
  #--------------------------------------------------------------------------
  # ● Returns the runes
  #--------------------------------------------------------------------------
  def runes
    @runes.keys.sort.collect {|id| $data_armors[id] }
  end
  #--------------------------------------------------------------------------
  # ● Returns all possessed items
  #--------------------------------------------------------------------------
  alias_method(:krx_sandal_patch_gp_ai, :all_items)
  def all_items
    krx_sandal_patch_gp_ai + runes
  end
end

#===========================================================================
# ■ Window_ItemList
#===========================================================================

class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● Determine if an item goes in the list
  #--------------------------------------------------------------------------
  alias_method(:krx_sandal_patch_wil_include?, :include?)
  def include?(item)
    case @category
    when :weapon
      item.is_a?(Game_CustomEquip) && item.object.is_a?(RPG::Weapon)
    when :armor
      (item.is_a?(Game_CustomEquip) && item.object.is_a?(RPG::Armor)) ||
      (item.is_a?(RPG::Armor) && item.is_rune?)
    else
      krx_sandal_patch_wil_include?(item)
    end
  end
end

#===========================================================================
# ■ Game_Actor
#===========================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Returns the list of unique equipment
  #--------------------------------------------------------------------------
  def custom_equips
    @equips
  end
  #--------------------------------------------------------------------------
  # ● Returns the list of traits
  #--------------------------------------------------------------------------
  def feature_objects
    runes = []
    @equips.compact.each do |equip|
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
  #--------------------------------------------------------------------------
  # ● Determine if an item can be equipped
  #--------------------------------------------------------------------------
  alias_method(:krx_sandal_patch_ga_equippable?, :equippable?)
  def equippable?(item)
    if item.is_a?(Game_CustomEquip)
      return equip_wtype_ok?(item.wtype_id) if item.object.is_a?(RPG::Weapon)
      return equip_atype_ok?(item.atype_id) if item.object.is_a?(RPG::Armor)
    end
    krx_sandal_patch_ga_equippable?(item)
  end
end

end