$simport.r 'iek/win32api/mouse', '1.0.0', 'Win32 Mouse module'  do |h|
  h.depend! 'iek/win32api/mouse/buttons', '~> 1.0.0'
  h.depend! 'iek/win32api/win32/user32', '~> 1.0.0'
end

##
# Windows compliant Mouse class for RPG Maker VX Ace
# Provides a bare minimal API
module Win32
  class Mouse
    class Point2
      def initialize(x = 0, y = 0)
        @x = x
        @y = y
      end

      def set(x, y)
        @x = x
        @y = y
      end
    end

    ##
    # Defines a Hash with all mouse VK_* key codes by lower cased Symbol(s)
    # [Hash<Symbol, Integer>] SYMBOL_TO_KEY
    SYMBOL_TO_KEY = {
      LBUTTON: Mouse::Buttons::LBUTTON,
      RBUTTON: Mouse::Buttons::RBUTTON,
      MBUTTON: Mouse::Buttons::MBUTTON,
      XBUTTON1: Mouse::Buttons::XBUTTON1,
      XBUTTON2: Mouse::Buttons::XBUTTON2
    }.freeze

    ##
    # Initialize Mouse module
    def initialize
      @user32 = Win32::User32.new
      @button_state = Array.new(7, false)
      @screen_point = Point2.new(-1, -1)
      @client_point = Point2.new(-1, -1)
    end

    ##
    # @return [Integer] Mouse x position in client
    def x
      @client_point.x
    end

    ##
    # @return [Integer] Mouse y position in client
    def y
      @client_point.y
    end

    ##
    # Converts given obj to a valid VK key code
    # @overload convert_button(str)
    #   @param [String, Symbol] str Name of key
    #   @raise [KeyError] in case that the key cannot be found
    # @overload convert_button(key_id)
    #   @param [Integer] key_id VK_* code
    # @return [Integer]
    def convert_button(obj)
      case obj
      when String, Symbol then return SYMBOL_TO_KEY.fetch(obj.to_sym)
      when Integer        then return obj
      else                     raise TypeError, "wrong argument type #{obj.class} (expected String, Symbol or Integer)"
      end
    end
    private :convert_button

    ##
    # Checks whether or not the button was pressed?
    # @param [String, Symbol, Integer] obj
    # @return [Boolean]
    def press?(obj)
      button = convert_button(obj)
      return @button_state[button]
    end

    ##
    # Updates the Mouse @button_state Array
    # Due to some quirks in Windows, we can get the Mouse button states from the
    # Keyboard module
    # @return [Void]
    def update_button_state
      @button_state[Mouse::Buttons::LBUTTON] = Keyboard.press?(Mouse::Buttons::LBUTTON)
      @button_state[Mouse::Buttons::RBUTTON] = Keyboard.press?(Mouse::Buttons::RBUTTON)
      @button_state[Mouse::Buttons::MBUTTON] = Keyboard.press?(Mouse::Buttons::MBUTTON)
    end
    private :update_button_state

    ##
    # Updates the Mouse @*_point(s)
    # @return [Void]
    def update_points
      pos = [0, 0].pack('l2')
      if @user32.get_cursor_pos(pos) > 0
        @screen_point.set(*pos.unpack('l2'))
      end
      pos = [@screen_point.x, @screen_point.y].pack('l2')
      if @user32.screen_to_client(Win32::Input.client_id, pos)
        @client_point.set(*pos.unpack('l2'))
      end
    end
    private :update_points

    ##
    # Mouse update function
    # @return [Void]
    def update
      update_button_state
      update_points
    end
  end
end
