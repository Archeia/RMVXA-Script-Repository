#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#  ▼ Cannibalism
#  Author: Kread-EX
#  Version 1.01
#  Release date: 25/12/2011
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#------------------------------------------------------------------------------
#  ▼ UPDATES
#------------------------------------------------------------------------------
# # 06/02/2013. Fixed a bug with multiple devours of a single enemy.
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
# # This script allows you to create skills to absorb a fraction of a target
# # parameters if it kills it. The gain is permanent. Pretty creepy huh.
#------------------------------------------------------------------------------
#  ▼ INSTRUCTIONS
#------------------------------------------------------------------------------
# # First, you need to create a *damaging* skill and put <cannibal> in its
# # notebox. Then, on enemies that can be eaten, use the following notetags:
# # <cannibal> <--- always start with this!
# # hp: number
# # mp: number
# # atk: number
# # def: number
# # mat: number
# # mdf: number
# # agi: number
# # luk: number
# # </cannibal> <--- always end with this!
# # The numbers represent the percentage of the enemy stats which will be
# # absorbed. Technically, you can go above 100 but this might be silly.
# # You don't need every tag of course, just put the ones you want - the others
# # will automatically be set to 0.
# # Other tag:
# # <static> <--- for a static stat gain instead of a dynamic one
# # THE LAZY WAY
# # The lazy way allows you to set the same ratio for every stat. Not very useful
# # but hey, it's here.
# # <cannibal: number>
#------------------------------------------------------------------------------
#  ▼ COMPATIBILITY
#------------------------------------------------------------------------------
# # Put it below Skill Fusion and Glimmer.
# #
# # List of aliases and overwrites:
# #
# # DataManager
# # load_database (alias)
# # load_cannibal_notetags (new method)
# #
# # RPG::Skill
# # load_cannibal_notetags (new method)
# # devour_skill (new attr method)
# #
# # Game_Actor
# # cannibal_bonus (new attr method)
# # devoured (new attr method)
# # setup (alias)
# # param_plus (alias)
# #
# # Game_Enemy
# # initialize (alias)
# # load_cannibal_notetags (new method)
# # can_devour? (new method)
# # devour_limit (new method)
# # devour_param_bonus (new method)
# #
# # Scene_Battle
# # apply_item_effects (alias)
# # devour (new method)
#------------------------------------------------------------------------------

($imported ||= {})['KRX-Cannibalism'] = true

puts 'Load: Cannibalism v1.01 by Kread-EX'

module KRX

	module REGEXP
		CANNIBAL =  /<cannibal:[ ]*(\d+)>/i
    CANNIBAL_START = /<cannibal>/i
    CANNIBAL_END = /<\/cannibal>/i
    HP_RATIO = /hp:[ ]*(\d+)/i
    MP_RATIO = /mp:[ ]*(\d+)/i
    ATK_RATIO = /atk:[ ]*(\d+)/i
    DEF_RATIO = /def:[ ]*(\d+)/i
    MAT_RATIO = /mat:[ ]*(\d+)/i
    MDF_RATIO = /mdf:[ ]*(\d+)/i
    AGI_RATIO = /agi:[ ]*(\d+)/i
    LUK_RATIO = /luk:[ ]*(\d+)/i
    STATIC = /<static>/i
    DEVOUR_LIMIT = /limit:[ ]*(\d+)/i
	end
  
  module VOCAB
    DEVOURED = "absorbed"
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
		alias_method(:krx_cannibal_dm_load_database, :load_database)
	end
	def self.load_database
		krx_cannibal_dm_load_database
		load_cannibal_notetags
	end  
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def self.load_cannibal_notetags
		groups = [$data_skills]
		for group in groups
			for obj in group
				next if obj.nil?
				obj.load_cannibal_notetags
			end
		end
		puts "Read: Cannibalism Notetags for Skills"
	end
end

#===========================================================================
# ■ RPG::Skill
#===========================================================================

class RPG::Skill < RPG::UsableItem
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
	attr_reader		  :devour_skill
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_cannibal_notetags
		@note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::CANNIBAL_START
        @devour_skill = true
			end
		end
	end
end

#===========================================================================
# ■ Game_Actor
#===========================================================================

class Game_Actor < Game_Battler
	#--------------------------------------------------------------------------
	# ● Public instance variables
	#--------------------------------------------------------------------------
  attr_reader   :cannibal_bonus
  attr_reader   :devoured
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
  alias_method(:krx_cannibal_ga_setup, :setup)
  def setup(actor_id)
    @cannibal_bonus = Array.new(8, 0)
    @devoured = []
    krx_cannibal_ga_setup(actor_id)
  end
  #--------------------------------------------------------------------------
  # ● Returns the parameter bonuses
  #--------------------------------------------------------------------------
  alias_method(:krx_cannibal_ga_pplus, :param_plus)
  def param_plus(param_id)
    krx_cannibal_ga_pplus(param_id) + @cannibal_bonus[param_id]
  end
