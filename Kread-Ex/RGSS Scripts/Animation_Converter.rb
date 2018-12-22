#==============================================================================
# ** Animation Converter
# v. 1.0
# Author: Kread-EX
# ------------------------------------------------------------------------------
# Converts vxdata animations files to rxdata.
#==============================================================================
 
# This script makes animations created with RMVX useable with RMXP.
# "What the point ?", you might ask.
# Well, I had to make this for my own use, so I release it in case others need it.
 
# Basically, RMVX animations use 2 bitmap files which is great. If you have animated battlers
# with a lot of special moves, you might end up with tons of bitmap files to bloat your
# project's size.
# In that case, you can create animation data in RPG VX and convert them to the XP format.
 
### INSTRUCTIONS ###
 
# 1 - Copy the script and paste it just above Main.
# 2 - Make your animation file with RPG Maker VX.
# 3 - Create a backup for all your animation files, you never know what might happens.
# 4 - Locate the file named "Animations.rvdata" in the "Data/Animations/" folder of your VX
# project and paste it in your XP project folder.
# 5 - Run your RMXP game executable from the editor.
# 6 - Copy the resulting "Animations.rxdata" file into the "Data/Animations/" folder of your
# XP project.
# 7 - Although you won't see the result in the editor, both bitmaps will be loaded by the game.
 
# NOTE: RPGXP Editor will not read the second bitmap of the animation but the game will.
 
#--------------------------------------------------------------------------
# * Converts the rvdata file
#--------------------------------------------------------------------------
module RPG
  class Animation
    attr_accessor(:animation1_name, :animation1_hue, :animation2_name, :animation2_hue)
    class Timing
      attr_accessor(:se)
    end
  end
  class SE
    attr_reader(:name, :volume, :pitch)
  end
end
if $DEBUG &amp;&amp; FileTest.exist?('Animations.rvdata')
  array = [nil]
  a = load_data('Animations.rvdata')
  a.each {|anim|
  next if anim == nil
  b = anim
  c = RPG::Animation.new
  c.id = b.id
  c.name = b.name
  c.animation_name = b.animation1_name
  c.animation_hue = b.animation1_hue
  c.position = b.position
  c.frame_max = b.frame_max
  c.frames = b.frames
  c.timings = b.timings
  (0..c.timings.size-1).each {|i| c.timings[i].se = RPG::AudioFile.new(b.timings[i].se.name,
  b.timings[i].se.volume, b.timings[i].se.pitch)}
  c.animation2_name = b.animation2_name
  c.animation2_hue = b.animation2_hue
  array.push(c)}
  save_data(array, 'Animations.rxdata')
end
 
#--------------------------------------------------------------------------
# * This part will allow the game to read the animation
#--------------------------------------------------------------------------
module RPG
  #--------------------------------------------------------------------------
  class Sprite < ::Sprite
    #--------------------------------------------------------------------------
    # * Process the animation
    #--------------------------------------------------------------------------
    def animation(animation, hit)
      dispose_animation
      @_animation = animation
      return if @_animation == nil
      @_animation_hit = hit
      @_animation_duration = @_animation.frame_max
      animation_name = @_animation.animation_name
      animation_name2 = @_animation.animation2_name
      animation_hue = @_animation.animation_hue
      animation_hue2 = @_animation.animation2_hue
      @bitmap = RPG::Cache.animation(animation_name, animation_hue)
      @bitmap2 = RPG::Cache.animation(animation_name2, animation_hue2) rescue @bitmap2 = nil
      if @@_reference_count.include?(@bitmap)
        @@_reference_count[@bitmap] += 1
      else
        @@_reference_count[@bitmap] = 1
      end
      if !@bitmap2.nil?
        if @@_reference_count.include?(@bitmap2)
          @@_reference_count[@bitmap2] += 1
        else
          @@_reference_count[@bitmap2] = 1
        end
      end
      @_animation_sprites = []
      if @_animation.position != 3 or not @@_animations.include?(animation)
        for i in 0..15
          sprite = ::Sprite.new(self.viewport)
          sprite.visible = false
          @_animation_sprites.push(sprite)
        end
        unless @@_animations.include?(animation)
          @@_animations.push(animation)
        end
      end
      update_animation
    end
    #--------------------------------------------------------------------------
    # * Sets the sprites
    #--------------------------------------------------------------------------
    def animation_set_sprites(sprites, cell_data, position)
      for i in 0..15
        sprite = sprites[i]
        pattern = cell_data[i, 0]
        if !pattern.nil? &amp;&amp; pattern < 100
          sprite.bitmap = @bitmap
        elsif !pattern.nil?
          sprite.bitmap = @bitmap2
        end
        if sprite == nil or pattern == nil or pattern == -1
          sprite.visible = false if sprite != nil
          next
        end
        sprite.visible = true
        sprite.src_rect.set(pattern % 5 * 192, pattern % 100 / 5 * 192, 192, 192)
        if position == 3
          if self.viewport != nil
            sprite.x = self.viewport.rect.width / 2
            sprite.y = self.viewport.rect.height - 160
          else
            sprite.x = 320
            sprite.y = 240
          end
        else
          sprite.x = self.x - self.ox + self.src_rect.width / 2
          sprite.y = self.y - self.oy + self.src_rect.height / 2
          sprite.y -= self.src_rect.height / 4 if position == 0
          sprite.y += self.src_rect.height / 4 if position == 2
        end
        sprite.x += cell_data[i, 1]
        sprite.y += cell_data[i, 2]
        sprite.z = 2000
        sprite.ox = 96
        sprite.oy = 96
        sprite.zoom_x = cell_data[i, 3] / 100.0
        sprite.zoom_y = cell_data[i, 3] / 100.0
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
        sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
        sprite.blend_type = cell_data[i, 7]
      end
    end
    #--------------------------------------------------------------------------
  end
  #--------------------------------------------------------------------------
end