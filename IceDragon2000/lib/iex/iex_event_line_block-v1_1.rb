#==============================================================================#
# ** IEX(Icy Engine Xelion) - Event Line Block
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Org.Concept   : Ccoa (His script inspired me)
# ** Script-Status : Addon (Event)
# ** Script Type   : Passabilty Changes
# ** Date Created  : 11/29/2010 (DD/MM/YYYY)
# ** Date Modified : 07/24/2011 (DD/MM/YYYY)
# ** Script Tag    : IEX - Event Line Block
# ** Difficulty    : Normal
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This lets you cut back on the tremendous amount of events used to block an area.
# You can now cut back and save, by just using one event that covers the
# entire line.
# This script is based a Japanese one I found some ages ago. 
# D: I dont even remember where the hell it is now.
# Anyway if you do find it, lemme know.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE 
#------------------------------------------------------------------------------#
# Tags - Comments - Events
#------------------------------------------------------------------------------#
#  direction
#  2 - Down
#  4 - Left
#  6 - Right
#  8 - Up
#
#  <LINE_BLOCK: direction, lenght>
#   This will have the event block the line from a direction.
#   Lenght is the total tiles the block should cover.
#   The arrows show the moveable direction.
#   So direction
#   2 Can move to the Bottom, but can't pass from the Top
#             
#          ---/\---
#
#   4 Can move to the Left, but can't pass from the right
#             |
#             |
#             |     
#             >
#             |
#             |
#             |
#   6 Can move to the Right, but can't pass from the left
#             |
#             |
#             |     
#             <
#             |
#             |
#             |
#   8 Can move to the Top, but can't pass from the Bottom
#
#        ---\/---
#
#  <ADD_BLOCK: end, lenght>
#   This allows you to add another segement to one of the sides
#   end = 1, -1
#  KEY
#  - |        Normal Sgement
#  /\ \/ < >  Direction of movement
#  =          Added segment
#
#  <line block: 2, 4>
#  <add block: -1, 1> 
#  
#  =----/\----
#
#  <line block: 8, 4>
#  <add block: -1, 1> 
#  
#  =----\/----
#
#  <line block: 4, 2>
#  <add block: 1, 3> 
#  
#  |
#  |
#  >
#  |
#  |
#  =
#  =
#  =
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#------------------------------------------------------------------------------#
#
# Should have no problems
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#------------------------------------------------------------------------------#
# 
# Below 
#  Materials
#  Anything that makes changes to events, and passability
#
# Above 
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES 
#------------------------------------------------------------------------------# 
# Classes
#   Game_Character
#     alias      :collide_with_characters?
#     new-method :line_blocker?
#     new-method :line_block
#     new-method :addition_block
#     new-method :addition_passable
#     new-method :line_passable
#     new-method :direction_xy
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  11/29/2010 - V1.0  Finished Script
#  01/02/2011 - V1.0  Released Script
#  01/08/2011 - V1.0a Small Changes
#  07/24/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment. 
#
#------------------------------------------------------------------------------#
$imported ||= {}
$imported["IEX_EventLineBlock"] = true