end

#===========================================================================
# ■ Game_Enemy
#===========================================================================

class Game_Enemy < Game_Battler
	#--------------------------------------------------------------------------
	# ● Object Initialize
	#--------------------------------------------------------------------------
	alias_method(:krx_cannibal_ge_init, :initialize)
	def initialize(index, enemy_id)
		krx_cannibal_ge_init(index, enemy_id)
		load_cannibal_notetags
		puts "Read: Cannibalism Notetags for #{enemy.name}"
	end 
	#--------------------------------------------------------------------------
	# ● Loads the note tags
	#--------------------------------------------------------------------------
	def load_cannibal_notetags
    @devour_ratio_p = Array.new(8, 0)
		enemy.note.split(/[\r\n]+/).each do |line|
			case line
			when KRX::REGEXP::CANNIBAL
        @can_devour = true
				$1.scan(/\d+/).each {|i| @devour_ratio = i.to_i}
      when KRX::REGEXP::CANNIBAL_START
        @can_devour = true
        @st_devour = true
      when KRX::REGEXP::HP_RATIO
        $1.scan(/\d+/).each {|i| @devour_ratio_p[0] = i.to_i} if @st_devour
      when KRX::REGEXP::MP_RATIO
        $1.scan(/\d+/).each {|i| @devour_ratio_p[1] = i.to_i} if @st_devour
      when KRX::REGEXP::ATK_RATIO
        $1.scan(/\d+/).each {|i| @devour_ratio_p[2] = i.to_i} if @st_devour
      when KRX::REGEXP::DEF_RATIO
        $1.scan(/\d+/).each {|i| @devour_ratio_p[3] = i.to_i} if @st_devour
      when KRX::REGEXP::MAT_RATIO
        $1.scan(/\d+/).each {|i| @devour_ratio_p[4] = i.to_i} if @st_devour
      when KRX::REGEXP::MDF_RATIO
        $1.scan(/\d+/).each {|i| @devour_ratio_p[5] = i.to_i} if @st_devour
      when KRX::REGEXP::AGI_RATIO
        $1.scan(/\d+/).each {|i| @devour_ratio_p[6] = i.to_i} if @st_devour
      when KRX::REGEXP::LUK_RATIO
        $1.scan(/\d+/).each {|i| @devour_ratio_p[7] = i.to_i} if @st_devour
      when KRX::REGEXP::STATIC
        @static_gain= true if @st_devour
      when KRX::REGEXP::DEVOUR_LIMIT
        $1.scan(/\d+/).each {|i| @devour_limit = i.to_i} if @st_devour
      when KRX::REGEXP::CANNIBAL_END
        @st_devour = false
			end
		end
	end
	#--------------------------------------------------------------------------
	# ● Determine if the enemy can be eaten
	#--------------------------------------------------------------------------
  def can_devour?
    return @can_devour
  end
	#--------------------------------------------------------------------------
	# ● Return the max number of times an enemy can be devoured
	#--------------------------------------------------------------------------
  def devour_limit
    return @devour_limit != nil ? @devour_limit : -1
  end
	#--------------------------------------------------------------------------
	# ● Returns the parameter gain upon eating
	#--------------------------------------------------------------------------
  def devour_param_bonus(param_id)
    if !@static_gain
      if @devour_ratio != nil
        return ((param_base(param_id) * @devour_ratio) / 100.00).round
      end
      return ((param_base(param_id) * @devour_ratio_p[param_id]) / 100.00).round
    else
      if @devour_ratio != nil
        return @devour_ratio
      end
      return @devour_ratio_p[param_id]
    end
  end
end

#==========================================================================
#  ■  Scene_Battle
#==========================================================================

class Scene_Battle < Scene_Base
	#--------------------------------------------------------------------------
	# ● Applies the action effects
	#--------------------------------------------------------------------------
	alias_method(:krx_cannibal_sb_aie, :apply_item_effects)
	def apply_item_effects(target, item)
		krx_cannibal_sb_aie(target, item)
    devour(target, item)
  end
	#--------------------------------------------------------------------------
	# ● Devours the enemy
	#--------------------------------------------------------------------------
  def devour(target, item)
		if item.is_a?(RPG::Skill) && item.devour_skill
      if target.is_a?(Game_Enemy) && target.can_devour? && target.dead?
        if @subject.devoured[target.enemy.id].nil? ||
        @subject.devoured[target.enemy.id] < target.devour_limit
          (0..7).each do |i|
            n = target.devour_param_bonus(i)
            @subject.cannibal_bonus[i] += n
            if n > 0
              text = "#{@subject.name} #{KRX::VOCAB::DEVOURED} #{n} #{$data_system.terms.params[i]}."
              @subject.devoured[target.enemy.id] = 0 if @subject.devoured[target.enemy.id].nil?
              @subject.devoured[target.enemy.id] += 1
              @log_window.replace_text(text)
              2.times {@log_window.wait}
            end
          end
        end
      end
		end
	end
end