=begin
Albhed Translator
by Fomar0153
Version 1.1
----------------------
Notes
----------------------
Adds an Albhed style language to your game.
----------------------
Instructions
----------------------
Follow the instructions in the Albhed module
turn your chosen switch on to have people speak
Albhed.
----------------------
Change Log
----------------------
1.0 -> 1.1 Added the ability to not translate sections
           of a message. Use { and } to keep part of the message untranslated.
           Added the ability to have the translated text appear in another 
           colour.
----------------------
Known bugs
----------------------
None
=end
module Albhed
  
  # Id of the switch to translate the text to Albhed
  ALBHED_SWITCH = 5
  ALBHED_COLOR = 16 # system color
  
  ALBHED_CHARS = {}
  # ALBHED_CHARS['letter'] = ['replacementletter', itemid to translate]
  ALBHED_CHARS['a'] = ['b', 1]
  ALBHED_CHARS['b'] = ['c', 1]
  ALBHED_CHARS['c'] = ['d', 1]
  ALBHED_CHARS['d'] = ['e', 1]
  ALBHED_CHARS['e'] = ['f', 1]
  ALBHED_CHARS['f'] = ['g', 1]
  ALBHED_CHARS['g'] = ['h', 1]
  ALBHED_CHARS['h'] = ['i', 1]
  ALBHED_CHARS['i'] = ['j', 1]
  ALBHED_CHARS['j'] = ['k', 1]
  ALBHED_CHARS['k'] = ['l', 1]
  ALBHED_CHARS['l'] = ['m', 1]
  ALBHED_CHARS['m'] = ['n', 1]
  ALBHED_CHARS['n'] = ['o', 1]
  ALBHED_CHARS['o'] = ['p', 1]
  ALBHED_CHARS['p'] = ['q', 1]
  ALBHED_CHARS['q'] = ['r', 1]
  ALBHED_CHARS['r'] = ['s', 1]
  ALBHED_CHARS['s'] = ['t', 1]
  ALBHED_CHARS['t'] = ['u', 1]
  ALBHED_CHARS['u'] = ['v', 1]
  ALBHED_CHARS['v'] = ['w', 1]
  ALBHED_CHARS['w'] = ['x', 1]
  ALBHED_CHARS['x'] = ['y', 1]
  ALBHED_CHARS['y'] = ['z', 1]
  ALBHED_CHARS['z'] = ['a', 1]
  
  def self.translate(c)
    return c if ALBHED_CHARS[c.downcase].nil?
    return c if $game_party.has_item?($data_items[ALBHED_CHARS[c.downcase][1]])
    return ALBHED_CHARS[c.downcase][0].downcase if c.downcase!.nil?
    return ALBHED_CHARS[c.downcase][0].upcase
  end
  
end

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● 通常文字の処理
  #--------------------------------------------------------------------------
  alias albhed_process_normal_character process_normal_character
  def process_normal_character(c, pos)
    if @trans.nil?
      @trans = true
    end
    return albhed_process_normal_character(c, pos) unless $game_switches[Albhed::ALBHED_SWITCH]
    if c == "{"
      @trans = false
      return
    end
    if c == "}"
      @trans = true
      return
    end
    c = Albhed.translate(c) if @trans
    change_color(text_color(Albhed::ALBHED_COLOR)) if @trans
    text_width = text_size(c).width
    draw_text(pos[:x], pos[:y], text_width * 2, pos[:height], c)
    change_color(normal_color)
    pos[:x] += text_width
  end
end