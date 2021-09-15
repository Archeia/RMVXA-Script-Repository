$simport.r 'iek/better_switches/callbacks', '1.0.0', 'Utilizes iek callbacks for better_switches' do |h|
  h.depend 'iek/better_switches', '>= 1.0.0'
  h.depend! 'iek/callbacks', '>= 1.0.0'
end

class Game_Switches
  include Mixin::Callback

  def on_change(id, org, now)
    $game_map.need_refresh = true
    try_callback(:on_change, id, org, now)
  end
end
