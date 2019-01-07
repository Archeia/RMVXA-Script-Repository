=begin
Keyboard Module
by Fomar0153
Version 1.0
----------------------
Notes
----------------------
Allows you test for keyboard input
----------------------
Instructions
----------------------
For a trigger (basically a click, holding a keydown will only trigger 
it once) use:
Keyboard.trigger?(Keyboard::VK_KEYA)

For a press (basically if the key is down) use:
Keyboard.press?(Keyboard::VK_KEYA)

For toggles (press once for on, press again for off) use:
Keyboard.toggle?(Keyboard::VK_KEYA)
----------------------
Known bugs
----------------------
None
=end
module Keyboard
  
  KEY_STATE = Win32API.new("user32", "GetKeyState", ["i"], "i")
  AKEY_STATE = Win32API.new("user32", "GetAsyncKeyState", ["i"], "i")
  
  # Key Codes found at:
  # http://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
  # Mouse buttons are physical
  VK_LBUTTON  = 0x01  # Left Mouse Button
  VK_RBUTTON  = 0x02  # Right Mouse Button
  VK_CANCEL   = 0x03  # Control-break processing
  VK_MBUTTON  = 0x04  # Middle mouse button (three-button mouse)
  VK_XBUTTON1 = 0x05  # X1 mouse button
  VK_XBUTTON2 = 0x06  # X2 mouse button
  VK_BACK     = 0x08  # BACKSPACE key
  VK_TAB      = 0x09  # TAB key
  VK_CLEAR    = 0x0C  # CLEAR key
  VK_RETURN   = 0x0D  # ENTER key
  VK_SHIFT    = 0x10  # SHIFT key
  VK_CONTROL  = 0x11  # CTRL key
  VK_MENU     = 0x12  # ALT key
  VK_PAUSE    = 0x13  # PAUSE key
  VK_CAPITAL  = 0x14  # CAPS LOCK key
  VK_ESCAPE   = 0x1B  # ESC key
  VK_SPACE    = 0x20  # SPACEBAR
  VK_PRIOR    = 0x21  # PAGE UP key
  VK_NEXT     = 0x22  # PAGE DOWN key
  VK_END      = 0x23  # END key
  VK_HOME     = 0x24  # HOME key
  VK_LEFT     = 0x25  # LEFT ARROW key
  VK_UP       = 0x26  # UP ARROW key
  VK_RIGHT    = 0x27  # RIGHT ARROW key
  VK_DOWN     = 0x28  # DOWN ARROW key
  VK_SELECT   = 0x29  # SELECT key
  VK_PRINT    = 0x2A  # PRINT key
  VK_EXECUTE  = 0x2B  # EXECUTE key
  VK_SNAPSHOT = 0x2C  # PRINT SCREEN key
  VK_INSERT   = 0x2D  # INS key
  VK_DELETE   = 0x2E  # DEL key
  VK_HELP     = 0x2F  # HELP key
  VK_NUMBERS0 = 0x30  # 0 key
  VK_NUMBERS1 = 0x31  # 1 key
  VK_NUMBERS2 = 0x32  # 2 key
  VK_NUMBERS3 = 0x33  # 3 key
  VK_NUMBERS4 = 0x34  # 4 key
  VK_NUMBERS5 = 0x35  # 5 key
  VK_NUMBERS6 = 0x36  # 6 key
  VK_NUMBERS7 = 0x37  # 7 key
  VK_NUMBERS8 = 0x38  # 8 key
  VK_NUMBERS9 = 0x39  # 9 key
  VK_KEYA     = 0x41  # A key
  VK_KEYB     = 0x42  # B key
  VK_KEYC     = 0x43  # C key
  VK_KEYD     = 0x44  # D key
  VK_KEYE     = 0x45  # E key
  VK_KEYF     = 0x46  # F key
  VK_KEYG     = 0x47  # G key
  VK_KEYH     = 0x48  # H key
  VK_KEYI     = 0x49  # I key
  VK_KEYJ     = 0x4A  # J key
  VK_KEYK     = 0x4B  # K key
  VK_KEYL     = 0x4C  # L key
  VK_KEYM     = 0x4D  # M key
  VK_KEYN     = 0x4E  # N key
  VK_KEYO     = 0x4F  # O key
  VK_KEYP     = 0x50  # P key
  VK_KEYQ     = 0x51  # Q key
  VK_KEYR     = 0x52  # R key
  VK_KEYS     = 0x53  # S key
  VK_KEYT     = 0x54  # T key
  VK_KEYU     = 0x55  # U key
  VK_KEYV     = 0x56  # V key
  VK_KEYW     = 0x57  # W key
  VK_KEYX     = 0x58  # X key
  VK_KEYY     = 0x59  # Y key
  VK_KEYZ     = 0x5A  # Z key
  
  def self.trigger?(key)
    if AKEY_STATE.call(key) != 0
      return true
    end
  end
  
  def self.press?(key)
    r = KEY_STATE.call(key)
    if r == -127 or r == -128
      return true
    end
  end
  
  # For things like caps lock
  def self.toggle?(key)
    if  KEY_STATE.call(key) == 1
      return true
    end
  end
end