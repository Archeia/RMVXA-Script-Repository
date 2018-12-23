#========================================================================
# ** Word Wrapping Message Boxes, by: KilloZapit
#------------------------------------------------------------------------
# Changes message boxes so it will automatically wrap long lines.
#
# Note: I consider this script to be public domain, and put no
# restrictions on it's use whatsoever. My only request is that
# a link back to the script is provided so more people can
# access it if they want to.
#
# Version the Second:
#   Now strips color codes and icon codes so they don't break words.
#   Also calculates icon width along with text width for words.
# Version the Third:
#   Now also strips delays and other timing related codes.
#   Splits for non-icon control codes before counting icons.
#   Control codes can now break lines in case of font changes.
#   Added some comments to clarify some code.
# Version the Forth:
#   Fixed a small bug that might cause a error when counting icons.
#   Added a small notice for copyright questions.
# Version the Fifth:
#   Added "collapse" mode, which elimanates extra spaces.
#   Can now use "whitespace" mode outside of wordwrap mode if needed.
# Version the Sixth:
#   Fixed problems with collapsed whitespace not wraping words right.
# Version the Seventh:
#   Added option to add a margin to the right hand side of the window.
#------------------------------------------------------------------------
# Also adds the following new escape sequences:
#
# \ww  - Word Wrap: turns word wrap on if it's off
# \nw  - No Wrap: Turns word wrap off
# \ws  - WhiteSpace mode: Converts newlines to spaces (like HTML)
# \nl  - New Line: Preserves hard returns
# \cs  - Collapse whiteSpace: Eliminates extra spaces (also like HTML)
# \pre - PRE-formatted: Preserves spaces
# \br  - line BRake: manual newline for whitespace mode
# \rm  - Right Margin: extra space on the right side of the window
#========================================================================

# Standard config module.
module KZIsAwesome
  module WordWrap

    # change this if you don't want wordwrap on by default.
    DEFAULT_WORDWRAP = true

    # change this if you want white space mode on by default.
    DEFAULT_WHITESPACE = false
   
    # change this if you want white space mode on by default.
    DEFAULT_COLLAPSE = true
    
    # change this to add a right margin to the window.
    DEFAULT_RIGHT_MARGIN = 0

  end
end

class Window_Base < Window
  include KZIsAwesome::WordWrap

  alias_method :initialize_kz_window_base, :initialize
  def initialize(x, y, width, height)
    initialize_kz_window_base(x, y, width, height)
    @wordwrap = DEFAULT_WORDWRAP
    @convert_newlines = DEFAULT_WHITESPACE
    @collapse_whitespace = DEFAULT_COLLAPSE
    @right_margin = DEFAULT_RIGHT_MARGIN
    @lastc = "\n"
  end

  alias_method :process_character_kz_window_base, :process_character
  def process_character(c, text, pos)
    c = ' ' if @convert_newlines && c == "\n"
    if @wordwrap && c =~ /[ \t]/
      c = '' if @collapse_whitespace && @lastc =~ /[\s\n\f]/
      if pos[:x] + get_next_word_size(c, text) > contents.width - @right_margin
        process_new_line(text, pos)
      else
        process_normal_character(c, pos)
      end
      @lastc = c
    else
      @lastc = c
      process_character_kz_window_base(c, text, pos)
    end
  end

  def get_next_word_size(c, text)
    # Split text by the next space/line/page and grab the first split
    nextword = text.split(/[\s\n\f]/, 2)[0]
    if nextword
      icons = 0
      if nextword =~ /\e/i
        # Get rid of color codes and YEA Message system outline colors
        nextword = nextword.split(/\e[oOcC]+\[\d*\]/).join
        # Get rid of message timing control codes
        nextword = nextword.split(/\e[\.\|\^<>!]/).join
        # Split text by the first non-icon escape code
        # (the hH is for compatibility with the Icon Hues script)
        nextword = nextword.split(/\e[^iIhH]+/, 2)[0]
        # Erase and count icons in remaining text
        nextword.gsub!(/\e[iIhH]+\[[\d,]*\]/) do
          icons += 1
          ''
        end if nextword
      end
      wordsize = (nextword ? text_size(c + nextword).width : text_size( c ).width)
      wordsize += icons * 24
    else
      wordsize = text_size( c ).width
    end
    return wordsize
  end

  alias_method :process_escape_character_kz_window_base, :process_escape_character
  def process_escape_character(code, text, pos)
    case code.upcase
    when 'WW'
      @wordwrap = true
    when 'NW'
      @wordwrap = false
    when 'WS'
      @convert_newlines = true
    when 'NL'
      @convert_newlines = false
    when 'CS'
      @collapse_whitespace = true
    when 'PRE'
      @collapse_whitespace = false
    when 'BR'
      process_new_line(text, pos)
      @lastc = "\n"
    when 'RM'
      @right_margin = obtain_escape_param(text)
    else
      process_escape_character_kz_window_base(code, text, pos)
    end
    # Recalculate the next word size and insert line breaks
    # (Needed primarily for font changes)
    if pos[:x] + get_next_word_size('', text) > contents.width
      process_new_line(text, pos)
    end
  end

end