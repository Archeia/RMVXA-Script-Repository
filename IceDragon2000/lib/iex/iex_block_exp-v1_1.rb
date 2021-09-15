#==============================================================================#
# ** IEX(Icy Engine Xelion) - Block EXP
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon
# ** Script-Status : Addon
# ** Date Created  : 09/11/2010
# ** Date Modified : 07/17/2011
# ** Version       : 1.1
#------------------------------------------------------------------------------#
$imported ||= {}
$imported["IEX_BlockExp"] = true
$imported["IEX_BLOCK_EXP"] = true # // For Compat
#==============================================================================#
# // You can add and remove actors for exp blocking via the 
# // $game_system.block_exp_actors array
# // $game_system.block_exp_actors.push(actor_id)   # // To add a new actor
# // $game_system.block_exp_actors.delete(actor_id) # // To remove an actor
# // If the text is too large to fit in the script box
# // Do this
# gs = $game_system
# bea= gs.block_exp_actors
# bea.push(actor_id)   # // To add a new actor
# bea.delete(actor_id) # // To remove an actor
#------------------------------------------------------------------------------#
#==============================================================================#
# ** IEX::BLOCK_EXP_GAIN
#==============================================================================#
module IEX
  module BLOCK_EXP_GAIN
    DEF_BLOCK_ACTORS = []
  end
end

#==============================================================================#
# ** Game_System
#==============================================================================#
class Game_System

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :block_exp_actors
  
  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------# 
  alias :iex_block_exp_gs_initialize :initialize unless $@
  def initialize( *args, &block )
    @block_exp_actors = IEX::BLOCK_EXP_GAIN::DEF_BLOCK_ACTORS
    iex_block_exp_gs_initialize( *args, &block )
  end
  
end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------#
  # * alias-method :change_exp
  #--------------------------------------------------------------------------# 
  alias :iex_block_exp_change_exp :change_exp unless $@
  def change_exp( *args, &block )
    return if $game_system.block_exp_actors.include?(@actor_id)
    iex_block_exp_change_exp( *args, &block )
  end
  
end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#