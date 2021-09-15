#encoding:UTF-8
# Game_Follower
#==============================================================================
# ** Game_Follower
#------------------------------------------------------------------------------
#  This class handles followers. A follower is an allied character, other than
# the front character, displayed in the party. It is referenced within the
# Game_Followers class.
#==============================================================================

class Game_Follower < Game_Character
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(member_index, preceding_character)
    super()
    @member_index = member_index
    @preceding_character = preceding_character
    @transparent = $data_system.opt_transparent
    @through = true
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    @character_name = visible? ? actor.character_name : ""
    @character_index = visible? ? actor.character_index : 0
  end
  #--------------------------------------------------------------------------
  # * Get Corresponding Actor
  #--------------------------------------------------------------------------
  def actor
    $game_party.battle_members[@member_index]
  end
  #--------------------------------------------------------------------------
  # * Determine Visibility
  #--------------------------------------------------------------------------
  def visible?
    actor && $game_player.followers.visible
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    @move_speed     = $game_player.real_move_speed
    @transparent    = $game_player.transparent
    @walk_anime     = $game_player.walk_anime
    @step_anime     = $game_player.step_anime
    @direction_fix  = $game_player.direction_fix
    @opacity        = $game_player.opacity
    @blend_type     = $game_player.blend_type
    super
  end
  #--------------------------------------------------------------------------
  # * Pursue Preceding Character
  #--------------------------------------------------------------------------
  def chase_preceding_character
    unless moving?
      sx = distance_x_from(@preceding_character.x)
      sy = distance_y_from(@preceding_character.y)
      if sx != 0 && sy != 0
        move_diagonal(sx > 0 ? 4 : 6, sy > 0 ? 8 : 2)
      elsif sx != 0
        move_straight(sx > 0 ? 4 : 6)
      elsif sy != 0
        move_straight(sy > 0 ? 8 : 2)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if at Same Position as Preceding Character
  #--------------------------------------------------------------------------
  def gather?
    !moving? && pos?(@preceding_character.x, @preceding_character.y)
  end
end
