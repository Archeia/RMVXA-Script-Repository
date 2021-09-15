module YGG
  module Util
    class Key
      def initialize(key)
        @key = key
        @state = false
        @counter = 0
      end

      def update
        @state = Input.keyboard.pressed?(@key)
        if @state
          @counter += 1
        else
          @counter = 0
        end
      end

      def triggered?
        @counter == 1
      end

      def pressed?
        @counter > 0
      end

      def repeated?
        pressed? && @counter % 7 == 0
      end
    end

    class Keys
      def initialize
        @keys = {}
        @list = []
      end

      def [](key_code)
        @keys.fetch(key_code)
      end

      def create_key(key_code)
        key = Key.new(key_code)
        @list << key
        key
      end

      def add(key_code)
        @keys[key_code] ||= create_key(key_code)
      end

      def update
        @list.each(&:update)
      end

      def triggered?(key_code)
        self[key_code].triggered?
      end

      def pressed?(key_code)
        self[key_code].pressed?
      end

      def repeated?(key_code)
        self[key_code].repeated?
      end
    end
  end
end
