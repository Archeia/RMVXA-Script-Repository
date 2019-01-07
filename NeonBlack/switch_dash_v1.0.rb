## v1.0a - Created by Neon Black at request of Aaron
## Free for commercial and non-commercial use with thanks or credit
 
class Game_Player < Game_Character
  ## Switch to enable or disable dash.
  ## Switch must be turned on in order to dash.
  @@dash_switch_num = 12
 
  alias_method "dash_11212015", "dash?"
  def dash?
    return dash_11212015 && $game_switches[@@dash_switch_num]
  end
end