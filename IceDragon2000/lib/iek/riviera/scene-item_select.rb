$simport.r 'iek/riviera/scene/item_select', '1.0.0', 'Riviera styled ItemSelect Menu' do |h|
  h.depend 'iek/riviera/scene/menu_base', '>= 1.0.0'
end

class Scene_ItemSelect < Scene_MenuBase
  def start
    super
  end

  def header_string
    'Item Select'
  end
end
