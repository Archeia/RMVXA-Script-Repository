#encoding:UTF-8
# ISS018 - Input 1.1
#==============================================================================#
# ** ISS - Input
#==============================================================================#
# ** Date Created  : 08/10/2011
# ** Date Modified : 10/04/2011
# ** Created By    : IceDragon
# ** Special Thanks: CaptainJet (Jet) (For helping me with the Win32API)
# ** For Game      : ISTS
# ** ID            : 018
# ** Version       : 1.1
# ** Optional      : ISS000 - Core 1.9 (or above)
#==============================================================================#
($imported ||= {})["ISS-Input"] = true
#==============================================================================#
# ** ISS
#==============================================================================#
module ISS
  install_script(18, :system, :input) if $simport.valid?('iss/core', '>= 1.9')
end

#==============================================================================#
# ** ISS::Input
#==============================================================================#
module ISS::Input ; end
#==============================================================================#
# ** ISS::Input::KEYS_MIX (MixIn) 1
#==============================================================================#
module ISS::Input::KEYS_MIX

  #--------------------------------------------------------------------------#
  # * Constant(s)
  #--------------------------------------------------------------------------#
  # // Win32API functions
  GKAS = Win32API.new("user32", "GetAsyncKeyState", "i", "i")
  GKS  = Win32API.new("user32", "GetKeyState", "i", "i")
  KBDE = Win32API.new("user32", 'keybd_event', ["i", "i", "l", "l"], "v")
  SNDI = Win32API.new("user32", "SendInput", ["I","P","I"], "i")

  # // Key Codes
  LETTERS = {}
  LETTERS['A'] = 0x41 ; LETTERS['B'] = 0x42 ; LETTERS['C'] = 0x43
  LETTERS['D'] = 0x44 ; LETTERS['E'] = 0x45 ; LETTERS['F'] = 0x46
  LETTERS['G'] = 0x47 ; LETTERS['H'] = 0x48 ; LETTERS['I'] = 0x49
  LETTERS['J'] = 0x4A ; LETTERS['K'] = 0x4B ; LETTERS['L'] = 0x4C
  LETTERS['M'] = 0x4D ; LETTERS['N'] = 0x4E ; LETTERS['O'] = 0x4F
  LETTERS['P'] = 0x50 ; LETTERS['Q'] = 0x51 ; LETTERS['R'] = 0x52
  LETTERS['S'] = 0x53 ; LETTERS['T'] = 0x54 ; LETTERS['U'] = 0x55
  LETTERS['V'] = 0x56 ; LETTERS['W'] = 0x57 ; LETTERS['X'] = 0x58
  LETTERS['Y'] = 0x59 ; LETTERS['Z'] = 0x5A

  NUMBERS = []
  NUMBERS[0] = 0x30 ; NUMBERS[1] = 0x31 ; NUMBERS[2] = 0x32 ; NUMBERS[3] = 0x33
  NUMBERS[4] = 0x34 ; NUMBERS[5] = 0x35 ; NUMBERS[6] = 0x36 ; NUMBERS[7] = 0x37
  NUMBERS[8] = 0x38 ; NUMBERS[9] = 0x39

  NUMPAD = []
  NUMPAD[0] = 0x60 ; NUMPAD[1] = 0x61 ; NUMPAD[2] = 0x62 ; NUMPAD[3] = 0x63
  NUMPAD[4] = 0x64 ; NUMPAD[5] = 0x65 ; NUMPAD[6] = 0x66 ; NUMPAD[7] = 0x67
  NUMPAD[8] = 0x68 ; NUMPAD[9] = 0x69

  NPAD_MULT = 0x6A ; NPAD_ADD  = 0x6B ; NPAD_SEP  = 0x6C ; NPAD_SUB  = 0x6D
  NPAD_DECI = 0x6E ; NPAD_DIV  = 0x6F

  F1 = 0x70 ; F2 = 0x71 ; F3 = 0x72 ; F4 = 0x73 ; F5 = 0x74 ; F6 = 0x75
  F7 = 0x76 ; F8 = 0x77 ; F9 = 0x78 ; F10 = 0x79 ; F11 = 0x7A ; F12 = 0x7B

  LEFT = 0x25 ; UP = 0x26 ; RIGHT = 0x27 ; DOWN = 0x28

  BACKSPACE = 0x08 ; TAB       = 0x09
  ENTER     = 0x0D
  SHIFT     = 0x10 ; CTRL      = 0x11 ; ALT       = 0x12
  LSHIFT    = 0xA0 ; LCTRL     = 0xA2 ; LALT      = 0xA4
  RSHIFT    = 0xA1 ; RCTRL     = 0xA3 ; RALT      = 0xA5
  ESCAPE    = 0x1B
  SPACEBAR  = 0x20 ; PAGEUP    = 0x21 ; PAGEDOWN  = 0x22 ; KEND = 0x23
  HOME      = 0x24 ;

  INSERT = 0x2D ; DELETE = 0x2E

  CAPLOCK    = 0x14
  NUMLOCK    = 0x90 ; SCROLLLOCK = 0x91

  SEMICOLON = COLON      = 0xBA
  PLUS      = EQUAL      = 0xBB
  COMMA     = ALEFT      = 0xBC
  MINUS     = UNDERSCORE = 0xBD
  PERIOD    = ARIGHT     = 0xBE
  BACKSLASH = QUESTION   = 0xBF
  TILDE     = ACCENT     = 0xC0
  LBRACE    = LBRACK     = 0xDB
  FSLASH    = SEPERATOR  = 0xDC
  RBRACE    = RBRACK     = 0xDD
  QUOTE     = DQUOTE     = 0xDE

  # // Key Sequences used with the key_sequence method
  KEY_SEQUENCES = {}
  KEY_SEQUENCES["FULLSCREEN"] = [ [ALT, 0], [ENTER, 0], [ENTER, 2], [ALT, 2] ]

  #--------------------------------------------------------------------------#
  # * Class Variable(s)
  #--------------------------------------------------------------------------#
  @@krc  = {} # // Key Repeat Counter
  @@kcl  = {} # // Key Cooling (used to fix trigger errors)

