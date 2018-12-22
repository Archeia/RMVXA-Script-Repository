#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ EXP Decay
#  Author: Kread-EX
#  Version 1.0
#  Release date: 02/02/2012
#
#  Big thanks to Arius.
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
# # This script lowers the experience given by the enemies upon death if they
# # are killed more than one time. It's a rough anti-grinding technique.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # Notetags are used to make EXP Decay work, and they are used on the enemies.
# # Three different tags are available:
# # <no_exp_decay>
# # By default, all enemies are affected. This tag prevent any decay to be applied
# # on the enemy.
# # <decay_rate: x>
# # The experience yielded will be reduced by x% per kill.
# # <decay_max: x>
# # The experience reduction will never go past x%.
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#-------------------------------------------------------------------------------------------------
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_expdecay_notetags (new method)
# #
# # RPG::Enemy
# # load_expdecay_notetags (new method)
# # exp_decay_rate (new attr method)
# # exp_decay_max (new attr method)
# # exp_decay_disable (new attr method)
# #
# # BattleManager
# # process_victory (alias)
# #
# # Game_Enemy
# # exp (alias)
# #
# # Game_Party
# # death_toll (new method)
# # death_toll_add (new method)
#-------------------------------------------------------------------------------------------------

$imported = {} if $imported.nil?
$imported['KRX-EXPDecay'] = true

puts 'Load: EXP Decay v1.0 by Kread-EX'

module KRX
  
  DEFAULT_EXP_DECAY_RATE = 25
  DEFAULT_EXP_DECAY_MAX = 100
  
  module REGEXP
    DECAY_OFF = /<no_exp_decay>/i
    unless $imported['KRX-SkillDecay']
      DECAY_RATE = /<decay_rate:[ ]*(\d+)>/i
      DECAY_MAX = /<decay_max:[ ]*(\d+)>/i
    end
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
		alias_method(:krx_expdecay_dm_load_database, :load_database)
	end
	def self.load_database
		krx_expdecay_dm_load_database
		load_expdecay_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_expdecay_notetags
		groups = [$data_enemies]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_expdecay_notetags
			end
		end
		puts "Read: EXP Decay Notetags"
	end
end

#===========================================================================
# ■ RPG::Enemy
#===========================================================================

class RPG::Enemy < RPG::BaseItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader   :exp_decay_rate
  attr_reader   :exp_decay_max
  attr_reader   :exp_decay_disable
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_expdecay_notetags
    @exp_decay_rate = KRX::DEFAULT_EXP_DECAY_RATE
    @exp_decay_max = KRX::DEFAULT_EXP_DECAY_MAX
    @exp_decay_disable = false
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::DECAY_OFF
        @exp_decay_disable = true
      when KRX::REGEXP::DECAY_RATE
        @exp_decay_rate = $1.to_i
      when KRX::REGEXP::DECAY_MAX
        @exp_decay_max = $1.to_i
			end
		end
	end
end

#==============================================================================
# ■ BattleManager
#==============================================================================

module BattleManager
	#--------------------------------------------------------------------------
	# ● Process the victory event
	#--------------------------------------------------------------------------
	class << self ; alias_method(:krx_expdecay_bm_pv, :process_victory); end
	def self.process_victory
    krx_expdecay_bm_pv
    $game_troop.members.each do |enemy|
      $game_party.death_toll_add(enemy.enemy_id)
    end
  end
end

#===========================================================================
# ■ Game_Enemy
#===========================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● Returns the exp yielded by a kill
  #--------------------------------------------------------------------------
  alias_method(:krx_expdecay_ge_exp, :exp)
  def exp
    base = krx_expdecay_ge_exp
    return base if enemy.exp_decay_disable
    rate = $game_party.death_toll(@enemy_id) * enemy.exp_decay_rate
    (base * ([(100.00 - rate), (100 - enemy.exp_decay_max)].max / 100)).round
  end
end

#===========================================================================
# ■ Game_Party
#===========================================================================

class Game_Party < Game_Unit
	#--------------------------------------------------------------------------
	# ● Returns the death toll of a specific enemy
	#--------------------------------------------------------------------------
  def death_toll(index)
    @death_toll = {} if @death_toll.nil?
    @death_toll[index] ||= 0
  end
	#--------------------------------------------------------------------------
	# ● Increments the toll
	#--------------------------------------------------------------------------
  def death_toll_add(index)
    val = death_toll(index)
    @death_toll[index] = val + 1
  end
end