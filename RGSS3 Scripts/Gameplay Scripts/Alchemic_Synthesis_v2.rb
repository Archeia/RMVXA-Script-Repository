#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ GO GO TOTORI!
#  Author: Kread-EX
#  Version 2.03
#  Release date: 08/12/2011
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#------------------------------------------------------------------------------
#  ▼ UPDATES
#------------------------------------------------------------------------------
# # 05/01/2013. Fixed a bug with items disappearing when trait selection is
# # cancelled.
# # 07/12/2012. Bug fixes.
# # 25/03/2012. Version 2.0 - huge backend revamp.
# # 20/12/2011. Fixed a saving bug.
# # 12/12/2011. Added detection for the future add-ons.
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
# # This script is a complex item synthesis system inspired from GUST Atelier
# # series in general and Atelier Totori in particular.
# # 
# # Features
# # - Ability to create objects based on recipes.
# # - Ability to switch an ingredient for another of the same family.
# # - Ability to set traits to ingredients and put them on the final item.
# # - Alchemic level and synthesis difficulty.
# # - Synthesis Shop (add-on).
# # - Party alchemic level and experience.
#------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#------------------------------------------------------------------------------
# # I'll direct you to this webpage for a clear explanation. It's complicated I'm afraid.
# # http://grimoirecastle.wordpress.com/2011/12/08/alchemic-synthesis-go-go-totori/
#------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#------------------------------------------------------------------------------
# # New classes: Scene_Alchemy, Window_SynthesisList, Window_SynthesisProp,
# # Window_IngredientList, Window_IngredientProp, Window_ItemFamily,
# # Window_TraitList, Window_FinalItem, Window_SynthCategory
# #
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_synth_notetags (new method)
# #
# # RPG::BaseItem
# # traits (new method)
# #
# # RPG::Item
# # recipe_data (new attr method)
# # synthesis_reqs (new attr method)
# # synthesis_level (new attr method)
# # synthesis_costs (new attr method)
# # synthesis_locks (new attr method)
# # load_synth_notetags (new method)
# # synthesis_quality (new method)
# # traits_type (new method)
# # effects (alias)
# #
# # RPG::EquipItem
# # synthesis_reqs (new attr method)
# # synthesis_level (new attr method)
# # synthesis_costs (new attr method)
# # synthesis_locks (new attr method)
# # load_synth_notetags (new method)
# # synthesis_quality (new method)
# # traits_type (new method)
# # features (alias)
# #
# # Game_Party
# # synthesis_level (new attr method)
# # synthesis_traits (new attr method)
# # synthesis_quality (new attr method)
# # synthesis_exp (new attr method)
# # initialize (alias)
# # synthesis_level_up (new method)
# # gain_synthesis_exp (new method)
# # exp_to_next_synth_level (new method)
#------------------------------------------------------------------------------

# Quits if the Traits Namer isn't found

if $imported.nil? || $imported['KRX-TraitsNamer'].nil?
	
msgbox('You need the Traits Namer in order to use Alchemic Synthesis. Loading aborted.')

else

$imported['KRX-AlchemicSynthesis'] = true

puts 'Load: Alchemic Synthesis ~GO GO TOTORI!~ v2.03 by Kread-EX'

module KRX
#===========================================================================
# ■ CONFIGURATION
#===========================================================================

  SYNTH_MAX_TRAITS = 4 # Don't change this unless you're using a custom UI.
  SYNTH_CATEGORIES = [:item, :weapon, :armor, :key_item]
  
  SYNTH_LEVEL_FORMULA = "100 * @synthesis_level"
  
  SYNTH_EXP_FORMULA = "20 * creation_level / @synthesis_level"
  
	module VOCAB
		TRAITS = 'Traits'
		INGREDIENTS = 'Ingredients'
		QUALITY = 'Quality:'
		SYNTH_POINTS = 'Synthesis Points:'
		CAULDRON = 'Cauldron'
		LEVEL = 'Synthesis Level:'
		SUCCESS_RATE = 'Success Rate:'
		SYNTH_FAILED = 'The synthesis has failed!'
		SYNTH_SUCCESS = 'The synthesis is successful!'
    END_TRAIT_SELECTION = 'Finish!'
    PERFORM_SYNTHESIS = 'Perform synthesis.'
    ALCHEMIC_LEVEL = 'Party Lv.'
	end
