#==============================================================================
# ▼ Mithran Picture Bug Fix
# -- Created: 3/12/2012
#==============================================================================
# The problem is caused when a picture is erased it holds an assoicated "picture"
# object in memory as long as you stay on the same scene. Every time that picture
# object comes up, it creates a NEW blank bitmap, every frame, basically if you 
# want it to lag, create a lot of blank pictures when they get garbage collected,
# it lags. 

# Each erased picture creates a single 32x32 blank bitmap to associate 
# itself with, every frame, same with any picture shown as (none). Since the lag 
# is caused by garbage collection, which is basically uncontrollabe with Ruby.
#
# The reason why it constantly creates new blank pictures is because the base 
# scripts check for the picture name. And if it's "" (aka no picture name), 
# it keeps creating. When a picture is erased, it sets to ""
#
# This script fixes that. 
#==============================================================================

class Sprite_Picture
  def update_bitmap
    if @picture.name != @pic_name
      self.bitmap = Cache.picture(@picture.name)
    end
    @pic_name = @picture.name
  end
  
end


class Spriteset_Map
  
  def update_pictures
    $game_map.screen.pictures.each do |pic|
      @picture_sprites[pic.number] ||= Sprite_Picture.new(@viewport2, pic)
      @picture_sprites[pic.number].update
      if pic.name == ""
        $game_map.screen.pictures.remove(pic.number)
        @picture_sprites[pic.number].dispose
        @picture_sprites[pic.number] = nil
      end
    end
  end

end

class Game_Pictures
  
  def remove(index)
    @data[index] = nil
  end
  
end