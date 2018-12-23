# Text Cache v 1.03
# by Mithran
# hosted at forums.rpgmakerweb.com

# Instructions
%Q(
This script is a workaround for the Bitmap#draw_text issues in RPGMaker VX Ace.

By default, there are several errors with Bitmap#draw_text in Ace.

1.  Text shrinking algorithm is overzealous.  Text drawn to a rect given by 
    its own text_size is reduced in size.  This is both counterintuitive, and not 
    the way it worked in previous versions (VX).
  
2.  Text drawn to any rect wider than approx 640 pixels wraps around to the 
    beginning of the line, overwriting previous text.  This also causes center
    and right alignments to fail.  This is both unnecessary and not how it worked
    in VX.
    
3.  Text drawn character by character with non true-type fonts has awkward spacing.
    In addition, the text_size of a string of characters is not the same as the 
    sum of the text_size of each character.
    This existed even in VX.
    
4.  The first character of a Bitmap#draw_text command for certain letters on 
    certain fonts is not drawn correctly.  Since message window draws character
    by character, this can become a major issue. (example: Verdana 20 pt font)
    
These errors can be demonstrated using my text draw debugger:
http://pastebin.com/p55ukZP2
    
What this script does:

1.  Adds 2 pixels to any draw_text width, so text can be intuitively drawn to its
    own text_size rect. Offsets x coordinate where appropriate.
    If SIMPLE_FIX is set to true, only this fix will be enabled.
    
2.  Adds a text cache.  Instead of drawing text directly when called, a unique
    bitmap is created for any potential text draw with buffers, drawn with extra
    space around it.  The character is then copied whenever a text draw is 
    attempted.
    
    Text Caching can be turned off by setting SIMPLE_FIX to true.
    
    Text Caching also has the following features:
    - Much faster processing than the original Bitmap#draw_text.
      Trades a small amount of memory to accomodate faster processing speed.
      The first time any letter is drawn takes approximately 3-4 times as long, 
      subsquently, any time this same letter and font is drawn it is upwards of
      twice as fast.  The longer the string drawn, the bigger the difference.
    - Accounts for a 3-length string when checking the size.  This makes single
      characters drawn look more natural for the offending fonts.
    Does not work with:
    - Reduced size text.
      If text is squeezed due to not being given enough room to draw, text caching
      is bypassed in favor of the original method.  This is due to the text 
      squeezing algorithm reducing each character by a variable amount that can
      not be determined with text_size.  Manually stretching or aligning this
      "squeezed" text looks completely awful, so for now, this will have to 
      stay like this.
      The exception to this is if the text has "just enough" room to draw, 
      it will be given the two extra pixels rather than squeezing it.
    - If text extends beyond MAX_DRAW_WIDTH, text caching will be forced.
      This disables the "squeeze" effect.  Using the default method means the text
      would draw over itself anyway, so this is the lesser of two evils.
      
Changelog:

v 1.03
  Added an option to control how much buffer is given before text squeeze turns off.
  Added an absolute width limit allowed for a draw_text operation to prevent a rare game.exe crash.
  Added an option to completely disable the default squeezing method to always cache.

v 1.02
  Fixed crash error when drawing a null/zero height character.

v 1.01
  Fixed crash error when using F12 to reset. (Thanks Archiea_Nessiah)

v 1.0 
Official release.
)

 
  DISABLE_TEXT_SQUEEZE = false
  # turning this to true completely disables all built in text squeezing methods

  TEXT_SQUEEZE_MIN_TRIGGER_RATE = 1.5 
  # the rate at which width of the text must be greater than the draw area
  # in order to trigger the default draw method that "squeezes" text
  # set to 1.0 to turn this feature off

  
