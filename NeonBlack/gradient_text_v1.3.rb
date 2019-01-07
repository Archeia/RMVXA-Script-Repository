###--------------------------------------------------------------------------###
#  CP Gradient Text script                                                     #
#  Version 1.3                                                                 #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neonblack                                                 #
#  Modified by:                                                                #
#                                                                              #
#  This work is licensed under the Creative Commons Attribution-NonCommercial  #
#  3.0 Unported License. To view a copy of this license, visit                 #
#  http://creativecommons.org/licenses/by-nc/3.0/.                             #
#  Permissions beyond the scope of this license are available at               #
#  http://cphouseset.wordpress.com/liscense-and-terms-of-use/.                 #
#                                                                              #
#      Contact:                                                                #
#  NeonBlack - neonblack23@live.com (e-mail) or "neonblack23" on skype         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Revision information:                                                   #
#  V1.3 - 10.14.2012                                                           #
#   Text shape and alignment fix                                               #
#  V1.2c - 10.13.2012                                                          #
#   Font "width" issue fixed                                                   #
#   Fixed a non-gradient issue                                                 #
#  V1.2b - 9.14.2012                                                           #
#   Fixed a divide by zero error                                               #
#  V1.2 - 9.13.2012                                                            #
#   Font positioning overwrite written                                         #
#  V1.1b - 9.8.2012                                                            #
#   4 character bug fix...                                                     #
#  V1.1 - 9.7.2012                                                             #
#   Disposed bitmap bugfix                                                     #
#  V1.0 - 9.2.2012                                                             #
#   Wrote and debugged main script                                             #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Compatibility:                                                          #
#  Alias:      - Bitmap: draw_text                                             #
#  New Methods - Bitmap: convert_string, create_char, font_color_light,        #
#                        font_color_dark                                       #
#                Text: get_char, add_char, size, create_big_bitmap, key,       #
#                      clear_cache, w, h, hw, hh                               #
#                Font: array                                                   #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  Place this script in the "Materials" section of the scripts above main.     #
#  This script is plug and play with a few different options to allow you to   #
#  customize to taste.                                                         #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Config:                                                                 #
#  These are the default values used by several of the functions in the        #
#  script.  You may change these values as you find your game requires in      #
#  order to give the player a better playing experience based on your game.    #
#                                                                              #
module CP    # Do not edit                                                     #
module TEXT  #  these two lines.                                               #
#                                                                              #
###-----                                                                -----###
# Change this to false to disable this script.  The functions will still be    #
# there, but the steps will be skipped.                                        #
USE = true # Default = true                                                    #
#                                                                              #
# Defines the size of the top and bottom edges of the font.  These pixels will #
# be the lightest and darkest color to make the text appear more "rounded".    #
EDGE = 3 # Default = 3                                                         #
#                                                                              #
# Chooses if the gradient colors are applied.  Can be turned to false if you   #
# just want to use the font buffer.                                            #
GRADIENT = true # Default = true                                               #
#                                                                              #
# The bop and bottom shading of the font.  A number between 0 and 100 should   #
# be used.  The top is changed to black while the bottom is changed to white.  #
LIGHT = 70 # Default = 70                                                      #
DARK = 40 # Default = 40                                                       #
#                                                                              #
# Fixes the positioning of some characters.  Use this for fonts that get cut   #
# off or display too far to the left.  May cause additional overhead and is    #
# not always needed, so false by default.                                      #
O_POSITION = false # Default = false                                           #
###--------------------------------------------------------------------------###
 
 
###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###


end
end

$imported = {} if $imported == nil
$imported["CP_GRADIENT"] = 1.0

