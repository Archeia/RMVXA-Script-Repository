$simport.r('iek/win32api/win32/kernel32', '1.0.0', 'Kernel32 link object') do |h|
  h.depend!('iek/win32api/link_object', '~> 1.0.0')
end

module Win32
  class Kernel32 < LinkObject
    dll 'kernel32'

    ##
    # :nodoc:
    def_func :get_private_profile_string_a, 'GetPrivateProfileStringA', 'pppplp', 'l'
  end
end
