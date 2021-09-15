$simport.r 'iek/riviera/scene/file', '1.0.0', 'Riviera styled File Menu' do |h|
  h.depend 'iek/riviera/scene/menu_base', '>= 1.0.0'
end

class Scene_File
  def header_string
    'File'
  end
end
