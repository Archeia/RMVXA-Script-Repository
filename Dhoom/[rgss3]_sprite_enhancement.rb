#==============================================================================
#
# • Dhoom Sprite Enhancement v.1.4
#   drd-workshop.blogspot.com
# -- Last Updated: 02.04.2015
# -- Requires: None
#
#==============================================================================
# This is for scripter only. Add a bunch of method for animating sprites.
#==============================================================================

class Sprite
  
  alias dhoom_battlehud_spr_initialize initialize
  def initialize(*args)
    dhoom_battlehud_spr_initialize(*args)
    @blink = false
    @glow = false
    @zoom = false
    @shake = false
  end

#------------------------------------------------------------------------------
# Change the opacity to make it look like it is blinking
#------------------------------------------------------------------------------
  def blink(duration, force = false)
    return if @blink && !force
    @blink = true
    @blink_duration = duration
    @blink_current_duration = duration
    @blink_phase = 0
    @blink_opacity = self.opacity
  end

#------------------------------------------------------------------------------
# Make the sprite glow. Use a cloned sprite for the glowing effect.
#------------------------------------------------------------------------------
  def glow(duration, zoom, force = false)
    return if @glow && !force
    @glow = true
    @glow_duration = duration
    @glow_current_duration = duration
    @glow_zoom = (zoom-1.0)/@glow_duration
    @glow_opacity = 255.0/@glow_duration
    @glow_sprite = make_clone
    @glow_sprite.x += @glow_sprite.ox
    @glow_sprite.y += @glow_sprite.oy
  end

#------------------------------------------------------------------------------
# Zoom in and zoom out.
#------------------------------------------------------------------------------
  def zoom(duration, value, force = false)
    return if @zoom && !force
    @zoom = true
    @zoom_duration = duration
    @zoom_total_duration = duration
    @zoom_valuex = (value-self.zoom_x)/(duration/2)
    @zoom_valuey = (value-self.zoom_y)/(duration/2)
    @zoom_ori_zvaluex = self.zoom_x
    @zoom_ori_zvaluey = self.zoom_y
    @zoom_x = self.x
    @zoom_y = self.y
    @zoom_phase = 0
    self.ox = self.width/2
    self.oy = self.height/2
    self.x += self.width/2
    self.y += self.height/2
  end

#------------------------------------------------------------------------------
# Shake the sprite in its position. Mode: 0 = x and y, 1 = x only, 2 = y only.
#------------------------------------------------------------------------------
  def shake(duration, value, mode = 0, force = false)
    return if @shake && !force
    @shake = true
    @shake_duration = duration
    @shake_total_duration = duration
    @shake_value = value
    @shake_orix = self.x
    @shake_oriy = self.y
    @shake_mode = mode
  end
  
#------------------------------------------------------------------------------
# Make a clone of this sprite then return it. Useful for manipulating the 
# sprite without modifying the real sprite. In this script, I used it for glow 
# method.
#------------------------------------------------------------------------------
  def make_clone
    sprite = Sprite.new(self.viewport)
    sprite.bitmap = self.bitmap.dup
    sprite.x = self.x
    sprite.y = self.y
    sprite.z = self.z
    sprite.ox = self.ox
    sprite.oy = self.oy
    sprite.opacity = self.opacity
    sprite.visible = self.visible
    sprite
  end

  alias dhoom_battlehud_spr_update update
  def update
    dhoom_battlehud_spr_update
    update_blink if @blink
    update_glow if @glow
    update_zoom if @zoom
    update_shake if @shake
  end

  def update_blink
    if @blink_phase == 0
      self.opacity -= @blink_opacity/(@blink_duration/2.0)
    else
      self.opacity += @blink_opacity/(@blink_duration/2.0)
    end
    @blink_current_duration -= 1
    if @blink_current_duration == @blink_duration/2
      @blink_phase = 1
    end
    if @blink_current_duration == 0
      self.opacity = @blink_opacity
      @blink = false
    end
  end
  
  def blink?
    @blink
  end

  def update_glow
    @glow_sprite.zoom_x += @glow_zoom
    @glow_sprite.zoom_y += @glow_zoom
    @glow_sprite.opacity -= @glow_opacity
    @glow_current_duration -= 1
    if @glow_current_duration == 0
      @glow_sprite.dispose
      @glow = false
    end
  end
  
  def glow?
    @glow
  end

  def update_zoom
    if @zoom_phase == 0
      self.zoom_x += @zoom_valuex
      self.zoom_y += @zoom_valuey
    else
      self.zoom_x -= @zoom_valuex
      self.zoom_y -= @zoom_valuey
    end
    @zoom_duration -= 1
    if @zoom_duration == 0
      self.zoom_x = @zoom_ori_zvaluex
      self.zoom_y = @zoom_ori_zvaluey
      self.x = @zoom_x
      self.y = @zoom_y
      self.ox = 0
      self.oy = 0
      @zoom = false
    elsif @zoom_duration == @zoom_total_duration/2
      @zoom_phase = 1
    end
  end

  def update_shake    
    self.x = @shake_orix - rand(@shake_value) + rand(@shake_value) if @shake_mode == 0 || @shake_mode == 1
    self.y = @shake_oriy - rand(@shake_value) + rand(@shake_value) if @shake_mode == 0 || @shake_mode == 2
    @shake_duration -= 1
    if @shake_duration == 0
      self.x = @shake_orix
      self.y = @shake_oriy
      @shake = false
    end
  end
  
  def shake?
    @shake
  end

  alias dhoom_battlehud_spr_dispose dispose
  def dispose
    dhoom_battlehud_spr_dispose
    @glow_sprite.dispose if @glow_sprite
  end
end