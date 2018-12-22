#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Item Charges
#  Author: Kread-EX
#  Version 1.05
#  Release date: 12/02/2012
#
#  Big thanks to Ravenith.
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#------------------------------------------------------------------------------
#  ▼ UPDATES
#------------------------------------------------------------------------------
# # 12/02/2013. Fixed a crashing bug.
# # 14/01/2013. Added option to limit item max nb (by Nosleinad's request)
# #             Also added option to disable charges text.
# # 16/02/2012. Fixed a bug with equipment scene.
# # 12/02/2012. Fixed a bug with the charges display.
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
#  ▼ INSTRUCTIONS
#------------------------------------------------------------------------------
# # I'll refer you to this link because I feel so lazy right now:
# # http://grimoirecastle.wordpress.com/item-charges/
#------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#------------------------------------------------------------------------------
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # extract_save_contents (alias)
# # load_itemcharges_notetags (new method)
# # reconstruct_item_list (new method)
# #
# # RPG::Item
# # max_charges (new attr method)
# # load_itemcharges_notetags (new method)
# # deep_copy (new method)
# #
# # Game_Battler
# # consume_equip_item (alias) - Actor Inventory only
# #
# # Game_Actor
# # trade_item_with_party (alias)
# # trade_item_with_party_wo_stack (new method)
# #
# # Game_Party
# # divided_items (new attr method)
# # item_charges (new attr method)
# # updated_data_items (new attr method)
# # temp_container (new attr method)
# # gain_item (alias)
# # add_divided_item (new method)
# # consume_item (alias)
# # consume_charges (new method)
# # consume_charges_wo_stack (new method)
# # temp_conainer_add (new method)
# # temp_container_extract (new method)
# # max_item_number (alias)
# #
# # Window_Base
# # draw_item_name (alias)
# # draw_item_charges (new method)
#------------------------------------------------------------------------------

($imported || {})['KRX-ItemCharges'] = true

puts 'Load: Item Charges v1.05 by Kread-EX'

module KRX
  
  CHARGES_DISPLAY_COLOR = Color.new(40, 255, 120, 255)
  DISABLE_ITEM_STACKING = true
  DISABLE_CHARGE_TEXT = false
  MAX_ITEMS = 9
  
  module REGEXP
    ITEM_CHARGES = /<item_charges:[ ]*(\d+)>/i
  end
  
end

#===========================================================================
# ■ DataManager
#===========================================================================

module DataManager  
	#--------------------------------------------------------------------------
	# ● Alias listings
	#--------------------------------------------------------------------------
	class << self
		alias_method(:krx_itemcharges_dm_load_database, :load_database)
    alias_method(:krx_itemcharges_dm_esc, :extract_save_contents)
	end
	#--------------------------------------------------------------------------
	# ● Loads the database
	#--------------------------------------------------------------------------
	def self.load_database
		krx_itemcharges_dm_load_database
		load_itemcharges_notetags
	end
  #--------------------------------------------------------------------------
  # ● Reads the savefile
  #--------------------------------------------------------------------------
  def self.extract_save_contents(contents)
    krx_itemcharges_dm_esc(contents)
    if $game_party.updated_data_items != nil && KRX::DISABLE_ITEM_STACKING
      $data_items = $game_party.updated_data_items
    end
  end
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_itemcharges_notetags
		groups = [$data_items]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_itemcharges_notetags
			end
		end
		puts "Read: Item Charges Notetags"
	end
  #--------------------------------------------------------------------------
  # ● Reconstructs $data_items with the non-stacking items
  #--------------------------------------------------------------------------
  def self.reconstruct_item_list
    old_size = new_id = $data_items.size
    $game_party.divided_items.each do |item|
      item.id = new_id
      new_id += 1
    end
    $game_party.updated_data_items = $data_items.concat($game_party.divided_items)
    new_size = $data_items.size
    return $data_items[old_size, new_size]
  end
end

#==========================================================================
# ■ RPG::Item
#==========================================================================

class RPG::Item < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader     :max_charges
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_itemcharges_notetags
		@note.split(/[\r\n]+/).each do |line|
			case line
      when KRX::REGEXP::ITEM_CHARGES
        @max_charges = $1.to_i
      end
		end
	end
	#--------------------------------------------------------------------------
	# ● Creates a deep copy
	#--------------------------------------------------------------------------
  def deep_copy
    item = RPG::Item.new
    instance_variables.each do |var|
      value = instance_variable_get(var)
      item.instance_variable_set(var, value)
    end
    item
  end
end

## Actor Inventory compatibility

if $imported['KRX-ActorInventory']

#===========================================================================
# ■ Game_Battler
#===========================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● Uses up an equipped item
  #--------------------------------------------------------------------------
  alias_method(:krx_itemcharges_gb_cei, :consume_equip_item)
  def consume_equip_item(item)
    if $game_party.item_charges[item.id] != nil
      $game_party.item_charges[item.id] -= 1
    else
    end
    if !$game_party.item_charges[item.id].nil? &&
    $game_party.item_charges[item.id] > 0
      return
    end
    krx_itemcharges_gb_cei(item)
  end
end

end ## Actor Inventory compatibility

