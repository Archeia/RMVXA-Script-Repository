#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
# Intelligent Attacks
# Author: Kread-EX
# Version 1.0
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

#-------------------------------------------------------------------------------------------------
#  TERMS OF USAGE
#-------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work for commercial purposes if you like it.
# #  Credit is appreciated.
#-------------------------------------------------------------------------------------------------

#===========================================================
# INTRODUCTION
#
# This little script allows you to setup "intelligent" skills and items. Simply
# put, those attacks can pinpoint the enemies status weakness and apply the
# the target is the most vulnerable to. Of course, this only applies if the
# ailment is not currently inflicted.
#
# In case of resistance equality, a random status is inflicted.
#
# You can control which ailments can be inflicted by which skill/item. There are
# two steps to follow:
#
# 1. VX USERS: use the <intelligent> tag in your skill or item notebox.
#    XP USERS: in the config module, fill the following constants:
#        Intelligent_Skill = [12, 44, 32]
#        Intelligent_Item = [7, 9]
#            Replace the numbers by the real IDs in the database.
#
# 2. In the database, for both makers, you can setup the state changes. For
#     the skills/items tagged as intelligent, this represents the statuses
#     that can POTENTIALLY be inflicted. They aren't inflicted all at once
#     anymore.
#===========================================================

# This line detects the used engine.
 
Exe = 'Game'
 
if (FileTest.exist?(Exe + '.rvproj') || FileTest.exist?(Exe + '.rgss2a'))
  Engine = :VX
else
  Engine = :XP
end

#==============================================================================
# ** Config Module (only for XP)
#==============================================================================

if Engine == :XP
  
  module KreadCFG
    
    Intelligent_Skill = [12]
    Intelligent_Item = [7]
    
  end
  
end


# VX Implementation

if Engine == :VX

#==============================================================================
# ** RPG::UsableItem
#==============================================================================

module RPG
  class UsableItem < BaseItem
    #--------------------------------------------------------------------------
    # * Check for the Intelligent tag
    #--------------------------------------------------------------------------
    def intelligent_tag?
      self.note.split(/[\r\n]+/).each do |line|
        if line =~ /<(?:INTELLIGENT|intelligent)>/i
          return true
        end
      end
      return false
    end
    #--------------------------------------------------------------------------
    # * Alter states set according to target
    #--------------------------------------------------------------------------
    def plus_state_set(*args)
      unless args.size > 0
        return @plus_state_set
      end
      target = args[0]
      weakest = sid = 0
      set = @plus_state_set.randomize
      set.each do |id|
        if target.state_probability(id) >= weakest && !target.state?(id)
          weakest = target.state_probability(id)
          sid = id
        end
      end
      return (sid == 0 ? [set.random] : [sid])
    end
    #--------------------------------------------------------------------------
  end
  #--------------------------------------------------------------------------
end

#==============================================================================
# ** Game_Battler
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # * Apply State Changes
  #--------------------------------------------------------------------------
  alias_method(:krx_intatk_gb_asc, :apply_state_changes) unless $@
  def apply_state_changes(obj)
    if obj.is_a?(RPG::UsableItem) && obj.intelligent_tag?
      apply_state_changes_int(obj)
      return
    end
    krx_intatk_gb_asc(obj)
  end
  #--------------------------------------------------------------------------
  # * Apply State Changes for Intelligent Attacks
  #--------------------------------------------------------------------------
  def apply_state_changes_int(obj)
    plus = obj.plus_state_set(self)
    minus = obj.minus_state_set
    for i in plus 
      next if state_resist?(i)
      next if dead?
      next if i == 1 and @immortal
      if state?(i)
        @remained_states.push(i)
        next
      end
      if rand(100) < state_probability(i)
        add_state(i)
        @added_states.push(i)
      end
    end
    for i in minus
      next unless state?(i)
      remove_state(i)
      @removed_states.push(i)
    end
    for i in @added_states & @removed_states
      @added_states.delete(i)
      @removed_states.delete(i)
    end
  end
  #--------------------------------------------------------------------------
end

# XP Implementation

else

#==============================================================================
# ** RPG::Skill and RPG::Item
#==============================================================================

module RPG

['Skill', 'Item'].each {|class_name|

CLDEF = <<__END__
class #{class_name}
  
  def intelligent_tag?
    return KreadCFG::Intelligent_#{class_name}.include?(id)
  end
  
  def reset_plus_state_set(target)
    @orig = @plus_state_set.clone if @orig == nil
    weakest = sid = 0
    set = @orig.randomize
    set.each do |id|
      if [0,100,80,60,40,20,0][target.state_ranks[id]] >= weakest &&
      !target.state?(id)
        weakest = [0,100,80,60,40,20,0][target.state_ranks[id]]
        sid = id
      end
    end
    @plus_state_set = sid == 0 ? [set.random] : [sid]
  end
  
end
__END__

eval (CLDEF)

}

end
  
#==============================================================================
# ** Game_Battler
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # * Apply Skill Effects
  #--------------------------------------------------------------------------
  alias_method(:krx_intatk_gb_se, :skill_effect) unless $@
  def skill_effect(user, skill)
    skill.reset_plus_state_set(self) if skill.intelligent_tag?
    krx_intatk_gb_se(user, skill)
  end
  #--------------------------------------------------------------------------
  # * Apply Item Effects
  #--------------------------------------------------------------------------
  alias_method(:krx_intatk_gb_ie, :item_effect) unless $@
  def item_effect(item)
    item.reset_plus_state_set(self) if item.intelligent_tag?
    krx_intatk_gb_ie(item)
  end
  #--------------------------------------------------------------------------
end

end

#==============================================================================
# ** Array
#==============================================================================

class Array
  #--------------------------------------------------------------------------
  # * Returns a random element
  #--------------------------------------------------------------------------
  def random
    return self[rand(self.size)]
  end
  #--------------------------------------------------------------------------
  # * Returns an unsorted array
  #--------------------------------------------------------------------------
  def randomize
    unsorted_array = []
    while unsorted_array.size < self.size
      ind = rand(self.size)
      unless unsorted_array.include?(self[ind])
        unsorted_array.push(self[ind])
      end
    end
    return unsorted_array
  end
  #--------------------------------------------------------------------------
end