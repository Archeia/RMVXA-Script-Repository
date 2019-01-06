#Special Keybinds v1.4a
#----------#
#Features: A way to use almost any key on your keyboard to toggle switches,
#           add to variables, or call scenes! Doesn't that sound just neat!
#
#Usage:   Press the set up keybind!
#        
#Customization: Add to the KI_KEYBINDS hash as needed!
#                Details below!
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
#This is where you set up your keybinds. It goes either:
# Key symbol => [cond, :scene, scene_name],
# Key Symbol => [cond, :var, var_id, amount],
# Key Symbol => [cond, :switch, switch_id],
# Key Symbol => [cond, :script, "script call"],
#
# Cond (condition) is either :press or :trigger. :press is continuous while
#  :trigger runs once per key press.
#
# Key Symbols are the names of the key, from A-Z, N0-N9, or many of the
# named keys! They are listed as symbols below for semi-easy reference!
#
#Adding and removing keybinds while in game with simple script calls:
#  $ki_keybinds.delete(symbol)
#  $ki_keybinds[symbol] = [keybind setup (see above)]
#Symbol is any Key Symbol as listed under Input below
 
$ki_keybinds= { :N1 => [:trigger, :scene, Scene_Title],
                :N2 => [:trigger, :var, 1, 5],
                :N3 => [:trigger, :switch, 1],
                :N4 => [:trigger, :script, "$game_party.gain_gold(1000)"],
                :W => [:press, :script, "$game_player.move_by_int(8)",nil,1],
                :A => [:press, :script, "$game_player.move_by_int(4)",nil,1],
                :S => [:press, :script, "$game_player.move_by_int(2)",nil,1],
                :D => [:press, :script, "$game_player.move_by_int(6)",nil,1],
                }
 
module Keyboard_Input
 
  ASKS = Win32API.new 'user32', 'GetAsyncKeyState', ['p'], 'i'
 
  INPUT = { :backspace => 0x08, :tab => 0x09, :enter => 0x0D, :shift => 0x10,
            :ctrl => 0x11, :alt => 0x12, :pause => 0x13, :caps => 0x14,
            :escape => 0x1B, :space => 0x20, :pageup => 0x21, :pagedown => 0x22,
            :end => 0x23, :home => 0x24, :left => 0x25, :up => 0x26,
            :right => 0x27, :down => 0x28, :print => 0x2C, :insert => 0x2D,
            :delete => 0x2E,
           
            :N0 => 0x30, :N1 => 0x31, :N2 => 0x32, :N3 => 0x33,
            :N4 => 0x34, :N5 => 0x35, :N6 => 0x36, :N7 => 0x37, :N8 => 0x38,
            :N9 => 0x39,
           
            :A => 0x41, :B => 0x42, :C => 0x43, :D => 0x44, :E => 0x45, :F => 0x46,
            :G => 0x47, :H => 0x48, :I => 0x49, :J => 0x4A, :K => 0x4B, :L => 0x4C,
            :M => 0x4D, :N => 0x4E, :O => 0x4F, :P => 0x50, :Q => 0x51, :R => 0x52,
            :S => 0x53, :T => 0x54, :U => 0x55, :V => 0x56, :W => 0x57, :X => 0x58,
            :Y => 0x59, :Z => 0x5A,
           
            :F1 => 0x70, :F2 => 0x71, :F3 => 0x72,
            :F4 => 0x73, :F5 => 0x74, :F6 => 0x75, :F7 => 0x76, :F8 => 0x77,
            :F9 => 0x78, :F10 => 0x79, :F11 => 0x7A, :F12 => 0x7B,
           
            :num => 0x90,
            :scroll => 0x91, :lshift => 0xA0, :rshift => 0xA1, :lctrl => 0xA2,
            :rctrl => 0xA3, :lalt => 0xA4, :ralt => 0xA5, :colon => 0xBa,
            :plus => 0xBB, :comma => 0xBC, :minus => 0xBD, :period => 0xBE,
            :slash => 0xBF, :tilde => 0xC0, :lbrace => 0xDB, :backslash => 0xDC,
            :rbrace => 0xDD, :quote => 0xDE  }
           
  def self.press?(symbol, delay = 30)
    return unless @delay == 0 or @delay.nil?
    return false if ASKS.call(INPUT[symbol]) == 0
    @delay = delay
    return true
  end
  def self.trigger?(symbol)
    return unless @pressed
    return false if @pressed[symbol]
    return false if ASKS.call(INPUT[symbol]) == 0
    @pressed[symbol] = true
    return true
  end
  def self.update
    setup unless @pressed
    @pressed.each do |key, val|
      @pressed[key] = ASKS.call(INPUT[key]) != 0
    end
    return if @delay == 0
    @delay -= 1 unless @delay.nil?
  end
  def self.setup
    @pressed = {}
  end
end
 
class Scene_Base
  alias cekb_update update
  def update
    cekb_update
    cekb_input_update
    Keyboard_Input.update
  end
  def cekb_input_update
    $ki_keybinds.each {|key, value|
      if value[0] == :press
        next unless Keyboard_Input.press?(key, value[4] ? value[4] : 30)
      elsif value[0] == :trigger
        next unless Keyboard_Input.trigger?(key)
      end
      next unless self.is_a?(Scene_Map)
      next if $game_map.interpreter.running?
      SceneManager.call(value[2]) if value[1] == :scene
      $game_variables[value[2]] += value[3] if value[1] == :var
      if value[1] == :switch
        id = value[2]
        switch = $game_switches[value[2]]
        switch == false ? $game_switches[id] = true : $game_switches[id] = false
      end
      eval(value[2]) if value[1] == :script
    }
  end
end
 
class Game_Player
  def move_by_int(dir)
    return if !movable? || $game_map.interpreter.running?
    move_straight(dir) if dir > 0
  end
end