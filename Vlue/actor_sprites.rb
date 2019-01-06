#Actor Sprites v1.0c
#----------#
#Features: Shows Actor Sprites in battle. Nothing fancy.
#
#Usage:    Plug and play
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
#x,y value for each party member
ACTOR_FORMATION = {
  0 => [350,200],
  1 => [370,230],
  2 => [390,260],
  3 => [410,290]
}
 
class Game_Actor
  def use_sprite?
    true
  end
  def screen_x
    ACTOR_FORMATION[self.index] ? ACTOR_FORMATION[self.index][0] : 0
  end
  def screen_y
    ACTOR_FORMATION[self.index] ? ACTOR_FORMATION[self.index][1] : 0
  end
  def screen_z
    200
  end
end
 
class Spriteset_Battle
  def create_actors
    @actor_sprites = []
    $game_party.battle_members.each do |actor|
      @actor_sprites.push(Sprite_Battler.new(@viewport1, actor))
    end
  end
  def update_actors
    @actor_sprites.each {|sprite| sprite.update }
  end
end
 
class Sprite_Battler
  alias sprite_update_bitmap update_bitmap
  def update_bitmap
    return sprite_update_bitmap if @battler.is_a?(Game_Enemy)
    if @char_bitmap.nil?
      return unless @battler.character_name
      new_bitmap = Cache.character(@battler.character_name)
      if @battler.character_name.include?("$")
        @char_bitmap = Bitmap.new(new_bitmap.width,new_bitmap.height)
        @char_bitmap.blt(0,0,new_bitmap,Rect.new(0,0,new_bitmap.width,new_bitmap.height))
        self.bitmap = Bitmap.new(new_bitmap.width/3,new_bitmap.height/4)
        self.bitmap.blt(0,0,@char_bitmap,Rect.new(0,new_bitmap.height/4,new_bitmap.width/3,new_bitmap.height/4))
      else
        @char_bitmap = Bitmap.new(new_bitmap.width/4,new_bitmap.height/2)
        xx = @battler.character_index % 4 * new_bitmap.width/4
        yy = @battler.character_index / 4 * new_bitmap.height/2
        @char_bitmap.blt(0,0,new_bitmap,Rect.new(xx,yy,new_bitmap.width/4,new_bitmap.height/2))
        self.bitmap = Bitmap.new(new_bitmap.width/12,new_bitmap.height/8)
        self.bitmap.blt(0,0,@char_bitmap,Rect.new(0,new_bitmap.height/8,new_bitmap.width/12,new_bitmap.height/8))
      end    
      init_visibility
    end
    @timer = 0 unless @timer
    if Graphics.frame_count % 20 == 0
      @timer += 1
      @timer = 0 if @timer == 3
    end
    self.bitmap.clear
    self.bitmap.blt(0,0,@char_bitmap,Rect.new(@char_bitmap.width/3 * @timer,@char_bitmap.height/4,@char_bitmap.width/3,@char_bitmap.height/4))
  end
end
 
class Scene_Battle
    def show_attack_animation(targets)
    if @subject.actor?
      show_normal_animation(targets, @subject.atk_animation_id1, false)
      show_normal_animation(targets, @subject.atk_animation_id2, true)
    else
      Sound.play_enemy_attack
      show_normal_animation(targets, 1, false)
      abs_wait_short
    end
  end
end