end

#==============================================================================#
# ** ISS::Input (MixIn)
#==============================================================================#
module ISS::Input

  #--------------------------------------------------------------------------#
  # * MixIn(s)
  #--------------------------------------------------------------------------#
  include ISS::Input::KEYS_MIX

  #--------------------------------------------------------------------------#
  # * new-method :key_pressed?
  #--------------------------------------------------------------------------#
  def key_pressed?(key)
    if GKAS.call(key).abs == 0x8000 ; @@krc[key] = 0 ; return true ; end
    return false
  end

  #--------------------------------------------------------------------------#
  # * new-method :adjust_key
  #--------------------------------------------------------------------------#
  def adjust_key(key)
    key -= 130 if key.between?(130, 158) ; return key
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_key_state
  #--------------------------------------------------------------------------#
  def set_key_state(key, state ) ; KBDE.call( key, 0, state, 0) ; end

  #--------------------------------------------------------------------------#
  # * new-method :send_key (still buggy)
  #--------------------------------------------------------------------------#
  def send_key(key, state)
    # // 0 - Mouse, 1 - Keyboard
    # // 0x0001 - Extended, 0x0002 - KeyUp, 0x0008 - ScanCode, 0x0004 - Unicode
    SNDI.call(1, [0, 0, 2, 0, 0].pack("LLLLL"), 256) #0x0002 # // Still Buggy
  end

  #--------------------------------------------------------------------------#
  # * new-method :correct_keys
  #--------------------------------------------------------------------------#
  def correct_keys(keys) ; return keys ; end#.flatten() ; end

  #--------------------------------------------------------------------------#
  # * new-method :key_sequence
  #--------------------------------------------------------------------------#
  def key_sequence(name)
    KEY_SEQUENCES[name].each { |a| set_key_state(*a) }
  end

  #--------------------------------------------------------------------------#
  # * new-method :repeating_update
  #--------------------------------------------------------------------------#
  def repeating_update()
    @@krc.keys.each { |key|
      if GKAS.call(key).abs == 0x8000
        @@krc[key] += 1 ; @@kcl[key] = 1
      else
        #@@krc.delete(key)
        if @@kcl[key] == 0
          @@krc.delete(key ) ; @@kcl.delete( key)
        else
          @@kcl[key] -= 1 if @@kcl.has_key?(key)
        end
      end
    }
  end

  #--------------------------------------------------------------------------#
  # * new-method :num_lock?
  #--------------------------------------------------------------------------#
  def num_lock?()    ; return GKS.call(NUM_LOCK   ) == 0x01 ; end

  #--------------------------------------------------------------------------#
  # * new-method :caps_lock?
  #--------------------------------------------------------------------------#
  def caps_lock?()   ; return GKS.call(CAPS_LOCK  ) == 0x01 ; end

  #--------------------------------------------------------------------------#
  # * new-method :scroll_lock?
  #--------------------------------------------------------------------------#
  def scroll_lock?() ; return GKS.call(SCROLL_LOCK) == 0x01 ; end

