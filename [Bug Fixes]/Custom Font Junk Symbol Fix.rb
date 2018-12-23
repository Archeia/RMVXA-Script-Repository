#--------------------------------------------------------------------------
# Custom Font Junk Symbol Fix
# Author(s):
# Lone Wolf
#--------------------------------------------------------------------------
# By default, the draw_text_ex method handles specific non-printable 
# characters, like line breaks, but does so in such a way as to leave 
# non-printable junk characters behind. While the normal font draws those 
# as blank spaces, any custom fonts used will render these junk characters 
# as character-not-found glyphs. This adds an extra step to character 
# processing to ensure that only printable characters are drawn to the screen.
#
#--------------------------------------------------------------------------

class Game_System
  def japanese?
    false
  end
end

class Window_Base
  alias :process_normal_character_vxa :process_normal_character
  def process_normal_character(c, pos)
	return unless c >= ' '
	process_normal_character_vxa(c, pos)
  end
end

