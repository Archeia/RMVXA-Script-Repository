#encoding:UTF-8
# ISS032 - Mouse
module ISS
  module Mouse
  end
end

module ISS::Mouse

  GKAS = Win32API.new("user32", "GetAsyncKeyState", "i", "i")
  GKS  = Win32API.new("user32", "GetKeyState", "i", "i")
  GCP  = Win32API.new("user32", "GetCursorPos", "p", "i")
  STC  = Win32API.new("user32", "ScreenToClient", "lp", "i")
  GCR  = Win32API.new("user32", "GetClientRect", "lp", "i")
  FW   = Win32API.new("user32", "FindWindowA", "pp", "l")
  GPS  = Win32API.new("kernel32", "GetPrivateProfileStringA", "pppplp", "l")

  @@client = nil

  game_name = "\0" * 256
  GPS.call('Game',' Title', '', game_name, 255, ".\\Game.ini")
  game_name.delete!("\0")
  @@client = FW.call('RGSS Player', game_name)

  def self.global_pos()
    pos = [0, 0].pack('ll')
    return (GCP.call(pos) != 0 ? pos.unpack('ll') : nil)
  end

  def self.pos()
    x, y = self.screen_to_client(*self.global_pos)
    width, height = *self.client_size
    unless x.nil?() || y.nil?()
      return x, y if x.between?(0, width ) && y.between?( 0, height)
    end
    return -32, -32
  end

  def self.screen_to_client(x, y)
    return nil unless (x and y)
    pos = [x, y].pack('ll')
    return (STC.call(hwnd, pos) != 0 ? pos.unpack('ll') : nil)
  end

  def self.hwnd()
    return @@client
  end

  def self.client_size()
    rect = [0, 0, 0, 0].pack('l4') ; GCR.call(hwnd, rect)
    return rect.unpack('l4')[2..3]
  end

  def self.left_click?()
    return GKAS.call(0x01) & 0x01 == 0x01
  end

  def self.right_click?()
    return GKAS.call(0x02) & 0x01 == 0x01
  end

  def self.middle_click?()
    return GKAS.call(0x04) & 0x01 == 0x01
  end

  def self.left_press?()
    return GKAS.call(0x01).abs & 0x8000 == 0x8000
  end

  def self.right_press?()
    return GKAS.call(0x02).abs & 0x8000 == 0x8000
  end

  def self.middle_press?()
    return GKAS.call(0x04).abs & 0x8000 == 0x8000
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
