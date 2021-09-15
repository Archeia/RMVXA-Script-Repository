$simport.r('iek/win32api/mouse/buttons', '1.0.0', 'Mouse Buttons module')

module Win32
  class Mouse
  ##
  # A list of the mouse related VK_* key codes from the Windows library
  #   http://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
    module Buttons
      BUTTONS = []

      ###
      #NULL                      = 0x00 # <NULL>
      LBUTTON                   = 0x01 # Left mouse button
      RBUTTON                   = 0x02 # Right mouse button
      #CANCEL                    = 0x03 # Control-break processing
      MBUTTON                   = 0x04 # Middle mouse button (three-button mouse)
      XBUTTON1                  = 0x05 # X1 mouse button
      XBUTTON2                  = 0x06 # X2 mouse button

      constants.each do |k|
        BUTTONS << [k, const_get(k)]
      end
      BUTTONS.freeze

      extend Enumerable

      def self.each
        return to_enum(:each) unless block_given?
        BUTTONS.each do |k, v|
          yield k, v
        end
      end
    end
  end
end
