$simport.r 'iek/win32api/keyboard', '1.0.0', 'Win32 Keyboard module' do |h|
  h.depend! 'iek/win32api/keyboard/keys', '~> 1.0.0'
  h.depend! 'iek/win32api/win32/user32', '~> 1.0.0'
end

# Windows compliant Keyboard class for RPG Maker VX Ace
# Provides a bare minimal API
module Win32
  class Keyboard
    # Defines a Hash with all the VK_* key codes by lower cased Symbol(s)
    # [Hash<Symbol, Integer>] SYMBOL_TO_KEY
    SYMBOL_TO_KEY = Hash[Keyboard::Keys.map { |k, v| [k.to_s.to_sym, v] }].freeze

    # Initialize Keyboard module
    def initialize
      @user32 = Win32::User32.new
      clear_buffer
      @key_state = Array.new(256, false)
    end

    # Clears the internal byte buffer
    #
    # @return [self]
    private def clear_buffer
      @byte_array = "\0" * 256
      self
    end

    # Converts given obj to a valid VK key code
    #
    # @overload convert_key(str)
    #   @param [String, Symbol] str Name of key
    #   @raise [KeyError] in case that the key cannot be found
    # @overload convert_key(key_id)
    #   @param [Integer] key_id VK_* code
    # @return [Integer]
    def convert_key(obj)
      case obj
      when String, Symbol then return SYMBOL_TO_KEY.fetch(obj.to_sym)
      when Integer        then return obj
      else
        raise TypeError,
         "wrong argument type #{obj.class} (expected String, Symbol or Integer)"
      end
    end
    private :convert_key

    # Checks whether or not the key was pressed?
    #
    # @param [String, Symbol, Integer] obj
    # @return [Boolean]
    def pressed?(obj)
      key = convert_key(obj)
      return @key_state[key]
    end
    alias_method :press?, :pressed?

    # Updates the @key_state Array by grabbing the values from the OS
    #
    # @return [Boolean] Whether or not the array was updated sucessfully
    def update_key_state
      clear_buffer
      if @user32.get_keyboard_state(@byte_array) > 0
        @byte_array.each_byte.each_with_index do |byte, i|
          @key_state[i] = (byte >> 7) == 1
        end
        true
      end
    end
    private :update_key_state

    # Keyboard update function
    #
    # @return [Void]
    def update
      update_key_state
    end
  end
end
