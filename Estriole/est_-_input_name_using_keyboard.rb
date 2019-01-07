=begin
EST - NAME INPUT USING KEYBOARD
v.1.0

Requires:
Neon Black Keyboard Input 1.0a
http://forums.rpgmakerweb.com/index.php?/topic/3456-developer-console/#entry37268
enter the link to his keyboard module script there.
or
http://pastebin.com/raw.php?i=rD4rQtKP
for direct link to his pastebin.

version history
v.1.0 - 2013.02.15 - finish the script

Introduction:
Have you ever feel it's not comfortable to input name by choosing which symbol 
then press enter. letter by letter. so time consuming.

this script change that!. instead of choosing symbol and press enter. 
you type letter directly from keyboard.

press esc / backspace to erase a character
press enter when you're done. maybe will put confirmation window later.

btw the name input window still there. i just hide it from view and change
some behavior. :D.

Usage
Plug and Play

Compatibility
it should compatible with most script. 
If you using Tsukihime Simple Text Input.
put this script ABOVE that script. so the script will also use KEYBOARD :D.
since the script is using name input window too.

=end
module ESTRIOLE
  module KEYBOARD_PRESS
    KEYBOARDPRESS = {
      :k0 => 48, :k1 => 49, :k2 => 50, :k3 => 51, :k4 => 52, :k5 => 53,
      :k6 => 54, :k7 => 55, :k8 => 56, :k9 => 57,
          
      :kA => 65, :kB => 66, :kC => 67, :kD => 68, :kE => 69, :kF => 70,
      :kG => 71, :kH => 72, :kI => 73, :kJ => 74, :kK => 75, :kL => 76,
      :kM => 77, :kN => 78, :kO => 79, :kP => 80, :kQ => 81, :kR => 82,
      :kS => 83, :kT => 84, :kU => 85, :kV => 86, :kW => 87, :kX => 88,
      :kY => 89, :kZ => 90,
          
      :kCOLON => 186,     :kQUOTE => 222,
      :kCOMMA => 188,     :kPERIOD => 190,     :kSLASH => 191,
      :kBACKSLASH => 220, :kLEFTBRACE => 219,  :kRIGHTBRACE => 221,
      :kMINUS => 189,     :kEQUAL => 187,     :kTILDE => 192,          
    }
  end
end

class Window_NameInput < Window_Selectable
  include ESTRIOLE::KEYBOARD_PRESS
  alias est_keyboard_name_input_init initialize
  def initialize(edit_window)
    est_keyboard_name_input_init(edit_window)
    self.visible = false
  end

  def process_handling
    return unless open? && active
    process_back if Input.repeat?(:kESC) or Input.repeat?(:kBACKSPACE)
    check_keyboard_input
  end
  alias cursor_page_change cursor_pagedown
  def check_keyboard_input
    KEYBOARDPRESS.each {|key|
    @edit_window.add(Keyboard.add_char(Ascii::SYM[key[0]])) if Input.trigger?(key[0])
    Sound.play_ok if Input.trigger?(key[0])
    }
    check_spaces
    check_enter
  end
  def check_spaces
    if Input.trigger?(:kSPACE)
    @edit_window.add(" ")
    Sound.play_ok
    end
  end
  def check_enter
    on_name_ok if Input.trigger?(:kENTER)
  end
  def cursor_pageup;end
  def cursor_pagedown;end
end