#==============================================================================#
# ** Game_Character
#==============================================================================#
class Game_Character

  #--------------------------------------------------------------------------#
  # * new-method :line_blocker?
  #--------------------------------------------------------------------------# 
  def line_blocker?() ; return false ; end
  
  #--------------------------------------------------------------------------#
  # * new-method :line_block
  #--------------------------------------------------------------------------# 
  def line_block() ; return [0, 0] ; end
  
  #--------------------------------------------------------------------------#
  # * new-method :addition_block
  #--------------------------------------------------------------------------#   
  def addition_block() ; return [0, 0] ; end
  
  #--------------------------------------------------------------------------#
  # * alias-method :collide_with_characters?
  #--------------------------------------------------------------------------# 
  alias :iex_lnblck_collide_with_characters? :collide_with_characters? unless $@
  def collide_with_characters?( x, y )
    for event in $game_map.events.values
      next if event == nil
      next unless event.line_blocker?()
      a  = event.line_block()
      ab = event.addition_block()
      ap = event.line_passable( a[0], a[1] )
      ap |= event.addition_passable( a[0], a[1], ab[0], ab[1] )
      if ap.include?( [x, y] )
        return true if a[0].to_i == direction_xy( x, y )
      end
    end
    iex_lnblck_collide_with_characters?( x, y )
  end
 
  #--------------------------------------------------------------------------#
  # * new-method :addition_passable
  #--------------------------------------------------------------------------# 
  def addition_passable( d, w, apend, amt )
    case d.to_i
    when 2 ; p = [w+amt, 0]
    when 4 ; p = [0, w+amt]
    when 6 ; p = [0, w+amt]
    when 8 ; p = [w+amt, 0]
    else   ; p = [0, 0]
    end
    xy, a = [@x, @y].clone, []
    a << xy
    case apend.to_i
    when 0 ; return [[nil, nil]]
    when 1  
      xy = [xy[0] + p[0], xy[1] + p[1]]
      a << xy
    when -1
      xy = [xy[0] - p[0], xy[1] - p[1]]
      a << xy
    end
    return a
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :line_passable
  #--------------------------------------------------------------------------# 
  def line_passable( d, w )
    case d.to_i
    when 2 ; p = [1, 0]
    when 4 ; p = [0, 1]
    when 6 ; p = [0, 1]
    when 8 ; p = [1, 0]
    else   ; p = [0, 0]
    end
    xy, a = [@x, @y], []
    a << xy
    for i in 0...w.to_i
      xy = [xy[0] + p[0], xy[1] + p[1]]
      a << xy
    end
    xy = [@x, @y]
    for i in 0...w.to_i
      xy = [xy[0] - p[0], xy[1] - p[1]]
      a << xy
    end
    return a
  end

  #--------------------------------------------------------------------------#
  # * new-method :direction_xy
  #--------------------------------------------------------------------------#
  def direction_xy( x, y )
    return 0 if @x - x > 1 or @x - x < -1 or @y - y > 1 or @y - y < -1
    return 2 if @x - x == 0  && @y - y == -1
    return 4 if @x - x == 1  && @y - y == 0
    return 6 if @x - x == -1 && @y - y == 0
    return 8 if @x - x == 0  && @y - y == 1
  end
  
end

#==============================================================================#
# ** Game_Event
#==============================================================================#
class Game_Event < Game_Character

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------# 
  alias :iex_lnblck_initialize :initialize unless $@
  def initialize( *args, &block )
    @line_blocker = false
    #             Direction, amount < >
    @line_block = [0, 0]
    #             nd +1 -1, amount > <
    @addition_block = [0, 0]
    iex_lnblck_initialize( *args, &block )
  end
  
  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------# 
  alias :iex_lnblck_setup :setup unless $@
  def setup( *args, &block )
    iex_lnblck_setup( *args, &block )
    lnblck_cache()
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :line_blocker?
  #--------------------------------------------------------------------------# 
  def line_blocker?() ; return @line_blocker ; end
  
  #--------------------------------------------------------------------------#
  # * new-method :line_block
  #--------------------------------------------------------------------------# 
  def line_block() ; return @line_block ; end
  
  #--------------------------------------------------------------------------#
  # * new-method :addition_block
  #--------------------------------------------------------------------------# 
  def addition_block() ; return @addition_block ; end
  
  #--------------------------------------------------------------------------#
  # * new-method :lnblck_cache
  #--------------------------------------------------------------------------# 
  def lnblck_cache()
    @addition_block = [0, 0]
    @line_block = [0, 0]
    @line_blocker = false
    return if @list == nil
    for i in 0..@list.size
      next if @list[i] == nil
      if @list[i].code == 108
        @list[i].parameters.to_s.split(/[\r\n]+/).each { |line| 
        case line
        when /<(?:LINE_BLOCK|line block|LNBLCK):?[ ]*(\d+)[ ]*,[ ]*(\d+)>/i
          @line_blocker = true
          @line_block = [$1.to_i, $2.to_i]
        when /<(?:ADD_BLOCK|add block):?[ ]*([\+\-]?\d+)[ ]*,[ ]*(\d+)>/i
          @line_blocker = true
          @addition_block = [$1.to_i, $2.to_i]
        end
       }  
      end
    end  
  end
  
end

#==============================================================================#
# ** END OF FILE
#==============================================================================#