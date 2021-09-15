$simport.r 'iek/riviera/scene/skill', '1.0.0', 'Riviera styled Skill Menu' do |h|
  h.depend 'iek/riviera/scene/item_base', '>= 1.0.0'
end

class Scene_Skill
  def header_string
    'Skills'
  end
end
