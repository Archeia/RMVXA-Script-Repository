module MapEditor3
  class CharacterPreview
    attr_reader :viewport
    attr_reader :character
    attr_reader :x
    attr_reader :y

    def initialize(viewport)
      @viewport = viewport
      @null_character = Game_CharacterBase.new
      @sprite = Sprite_CharacterPreview.new(@viewport, @null_character)
      self.x = 0
      self.y = 0
    end

    def dispose
      @sprite.dispose
    end

    def update
      @sprite.update
    end

    def x=(x)
      @x = x
      @sprite.x = x + 16
    end

    def y=(y)
      @y = y
      @sprite.y = y + 32
    end

    def viewport=(viewport)
      @viewport = viewport
      @sprite.viewport = @viewport
    end

    def character=(character)
      @character = character || @null_character
      @sprite.character = @character
    end
  end
end
