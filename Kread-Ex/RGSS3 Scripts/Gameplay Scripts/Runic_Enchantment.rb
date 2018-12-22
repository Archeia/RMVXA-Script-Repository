#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Runic Enchantment
#  Author: Kread-EX
#  Version 1.06
#  Release date: 11/03/2012
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#-------------------------------------------------------------------------------------------------
#  ▼ UPDATES
#-------------------------------------------------------------------------------------------------
# # 02/06/2012. Now lists equipped items.
# # 19/03/2012. Fixed a crashing bug.
# # 17/03/2012. Added the option to limit runes to either the weapon or the
# # armor. Runes can also be set as impossible to double up on the same
# # equipment piece.
# # Also, bugfixes.
#-------------------------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#-------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # rpgmakerweb.com
# # rpgrevolution.com
#-------------------------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#-------------------------------------------------------------------------------------------------
# # An enchantment system inspired from Dragon's Age. Recommended to use only
# # for unique weapons and armors.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # REQUIRES THE TRAITS NAMER:
# # http://grimoirecastle.wordpress.com/rgss3-scripts/core-scripts/traits-namer/
# #
# # Tag enchant-able weapons with <enchant> in their notebox.
# # Modify rune slots with <rune_slots: x>
# #
# # Runes are armors with the <rune> notetag and None as an armor type.
# # <weapon_rune> Limits the rune to a weapon.
# # <armor_rune> Limits the rune to an armor.
# # <unique_rune> Only one of those on the same piece.
# #
# # Use SceneManager.call(Scene_Enchant) to enter the scene or use Yanfly's
# # Ace Menu Engine.
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#-------------------------------------------------------------------------------------------------
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_sandal_notetags (new method)
# #
# # RPG::EquipItem
# # can_enchant (new attr method)
# # rune_slots (new attr method)
# # rune_type (new attr method)
# # rune_unique (new attr method)
# # load_sandal_notetags (new method)
# # is_rune? (new method)
# # static_rune_params (new method)
# #
# # Game_Actor
# # feature_objects (alias)
# #
# # Game_Party
# # enchants_w (new method)
# # enchants_a (new method)
# # equipped_items (new method)
# #
# # Scene_Enchant (new class)
# # Window_EnchantList (new class)
# # Window_RuneList (new class)
# # Window_ViewRunes (new class)
# # Window_ViewRunesTraits (new class)
#-------------------------------------------------------------------------------------------------

# Quits if the Traits Namer isn't found

if $imported.nil? || $imported['KRX-TraitsNamer'].nil?
	
msgbox('You need the Traits Namer in order to use Runic Enchantment. Loading aborted.')

else

$imported['KRX-Enchantment'] = true

puts 'Load: Enchantment v1.06 by Kread-EX'

#===========================================================================
# ■ CONFIGURATION
#===========================================================================

module KRX
  
  # The max rune slots by default.
  RUNE_SLOTS_MAX = 5
    
  module VOCAB
    # Runes name in menus.
    RUNE_NAME = 'Runes'
    # Runes traits name
    RUNE_TRAITS_NAME = 'Traits'
  end
#===========================================================================
# ■ CONFIGURATION ENDS HERE
#===========================================================================
  module REGEXP
    ALLOW_ENCHANT = /<enchant>/i
    RUNE = /<rune>/i
    RUNE_SLOTS = /<rune_slots:[ ]*(\d+)>/i
    RUNE_WEAPON = /<weapon_rune>/i
    RUNE_ARMOR = /<armor_rune>/i
    RUNE_UNIQUE = /<unique_rune>/i
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
		alias_method(:krx_sandal_dm_load_database, :load_database)
	end
	def self.load_database
		krx_sandal_dm_load_database
		load_sandal_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_sandal_notetags
		groups = [$data_weapons, $data_armors]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_sandal_notetags
			end
		end
		puts "Read: Enchantment Notetags"
	end
end

#===========================================================================
# ■ RPG::EquipItem
#===========================================================================

