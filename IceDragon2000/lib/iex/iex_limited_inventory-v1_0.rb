#==============================================================================#
# ** IEX(Icy Engine Xelion) - Actor Inventory
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon
# ** Script-Status : Addon (Actor)
# ** Script-Type   : Limited Inventory (For actors)
# ** Date Created  : 09/12/2010
# ** Date Modified : 07/24/2011
# ** Request By    : Miacuro
# ** Version       : 1.0
#------------------------------------------------------------------------------#
# This adds a actor inventory system to your game.
# *WARNING*
# Once inserted your characters will not have access to the normal inventory.
#==============================================================================#
# **INTRODUCTION
#------------------------------------------------------------------------------#
#   *Reserved for when I actually get around to typing this*
#
#
#------------------------------------------------------------------------------#
#==============================================================================#
# **FEATURES
#------------------------------------------------------------------------------#
#  Each actor has there own unique inventory.
#  You can add and remove items from the actor's inventory.
#  Limited Actor Inventories
#  You can call the inventory from an event using this
#  actor_inventory(actor_id) 
# 
#  You can add to the inventory using
#  add_to_actor_inventory(actor_id, item_id, number)
#
#  You can remove from the inventory using
#  remove_from_actor_inventory(actor_id, item_id, number) 
#
#  You can clear the whole inventory using
#  clear_actor_inventory(actor_id)
#
#
# Item Notetags
# <not for inventory> An item with this tag cannot be used in the actor inventory
#                     By Default all items can be used for the actor inventory.
# <inventory limit: x> x being the amount of the same item that can be kept in the 
#                      Inventory for 1 slot.
#
# Equipment Tags
# <max equip item: +/-x> Equipment that raise or lower the maximum items that 
#                        can be carried, this is suppose to work with the 
#                        overstock feature. 
#
#
# Skill Notetags *Untested*
# <break item x, x, x> or <break items x, x, x> x being any amount of ITEM ids
#                                               When the skill is used on a actor
#                                               If the item is in the actor's 
#                                               Inventory, it will be lost
#
# <break random item> The name says it, when used on an actor, they lose a random
#                     Item
#
# <break all items> The name says it, when used on an actor, they lose all Items
#
# <jettison items: x, x, x> Works similar to the break item, except, that it is the actor
#                  who throws away the items when they use the skill.
#
# <require item: x, x, x> Unless the items are present in the actor's inventory 
#                         the skill cannot be used
#
# ** Missing / Needs to be fixed
#  Merchant classes won't work correctly in YEM 
#  Overstock feature, hasn't been implemented yet.
#
#==============================================================================#
# **CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  10/05/2010 - V0.8  Realeased Script
#  10/06/2010 - V0.8a Multiple Bug Fixes
#  11/07/2010 - V0.8b Bug Fixes, Selection box now goes to send to when item is
#                     Available.
#  11/15/2010 - V0.9  Fixed Merchant class Bug
#  07/24/2011 - V1.0  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# **KNOWN_ISSUES
#------------------------------------------------------------------------------#
#  Non at the Moment.
#
#------------------------------------------------------------------------------#
# $scene = IEX_Scene_Actor_Inventory.new($game_actors[actor_id])
# That is the script call for it... Do not use this, it is for scripter ref
#==============================================================================#
$imported = {} if $imported == nil
$imported["IEX_Actor_Inventory"] = true
#==============================================================================#
# ** IEX::ACTOR_INVENTORY
#==============================================================================#
module IEX
  module ACTOR_INVENTORY
#==============================================================================#
#                           Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#   
#---------------------------------------------------------------#
# ** Main Config 
#---------------------------------------------------------------#  
    ALLOW_OVERSTOCK = false # Apart of the Overstock, Can be ignored for now
    RANDOM_PRUNE = false # Apart of the Overstock, Can be ignored for now
    
    INVEN_ITEM_LIMIT = 5

    ACTOR_LIMITS = {
  #Actor_Id => Limit,
    0 => 4, # If an actor is stated it will use this instead
    }
    
    MERCHANT_CLASSES = [] 
    ALLOW_INVENTORY_MENU = true # Should the inventory command be added to the menu
                              
#---------------------------------------------------------------#
# ** Draw_Item 
#---------------------------------------------------------------#    
    NUMBER_COLUMNS = 5 # Number of Colunms in the in Inventory Window
    ITEM_SQ_SPACING = 42 # Spacing between Items
    RECT_SIZE = 32 # Bordered Rectangle Size
    SELECTION_SIZE = 48 # Selection Cursor Size
    
    DRAW_ITEM_ICON_IN_HELP = true # Should the items Icon be drawn in the help?
    DRAW_AMOUNT_FOR_1 = false # If there is only one of the item should it write 1
    
    ITEM_NUM_POS = [0, 8] # [x, y] Position of Item Number 
    ITEM_NUM_ALIGN = 1 # 0 - Flush Left, 1 - Center, 2 - Flush Right
    ITEM_NUM_FORMAT = "x%2d" # Format "yourtext%2d" used when showing amount
    ITEM_ICON_POS = [4, 4] # Items Icon Position 
    
#---------------------------------------------------------------#
# ** Vocab
#---------------------------------------------------------------# 
    ITEM_HEADER = "Inventory"
    USE_ITEM = "Use Item"
    SEND_TO_ACTOR = "Send to Actor"
    SEND_TO_INVENTORY = "Send to Inventory"
    SEND_ALL_TO_INVENTORY = "Send All To Inventory"
    SWITCH_TO_INVENTORY = "Switch to Inventory"
    SWITCH_TO_ACTOR = "Switch to Actor"
    CANCEL = "Cancel"
    CONFIRM = "Finished?"

    INVENTORY_TEXT_NAME = "Actor Inventory"
#==============================================================================#
#                           End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#     
  end
end

