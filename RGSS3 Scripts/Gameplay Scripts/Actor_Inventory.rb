#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Actor Inventory
#  Author: Kread-EX
#  Version 1.11
#  Release date: 11/02/2012
#
#  Big thanks to Seiryuki.
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#------------------------------------------------------------------------------
#  ▼ UPDATES
#------------------------------------------------------------------------------
# # 13/04/2013. Fixed compat. with YF Convert Damage and Buff/State Manager.
# # 16/01/2012. Fixed compat. with Fomar's Equipment Skills.
# # 01/04/2012. Fixed compat. with Ace Passive States
# # 01/04/2012. Fixed compat. with various YF scripts.
# # 26/03/2012. Added class conditions for items.
# # 12/02/2012. Fixed critical bug.
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
# # Consumable items become equippable and they are only available in battle once
# # equipped akin to the Suikoden series. It offers strategic options as the
# # player has to choose between stats (accessories) or items.
#------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#------------------------------------------------------------------------------
# # Requires (yes, I said REQUIRES) Yanfly's Ace Equip Engine. After that, it's
# # pretty plug and play, just select the slot type in the config module. By
# # default, it's 4 (same as accessories) but do whatever you want.
# #
# # <class_locks: x, x>
# # This item notetag allows you to lock items to certain classes.
#------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#------------------------------------------------------------------------------
# # Obviously enough, needs to be placed below Ace Equip Engine since it's needed.
# # Ace Battle Engine on the other hand is optional.
# # Numerous overwrites make this script incompatible with battle scripts that
# # changes how items behave in battle.
# #
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_actinv_notetags (new method)
# #
# # RPG::Item
# # etype_id (new method)
# # params (new method)
# #
# # Game_Temp
# # item_equip_index (new attr method)
# #
# # Game_Battler
# # consume_item (alias)
# # consume_equip_item (new method)
# #
# # Game_Actor
# # equippable? (overwrite)
# # sealed_etypes (overwrite)
# # fixed_etypes (overwrite)
# #
# # Game_Party
# # has_item? (alias)
# #
# # Window_EquipItem
# # include? (overwrite)
# #
# # Window_ActorItem (new class)
# #
# # Scene_Battle
# # create_item_window (overwrite)
# # command_item (overwrite)
# # on_item_ok (alias)
# # on_actor_cancel (alias)
#------------------------------------------------------------------------------

# Quits if Ace Equip Engine isn't found.

if $imported.nil? || $imported['YEA-AceEquipEngine'].nil?
	
msgbox('You need YF Ace Equip Engine in order to use Actor Inventory. Loading aborted.')

else
	
$imported['KRX-ActorInventory'] = true

#puts 'Load: Actor Inventory v1.11 by Kread-EX'

module KRX

  ITEMS_ETYPE_ID = 4
  
  module REGEXP
    ITEM_CLASS_LOCKS = /<class_locks:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
  end
end

#===========================================================================
# ■ DataManager
#===========================================================================

module DataManager  
	#--------------------------------------------------------------------------
	# ● Loads the database
	#--------------------------------------------------------------------------
	class << self
		alias_method(:krx_actinv_dm_load_database, :load_database)
	end
	def self.load_database
		krx_actinv_dm_load_database
		load_actinv_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_actinv_notetags
		groups = [$data_items]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_actinv_notetags
			end
		end
		#puts "Read: Actor Inventory Notetags"
	end
end

#===========================================================================
# ■ RPG::Item
#===========================================================================

class RPG::Item < RPG::UsableItem
  #--------------------------------------------------------------------------
  # ● Public instance variables
  #--------------------------------------------------------------------------
  attr_reader   :c_locks
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_actinv_notetags
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::ITEM_CLASS_LOCKS
        @c_locks = []
				$1.scan(/\d+/).each {|i| @c_locks.push(i.to_i)}
			end
		end
	end
  #--------------------------------------------------------------------------
  # ● Set the etype to the same as accessories
  #--------------------------------------------------------------------------
  def etype_id
    KRX::ITEMS_ETYPE_ID
  end
  #--------------------------------------------------------------------------
  # ● Set parameter gains to 0
  #--------------------------------------------------------------------------
  def params
    [0] * 8
  end
end

#===========================================================================
# ■ Game_Temp
#===========================================================================

class Game_Temp
  attr_accessor  :item_equip_index
end

#===========================================================================
# ■ Game_Battler
#===========================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● Uses up an item
  #--------------------------------------------------------------------------
  alias_method(:krx_actinv_gb_ci, :consume_item)
  def consume_item(item)
    if SceneManager.scene.is_a?(Scene_Battle)
      consume_equip_item(item)
      return
    end
    krx_actinv_gb_ci(item)
  end
  #--------------------------------------------------------------------------
  # ● Uses up an equipped item
  #--------------------------------------------------------------------------
  def consume_equip_item(item)
    unless !is_a?(Game_Actor)
      @equips[$game_temp.item_equip_index] = Game_BaseItem.new
    end
  end
end