class RPG::EquipItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader   :can_enchant
  attr_reader   :rune_slots
  attr_reader   :rune_type
  attr_reader   :rune_unique
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_sandal_notetags
    @rune_slots = KRX::RUNE_SLOTS_MAX
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::ALLOW_ENCHANT
				@can_enchant = true
      when KRX::REGEXP::RUNE
        @is_rune = true
      when KRX::REGEXP::RUNE_SLOTS
        @rune_slots = $1.to_i
      when KRX::REGEXP::RUNE_WEAPON
        @rune_type = :weapon
      when KRX::REGEXP::RUNE_ARMOR
        @rune_type = :armor
      when KRX::REGEXP::RUNE_UNIQUE
        @rune_unique = true
			end
		end
	end
	#--------------------------------------------------------------------------
	# ● Determine if the item is a rune
	#--------------------------------------------------------------------------
  def is_rune?
    @is_rune && self.is_a?(RPG::Armor)
  end
end

#===========================================================================
# ■ Game_Actor
#===========================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Returns the list of traits
  #--------------------------------------------------------------------------
  alias_method(:krx_sandal_ga_fo, :feature_objects)
  def feature_objects
    runes = []
    equips.compact.each do |equip|
      container = equip.is_a?(RPG::Weapon) ? $game_party.enchants_w :
      $game_party.enchants_a
      next if container[equip.id].nil?
      ids = container[equip.id]
      ids.each do |id|
        next if id.nil?
        runes.push($data_armors[id])
      end
    end
    krx_sandal_ga_fo + runes.compact
  end
end

#===========================================================================
# ■ Game_Party
#===========================================================================

class Game_Party < Game_Unit
	#--------------------------------------------------------------------------
	# ● Returns the items equipped by all actors
	#--------------------------------------------------------------------------
  def equipped_items
    result = []
    members.each {|actor| result.push(actor.equips)}
    return result.flatten
  end
	#--------------------------------------------------------------------------
	# ● Returns weapon enchantments
	#--------------------------------------------------------------------------
  def enchants_w
    @enchants_w ||= {}
  end
	#--------------------------------------------------------------------------
	# ● Returns armor enchantments
	#--------------------------------------------------------------------------
  def enchants_a
    @enchants_a ||= {}
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
end

#==========================================================================
# ■ Window_EnchantList
#==========================================================================
	
class Window_EnchantList < Window_ItemList
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
	def initialize(x, y, w, h)
		super(x, y, w, h)
		refresh
    select(0)
    activate
	end
	#--------------------------------------------------------------------------
	# ● Enable (always true)
	#--------------------------------------------------------------------------
	def enable?(item)
		item != nil
	end
	#--------------------------------------------------------------------------
	# ● Creates the list based on the recipes
	#--------------------------------------------------------------------------
	def make_item_list
		@data = []
    ($game_party.all_items + $game_party.equipped_items).each do |itm|
      next if @data.include?(itm)
      @data.push(itm) if itm.is_a?(RPG::EquipItem) && itm.can_enchant
    end
	end
  #--------------------------------------------------------------------------
  # ● Displays the item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item))
    end
  end
	#--------------------------------------------------------------------------
	# ● Returns the number of columns
	#--------------------------------------------------------------------------
	def col_max
		return 1
	end
	#--------------------------------------------------------------------------
	# ● Assigns a rune window
	#--------------------------------------------------------------------------
	def rune_window=(value)
		@rune_window = value
	end
	#--------------------------------------------------------------------------
	# ● Refreshes the help and rune windows
	#--------------------------------------------------------------------------
	def update_help
		@help_window.set_item(item)
		@rune_window.set_item(item) unless @rune_window.nil?
	end
end

#==========================================================================
# ■ Window_RuneList
#==========================================================================
	
class Window_RuneList < Window_ItemList
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
	def initialize(x, y, w, h)
		super(x, y, w, h)
		refresh
    select(0)
    hide
	end
	#--------------------------------------------------------------------------
	# ● Enable
	#--------------------------------------------------------------------------
	def enable?(item)
    return true if item.nil?
    if item.rune_unique
      ti = SceneManager.scene.target_item
      container = ti.class == RPG::Weapon ? $game_party.enchants_w :
      $game_party.enchants_a
      slots = container[ti.id]
      return !slots.include?(item.id)
    end
    if item.rune_type == :weapon
      return SceneManager.scene.target_item.class == RPG::Weapon
    elsif item.rune_type == :armor
      return SceneManager.scene.target_item.class == RPG::Armor
    end
		return true
	end
	#--------------------------------------------------------------------------
	# ● Creates the list based on the recipes
	#--------------------------------------------------------------------------
	def make_item_list
		@data = $game_party.all_items.select do |itm|
      itm.is_a?(RPG::EquipItem) && itm.is_rune?
    end
    @data.insert(0, nil)
	end
	#--------------------------------------------------------------------------
	# ● Returns the number of columns
	#--------------------------------------------------------------------------
	def col_max
		return 1
	end
	#--------------------------------------------------------------------------
	# ● Assigns a traits window
	#--------------------------------------------------------------------------
	def traits_window=(value)
		@traits_window = value
	end
  #--------------------------------------------------------------------------
  # ● Updates the help window
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item) unless @help_window.nil?
    @traits_window.set_item(item) unless @traits_window.nil?
  end
