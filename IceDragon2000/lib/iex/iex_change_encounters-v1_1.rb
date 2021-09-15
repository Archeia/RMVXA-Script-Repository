#==============================================================================#
# ** IEX(Icy Engine Xelion) - Change Encounter
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon
# ** Script-Status : Addon (Map Encounters)
# ** Script Type   : Map Encounter Modifier
# ** Date Created  : 11/02/2010
# ** Date Modified : 07/17/2011
# ** Requested by  : phropheus
# ** Version       : 1.1
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
#  >,< Screw the introduction! Anyway this script is meant to allow the 
#  user to add /remove game troops to any map.
#
#  **Note It does not overwrite the original encounter list, instead it simply
#    adds to the existing one.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** HOW TO USE
#------------------------------------------------------------------------------#
#  Event script calls
#------------------------------------------------------------------------------#
#  iex_add_troop(map_id, troop_id)
#   Adds a selected to troop (troop_id) to the map (map_id)
# 
#  iex_remove_troop(map_id, troop_id)
#   Removes a selected to troop (troop_id) to the map (map_id)
#
#  iex_clear_troop(map_id)
#   Clears / Removes a selected to map's (map_id) extra ecounters.
#   Restoring it to normal
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
# 
# (DD/MM/YYYY)
#  11/02/2010 - V1.0  Finished Script
#  07/17/2011 - V1.1  Edited for the IEX Recall
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Non at the moment. 
#
#------------------------------------------------------------------------------#
$imported ||= {}
$imported["IEX_Change_Encounter"] = true
#==============================================================================#
# ** Game Player
#==============================================================================#
class Game_Player < Game_Character
   
  #--------------------------------------------------------------------------#
  # * Create Group ID for Troop Encountered
  #--------------------------------------------------------------------------#
  def make_encounter_troop_id()
    encounter_list = $game_map.encounter_list.clone
    for area in $data_areas.values
      encounter_list += area.encounter_list if in_area?(area)
    end
    encounter_list += $game_system.iex_get_map_extra_troops($game_map.map_id)
    if encounter_list.empty?
      make_encounter_count
      return 0
    end
    return encounter_list[rand(encounter_list.size)]
  end
  
end

#==============================================================================#
# ** Game System
#==============================================================================#
class Game_System

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#  
  alias iex_change_encounter_initialize initialize unless $@
  def initialize( *args, &block )
    iex_change_encounter_initialize( *args, &block )
    999.times { |i| iex_create_troop_cache( i ) }
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_create_troop_cache
  #--------------------------------------------------------------------------#  
  def iex_create_troop_cache( map_id )
    @iex_more_troops ||= {}
    @iex_more_troops[map_id] ||= []
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_get_map_extra_troops
  #--------------------------------------------------------------------------#  
  def iex_get_map_extra_troops( map_id )
    iex_create_troop_cache( map_id )
    return @iex_more_troops[map_id]
  end  
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_add_troop
  #--------------------------------------------------------------------------#  
  def iex_add_troop( map_id, troop_id )
    iex_create_troop_cache( map_id )
    @iex_more_troops[map_id] |= [troop_id]
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_remove_troop
  #--------------------------------------------------------------------------#   
  def iex_remove_troop( map_id, troop_id )
    iex_create_troop_cache( map_id ) 
    @iex_more_troops[map_id].delete( troop_id )
    @iex_more_troops[map_id].compact!()
  end 
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_clear_troop
  #--------------------------------------------------------------------------#  
  def iex_clear_troop( map_id )
    iex_create_troop_cache( map_id )
    @iex_more_troops[map_id].clear() 
  end  
  
end

#==============================================================================#
# ** Game Interpreter
#==============================================================================#
class Game_Interpreter

  #--------------------------------------------------------------------------#
  # * new-method :iex_add_troop
  #--------------------------------------------------------------------------#   
  def iex_add_troop( map_id, troop_id )
    $game_system.iex_add_troop(map_id, troop_id)
  end
  
  #--------------------------------------------------------------------------#
  # * new-method :iex_remove_troop
  #--------------------------------------------------------------------------#   
  def iex_remove_troop( map_id, troop_id )
    $game_system.iex_remove_troop(map_id, troop_id)
  end
   
  #--------------------------------------------------------------------------#
  # * new-method :iex_clear_troop
  #--------------------------------------------------------------------------#   
  def iex_clear_troop( map_id )
    $game_system.iex_clear_troop(map_id)
  end
  
end

#==============================================================================#
# ** END OF FILE
#==============================================================================#