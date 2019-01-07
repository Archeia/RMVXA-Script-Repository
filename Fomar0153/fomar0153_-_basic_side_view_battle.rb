=begin
Basic Side View Battle Script
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
No requirements
Displays battlers for the player's party.
----------------------
Instructions
----------------------
You will need to import battlers for the party to use
they should be named like this:
name_battler
e.g.
Ralph_battler
----------------------
Known bugs
----------------------
None
=end
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● New Method battler_name
  #--------------------------------------------------------------------------
  def battler_name
    return actor.name + "_battler"
  end
  #--------------------------------------------------------------------------
  # ● Rewrites use_sprite?
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end
  #--------------------------------------------------------------------------
  # ● New Method screen_x
  #--------------------------------------------------------------------------
  def screen_x
    return 450
  end
  #--------------------------------------------------------------------------
  # ● New Method screen_y
  #--------------------------------------------------------------------------
  def screen_y
    return 120 + self.index * 40
  end
  #--------------------------------------------------------------------------
  # ● New Method screen_z
  #--------------------------------------------------------------------------
  def screen_z
    return 100
  end
end

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● Rewrites create_actors
  #--------------------------------------------------------------------------
  def create_actors
    @actor_sprites = $game_party.battle_members.reverse.collect do |actor|
      Sprite_Battler.new(@viewport1, actor)
    end
  end
end