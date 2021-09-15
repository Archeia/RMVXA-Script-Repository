class Window_Base
  def process_character(c, text, pos)
    case c
    when "\r"   # Return
      # and we should care about returns because?
    when "\n"   # New line
      process_new_line(text, pos)
    when "\f"   # New page
      process_new_page(text, pos)
    when "\e"   # Control character
      process_escape_character(obtain_escape_code(text), text, pos)
    else        # Normal character
      process_normal_character(c, pos)
    end
  end
end