#===========================================================================
# ■ CONFIGURATION ENDS HERE
#===========================================================================
	module REGEXP
		SYNTHESIS_ITEM = /<synth_item:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
		SYNTHESIS_ITEM_REQ = /<synth_req_item:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
		SYNTHESIS_WEAPON = /<synth_weapon:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
		SYNTHESIS_WEAPON_REQ = /<synth_req_weapon:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
		SYNTHESIS_ARMOR = /<synth_armor:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
		SYNTHESIS_ARMOR_REQ = /<synth_req_armor:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
		SYNTHESIS_FAMILY = /<synth_family:[ ]*(.+)>/
		SYNTHESIS_QUALITY = /<synth_quality:[ ]*(\d+)>/i
		SYNTHESIS_LEVEL = /<synth_level:[ ]*(\d+)>/i
    SYNTHESIS_COSTS = /<synth_costs:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
    SYNTHESIS_LOCKS = /<synth_locks:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
	end
	#--------------------------------------------------------------------------
	# ● Checks alchemic modifications to items
	#--------------------------------------------------------------------------
  def self.determine_alchemic_value(property, object, default_value)
    return default_value if $game_party.nil?
    case property
    when :quality
      result = $game_party.synthesis_quality[[object.class, object.id]]
    when :effects
      adds = $game_party.synthesis_traits[[object.class, object.id]]
      if adds != nil
        result = []
        adds.each do |a|
          result.push(RPG::UsableItem::Effect.new(a[0], a[1], a[2], a[3]))
        end
        final_result = default_value + result
        return final_result
      end
    when :features
      adds = $game_party.synthesis_traits[[object.class, object.id]]
      if adds != nil
        result = []
        adds.each do |a|
          result.push(RPG::BaseItem::Feature.new(a[0], a[1], a[2]))
        end
        final_result = default_value + result
        return final_result
      end
    end
    result.nil? ? default_value : result
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
		alias_method(:krx_totori_dm_load_database, :load_database)
	end
	def self.load_database
		krx_totori_dm_load_database
		load_synth_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_synth_notetags
		groups = [$data_items, $data_weapons, $data_armors]
		classes = [RPG::Item, RPG::Weapon, RPG::Armor]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_synth_notetags if classes.include?(obj.class)
			end
		end
		puts "Read: Alchemic Synthesis Notetags"
	end
end

#==========================================================================
# ■ RPG::BaseItem
#==========================================================================

class RPG::BaseItem
	#--------------------------------------------------------------------------
	# ● Returns the traits
	#--------------------------------------------------------------------------
  def traits
    container = is_a?(RPG::EquipItem) ? features : effects
    result = []
    container.each_index do |i|
      result.push(container[i]) if !@synthesis_locks.include?(i)
    end
    result
  end
end

#==========================================================================
# ■ RPG::Item
#==========================================================================

class RPG::Item < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_reader		:recipe_data
	attr_reader		:synthesis_reqs
	attr_reader		:synthesis_family
	attr_reader		:synthesis_level
  attr_reader   :synthesis_costs
  attr_reader   :synthesis_locks
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_synth_notetags
		@recipe_data = []
    @synthesis_reqs, @synthesis_costs, @synthesis_locks = [], [], []
		@synthesis_family = nil
		@synthesis_quality, @synthesis_level = 0, 1
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::SYNTHESIS_ITEM
				$1.scan(/\d+/).each {|i| @recipe_data.push($data_items[i.to_i])}
			when KRX::REGEXP::SYNTHESIS_WEAPON
				$1.scan(/\d+/).each {|i| @recipe_data.push($data_weapons[i.to_i])}
			when KRX::REGEXP::SYNTHESIS_ARMOR
				$1.scan(/\d+/).each {|i| @recipe_data.push($data_armors[i.to_i])}
			when KRX::REGEXP::SYNTHESIS_ITEM_REQ
				$1.scan(/\d+/).each {|i| @synthesis_reqs.push($data_items[i.to_i])}
			when KRX::REGEXP::SYNTHESIS_WEAPON_REQ
				$1.scan(/\d+/).each {|i| @synthesis_reqs.push($data_weapons[i.to_i])}
			when KRX::REGEXP::SYNTHESIS_ARMOR_REQ
				$1.scan(/\d+/).each {|i| @synthesis_reqs.push($data_armors[i.to_i])}
			when KRX::REGEXP::SYNTHESIS_FAMILY
				@synthesis_family = $1
			when KRX::REGEXP::SYNTHESIS_QUALITY
				@synthesis_quality = $1.to_i
			when KRX::REGEXP::SYNTHESIS_LEVEL
				@synthesis_level = $1.to_i
			when KRX::REGEXP::SYNTHESIS_COSTS
        $1.scan(/\d+/).each {|i| @synthesis_costs.push(i.to_i)}
			when KRX::REGEXP::SYNTHESIS_LOCKS
        $1.scan(/\d+/).each {|i| @synthesis_locks.push(i.to_i - 1)}
			end
		end
	end
	#--------------------------------------------------------------------------
	# ● Returns the synthesis quality
	#--------------------------------------------------------------------------
	def synthesis_quality
		KRX.determine_alchemic_value(:quality, self, @synthesis_quality)
	end
	#--------------------------------------------------------------------------
	# ● Returns the type of traits
	#--------------------------------------------------------------------------
  def traits_type
    :effects
  end
	#--------------------------------------------------------------------------
	# ● Returns the effects
	#--------------------------------------------------------------------------
  alias_method(:krx_totori_item_effects, :effects)
  def effects
    KRX.determine_alchemic_value(:effects, self, krx_totori_item_effects)
  end
end

#==========================================================================
# ■ RPG::EquipItem
#==========================================================================