class Bitmap
  TEXT_TOP_BUFFER = 2
  TEXT_SIDE_BUFFER = 8 # buffer in pixels to draw text away from 
  # the edge of the bitmap, to prevent certain characters from being cut off
  SIMPLE_FIX = false # just adds the two pixels to prevent unnecessary squeeze
  # depricated, as doing so causes the other mentioned bugs to still appear
  # 1.03 - changed to continue to draw text by character to prevent the crashing error
  MAX_TEXT_DRAW_WIDTH = 640 # tests have shown the draw fails at around 640px
  # if nil, no max width
  MAX_TEXT_DRAW_WIDTH_ABSOLUTE = 2016 # the absolute limit accepted by draw_text
  # this prevents a game.exe crash when the draw_text is called to a small space with a ton of text
  # any text longer than this will be automatically drawn without squeezing
  # this option should NEVER trigger either way
  NO_FIX = false # completely disables the fix, for testing comparison
  
  
  alias draw_text_vxa draw_text
  def draw_text(*args)
    return draw_text_vxa(*args) if NO_FIX
    if args[0].is_a?(Rect)
      rect = args[0]
      x, y, width, height = rect.x, rect.y, rect.width, rect.height
      text = args[1].to_s.clone || ""
      align = args[2] || 0
    else
      x, y, width, height = *args[0..3]
      text = args[4].to_s.clone || ""
      align = args[5] || 0
    end
    if check_squeeze_allowed(x, y, width, height, text)
      x -= align
      # shift one pixels to the left if centering 
      # two if right right justified
      # to offset the extra width given
      draw_text_vxa(x, y, width + 2, height, text, align)
    else
      draw_text_cached(x, y, width, height, text, align)
    end
  end
  
  def check_squeeze_allowed(x, y, width, height, text)
    return false if DISABLE_TEXT_SQUEEZE # completely disables squeeze
    return false if MAX_TEXT_DRAW_WIDTH && width > MAX_TEXT_DRAW_WIDTH # will not squeeze if over size limit
    text_width = text_size(text).width
    return false if text_width >= MAX_TEXT_DRAW_WIDTH_ABSOLUTE # will not squeeze if over size limit
    text_width > width * TEXT_SQUEEZE_MIN_TRIGGER_RATE # will not squeeze if over size limit
  end
  
  def draw_text_cached(x, y, width, height, text, align, allow_squeeze = false)
    text_rect = self.text_size(text)
    text_width = text_rect.width
    text_height = text_rect.height
    # allow_squeeze - not recommended and completely hidden unless you are reading this
    if allow_squeeze && text_width > width * TEXT_SQUEEZE_MIN_TRIGGER_RATE
      ratio = width / text_width.to_f
      ratio = 0.5 if ratio < 0.5
      rect = Rect.new(0, 0, 0, 0)
    else 
      ratio = nil
    end
    fontkey = self.font.to_a
    case align
    when 1; x += (width - text_width) / 2
    when 2; x += width - text_width
    end
    y += (height - text_height) / 2 # horizontal center
    buf = -TEXT_SIDE_BUFFER
    buf *= ratio if ratio
    text.each_char { |char|
    letter = TextCache.letters(fontkey, char)
    if SIMPLE_FIX  # swap with original method for debugging and simple fix
      draw_text_vxa(x + buf, y, letter.rect.width + 2, letter.height, char)
      buf += letter.rect.width - TEXT_SIDE_BUFFER * 2
    elsif ratio # drawing squished text
      w = (ratio * 10).to_i * letter.rect.width / 10 
      rect.set(x + buf, y, w, text_height)
      self.stretch_blt(rect, letter, letter.rect) 
      buf += (letter.rect.width * ratio - TEXT_SIDE_BUFFER * 2 * ratio).to_i
    else
      self.blt(x + buf, y, letter, letter.rect)
      buf += letter.rect.width - TEXT_SIDE_BUFFER * 2
    end
    }
    nil
  end
end

module TextCache
  BUFFER_DRAW = 300 # for drawing characters, to make sure there is enough room
  
  def self.canvas(font = nil)
    @canvas = Bitmap.new(32, 32) if @canvas.nil? || @canvas.disposed?
    #@canvas.font = font if font and font != @canvas.font
    @canvas
  end
  
  def self.letters(font, char)
    @cache ||= {}
    key = font + [char]
    if include?(key)
      return @cache[key]
    elsif char.empty?
      return empty_bitmap
    else
      return new_letter(font, char)
    end
  end
  
  def self.empty_bitmap # not used, added for completness in case the cache is accessed directly
    @cache[:empty] = Bitmap.new(32, 32) unless include?(:empty)
    @cache[:empty]
  end 
  
  def self.new_letter(fontary, char)
    font = create_font(fontary)
    # get the font
    canvas.font = font
    rect = canvas.text_size(char * 3) 
    return @cache[key] = empty_bitmap if (rect.height == 0 || rect.width == 0)
    # get size of character between two other characters (for better kerning)
    b = Bitmap.new((rect.width / 3) + Bitmap::TEXT_SIDE_BUFFER * 2, rect.height)
    # create bitmap just big enough for one character
    b.font = font
    # get the font
    b.draw_text_vxa(rect.x - b.text_size(" ").width + Bitmap::TEXT_SIDE_BUFFER, rect.y - Bitmap::TEXT_TOP_BUFFER, BUFFER_DRAW, rect.height + Bitmap::TEXT_TOP_BUFFER * 2, " #{char} ", 0)
    # draw blank spaces before and after character, fix for cutting off the 
    # first pixel using draw_text
    key = fontary + [char]
    @cache[key] = b    
  end
  
  def self.create_font(fontary)
    font = Font.new(*fontary[0..1])
    font.bold = fontary[2]
    font.italic = fontary[3]
    font.outline = fontary[4]
    font.shadow = fontary[5]
    font.color.set(*fontary[6..9])
    font.out_color.set(*fontary[10..13])
    font
  end

  
  def self.include?(key)
    @cache[key] && !@cache[key].disposed?
  end

  def self.clear
    @cache ||= {}
    @cache.clear
    GC.start
  end
  
end



class Font
  # font's instance variables are not reflective, so this has to be defined explicitly
  def to_a
    [name, size, bold, italic, outline, shadow, color.red, color.green, color.blue, color.alpha, out_color.red, out_color.green, out_color.blue, out_color.alpha]
  end
  
end