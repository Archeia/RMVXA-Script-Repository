#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Asagi's Gun License
#  Author: Kread-EX
#  Version 1.04
#  Release date: 15/02/2012
#
#  For Seiryuki.
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#-------------------------------------------------------------------------------------------------
#  ▼ UPDATES
#-------------------------------------------------------------------------------------------------
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
# # <ammo_type_id: x>
# # Replace x with the weapon type of the kind of ammo you want to use.
# #
# # Preparing the ammo
# # Ammo are weapons and they actually don't need any notetag. The only
# # requirement is that their weapon type must be the same as the one indicated
# # in the class tab to be useable.
# #
# # Skill notetags
# # <linked_ammo_type: x>
# # Will require and consume ammo of a specific type.
# # <linked_ammo_id: x>
# # Will require and consume unique arrows. In this case, x isn't the weapon
# # type but the weapon ID.
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
# # load_ammo_notetags (new method)
# #
# # Game_Actor
# # change_equip (alias)
# # equip_slots (alias)
# # equippable? (alias)
# # skill_cost_payable? (alias)
# # skill_ammo_reqs_ok? (new method)
# # pay_skill_cost (alias)
# # consume_ammo (new method)
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
    AMMO_CONSUMPTION_TYPE = /<linked_ammo_type:[ ]*(\d+)>/i
    AMMO_CONSUMPTION_ID = /<linked_ammo_id:[ ]*(\d+)>/i
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
		groups = [$data_classes, $data_skills]
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
  attr_reader     :ammo_slot_id
  attr_reader     :ammo_slot_name
  attr_reader     :ammo_type_id
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_ammo_notetags
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::AMMO_SLOT_ID
				@ammo_slot_id = $1.to_i
			when KRX::REGEXP::AMMO_SLOT_NAME
				@ammo_slot_name = $1
			when KRX::REGEXP::AMMO_TYPE_ID
				@ammo_type_id = $1.to_i
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
  attr_reader     :ammo_type_id
  attr_reader     :ammo_absolute_id
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_ammo_notetags
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::AMMO_CONSUMPTION_TYPE
				@ammo_type_id = $1.to_i
			when KRX::REGEXP::AMMO_CONSUMPTION_ID
				@ammo_absolute_id = $1.to_i
			end
		end
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
      return true if item.wtype_id == self.class.ammo_type_id
    end
    return krx_ammo_ga_equippable?(item)
  end
  #--------------------------------------------------------------------------
  # ● Performs equipment change
  #--------------------------------------------------------------------------
  alias_method(:krx_ammo_ga_ce, :change_equip)
  def change_equip(slot_id, item)
    if self.class.ammo_slot_id == slot_id && item.is_a?(RPG::Weapon)
      return unless item.wtype_id == self.class.ammo_type_id
      return unless trade_item_with_party(item, equips[slot_id])
      @equips[slot_id].object = item
      return
    end
    krx_ammo_ga_ce(slot_id, item)
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
    return true if skill.ammo_type_id.nil? && skill.ammo_absolute_id.nil?
    result = false
    slot_id = self.class.ammo_slot_id
    if skill.ammo_type_id != nil
      return false unless self.class.ammo_user?
      item = @equips[slot_id].object
      return false if item.nil?
      result = true if item.wtype_id == skill.ammo_type_id
    end
    if skill.ammo_absolute_id != nil
      return false unless self.class.ammo_user?
      item = @equips[slot_id].object
      return false if item.nil?
      result = true if item.id == skill.ammo_absolute_id
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
    return if skill.ammo_type_id.nil? && skill.ammo_absolute_id.nil?
    slot_id = self.class.ammo_slot_id
    item = @equips[slot_id].object
    $game_party.lose_item(item, 1, true)
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
      return @actor.class.ammo_slot_name
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
      if @slot_id == @actor.class.ammo_slot_id
        return true if item.nil?
        return false unless item.is_a?(RPG::Weapon)
        return @actor.class.ammo_type_id == item.wtype_id
      else
        if item.is_a?(RPG::Weapon)
          return false if @actor.class.ammo_type_id == item.wtype_id
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
      if @slot_id == @actor.class.ammo_slot_id
        return true if item.nil?
        return @actor.class.ammo_type_id == item.wtype_id
      end
    end
    krx_ammo_wei_enable?(item)
  end
end