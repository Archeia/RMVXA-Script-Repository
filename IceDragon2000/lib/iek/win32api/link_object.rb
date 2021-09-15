$simport.r 'iek/win32api/link_object', '1.0.0', 'Wrapper class for Win32API functions'

module Win32
  class LinkObject
    def initialize
      @cache = {}
    end

    def func(dll, *args)
      Win32API.new(dll, *args)
    end

    def dll_name
      @dll_name ||= self.class.dll_name.freeze
    end

    def self.dll(name)
      @dll_name = name
    end

    def self.def_func(name, *args, &b)
      b ||= lambda do |f, *a|
        f.call(*a)
      end
      define_method(name) do |*a|
        f = @cache[name] ||= func(dll_name, *args)
        b.call(f, *a)
      end
    end

    class << self
      attr_reader :dll_name
    end

    private :func
  end
end
