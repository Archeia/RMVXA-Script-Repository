class YGG::System
  def drops_window_visible?
    if ::YGG::DROPS_WINDOW_SWITCH > 0
      $game_switches[::YGG::DROPS_WINDOW_SWITCH]
    else
      true
    end
  end

  def start_target_selection( target_count=1, targets=[] )
    return [] if targets.empty?
    darken_sprite = Sprite.new
    darken_sprite.bitmap = Cache.picture("BlackSheet")
    darken_sprite.opacity = 96
    target_cursor = Sprite.new
    target_cursor.bitmap = Cache.picture("YGG2_Cursor")
    target_cursor.ox, target_cursor.oy = 16, 64
    hold_cursors = []
    target_index = 0
    targets.sort_by! { |a| a.screen_x }
    target = targets[target_index]
    selected_targets = []
    target_cursor.x, target_cursor.y = target.screen_x, target.screen_y unless target.nil?
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::RIGHT) || Input.trigger?(Input::DOWN)
        Sound.play_cursor
        target_index = (target_index + 1) % [targets.size, 1].max
        target = targets[target_index]
      elsif Input.trigger?(Input::LEFT) || Input.trigger?(Input::UP)
        Sound.play_cursor
        target_index = (target_index - 1) % [targets.size, 1].max
        target = targets[target_index]
      end
      if Input.trigger?(Input::C)
        Sound.play_decision
        selected_targets << target
        if selected_targets.size == target_count
          break
        else
          sp = Sprite.new
          sp.bitmap = Cache.picture( "YGG2_Cursor" )
          sp.ox, sp.oy = 16, 64
          sp.zoom_x, sp.zoom_y = 0.75, 0.75
          sp.x, sp.y = target.screen_x, target.screen_y
          hold_cursors << sp
        end
      elsif Input.trigger?(Input::B)
        Sound.play_cancel
        selected_targets.pop
        sp = hold_cursors.pop
        sp.dispose unless sp.nil?
        break if selected_targets.empty?
      end
      unless target.nil?
        if target.screen_x > target_cursor.x
          target_cursor.x = [target_cursor.x + Graphics.width/30.0, target.screen_x].min
        elsif target.screen_x < target_cursor.x
          target_cursor.x = [target_cursor.x - Graphics.width/30.0, target.screen_x].max
        end
        if target.screen_y > target_cursor.y
          target_cursor.y = [target_cursor.y + Graphics.height/30.0, target.screen_y].min
        elsif target.screen_y < target_cursor.y
          target_cursor.y = [target_cursor.y - Graphics.height/30.0, target.screen_y].max
        end
      end
    end
    hold_cursors.compact.each { |s| s.dispose }
    target_cursor.dispose
    darken_sprite.dispose
    Graphics.update
    # // Double trigger fix
    Input.update
    return selected_targets
  end

  def start_xy_selection
  end

  def gameover_process
    $game_temp.next_scene = "gameover"
  end

  def __on_load
    self.flush_battlers
    $game_player.ygg_unregister
    $game_player.refresh_handles
    $game_map.events.values.each do |ev|
      ev.refresh_handles
      ev.ygg_unregister
      ev.update
    end
    $game_player.ygg_register
    self.projectiles.each do |pro|
      pro.refresh_handles
      pro.__reload
    end
  end
end
