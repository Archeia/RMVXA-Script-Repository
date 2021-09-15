#encoding:UTF-8
# Game_System
#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles system-related data. Also manages vehicles and BGM, etc.
# The instance of this class is referenced by $game_system.
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :timer                    # timer
  attr_accessor :timer_working            # timer working flag
  attr_accessor :save_disabled            # save forbidden
  attr_accessor :menu_disabled            # menu forbidden
  attr_accessor :encounter_disabled       # encounter forbidden
  attr_accessor :save_count               # save count
  attr_accessor :version_id               # game version ID
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @timer = 0
    @timer_working = false
    @save_disabled = false
    @menu_disabled = false
    @encounter_disabled = false
    @save_count = 0
    @version_id = 0
  end
  #--------------------------------------------------------------------------
  # * Get Battle BGM
  #--------------------------------------------------------------------------
  def battle_bgm
    if @battle_bgm == nil
      return $data_system.battle_bgm
    else
      return @battle_bgm
    end
  end
  #--------------------------------------------------------------------------
  # * Set Battle BGM
  #     battle_bgm : new battle BGM
  #--------------------------------------------------------------------------
  def battle_bgm=(battle_bgm)
    @battle_bgm = battle_bgm
  end
  #--------------------------------------------------------------------------
  # * Get Battle End ME
  #--------------------------------------------------------------------------
  def battle_end_me
    if @battle_end_me == nil
      return $data_system.battle_end_me
    else
      return @battle_end_me
    end
  end
  #--------------------------------------------------------------------------
  # * Set Battle End ME
  #     battle_end_me : new battle end ME
  #--------------------------------------------------------------------------
  def battle_end_me=(battle_end_me)
    @battle_end_me = battle_end_me
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    if @timer_working and @timer > 0
      @timer -= 1
      if @timer == 0 and $game_temp.in_battle     # If the timer 0 in battle
        $game_temp.next_scene = "map"             # interrupt the battle
      end
    end
  end
end