class RPG::EquipItem < RPG::BaseItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_reader		:synthesis_reqs
	attr_reader		:synthesis_family
	attr_reader		:synthesis_level
  attr_reader   :synthesis_costs
  attr_reader   :synthesis_locks
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_synth_notetags
    @synthesis_reqs, @synthesis_costs, @synthesis_locks = [], [], []
		@synthesis_family = nil
		@synthesis_quality, @synthesis_level = 0, 1
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::SYNTHESIS_ITEM_REQ
				$1.scan(/\d+/).each {|i| @synthesis_reqs.push($data_items[i.to_i])}
			when KRX::REGEXP::SYNTHESIS_WEAPON_REQ
				$1.scan(/\d+/).each {|i| @synthesis_reqs.push($data_weapons[i.to_i])}
			when KRX::REGEXP::SYNTHESIS_ARMOR_REQ
				$1.scan(/\d+/).each {|i| @synthesis_reqs.push($data_armors[i.to_i])}
			when KRX::REGEXP::SYNTHESIS_FAMILY
				@synthesis_family = $1
			when KRX::REGEXP::SYNTHESIS_QUALITY
				@synthesis_quality = $1.to_i
			when KRX::REGEXP::SYNTHESIS_LEVEL
				@synthesis_level = $1.to_i
			when KRX::REGEXP::SYNTHESIS_COSTS
        $1.scan(/\d+/).each {|i| @synthesis_costs.push(i.to_i)}
			when KRX::REGEXP::SYNTHESIS_LOCKS
        $1.scan(/\d+/).each {|i| @synthesis_locks.push(i.to_i - 1)}
			end
		end
	end
	#--------------------------------------------------------------------------
	# ● Returns the synthesis quality
	#--------------------------------------------------------------------------
	def synthesis_quality
		KRX.determine_alchemic_value(:quality, self, @synthesis_quality)
	end
	#--------------------------------------------------------------------------
	# ● Returns the type of traits
	#--------------------------------------------------------------------------
  def traits_type
    :features
  end
	#--------------------------------------------------------------------------
	# ● Returns the effects
	#--------------------------------------------------------------------------
  alias_method(:krx_totori_item_features, :features)
  def features
    KRX.determine_alchemic_value(:features, self, krx_totori_item_features)
  end
end

#==========================================================================
# ■ Game_Party
#==========================================================================

class Game_Party < Game_Unit
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_accessor	:synthesis_level
	attr_accessor	:synthesis_traits
	attr_accessor	:synthesis_quality
  attr_accessor	:synthesis_exp
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
	alias_method(:krx_totori_gp_initialize, :initialize)
	def initialize
		krx_totori_gp_initialize
		@synthesis_level = 1.00
		@synthesis_traits = {}
		@synthesis_quality = {}
    @synthesis_exp = 0
	end
	#--------------------------------------------------------------------------
	# ● Checks for synthesis level up
	#--------------------------------------------------------------------------
  def synthesis_level_up
    while @synthesis_exp >= exp_to_next_synth_level
      @synthesis_level += 1.00
      @synthesis_exp = 0
    end
  end
	#--------------------------------------------------------------------------
	# ● Gains synthesis exp
	#--------------------------------------------------------------------------
  def gain_synthesis_exp(creation_level)
    @synthesis_exp += eval(KRX::SYNTH_EXP_FORMULA)
    synthesis_level_up
  end
	#--------------------------------------------------------------------------
	# ● Returns the exp needed for the next level
	#--------------------------------------------------------------------------
  def exp_to_next_synth_level
    eval(KRX::SYNTH_LEVEL_FORMULA)
  end
end

#==========================================================================
# ■ Window_SynthCategory
#==========================================================================

class Window_SynthCategory < Window_ItemCategory
	#--------------------------------------------------------------------------
	# ● Creates the command list
	#--------------------------------------------------------------------------
  def make_command_list
    list = KRX::SYNTH_CATEGORIES
    add_command(Vocab::item, :item) if list.include?(:item)
    add_command(Vocab::weapon, :weapon) if list.include?(:weapon)
    add_command(Vocab::armor, :armor)  if list.include?(:armor)
    add_command(Vocab::key_item, :key_item) if list.include?(:key_item)
  end
end

#==========================================================================
# ■ Window_SynthesisList
#==========================================================================
	
class Window_SynthesisList < Window_ItemList
	#--------------------------------------------------------------------------
	# ● Determine if an item goes in the list
	#--------------------------------------------------------------------------
	def include?(item)
		case @category
		when :item
			item.is_a?(RPG::Item) && !item.key_item?
		when :weapon
			item.is_a?(RPG::Weapon)
		when :armor
			item.is_a?(RPG::Armor)
		when :key_item
			item.is_a?(RPG::Item) && item.key_item?
		else
			return false
		end
	end
	#--------------------------------------------------------------------------
	# ● Determine if the required ingredients for synthesis are available
	#--------------------------------------------------------------------------
	def enable?(item)
		return false if item.nil?
		ok = []
		families = item.synthesis_reqs.collect {|x| x.synthesis_family}
		families.each do |family|
			for itm in $game_party.all_items
				next unless itm.synthesis_family == family
				if  $game_party.item_number(itm) >= 1
					ok.push(true)
					break
				end
			end
		end
		return ok.size == item.synthesis_reqs.size
	end
	#--------------------------------------------------------------------------
	# ● Creates the list based on the recipes
	#--------------------------------------------------------------------------
	def make_item_list
		@data = []
		recipes = $game_party.items.select {|item| !item.recipe_data.empty?}
		for rec in recipes
			for syn in rec.recipe_data
				@data.push(syn) if include?(syn)
			end
		end
	end
	#--------------------------------------------------------------------------
	# ● Displays the item icon and name
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
	# ● Assigns a properties window
	#--------------------------------------------------------------------------
	def prop_window=(value)
		@prop_window = value
	end
	#--------------------------------------------------------------------------
	# ● Refreshes the help and prop windows
	#--------------------------------------------------------------------------
	def update_help
		@help_window.set_item(item)
		@prop_window.set_item(item)
	end
	#--------------------------------------------------------------------------
	# ● Returns the number of columns
	#--------------------------------------------------------------------------
	def col_max
		return 1
	end
