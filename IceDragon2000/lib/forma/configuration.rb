$simport.r 'forma', '1.0.0', 'Configuration module'

# Configuration Registry
#
# @example
#   Forma = FormaRegistry.new
#   Forma.configure('iek/sapling') do |c|
#     c[:gc_timer] = 120
#   end
class FormaRegistry
  class Configuration
    attr_reader :name

    def initialize(name)
      @name = name
      @config = {}
    end

    def default(key, value)
      @config[key] = value unless @config.has_key?(key)
    end

    def [](key)
      @config[key]
    end

    def []=(key, value)
      @config[key] = value
    end
  end

  def initialize
    @map = {}
  end

  def [](name)
    @map[name]
  end

  def configure(name)
    (@map[name] ||= Configuration.new(name)).tap do |config|
      yield config if block_given?
    end
  end
end

Forma = FormaRegistry.new