#===========================================================================
# ■ Game_Actor
#===========================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Trade items between an actor and the inventory
  #--------------------------------------------------------------------------
  alias_method(:krx_itemcharges_ga_tiwp, :trade_item_with_party)
  def trade_item_with_party(new_item, old_item)
    unless KRX::DISABLE_ITEM_STACKING
      return krx_itemcharges_ga_tiwp(new_item, old_item)
    end
    trade_item_with_party_wo_stack(new_item, old_item)
  end
  #--------------------------------------------------------------------------
  # ● Trade items between an actor and the inventory (no stack version)
  #--------------------------------------------------------------------------
  def trade_item_with_party_wo_stack(new_item, old_item)
    return false if new_item && !$game_party.has_item?(new_item)
    if old_item != nil && old_item.is_a?(RPG::Item) && old_item.max_charges != nil
      $game_party.temp_container_extract(old_item)
    else
      $game_party.gain_item(old_item, 1)
    end
    if new_item != nil && new_item.is_a?(RPG::Item) && new_item.max_charges != nil
      $game_party.temp_container_add(new_item)
    else
      $game_party.lose_item(new_item, 1)
    end
    return true
  end
end

#==========================================================================
# ■ Game_Party
#==========================================================================

class Game_Party < Game_Unit
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader     :divided_items
  attr_writer     :item_charges
  attr_accessor   :updated_data_items
	#--------------------------------------------------------------------------
	# ● Get item charges
	#--------------------------------------------------------------------------
  def item_charges
    @item_charges ||= {}
  end
	#--------------------------------------------------------------------------
	# ● Adds an item to party's inventory
	#--------------------------------------------------------------------------
  alias_method(:krx_itemcharges_gp_gi, :gain_item)
  def gain_item(item, amount, include_equip = false)
    if item.is_a?(RPG::Item) && item.max_charges != nil
      if KRX::DISABLE_ITEM_STACKING
        add_divided_item(item, amount)
        return
      else
        @item_charges ||= {}
        if amount > 0 && @item_charges[item.id].nil?
          @item_charges[item.id] = item.max_charges
        end
      end
    end
    krx_itemcharges_gp_gi(item, amount, include_equip)
  end
	#--------------------------------------------------------------------------
	# ● Adds an item to party's inventory without stacking
	#--------------------------------------------------------------------------
  def add_divided_item(item, amount)
    @divided_items = []
    if amount > 0
      amount.times {@divided_items.push(item.deep_copy) }
      @divided_items = DataManager.reconstruct_item_list
      @divided_items.each do |itm|
        @items[itm.id] = 1
        @item_charges = {} if @item_charges.nil? 
        if @item_charges[itm.id].nil? || @item_charges[itm.id] <= 0
          @item_charges[itm.id] = itm.max_charges
        end
      end
    else
      @items.delete(item.id)
    end
  end
	#--------------------------------------------------------------------------
	# ● Uses up an item
	#--------------------------------------------------------------------------
  alias_method(:krx_itemcharges_gp_ci, :consume_item)
  def consume_item(item)
    if KRX::DISABLE_ITEM_STACKING
      return if consume_charges_wo_stack(item)
    else
      return if consume_charges(item)
    end
    krx_itemcharges_gp_ci(item)
  end
	#--------------------------------------------------------------------------
	# ● Uses up an item's charges
	#--------------------------------------------------------------------------
  def consume_charges(item)
    return if @item_charges[item.id].nil?
    @item_charges[item.id] -= 1
    if @item_charges[item.id] <= 0
      @item_charges[item.id] = item.max_charges
      return false
    end
    true
  end
	#--------------------------------------------------------------------------
	# ● Uses up an item's charges (non-stacking version)
	#--------------------------------------------------------------------------
  def consume_charges_wo_stack(item)
    return if @item_charges[item.id].nil?
    @item_charges[item.id] -= 1
    @item_charges[item.id] > 0
  end
	#--------------------------------------------------------------------------
	# ● Temporary item stockage during equipment change (add)
	#--------------------------------------------------------------------------
  def temp_container_add(item)
    return if item.nil?
    @temp_container = [] if @temp_container.nil?
    @temp_container.push(item)
    @items.delete(item.id)
  end
	#--------------------------------------------------------------------------
	# ● Temporary item stockage during equipment change (remove)
	#--------------------------------------------------------------------------
  def temp_container_extract(item)
    return if item.nil?
    if @temp_container != nil && @temp_container.include?(item)
      @items[item.id] = 1
      @temp_container.delete(item)
      @temp_container.compact!
    end
  end
  #--------------------------------------------------------------------------
  # ● Get max number of items
  #--------------------------------------------------------------------------
  alias_method(:krx_itemcharges_gp_min, :max_item_number)
  def max_item_number(item)
    return KRX::MAX_ITEMS if item.class == RPG::Item
    return krx_itemcharges_gp_min(item)
  end
end

#==========================================================================
# ■ Window_Base
#==========================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● Displays an item's name and icon
  #--------------------------------------------------------------------------
  alias_method(:krx_itemcharges_wb_din, :draw_item_name)
  def draw_item_name(item, x, y, enabled = true, width = 172)
    krx_itemcharges_wb_din(item, x, y, enabled, width)
    draw_item_charges(item, x, y, enabled)
  end
  #--------------------------------------------------------------------------
  # ● Displays an item's number of charges
  #--------------------------------------------------------------------------
  def draw_item_charges(item, x, y, enabled)
    return if KRX::DISABLE_CHARGE_TEXT
    return unless item.is_a?(RPG::Item)
    return if item.max_charges.nil?
    return if $game_party.item_charges.nil?
    return if $game_party.item_charges[item.id].nil?
    size = contents.text_size(item.name).width
    string = "(#{$game_party.item_charges[item.id]})"
    old_color = contents.font.color.dup
    contents.font.color = KRX::CHARGES_DISPLAY_COLOR
    contents.font.color.alpha = 128 unless enabled
    contents.draw_text(x + size + 28, y, 48, line_height, string)
    contents.font.color = old_color
  end
end