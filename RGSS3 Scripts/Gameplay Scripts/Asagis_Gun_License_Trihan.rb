#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Asagi's Gun License
#  Author: Kread-EX
#  Modified by: Trihan
#  Version 1.08x
#  Release date: 13/04/2012
#
#  For Seiryuki.
#
#  Thanks to Angius for finding a bug.
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#-------------------------------------------------------------------------------------------------
#  ▼ UPDATES
#-------------------------------------------------------------------------------------------------
# # 13/04/2012. Bugfix: Gaining a non-ranged weapon caused the script to crash
# # when moving the cursor over the ammo slot in the equipment menu.
# # 10/04/2012. Bugfix: unequipping non-weapon items caused a crash.
# # 10/04/2012. Modifications: Added slot names on a per-weapon basis.
# # 09/04/2012. Modifications: allowed ammo to be assigned on a per-weapon basis
# # rather than classes, and allowed skills to use multiple ammo types/IDs.
# # Implemented ammo costs for skills.
# # Prevented multiple ammo users from equipping the same ammo.
# # Equipped ammo is now removed from the equippable items list.
# # The item list now shows the correct quantity of ammo if a party member has
# # that ammo equipped.
# # 09/03/2012. Bugfix: skills without ammo could crash.
# # 08/03/2012. Bugfix: ammo stopped consuming because of my previous bugfixes.
# # 22/02/2012. Bugfix: some REGEXP didn't work with european characters.
# # 20/02/2012. Bugfix: all skills used to consume ammo.
#-------------------------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#-------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # rpgmakervxace.net
# # rpgrevolution.com
#-------------------------------------------------------------------------------------------------
#  ▼ INTRODUCTION
  #-------------------------------------------------------------------------------------------------
  # # Enables the use of ammunition for skills.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # Three levels of configuration: Class, Weapon and Skill.
# # Class notetags:
# # <ammo_slot_id: x>
# # This determines the slot in the equip screen which will be replaced by the
# # ammo slot.
# # <ammo_slot_name: string> Just the name of the slot.
# #
# # Weapon notetags:
# # <ammo_type_id: x, y, z>
# # Replace x with the weapon types of the kind of ammo you want the
# # weapon to use.
# #
# # Skill notetags
# # <linked_ammo_types: x>
# # Will require and consume ammo of a specific type.
# # <linked_ammo_ids: x>
# # Will require and consume unique arrows. In this case, x isn't the weapon
# # type but the weapon ID.
# # <ammo_cost: x>
# # Determines how much ammo is required to use the skill, and will be expended
# # on use.
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#-------------------------------------------------------------------------------------------------
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_ammo_notetags (new method)
# #
# # RPG::Class
# # ammo_slot_id (new attr method)
# # ammo_slot_name (new attr method)
# # load_ammo_notetags (new method)
# # ammo_user? (new method)
# #
# # RPG::Skill
# # ammo_type_id (new attr method)
# # ammo_absolute_id (new attr method)
# # ammo_cost (new attr method)
# # load_ammo_notetags (new method)
# #
# # RPG::Weapon
# # ammo_type_ids (new attr method)
# # already_equipped (new attr method)
# # load_ammo_notetags (new method)
# # ammo_user? (new method)
# #
# # Game_Actor
# # change_equip (alias)
# # equip_slots (alias)
# # equippable? (alias)
# # release_unequippable_items (overload)
# # skill_cost_payable? (alias)
# # skill_ammo_reqs_ok? (new method)
# # pay_skill_cost (alias)
# # consume_ammo (new method)
# # 
# # Game_Party
# # discard_members_equip (overload)
# # 
# # Window_EquipSlot
# # draw_item (alias)
# # slot_name (alias)
# #
# # Window_EquipItem
# # include? (alias)
# # enable? (alias)
#-------------------------------------------------------------------------------------------------

$imported = {} if $imported.nil?
$imported['KRX-AsagisGunLicense'] = true

puts 'Load: Asagi\'s Gun License v1.03 by Kread-EX'

