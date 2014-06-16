#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Conditioned Traits
#  Author: Kread-EX
#  Version 1.06
#  Release date: 10/12/2011
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#------------------------------------------------------------------------------
#  ▼ UPDATES
#------------------------------------------------------------------------------
# # 01/04/2013. Added switch condition for equipment.
# # 26/03/2012. Bugfix: I forgot parenthesis D:
# # 21/03/2012. Added skill condition for actors and classes.
# # 23/02/2012. Fixed a bug with multiples conditioned traits.
# # 24/12/2011. Fixed a bug with the full version of Ace.
#------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#------------------------------------------------------------------------------
# # A simple script allowing you to specify conditions for traits in the every
# # case it applies.
# # 
# # Features
# # - Level condition (for actors)
# # - Switch condition (for classes and enemies)
# # - Skill condition (for actors and classes)
#------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#------------------------------------------------------------------------------
# # Very easy, just use a notetag in either the actors, classes or enemies tab.
# # <trait_condition: x, y, z>
# # x = the trait number in the field (note that it starts at 0, not 1)
# # y = two possible strings: level and switch (level is only for actors)
# # z = either the level threshold or the switch ID
# #
# # NEW: y can be skill for both classes and actors.
#------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#------------------------------------------------------------------------------
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_condtraits_notetags (new method)
# #
# # RPG::Actor, RPG::Class, RPG::Enemy
# # load_condtraits_notetags (new method)
# #
# # Game_BattlerBase
# # all_features (alias)
# # remove_invalid_features (new method)
#------------------------------------------------------------------------------

#puts 'Load: Conditioned Traits v1.06 by Kread-EX'

module KRX
	
	module REGEXP
		TRAIT_CONDITION = /<trait_condition:[ ]*(\d+, \w+, .+]*)>/i
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
		alias_method(:krx_condtraits_dm_load_database, :load_database) unless $@
	end
	def self.load_database
		krx_condtraits_dm_load_database
		load_condtraits_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_condtraits_notetags
		groups = [$data_actors, $data_classes, $data_enemies, $data_weapons,
    $data_armors]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_condtraits_notetags
			end
		end
		#puts "Read: Conditioned Traits Notetags"
	end
end

#===========================================================================
# ■ RPG::Actor
#===========================================================================

class RPG::Actor
	#--------------------------------------------------------------------------
	# ● Constants
	#--------------------------------------------------------------------------
  COND_TRAITS = [:level, :switch, :skill]
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_reader		:traits_conditions
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_condtraits_notetags
		@traits_conditions = {}
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::TRAIT_CONDITION
        ary = []
				$1.scan(/\w+/).each {|i| ary.push(i)}
				@traits_conditions[features[ary[0].to_i]] = [ary[1].to_sym]
				if COND_TRAITS.include?(@traits_conditions[features[ary[0].to_i]][0])
					@traits_conditions[features[ary[0].to_i]].push(ary[2].to_i)
				end
			end
		end
	end
end

#===========================================================================
# ■ RPG::Class
#===========================================================================

class RPG::Class
	#--------------------------------------------------------------------------
	# ● Constants
	#--------------------------------------------------------------------------
  COND_TRAITS = [:switch, :skill]
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_reader		:traits_conditions
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_condtraits_notetags
		@traits_conditions = {}
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::TRAIT_CONDITION
        ary = []
				$1.scan(/\w+/).each {|i| ary.push(i)}
				@traits_conditions[features[ary[0].to_i]] = [ary[1].to_sym]
				if COND_TRAITS.include?(@traits_conditions[features[ary[0].to_i]][0])
					@traits_conditions[features[ary[0].to_i]].push(ary[2].to_i)
				end
			end
		end
	end
end

#===========================================================================
# ■ RPG::EquipItem
#===========================================================================

class RPG::EquipItem < RPG::BaseItem
	#--------------------------------------------------------------------------
	# ● Constants
	#--------------------------------------------------------------------------
  COND_TRAITS = [:switch]
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_reader		:traits_conditions
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_condtraits_notetags
		@traits_conditions = {}
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::TRAIT_CONDITION
        ary = []
				$1.scan(/\w+/).each {|i| ary.push(i)}
				@traits_conditions[features[ary[0].to_i]] = [ary[1].to_sym]
				if COND_TRAITS.include?(@traits_conditions[features[ary[0].to_i]][0])
					@traits_conditions[features[ary[0].to_i]].push(ary[2].to_i)
				end
			end
		end
	end
end

#===========================================================================
# ■ RPG::Enemy
#===========================================================================

class RPG::Enemy
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_reader		:traits_conditions
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_condtraits_notetags
		@traits_conditions = {}
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::TRAIT_CONDITION
        ary = []
				$1.scan(/\w+/).each {|i| ary.push(i)}
				@traits_conditions[features[ary[0].to_i]] = [ary[1].to_sym]
				if @traits_conditions[features[ary[0].to_i]][0] == :switch
					@traits_conditions[features[ary[0].to_i]].push(ary[2].to_i)
				end
			end
		end
	end
end

#===========================================================================
# ■ Game_BattlerBase
#===========================================================================

class Game_BattlerBase
	#--------------------------------------------------------------------------
	# ● Removes the unauthorized features
	#--------------------------------------------------------------------------
	def remove_invalid_features(ary)
		new_ary = ary.dup
		ary.each do |f|
			if self.is_a?(Game_Actor)
				if actor.traits_conditions[f] != nil
					case actor.traits_conditions[f][0]
						when :level
						new_ary.delete(f) if !(actor.traits_conditions[f][1] <= level)
						when :switch
						new_ary.delete(f) if !$game_switches[actor.traits_conditions[f][1]]
            when :skill
            skill = $data_skills[actor.traits_conditions[f][1]]
            new_ary.delete(f) if !skill_learn?(skill)
					end
				end
				if self.class.traits_conditions[f] != nil
          case self.class.traits_conditions[f][0]
            when :switch
            new_ary.delete(f) if !$game_switches[self.class.traits_conditions[f][1]]
            when :skill
            skill = $data_skills[self.class.traits_conditions[f][1]]
            new_ary.delete(f) if !skill_learn?(skill)
          end
				end
        self.equips.each do |equip|
          next if equip.nil?
          if equip.traits_conditions[f] != nil
            new_ary.delete(f) if !$game_switches[equip.traits_conditions[f][1]]
          end
        end
			elsif self.is_a?(Game_Enemy) && enemy.traits_conditions[f] != nil
				if enemy.traits_conditions[f] != nil &&
				enemy.traits_conditions[f][0] == :switch
					new_ary.delete(f) if !$game_switches[enemy.traits_conditions[f][1]]
				end
			end
		end
		return new_ary.compact
	end
	#--------------------------------------------------------------------------
	# ● Returns the list of features
	#--------------------------------------------------------------------------
	alias_method(:krx_condtraits_gbb_all_features, :all_features) unless $@
	def all_features
		ary = krx_condtraits_gbb_all_features
		return remove_invalid_features(ary)
	end
end