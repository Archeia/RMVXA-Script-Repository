#==============================================================================
#    Show Animated Picture
#    Version: 1.0
#    Author: modern algebra (rmrk.net)
#    Ported by by: Kread-Ex
#    Date: February 20, 2010
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    
#    This will allow you to show animated pictures through the regular event 
#   commands. 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Place this script in its own slot in the Script Editor (F11) above Main
#   and below all the other default scripts.
#
#    The format for the animated picture is that each frame of the animation 
#   should be placed in the image to the right of the previous frame. Each 
#   frame must be equal width. The easiest example is any direction of a 
#   character sprite. Once you have created your picture in the correct format,
#   you must identify how you want it to animate in its name. You can name the
#   file whatever you want, but you need to include this code somewhere in the
#   name:
#        %[frame_width, time_interval]
#   where:
#     frame_width : the width of each frame, so this should be an integer of 
#       however many pixels wide each frame of the animation is
#     time_interval : this determines how much time each frame is shown for 
#       before switching to the next frame. It is also an integer, where
#       60 = 1 second. So, if you want each frame to be shown for only 1/10 of
#       a second, then you should put 6 here. If you do not specify a time
#       interval and leave it as %[frame_width] then it will take the value
#       specified in SAP_DEFAULT_TIME at line 56.
#
#    The animation will go from the first through to the last frame and then
#   repeat until the picture is erased. It will switch between frames at the
#   speed you define by setting time_interval.
#
#    If you do not include this code in the name, then the game will treat it 
#   as a normal picture and show the whole thing.
#==============================================================================

#==============================================================================
# ** Sprite_Picture
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new constant - SAP_DEFAULT_FRAMES
#    aliased method - update
#    new method - update_src_rect
#==============================================================================

class Sprite_Picture
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * CONSTANTS
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  SAP_DEFAULT_TIME = 12
  Z_VALUE = 200
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Frame Update
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malbr_anmtepictr_upte_6ys1 update
  def update(*args)
    # Check if picture has changed and, if so, whether it is animated
    if @picture_name != @picture.name
      @sap_animated = @picture.name[/%\[(\d+),?\s*?(\d*?)\]/] != nil
      if @sap_animated
        @sap_frame_width = $1.to_i
        @sap_time_interval = $2.to_i != 0 ? $2.to_i : SAP_DEFAULT_TIME
        self.z = Z_VALUE
      end
      @sap_current_frame = -1
      @sap_frame_count = 0
      @picture_name = @picture.name
    end
    malbr_anmtepictr_upte_6ys1(*args) # Run Original Method
    # If picture is animated
    update_src_rect if @sap_animated
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Update Transfer Origin Rectangle
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_src_rect
    @sap_frame_count %= @sap_time_interval
    if @sap_frame_count == 0
      @sap_current_frame += 1
      @sap_current_frame = 0 if self.bitmap.width < (@sap_current_frame + 1)*@sap_frame_width
      sx = @sap_current_frame*@sap_frame_width
      self.src_rect.set(sx, 0, @sap_frame_width, self.bitmap.height)
    end
    @sap_frame_count += 1
  end
end
