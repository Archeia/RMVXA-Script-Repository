$simport.r 'iek/better_variables/callbacks', '1.0.0', 'Utilizes iek callbacks for better_variables' do |h|
  h.depend 'iek/better_variables', '>= 1.0.0'
  h.depend! 'iek/callbacks', '>= 1.0.0'
end

class Game_Variables
  include Mixin::Callback

  def on_change(id, org, now)
    $game_map.need_refresh = true
    try_callback(:on_change, id, org, now)
  end
end
