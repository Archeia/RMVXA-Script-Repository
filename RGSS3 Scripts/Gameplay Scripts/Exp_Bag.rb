#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ EXP Bag
#  Author: Kread-EX
#  Version 1.01
#  Release date: 01/02/2012
#
#  For Tobyej.
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#-------------------------------------------------------------------------------------------------
#  ▼ UPDATES
#-------------------------------------------------------------------------------------------------
# # 30/03/2012. Fixed mistake in dynamic exp calculation.
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
#-------------------------------------------------------------------------------------------------
#  ▼ INTRODUCTION
#-------------------------------------------------------------------------------------------------
# # A small script made for Tobyej. It allows item to give exp to either their
# # target or their user. Actually works for skills too.
#-------------------------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#-------------------------------------------------------------------------------------------------
# # 4 possible notetags
# # <target_exp: x> Gives x Exp points to the target.
# # <target_exp%: x> Gives to the target x% of the required EXP for next level.
# # <user_exp: x> Gives x Exp points to the user.
# # <user_exp%: x> Gives to the user x% of the required EXP for next level.
#-------------------------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#-------------------------------------------------------------------------------------------------
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_expbag_notetags (new method)
# #
# # RPG::UsableItem
# # load_expbag_notetags (new method)
# # exp_user (new attr method)
# # exp_user_dyn (new attr method)
# # exp_target (new attr method)
# # exp_target_dyn (new attr method)
# #
# # Game_Actor
# # item_test (alias)
# # item_apply (alias)
# # item_user_effect (alias)
#-------------------------------------------------------------------------------------------------

$imported = {} if $imported.nil?
$imported['KRX-EXPBag'] = true

puts 'Load: EXP Bag v1.01 by Kread-EX'

module KRX
  
  module REGEXP
    EXP_GAIN_ON_HIT = /<target_exp:[ ]*(\d+)>/i
    EXP_GAIN_ON_HIT_DYN = /<target_exp%:[ ]*(\d+)>/i
    EXP_GAIN_ON_USE = /<user_exp:[ ]*(\d+)>/i
    EXP_GAIN_ON_USE_DYN = /<user_exp%:[ ]*(\d+)>/i
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
		alias_method(:krx_expbag_dm_load_database, :load_database)
	end
	def self.load_database
		krx_expbag_dm_load_database
		load_expbag_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_expbag_notetags
		groups = [$data_items, $data_skills]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_expbag_notetags
			end
		end
		puts "Read: EXP Bag Notetags"
	end
end

#==========================================================================
# ■ RPG::UsableItem
#==========================================================================

class RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader     :exp_user
  attr_reader     :exp_user_dyn
  attr_reader     :exp_target
  attr_reader     :exp_target_dyn
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_expbag_notetags
    @exp_user = @exp_user_dyn = 0
    @exp_target = @exp_target_dyn = 0
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::EXP_GAIN_ON_HIT
				@exp_target = $1.to_i
			when KRX::REGEXP::EXP_GAIN_ON_HIT_DYN
				@exp_target_dyn = $1.to_i
			when KRX::REGEXP::EXP_GAIN_ON_USE
				@exp_user = $1.to_i
			when KRX::REGEXP::EXP_GAIN_ON_USE_DYN
				@exp_user_dyn = $1.to_i
			end
		end
	end
end

#==========================================================================
# ■ Game_Actor
#==========================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● Searches if the item has any effect
  #--------------------------------------------------------------------------
  alias_method(:krx_expbag_ga_it, :item_test)
  def item_test(user, item)
    return true if item.exp_target > 0
    return true if item.exp_target_dyn > 0
    return true if item.exp_user > 0
    return true if item.exp_user_dyn > 0
    return krx_expbag_ga_it(user, item)
  end
  #--------------------------------------------------------------------------
  # ● Applies the effects of a skill or item
  #--------------------------------------------------------------------------
  alias_method(:krx_expbag_ga_ia, :item_apply)
  def item_apply(user, item)
    krx_expbag_ga_ia(user, item)
    gain_exp(item.exp_target) if item.exp_target > 0
    if item.exp_target_dyn > 0
      rate = item.exp_target_dyn / 100.00
      gain_exp((next_level_exp - current_level_exp) * rate)
    end
  end
  #--------------------------------------------------------------------------
  # ● Applies the effects of the item on the user
  #--------------------------------------------------------------------------
  alias_method(:krx_expbag_ga_iue, :item_user_effect)
  def item_user_effect(user, item)
    krx_expbag_ga_iue(user, item)
    user.gain_exp(item.exp_user) if item.exp_user > 0
    if item.exp_user_dyn > 0
      user.gain_exp(((user.next_level_exp - user.current_level_exp) *
      item.exp_user_dyn / 100.00).round)
    end
  end
end