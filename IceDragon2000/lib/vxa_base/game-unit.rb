#encoding:UTF-8
# Game_Unit
#==============================================================================
# ** Game_Unit
#------------------------------------------------------------------------------
#  This class handles units. It's used as a superclass of the Game_Party and
# and Game_Troop classes.
#==============================================================================

class Game_Unit
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :in_battle                # in battle flag
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @in_battle = false
  end
  #--------------------------------------------------------------------------
  # * Get Members
  #--------------------------------------------------------------------------
  def members
    return []
  end
  #--------------------------------------------------------------------------
  # * Get Array of Living Members
  #--------------------------------------------------------------------------
  def alive_members
    members.select {|member| member.alive? }
  end
  #--------------------------------------------------------------------------
  # * Get Array of Incapacitated Members
  #--------------------------------------------------------------------------
  def dead_members
    members.select {|member| member.dead? }
  end
  #--------------------------------------------------------------------------
  # * Get Array of Movable Members
  #--------------------------------------------------------------------------
  def movable_members
    members.select {|member| member.movable? }
  end
  #--------------------------------------------------------------------------
  # * Clear all Members' Battle Actions
  #--------------------------------------------------------------------------
  def clear_actions
    members.each {|member| member.clear_actions }
  end
  #--------------------------------------------------------------------------
  # * Calculate Average Value of Agility
  #--------------------------------------------------------------------------
  def agi
    return 1 if members.size == 0
    members.inject(0) {|r, member| r += member.agi } / members.size
  end
  #--------------------------------------------------------------------------
  # * Calculate Total Target Rate
  #--------------------------------------------------------------------------
  def tgr_sum
    alive_members.inject(0) {|r, member| r + member.tgr }
  end
  #--------------------------------------------------------------------------
  # * Random Selection of Target
  #--------------------------------------------------------------------------
  def random_target
    tgr_rand = rand * tgr_sum
    alive_members.each do |member|
      tgr_rand -= member.tgr
      return member if tgr_rand < 0
    end
    alive_members[0]
  end
  #--------------------------------------------------------------------------
  # * Randomly Determine Target (K.O.)
  #--------------------------------------------------------------------------
  def random_dead_target
    dead_members.empty? ? nil : dead_members[rand(dead_members.size)]
  end
  #--------------------------------------------------------------------------
  # * Smooth Selection of Target
  #--------------------------------------------------------------------------
  def smooth_target(index)
    member = members[index]
    (member && member.alive?) ? member : alive_members[0]
  end
  #--------------------------------------------------------------------------
  # * Smooth Selection of Target (K.O.)
  #--------------------------------------------------------------------------
  def smooth_dead_target(index)
    member = members[index]
    (member && member.dead?) ? member : dead_members[0]
  end
  #--------------------------------------------------------------------------
  # * Clear Action Results
  #--------------------------------------------------------------------------
  def clear_results
    members.select {|member| member.result.clear }
  end
  #--------------------------------------------------------------------------
  # * Processing at Start of Battle
  #--------------------------------------------------------------------------
  def on_battle_start
    members.each {|member| member.on_battle_start }
    @in_battle = true
  end
  #--------------------------------------------------------------------------
  # * Processing at End of Battle
  #--------------------------------------------------------------------------
  def on_battle_end
    @in_battle = false
    members.each {|member| member.on_battle_end }
  end
  #--------------------------------------------------------------------------
  # * Create Battle Action
  #--------------------------------------------------------------------------
  def make_actions
    members.each {|member| member.make_actions }
  end
  #--------------------------------------------------------------------------
  # * Determine Everyone is Dead
  #--------------------------------------------------------------------------
  def all_dead?
    alive_members.empty?
  end
  #--------------------------------------------------------------------------
  # * Get Substitute Battler
  #--------------------------------------------------------------------------
  def substitute_battler
    members.find {|member| member.substitute? }
  end
end
