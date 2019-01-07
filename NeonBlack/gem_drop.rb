#==============================================================================
# ** Archeia Gem Parade
#------------------------------------------------------------------------------
#  How to use: GEM_DROP: item_id drop_rate skill_id/actor_id
#  Example: GEM_DROP: 28 0 Actor 5
#  Skill_id 0 means it drops from any skill
#  0 drop rate = 100% Guaranteed. It follows VX Drop Rate EX 100 = 1/100
#==============================================================================

class Scene_Battle < Scene_Base
  WAIT_TIME = 50
  
  #--------------------------------------------------------------------------
  # * Alias Listings
  #--------------------------------------------------------------------------  
  alias tds_archeia_gem_parade_scene_battle_execute_action     execute_action  
  #--------------------------------------------------------------------------
  # * Execute Battle Actions
  #--------------------------------------------------------------------------
  def execute_action
    # Run Original Method
    tds_archeia_gem_parade_scene_battle_execute_action
    # Return if Subject is an enemy
    return if @subject.enemy?
    # If Subject Gem Drops is not nil or empty
    if !@subject.gem_drops.nil? and !@subject.gem_drops.empty?
      # Go Through Gem Drops
      @subject.gem_drops.each_value {|array|
        array.each do |item|
          # Show Drop Message
          @log_window.add_pop_array(item.icon_index, "#{item.name} obtained") 
          abs_wait(WAIT_TIME)
          # Gain Item
          $game_party.gain_item(item, 1)
        end
      }
      # Subject Clear Gem Drops
      # Changed into a hash ~Kread
      @subject.gem_drops = {}
    end
  end
end


#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :gem_drops                                  # Gem Drops Array 
  #--------------------------------------------------------------------------
  # * Alias Listings
  #--------------------------------------------------------------------------  
  alias tds_archeia_gem_parade_game_battler_item_apply            item_apply 
  #--------------------------------------------------------------------------
  # * Apply Item Effect
  #--------------------------------------------------------------------------
  def item_apply(user, item)     
    # Run Original Method
    tds_archeia_gem_parade_game_battler_item_apply(user, item)
    # If User is an actor and Target is not
    if user.actor? and self.enemy? and self.dead?
      # Clear User Gem Drops Array (Hash and Array now ~Kread)
      user.gem_drops = {} if user.gem_drops.nil?
      # Fixes multi hits attacks ~Kread
      return if user.gem_drops[self.index] != nil
      self.enemy.note.scan(/GEM_DROP: (\d+) (\d+) (\w+) (\d+)/) {|id, drop, obj, obj_id|
        next if obj == "Skill" and obj_id.to_i > 0 and item.id != obj_id.to_i 
        next if obj == "Actor" and user.id != obj_id.to_i
        next if rand(drop.to_i).to_i > 0        
        # Add Item to Gem Drops
        user.gem_drops[self.index] = [] if user.gem_drops[self.index].nil?
        user.gem_drops[self.index] << $data_items[id.to_i]
      }      
    end
  end  
end

# Puts this in your Gem Parade script to fix the counter attack issue.

#==============================================================================
# ** Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Counterattack execution
  #--------------------------------------------------------------------------
  alias_method(:krx_nessy_gem_sb_ic, :invoke_counter_attack)
  def invoke_counter_attack(target, item)
    krx_nessy_gem_sb_ic(target, item)
    if @subject.enemy?
      if !target.gem_drops.nil? && !target.gem_drops.empty?
        #target.gem_drops.each {|gem| 
        target.gem_drops.each_value {|array|
          array.each do |gem| 
            @log_window.add_pop_array(gem.icon_index, "#{gem.name} obtained") 
            abs_wait(WAIT_TIME)
            $game_party.gain_item(gem, 1)
          end
        }
        target.gem_drops = {}
      end
    end
  end
end