#==============================================================================#
# ** IEX::REGEXP::ACTOR_INVENTORY
#==============================================================================#
module IEX
  module REGEXP
    module ACTOR_INVENTORY
      # Used by items
      INVENTORY_CANT = /<(?:INVENTORY_CANT|inventory cant|not_for_inventory|not for inventory)>/i
      INVENTORY_LIMIT = /<(?:INVENTORY_LIMIT|inventory limit):[ ]*(\d+)>/i
      
      # Used by equipment
      EQUIP_INVENTORY = /<(?:EQUIP_INVENTORY|equip inventory|max_equip_item|max equip item):[ ]*([\+\-]\d+)>/i
      
      # Used by encumber state ** Incomplete
      ENCUMBER_STATE = /<(?:ENCUMBERANCE|encumber|encumbered)>/i
      CANT_ATTACK = /<(?:CANT_ATTACK|cant attack)>/i
      CANT_USE_SKILL = /<(?:CANT_USE_SKILL|cant use skill)>/i
      STAT_ENCUM = /<(\w+)[ ](?:STAT_CHANGE|stat change):[ ]*([\+\-]\d+)(?:%|%)-(\w+)>/i
      
      # Skill Tags
      BREAK_ITEM = /<(?:BREAK_ITEM|break item|break_items|break items):[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      BREAK_AT_RANDOM = /<(?:BREAK_RANDOM_ITEM|break random item)>/i
      BREAK_ALL_ITEMS = /<(?:BREAK_ALL_ITEMS|break all items)>/i
      
      JETIISON_ITEMS = /<(?:JETTISON_ITEM|jettison item|JETTISON_ITEMS|jettison items):[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      REQUIRE_ITEMS = /<(?:REQUIRE_ITEM|require item|REQUIRE_ITEMS|require items):[ ]*(\d+(?:\s*,\s*\d+)*)>/i
    end
  end
end

#==============================================================================#
# ** RPG::BaseItem
#==============================================================================#
class RPG::BaseItem

  #--------------------------------------------------------------------------#
  # * new-method :iex_build_inventory_cache
  #--------------------------------------------------------------------------#
  def iex_build_inventory_cache()
    @equip_inventory = 0
    @inventory_cant = false
    @inventory_limit = IEX::ACTOR_INVENTORY::INVEN_ITEM_LIMIT
    self.note.split(/[\r\n]+/).each { |line| 
      case line
      when IEX::REGEXP::ACTOR_INVENTORY::INVENTORY_CANT
        @inventory_cant = true
      when IEX::REGEXP::ACTOR_INVENTORY::INVENTORY_LIMIT
        @inventory_limit = $1.to_i
      when IEX::REGEXP::ACTOR_INVENTORY::EQUIP_INVENTORY
        @equip_inventory = $1.to_i
      end
    }
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :cant_use_for_inventory?
  #--------------------------------------------------------------------------#
  def cant_use_for_inventory?()
    iex_build_inventory_cache if @inventory_cant.nil?()
    return @inventory_cant
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :change_to_inventory
  #--------------------------------------------------------------------------#  
  def change_to_inventory()
    iex_build_inventory_cache if @equip_inventory.nil?()
    return @equip_inventory
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :limited_item_amt
  #--------------------------------------------------------------------------#  
  def limited_item_amt()
    iex_build_inventory_cache if @inventory_limit.nil?()
    return @inventory_limit
  end
  
end

#==============================================================================#
# ** RPG::Skill
#==============================================================================#
class RPG::Skill
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_build_act_inv_rpg_skill_cache
  #--------------------------------------------------------------------------# 
  def iex_build_act_inv_rpg_skill_cache()
    @break_items = []
    @break_random = false
    @break_all = false
    @require_item = []
    @jettison_item = []
    
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when IEX::REGEXP::ACTOR_INVENTORY::BREAK_ITEM 
      $1.scan(/\d+/).each { |num| 
      @break_items.push(num.to_i) }
    when IEX::REGEXP::ACTOR_INVENTORY::BREAK_AT_RANDOM
      @break_random = true
    when IEX::REGEXP::ACTOR_INVENTORY::BREAK_ALL_ITEMS
      @break_all = true
    when IEX::REGEXP::ACTOR_INVENTORY::REQUIRE_ITEMS
      $1.scan(/\d+/).each { |num| 
      @require_item.push(num.to_i) }
    when IEX::REGEXP::ACTOR_INVENTORY::JETIISON_ITEMS
      $1.scan(/\d+/).each { |num| 
      @jettison_item.push(num.to_i) }
    end    
      }
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :break_items
  #--------------------------------------------------------------------------# 
  def break_items()
    iex_build_act_inv_rpg_skill_cache if @break_items.nil?()
    return @break_items
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :break_random_item
  #--------------------------------------------------------------------------# 
  def break_random_item()
    iex_build_act_inv_rpg_skill_cache if @break_random.nil?()
    return @break_random
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :break_all_items
  #--------------------------------------------------------------------------# 
  def break_all_items()
    iex_build_act_inv_rpg_skill_cache if @break_all.nil?()
    return @break_all
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :require_items
  #--------------------------------------------------------------------------# 
  def require_items()
    iex_build_act_inv_rpg_skill_cache if @require_item.nil?()
    return @require_item
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :jettison_items
  #--------------------------------------------------------------------------#  
  def jettison_items()
    iex_build_act_inv_rpg_skill_cache if @jettison_item.nil?()
    return @jettison_item
  end
  
end

#==============================================================================#
# ** RPG::State ** Incomplete
#==============================================================================#
class RPG::State

  #--------------------------------------------------------------------------#
  # * new-method :iex_build_inventory_state_cache
  #--------------------------------------------------------------------------#   
  def iex_build_inventory_state_cache()
    @encumber_state = false
    @cant_attack = false
    @cant_use_skill = false
    
    @iex_inv_stat_change = {}
    @iex_inv_stat_change["ATK"] = [false, 0, "S"]
    @iex_inv_stat_change["DEF"] = [false, 0, "S"]
    @iex_inv_stat_change["MAG"] = [false, 0, "S"]
    @iex_inv_stat_change["AGI"] = [false, 0, "S"]
    
    self.note.split(/[\r\n]+/).each { |line|
    case line
      when IEX::REGEXP::ACTOR_INVENTORY::ENCUMBER_STATE
        @encumber_state
      when IEX::REGEXP::ACTOR_INVENTORY::CANT_ATTACK
        @cant_attack = true
      when IEX::REGEXP::ACTOR_INVENTORY::CANT_USE_SKILL
        @cant_use_skill = true
      when IEX::REGEXP::ACTOR_INVENTORY::STAT_ENCUM  
       case $1.to_s.upcase
         when /(?:ATK)/i
           @iex_inv_stat_change["ATK"] = [true, $2.to_i, $3.to_s.upcase]
         when /(?:DEF)/i
           @iex_inv_stat_change["DEF"] = [true, $2.to_i, $3.to_s.upcase]
         when /(?:SPI|MAG)/i
           @iex_inv_stat_change["MAG"] = [true, $2.to_i, $3.to_s.upcase]
         when /(?:AGI|SPD)/i
           @iex_inv_stat_change["AGI"] = [true, $2.to_i, $3.to_s.upcase]
       end  
    end  
    }
  end
  
end

#==============================================================================#
# ** IEX_Inventory_Slot
#==============================================================================#
class IEX_Inventory_Slot
  
  attr_accessor :id
  attr_accessor :item_id
  attr_accessor :item_number
  attr_accessor :overstock
  
  def initialize(id = 0)
    @id = id
    clear_item
    @overstock = false
    @item_id = 0
  end
  
  def clear_item
    @item_id = 0
    @item_number = 0
  end
  
  def gain_item(n)
    @item_number = [[@item_number + n, $data_items[@item_id].limited_item_amt].min, 0].max
    if @item_number == 0
      clear_item
    end
  end
    
  def lose_item(n)
    gain_item(-n)
  end
  
  def set_item(item_id, n)
    return if $data_items[item_id] == nil
    @item_id = item_id
    @item_number = n
    if @item_number <= 0
      clear_item
    end
  end
  
  def empty?
    return true if (@item_id == 0 and @item_number == 0)
    return false
  end
  
  def full?
    return false if @item_id == 0
    return true if @item_number >= item.limited_item_amt.to_i
    return false if empty?
    return false
  end
  
  def has_space?
    return true if @item_id == 0
    return true if @item_number < item.limited_item_amt.to_i
    return false
  end
  
  def item
    return $data_items[@item_id]
  end
  
  def item_limit
    return item.limited_item_amt.to_i
  end
  
end

#==============================================================================
# ** IEX_Actor_Inventory
#==============================================================================
class IEX_Actor_Inventory
  
  attr_accessor :actor_id
  attr_accessor :slots
  attr_accessor :general_size
  
  def initialize(actor_id, slot_num)
    @slots = []
    @actor_id = actor_id
    @general_size = slot_num 
    for i in 0..(slot_num - 1)
      @slots.push(IEX_Inventory_Slot.new)
    end  
    reset_slot_ids
  end
  
  def inv_size
    return @slots.size
  end
  
  def change_size(new_size = @general_size)
    old_size = @slots.size
    if new_size > old_size
      size = (new_size - 1) - @slots.size
      for i in 0..size
        add_slot
      end
    else   
      strip_size = @slots.size - new_size
      for i in 0...strip_size
        if @slots[i] != nil
          remove_slot#(i)
        end
      end
      reset_slot_ids
    end
  end
  
  def add_slot
    @slots.push(IEX_Inventory_Slot.new)
    reset_slot_ids
  end
  
  def remove_slot
    @slots.pop
    @slots = @slots.compact
  end
  
  def reset_slot_ids
    for i in 0..@slots.size
      next if @slots[i] == nil
      @slots[i].id = i
    end
  end
  
  def full?
    ff = []
    for sl in @slots
      return false if sl.has_space?
    end
    return true
  end
  
  def empty?
    for sl in @slots
      return false unless sl.empty?
    end  
    return true
  end
  
  def clear_inventory
    for slo in @slots
      lose_item(slo.item, slo.item_number)
    end  
  end
  
  def clear_random
    loop {
    break if empty?
     itemzs_st = items
      ite = itemzs_st[rand(itemzs_st.size)]
      if ite[0] != nil
        lose_item(ite[0], 1, ite[1])
        break
      end  
    }  
  end
  
  def items
    ite = []
    for sl in @slots
      ite.push([$data_items[sl.item_id], sl.id])
    end
    return ite
  end
  
  def only_items
    ite = []
    for sl in @slots
      ite.push($data_items[sl.item_id])
    end
    return ite
  end
  
  def gain_item(ite, n, slot = nil)
    return unless ite.is_a?(RPG::Item)
    amt = n
    lim = ite.limited_item_amt 
    for slo in @slots
      if slo.item_id.to_i == ite.id.to_i
        next if slo.full?
        d = [amt, slo.item_limit - slo.item_number].min
        slo.gain_item(d)
        amt = [amt - d, 0].max
      elsif slo.empty?
        d = [amt, lim].min
        slo.set_item(ite.id, d)
        amt -= d
      end
    end
  end
  
  def lose_item(ite, n = 0, slot = nil)
    return unless ite.is_a?(RPG::Item)
    amt = n
    lim = ite.limited_item_amt
    for slo in @slots
      if slo.item_id == ite.id
        d = [amt, lim].min
        slo.lose_item(d)
        amt -= d
      end
    end
  end
  
  def has_item?(ite)
    for slo in @slots
      return true if slo.item.id == ite.id
    end
    return false
  end
  
end

#==============================================================================#
# ** Game_Battler
#==============================================================================#
class Game_Battler 
  
  def is_a_merchant?
    return false
  end
  
  def item_can_use?(item)
    return false
  end
  
  def has_item?(item)
    return false
  end
  
end  

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler
  
  attr_accessor :last_item_index
  
  alias iex_actor_inventory_initialize initialize unless $@
  def initialize( *args, &block )
    iex_actor_inventory_initialize( *args, &block )
    make_inventory
  end
  
  def make_inventory
    if IEX::ACTOR_INVENTORY::ACTOR_LIMITS.has_key?(@actor_id)
      num = IEX::ACTOR_INVENTORY::ACTOR_LIMITS[@actor_id]
    else
      num = IEX::ACTOR_INVENTORY::ACTOR_LIMITS[0]
    end  
    @inventory = IEX_Actor_Inventory.new(@actor_id, num)
    @last_item_index = 0 
  end
  
  def actor_inventory
    return @inventory
  end
  
  #--------------------------------------------------------------------------
  # * Determine Usable Skills
  #     skill : skill
  #--------------------------------------------------------------------------
  alias iex_actor_inven_skill_can_use? skill_can_use? unless $@
  def skill_can_use?(skill)
    return false unless skill.is_a?(RPG::Skill)
    return false unless movable?
    return false if silent? and skill.spi_f > 0
    return false if calc_mp_cost(skill) > mp
    unless skill.require_items.empty?
      need = []
      for ite in skill.require_items
        need.push($data_items[ite])
      end  
      return false unless need.all? { |itz| @inventory.has_item?(itz)}
    end  
    iex_actor_inven_skill_can_use?(skill)
  end
  
  alias iex_act_inv_make_obj_damage_value make_obj_damage_value unless $@
  def make_obj_damage_value(user, obj)
    dama = iex_act_inv_make_obj_damage_value(user, obj)
      if obj.break_all_items
        @inventory.clear_inventory
      elsif obj.break_random_item
        @inventory.clear_random
      end  
      bera = obj.break_items
      unless bera.empty?
        for ite in bera
          lose_item($data_items[ite])
        end
      end 
      if user.actor?
        jeti = obj.jettison_items
        unless jeti.empty?
          for jet_ite in jeti
            user.lose_item($data_items[jet_ite])
          end
        end  
      end  
    return dama
  end
  
  def has_item?(item)
    return @inventory.has_item?(item)
  end
  
  alias iex_actor_inventory_change_equip change_equip unless $@
  def change_equip( *args, &block )
    iex_actor_inventory_change_equip( *args, &block )
    change_inventory_size
  end
  
  def change_inventory_size(n = nil) 
    if n == nil
      lim = inventory_limit
      @inventory.change_size(lim)
    else
      @inventory.change_size(n.to_i)
    end  
  end
  
  def inventory_limit
    make_inventory if @inventory == nil
    lim = 0
    lim = [lim + @inventory.general_size, 0].max
    for eqp in equips
      next unless eqp.is_a?(RPG::Armor) or eqp.is_a?(RPG::Weapon)
      lim = [lim + eqp.change_to_inventory, 0].max
    end 
    return lim
  end
   
  def inventory_real_size
    return @inventory.inv_size
  end
  
  def inventory_empty?
    if is_a_merchant?
      return $game_party.items.empty?
    else
      return @inventory.empty?
    end  
  end
   
  def inventory_full?
    if is_a_merchant?
      return false
    else  
      return @inventory.full?
    end  
  end
  
  def inventory
    if is_a_merchant?
      prop_ite = []
      for ite in $game_party.items
        prop_ite.push([prop_ite, nil])
      end  
      return prop_ite
    else
      return @inventory.items
    end
  end
  
  def inventory_valid? # Can any of the items in the inventory be used?
    for item in inventory
      next if item[0] == nil
      return true if item_can_use?(item[0])
    end 
    return false
  end
  
  def is_a_merchant?
    merch = IEX::ACTOR_INVENTORY::MERCHANT_CLASSES
    return true if merch.include?(@class_id)
    return false
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Item is Usable
  #     item : item
  #--------------------------------------------------------------------------
  def item_can_use?(item)
    return false unless item.is_a?(RPG::Item)
    return false if inventory_number(item) == 0
    if $game_temp.in_battle
      return item.battle_ok?
    else
      return item.menu_ok?
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get Number of Items Possessed
  #     item : item
  #--------------------------------------------------------------------------
  def inventory_number(item, slot = nil)
    if self.is_a_merchant?
      return $game_party.item_number(item)
    else  
      number = 0
      if slot == nil
        for ite in @inventory.slots
          next if ite == nil
          next if ite.item_id == nil
          if ite.item_id == item.id
            number += ite.item_number
          end
        end  
      else
        number = @inventory.slots[slot].item_number
      end  
      return number == nil ? 0 : number
    end  
  end
  
  #--------------------------------------------------------------------------
  # * Gain Items (or lose)
  #     item          : Item
  #     n             : Number
  #     include_equip : Include equipped items
  #--------------------------------------------------------------------------
  def gain_item(item, n, slot = nil)
    return unless item.is_a?(RPG::Item)
    if is_a_merchant?
      $game_party.gain_item(item, n)
    else  
      return if inventory_full? and n > 0
      @inventory.gain_item(item, n, slot)
    end  
  end
  #--------------------------------------------------------------------------
  # * Lose Items
  #     item          : Item
  #     n             : Number
  #--------------------------------------------------------------------------
  def lose_item(item, n, slot = nil)
    if is_a_merchant?
      $game_party.lose_item(item, n)
    else  
      @inventory.lose_item(item, n, slot)
    end  
  end
  #--------------------------------------------------------------------------
  # * Consume Items
  #     item : item
  #    If the specified object is a consumable item, the number in investory
  #    will be reduced by 1.
  #--------------------------------------------------------------------------
  def consume_item(item, slot = nil)
    if item.is_a?(RPG::Item) and item.consumable
      lose_item(item, 1, slot)
    end
  end
  
  def send_to_inventory(item, num, slot = nil)
    number = [inventory_number(item, slot), num].min
    $game_party.gain_item(item, number)
    lose_item(item, number, slot)
  end
  
  def send_inventory_to_party
    for slo in @inventory.slots
      $game_party.gain_item(slo.item, slo.item_number)
      lose_item(slo.item, slo.item_number, slo.id)
    end 
  end
  
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#==============================================================================
class Game_Party < Game_Unit
  
  def send_item_to_actor(actor, item, n)
    return if n <= 0
    return unless item.is_a?(RPG::Item)
    return if actor == nil
    return unless actor.is_a?(Game_Actor)
    return if actor.inventory_full?
    num = [item_number(item), n].min
    lose_item(item, num)
    actor.gain_item(item, num)
  end
  
end

#==============================================================================
# Window_Command (imported from KGC)
#==============================================================================

class Window_Command < Window_Selectable
unless method_defined?(:add_command)
  #--------------------------------------------------------------------------
  # add command
  #--------------------------------------------------------------------------
  def add_command(command)
    @commands << command
    @item_max = @commands.size
    item_index = @item_max - 1
    refresh_command
    draw_item(item_index)
    return item_index
  end
  #--------------------------------------------------------------------------
  # refresh command
  #--------------------------------------------------------------------------
  def refresh_command
    buf = self.contents.clone
    self.height = [self.height, row_max * WLH + 32].max
    create_contents
    self.contents.blt(0, 0, buf, buf.rect)
    buf.dispose
  end
  #--------------------------------------------------------------------------
  # insert command
  #--------------------------------------------------------------------------
  def insert_command(index, command)
    @commands.insert(index, command)
    @item_max = @commands.size
    refresh_command
    refresh
  end
  #--------------------------------------------------------------------------
  # remove command
  #--------------------------------------------------------------------------
  def remove_command(command)
    @commands.delete(command)
    @item_max = @commands.size
    refresh
  end
end
end

#==============================================================================
# ** IEX_Header_Window
#------------------------------------------------------------------------------
#  This window displays a header.
#==============================================================================
class IEX_Actor_Inventory_Header < Window_Base

  attr_accessor :font_size
  attr_accessor :font_color
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x      : window x-coordinate
  #     y      : window y-coordinate
  #     width  : window width
  #     height : window height
  #-------------------------------------------------------------------------- 
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @old_text = nil
    @font_color = system_color
    reset_font_size
  end
  #--------------------------------------------------------------------------
  # ** Reset Font Size
  #   Resets the font size to 26
  #--------------------------------------------------------------------------
  def reset_font_size
    @font_size = 26
  end
  
  #--------------------------------------------------------------------------
  # ** Set Header
  #     text   : text
  #     icon   : icon_index
  #     align  : align
  #-------------------------------------------------------------------------- 
  def set_header(text = "", icon = nil, align = 0)
    return if @old_text == text
    self.contents.clear
    icon_offset = 32
    if icon == nil
      x = 0
    else
      x = icon_offset
      draw_icon(icon, 0, 0)
    end
     y = 0
     old_font_size = self.contents.font.size
     self.contents.font.size = @font_size
     self.contents.font.color = @font_color
     self.contents.draw_text(x, y, (self.width - x) - 48, WLH, text, align)
     self.contents.font.color = normal_color
     self.contents.font.size = old_font_size
     @old_text = text
  end
  
end

#==============================================================================
# ** IEX_Window_Actor_Inventory
#------------------------------------------------------------------------------
#==============================================================================
class IEX_Window_Actor_Inventory < ICY_HM_Window_Selectable
  
  include IEX::ACTOR_INVENTORY
  
  def initialize(actor = nil, x = 0, y = 0, width = Graphics.width, height = Graphics.height)
    super(x, y, width, height)
    self.active = false
    @actor = actor
    self.index = @actor.last_item_index
    @column_max = NUMBER_COLUMNS
    @item_sq_spacing = ITEM_SQ_SPACING
    @rect_size = RECT_SIZE
    @selection_size = SELECTION_SIZE
    refresh
  end
  
  #--------------------------------------------------------------------------
  # * Get Item
  #--------------------------------------------------------------------------
  def item
    return @commands[self.index][0]
  end
  
  def all_items
    new = []
    for com in @commands
      new.push(com[0])
    end
    return new
  end
  
  def limit
    return @commands[self.index][1]
  end
  
  #--------------------------------------------------------------------------
  # * Whether or not to include in item list
  #     item : item
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    if $game_temp.in_battle
      return false unless item.is_a?(RPG::Item)
    end
    return true
  end
  
  def refresh
    super
    @commands = []
    return if @actor == nil    
    if @actor.is_a_merchant?
      for item in $game_party.items
        next unless include?(item)
        @commands.push([item, nil])
      end
    else
      @commands = @actor.inventory
    end 
    @item_max = @actor.inventory_real_size
    if @actor.is_a_merchant?
      act_limit = @actor.inventory_real_size + 1
    else  
      act_limit = @actor.inventory_limit
    end  
    self.contents.clear
    create_contents
    counz = 0
    for ite in @commands
      if counz >= act_limit
        over = true 
      else
        over = false
      end  
      draw_item(ite[0], ite[1], over)
      counz += 1
    end
    update
  end
  
  def draw_item(item, slot = nil, overstock = false)
    if overstock
      color = crisis_color
    else
      color = system_color
    end
    draw_border_rect(@nw_x, @nw_y, RECT_SIZE, RECT_SIZE, 4, color)
    unless item == nil
      numberbox = Rect.new(@nw_x + ITEM_NUM_POS[0],@nw_y + ITEM_NUM_POS[1], RECT_SIZE, RECT_SIZE)
      usable = @actor.item_can_use?(item)   
      draw_icon(item.icon_index, @nw_x + ITEM_ICON_POS[0], @nw_y + ITEM_ICON_POS[1], usable) 
      if @actor.is_a_merchant?
        number = $game_party.item_number(item)
      else  
        number = @actor.inventory_number(item, slot)
      end  
      # Writes Item Amount
      old_font_size = self.contents.font.size
      self.contents.font.size = 16
      if DRAW_AMOUNT_FOR_1
        self.contents.draw_text(numberbox, sprintf(ITEM_NUM_FORMAT, number), ITEM_NUM_ALIGN) 
      elsif DRAW_AMOUNT_FOR_1 == false and number > 1 
        self.contents.draw_text(numberbox, sprintf(ITEM_NUM_FORMAT, number), ITEM_NUM_ALIGN) 
      end
      self.contents.font.size = old_font_size
    end  
    advance_space
  end
  
end

#==============================================================================
# ** IEX_Window_Main_Inventory * Used to show party inventory
#------------------------------------------------------------------------------
#==============================================================================
class IEX_Window_Main_Inventory < ICY_HM_Window_Selectable
  
  include IEX::ACTOR_INVENTORY
  
  def initialize(x = 0, y = 0, width = Graphics.width, height = Graphics.height)
    super(x, y, width, height)
    self.active = false
    self.index = 0
    @column_max = NUMBER_COLUMNS
    @item_sq_spacing = ITEM_SQ_SPACING
    @rect_size = RECT_SIZE
    @selection_size = SELECTION_SIZE
    refresh
  end
  
  #--------------------------------------------------------------------------
  # * Get Item
  #--------------------------------------------------------------------------
  def item
    return @commands[self.index]
  end
  
  def refresh
    super
    @commands = []
    for it in $game_party.items
      if it.is_a?(RPG::Item)
       @commands.push(it) unless it.cant_use_for_inventory?
      end
    end
    @item_max = @commands.size
    self.contents.clear
    create_contents
    for ite in @commands
      draw_item(ite)
    end
    update
  end
  
  def draw_item(item)
    next if item == nil
    draw_border_rect(@nw_x, @nw_y, RECT_SIZE, RECT_SIZE, 4)
    numberbox = Rect.new(@nw_x + ITEM_NUM_POS[0],@nw_y + ITEM_NUM_POS[1], RECT_SIZE, RECT_SIZE)
    usable = $game_party.item_can_use?(item)   
    draw_icon(item.icon_index, @nw_x + ITEM_ICON_POS[0], @nw_y + ITEM_ICON_POS[1], usable) 
    number = $game_party.item_number(item)
    # Writes Item Amount
    old_font_size = self.contents.font.size
    self.contents.font.size = 16
    if DRAW_AMOUNT_FOR_1
      self.contents.draw_text(numberbox, sprintf(ITEM_NUM_FORMAT, number), ITEM_NUM_ALIGN) 
    elsif DRAW_AMOUNT_FOR_1 == false and number > 1 
      self.contents.draw_text(numberbox, sprintf(ITEM_NUM_FORMAT, number), ITEM_NUM_ALIGN) 
    end
    self.contents.font.size = old_font_size
    advance_space
  end
  
end

#==============================================================================
# ** IEX_Window_Actor_Inventory_Basic * Used to show items in YEM battle
#------------------------------------------------------------------------------
#==============================================================================
class IEX_Window_Actor_Inventory_Basic < Window_Selectable
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :battle_refresh_call
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x      : window x-coordinate
  #     y      : window y-coordinate
  #     width  : window width
  #     height : window height
  #--------------------------------------------------------------------------
  def initialize(actor, x, y, width, height)
    super(x, y, width, height)
    @column_max = 2
    @actor = actor
    @data = []
    self.index = 0
    refresh
  end
  
  #--------------------------------------------------------------------------
  # new method: update
  #--------------------------------------------------------------------------
  def update
    if @battle_refresh_call
      $game_temp.less_spacing = true
      refresh
      @battle_refresh_call = false
      $game_temp.less_spacing = nil
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Get Item
  #--------------------------------------------------------------------------
  def item
    if @data[self.index] != nil
      return @data[self.index][0]
    else
      return nil
    end
  end
  
  def limit
    return @commands[self.index][1]
  end
  
  #--------------------------------------------------------------------------
  # * Whether or not to include in item list
  #     item : item
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    if $game_temp.in_battle
      return false unless item.is_a?(RPG::Item)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Whether or not to display in enabled state
  #     item : item
  #--------------------------------------------------------------------------
  def enable?(item)
    return @actor.item_can_use?(item)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    @data = []
    return if @actor == nil
    if @actor.is_a_merchant?
      for item in $game_party.items
        next unless include?(item)
        @data.push([item, nil])
      end
    else
      for item in @actor.inventory
        next unless include?(item[0])
        @data.push(item)
      end
    end  
    self.index = @actor.last_item_index
    @data.push(nil) if include?(nil)
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = @data[index]
    if item != nil
      rect.width -= 4
      if @actor.is_a_merchant?
        number = $game_party.item_number(item[0])
      else  
        number = @actor.inventory_number(item[0], item[1])
      end      
      enabled = enable?(item[0])
      draw_item_name(item[0], rect.x, rect.y, enabled)
      self.contents.draw_text(rect, sprintf(":%2d", number), 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item == nil ? "" : item.description)
  end
  
end

#==============================================================================#
# ** IEX_WindowNumber
#==============================================================================#
class IEX_WindowNumber < Window_Base

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(x, y)
    super(x, y, 304, 96)
    @item = nil
    @max = 1
    @price = 0
    @number = 1
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :set
  #--------------------------------------------------------------------------#
  def set( item, max )
    @item = item
    @max = max
    @number = 1
    refresh
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :number
  #--------------------------------------------------------------------------#
  def number() ; return @number ; end
  
  #--------------------------------------------------------------------------#
  # * super-method :refresh
  #--------------------------------------------------------------------------#
  def refresh()
    y = 0
    self.contents.clear
    draw_item_name(@item, 32, y)
    self.contents.font.color = normal_color
    self.contents.draw_text(162, y + 32, 20, WLH, @max)
    self.contents.draw_text(186, y + 32, 20, WLH, "/")
    self.contents.draw_text(210, y + 32, 20, WLH, @number, 2)
    self.cursor_rect.set(210, y + 32, 28, WLH)
  end
  
  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
  def update()
    super()
    if self.active
      last_number = @number
      if Input.repeat?(Input::RIGHT) and @number < @max
        @number += 1
      end
      if Input.repeat?(Input::LEFT) and @number > 0
        @number -= 1
      end
      if Input.repeat?(Input::UP) and @number < @max
        @number = [@number + 10, @max].min
      end
      if Input.repeat?(Input::DOWN) and @number > 0
        @number = [@number - 10, 0].max
      end
      if @number != last_number
        Sound.play_cursor
        refresh
      end
    end
  end
  
end

#==============================================================================#
# ** Game_BattleAction
#==============================================================================#
class Game_BattleAction
  
  
  #--------------------------------------------------------------------------#
  # * overwrite-method :valid?
  #--------------------------------------------------------------------------#
  def valid?()
    return false if nothing?                      # Do nothing
    return true if @forcing                       # Force to act
    return false unless battler.movable?          # Cannot act
    if skill?                                     # Skill
      return false unless battler.skill_can_use?(skill)
    elsif item?                                   # Item
      return false unless battler.item_can_use?(item)
    end
    return true
  end unless $imported["BattleEngineMelody"]
  
end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler
    
  #--------------------------------------------------------------------------#
  # * new-method :perform_consume_item
  #--------------------------------------------------------------------------#
  def perform_consume_item( item )
    return if item == nil or !item.is_a?(RPG::Item)
    consume_item(item)
  end if $imported["BattleEngineMelody"]

end

#==============================================================================#
# ** Game_Interpreter
#==============================================================================#
class Game_Interpreter

  #--------------------------------------------------------------------------#
  # * new-method :actor_inventory
  #--------------------------------------------------------------------------#  
  def actor_inventory( actor_id )
    return if $game_actors[actor_id] == nil
    $scene = IEX_Scene_Actor_Inventory.new($game_actors[actor_id])
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :add_to_actor_inventory
  #--------------------------------------------------------------------------#  
  def add_to_actor_inventory(actor_id, item_id, n)
    return if $game_actors[actor_id] == nil
    $game_actors[actor_id].gain_item($data_items[item_id], n)
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :remove_from_actor_inventory
  #--------------------------------------------------------------------------#   
  def remove_from_actor_inventory(actor_id, item_id, n)
    return if $game_actors[actor_id] == nil
    $game_actors[actor_id].lose_item($data_items[item_id], n)
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :clear_actor_inventory
  #--------------------------------------------------------------------------#  
  def clear_actor_inventory( actor_id )
    return if $game_actors[actor_id] == nil
    $game_actors[actor_id].actor_inventory.clear_inventory
  end
  
end

#==============================================================================#
# ** Window_ActorCommand
#==============================================================================#
class Window_ActorCommand < Window_Command
  
  if $imported["BattleEngineMelody"]
    #--------------------------------------------------------------------------#
    # * new-method :enabled?
    #--------------------------------------------------------------------------#
    alias iex_actor_inventory_enabled? enabled? unless $@
    def enabled?( obj=nil )
      return false unless @actor.actor?
      if obj == "item".to_sym
        return false unless @actor.inventory_valid?
      end  
      iex_actor_inventory_enabled?(obj)    
    end
  end  
  
end

#===============================================================================#
# Scene Menu
#===============================================================================#
class Scene_Menu < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias create command window
  #--------------------------------------------------------------------------
  alias iex_actor_inventory_sm_ccw create_command_window unless $@
  def create_command_window( *args, &block )
    iex_actor_inventory_sm_ccw( *args, &block )
    if IEX::ACTOR_INVENTORY::ALLOW_INVENTORY_MENU
      text = IEX::ACTOR_INVENTORY::INVENTORY_TEXT_NAME
      @command_actor_inventory = @command_window.add_command(text)
      if @command_window.oy > 0
        @command_window.oy -= Window_Base::WLH
      end
    end
    @command_window.index = @menu_index
  end
  
  #--------------------------------------------------------------------------
  # alias update command selection
  #--------------------------------------------------------------------------
  alias iex_actor_inventory_sm_ucs update_command_selection unless $@
  def update_command_selection( *args, &block )
    iex_act_inv_command = 0
    if Input.trigger?(Input::C)
      case @command_window.index
      when @command_actor_inventory
        iex_act_inv_command = 1
      end
    end
    if iex_act_inv_command == 1
      if $game_party.members.size == 0
        Sound.play_buzzer
        return
      end
      Sound.play_decision
      start_actor_selection
      return
    end
    iex_actor_inventory_sm_ucs( *args, &block )
  end
  
  #--------------------------------------------------------------------------
  # alias update actor selection
  #--------------------------------------------------------------------------
  alias iex_actor_inventory_sm_uas update_actor_selection unless $@
  def update_actor_selection( *args, &block )
    if Input.trigger?(Input::C)
      $game_party.last_actor_index = @status_window.index
      Sound.play_decision
      case @command_window.index
      when @command_actor_inventory
        @menu_index = @command_window.index
        actor = $game_party.members[@status_window.index]
        $scene = IEX_Scene_Actor_Inventory.new(actor, true)
        return
      end
    end
    iex_actor_inventory_sm_uas( *args, &block )
  end
  
end # Scene Menu

#==============================================================================#
# ** Scene_Battle
#==============================================================================#
class Scene_Battle < Scene_Base
  
  unless $imported["BattleEngineMelody"]
  #--------------------------------------------------------------------------
  # * Start Item Selection
  #--------------------------------------------------------------------------
  def start_item_selection
    @help_window = Window_Help.new
    @item_window = IEX_Window_Actor_Inventory.new(@active_battler, 0, 56, Graphics.width, 232)
    @item_window.help_window = @help_window
    @actor_command_window.active = false
  end
  
  #--------------------------------------------------------------------------#
  # * Update Item Selection
  #--------------------------------------------------------------------------#
  def update_item_selection()
    @item_window.active = true
    @item_window.update
    @help_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_item_selection
    elsif Input.trigger?(Input::C)
      @item = @item_window.item
      if @item != nil
        @active_battler.last_item_index = @item_window.index
      end
      if @active_battler.item_can_use?(@item)
        Sound.play_decision
        determine_item
      else
        Sound.play_buzzer
      end
    end
  end
   
  #--------------------------------------------------------------------------#
  # * Execute Battle Action: Item
  #--------------------------------------------------------------------------#
  def execute_action_item()
    item = @active_battler.action.item
    text = sprintf(Vocab::UseItem, @active_battler.name, item.name)
    @message_window.add_instant_text(text)
    targets = @active_battler.action.make_targets
    display_animation(targets, item.animation_id)
    @active_battler.consume_item(item)
    $game_temp.common_event_id = item.common_event_id
    for target in targets
      target.item_effect(@active_battler, item)
      display_action_effects(target, item)
    end
  end
  
  else
  
  #--------------------------------------------------------------------------#
  # overwrite method :start_item_selection
  #--------------------------------------------------------------------------#
  def start_item_selection()
    dx = 0; dy = Graphics.height-128; dw = Graphics.width - 128; dh = 128
    $game_temp.less_spacing = true
    @item_window = IEX_Window_Actor_Inventory_Basic.new(@selected_battler, dx, dy, dw, dh)
    @item_window.help_window = @view_help_window
    @actor_command_window.active = false
    create_mini_window
    pause_atb(true) if semi_wait_atb? or wait_atb?
  end
  
end

end

#==============================================================================#
# ** IEX_Scene_Actor_Inventory
#==============================================================================#
class IEX_Scene_Actor_Inventory < Scene_Base
  
  def initialize(actor, called = false)
    if actor.kind_of?(Game_Battler)
      @actor = actor
    elsif actor != nil  
      @actor = $game_party.members[actor]
      called = true
    else 
      @actor = nil
    end  
    @call_from_menu = called
  end
  
  def start
    super
    create_menu_background
    @windows = {}
    sq_width = Graphics.width / 2
    @windows["Inventory"] = IEX_Window_Actor_Inventory.new(@actor, 0, 112, sq_width, 248)    
    @windows["MainInve"] = IEX_Window_Main_Inventory.new(sq_width, 112, sq_width, 248)
    
    if @actor.inventory_empty?
      @windows["Inventory"].active = false
      @windows["MainInve"].active = true
    else
      @windows["Inventory"].active = true
      @windows["MainInve"].active = false
    end  
    
    @windows["Help"] = IEX_Actor_Inventory_Header.new(0, 56, Graphics.width, 56)
    @windows["Help"].font_color = @windows["Help"].normal_color
    @windows["Help"].font_size = 19
    
    @windows["MainHelp"] = IEX_Actor_Inventory_Header.new(0, 360, Graphics.width, 56)
    @windows["MainHelp"].font_color = @windows["Help"].normal_color
    @windows["MainHelp"].font_size = 19
    
    form = "%1$s's %2$s"
    header = sprintf(form, @actor.name, IEX::ACTOR_INVENTORY::ITEM_HEADER)
    icon = 0
    @windows["Header"] = IEX_Actor_Inventory_Header.new(0, 0, Graphics.width, 56)
    @windows["Header"].set_header(header, icon, 1)
    @to_actor = false
    @to_inventory = false
    create_commands
  end
  
  def create_commands
    sq_width = Graphics.width / 3
    pos_x = (Graphics.width - sq_width) / 2
    pos_y = (Graphics.height - (32 + (24 * 4))) / 2
    commands_act = [IEX::ACTOR_INVENTORY::SWITCH_TO_INVENTORY, 
    IEX::ACTOR_INVENTORY::SEND_TO_INVENTORY, IEX::ACTOR_INVENTORY::SEND_ALL_TO_INVENTORY, IEX::ACTOR_INVENTORY::CANCEL]
    commands_inv = [IEX::ACTOR_INVENTORY::SWITCH_TO_ACTOR, 
    IEX::ACTOR_INVENTORY::SEND_TO_ACTOR, IEX::ACTOR_INVENTORY::CANCEL]
   #commands_act = [IEX::ACTOR_INVENTORY::USE_ITEM, IEX::ACTOR_INVENTORY::SWITCH_TO_INVENTORY, 
   #IEX::ACTOR_INVENTORY::SEND_TO_INVENTORY, IEX::ACTOR_INVENTORY::SEND_ALL_TO_INVENTORY, IEX::ACTOR_INVENTORY::CANCEL]
   #commands_inv = [IEX::ACTOR_INVENTORY::USE_ITEM, IEX::ACTOR_INVENTORY::SWITCH_TO_ACTOR, 
   #IEX::ACTOR_INVENTORY::SEND_TO_ACTOR, IEX::ACTOR_INVENTORY::CANCEL]
    @windows["Act_To_Inventory"] = Window_Command.new(sq_width, commands_act)
    @windows["Act_To_Inventory"].x = pos_x
    @windows["Act_To_Inventory"].y = pos_y
    @windows["Inventory_To_Act"] = Window_Command.new(sq_width, commands_inv)
    @windows["Inventory_To_Act"].x = pos_x
    @windows["Inventory_To_Act"].y = pos_y
    commands_con = [IEX::ACTOR_INVENTORY::CONFIRM, IEX::ACTOR_INVENTORY::CANCEL]
    @windows["Confirm"] = Window_Command.new(sq_width, commands_con)
    @windows["Confirm"].x = pos_x
    @windows["Confirm"].y = pos_y
    @windows["Number"] = IEX_WindowNumber.new(pos_x, pos_y)
    act_inv_visible(false)
    inv_act_visible(false)
    confirm_visible(false)
    number_visible(false)
  end
  
  def terminate
    super
    for win in @windows.values
      next if win == nil
      win.dispose
      win = nil
    end
    ensure @windows.clear
    @windows = nil
  end
  
  def update
    super
    update_menu_background
    for win in @windows.values
      next if win == nil
      next unless win.active 
      win.update
    end
    update_input
    update_item_help
    update_help
  end
  
  def update_input
    if Input.trigger?(Input::C)
      if @windows["Inventory"].active
        Sound.play_decision
        act_inv_win_active(false)
        act_inv_visible(true)
      elsif @windows["MainInve"].active
        Sound.play_decision
        inv_win_active(false)
        inv_act_visible(true)
      elsif @windows["Act_To_Inventory"].active
        case @windows["Act_To_Inventory"].commands[@windows["Act_To_Inventory"].index]
        when IEX::ACTOR_INVENTORY::USE_ITEM
          Sound.play_decision
          use_actor_item
        when IEX::ACTOR_INVENTORY::SWITCH_TO_INVENTORY
          if @actor.is_a_merchant?
            Sound.play_buzzer
          else  
            Sound.play_decision
            inv_win_active(true)
            act_inv_visible(false)
          end  
        when IEX::ACTOR_INVENTORY::SEND_TO_INVENTORY 
          unless @windows["Inventory"].item == nil
            if @actor.is_a_merchant?
              Sound.play_buzzer
            else  
              Sound.play_decision
              @to_actor = false
              @to_inventory = true
              act_inv_visible(false)
              start_send_to_inventory
            end
          else
            Sound.play_buzzer
            @windows["MainHelp"].set_header("Item Invalid", 0, 0)
          end
        when IEX::ACTOR_INVENTORY::SEND_ALL_TO_INVENTORY
          if @actor.is_a_merchant?
            Sound.play_buzzer
          else   
            unless @actor.inventory.empty?
              Sound.play_decision
              send_item_to_inventory(true)
              refresh_inventory
            else
              Sound.play_buzzer
              @windows["MainHelp"].set_header("No Items", 0, 0)
            end
          end  
        when IEX::ACTOR_INVENTORY::CANCEL 
          Sound.play_cancel
          act_inv_win_active(true)
          act_inv_visible(false)
        end  
      elsif @windows["Inventory_To_Act"].active
        case @windows["Inventory_To_Act"].commands[@windows["Inventory_To_Act"].index]
        when IEX::ACTOR_INVENTORY::USE_ITEM
          Sound.play_decision
          use_inventory_item
        when IEX::ACTOR_INVENTORY::SWITCH_TO_ACTOR
          Sound.play_decision
          act_inv_win_active(true)
          inv_act_visible(false)
        when IEX::ACTOR_INVENTORY::SEND_TO_ACTOR
          unless @windows["MainInve"].item == nil
            Sound.play_decision
            @to_actor = true
            @to_inventory = false
            inv_act_visible(false)
            start_send_to_actor
          else
            Sound.play_buzzer
            @windows["MainHelp"].set_header("Item Invalid", 0, 0)
          end
        when IEX::ACTOR_INVENTORY::CANCEL 
          Sound.play_cancel
          inv_win_active(true)
          inv_act_visible(false)
        end
      elsif @windows["Number"].active 
         Sound.play_decision
         if @to_actor 
           send_item_to_actor
           inv_win_active(true)
           #inv_act_visible(true)
         elsif @to_inventory 
           send_item_to_inventory
           act_inv_win_active(true)
           #act_inv_visible(true)
         end
         refresh_inventory
         @to_actor = false
         @to_inventory = false
         number_visible(false)
       elsif @windows["Confirm"].active
         case @windows["Confirm"].commands[@windows["Confirm"].index]
         when IEX::ACTOR_INVENTORY::CONFIRM 
           Sound.play_decision
           return_scene
         when IEX::ACTOR_INVENTORY::CANCEL
           Sound.play_cancel
           if @to_actor
             act_inv_win_active(true)
           elsif @to_inventory
             inv_win_active(true)
           end  
            @to_actor = false
            @to_inventory = false
            confirm_visible(false)
         end  
      end
    elsif Input.trigger?(Input::B)
      if @windows["Inventory"].active
        Sound.play_cancel
        @to_actor = true
        @to_inventory = false
        act_inv_win_active(false)
        confirm_visible(true)
      elsif @windows["MainInve"].active
        Sound.play_cancel
        @to_inventory = true
        @to_actor = false
        inv_win_active(false)
        confirm_visible(true)
      elsif @windows["Act_To_Inventory"].active
        Sound.play_cancel
        act_inv_win_active(true)
        act_inv_visible(false)
      elsif @windows["Inventory_To_Act"].active
        Sound.play_cancel
        inv_win_active(true)
        inv_act_visible(false)
      elsif @windows["Number"].active
        Sound.play_cancel
         if @to_actor 
           inv_act_visible(true)
           number_visible(false)
           @to_actor = false
         elsif @to_inventory 
           act_inv_visible(true)
           number_visible(false)
           @to_inventory = false
         end 
      elsif @windows["Confirm"].active
         Sound.play_cancel
         if @to_actor
           act_inv_win_active(true)
         elsif @to_inventory
           inv_win_active(true)
         end  
          @to_actor = false
          @to_inventory = false
          confirm_visible(false)
        end
      elsif Input.trigger?(Input::L)
        for i in 0..$game_party.members.size
          act = $game_party.members[i]
          next if act == nil
          if act.id == @actor.id
            act_index = (i - 1) % $game_party.members.size
            break
          else
            act_index = i
          end
        end  
        $scene = IEX_Scene_Actor_Inventory.new($game_party.members[act_index])
      elsif Input.trigger?(Input::R) 
        for i in 0..$game_party.members.size
          act = $game_party.members[i]
          next if act == nil
          if act.id == @actor.id
            act_index = (i + 1) % $game_party.members.size
            break
          else
            act_index = i
          end
        end 
        $scene = IEX_Scene_Actor_Inventory.new($game_party.members[act_index])
    end
  end
  
  def update_item_help
    return if @windows["Inventory"] == nil
    return if @windows["MainInve"] == nil
    item = @windows["Inventory"].item if @windows["Inventory"].active
    item = @windows["MainInve"].item if @windows["MainInve"].active
    lim = @windows["Inventory"].limit if @windows["Inventory"].active # Is the slots id
    lim = nil if @windows["MainInve"].active
    unless item == nil
      if @actor.is_a_merchant?
        num = $game_party.item_number(item)
      else
        num = @actor.inventory_number(item, lim)
      end  
      text = sprintf('%s x%s - %s', item.name, num, item.description)
      icon = item.icon_index
    else
      text = "......"
      icon = 0
    end  
    @windows["Help"].set_header(text, icon)
  end
  
  def update_help
    return if @windows["MainHelp"] == nil
    if @windows["Inventory"].active
      text = "Currently In #{@actor.name}'s #{IEX::ACTOR_INVENTORY::ITEM_HEADER}"
      icon = 0
    elsif @windows["MainInve"].active
      text = "Currently In Party's #{IEX::ACTOR_INVENTORY::ITEM_HEADER}"
      icon = 0
    elsif @windows["Act_To_Inventory"].active
      case @windows["Act_To_Inventory"].commands[@windows["Act_To_Inventory"].index]
      when IEX::ACTOR_INVENTORY::USE_ITEM
        text = "Use selected item?"
        icon = 0       
      when IEX::ACTOR_INVENTORY::SWITCH_TO_INVENTORY
        text = "Switch over to Party's Inventory?"
        icon = 0
      when IEX::ACTOR_INVENTORY::SEND_TO_INVENTORY 
        text = "Send item to Party's Inventory"
        icon = 0
      when IEX::ACTOR_INVENTORY::SEND_ALL_TO_INVENTORY
        text = "Send All Items To Party's Inventory"
        icon = 0
      when IEX::ACTOR_INVENTORY::CANCEL          
        text = "Go Back"
        icon = 0
      else
        text = "......."
        icon = 0
      end 
    elsif @windows["Inventory_To_Act"].active
      case @windows["Inventory_To_Act"].commands[@windows["Inventory_To_Act"].index]
      when IEX::ACTOR_INVENTORY::USE_ITEM
        text = "Use selected item?"
        icon = 0       
      when IEX::ACTOR_INVENTORY::SWITCH_TO_ACTOR
        text = "Switch over to Actor's Inventory?"
        icon = 0
      when IEX::ACTOR_INVENTORY::SEND_TO_ACTOR 
        text = "Send item to Actor's Inventory"
        icon = 0
      when IEX::ACTOR_INVENTORY::CANCEL          
        text = "Go Back"
        icon = 0
      else
        text = "......."
        icon = 0
      end   
    else
      text = "......."
      icon = 0
    end
    @windows["MainHelp"].set_header(text, icon, 0)
  end
  
  def use_actor_item
  end
  
  def use_inventory_item
  end
  
  def send_item_to_actor
    item = @windows["MainInve"].item
    amount = @windows["Number"].number
    $game_party.send_item_to_actor(@actor, item, amount)
  end
  
  def send_item_to_inventory(all = false)
    if all 
      @actor.send_inventory_to_party
    else
      item = @windows["Inventory"].item
      amount = @windows["Number"].number
      @actor.send_to_inventory(item, amount)
    end
  end
  
  def start_send_to_actor
    number_visible(true)
    item = @windows["MainInve"].item
    max = $game_party.item_number(item)
    @windows["Number"].set(item, max)
  end
    
  def start_send_to_inventory
    number_visible(true)
    item = @windows["Inventory"].item
    max = @actor.inventory_number(item, @windows["Inventory"].limit)
    @windows["Number"].set(item, max)
  end
  
  def refresh_inventory
    @windows["Inventory"].refresh
    @windows["MainInve"].refresh
    @windows["Inventory"].update
    @windows["MainInve"].update
    refresh_act_command_window
    refresh_inv_command_window
  end
  
  def return_scene
    if @call_from_menu
      $scene = Scene_Menu.new
    else
      $scene = Scene_Map.new
    end  
  end
  
  def refresh_act_command_window
    @windows["Act_To_Inventory"].contents.clear
    @windows["Act_To_Inventory"].refresh
    @windows["Act_To_Inventory"].index = 0
    all_nil = []
    for ite in @windows["Inventory"].all_items
      all_nil.push(ite == nil) 
    end
    if @actor.is_a_merchant?
      for i in 0..@windows["Act_To_Inventory"].commands.size
        case @windows["Act_To_Inventory"].commands[i]
        when IEX::ACTOR_INVENTORY::SWITCH_TO_INVENTORY
          @windows["Act_To_Inventory"].draw_item(i, false)
        when IEX::ACTOR_INVENTORY::SEND_TO_INVENTORY
          @windows["Act_To_Inventory"].draw_item(i, false)
        when IEX::ACTOR_INVENTORY::SEND_ALL_TO_INVENTORY  
          @windows["Act_To_Inventory"].draw_item(i, false) 
        end
      end 
    elsif @windows["Inventory"].item == nil
      for i in 0..@windows["Act_To_Inventory"].commands.size
        case @windows["Act_To_Inventory"].commands[i]
        when IEX::ACTOR_INVENTORY::SEND_TO_INVENTORY
          @windows["Act_To_Inventory"].draw_item(i, false)
        when IEX::ACTOR_INVENTORY::SEND_ALL_TO_INVENTORY  
          @windows["Act_To_Inventory"].draw_item(i, false) if all_nil.all?
        end
      end 
    else
      for i in 0..@windows["Act_To_Inventory"].commands.size
        if @windows["Act_To_Inventory"].commands[i] == IEX::ACTOR_INVENTORY::SEND_TO_INVENTORY
          @windows["Act_To_Inventory"].index = i
        end
      end   
    end
  end
  
  def refresh_inv_command_window
    @windows["Inventory_To_Act"].contents.clear
    @windows["Inventory_To_Act"].refresh
    @windows["Inventory_To_Act"].index = 0
    if @windows["MainInve"].item == nil
      for i in 0..@windows["Inventory_To_Act"].commands.size
        if @windows["Inventory_To_Act"].commands[i] == IEX::ACTOR_INVENTORY::SEND_TO_ACTOR
          @windows["Inventory_To_Act"].draw_item(i, false)
        end
      end 
    else
      for i in 0..@windows["Inventory_To_Act"].commands.size
        if @windows["Inventory_To_Act"].commands[i] == IEX::ACTOR_INVENTORY::SEND_TO_ACTOR
          @windows["Inventory_To_Act"].index = i
        end
      end 
    end
  end
  
  def act_inv_win_active(bool = true) ; @windows["Inventory"].active = bool ; end
  
  def inv_win_active(bool = true) ; @windows["MainInve"].active = bool ; end
  
  def act_inv_visible(bool = false)
    @windows["Act_To_Inventory"].active = bool
    @windows["Act_To_Inventory"].visible = bool
    refresh_act_command_window()
  end
  
  def inv_act_visible(bool = false)
    @windows["Inventory_To_Act"].active = bool
    @windows["Inventory_To_Act"].visible = bool
    refresh_inv_command_window()
  end
  
  def confirm_visible(bool = false)
    @windows["Confirm"].visible = bool
    @windows["Confirm"].active = bool
  end
  
  def number_visible(bool = false)
    @windows["Number"].visible = bool
    @windows["Number"].active = bool
  end
  
end

#==============================================================================#
# ** END OF FILE
#==============================================================================#