end

#==========================================================================
# ■ Window_IngredientList
#==========================================================================
	
class Window_IngredientList < Window_ItemList
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
	def initialize(x, y, w, h, item)
		super(x, y, w, h)
		@base_item = item
		refresh
	end
	#--------------------------------------------------------------------------
	# ● Determine if an item goes in the list
	#--------------------------------------------------------------------------
	def number?
		case @category
		when :ing0
			return 0
		when :ing1
			return 1
		when :ing2
			return 2
		when :ing3
			return 3
		else
			return 0
		end
	end
	#--------------------------------------------------------------------------
	# ● Enable
	#--------------------------------------------------------------------------
	def enable?(item)
		return $game_party.has_item?(item, false)
	end
	#--------------------------------------------------------------------------
	# ● Creates the list based on the recipes
	#--------------------------------------------------------------------------
	def make_item_list
		family = @base_item.synthesis_reqs[number?].synthesis_family
		@data = $game_party.all_items.select {|itm| itm.synthesis_family == family}
	end
	#--------------------------------------------------------------------------
	# ● Returns the number of columns
	#--------------------------------------------------------------------------
	def col_max
		return 1
	end
	#--------------------------------------------------------------------------
	# ● Assigns a properties window
	#--------------------------------------------------------------------------
	def prop_window=(value)
		@prop_window = value
	end
	#--------------------------------------------------------------------------
	# ● Refreshes the help and prop windows
	#--------------------------------------------------------------------------
	def update_help
		@help_window.set_item(item)
		@prop_window.set_item(item)
	end
end

#==========================================================================
# ■ Window_SynthesisProp
#==========================================================================
	
class Window_SynthesisProp < Window_Base
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
		draw_item_traits(item)
		draw_item_ingredients(item)
	end
	#--------------------------------------------------------------------------
	# ● Displays the item's traits
	#--------------------------------------------------------------------------
	def draw_item_traits(item)
    max = KRX::SYNTH_MAX_TRAITS
		change_color(system_color)
		contents.draw_text(0, 0, width, line_height, KRX::VOCAB::TRAITS)
		change_color(normal_color)
		(1..max).each {|i| contents.draw_text(0, line_height * i, width, line_height,
    "#{i}.")}
		item.traits.each_index do |i|
      break if i == max
      name = KRX::TraitsNamer.trait_name(item.traits[i])
			contents.draw_text(24, line_height * (i+1), width - 24, line_height, name)
		end
		draw_horz_line(line_height * 5)
	end
	#--------------------------------------------------------------------------
	# ● Displays the item's requires ingredients
	#--------------------------------------------------------------------------
	def draw_item_ingredients(item)
		change_color(system_color)
		contents.draw_text(0, line_height * 6, width, line_height, KRX::VOCAB::INGREDIENTS)
		change_color(normal_color)
		item.synthesis_reqs.each_index do |i|
			itm = item.synthesis_reqs[i]
			draw_item_name(itm, 0, line_height * (i + 7), true, width)
		end
	end
	#--------------------------------------------------------------------------
	# ● Displays an horizontal line
	#--------------------------------------------------------------------------
	def draw_horz_line(y)
		line_y = y + line_height / 2 - 1
		contents.fill_rect(0, line_y, contents_width, 2, line_color)
	end
	#--------------------------------------------------------------------------
	# ● Returns the color used for horizontal lines
	#--------------------------------------------------------------------------
	def line_color
		color = normal_color
		color.alpha = 48
		return color
	end
end

#==========================================================================
# ■ Window_IngredientProp
#==========================================================================
	