end

#==========================================================================
# ■ Window_ViewRunes
#==========================================================================
	
class Window_ViewRunes < Window_Selectable
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
	def initialize(x, y, width, height)
		super
		set_item
	end
	#--------------------------------------------------------------------------
	# ● Refresh the contents
	#--------------------------------------------------------------------------
	def set_item(item = nil)
		contents.clear
		return if item.nil?
    container = item.is_a?(RPG::Weapon) ? $game_party.enchants_w :
    $game_party.enchants_a
    container[item.id] = [] if container[item.id].nil?
    @data = container[item.id]
    filler = item.rune_slots - @data.size
    filler.times {@data.push(nil)} if filler > 0
		draw_item_runes(item)
	end
	#--------------------------------------------------------------------------
	# ● Returns the selected rune
	#--------------------------------------------------------------------------
  def get_item
    $data_armors[@data[index]]
  end
	#--------------------------------------------------------------------------
	# ● Displays the item's runes
	#--------------------------------------------------------------------------
	def draw_item_runes(item)
    # Draws the sys text
		change_color(system_color)
		contents.draw_text(4, 0, width, line_height, KRX::VOCAB::RUNE_NAME)
		change_color(normal_color)
		(1..item.rune_slots).each do |i|
      contents.draw_text(4, line_height * i, width, line_height, "#{i}.")
    end
    # Draws the runes
		@data.each_index do |i|
      next if @data[i].nil?
			rune = $data_armors[@data[i]]
      draw_item_name(rune, 28, line_height * (i + 1), true, width - 24)
		end
	end
	#--------------------------------------------------------------------------
	# ● Returns the number of columns
	#--------------------------------------------------------------------------
	def col_max
		return 1
	end
  #--------------------------------------------------------------------------
  # ● Returns the max number of rows
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # ● Sets the rectangle for selections
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing)
    rect.y = (index / col_max * item_height) + line_height
    rect
  end
	#--------------------------------------------------------------------------
	# ● Assigns a traits window
	#--------------------------------------------------------------------------
	def traits_window=(value)
		@traits_window = value
	end
  #--------------------------------------------------------------------------
  # ● Updates the help window
  #--------------------------------------------------------------------------
  def update_help
    unless @help_window.nil?
      itm = @data[index].nil? ? nil : get_item
      @help_window.set_item(itm)
    end
    @traits_window.set_item(@data[index]) unless @traits_window.nil?
  end
end

#==========================================================================
# ■ Window_ViewRunesTraits
#==========================================================================
	
class Window_ViewRunesTraits < Window_Base
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
	def initialize(x, y, width, height)
		super
		set_item
	end
	#--------------------------------------------------------------------------
	# ● Refresh the contents
	#--------------------------------------------------------------------------
	def set_item(item = nil)
		contents.clear
		return if item.nil?
    item = $data_armors[item] if item.is_a?(Integer)
    draw_rune_traits(item)
	end
	#--------------------------------------------------------------------------
	# ● Displays the rune's traits
	#--------------------------------------------------------------------------
	def draw_rune_traits(item)
    # Draws the sys text
		change_color(system_color)
		contents.draw_text(4, 0, width, line_height, KRX::VOCAB::RUNE_TRAITS_NAME)
		change_color(normal_color)
    # Draws the traits
		item.features.each_index do |i|
      f = item.features[i]
      name = KRX::TraitsNamer.feature_name(f.code, f.data_id, f.value)
      contents.draw_text(4, line_height * (i + 1), width - 24, line_height, name)
		end
	end
end

#==========================================================================
# ■ Scene_Enchant
#==========================================================================

