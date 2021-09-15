$simport.r 'iei/cache_constructor', '0.1.0', 'IEI Cache Constructor'

#-inject gen_module_header 'IEI::CacheConstructor'
module IEI
  module CacheConstructor
    def self.included(mod)
      mod.cc_init
    end

    def cc_init
      @constructor = {}
    end

    def construct(name, &func)
      @constructor[name] = func
    end

    def call_construct(name, *args, &block)
      @constructor[name].call(*args, &block) if @constructor.has_key?(name)
    end
  end
end