class Window_IngredientProp < Window_SynthesisProp
	#--------------------------------------------------------------------------
	# ● Refresh the contents
	#--------------------------------------------------------------------------
	def set_item(item = nil)
		contents.clear
		draw_current_cauldron
		return if item.nil?
		draw_item_traits(item)
	end
	#--------------------------------------------------------------------------
	# ● Displays the item's traits
	#--------------------------------------------------------------------------
	def draw_item_traits(item)
    max = KRX::SYNTH_MAX_TRAITS
		change_color(system_color)
		contents.draw_text(0, 0, width, line_height, KRX::VOCAB::QUALITY)
		size = text_size(KRX::VOCAB::QUALITY).width
		change_color(normal_color)
		contents.draw_text(size, 0, 32, line_height, item.synthesis_quality, 2)
    return if item.traits.empty?
		item.traits.each_index do |i|
      break if i == max
      name = KRX::TraitsNamer.trait_name(item.traits[i-1])
			cost = item.synthesis_costs[i-1]
			contents.draw_text(0, line_height * (i + 1), width, line_height, "#{i + 1}.")
			contents.draw_text(24, line_height * (i + 1), width - 24, line_height,
			"#{name} (#{cost})")
		end
	end
	#--------------------------------------------------------------------------
	# ● Displays the current ingredient selection
	#--------------------------------------------------------------------------
	def draw_current_cauldron
		draw_horz_line(line_height * 5)
		change_color(system_color)
		contents.draw_text(0, line_height * 6, width, line_height, KRX::VOCAB::CAULDRON)
		return if SceneManager.scene.cauldron.empty?
		change_color(normal_color)
		SceneManager.scene.cauldron.each_index do |i|
			draw_item_name(SceneManager.scene.cauldron(true)[i], 0, line_height * (i + 7), true, width)
		end
	end
end

#==========================================================================
# ■ Window_ItemFamily
#==========================================================================

class Window_ItemFamily < Window_ItemCategory
	#--------------------------------------------------------------------------
	# ● Create the commands list
	#--------------------------------------------------------------------------
	def make_command_list
		itm = $game_party.last_item.object
    famnbs = {}
		return if itm.nil?
		(0...itm.synthesis_reqs.size).each do |i|
			fam = itm.synthesis_reqs[i].synthesis_family
      famnbs[fam] = 0 if famnbs[fam].nil?
      famnbs[fam] += 1
      next if SceneManager.scene.cauldron_nb(fam) >= famnbs[fam]
      symb = "ing#{i}".to_sym
      add_command(fam, symb)
		end
	end
end

#==========================================================================
# ■ Window_TraitList
#==========================================================================

class Window_TraitList < Window_ItemList
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
	def initialize(x, y, w, h, p)
		@points = p
		@deleted = []
		super(x, y, w, h)
	end
	#--------------------------------------------------------------------------
	# ● Lists the traits of the items in the cauldron
	#--------------------------------------------------------------------------
	def make_item_list
		@data = []
    @costs = []
    target_itm = $game_party.last_item.object
    unless @deleted.size == KRX::SYNTH_MAX_TRAITS
      SceneManager.scene.cauldron(true).each do |item|
        next if item.traits_type != target_itm.traits_type
        item.traits.each_index do |i|
          trait = item.traits[i]
          next if @deleted.include?(trait)
          @data.push(trait)
          @costs.push(item.synthesis_costs[i])
        end
      end
		end
		@data.push(KRX::VOCAB::END_TRAIT_SELECTION)
    @data.uniq!
	end
	#--------------------------------------------------------------------------
	# ● Enable
	#--------------------------------------------------------------------------
	def enable?(item)
		return true if item == KRX::VOCAB::END_TRAIT_SELECTION
    return false if duplicate_trait_type?(item)
		@points >= @costs[@data.index(item)]
  end
	#--------------------------------------------------------------------------
	# ● Determine if there are two traits with the same function
	#--------------------------------------------------------------------------
	def duplicate_trait_type?(trait)
    itm = $game_party.last_item.object
    return false if $game_party.synthesis_traits[[itm.class, itm.id]].nil?
    $game_party.synthesis_traits[[itm.class, itm.id]].each do |arr|
      return true if arr[0] == trait.code && arr[1] == trait.data_id
    end
    false
  end
	#--------------------------------------------------------------------------
	# ● Remove a trait
	#--------------------------------------------------------------------------
	def remove_item(trait, points)
		@deleted.push(trait)
		@points = points
		refresh
	end
	#--------------------------------------------------------------------------
	# ● Returns the points cost of a trait
	#--------------------------------------------------------------------------
  def trait_cost(trait)
    @costs[@data.index(trait)]
  end
	#--------------------------------------------------------------------------
	# ● Displays the trait name and cost
	#--------------------------------------------------------------------------
	def draw_item(index)
		trait = @data[index]
		change_color(normal_color, enable?(trait))
    name = trait.is_a?(String) ? trait : KRX::TraitsNamer.trait_name(trait)
		contents.draw_text(4, index * line_height, width, line_height, name)
		return if trait == 'Finish!'
		cost = @costs[index]
		contents.draw_text(4, index * line_height, width - 32, line_height, cost, 2)
	end
	#--------------------------------------------------------------------------
	# ● Returns the number of columns
	#--------------------------------------------------------------------------
	def col_max
		return 1
	end
	#--------------------------------------------------------------------------
	# ● Refreshes the help window
	#--------------------------------------------------------------------------
	def update_help
		if @data[index] == KRX::VOCAB::END_TRAIT_SELECTION
			help = KRX::VOCAB::PERFORM_SYNTHESIS
		else
      help = KRX::TraitsNamer.trait_description(@data[index])
		end
		@help_window.set_text(help)
	end
end

#==========================================================================
# ■ Window_FinalItem
#==========================================================================
	
