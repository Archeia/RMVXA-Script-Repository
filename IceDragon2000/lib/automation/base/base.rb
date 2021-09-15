module Automation
  class Base
    ##
    # @return [Hash<Symbol, Class>]
    @@components = {}
    @@automation_id = 0

    attr_reader :id

    def initialize
      reset
      @id = @@automation_id += 1
    end

    def reset
      #
    end

    def type
      nil
    end

    def dead?
      true # overwrite in subclass
    end

    def update(target)

    end

    def static_update(target)
      update(target) until dead?
    end

    def static_render(page_klass=OpenStruct)
      record = []
      page = page_klass.new
      until dead?
        update(page)
        record << page
        page = page.dup
      end
      return record
    end

    def self.type(*a)
      if a.empty?
        return @type
      else
        @type, = a
        define_method(:type) { @type }
        @@components[@type] = self
      end
    end

    def self.components
      @@components
    end
  end
end