class Scene_Enchant < Scene_ItemBase
	#--------------------------------------------------------------------------
	# ● Scene start
	#--------------------------------------------------------------------------
	def start
    super
    create_help_window
    create_traits_window
    create_rune_window
    create_enchant_window
    create_runelist_window
  end
	#--------------------------------------------------------------------------
	# ● Creates the window showing the rune's traits
	#--------------------------------------------------------------------------
  def create_traits_window
    wx = ww = Graphics.width / 2
    wh = (Graphics.height - @help_window.height) / 2
    wy = Graphics.height - wh
    @traits_window = Window_ViewRunesTraits.new(wx, wy, ww, wh)
  end
	#--------------------------------------------------------------------------
	# ● Creates the window showing the current rune set
	#--------------------------------------------------------------------------
  def create_rune_window
    wy = @help_window.height
    wx = ww = Graphics.width / 2
    wh = (Graphics.height - wy) / 2
    @rune_window = Window_ViewRunes.new(wx, wy, ww, wh)
    @rune_window.help_window = @help_window
    @rune_window.traits_window = @traits_window
    @rune_window.set_handler(:ok, method(:on_slot_ok))
    @rune_window.set_handler(:cancel, method(:on_slot_cancel))
  end
	#--------------------------------------------------------------------------
	# ● Creates the window listing the enchantable equipment
	#--------------------------------------------------------------------------
  def create_enchant_window
    wy = @help_window.height
    ww = Graphics.width / 2
    wh = Graphics.height - wy
    @enchant_window = Window_EnchantList.new(0, wy, ww, wh)
    @enchant_window.set_handler(:ok, method(:on_item_ok))
    @enchant_window.set_handler(:cancel, method(:return_scene))
    @enchant_window.help_window = @help_window
    @enchant_window.rune_window = @rune_window
    @enchant_window.update_help
  end
	#--------------------------------------------------------------------------
	# ● Creates the window listing the available runes
	#--------------------------------------------------------------------------
  def create_runelist_window
    wy = @help_window.height
    ww = Graphics.width / 2
    wh = Graphics.height - wy
    @runelist_window = Window_RuneList.new(0, wy, ww, wh)
    @runelist_window.help_window = @help_window
    @runelist_window.traits_window = @traits_window
    @runelist_window.set_handler(:ok, method(:on_rune_ok))
    @runelist_window.set_handler(:cancel, method(:on_rune_cancel))
  end
	#--------------------------------------------------------------------------
	# ● Validates the item selection
	#--------------------------------------------------------------------------
  def on_item_ok
    @enchant_window.deactivate
    @rune_window.select(0)
    @rune_window.activate
  end
	#--------------------------------------------------------------------------
	# ● Validates the rune slot selection
	#--------------------------------------------------------------------------
  def on_slot_ok
    @rune_window.deactivate
    @enchant_window.hide
    @runelist_window.show.select(0)
    @runelist_window.activate
  end
	#--------------------------------------------------------------------------
	# ● Cancels the rune slot selection
	#--------------------------------------------------------------------------
  def on_slot_cancel
    @rune_window.unselect
    @enchant_window.select_last
    @enchant_window.activate
    @traits_window.set_item(nil)
  end
	#--------------------------------------------------------------------------
	# ● Validates the rune selection
	#--------------------------------------------------------------------------
  def on_rune_ok
    e_type = @enchant_window.item.class
    e_id = @enchant_window.item.id
    r_index = @rune_window.index
    r_id = @runelist_window.item != nil ? @runelist_window.item.id : nil
    $game_party.inscribe_rune(e_type, e_id, r_id, r_index)
    @rune_window.set_item(@enchant_window.item)
    @rune_window.activate
    @runelist_window.hide.refresh
    @runelist_window.unselect
    @enchant_window.show
  end
	#--------------------------------------------------------------------------
	# ● Cancels the rune selection
	#--------------------------------------------------------------------------
  def on_rune_cancel
    @rune_window.activate
    @runelist_window.hide.unselect
    @runelist_window.deactivate
    @enchant_window.show
  end
	#--------------------------------------------------------------------------
	# ● Returns the target item
	#--------------------------------------------------------------------------
  def target_item
    @enchant_window.item
  end
end

## Menu inclusion, with Yanfly's Ace Menu Engine
if $imported["YEA-AceMenuEngine"]

#==========================================================================
#  ■ Scene_Menu
#==========================================================================
	
class Scene_Menu < Scene_MenuBase
	#--------------------------------------------------------------------------
	# ● Switch to the enchant scene
	#--------------------------------------------------------------------------
	def command_enchant
    SceneManager.call(Scene_Enchant)
  end
end

end ## End of Yanfly's Menu inclusion

end ## End of Traits Namer's check.