module KRX
  
  module REGEXP
    AMMO_SLOT_ID = /<ammo_slot_id:[ ]*(\d+)>/i
    AMMO_SLOT_NAME = /<ammo_slot_name:[ ]*(.+)>/
    AMMO_TYPE_ID = /<ammo_type_id:[ ]*(\d+)>/i
    AMMO_CONSUMPTION_TYPES = /<linked_ammo_types:[ ]*(.+?)>/i
    AMMO_CONSUMPTION_IDS = /<linked_ammo_ids:[ ]*(.+?)>/i
    AMMO_COST = /<ammo_cost:[ ]*(\d+)>/i
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
    alias_method(:krx_ammo_dm_load_database, :load_database)
  end
  def self.load_database
    krx_ammo_dm_load_database
    load_ammo_notetags
  end  
  #--------------------------------------------------------------------------
  # ● Loads the note tags
  #--------------------------------------------------------------------------
  def self.load_ammo_notetags
    groups = [$data_classes, $data_skills, $data_weapons]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_ammo_notetags
      end
    end
    puts "Read: Ammo Requirements Notetags"
  end
end

#===========================================================================
# ■ RPG::Class
#===========================================================================

class RPG::Class < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● Public instance variables
  #--------------------------------------------------------------------------
  attr_reader     :weapon_slot_id
  attr_reader     :ammo_slot_id
  attr_reader     :ammo_slot_name
  #--------------------------------------------------------------------------
  # ● Loads the note tags
  #--------------------------------------------------------------------------
  def load_ammo_notetags
    @note.split(/[\r\n]+/).each do |line|
      case line
      when KRX::REGEXP::AMMO_SLOT_ID
        @ammo_slot_id = $1.to_i
        if @ammo_slot_id == 0
          @weapon_slot_id = 1
        else
          @weapon_slot_id = 0
        end
      when KRX::REGEXP::AMMO_SLOT_NAME
        @ammo_slot_name = $1
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Determine if this class uses ammo
  #--------------------------------------------------------------------------
  def ammo_user?
    return @ammo_slot_id != nil
  end
end

#===========================================================================
# ■ RPG::Skill
#===========================================================================

class RPG::Skill < RPG::UsableItem
  #--------------------------------------------------------------------------
  # ● Public instance variables
  #--------------------------------------------------------------------------
  attr_reader     :ammo_type_ids
  attr_reader     :ammo_absolute_ids
  attr_reader     :ammo_cost
  #--------------------------------------------------------------------------
  # ● Loads the note tags
  #--------------------------------------------------------------------------
  def load_ammo_notetags
    @note.split(/[\r\n]+/).each do |line|
      case line
      when KRX::REGEXP::AMMO_CONSUMPTION_TYPES
        @ammo_type_ids = []
        @ammo_type_ids |= $1.scan(/\d+/).collect { |id| id.to_i }
      when KRX::REGEXP::AMMO_CONSUMPTION_IDS
        @ammo_absolute_ids = []
        @ammo_absolute_ids |= $1.scan(/\d+/).collect { |id| id.to_i }
      when KRX::REGEXP::AMMO_COST
        @ammo_cost = $1.to_i
      end
    end
  end
end

class RPG::Weapon < RPG::EquipItem
  #--------------------------------------------------------------------------
  # ● Public instance variables
  #--------------------------------------------------------------------------
  attr_reader     :ammo_type_id
  attr_reader     :ammo_slot_name
  attr_accessor   :already_equipped
  #--------------------------------------------------------------------------
  # ● Constructor
  #--------------------------------------------------------------------------
  alias_method(:krx_ammo_rw_init, :initialize)
  def initialize
    @already_equipped = false
    krx_ammo_rw_init
  end
  #--------------------------------------------------------------------------
  # ● Loads the note tags
  #--------------------------------------------------------------------------
  def load_ammo_notetags
    @note.split(/[\r\n]+/).each do |line|
      case line
      when KRX::REGEXP::AMMO_SLOT_NAME
        @ammo_slot_name = $1
      when KRX::REGEXP::AMMO_TYPE_ID
        @ammo_type_id = $1.to_i
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Determine if this weapon uses ammo
  #--------------------------------------------------------------------------
  def ammo_user?
    return @ammo_type_id != nil
  end
end