end

#==============================================================================#
# ** Input
#==============================================================================#
module Input

  #--------------------------------------------------------------------------#
  # * MixIn(s)
  #--------------------------------------------------------------------------#
  include ISS::Input

  #--------------------------------------------------------------------------#
  # * alias-methods
  #--------------------------------------------------------------------------#
  class << self
    include ISS::Input
    alias :iss018_input_trigger? :trigger? unless $@
    alias :iss018_input_press? :press? unless $@
    alias :iss018_input_repeat? :repeat? unless $@
    alias :iss018_input_update :update unless $@
  end

  #--------------------------------------------------------------------------#
  # * alias-method :trigger?
  #--------------------------------------------------------------------------#
  def self.trigger?(*keys)
    return correct_keys(keys).any? { |key|
      if key < 30
        res = iss018_input_trigger?(key)
      else
        adjk = adjust_key(key)
        count = @@krc[adjk]
        res = ((count == 0) || (count.nil?() ? key_pressed?(adjk ) : false))
      end
      res
    }
  end

  #--------------------------------------------------------------------------#
  # * new-method :all_trigger?
  #--------------------------------------------------------------------------#
  def self.all_trigger?(*keys)
    return correct_keys(keys).all? { |key|
      if key < 30
        res = iss018_input_trigger?(key)
      else
        adjk = adjust_key(key)
        count = @@krc[adjk]
        res = ((count == 0) || (count.nil?() ? key_pressed?(adjk ) : false))
      end
      res
    }
  end

  #--------------------------------------------------------------------------#
  # * alias-method :repeat?
  #--------------------------------------------------------------------------#
  def self.repeat?(*keys)
    return correct_keys(keys).any? { |key|
      if key < 30
        res = iss018_input_repeat?(key)
      else
        adjk = adjust_key(key)
        count = @@krc[adjk]
        if count == 0
          res = true
        else
          if count.nil?()
            res = key_pressed?(adjk)
          else
            res = (count >= 23 and (count - 23) % 6 == 0)
          end
        end
      end
      res
    }
  end

  #--------------------------------------------------------------------------#
  # * new-method :all_repeat?
  #--------------------------------------------------------------------------#
  def self.all_repeat?(*keys)
    return correct_keys(keys).all? { |key|
      if key < 30
        res = iss017_input_repeat?(key)
      else
        adjk = adjust_key(key)
        count = @@krc[adjk]
        if count == 0
          res = true
        else
          if count.nil?()
            res = key_pressed?(adjk)
          else
            res = (count >= 23 and (count - 23) % 6 == 0)
          end
        end
      end
      res
    }
  end

  #--------------------------------------------------------------------------#
  # * alias-method :press?
  #--------------------------------------------------------------------------#
  def self.press?(*keys)
    return correct_keys(keys).any? { |key|
      if key < 30
        res = iss018_input_press?(key)
      else
        adjk = adjust_key(key)
        res = @@krc[adjk].nil?() ? key_pressed?(adjk) : true
      end
      res
    }
  end

  #--------------------------------------------------------------------------#
  # * new-method :all_press?
  #--------------------------------------------------------------------------#
  def self.all_press?(*keys)
    return correct_keys(keys).all? { |key|
      if key < 30
        res = iss018_input_press?(key)
      else
        adjk = adjust_key(key)
        res = @@krc[adjk].nil?() ? key_pressed?(adjk) : true
      end
      res
    }
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  def self.update(*args, &block)
    iss018_input_update(*args, &block)
    repeating_update()
  end

end

#loop do
#  Graphics.update
#  Input.update
#  if Input.trigger?(Input::UP)
#    puts "UP"
#end
#end
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
