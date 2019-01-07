##-----------------------------------------------------------------------------
#  Large Sprite ☆ Display Fix v1.2b
#  Created by Neon Black at request of seita
#  v1.2 - 8.23.13 - Fixed a few slight positioning issues
#  v1.1 - 8.18.13 - Fixed an odd lag issue
#  v1.0 - 8.17.13 - Main script completed
#  Only for non-commercial use.  See full terms of use and contact info at:
#  http://cphouseset.wordpress.com/liscense-and-terms-of-use/
##-----------------------------------------------------------------------------
 
##------
## By default, this script only affects the player.  To allow it to affect
## an event page as well, add a comment with the tag <large sprite> to the page
## of the event you would like to have affected by this.
 
class Sprite_Character < Sprite_Base
  ##------
  ## The ID of the terrain used to display the large character above ☆ tiles.
  ## If the player is below this tile (y position), the sprite will appear
  ## above all tiles and events from that y position up.  If the player is on
  ## the same tile or above (y position) the event will appear BELOW ☆ tiles
  ## from that position up.
  ##------
  UpperTerrain = 7
 
  ## Alias the update method to add in the new graphic check.
  alias :cp_073013_update_pos :update_position
  def update_position(*args)
    cp_073013_update_pos(*args)
    check_encompassed_area if sprite_is_onscreen?
  end
 
  ## Alias the dispose to dispose the upper sprite.
  alias :cp_073013_dispose :dispose
  def dispose(*args)
    @upper_area_sprite.dispose if @upper_area_sprite
    cp_073013_dispose(*args)
  end
 
  ## Alias the graphic changed method to allow the sprite to revent to what it
  ## was during the last frame.  This allows the check to work again.
  alias :cp_073013_graphic_changed? :graphic_changed?
  def graphic_changed?(*args)
    cp_073013_graphic_changed?(*args) || @set_upper_area_sprite
  end
 
  ## Check if the sprite is onscreen.  Reduces redundant drawing.
  def sprite_is_onscreen?
    return false if @character.is_a?(Game_Vehicle) || @character.is_a?(Game_Follower)
    return false unless @character.is_a?(Game_Player) || @character.large_sprite
    return false if @character.screen_z >= 200
    top_left, bot_right = get_edge_corner_dis
    return false if top_left[0] > Graphics.width
    return false if top_left[1] > Graphics.height
    return false if bot_right[0] < 0
    return false if bot_right[1] < 0
    return true
  end
 
  ## Get the top left and bottom right positions.
  def get_edge_corner_dis
    top_left = [self.x - self.ox, self.y - self.oy]
    bot_right = [top_left[0] + self.width, top_left[1] + self.height]
    return [top_left, bot_right]
  end
 
  ## Long method that checks each position and draws the upper sprite.
  def check_encompassed_area
    @set_upper_area_sprite = false
    top_left, bot_right = get_edge_corner_dis
    last_x, last_y, copy_region = nil, nil, 0
    map_xd, map_yd = $game_map.display_x * 32, $game_map.display_y * 32
    ##total_height = (self.height + @character.jump_height).round
    total_height = (self.oy).round
    self.width.times do |x|
      xp = map_xd.to_i + top_left[0] + x
      unless xp / 32 == last_x
        last_x = xp / 32
        last_y, copy_region = nil, 0
        total_height.times do |y|
          yp = map_yd.to_i + bot_right[1] + @character.jump_height - y
          next if yp.to_i / 32 == last_y
          last_y = yp.to_i / 32
          if last_y == (@character.screen_y + map_yd).to_i / 32
#~           if last_y == (@character.screen_y + @character.jump_height +
#~              map_yd).to_i / 32
            break if $game_map.terrain_tag(last_x, last_y) == UpperTerrain
            next
          end
          next if $game_map.terrain_tag(last_x, last_y) != UpperTerrain
          copy_region = [self.height, total_height - y + 1].min
          set_upper_sprite
          break
        end
      end
      next if copy_region == 0
      rect = Rect.new(src_rect.x + x, src_rect.y, 1, copy_region)
      @upper_area_sprite.bitmap.blt(x, 0, self.bitmap, rect)
      self.bitmap.clear_rect(rect)
    end
    if !@set_upper_area_sprite && @upper_area_sprite
      @upper_area_sprite.visible = false
    end
  end
 
  ## Creates the upper sprite that's a copy of the current sprite.
  def set_upper_sprite
    return if @set_upper_area_sprite
    @upper_area_sprite ||= Sprite.new
    @upper_area_sprite.bitmap = Bitmap.new(self.width, self.height)
    props = ["x", "y", "ox", "oy", "zoom_x", "zoom_y", "angle", "mirror",
             "bush_depth", "opacity", "blend_type", "color", "tone", "visible",
             "viewport"]
    props.each do |meth|
      @upper_area_sprite.method("#{meth}=").call(self.method(meth).call)
    end
#~     @upper_area_sprite.x = @upper_area_sprite.y = 100
    @upper_area_sprite.z = 200
    @upper_area_sprite.viewport = @viewport1
    @set_upper_area_sprite = true
    old_bitmap, old_src_rect = self.bitmap, self.src_rect.clone
    self.bitmap = Bitmap.new(old_bitmap.width, old_bitmap.height)
    self.bitmap.blt(0, 0, old_bitmap, old_bitmap.rect)
    self.src_rect = old_src_rect
  end
end
 
class Game_Event < Game_Character
  attr_reader :large_sprite
 
  alias :cp_081713_setup_page_settings :setup_page_settings
  def setup_page_settings(*args)
    cp_081713_setup_page_settings(*args)
    get_large_sprite_conditions
  end
 
  def get_large_sprite_conditions
    @large_sprite = false
    return if @list.nil? || @list.empty?
    @list.each do |line|
      next unless line.code == 108 || line.code == 408
      case line.parameters[0]
      when /<large sprite>/i
        @large_sprite = true
      end
    end
  end
end