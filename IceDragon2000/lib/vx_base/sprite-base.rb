#encoding:UTF-8
# Sprite_Base
#==============================================================================
# ** Sprite_Base
#------------------------------------------------------------------------------
#  A sprite class with animation display processing added.
#==============================================================================

class Sprite_Base < Sprite
  #--------------------------------------------------------------------------
  # * Class Variable
  #--------------------------------------------------------------------------
  @@animations = []
  @@_reference_count = {}
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport : viewport
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    @use_sprite = true          # Sprite use flag
    @animation_duration = 0     # Remaining animation time
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_animation
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    if @animation != nil
      @animation_duration -= 1
      if @animation_duration % 4 == 0
        update_animation
      end
    end
    @@animations.clear
  end
  #--------------------------------------------------------------------------
  # * Determine if animation is being displayed
  #--------------------------------------------------------------------------
  def animation?
    return @animation != nil
  end
  #--------------------------------------------------------------------------
  # * Start Animation
  #--------------------------------------------------------------------------
  def start_animation(animation, mirror = false)
    dispose_animation
    @animation = animation
    return if @animation == nil
    @animation_mirror = mirror
    @animation_duration = @animation.frame_max * 4 + 1
    load_animation_bitmap
    @animation_sprites = []
    if @animation.position != 3 or not @@animations.include?(animation)
      if @use_sprite
        for i in 0..15
          sprite = ::Sprite.new(viewport)
          sprite.visible = false
          @animation_sprites.push(sprite)
        end
        unless @@animations.include?(animation)
          @@animations.push(animation)
        end
      end
    end
    if @animation.position == 3
      if viewport == nil
        @animation_ox = 544 / 2
        @animation_oy = 416 / 2
      else
        @animation_ox = viewport.rect.width / 2
        @animation_oy = viewport.rect.height / 2
      end
    else
      @animation_ox = x - ox + width / 2
      @animation_oy = y - oy + height / 2
      if @animation.position == 0
        @animation_oy -= height / 2
      elsif @animation.position == 2
        @animation_oy += height / 2
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Read (Load) Animation Graphics
  #--------------------------------------------------------------------------
  def load_animation_bitmap
    animation1_name = @animation.animation1_name
    animation1_hue = @animation.animation1_hue
    animation2_name = @animation.animation2_name
    animation2_hue = @animation.animation2_hue
    @animation_bitmap1 = Cache.animation(animation1_name, animation1_hue)
    @animation_bitmap2 = Cache.animation(animation2_name, animation2_hue)
    if @@_reference_count.include?(@animation_bitmap1)
      @@_reference_count[@animation_bitmap1] += 1
    else
      @@_reference_count[@animation_bitmap1] = 1
    end
    if @@_reference_count.include?(@animation_bitmap2)
      @@_reference_count[@animation_bitmap2] += 1
    else
      @@_reference_count[@animation_bitmap2] = 1
    end
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # * Dispose of Animation
  #--------------------------------------------------------------------------
  def dispose_animation
    if @animation_bitmap1 != nil
      @@_reference_count[@animation_bitmap1] -= 1
      if @@_reference_count[@animation_bitmap1] == 0
        @animation_bitmap1.dispose
      end
    end
    if @animation_bitmap2 != nil
      @@_reference_count[@animation_bitmap2] -= 1
      if @@_reference_count[@animation_bitmap2] == 0
        @animation_bitmap2.dispose
      end
    end
    if @animation_sprites != nil
      for sprite in @animation_sprites
        sprite.dispose
      end
      @animation_sprites = nil
      @animation = nil
    end
    @animation_bitmap1 = nil
    @animation_bitmap2 = nil
  end
  #--------------------------------------------------------------------------
  # * Update Animation
  #--------------------------------------------------------------------------
  def update_animation
    if @animation_duration > 0
      frame_index = @animation.frame_max - (@animation_duration + 3) / 4
      animation_set_sprites(@animation.frames[frame_index])
      for timing in @animation.timings
        if timing.frame == frame_index
          animation_process_timing(timing)
        end
      end
    else
      dispose_animation
    end
  end
  #--------------------------------------------------------------------------
  # * Set Animation Sprite
  #     frame : Frame data (RPG::Animation::Frame)
  #--------------------------------------------------------------------------
  def animation_set_sprites(frame)
    cell_data = frame.cell_data
    for i in 0..15
      sprite = @animation_sprites[i]
      next if sprite == nil
      pattern = cell_data[i, 0]
      if pattern == nil or pattern == -1
        sprite.visible = false
        next
      end
      if pattern < 100
        sprite.bitmap = @animation_bitmap1
      else
        sprite.bitmap = @animation_bitmap2
      end
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192)
      if @animation_mirror
        sprite.x = @animation_ox - cell_data[i, 1]
        sprite.y = @animation_oy + cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x = @animation_ox + cell_data[i, 1]
        sprite.y = @animation_oy + cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      sprite.z = self.z + 300 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end
  #--------------------------------------------------------------------------
  # * SE and Flash Timing Processing
  #     timing : timing data (RPG::Animation::Timing)
  #--------------------------------------------------------------------------
  def animation_process_timing(timing)
    timing.se.play
    case timing.flash_scope
    when 1
      self.flash(timing.flash_color, timing.flash_duration * 4)
    when 2
      if viewport != nil
        viewport.flash(timing.flash_color, timing.flash_duration * 4)
      end
    when 3
      self.flash(nil, timing.flash_duration * 4)
    end
  end
end
