$simport.r 'iek/riviera/scene/load', '1.0.0', 'Riviera styled Load Menu' do |h|
  h.depend 'iek/riviera/scene/file', '>= 1.0.0'
end

class Scene_Load
  def header_string
    'Load'
  end
end
