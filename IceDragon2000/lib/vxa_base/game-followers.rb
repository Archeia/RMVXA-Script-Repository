#encoding:UTF-8
# Game_Followers
#==============================================================================
# ** Game_Followers
#------------------------------------------------------------------------------
#  This is a wrapper for a follower array. This class is used internally for
# the Game_Player class. 
#==============================================================================

class Game_Followers
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :visible                  # Player Followers ON?
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     leader:  Lead character
  #--------------------------------------------------------------------------
  def initialize(leader)
    @visible = $data_system.opt_followers
    @gathering = false                    # Gathering processing underway flag
    @data = []
    @data.push(Game_Follower.new(1, leader))
    (2...$game_party.max_battle_members).each do |index|
      @data.push(Game_Follower.new(index, @data[-1]))
    end
  end
  #--------------------------------------------------------------------------
  # * Get Followers
  #--------------------------------------------------------------------------
  def [](index)
    @data[index]
  end
  #--------------------------------------------------------------------------
  # * Iterator
  #--------------------------------------------------------------------------
  def each
    @data.each {|follower| yield follower } if block_given?
  end
  #--------------------------------------------------------------------------
  # * Iterator (Reverse)
  #--------------------------------------------------------------------------
  def reverse_each
    @data.reverse.each {|follower| yield follower } if block_given?
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    each {|follower| follower.refresh }
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    if gathering?
      move unless moving? || moving?
      @gathering = false if gather?
    end
    each {|follower| follower.update }
  end
  #--------------------------------------------------------------------------
  # * Movement
  #--------------------------------------------------------------------------
  def move
    reverse_each {|follower| follower.chase_preceding_character }
  end
  #--------------------------------------------------------------------------
  # * Synchronize
  #--------------------------------------------------------------------------
  def synchronize(x, y, d)
    each do |follower|
      follower.moveto(x, y)
      follower.set_direction(d)
    end
  end
  #--------------------------------------------------------------------------
  # * Gather
  #--------------------------------------------------------------------------
  def gather
    @gathering = true
  end
  #--------------------------------------------------------------------------
  # * Determine if Gathering
  #--------------------------------------------------------------------------
  def gathering?
    @gathering
  end
  #--------------------------------------------------------------------------
  # * Get Array of Displayed Followers
  #    "folloers" is typo, but retained because of the compatibility.
  #--------------------------------------------------------------------------
  def visible_folloers
    @data.select {|follower| follower.visible? }
  end
  #--------------------------------------------------------------------------
  # * Determine if Moving
  #--------------------------------------------------------------------------
  def moving?
    visible_folloers.any? {|follower| follower.moving? }
  end
  #--------------------------------------------------------------------------
  # * Determine if Gathered
  #--------------------------------------------------------------------------
  def gather?
    visible_folloers.all? {|follower| follower.gather? }
  end
  #--------------------------------------------------------------------------
  # * Detect Collision
  #--------------------------------------------------------------------------
  def collide?(x, y)
    visible_folloers.any? {|follower| follower.pos?(x, y) }
  end
end
