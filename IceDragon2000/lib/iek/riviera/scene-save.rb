$simport.r 'iek/riviera/scene/save', '1.0.0', 'Riviera styled Save Menu' do |h|
  h.depend 'iek/riviera/scene/file', '>= 1.0.0'
end

class Scene_Save
  def header_string
    'Save'
  end
end
