$simport.r 'iek/riviera/scene/field_status', '1.0.0', 'Riviera Field Status Menu' do |h|
  h.depend 'iek/riviera/scene/status', '>= 1.0.0'
end

class Scene_FieldStatus < Scene_Status
  def header_string
    'Field Status'
  end
end
