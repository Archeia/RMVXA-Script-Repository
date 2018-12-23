#==============================================================================
# Show Animation Fix
# by Engr. Adiktuzmiko
#==============================================================================
# So from my own experience + some threads a few months back, the show animation 
# event command (or maybe animations as a whole) works a bit odd when the screen 
# scrolls. The animation scrolls with the screen instead of staying on target, 
# which is weird for non-screen animations.
#
# Better put it above any other script, especially those that might be overwriting
# the same method.
#==============================================================================
class Sprite_Base 
  def update_animation return unless animation? 
    # We reset the origin so that it shows correctly 
    set_animation_origin 
    @ani_duration -= 1 
    if @ani_duration % @ani_rate == 0 
    if @ani_duration > 0 
      frame_index = @animation.frame_max 
      frame_index -= (@ani_duration + @ani_rate - 1) / @ani_rate 
      animation_set_sprites(@animation.frames[frame_index]) 
      @animation.timings.each do |timing| 
      animation_process_timing(timing) 
      if timing.frame == frame_index 
      end 
      else 
      end_animation 
      end 
    end 
  end
end
