module MapEditor3
  class Sprite_CharacterPreview < Sprite_Character
    def update_position
      self.z = @character.screen_z
    end
  end
end
