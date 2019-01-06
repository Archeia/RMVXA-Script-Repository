#Vlue's Rudimentary Text Wrap. Whee

$useTextWrap = true

class Window_Base
  alias :draw_text_ex_wrap :draw_text_ex
  def draw_text_ex(x, y, text)
    if $useTextWrap
      reset_font_settings
      text = convert_escape_characters(text)
      pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
      words = text.split
      words.each {|word| process_word(text,word,pos)}
    else
      draw_text_ex_wrap(x, y, text)
    end
  end
  def process_word(text, word, pos)
    text_width = text_size(word).width
    index = text.index(word) + word.size + 1
    process_new_line(text, pos) if pos[:x] + text_width > contents.width
    process_character(word.slice!(0,1), word, pos) until word.empty?
    process_character(' ',' ',pos)
  end
  alias cec_tw convert_escape_characters
  def convert_escape_characters(text)
    result = cec_tw(text)
    result.gsub!("\n") { "¶" }
    result
  end
  alias pc_tw process_character
  def process_character(c, text, pos)
    c == "¶" ? process_new_line(text, pos) : pc_tw(c,text,pos)
  end
end

class Window_Message
  alias :process_all_text_wrap :process_all_text
  def process_all_text
    if $useTextWrap
      open_and_wait
      text = convert_escape_characters($game_message.all_text)
      pos = {}
      new_page(text, pos)
      words = text.split
      words.each {|word| process_word(text, word, pos) }
    else
      process_all_text_wrap
    end
  end
end