#===========================================================================
# ■ Game_Actor
#===========================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Determine if an item can be equipped
  #--------------------------------------------------------------------------
  def equippable?(item)
    if item.is_a?(RPG::Item)
      return false if item.c_locks != nil && !item.c_locks.include?(class_id)
      return false if item.itype_id == 2
      return false unless item.battle_ok?
      return true
    end
    return false if item.nil?
    return false if equip_type_sealed?(item.etype_id)
    return equip_wtype_ok?(item.wtype_id) if item.is_a?(RPG::Weapon)
    return equip_atype_ok?(item.atype_id) if item.is_a?(RPG::Armor)
    return false
  end
  #--------------------------------------------------------------------------
  # new method: sealed_etypes
  #--------------------------------------------------------------------------
  def sealed_etypes
    array = []
    array |= self.actor.sealed_equip_type
    array |= self.class.sealed_equip_type
    for equip in equips
      next if equip.nil? || equip.is_a?(RPG::Item)
      array |= equip.sealed_equip_type
    end
    for state in states
      next if state.nil?
      array |= state.sealed_equip_type
    end
    return array
  end
  #--------------------------------------------------------------------------
  # new method: fixed_etypes
  #--------------------------------------------------------------------------
  def fixed_etypes
    array = []
    array |= self.actor.fixed_equip_type
    array |= self.class.fixed_equip_type
    for equip in equips
      next if equip.nil? || equip.is_a?(RPG::Item)
      array |= equip.fixed_equip_type
    end
    for state in states
      next if state.nil?
      array |= state.fixed_equip_type
    end
    return array
  end
end

#===========================================================================
# ■ Game_Party
#===========================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● Determine if the party possess an item
  #--------------------------------------------------------------------------
  alias_method(:krx_actinv_gp_has_item?, :has_item?)
  def has_item?(item, include_equip = false)
    return true if SceneManager.scene.is_a?(Scene_Battle)
    return krx_actinv_gp_has_item?(item, include_equip)
  end
end

#===========================================================================
# ■ Window_EquipItem
#===========================================================================

class Window_EquipItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● Determine if an item goes into the list
  #--------------------------------------------------------------------------
  def include?(item)
    if item.nil? && !@actor.nil?
      etype_id = @actor.equip_slots[@slot_id]
      return YEA::EQUIP::TYPES[etype_id][1]
    end
    return true if item.nil?
    return false if @slot_id < 0
    return false if item.etype_id != @actor.equip_slots[@slot_id]
    return @actor.equippable?(item)
  end
end

#==============================================================================
# ■ Window_ActorItem
#==============================================================================

class Window_ActorItem < Window_EquipSlot
  #--------------------------------------------------------------------------
  # ● Determine if a slot can be selected
  #--------------------------------------------------------------------------
  def enable?(index)
    item = @actor.equips[index]
    item.is_a?(RPG::Item) && item.battle_ok?
  end
  #--------------------------------------------------------------------------
  # ● Makes the window appear
  #--------------------------------------------------------------------------
  def show
    @help_window.show
    super
  end
  #--------------------------------------------------------------------------
  # ● Makes the window disappear
  #--------------------------------------------------------------------------
  def hide
    @help_window.hide unless @help_window.nil?
    super
  end
end

#==============================================================================
# ■ Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● Constructs the item window
  #--------------------------------------------------------------------------
  def create_item_window
    wx = 0
    wy = @help_window.height
    ww = Graphics.width / 2 + 48
    @item_window = Window_ActorItem.new(wx, wy, ww)
    @item_window.height -= @status_window.height
    @item_window.hide
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
  end
  #--------------------------------------------------------------------------
  # ● Selects an item
  #--------------------------------------------------------------------------
  def command_item
    @item_window.actor = BattleManager.actor
    @item_window.refresh
    @item_window.show.activate.select(0)
  end
  #--------------------------------------------------------------------------
  # ● Validates the item selection
  #--------------------------------------------------------------------------
  alias_method(:krx_actinv_sb_oio, :on_item_ok)
  def on_item_ok
    $game_temp.item_equip_index = @item_window.index
    krx_actinv_sb_oio
  end
  #--------------------------------------------------------------------------
  # ● Cancels the actor selection
  #--------------------------------------------------------------------------
  alias_method(:krx_actinv_sb_oac, :on_actor_cancel)
  def on_actor_cancel
    krx_actinv_sb_oac
    @status_window.show
  end
end

# YEA compatibility

#===========================================================================
# ■ RPG::Item
#===========================================================================

class RPG::Item < RPG::UsableItem
  # Lunatic Parameters
  def custom_parameters
    if @custom_parameters.nil?
      @custom_parameters = {
      0 => [], 1 => [], 2 => [], 3 => [], 4 => [], 5 => [], 6 => [], 7 => [] }
    end
    @custom_parameters
  end
  # Passive states
  def passive_states; []; end
  # Skill Restrictions
  def warmup_rate; 1; end
  # Skill Cost Manager
  def hp_cost_rate; 1; end
  def gold_cost_rate; 1; end
  def tp_cost_rate; 1; end
  def cooldown_rate; 1; end
  # Element Reflect
  def element_reflect; []; end
  # Element Absorb
  def element_absorb; []; end
end

end # YEA compatibility

# Buff/State Manager compatibility
if $imported["YEA-Buff&StateManager"]
  class RPG::UsableItem < RPG::BaseItem
    alias_method(:krx_actinv_bsm, :load_notetags_bsm)
    def load_notetags_bsm
      super
      krx_actinv_bsm
    end
  end
end # End of Buff/State Manager compatibility

# Convert Damage compatibility
if $imported["YEA-ConvertDamage"]
  class RPG::UsableItem < RPG::BaseItem
    alias_method(:krx_actinv_convertdmg, :load_notetags_convertdmg)
    def load_notetags_convertdmg
      super
      krx_actinv_convertdmg
    end
  end
end # End of Buff/State Manager compatibility

# Fomar's Equipment Skills compatibility
if defined?(Equipment_Skills)
  
class Window_EquipSlot < Window_Selectable
  def update
    eqskills_update
    return if SceneManager.scene.is_a?(Scene_Battle)
    @status_window.refresh(self.item) if self.active == true
  end
end

end # Fomar's Equipment Skills compatibility