$simport.r 'iek/win32api/input', '1.0.0', 'Input module' do |h|
  h.depend! 'iek/win32api/win32/kernel32', '~> 1.0.0'
  h.depend! 'iek/win32api/win32/user32', '~> 1.0.0'
end

module Win32
  module Input
    class << self
      # @return [Integer] Pointer to the Window Handle
      attr_reader :client_id
    end

    ##
    # Initialize the Win32 Module
    def self.init
      @kernel32 = Win32::Kernel32.new
      @user32 = Win32::User32.new
      set_client
    end

    ##
    # Sets the Window client
    def self.set_client
      game_name = "\0" * 256 # create a 256 NULL byte Array
      @kernel32.get_private_profile_string_a('Game', ' Title', '', game_name, 256, ".\\Game.ini" )
      game_name.delete!("\0") # remove NULL bytes
      @client_id = @user32.find_window_a('RGSS Player', game_name)
    end

    class << self
      private :set_client
    end

    init
  end
end