#===========================================================================
# ■ Game_Actor
#===========================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Gets the available equipment slots
  #--------------------------------------------------------------------------
  alias_method(:krx_ammo_ga_es, :equip_slots)
  def equip_slots
    base = krx_ammo_ga_es
    return base unless self.class.ammo_user?
    ammo_slot = self.class.ammo_slot_id
    result = []
    done = false
    base.each do |x|
      if x == ammo_slot && !done
        result.push(0)
        done = true
      else
        result.push(x)
      end
    end
    result
  end
  #--------------------------------------------------------------------------
  # ● Determines if an item can be equipped
  #--------------------------------------------------------------------------
  alias_method(:krx_ammo_ga_equippable?, :equippable?)
  def equippable?(item)
    if self.class.ammo_user? && item.is_a?(RPG::Weapon)
      weapon_slot = self.class.weapon_slot_id
      if self.equips[weapon_slot]
        return true if item.wtype_id == self.equips[weapon_slot].ammo_type_id
      end
    end
    return krx_ammo_ga_equippable?(item)
  end
  #--------------------------------------------------------------------------
  # ● Performs equipment change
  #--------------------------------------------------------------------------
  alias_method(:krx_ammo_ga_ce, :change_equip)
  def change_equip(slot_id, item)
    if item == nil && equips[slot_id] && equips[slot_id].is_a?(RPG::Weapon)
      equips[slot_id].already_equipped = false
    elsif self.class.ammo_slot_id == slot_id && item.is_a?(RPG::Weapon)
      weapon_slot = self.class.weapon_slot_id
      return unless item.is_a?(RPG::Weapon) && item.wtype_id == self.equips[weapon_slot].ammo_type_id
      return unless trade_item_with_party(item, equips[slot_id])
      if equips[slot_id] != nil && equips[slot_id].is_a?(RPG::Weapon)
        equips[slot_id].already_equipped = false
      end
      item.already_equipped = true
      @equips[slot_id].object = item
      return
    end
    krx_ammo_ga_ce(slot_id, item)
  end
  #--------------------------------------------------------------------------
  # * Remove Equipment that Cannot Be Equipped 
  #     item_gain:  Return removed equipment to party.
  #--------------------------------------------------------------------------
  def release_unequippable_items(item_gain = true)
    loop do
      last_equips = equips.dup
      @equips.each_with_index do |item, i|
        if !equippable?(item.object) || item.object.etype_id != equip_slots[i]
          if item.object.is_a?(RPG::Weapon)
            item.object.already_equipped = false if item.object.already_equipped == true
          end
          trade_item_with_party(nil, item.object) if item_gain
          item.object = nil
        end
      end
      return if equips == last_equips
    end
  end
  #--------------------------------------------------------------------------
  # ● Determine if a skill can be used
  #--------------------------------------------------------------------------
  alias_method(:krx_ammo_ga_scp?, :skill_cost_payable?)
  def skill_cost_payable?(skill)
    return false unless skill_ammo_reqs_ok?(skill)
    return krx_ammo_ga_scp?(skill)
  end
  #--------------------------------------------------------------------------
  # ● Check the ammo requirements for the skill
  #--------------------------------------------------------------------------
  def skill_ammo_reqs_ok?(skill)
    return true if skill.ammo_type_ids.nil? && skill.ammo_absolute_ids.nil?
    result = false
    weapon_id = self.class.weapon_slot_id
    slot_id = self.class.ammo_slot_id
    if skill.ammo_type_ids != nil
      return false unless self.class.ammo_user?
      item = @equips[slot_id].object
      return false if item.nil?
      if skill.ammo_cost
        return false if $game_party.item_number(item) < skill.ammo_cost - 1
      end
      result = true if skill.ammo_type_ids.include?(item.wtype_id)
    end
    if skill.ammo_absolute_ids != nil
      return false unless self.class.ammo_user?
      item = @equips[slot_id].object
      return false if item.nil?
      if skill.ammo_cost
        return false if $game_party.item_number(item) < skill.ammo_cost - 1
      end
      result = true if skill.ammo_type_ids.include?(item.id)
    end
    result
  end
  #--------------------------------------------------------------------------
  # ● Pay the required cost for a skill
  #--------------------------------------------------------------------------
  alias_method(:krx_ammo_ga_psc, :pay_skill_cost)
  def pay_skill_cost(skill)
    krx_ammo_ga_psc(skill)
    consume_ammo(skill) if self.class.ammo_user?
  end
  #--------------------------------------------------------------------------
  # ● Consume the required ammo for a skill
  #--------------------------------------------------------------------------
  def consume_ammo(skill)
    return if skill.ammo_type_ids.nil? && skill.ammo_absolute_ids.nil?
    slot_id = self.class.ammo_slot_id
    item = @equips[slot_id].object
    if skill.ammo_cost
      $game_party.lose_item(item, skill.ammo_cost, true)
    else
      $game_party.lose_item(item, 1, true)
    end
  end
