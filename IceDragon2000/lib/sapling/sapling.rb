$simport.r('sapling', '1.0.0', 'Provides a character + battler binding API')

module Sapling
  # CharacterBinding will implement the Character hosting API
  module CharacterBinding
    attr_accessor :character
  end

  # BattlerBinding will implement the Battler hosting API
  module BattlerBinding
    attr_accessor :battler
  end
end
