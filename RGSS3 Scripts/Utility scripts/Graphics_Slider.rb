#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
# Sliding Graphics
# Author: Kread-EX
# Version 1.0
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
 
#  TERMS OF USAGE
# #------------------------------------------------------------------------------------------------------------------
# #  You are free to adapt this work to suit your needs.
# #  You can use this work both for commercial and non-commercial work.
# #  Credit is appreciated.
# #------------------------------------------------------------------------------------------------------------------
 
#===========================================================
# INTRODUCTION
#
# Adds moving capabilities to your sprites and windows. Only useful to scripters.
# Cross-engine (Works for XP and VX).
# Easy to use and no ZeroDivision error.
# Four methods to know:
#
# x_slide(new_x, incrementation) <-- Horizontal sliding
# y_slide(new_y, incrementation) <-- Vertical sliding
# bi_slide(new_x, new_y, x_incrementation, y_incrementation) <-- Dual sliding
# is_sliding? <-- Query to check if sliding.
#===========================================================
 
#===========================================================
# ** GFX_Slider
#------------------------------------------------------------------------------
# This is mixed into windows and sprites to make them slide.
#===========================================================
 
module GFX_Slider
  #--------------------------------------------------------------------------
  # * Perform horizontal slide
  #--------------------------------------------------------------------------
  def x_slide(x_dest, inc)
    @x_destination = x_dest
    @x_increment= inc
  end
  #--------------------------------------------------------------------------
  # * Perform vertical slide
  #--------------------------------------------------------------------------
  def y_slide(y_dest, inc)
    @y_destination = y_dest
    @y_increment = inc
  end
  #--------------------------------------------------------------------------
  # * Perform both
  #--------------------------------------------------------------------------
  def bi_slide(x_dest, y_dest, x_inc, y_inc)
    x_slide(x_dest, x_inc)
    y_slide(y_dest, y_inc)
  end
  #--------------------------------------------------------------------------
  # * Update horizontal motion
  #--------------------------------------------------------------------------
  def update_x_slide
    return if @x_destination == nil
    if @x_destination > self.x
      self.x = [self.x + @x_increment, @x_destination].min
    else
      self.x = [self.x - @x_increment, @x_destination].max
    end
    @x_destination = nil if @x_destination == self.x
  end
  #--------------------------------------------------------------------------
  # * Update vertical motion
  #--------------------------------------------------------------------------
  def update_y_slide
    return if @y_destination == nil
    if @y_destination > self.y
      self.y = [self.y + @y_increment, @y_destination].min
    else
      self.y = [self.y - @y_increment, @y_destination].max
    end
    @y_destination = nil if @y_destination == self.y
  end
  #--------------------------------------------------------------------------
  # * Checks if sliding
  #--------------------------------------------------------------------------
  def is_sliding?
    return (@x_destination != nil || @y_destination != nil)
  end
  #--------------------------------------------------------------------------
end
 
#===========================================================
# ** Window_Base implementation
#===========================================================
 
class Window_Base < Window
  include GFX_Slider
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  unless method_defined?(:kread_slide_window_init)
    alias_method  :kread_slide_window_init, :initialize
  end
  def initialize(x, y, width, height)
    kread_slide_window_init(x, y, width, height) # Original call
    # When these two variables are different than the coordinates, the window moves.
    @x_destination = nil
    @y_destination = nil
    # Coordinates incrementation.
    @x_increment = 0
    @y_increment = 0
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  unless method_defined?(:kread_slide_window_update)
    alias_method  :kread_slide_window_update, :update
  end
  def update
    kread_slide_window_update  # Original call
    update_x_slide
    update_y_slide
    return if self.is_sliding?
  end
  #--------------------------------------------------------------------------
end
 
#===========================================================
# ** Sprite implementation
#===========================================================
 
class Sprite
  include GFX_Slider
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  unless method_defined?(:kread_slide_sprite_init)
    alias_method  :kread_slide_sprite_init, :initialize
  end
  def initialize(viewport = nil)
    kread_slide_sprite_init(viewport) # Original call
    # When these two variables are different than the coordinates, the window moves.
    @x_destination = nil
    @y_destination = nil
    # Coordinates incrementation.
    @x_increment = 0
    @y_increment = 0
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  unless method_defined?(:kread_slide_sprite_update)
    alias_method  :kread_slide_sprite_update, :update
  end
  def update
    kread_slide_sprite_update  # Original call
    update_x_slide
    update_y_slide
    return if self.is_sliding?
  end
  #--------------------------------------------------------------------------
end