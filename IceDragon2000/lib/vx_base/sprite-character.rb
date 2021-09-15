#encoding:UTF-8
# Sprite_Character
#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  This sprite is used to display characters. It observes a instance of the
# Game_Character class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  BALLOON_WAIT = 12                  # Final balloon frame wait time
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :character
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport  : viewport
  #     character : character (Game_Character)
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    @balloon_duration = 0
    update
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    dispose_balloon
    super
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    update_bitmap
    self.visible = (not @character.transparent)
    update_src_rect
    self.x = @character.screen_x
    self.y = @character.screen_y
    self.z = @character.screen_z
    self.opacity = @character.opacity
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    update_balloon
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      start_animation(animation)
      @character.animation_id = 0
    end
    if @character.balloon_id != 0
      @balloon_id = @character.balloon_id
      start_balloon
      @character.balloon_id = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Get tile set image that includes the designated tile
  #     tile_id : Tile ID
  #--------------------------------------------------------------------------
  def tileset_bitmap(tile_id)
    set_number = tile_id / 256
    return Cache.system("TileB") if set_number == 0
    return Cache.system("TileC") if set_number == 1
    return Cache.system("TileD") if set_number == 2
    return Cache.system("TileE") if set_number == 3
    return nil
  end
  #--------------------------------------------------------------------------
  # * Update Transfer Origin Bitmap
  #--------------------------------------------------------------------------
  def update_bitmap
    if @tile_id != @character.tile_id or
       @character_name != @character.character_name or
       @character_index != @character.character_index
      @tile_id = @character.tile_id
      @character_name = @character.character_name
      @character_index = @character.character_index
      if @tile_id > 0
        sx = (@tile_id / 128 % 2 * 8 + @tile_id % 8) * 32;
        sy = @tile_id % 256 / 8 % 16 * 32;
        self.bitmap = tileset_bitmap(@tile_id)
        self.src_rect.set(sx, sy, 32, 32)
        self.ox = 16
        self.oy = 32
      else
        self.bitmap = Cache.character(@character_name)
        sign = @character_name[/^[\!\$]./]
        if sign != nil and sign.include?('$')
          @cw = bitmap.width / 3
          @ch = bitmap.height / 4
        else
          @cw = bitmap.width / 12
          @ch = bitmap.height / 8
        end
        self.ox = @cw / 2
        self.oy = @ch
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update Transfer Origin Rectangle
  #--------------------------------------------------------------------------
  def update_src_rect
    if @tile_id == 0
      index = @character.character_index
      pattern = @character.pattern < 3 ? @character.pattern : 1
      sx = (index % 4 * 3 + pattern) * @cw
      sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
  end
  #--------------------------------------------------------------------------
  # * Start Balloon Icon Display
  #--------------------------------------------------------------------------
  def start_balloon
    dispose_balloon
    @balloon_duration = 8 * 8 + BALLOON_WAIT
    @balloon_sprite = ::Sprite.new(viewport)
    @balloon_sprite.bitmap = Cache.system("Balloon")
    @balloon_sprite.ox = 16
    @balloon_sprite.oy = 32
    update_balloon
  end
  #--------------------------------------------------------------------------
  # * Update Balloon Icon
  #--------------------------------------------------------------------------
  def update_balloon
    if @balloon_duration > 0
      @balloon_duration -= 1
      if @balloon_duration == 0
        dispose_balloon
      else
        @balloon_sprite.x = x
        @balloon_sprite.y = y - height
        @balloon_sprite.z = z + 200
        if @balloon_duration < BALLOON_WAIT
          sx = 7 * 32
        else
          sx = (7 - (@balloon_duration - BALLOON_WAIT) / 8) * 32
        end
        sy = (@balloon_id - 1) * 32
        @balloon_sprite.src_rect.set(sx, sy, 32, 32)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Dispose of Balloon Icon
  #--------------------------------------------------------------------------
  def dispose_balloon
    if @balloon_sprite != nil
      @balloon_sprite.dispose
      @balloon_sprite = nil
    end
  end
end
