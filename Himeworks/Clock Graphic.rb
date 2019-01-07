=begin
#===============================================================================
 Title: Clock Graphic
 Author: Hime
 Date: Mar 28, 2013
--------------------------------------------------------------------------------
 ** Change log
 Mar 28, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script replaces the default timer sprite with a custom clock picture
 of your choice. It might look better.
 
--------------------------------------------------------------------------------
 ** Installation
 
 Place this script below Materials and above Main
 Add any clock images to your Graphics/System folder.

--------------------------------------------------------------------------------
 ** Usage
 
 In the configuration below, specify the filename of the picture to use
 for the clock. The clock should be a perfect circle with the hands extending
 from the center.
 
 The clock hands are drawn automatically and are scaled to the size of the
 image.
 
 You can specify the origin of the clock, which is the position of the
 upper-left corner, if you wish to move where the clock will be displayed.
 
 You can also specify the colors of each hand.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_ClockGraphic"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Clock_Graphic
    
    # Name of the picture to use for the clock.
    # This should be in the System folder
    Picture_Name = "clock3"
    
    # The clock's x- and y-origin (upper-left corner)
    Clock_Origin = [0, 0]
    
    # The colours for each hand. Specify the RGB values
    Minute_Color = Color.new(255, 255, 0)
    Second_Color = Color.new(255, 0, 0)
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
#-------------------------------------------------------------------------------
# The main clock sprite
#-------------------------------------------------------------------------------
class Sprite_Clock < Sprite
  
  def initialize(viewport, timer)
    super(viewport)
    self.visible = timer.working?
    @timer = timer
    create_bitmap
    create_hands
    update_hands
  end
  
  def create_bitmap
    self.bitmap = Cache.system(TH::Clock_Graphic::Picture_Name)
    self.x, self.y = TH::Clock_Graphic::Clock_Origin
  end
  
  def create_hands
    create_second_hand
    create_minute_hand
  end
  
  def create_minute_hand
    return if @minute_hand
    @minute_hand = Sprite_ClockMinuteHand.new(@viewport, @timer, 3, self.bitmap.height / 3)
    @minute_hand.x = self.x + self.bitmap.width / 2
    @minute_hand.y = self.y + self.bitmap.height / 2 + 1
    @minute_hand.ox = -1
    @minute_hand.z = self.viewport.z + 1
  end
  
  def create_second_hand
    return if @second_hand
    @second_hand = Sprite_ClockSecondHand.new(@viewport, @timer, 3, self.bitmap.height / 2.4)
    @second_hand.x = self.x + self.bitmap.width / 2
    @second_hand.y = self.y + self.bitmap.height / 2 + 1
    @second_hand.z = self.viewport.z + 1
    @second_hand.ox = 1
  end

  def update
    super
    update_visible
    update_hands
  end
  
  def update_visible
    self.visible = @timer.working?
  end
  
  def update_hands
    @minute_hand.update
    @second_hand.update
  end
  
  def dispose
    super
    dispose_hands
    self.bitmap.dispose
  end
  
  def dispose_hands
    @minute_hand.dispose
    @second_hand.dispose
  end
end

#-------------------------------------------------------------------------------
# Generic clock hand sprite
#-------------------------------------------------------------------------------
class Sprite_ClockHand < Sprite
  
  def initialize(viewport, timer, width, height)
    super(viewport)
    self.visible = timer.working?
    @timer = timer
    @width = width
    @height = height
    draw_hand
  end
  
  def draw_hand
    self.bitmap = Bitmap.new(@width, @height)
    self.bitmap.fill_rect(self.bitmap.rect, hand_color)
  end
  
  def hand_color
    Color.new(0, 0, 0)
  end
  
  def update
    update_visible
  end
  
  def update_visible
    self.visible = @timer.working?
  end
  
  def dispose
    self.bitmap.dispose if self.bitmap
    super
  end
end

#-------------------------------------------------------------------------------
# Sprite for the minute hand
#-------------------------------------------------------------------------------
class Sprite_ClockMinuteHand < Sprite_ClockHand
  
  def update
    self.angle = 180 - (@timer.sec / 60.0 * 6)
    super
  end
  
  def hand_color
    TH::Clock_Graphic::Minute_Color
  end
end

#-------------------------------------------------------------------------------
# Sprite for the second hand
#-------------------------------------------------------------------------------
class Sprite_ClockSecondHand < Sprite_ClockHand
  
  def hand_color
    TH::Clock_Graphic::Second_Color
  end
  
  def update
    self.angle = 180 - (@timer.sec * 6)
    super
  end
end

#-------------------------------------------------------------------------------
# Replace the default timer sprite with our custom clock sprite
#-------------------------------------------------------------------------------
class Spriteset_Map
  def create_timer
    @timer_sprite = Sprite_Clock.new(@viewport2, $game_timer)
  end
end