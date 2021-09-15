#encoding:UTF-8
# Game_System
#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles system data. It saves the disable state of saving and 
# menus. Instances of this class are referenced by $game_system.
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :save_disabled            # save forbidden
  attr_accessor :menu_disabled            # menu forbidden
  attr_accessor :encounter_disabled       # encounter forbidden
  attr_accessor :formation_disabled       # formation change forbidden
  attr_accessor :battle_count             # battle count
  attr_reader   :save_count               # save count
  attr_reader   :version_id               # game version ID
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @save_disabled = false
    @menu_disabled = false
    @encounter_disabled = false
    @formation_disabled = false
    @battle_count = 0
    @save_count = 0
    @version_id = 0
    @window_tone = nil
    @battle_bgm = nil
    @battle_end_me = nil
    @saved_bgm = nil
  end
  #--------------------------------------------------------------------------
  # * Determine if Japanese Mode
  #--------------------------------------------------------------------------
  def japanese?
    $data_system.japanese
  end
  #--------------------------------------------------------------------------
  # * Get Window Color
  #--------------------------------------------------------------------------
  def window_tone
    @window_tone || $data_system.window_tone
  end
  #--------------------------------------------------------------------------
  # * Set Window Color
  #--------------------------------------------------------------------------
  def window_tone=(window_tone)
    @window_tone = window_tone
  end
  #--------------------------------------------------------------------------
  # * Get Battle BGM
  #--------------------------------------------------------------------------
  def battle_bgm
    @battle_bgm || $data_system.battle_bgm
  end
  #--------------------------------------------------------------------------
  # * Set Battle BGM
  #--------------------------------------------------------------------------
  def battle_bgm=(battle_bgm)
    @battle_bgm = battle_bgm
  end
  #--------------------------------------------------------------------------
  # * Get Battle End ME
  #--------------------------------------------------------------------------
  def battle_end_me
    @battle_end_me || $data_system.battle_end_me
  end
  #--------------------------------------------------------------------------
  # * Set Battle End ME
  #--------------------------------------------------------------------------
  def battle_end_me=(battle_end_me)
    @battle_end_me = battle_end_me
  end
  #--------------------------------------------------------------------------
  # * Pre-Save Processing
  #--------------------------------------------------------------------------
  def on_before_save
    @save_count += 1
    @version_id = $data_system.version_id
    @frames_on_save = Graphics.frame_count
    @bgm_on_save = RPG::BGM.last
    @bgs_on_save = RPG::BGS.last
  end
  #--------------------------------------------------------------------------
  # * Post-Load Processing
  #--------------------------------------------------------------------------
  def on_after_load
    Graphics.frame_count = @frames_on_save
    @bgm_on_save.play
    @bgs_on_save.play
  end
  #--------------------------------------------------------------------------
  # * Get Play Time in Seconds
  #--------------------------------------------------------------------------
  def playtime
    Graphics.frame_count / Graphics.frame_rate
  end
  #--------------------------------------------------------------------------
  # * Get Play Time in Character String
  #--------------------------------------------------------------------------
  def playtime_s
    hour = playtime / 60 / 60
    min = playtime / 60 % 60
    sec = playtime % 60
    sprintf("%02d:%02d:%02d", hour, min, sec)
  end
  #--------------------------------------------------------------------------
  # * Save BGM
  #--------------------------------------------------------------------------
  def save_bgm
    @saved_bgm = RPG::BGM.last
  end
  #--------------------------------------------------------------------------
  # * Resume BGM
  #--------------------------------------------------------------------------
  def replay_bgm
    @saved_bgm.replay if @saved_bgm
  end
end