end
#===========================================================================
# ■ Game_Party
#===========================================================================
class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Discard Members' Equipment
  #--------------------------------------------------------------------------
  def discard_members_equip(item, amount)
    n = amount
    members.each do |actor|
      while n > 0 && actor.equips.include?(item)
        if item.is_a?(RPG::Weapon)
          item.already_equipped = false if item.already_equipped == true
        end
        actor.discard_equip(item)
        n -= 1
      end
    end
  end
end

#===========================================================================
# ■ Window_ItemList
#===========================================================================

class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Draw Number of Items
  #--------------------------------------------------------------------------
  def draw_item_number(rect, item)
    quantity = 0
    for member in $game_party.all_members
      if member.class.ammo_user?
        if member.equips[member.class.ammo_slot_id]
          if member.equips[member.class.ammo_slot_id].id == item.id
            quantity += 1
          end
        end
      end
    end
    draw_text(rect, sprintf(":%2d", ($game_party.item_number(item) + quantity)), 2)
  end
end

#===========================================================================
# ■ Window_EquipSlot
#===========================================================================

class Window_EquipSlot < Window_Selectable
  #--------------------------------------------------------------------------
  # ● Displays the equipped item
  #--------------------------------------------------------------------------
  alias_method(:krx_ammo_wes_di, :draw_item)
  def draw_item(index)
    krx_ammo_wes_di(index)
    rect = item_rect_for_text(index)
    item = @actor.equips[index]
    name = slot_name(index)
    if @actor.class.ammo_user? && name == @actor.class.ammo_slot_name
      unless item.nil?
        draw_text(rect, sprintf(":%2d", $game_party.item_number(item) + 1), 2)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Determine the name of the slot
  #--------------------------------------------------------------------------
  alias_method(:krx_ammo_wes_sn, :slot_name)
  def slot_name(index)
    if @actor && @actor.class.ammo_slot_id == index
      if @actor.equips[@actor.class.weapon_slot_id]
        if @actor.equips[@actor.class.weapon_slot_id].ammo_slot_name != nil
          return @actor.equips[@actor.class.weapon_slot_id].ammo_slot_name
        else
          return @actor.class.ammo_slot_name
        end
      end
    end
    krx_ammo_wes_sn(index)
  end
end

#===========================================================================
# ■ Window_Item
#===========================================================================

class Window_EquipItem < Window_ItemList
  #--------------------------------------------------------------------------
  # ● Determine if an item goes in the list
  #--------------------------------------------------------------------------
  alias_method(:krx_ammo_wei_include?, :include?)
  def include?(item)
    if @actor.class.ammo_user?
      weapon_slot = @actor.class.weapon_slot_id
      if @slot_id == @actor.class.ammo_slot_id
        return true if item.nil?
        return false unless item.is_a?(RPG::Weapon) && @actor.equips[weapon_slot]
        return false if item.already_equipped == true
        if @actor.equips[@slot_id]
          return false if @actor.equips[@slot_id].id == item.id
        end
        return @actor.equips[weapon_slot].ammo_type_id == item.wtype_id
      else
        if item.is_a?(RPG::Weapon) && @actor.equips[weapon_slot]
          return false if @actor.equips[weapon_slot].ammo_type_id == item.wtype_id
        end
      end
    end
    krx_ammo_wei_include?(item)
  end
  #--------------------------------------------------------------------------
  # ● Determine if an item can be equipped
  #--------------------------------------------------------------------------
  alias_method(:krx_ammo_wei_enable?, :enable?)
  def enable?(item)
    if @actor.class.ammo_user?
      weapon_slot = @actor.class.weapon_slot_id
      if @slot_id == @actor.class.ammo_slot_id && @actor.equips[weapon_slot]
        return true if item.nil?
        return @actor.equips[weapon_slot].ammo_type_id == item.wtype_id
      end
    end
    krx_ammo_wei_enable?(item)
  end
end