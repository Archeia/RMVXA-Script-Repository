$simport.r 'iek/riviera/scene/equip', '1.0.0', 'Riviera styled Equip Menu' do |h|
  h.depend 'iek/riviera/scene/menu_base', '>= 1.0.0'
end

class Scene_Equip
  def header_string
    'Equip'
  end
end
