$simport.r('iek/win32api/win32/user32', '1.0.0', 'User32 link object') do |h|
  h.depend!('iek/win32api/link_object', '~> 1.0.0')
end

module Win32
  class User32 < LinkObject
    dll 'user32'

    ##
    # :nodoc:
    def_func :get_async_key_state, 'GetAsyncKeyState', 'i', 'i'

    ##
    # :nodoc:
    def_func :get_key_state, 'GetKeyState', 'i', 'i'

    ##
    # :nodoc:
    def_func :get_keyboard_state, 'GetKeyboardState', 'p', 'i'

    ##
    # :nodoc:
    def_func :get_cursor_pos, 'GetCursorPos', 'p' , 'i'

    ##
    # :nodoc:
    def_func :set_cursor_pos, 'SetCursorPos', 'll' , 'i'

    ##
    # :nodoc:
    def_func :screen_to_client, 'ScreenToClient', 'lp', 'i'

    ##
    # :nodoc:
    def_func :client_to_screen, 'ClientToScreen', 'lp', 'i'

    ##
    # :nodoc:
    def_func :get_client_rect, 'GetClientRect', 'lp', 'i'

    ##
    # :nodoc:
    def_func :find_window_a, 'FindWindowA', 'pp', 'l'
  end
end
