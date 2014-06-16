#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Skill Decay
#  Author: Kread-EX
#  Version 1.01
#  Release date: 28/01/2012
#
#  Big thanks to infamous bon bon.
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#-------------------------------------------------------------------------------------------------
#  ▼ UPDATES
#-------------------------------------------------------------------------------------------------
# # 30/01/2012. Fixed a really stupid bug.
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
# # Skills used in battle start to decay and lose effectiveness. The decay can
# # eventually be reverted. If several people use the same skill, the decay is
# # even faster. This can break skill-spamming strategies, if used right at
# # least.
# # Note that it only affects damage, hit rate (optional) and recovery formulas.
# # Traits don't decay.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # By default, skills don't decay at all. There are a variety of notetags you
# # will have to use in order to apply the effects.
# # <decay_on> This enables decay for the skill.
# # <decay_max: x> The maximum efficiency loss. For instance, if set to 50,
# # the skill effectiveness will never drop below 50%.
# # <decay_rate: x> The efficiency loss per use. Every time any battler uses
# # this skill, it loses x in power and/or accuracy.
# # <hit_rate_decay> Enables the accuracy decay.
# # <revert_decay: x, x, x...> Raises the given skill IDs power back to their
# # full potential.
# # <revert_all_decay> Same as above, but for absolutely every skill.
# #
# # You don't have to set the maximum and decay rate for every skill. There are
# # default values and you can find them in the config part of the script.
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#-------------------------------------------------------------------------------------------------
# # Works with the base Ace Battle Engine, but not tested with every add-on.
# # Feel free to report incompatiblities as they will fixed if possible.
# #
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_decay_notetags (new method)
# #
# # BattleManager
# # setup (alias)
# #
# # RPG::Skill
# # decay on (new attr method)
# # decay_max (new attr method)
# # decay_rate (new attr method)
# # decay_hit_rate (new attr method)
# # load_decay_notetags (new method)
# # get_decay_reversion (new method)
# # decay_hit_rate (new method)
# #
# # RPG::Item
# # load_decay_notetags (new method)
# # get_decay_reversion (new method)
# #
# # RPG::UsableItem::Damage
# # apply_decay (new method)
# #
# # Game_Temp
# # current_decays (new attr method)
# #
# # Game_ActionResult
# # make_damage (alias)
# #
# # Game_Battler
# # item_hit (alias)
# #
# # Scene_Battle
# # use_item (alias)
# # add_decay (new method)
# # reverse_decay (new method)
#-------------------------------------------------------------------------------------------------

$imported = {} if $imported.nil?
$imported['KRX-SkillDecay'] = true

puts 'Load: Skill Decay v1.01 by Kread-EX'

module KRX
  
  DEFAULT_DECAY_MAX = 50
  DEFAULT_DECAY_RATE = 4
  
	module REGEXP
    DECAY_ENABLE = /<decay_on>/i
    DECAY_MAX = /<decay_max:[ ]*(\d+)>/i
    DECAY_RATE = /<decay_rate:[ ]*(\d+)>/i
    DECAY_HIT = /<hit_rate_decay>/i
    REVERT_IDS = /<revert_decay:[ ]*(\d+(?:\s*,\s*\d+)*)>/i
    REVERT_ALL = /<revert_all_decay>/i
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
		alias_method(:krx_decay_dm_load_database, :load_database)
	end
	def self.load_database
		krx_decay_dm_load_database
		load_decay_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_decay_notetags
		groups = [$data_skills, $data_items]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_decay_notetags
			end
		end
		puts "Read: Skill Decay Notetags"
	end
end

#==============================================================================
# ■ BattleManager
#==============================================================================

module BattleManager
  #--------------------------------------------------------------------------
  # ● Setups
  #--------------------------------------------------------------------------
	class << self ; alias_method(:krx_decay_bm_setup, :setup) ; end
  def self.setup(troop_id, can_escape = true, can_lose = false)
    krx_decay_bm_setup(troop_id, can_escape, can_lose)
    $game_temp.current_decays = {}
  end
end

#===========================================================================
# ■ RPG::Skill
#===========================================================================

