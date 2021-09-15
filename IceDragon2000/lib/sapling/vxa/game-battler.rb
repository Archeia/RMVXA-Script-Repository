$simport.r('sapling/vxa/game-battler', '1.0.0', 'Sapling VXA Game_Battler Integration') do |d|
  d.depend!('sapling', '~> 1.0.0')
end

class Game_Battler
  include Sapling::CharacterBinding
end
