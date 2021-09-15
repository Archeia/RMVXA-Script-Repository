#encoding:UTF-8
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# Classes
#   Game_BattleAction
#     new-method :battle_vocab
#     new-method :battle_commands
#   Window_ActorCommand
#     new-method :draw_command
#     overwrite  :initialize
#     overwrite  :setup
#     overwrite  :refresh
#     overwrite  :draw_item
#   Scene_Battle
#     overwrite  :execute_action_skill
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
($imported ||= {})["IEO-IMoveUMove"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
($ieo_script = {})[[24, "IMoveUMove"]] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# IEO::REGEX::RIVIERA_MAPNAVIGATION
#==============================================================================#
module IEO
  module REGEXP
    module IMOVE_UMOVE
      module EVENT
        #        Modes        : Button
        MULTIMOVE = /<MULTIMOVE:[ ]*(.*)>/i
      end
    end
  end
end

#==============================================================================#
# Game_Map
#==============================================================================#
class Game_Map

  def trigger_globalmove
    for ev in @events.values.compact
      ev.set_moveallow(true)
    end
  end

end

#==============================================================================#
# Game_Character
#==============================================================================#
class Game_Character

  attr_accessor :allow_movement

  alias ieo024_initialize initialize unless $@
  def initialize
    ieo024_initialize
    @allow_movement   = true
    @bypass_movelimit = false
    @multimove_cap = 1
    @multimove     = 1
  end

  alias ieo024_move_type_custom move_type_custom unless $@
  def move_type_custom
    @multimove -= 1 if @multimove > 0
    return unless @allow_movement unless @move_route_forcing or @bypass_movelimit
    ieo024_move_type_custom
    if @multimove <= 0
      @allow_movement = false unless @bypass_movelimit
    end
    unless @move_route.nil?
      command = @move_route.list[@move_route_index]   # Get movement command
      if command.code == 0                            # End of list
        @move_route_index = 0 if @move_route.repeat   # [Repeat Action]
      end
    end
  end

  def set_moveallow(bool)
    @allow_movement = true
    @multimove = @multimove_cap
  end

end

#==============================================================================#
# Game_Event
#==============================================================================#
class Game_Event < Game_Character

  alias ieo024_ge_initialize initialize unless $@
  def initialize(map_id, event)
    ieo024_ge_initialize(map_id, event)
  end

  alias ieo024_setup setup unless $@
  def setup(new_page)
    ieo024_setup(new_page)
  end

  def ieo024_eventcache
    @multimove_cap = 1
    @bypass_movelimit = false
    $game_map.unregister_current_navi(self, :move)
    $game_map.unregister_current_navi(self, :look)
    return if @list == nil
    for i in 0..@list.size
      next if @list[i] == nil
      if @list[i].code == 108
        @list[i].parameters.to_s.split(/[\r\n]+/).each { |line|
        case line
        when IEO::REGEXP::IMOVE_UMOVE::MULTIMOVE
          val = $1.to_i
          case val
          when -1
            @bypass_movelimit = true
          else
            @multimove_cap = val
          end
        end
        }
      end
    end
  end

end

#==============================================================================#
# Game_Player
#==============================================================================#
class Game_Player < Game_Character

  #--------------------------------------------------------------------------
  # * Processing of Movement via input from the Directional Buttons
  #--------------------------------------------------------------------------
  alias ieo024_move_by_input move_by_input unless $@
  def move_by_input
    ieo024_move_by_input
    #return unless movable?
    return if $game_map.interpreter.running?
    case Input.dir4
    when 2, 4, 6, 8
      $game_map.trigger_globalmove
    end
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
