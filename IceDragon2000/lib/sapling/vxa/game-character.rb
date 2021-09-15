$simport.r('sapling/vxa/game-character', '1.0.0', 'Sapling VXA Game_Character Integration') do |d|
  d.depend!('sapling', '~> 1.0.0')
end

class Game_Character
  include Sapling::BattlerBinding
end
