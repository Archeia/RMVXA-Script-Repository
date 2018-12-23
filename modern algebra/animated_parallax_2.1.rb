#==============================================================================
#    Animated Parallax
#    Version 2.1
#    Author: modern algebra (rmrk.net)
#    Date: September 9, 2011
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script allows you to set an animated parallax background by having 
#   multiple frames and switching between them at a user-defined speed. By 
#   default, this script only supports .png, .jpg, and .bmp file formats for 
#   the animated parallax panels (as they are the only ones I know RMVX 
#   supports).
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    
#    The script operates by having multiple parallax backgrounds and switching
#   between them at a speed set by you, unique for each map
#
#    Thus, if you want to use an animated parallax, you need to do a few things:
#      (a) Make or find the parallax backgrounds you want to use and import 
#        them into your game. Then, label them all the same with the one
#        distinction that at the end of each should have a _1, _2, etc...
#          Example Naming:
#            BlueSky_1, BlueSky_2, BlueSky_3, etc...
#      (b) Set the parallax background to any given map that you want the 
#        animated parallaxes for. Be sure to set it to the first one you want
#        in succession, so BlueSky_1, not BlueSky_2 or _3. If you do set it to
#        BlueSky_2, then it will only animate between images _2 and _3.
#      (c) Scroll down to the EDITABLE REGION at line 48 and follow the 
#        instructions for setting the animation speed
#==============================================================================

$imported = {} unless $imported
$imported["MAAnimatedParallax"] = true
$imported["MAAnimatedParallax2.1"] = true

#==============================================================================
# ** Game_Map
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - update_parallax; setup_parallax
#    new method - maap_check_extensions; setup_parallax_frames
#==============================================================================

class Game_Map
  MAAP_PARALLAX_ANIMATION_FRAMES = { # <- Don't touch
  #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  #    EDITABLE REGION
  #|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #  MAAP_PARALLAX_ANIMATION_FRAMES - this constant allows you to set the
  # speed at which the parallax switches to the next graphic in the animation
  # series by individual maps. So if you want it to be every 20 frames in one
  # map but every 35 in another map, this is where you do it. All you need to 
  # do is type in the following code:
  #
  #      map_id => frames,
  # where map_id is the ID of the Map you want to set it for and frames is
  # either (a) an integer for how many frames you want to show each panel 
  # before switching to the next; or (b) an array of integers where each entry
  # of the array is the number of frames to keep the corresponding frame up 
  # before switching to the next. This allows you to vary the time each of the
  # frames is left on before switching. There are 60 frames in a second.
  #
  #    EXAMPLES:
  #      1 => 35,    Map 1 will cycle through parallax panels every 35 frames
  #      2 => 40,    Map 2 will cycle through parallax panels every 40 frames
  #      8 => [20, 5, 15],    Map 8 will keep the first panel of the animated
  #                  parralax on for 20 frames before switching to the second
  #                  panel which will be on for 5 frames before switching to 
  #                  the third panel which is on 15 frames before switching 
  #                  back to the first panel.
  #
  #  Note that the comma is necessary! For any maps where you use animated 
  # parallaxes but do not include the map ID in this hash, then it will default
  # to the value at line 83.
    2 => 40, 
    8 => 20, 
  } # <- Don't touch
  #  Changing the below value allows you to change the default speed of frame 
  # animation. Ie. the speed of frame animation in a map in which you have not
  # directly set the speed via the above hash configuration. 
  MAAP_PARALLAX_ANIMATION_FRAMES.default = 30
  #  Depending on the size of the parallaxes and how many panels you use in a
  # map, there can be some lag when you load new panels. The following option 
  # allows you to decide whether all the parallax frames are loaded at once 
  # when the map is first entered or individually the first time each panel 
  # shows up. Generally, if your panels are very large (1MB+) then you should
  # set it to true; if smaller files, then you should set it to false.
  MAAP_PRELOAD_PARALLAXES = true
  #|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #    END EDITABLE REGION
  #///////////////////////////////////////////////////////////////////////////
  MAAP_SUPPORTED_EXTENSIONS = ["png", "jpg", "bmp"]
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Parallax
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_ap_stuppara_5tc1 setup_parallax
  def setup_parallax (*args, &block)
    ma_ap_stuppara_5tc1 (*args, &block) # Run Original Method
    setup_parallax_frames
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Parallax
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mlg_ap_updparal_4fg2 update_parallax
  def update_parallax (*args, &block)
    mlg_ap_updparal_4fg2 (*args, &block) # Run Original Method
    # Use the timer if the parallax has more than one frame
    if @maap_parallax_frames && @maap_parallax_frames.size > 1
      @maap_parallax_frame_timer += 1
      if @maap_parallax_frame_timer % @maap_parallax_frame_limit == 0
        @maap_parallax_index = (@maap_parallax_index + 1) % @maap_parallax_frames.size
        @parallax_name = @maap_parallax_frames[@maap_parallax_index]
        if MAAP_PARALLAX_ANIMATION_FRAMES[@map_id].is_a? (Array) && MAAP_PARALLAX_ANIMATION_FRAMES[@map_id].size > @maap_parallax_index
          @maap_parallax_frame_limit = MAAP_PARALLAX_ANIMATION_FRAMES[@map_id][@maap_parallax_index]
        end
      end
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Parallax Frames
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def setup_parallax_frames
    # Dispose the cached bitmaps from the previous map
    last_map_bmps = @maap_parallax_frames.nil? ? [] : @maap_parallax_frames
    @maap_parallax_index = 0
    @maap_parallax_frames = [@parallax_name]
    @maap_parallax_frame_timer = 0
    if MAAP_PARALLAX_ANIMATION_FRAMES[@map_id].is_a? (Array) && MAAP_PARALLAX_ANIMATION_FRAMES[@map_id].size > 0
      @maap_parallax_frame_limit = MAAP_PARALLAX_ANIMATION_FRAMES[@map_id][0]
    else
      @maap_parallax_frame_limit = MAAP_PARALLAX_ANIMATION_FRAMES[@map_id]
    end
    if @parallax_name[/_(\d+)$/] != nil
      frame_id = $1.to_i + 1
      base_name = @parallax_name.sub (/_\d+$/) { "" }
      while maap_check_extensions ("Graphics/Parallaxes/#{base_name}_#{frame_id}")
        @maap_parallax_frames.push ("#{base_name}_#{frame_id}")
        frame_id += 1
      end
    end
    (last_map_bmps - @maap_parallax_frames).each { |bmp| (Cache.parallax (bmp)).dispose }
    # Preload all the parallax bitmaps so no lag is experienced on first load
    if MAAP_PRELOAD_PARALLAXES
      (@maap_parallax_frames - last_map_bmps).each { |bmp| Cache.parallax (bmp) }
      Graphics.frame_reset
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Check Extensions
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maap_check_extensions (filepath)
    MAAP_SUPPORTED_EXTENSIONS.each { |ext| 
      return true if FileTest.exist? ("#{filepath}.#{ext}") }
    return false
  end
end

#==============================================================================
# ** Spriteset Map
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - update_parallax
#==============================================================================

class Spriteset_Map
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Parallax
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malg_animparlx_upd_4rg1 update_parallax
  def update_parallax (*args, &block)
    # Don't ever dispose the cached parallax pictures.
    @parallax.bitmap = nil if @parallax_name != $game_map.parallax_name  
    malg_animparlx_upd_4rg1 (*args, &block) # Run Original Method
  end
end