#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Advanced Trait Manager
#  Author: Kread-EX
#  Version 1.02
#  Release date: 25/03/2012
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#------------------------------------------------------------------------------
#  ▼ UPDATES
#------------------------------------------------------------------------------
# # 01/04/2012. Fixed a Trait error.
# # 27/03/2012. Fixed a Vocab error.
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
# # Add-on for the Alchemic Synthesis script, it allows for a better control on
# # which trait appear on which item.
#------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#------------------------------------------------------------------------------
# # Just setup the traits by following the template.
#------------------------------------------------------------------------------

if $imported.nil? || $imported['KRX-AlchemicSynthesis'].nil?
	
msgbox('You need the Alchemic Synthesis script in order to use the Advanced
Trait Manager. Loading aborted.')

else
	
$imported['KRX-AdvTraitManager'] = true

puts 'Load: Advanced Trait Manager v1.02 by Kread-EX'

module KRX
#===========================================================================
# ■ CONFIGURATION
#===========================================================================

  SYNTHESIS_TRAITS = {
    
  # Format:
  # "Trait name" => [a, b, [[c, d, e, (f)], [c, d, e, (f)]...], 'string']
  # a: category. 0 for feature, 1 for effect.
  # b: the trait cost.
  # c: trait code.
  # d: trait data_id.
  # e: trait value or value1 (for effects).
  # f: trait value2 (only for effects).
  # string: trait description (leave to nil in order to use the Traits Namer).
  
  # The various traits appearing on equipment pieces.
		
  "Poisonous" => [0, 3, [[32, 2, 50]]],
  "Venomous" => [0, 8, [[32, 2, 100]]],
  "Dragon Power" => [0, 10, [[22, 2, 25]]],
  "Damage Reducer" => [0, 20, [[23, 6, 50], [23, 7, 50]], "Halves all damage."],
  "Safety Card" => [0, 8, [[64, 0, 0]]],
  "Good Fortune" => [0, 25, [[64, 4, 0]]],
  "Shield of Fire" => [0, 10, [[11, 3, 0]]],
  "Shield of Ice" => [0, 10, [[11, 4, 0]]],
  "Shield of Lightning" => [0, 10, [[11, 5, 0]]],
  "Shield of Water" => [0, 10, [[11, 6, 0]]],
  "Shield of Earth" => [0, 10, [[11, 7, 0]]],
  "Shield of Wind" => [0, 10, [[11, 8, 0]]],
  "Ninja Power" => [0, 15, [[22, 1, 100]]],
  "Hero Soul" => [0, 15, [[21, 0, 150]]],
  "Double Move" => [0, 20, [[61, 0, 100]]],
  "Atk +30%" => [0, 10, [[21, 3, 30]]],
  "Def +30%" => [0, 10, [[21, 4, 30]]],
  "Mag +30%" => [0, 10, [[21, 5, 30]]],
  "Mgr +30%" => [0, 10, [[21, 6, 30]]],
  "Berserker Dance" => [0, 8, [[43, 83, 0]]],
		
  # The traits appearing on usable items.
		
  "Atk+" => [1, 5, [[31, 2, 5, 0]]],
  "Def+" => [1, 5, [[31, 3, 5, 0]]],
  "Mag+" => [1, 5, [[31, 4, 5, 0]]],
  "Mgr+" => [1, 5, [[31, 5, 5, 0]]],
  "Agi+" => [1, 5, [[31, 6, 5, 0]]],
  "Lck+" => [1, 5, [[31, 7, 5, 0]]],
  "Atk-" => [1, 5, [[32, 2, 5, 0]]],
  "Def-" => [1, 5, [[32, 3, 5, 0]]],
  "Mag-" => [1, 5, [[32, 4, 5, 0]]],
  "Mgr-" => [1, 5, [[32, 5, 5, 0]]],
  "Agi-" => [1, 5, [[32, 6, 5, 0]]],
  "Lck-" => [1, 5, [[32, 7, 5, 0]]],
  "HP Recovery XS" => [1, 1, [[11, 0, 10, 0]]],
  "HP Recovery S" => [1, 4, [[11, 0, 25, 0]]],
  "HP Recovery M" => [1, 8, [[11, 0, 50, 0]]],
  "HP Recovery L" => [1, 16, [[11, 0, 75, 0]]],
  "HP Recovery XL" => [1, 2, [[11, 0, 100, 0]]],
  "MP Recovery XS" => [1, 1, [[12, 0, 10, 0]]],
  "MP Recovery S" => [1, 4, [[12, 0, 25, 0]]],
  "MP Recovery M" => [1, 8, [[12, 0, 50, 0]]],
  "MP Recovery L" => [1, 16, [[12, 0, 75, 0]]],
  "MP Recovery XL" => [1, 25, [[12, 0, 100, 0]]],
  "TP Recovery XS" => [1, 1, [[13, 0, 2, 0]]],
  "TP Recovery S" => [1, 4, [[13, 0, 5, 0]]],
  "TP Recovery M" => [1, 8, [[13, 0, 10, 0]]],
  "TP Recovery L" => [1, 16, [[13, 0, 16, 0]]],
  "TP Recovery XL" => [1, 25, [[13, 0, 20, 0]]],
  "Revive XS" => [1, 1, [[22, 1, 100, 0], [11, 0, 10, 0]], "Revives and restores 10% HP."],
  "Revive S" => [1, 4, [[22, 1, 100, 0], [11, 0, 25, 0]], "Revives and restores 25% HP."],
  "Revive M" => [1, 8, [[22, 1, 100, 0], [11, 0, 50, 0]], "Revives and restores 50% HP."],
  "Revive L" => [1, 16, [[22, 1, 100, 0], [11, 0, 75, 0]], "Revives and restores 75% HP."],
  "Revive XL" => [1, 25, [[22, 1, 100, 0], [11, 0, 100, 0]], "Revives and restores 100% HP."],
  "Poison Recovery" => [1, 1, [[22, 2, 100, 0]]],
  "MP Eater" => [1, 13, [[12, 0, -75, 0]], "Reduces MP by 75%."]
    
  }
#===========================================================================
# ■ CONFIGURATION ENDS HERE
#===========================================================================
	module REGEXP
		SYNTHESIS_TRAITS_ON = /<synth_traits>/i
    SYNTHESIS_TRAITS_OFF = /<\/synth_traits>/i
	end
	#--------------------------------------------------------------------------
	# ● Build a trait based on the advanced data
	#--------------------------------------------------------------------------
  def self.build_trait(data)
    data[0] == 0 ? build_feature(data) : build_effect(data)
  end
	#--------------------------------------------------------------------------
	# ● Build a feature based on the advanced data
	#--------------------------------------------------------------------------
  def self.build_feature(data)
    feature = data[2].size == 1 ? 0 : []
    if feature.is_a?(Array)
      data[2].each do |arr|
        obj = RPG::BaseItem::Feature.new(arr[0], arr[1], arr[2])
        feature.push(obj)
      end
    else
      arr = data[2][0]
      feature = RPG::BaseItem::Feature.new(arr[0], arr[1], arr[2])
    end
    feature
  end
	#--------------------------------------------------------------------------
	# ● Build an effect based on the advanced data
	#--------------------------------------------------------------------------
  def self.build_effect(data)
    effect = data[2].size == 1 ? 0 : []
    if effect.is_a?(Array)
      data[2].each do |arr|
        v1 = self.correct_value(arr, arr[2])
        v2 = self.correct_value(arr, arr[3])
        obj = RPG::UsableItem::Effect.new(arr[0], arr[1], v1, v2)
        effect.push(obj)
      end
    else
      arr = data[2][0]
      v1 = self.correct_value(arr, arr[2])
      v2 = self.correct_value(arr, arr[3])
      effect = RPG::UsableItem::Effect.new(arr[0], arr[1], v1, v2)
    end
    effect
  end
	#--------------------------------------------------------------------------
	# ● Corrects the erroneous values
	#--------------------------------------------------------------------------
  def self.correct_value(data, val)
    code = data[0]
    result = case code
    when 11, 12 # HP/MP recovery
      val == data[2] ? val * 0.01 : val
    else
      val
    end
    result
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
          result.push(build_effect(SYNTHESIS_TRAITS[a]))
        end
        final_result = default_value + result.flatten
        return final_result
      end
    when :features
      adds = $game_party.synthesis_traits[[object.class, object.id]]
      if adds != nil
        result = []
        adds.each do |a|
          result.push(build_feature(SYNTHESIS_TRAITS[a]))
        end
        final_result = default_value + result.flatten
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
		alias_method(:krx_totoriadv_dm_ld, :load_database)
	end
	def self.load_database
		krx_totoriadv_dm_ld
		load_synthadv_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_synthadv_notetags
		groups = [$data_items, $data_weapons, $data_armors]
		classes = [RPG::Item, RPG::Weapon, RPG::Armor]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_synthadv_notetags if classes.include?(obj.class)
			end
		end
		puts "Read: Advanced Trait Manager Notetags"
	end
end

#==========================================================================
# ■ RPG::Item
#==========================================================================

class RPG::Item < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_reader		:synthesis_traits
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_synthadv_notetags
		@synthesis_traits = []
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::SYNTHESIS_TRAITS_ON
				@parse_traits = true
			when KRX::REGEXP::SYNTHESIS_TRAITS_OFF
				@parse_traits = false
			else
        @synthesis_traits.push(line) if @parse_traits
			end
		end
	end
end

#==========================================================================
# ■ RPG::EquipItem
#==========================================================================

class RPG::EquipItem < RPG::BaseItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_reader		:synthesis_traits
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_synthadv_notetags
		@synthesis_traits = []
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::SYNTHESIS_TRAITS_ON
				@parse_traits = true
			when KRX::REGEXP::SYNTHESIS_TRAITS_OFF
				@parse_traits = false
			else
        @synthesis_traits.push(line) if @parse_traits
			end
		end
	end
end

#==========================================================================
# ■ Window_SynthesisProp
#==========================================================================
	
class Window_SynthesisProp < Window_Base

	#--------------------------------------------------------------------------
	# ● Displays the item's traits
	#--------------------------------------------------------------------------
	def draw_item_traits(item)
    max = KRX::SYNTH_MAX_TRAITS
    draw_horz_line(line_height * 5)
		change_color(system_color)
		contents.draw_text(0, 0, width, line_height, KRX::VOCAB::TRAITS)
		change_color(normal_color)
		(1..max).each {|i| contents.draw_text(0, line_height * i, width, line_height,
    "#{i}.")}
    container = $game_party.synthesis_traits[[item.class, item.id]]
    return if container.nil?
		container.each_index do |i|
      break if i == max
      name = container[i]
			contents.draw_text(24, line_height * (i+1), width - 24, line_height, name)
		end
	end
end

#==========================================================================
# ■ Window_IngredientProp
#==========================================================================

class Window_IngredientProp < Window_SynthesisProp
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
    return if item.synthesis_traits.empty?
		item.synthesis_traits.each_index do |i|
      break if i == max
      name = item.synthesis_traits[i]
			cost = KRX::SYNTHESIS_TRAITS[item.synthesis_traits[i]][1]
			contents.draw_text(0, line_height * (i + 1), width, line_height, "#{i + 1}.")
			contents.draw_text(24, line_height * (i + 1), width - 24, line_height,
			"#{name} (#{cost})")
		end
	end
end

#==========================================================================
# ■ Window_TraitList
#==========================================================================

class Window_TraitList < Window_ItemList
	#--------------------------------------------------------------------------
	# ● Lists the traits of the items in the cauldron
	#--------------------------------------------------------------------------
	def make_item_list
		@data = []
    target_itm = $game_party.last_item.object
    unless @deleted.size == 4
      SceneManager.scene.cauldron(true).each do |item|
        item.synthesis_traits.each_index do |i|
          trait = item.synthesis_traits[i]
          tdata = KRX::SYNTHESIS_TRAITS[trait]
          next if tdata[0] == 0 && target_itm.is_a?(RPG::Item)
          next if tdata[0] == 1 && target_itm.is_a?(RPG::EquipItem)
          next if @deleted.include?(trait) || @data.include?(trait)
          @data.push(trait)
        end
      end
		end
		@data.push(KRX::VOCAB::END_TRAIT_SELECTION)
	end
	#--------------------------------------------------------------------------
	# ● Enable
	#--------------------------------------------------------------------------
	def enable?(item)
		return true if item == KRX::VOCAB::END_TRAIT_SELECTION
    return false if duplicate_trait_type?(item)
		@points >= KRX::SYNTHESIS_TRAITS[item][1]
  end
	#--------------------------------------------------------------------------
	# ● Determine if there are two traits with the same function
	#--------------------------------------------------------------------------
	def duplicate_trait_type?(trait)
    itm = $game_party.last_item.object
    return false if $game_party.synthesis_traits[[itm.class, itm.id]].nil?
    $game_party.synthesis_traits[[itm.class, itm.id]].each do |str|
      return true if str == trait
    end
    false
  end
	#--------------------------------------------------------------------------
	# ● Returns the points cost of a trait
	#--------------------------------------------------------------------------
  def trait_cost(trait)
    KRX::SYNTHESIS_TRAITS[trait][1]
  end
	#--------------------------------------------------------------------------
	# ● Displays the trait name and cost
	#--------------------------------------------------------------------------
	def draw_item(index)
		trait = @data[index]
		change_color(normal_color, enable?(trait))
		contents.draw_text(4, index * line_height, width, line_height, trait)
		return if trait == KRX::VOCAB::END_TRAIT_SELECTION
		cost = trait_cost(trait)
		contents.draw_text(4, index * line_height, width - 32, line_height, cost, 2)
	end
	#--------------------------------------------------------------------------
	# ● Refreshes the help window
	#--------------------------------------------------------------------------
	def update_help
		if @data[index] == KRX::VOCAB::END_TRAIT_SELECTION
			help = KRX::VOCAB::PERFORM_SYNTHESIS
		else
      tdata = KRX::SYNTHESIS_TRAITS[@data[index]]
      help = tdata[3]
      if help.nil?
        trait = KRX.build_trait(tdata)
        help = KRX::TraitsNamer.trait_description(trait)
      end
		end
		@help_window.set_text(help)
	end
end

#==========================================================================
# ■ Window_FinalItem
#==========================================================================
	
class Window_FinalItem < Window_SynthesisProp
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
    container = $game_party.synthesis_traits[[@item.class, @item.id]]
    return if container.nil?
		container.each_index do |i|
      break if i == max
      name = container[i]
			contents.draw_text(24, line_height * (i+5), width - 24, line_height, name)
		end
	end
end

#==========================================================================
# ■ Scene_Alchemy
#==========================================================================

class Scene_Alchemy < Scene_MenuBase
	#--------------------------------------------------------------------------
	# ● Validates a trait selection
	#--------------------------------------------------------------------------
	def on_trait_ok
		item = $game_party.last_item.object
		tname = @trait_window.item
		if tname == KRX::VOCAB::END_TRAIT_SELECTION
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
    $game_party.synthesis_traits[[item.class, item.id]].push(tname)
		@points -= @trait_window.trait_cost(tname)
		@trait_window.remove_item(tname, @points)
		@trait_window.activate
		@final_window.update_points(@points)
		@final_window.set_item(item)
	end
end

end # End parent script check