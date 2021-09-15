$simport.r('jade', '1.0.0', 'Battle System Toolkit') do |d|
  d.depend!('sapling', '~> 1.0.0')
  d.depend!('iek/abstract_method_error/core_ext/module', '~> 1.0.0')
end

module Jade
  module Character
    #
  end

  module Map
    def init_tbs
      @placements = []
    end

    private abstract :character_class

    def create_character
      character_class.new
    end

    def add_character
      #
    end

    def new_character
      character = create_character
      add_character(character)
    end

    def find_character_by_id(id)
      #
    end

    def remove_character(character)
      #
    end

    def remove_character_by_id(id)
      remove_character(find_character_by_id(id))
    end
  end
end