class RPG::Skill < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader     :decay_on
	attr_reader		  :decay_max
  attr_reader     :decay_rate
  attr_reader     :decay_hit_rate
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_decay_notetags
    @decay_max = KRX::DEFAULT_DECAY_MAX 
    @decay_rate = KRX::DEFAULT_DECAY_RATE 
    @decay_revert_ids = []
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::DECAY_ENABLE
        @decay_on = true
      when KRX::REGEXP::DECAY_MAX
        @decay_max = $1.to_i
      when KRX::REGEXP::DECAY_RATE
        @decay_rate = $1.to_i
      when KRX::REGEXP::DECAY_HIT
        @decay_hit_rate = true
      when KRX::REGEXP::REVERT_IDS
        $1.scan(/\d+/).each {|i| @decay_revert_ids.push(i.to_i)}
      when KRX::REGEXP::REVERT_ALL
        @decay_revert_all = true
			end
		end
	end
	#--------------------------------------------------------------------------
	# ● Returns the IDs of the skill which will be re-powered
	#--------------------------------------------------------------------------
  def get_decay_reversion
    return 1...$data_skills.size if @decay_revert_all
    return @decay_revert_ids if !@decay_revert_ids.empty?
    return nil
  end
	#--------------------------------------------------------------------------
	# ● Returns the decayed hit rate
	#--------------------------------------------------------------------------
  def decay_hit_rate(value)
    return value unless SceneManager.scene.is_a?(Scene_Battle)
    return value unless @decay_on
    return value unless @decay_hit_rate
    return value unless $game_temp.current_decays[self.id] != nil
    (value * (100.00 - $game_temp.current_decays[self.id]) / 100).round
  end
end

#===========================================================================
# ■ RPG::Item
#===========================================================================

class RPG::Item < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_decay_notetags
		@note.split(/[\r\n]+/).each do |line|
			case line
      when KRX::REGEXP::REVERT_IDS
        $1.scan(/\d+/).each {|i| @decay_revert_ids.push(i.to_i)}
      when KRX::REGEXP::REVERT_ALL
        @decay_revert_all = true
			end
		end
	end
	#--------------------------------------------------------------------------
	# ● Returns the IDs of the skill which will be re-powered
	#--------------------------------------------------------------------------
  def get_decay_reversion
    return 1...$data_skills.size if @decay_revert_all
    return @decay_revert_ids
  end
end
  
#===========================================================================
# ■ RPG::UsableItem::Damage
#===========================================================================

class RPG::UsableItem::Damage
	#--------------------------------------------------------------------------
	# ● Causes the decay
	#--------------------------------------------------------------------------
  def apply_decay(dmg, itm)
    return dmg unless itm.is_a?(RPG::Skill)
    return dmg unless itm.decay_on
    return dmg unless $game_temp.current_decays[itm.id] != nil
    (dmg * (100.00 - $game_temp.current_decays[itm.id]) / 100).round
  end
end

#===========================================================================
# ■ Game_Temp
#===========================================================================

class Game_Temp
  attr_accessor   :current_decays
end

#===========================================================================
# ■ Game_ActionResult
#===========================================================================

class Game_ActionResult
	#--------------------------------------------------------------------------
	# ● Finishes to calculate the damage
	#--------------------------------------------------------------------------
  alias_method(:krx_decay_gar_md, :make_damage)
  def make_damage(value, item)
    value = item.damage.apply_decay(value, item)
    krx_decay_gar_md(value, item)
  end
end

#===========================================================================
# ■ Game_Battler
#===========================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● Determine hit rate
  #--------------------------------------------------------------------------
  alias_method(:krx_decay_gb_ih, :item_hit)
  def item_hit(user, item)
    rate = krx_decay_gb_ih(user, item)
    return item.decay_hit_rate(rate) if item.is_a?(RPG::Skill)
    return rate
  end
end

#===========================================================================
# ■ Scene_Battle
#===========================================================================

class Scene_Battle < Scene_Base
	#--------------------------------------------------------------------------
	# ● Uses a skill or item
	#--------------------------------------------------------------------------
  alias_method(:krx_decay_sb_ui, :use_item)
	def use_item
    krx_decay_sb_ui
    item = @subject.current_action.item
    add_decay(item) if item.is_a?(RPG::Skill) && item.decay_on
    reverse_decay(item)
  end
	#--------------------------------------------------------------------------
	# ● Adds to the decay counter
	#--------------------------------------------------------------------------
  def add_decay(item)
    ary = $game_temp.current_decays
    ary[item.id] = 0 if ary[item.id].nil?
    ary[item.id] = [(ary[item.id] + item.decay_rate), item.decay_max].min
  end
	#--------------------------------------------------------------------------
	# ● Cancels skill decay
	#--------------------------------------------------------------------------
  def reverse_decay(item)
    result = item.get_decay_reversion
    return if result.nil?
    result.each {|i| $game_temp.current_decays[i] = 0}
  end
end