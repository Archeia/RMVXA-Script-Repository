=begin
Sprite Based Side View Battle Script
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
No requirements
Displays battlers for the player's party.
This script uses the player sprite facing left.
----------------------
Instructions
----------------------
Plug and play
----------------------
Known bugs
----------------------
None
=end
class Game_Actor < Game_Battler
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

class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # * Update Transfer Origin Bitmap
  #--------------------------------------------------------------------------
  alias sbb_update_bitmap update_bitmap
  def update_bitmap
    if @battler.is_a?(Game_Actor)
      char_bitmap = Cache.character(@battler.character_name)
      sign = @battler.character_name[/^[\!\$]./]
      if sign && sign.include?('$')
        cw = char_bitmap.width / 3
        ch = char_bitmap.height / 4
      else
        cw = char_bitmap.width / 12
        ch = char_bitmap.height / 8
      end
      new_bitmap = Bitmap.new(cw, ch)
      sx = (@battler.character_index % 4 * 3 + 1) * cw
      sy = (@battler.character_index / 4 * 4 + 1) * ch
      new_bitmap.blt(0, 0, char_bitmap, Rect.new(sx, sy, cw, ch))
      if bitmap != new_bitmap
        self.bitmap = new_bitmap
        init_visibility
      end
    else
      sbb_update_bitmap
    end
  end
end