class Window_FinalItem < Window_SynthesisProp
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
	def initialize(x, y, w, h, q, p, l, s)
		@quality = q
		@points = p
		@level = l
		@success = [s, 100].min
		super(x, y, w, h)
	end
	#--------------------------------------------------------------------------
	# ● Alters the points value
	#--------------------------------------------------------------------------
	def update_points(value)
		@points = value
	end
	#--------------------------------------------------------------------------
	# ● Refresh the contents
	#--------------------------------------------------------------------------
	def set_item(item = $game_party.last_item.object)
		@item = item
		contents.clear
		draw_item_name(@item, 4, 0, true, width)
		draw_item_quality
		draw_item_traits
		draw_synthesis_success
    draw_synthesis_exp
	end
	#--------------------------------------------------------------------------
	# ● Displays the item quality
	#--------------------------------------------------------------------------
	def draw_item_quality
		change_color(system_color)
		contents.draw_text(4, line_height * 1, width, line_height, KRX::VOCAB::QUALITY)
		contents.draw_text(4, line_height * 2, width, line_height, KRX::VOCAB::SYNTH_POINTS)
		change_color(normal_color)
		s1 = text_size(KRX::VOCAB::QUALITY).width
		s2 = text_size(KRX::VOCAB::SYNTH_POINTS).width
		contents.draw_text(4 + s1, line_height * 1, 32, line_height, @quality.to_s, 2)
		contents.draw_text(4 + s2, line_height * 2, 32, line_height, @points.to_s, 2)
	end
	#--------------------------------------------------------------------------
	# ● Displays the item traits
	#--------------------------------------------------------------------------
	def draw_item_traits
    max = KRX::SYNTH_MAX_TRAITS
		draw_horz_line(line_height * 3)
		change_color(system_color)
		contents.draw_text(4, line_height * 4, width, line_height, KRX::VOCAB::TRAITS)
		change_color(normal_color)
		(1..max).each {|i| contents.draw_text(0, line_height * (i + 4), width,
    line_height, "#{i}.")}
		@item.traits.each_index do |i|
      break if i == max
      name = KRX::TraitsNamer.trait_name(@item.traits[i])
			contents.draw_text(24, line_height * (i+5), width - 24, line_height, name)
		end
	end
	#--------------------------------------------------------------------------
	# ● Displays the synthesis success rate
	#--------------------------------------------------------------------------
	def draw_synthesis_success
		draw_horz_line(line_height * 9)
		change_color(system_color)
		contents.draw_text(4, line_height * 10, width, line_height, KRX::VOCAB::LEVEL)
		contents.draw_text(4, line_height * 11, width, line_height, KRX::VOCAB::SUCCESS_RATE)
		s1 = text_size(KRX::VOCAB::LEVEL).width
		s2 = text_size(KRX::VOCAB::SUCCESS_RATE).width
		change_color(normal_color)
		contents.draw_text(4 + s1, line_height * 10, 32, line_height, @level.to_s, 2)
		case @success
			when 0..19
			change_color(knockout_color)
			when 20..49
			change_color(crisis_color)
			when 50..99
			change_color(normal_color)
			when 100
			change_color(mp_cost_color)
		end
		contents.draw_text(4 + s2, line_height * 11, 48, line_height, "#{@success}%", 2)
	end
	#--------------------------------------------------------------------------
	# ● Displays the current synthesis EXP
	#--------------------------------------------------------------------------
  def draw_synthesis_exp
    change_color(system_color)
    text = KRX::VOCAB::ALCHEMIC_LEVEL
    contents.draw_text(4, line_height * 12, width, line_height, text)
    s = text_size(text).width
    value = $game_party.synthesis_level.to_i
		change_color(normal_color)
		contents.draw_text(4 + s, line_height * 12, 24, line_height, value.to_s, 2)
    rate = $game_party.synthesis_exp / $game_party.exp_to_next_synth_level
    color1 = Color.new(0, 80, 0)
    color2 = Color.new(0, 200, 100)
    draw_gauge(s+48, line_height*12-2, width-(s+48), rate, color1, color2)
  end
end

#==========================================================================
# ■ Scene_Alchemy
#==========================================================================

