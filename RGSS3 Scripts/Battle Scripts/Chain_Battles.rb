#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Chain Battles
#  Author: Kread-EX
#  Version 1.0
#  Release date: 11/12/2011
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#-------------------------------------------------------------------------------------------------
#  ▼ TERMS OF USAGE
#-------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
# #
# # For support:
# # grimoirecastle.wordpress.com
# # OR
# # rpgmakervxace.net
# # OR
# # rpgrevolution.com
#-------------------------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#-------------------------------------------------------------------------------------------------
# # Battles can be started in succession without pause. The EXP and gold raises
# # depending of the successive battles number but in case of escape or defeat
# # everything is lost. Think Romancing SaGa; Minstrel Song.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # You'll need to allocate 2 variables: one will indicate the troop ID of the next
# # battle and the second the percentage of the chain happening.
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
# # Works with the DBS and Ace Battle Engine. 
# # List of aliases and overwrites:
# #
# # BattleManager
# # process_victory (alias)
# # battle_start (alias)
# # battle_end (alias)
# # init_members (alias)
# # store_chain_rewards (new method)
# # clear_chain_data (new method)
# #
# # Game_Temp
# # initialize (alias)
# #
# # Game_Troop
# # exp_total (alias)
# # gold_total (alias)
# # make_drop_items (alias)
#-------------------------------------------------------------------------------------------------

# YEA compatibility
if $imported != nil
	$imported['KRX-ChainBattles'] = true
end

puts 'Load: Chain Battles v1.0 by Kread-EX'

module KRX

	CHAIN_TROOP = 3
	CHAIN_CHANCE = 4
	
end

#===========================================================================
# ■ BattleManager
#===========================================================================

module BattleManager
	#--------------------------------------------------------------------------
	# ● Aliases
	#--------------------------------------------------------------------------
	class << self
		unless $@
			alias_method(:krx_bchain_bm_pvic, :process_victory)
			alias_method(:krx_bchain_bm_start, :battle_start)
			alias_method(:krx_bchain_bm_end, :battle_end)
			alias_method(:krx_bchain_bm_init, :init_members)
		end
	end
	#--------------------------------------------------------------------------
	# ● Initializes the members
	#--------------------------------------------------------------------------
	def self.init_members
		return if $game_temp.chain_start
		krx_bchain_bm_init
	end
	#--------------------------------------------------------------------------
	# ● Initializes the battle data
	#--------------------------------------------------------------------------
	def self.battle_start
		if $game_temp.chain_start
			$game_system.battle_count += 1
			$game_temp.chain_bonus += 0.25
			$game_troop.on_battle_start
			$game_variables[KRX::CHAIN_TROOP] = 0
			# YEA style
			unless ($imported != nil && $imported['YEA-BattleEngine'])
				$game_troop.enemy_names.each do |name|
					$game_message.add(sprintf(Vocab::Emerge, name))
				end
			end
			# End of YEA style
			
			$game_temp.chain_start = false
			wait_for_message
			return
		end
		krx_bchain_bm_start
	end
	#--------------------------------------------------------------------------
	# ● Ends the battle
	#--------------------------------------------------------------------------
	def self.battle_end(result)
		clear_chain_data unless result == 0
		krx_bchain_bm_end(result)
	end
	#--------------------------------------------------------------------------
	# ● Process the victory handler
	#--------------------------------------------------------------------------
	def self.process_victory
		ct = $game_variables[KRX::CHAIN_TROOP]
		cc = $game_variables[KRX::CHAIN_CHANCE]
		if ct > 0 && (rand(100) + 1) <= cc
			store_chain_rewards
			$game_temp.chain_start = true
			SceneManager.return
			SceneManager.call(Scene_Battle)
			setup(ct, @can_escape, @can_lose)
			$game_troop.screen.start_flash(Color.new(255, 0, 0, 160), 40)
			return true
		end
		krx_bchain_bm_pvic
	end
	#--------------------------------------------------------------------------
	# ● Stores the rewards
	#--------------------------------------------------------------------------
	def self.store_chain_rewards
		$game_temp.chain_exp += $game_troop.exp_total
		$game_temp.chain_gold += $game_troop.gold_total
		$game_troop.make_drop_items.each do |item|
			$game_temp.chain_spoils.push(item)
		end
	end
	#--------------------------------------------------------------------------
	# ● Resets the data
	#--------------------------------------------------------------------------
	def self.clear_chain_data
		$game_temp.chain_exp = 0
		$game_temp.chain_gold = 0
		$game_temp.chain_spoils.clear
		$game_temp.chain_bonus = 0
		$game_temp.chain_start = false
		$game_variables[KRX::CHAIN_TROOP] = 0
	end
end

#===========================================================================
# ■ Game_Temp
#===========================================================================

class Game_Temp
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_accessor	:chain_exp
	attr_accessor	:chain_gold
	attr_accessor	:chain_spoils
	attr_accessor	:chain_start
	attr_accessor	:chain_bonus
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
	alias_method(:krx_bchain_gt_init, :initialize) unless $@
	def initialize
		krx_bchain_gt_init
		@chain_exp = @chain_gold = 0
		@chain_spoils = []
		@chain_start = false
		@chain_bonus = 0
	end
end

#===========================================================================
# ■ Game_Troop
#===========================================================================

class Game_Troop < Game_Unit
	#--------------------------------------------------------------------------
	# ● Returns the EXP total of the enemies
	#--------------------------------------------------------------------------
	alias_method(:krx_bchain_troop_exp, :exp_total) unless $@
	def exp_total
		((krx_bchain_troop_exp + $game_temp.chain_exp) *
		($game_temp.chain_bonus + 1)).round
	end
	#--------------------------------------------------------------------------
	# ● Returns the gold total of the enemies
	#--------------------------------------------------------------------------
	alias_method(:krx_bchain_troop_gold, :gold_total) unless $@
	def gold_total
		((krx_bchain_troop_gold + $game_temp.chain_gold)  *
		($game_temp.chain_bonus + 1)).round
	end
	#--------------------------------------------------------------------------
	# ● Returns the spoils dropped by the enemies
	#--------------------------------------------------------------------------
	alias_method(:krx_bchain_troop_spoils, :make_drop_items) unless $@
	def make_drop_items
		krx_bchain_troop_spoils + $game_temp.chain_spoils
	end
end