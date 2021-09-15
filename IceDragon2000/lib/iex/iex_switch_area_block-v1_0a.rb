#==============================================================================#
# ** IEX(Icy Engine Xelion) - Switch Area Block
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Addon (Area, Maps)
# ** Script Type   : Passage Edit
# ** Date Created  : ??/??/2010 (DD/MM/YYYY)
# ** Date Modified : 01/08/2011 (DD/MM/YYYY)
# ** Script Tag    : IEX - Switch Area Block
# ** Difficulty    : Easy
# ** Version       : 1.0a
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# This makes use of the areas, by making them affect passabilty.
# In other words, you can block whole areas, without tiles or events.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
# V1.0 - Tags - Areas - Place in area's name
#------------------------------------------------------------------------------#
# <SWITCH_BLOCK> 
# <SWITCH_BLOCK: x>
# All are case insensitive.
# The first tag will cause the area to always be impassable.
# The second tag will cause the are to only be impassable when switch x is
# set to false.
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
#
# Above 
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES 
#------------------------------------------------------------------------------# 
# Classes
#   RPG::Area
#     alias      :initialize 
#     new-method :iex_switch_block
#     new-method :iex_valid_area?
#   Game_Map
#     alias      :setup
#     alias      :passable?
#     new-method :setup_blocker_cache
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# (DD/MM/YYYY)
#  ??/??/2010 - V1.0  Finished Script
#  01/01/2011 - V1.0  Finished Docing
#  01/08/2011 - V1.0a Small Changes
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment. 
#
#------------------------------------------------------------------------------#
$imported = {} if $imported == nil
$imported["IEX_SwitchAreaBlock"] = true

#==============================================================================
# ** RPG::Area
#------------------------------------------------------------------------------
#==============================================================================
class RPG::Area
  
  attr_reader :blocker_switch
  attr_reader :blocker_area
  
  alias iex_switch_blocker_initialize initialize unless $@
  def initialize(*args)
    iex_switch_blocker_initialize(*args)
    @blocker_switch = nil
    @blocker_area = false
  end
  
  def iex_switch_block
    @blocker_switch = nil
    @blocker_area = false
    case @name
    when /<(?:SWITCH_BLOCK|switch block):?[ ]*(\d+)?>/i
      @blocker_area = true
      if $1.to_i != nil
        @blocker_switch = $1.to_i
      end  
    end 
    return @blocker_area
  end
  
  def iex_valid_area?(x_x, y_y)
    stack_ans = []
    bool_x = (x_x >= @rect.x and x_x < @rect.x + @rect.width)
      stack_ans.push(bool_x)
    bool_y = (y_y >= @rect.y and y_y < @rect.y + @rect.height)
      stack_ans.push(bool_y)
    return stack_ans
  end
  
end

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#==============================================================================
class Game_Map
  
  alias iex_switch_blocker_setup setup unless $@
  def setup(*args)
    iex_switch_blocker_setup(*args)
    setup_blocker_cache
  end
  
  def setup_blocker_cache
    @blocker_area_table = Table.new(width, height, 2)
    valid_areas = []
    for i in 0..$data_areas.size
      are = $data_areas[i]
      next if are == nil
      next if are.map_id != @map_id
      next unless are.iex_switch_block
      valid_areas.push(are)
    end  
    
    for x in 0..width
      for y in 0..height
          @blocker_area_table[x, y, 0] = 0
          @blocker_area_table[x, y, 1] = 0
        for ar in valid_areas
          next if ar == nil
          validty = ar.iex_valid_area?(x, y)
          next unless validty.all?
          @blocker_area_table[x, y, 0] = ar.id
          if ar.blocker_switch != nil
            @blocker_area_table[x, y, 1] = ar.blocker_switch
          end  
        end  
      end
    end
    
  end  
  
  #--------------------------------------------------------------------------
  # * Determine if Passable
  #     x    : x coordinate
  #     y    : y coordinate
  #     flag : The impassable bit to be looked up
  #            (normally 0x01, only changed for vehicles)
  #--------------------------------------------------------------------------
  alias iex_switch_blocker_passable? passable? unless $@
  def passable?(x, y, flag = 0x01)
    if @blocker_area_table != nil
      if @blocker_area_table[x, y, 0] != 0 
        if @blocker_area_table[x, y, 1] != 0 
          if @blocker_area_table[x, y, 1].to_i != nil
            if $game_switches[@blocker_area_table[x, y, 1].to_i] == false
              return false 
            end  
          end  
        else
          return false  
        end  
      end
    end  
      
    iex_switch_blocker_passable?(x, y, flag)
  end
  
end