class Scene_Alchemy < Scene_MenuBase
	#--------------------------------------------------------------------------
	# ● Scene start
	#--------------------------------------------------------------------------
	def start
		super
		@item_cauldron, @family_cauldron = [], []
		@old_traits = $game_party.synthesis_traits.dup
		@old_qual = $game_party.synthesis_quality.dup
    @queued_ings = []
		create_help_window
		create_category_window
		create_properties_window
		create_item_window
	end
	#--------------------------------------------------------------------------
	# ● Creates the window displaying the item categories
	#--------------------------------------------------------------------------
	def create_category_window
		@category_window = Window_SynthCategory.new
		@category_window.viewport = @viewport
		@category_window.help_window = @help_window
		@category_window.y = @help_window.height
		@category_window.set_handler(:ok,     method(:on_category_ok))
		@category_window.set_handler(:cancel, method(:return_scene))
	end
	#--------------------------------------------------------------------------
	# ● Creates the window displaying the item's properies and requirements
	#--------------------------------------------------------------------------
	def create_properties_window
		wy = @category_window.y + @category_window.height
		wh = Graphics.height - wy
		@prop_window = Window_SynthesisProp.new(Graphics.width / 2, wy,
    Graphics.width / 2, wh)
		@prop_window.viewport = @viewport
	end
	#--------------------------------------------------------------------------
	# ● Creates the window displaying the items available to synthesis
	#--------------------------------------------------------------------------
	def create_item_window
		wy = @category_window.y + @category_window.height
		wh = Graphics.height - wy
		@item_window = Window_SynthesisList.new(0, wy, Graphics.width / 2, wh)
		@item_window.viewport = @viewport
		@item_window.help_window = @help_window
		@item_window.prop_window = @prop_window
		@item_window.set_handler(:ok,     method(:on_item_ok))
		@item_window.set_handler(:cancel, method(:on_item_cancel))
		@category_window.item_window = @item_window
	end
	#--------------------------------------------------------------------------
	# ● Creates the window displaying the available ingredients
	#--------------------------------------------------------------------------
	def create_ingredient_window
		wy = @category_window.y + @category_window.height
		wh = Graphics.height - wy
		@i_prop_window = Window_IngredientProp.new(Graphics.width / 2, wy,
    Graphics.width / 2, wh)
		@i_prop_window.viewport = @viewport
		@ing_window = Window_IngredientList.new(0, wy, Graphics.width / 2, wh,
    @item_window.item)
		@ing_window.viewport = @viewport
		@ing_window.help_window = @help_window
		@ing_window.prop_window = @i_prop_window
		@ing_window.set_handler(:ok,     method(:on_ing_ok))
		@ing_window.set_handler(:cancel, method(:on_ing_cancel))
		@family_window = Window_ItemFamily.new
		@family_window.y = @help_window.height
		@family_window.item_window = @ing_window
		@family_window.set_handler(:ok,     method(:on_family_ok))
		@family_window.set_handler(:cancel,     method(:on_family_cancel))
		@family_window.activate
		@family_window.select(0)
	end
	#--------------------------------------------------------------------------
	# ● Creates the windows related to the cauldron
	#--------------------------------------------------------------------------
	def create_cauldron_windows
		wy = @help_window.y + @help_window.height
		wh = Graphics.height - wy
		ww = Graphics.width / 2
		@trait_window = Window_TraitList.new(0, wy, ww, wh, @points)
		@trait_window.refresh
		@trait_window.activate
		@trait_window.select(0)
		@trait_window.help_window = @help_window
		@trait_window.set_handler(:ok, method(:on_trait_ok))
		@trait_window.set_handler(:cancel, method(:on_trait_cancel))
		@final_window = Window_FinalItem.new(ww, wy, ww, wh, @quality, @points,
		@level, @success)
	end
	#--------------------------------------------------------------------------
	# ● Destroys the ingredient-related windows
	#--------------------------------------------------------------------------
	def destroy_ingredient_windows
		@ing_window.dispose; @ing_window = nil
		@family_window.dispose; @family_window = nil
		@i_prop_window.dispose; @i_prop_window = nil
	end
	#--------------------------------------------------------------------------
	# ● Destroys the cauldron-related windows
	#--------------------------------------------------------------------------
	def destroy_cauldron_windows
		@trait_window.dispose; @trait_window = nil
		@final_window.dispose; @final_window = nil
	end
	#--------------------------------------------------------------------------
	# ● Returns the current ingredient selection
	#--------------------------------------------------------------------------
	def cauldron(item = false)
		item ? @item_cauldron : @family_cauldron
	end
	#--------------------------------------------------------------------------
	# ● Update the cauldron contents
	#--------------------------------------------------------------------------
	def update_cauldron(add = true)
		if add
      $game_party.lose_item(@ing_window.item, 1)
      @queued_ings.push(@ing_window.item)
			@item_cauldron.push(@ing_window.item)
			@family_cauldron.push(@ing_window.item.synthesis_family)
			@ing_window.unselect
		else
      $game_party.gain_item(@queued_ings.pop, 1)
			@item_cauldron.pop
			@family_cauldron.pop
      @ing_window.item
		end
		@family_window.refresh
		@family_window.update
		@family_window.activate
		@family_window.select(0)
		@ing_window.update_help
	end
	#--------------------------------------------------------------------------
	# ● Returns the number of an element in the family cauldron
	#--------------------------------------------------------------------------
  def cauldron_nb(fam)
    result = 0
    @family_cauldron.each {|f| result += 1 if f == fam}
    result
  end
	#--------------------------------------------------------------------------
	# ● Determine the final quality of the item
	#--------------------------------------------------------------------------
	def compute_quality
		total_value = 0
		ary = []
		ary = @item_cauldron.collect {|itm| itm.synthesis_quality}
		ary.each {|v| total_value += v}
		rate = total_value / ary.size
		@quality = rate
		@points = rate
    oitm = $game_party.last_item.object
		$game_party.synthesis_quality[[oitm.class, oitm.id]] = rate
	end
	#--------------------------------------------------------------------------
	# ● Determine the synthesis success rate
	#--------------------------------------------------------------------------
	def compute_success
		@level = $game_party.last_item.object.synthesis_level
		@success = (100 * ($game_party.synthesis_level / @level)).round
	end
	#--------------------------------------------------------------------------
	# ● Synthesis outcome
	#--------------------------------------------------------------------------
	def process_outcome(failure = false)
		destroy_cauldron_windows
		wy = Graphics.height / 2 - @help_window.height / 2
		@help_window.move(0, wy, Graphics.width, @help_window.height - 16)
		@help_window.arrows_visible = false
		if failure
			@help_window.set_text(KRX::VOCAB::SYNTH_FAILED)
			$game_party.synthesis_traits = @old_traits.dup
			$game_party.synthesis_quality = @old_qual.dup
		else
			@help_window.set_text(KRX::VOCAB::SYNTH_SUCCESS)
			$game_party.gain_item($game_party.last_item.object, 1)
      $game_party.gain_synthesis_exp($game_party.last_item.object.synthesis_level)
		end
		Graphics.wait(40)
		on_item_cancel
    @item_cauldron.clear
    @family_cauldron.clear
		@help_window.move(0, 0, Graphics.width, @help_window.height + 16)
	end
	#--------------------------------------------------------------------------
	# ● Confirms the category selection
	#--------------------------------------------------------------------------
	def on_category_ok
		@item_window.activate
		@item_window.select_last
	end
	#--------------------------------------------------------------------------
	# ● Confirms the item selection
	#--------------------------------------------------------------------------
	def on_item_ok
		$game_party.last_item.object = @item_window.item
		@item_window.hide
		@category_window.hide
		@prop_window.hide
		create_ingredient_window
	end
	#--------------------------------------------------------------------------
	# ● Returns to the category selection
	#--------------------------------------------------------------------------
	def on_item_cancel
		@item_window.unselect
		@item_window.show
		@item_window.refresh
		@prop_window.set_item(nil)
		@prop_window.show
		@category_window.activate
		@category_window.show
	end
	#--------------------------------------------------------------------------
	# ● Confirms the family selection
	#--------------------------------------------------------------------------
	def on_family_ok
		@family_window.deactivate
		@ing_window.select_last
		@ing_window.activate
	end
	#--------------------------------------------------------------------------
	# ● Returns to the item selection
	#--------------------------------------------------------------------------
	def on_family_cancel
    $game_party.gain_item(@last_ing, 1) unless @last_ing.nil?
		unless cauldron.empty?
			update_cauldron(false)
			return
		end
		destroy_ingredient_windows
		@item_window.show
		@item_window.activate
		@category_window.show
		@prop_window.show
	end
	#--------------------------------------------------------------------------
	# ● Confirms the ingredient selection
	#--------------------------------------------------------------------------
	def on_ing_ok
    itm = $game_party.last_item.object
    update_cauldron
		if cauldron.size == itm.synthesis_reqs.size
      $game_party.synthesis_traits[[itm.class, itm.id]] = nil
			compute_quality
			compute_success
			destroy_ingredient_windows
			create_cauldron_windows
		end
	end
	#--------------------------------------------------------------------------
	# ● Returns to the family selection
	#--------------------------------------------------------------------------
	def on_ing_cancel
		@ing_window.unselect
		@i_prop_window.set_item(nil)
		@family_window.activate
	end
	#--------------------------------------------------------------------------
	# ● Validates a trait selection
	#--------------------------------------------------------------------------
	def on_trait_ok
		item = $game_party.last_item.object
		trait = @trait_window.item
		if trait == KRX::VOCAB::END_TRAIT_SELECTION
			if (rand(100) + 1) <= @success
				process_outcome
			else
				process_outcome(true)
			end
			return
		end
		if $game_party.synthesis_traits[[item.class, item.id]].nil?
			$game_party.synthesis_traits[[item.class, item.id]] = []
		end
    container = $game_party.synthesis_traits[[item.class, item.id]]
		if item.is_a?(RPG::Item)
      container.push([trait.code, trait.data_id, trait.value1, trait.value2])
    else
      container.push([trait.code, trait.data_id, trait.value])
    end
		@points -= @trait_window.trait_cost(trait)
		@trait_window.remove_item(trait, @points)
		@trait_window.activate
		@final_window.update_points(@points)
		@final_window.set_item(item)
	end
	#--------------------------------------------------------------------------
	# ● Returns to the ingredient selection
	#--------------------------------------------------------------------------
	def on_trait_cancel
		@family_cauldron.clear
		@item_cauldron.clear
		$game_party.synthesis_traits = @old_traits.dup
    $game_party.gain_item(@queued_ings.pop, 1) until @queued_ings.empty?
		destroy_cauldron_windows
		create_ingredient_window
	end
end

## Menu inclusion, with Yanfly's Ace Menu Engine
if $imported["YEA-AceMenuEngine"]

#==========================================================================
#  ■ Scene_Menu
#==========================================================================
	
class Scene_Menu < Scene_MenuBase
	#--------------------------------------------------------------------------
	# ● Switch to the synthesis scene
	#--------------------------------------------------------------------------
	def command_totori
    SceneManager.call(Scene_Alchemy)
  end
end

end ## End of Yanfly's Menu inclusion

end ## End of Traits Namer's check.