class Bitmap  ## Alias draw_text for all the new functions.
  alias cp_draw_grad_text draw_text unless $@
  def draw_text(*args)
    return cp_draw_grad_text(*args) unless CP::TEXT::USE
    case args.size  ## Gets all the default arguments.
    when 2, 3
      rect = args[0].dup
      string = args[1]
      align = args[2] ? args[2] : 0
    when 5, 6
      rect = Rect.new(args[0], args[1], args[2], args[3])
      string = args[4]
      align = args[5] ? args[5] : 0
    else
      return cp_draw_grad_text(*args)  ## Stops if something is somehow off.
    end
    font_bit = convert_string(string)  ## Gets the converted bitmap.
    rect.x -= Text.hw; rect.y -= Text.hh  ## Increases the edges of the rectangle.
    rect.height += Text.h; rect.width += Text.w
    if font_bit.height > rect.height  ## Checks height and adjusts the rect.
      font_bit.clear_rect(0, rect.height, font_bit.width, font_bit.height)
      rect.height = font_bit.height
    else
      unless font_bit.height == rect.height
        rect.y += (rect.height - font_bit.height) / 2
        rect.height = font_bit.height  ## Centers a taller rect.
      end
    end
    if font_bit.width > rect.width  ## Checks width and adjusts.
      pal = (rect.width - Text.w).to_f / (font_bit.width - Text.w)
      pal = (Text.w - (pal * Text.w)).to_i / 2 rescue pal = Text.hw
      rect.x += pal  ## Gets the border of the rect and adjusts.
      rect.width -= (pal * 2)
      stretch_blt(rect, font_bit, font_bit.rect)
    else
      offset = (rect.width - font_bit.width) / 2
      blt(rect.x + (offset * align), rect.y, font_bit, font_bit.rect)
    end
  end
  
  def convert_string(string)  ## Creates the string bitmap from the cache.
    string_r = Text.size(string, font)
    bitmap = Bitmap.new(string_r.width, string_r.height)
    space = 0
    var = string.to_s
    var.each_char do |c|  ## Draws each character from the cache.
      bit = Text.get_char(c, font)
      bitmap.blt(space, 0, bit, bit.rect)
      space += bit.width - Text.w
    end
    result = Bitmap.new(space + Text.w, bitmap.height)
    result.blt(0, 0, bitmap, bitmap.rect)
    return result
  end
  
  def create_char(string)  ## Creates a new character for the cache.
    edge = CP::TEXT::EDGE
    shift = 0
    if ((edge * 2) + Text.h > height) || !CP::TEXT::GRADIENT
      cp_draw_grad_text(1, 0, width, height, string, 1)
      for i in 0...height
        Text.hw.times do |n|
          break unless CP::TEXT::O_POSITION
          blnk = get_pixel(n + 1, i)
          next if blnk.alpha == 0
          shift = [Text.hw - n, shift].max
          break
        end
      end
    else  ## ^ Return a defaul character under certain conditions.
      bitmap = Bitmap.new(width + 1, height)
      bitmap.font = font
      h1 = (height - Text.h - edge * 2) / 2
      h2 = (height - Text.h - edge * 2) - h1
      gr1 = Rect.new(0, 9 + edge, 1, h1)       ## Creates the dark and
      gr2 = Rect.new(0, 9 + edge + h1, 1, h2)  ## light rectangles.
      bitmap.gradient_fill_rect(gr1, font_color_light, font.color, true)
      bitmap.gradient_fill_rect(gr2, font.color, font_color_dark, true)
      rect = Rect.new(1, 0, width, height)
      done = false
      font.color = font_color_light
      cp_draw_grad_text(0, 0, width, height, string, 1)
      for i in 0...height  ## Creates the new image in several steps.
        clr = bitmap.get_pixel(0, i)  ## Think of it like a slow scan tv.
        Text.hw.times do |n|
          break unless CP::TEXT::O_POSITION
          blnk = bitmap.get_pixel(n + 1, i)
          next if blnk.alpha == 0
          shift = [Text.hw - n, shift].max
          break
        end
        if clr.alpha == 0
          next unless done
          cr = Rect.new(1, 0, width, i)
          bitmap.clear_rect(cr)
          blt(1, 0, bitmap, rect)
        else
          unless done
            cr = Rect.new(1, i, width, height)
            clear_rect(cr)
            done = true
          end
          tr = Rect.new(1, i, width, 1)
          bitmap.font.color = clr
          bitmap.clear_rect(rect)
          bitmap.cp_draw_grad_text(1, 0, width, height, string, 1)
          blt(1, i, bitmap, tr)
        end
      end
    end
    shift -= 1
    return if shift <= 0
    holder = Bitmap.new(width, height)
    holder.blt(0 + shift, 0, self, self.rect)
    clear_rect(self.rect)
    blt(0, 0, holder, holder.rect)
  end
  
  def font_color_light  ## Creates the light font color.
    r = font.color.red
    g = font.color.green
    b = font.color.blue
    color = []
    [r, g, b].each {|c| color.push(c + (255 - c) * CP::TEXT::LIGHT / 100) }
    return Color.new(color[0], color[1], color[2], font.color.alpha)
  end
  
  def font_color_dark  ## Creates the dark font color.
    r = font.color.red
    g = font.color.green
    b = font.color.blue
    color = []
    [r, g, b].each {|c| color.push(c - c * CP::TEXT::DARK / 100) }
    return Color.new(color[0], color[1], color[2], font.color.alpha)
  end
end

module Text
  WIDTH = 40
  HEIGHT = 20
  
  def self.w; return WIDTH; end
  def self.h; return HEIGHT; end
  def self.hw; return WIDTH / 2; end
  def self.hh; return HEIGHT / 2; end
  
  def self.get_char(char, font = Font.new)
    @letter = {} if @letter.nil?  ## Returns the character bitmap by font.
    add_char(char, font) unless @letter.include?(key(char, font))
    return @letter[key(char, font)]
  end
  
  def self.add_char(char, font)
    rect = size(char, font)  ## Creates and edits a new bitmap for the cache.
    @letter[key(char, font)] = Bitmap.new(rect.width, rect.height)
    @letter[key(char, font)].font = font
    @letter[key(char, font)].create_char(" " + char + " ")
  end
  
  def self.size(char, font = Font.new)
    create_big_bitmap
    @bitmap.font = font  ## Gets a character's size with a buffer.
    rect = @bitmap.text_size(char)
    rect.width += Text.w
    rect.height += Text.h
    return rect
  end
  
  def self.create_big_bitmap
    return unless @bitmap.nil? || @bitmap.disposed?
    @bitmap = Bitmap.new(Graphics.width, Graphics.height)
    clear_cache
  end
  
  def self.key(char, font)  ## Creates a character's key by font.
    res = font.array + [char]
    return res
  end
  
  def self.clear_cache  ## Clears the cache.  Not called by me at all.
    @letter = {}
  end
end

class Font   ## Gets the fonts total array.  All aspects of the font
  def array  ## are here for use in making a character bitmap's key.
    [name, size, bold, italic, outline, shadow, color.red, color.green,
     color.blue, color.alpha, out_color.red, out_color.green, out_color.blue,
     out_color.alpha]
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###