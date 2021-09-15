$simport.r('iek/win32api/win32/ws2_32', '1.0.0', 'Ws2_32 link object') do |h|
  h.depend!('iek/win32api/link_object', '~> 1.0.0')
end

module Win32
  class Ws2_32 < LinkObject

  end
end
