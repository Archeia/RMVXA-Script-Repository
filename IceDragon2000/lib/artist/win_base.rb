# Artist (Window::Base)
# // 03/05/2012
# // 03/05/2012
class Artist
  def contents
    bitmap
  end

  def windowskin
    @parent.windowskin
  end

  def line_height
    @parent.line_height
  end

  def padding
    @parent.padding
  end

  def standard_padding
    @parent.standard_padding
  end

  # // From Window::Base
  #--------------------------------------------------------------------------
  # ● ゲージの描画
  #     rate   : 割合（1.0 で満タン）
  #     color1 : グラデーション 左端
  #     color2 : グラデーション 右端
  #--------------------------------------------------------------------------
  def draw_gauge(x, y, width, rate, color1, color2)
    fill_w = (width * rate).to_i
    gauge_y = y + line_height - 8
    contents.fill_rect(x, gauge_y, width, 6, gauge_back_color)
    contents.gradient_fill_rect(x, gauge_y, fill_w, 6, color1, color2)
  end
  #--------------------------------------------------------------------------
  # ● 顔グラフィックの描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_face(face_name, face_index, x, y, enabled = true)
    bitmap = Cache.face(face_name)
    rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # ● 歩行グラフィックの描画
  #--------------------------------------------------------------------------
  def draw_character(character_name, character_index, x, y)
    return unless character_name
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
  #--------------------------------------------------------------------------
  # ● HP の文字色を取得
  #--------------------------------------------------------------------------
  def hp_color(actor)
    return knockout_color if actor.hp == 0
    return crisis_color if actor.hp < actor.mhp / 4
    return normal_color
  end
  #--------------------------------------------------------------------------
  # ● MP の文字色を取得
  #--------------------------------------------------------------------------
  def mp_color(actor)
    return crisis_color if actor.mp < actor.mmp / 4
    return normal_color
  end
  #--------------------------------------------------------------------------
  # ● TP の文字色を取得
  #--------------------------------------------------------------------------
  def tp_color(actor)
    return normal_color
  end
  #--------------------------------------------------------------------------
  # ● アクターの歩行グラフィック描画
  #--------------------------------------------------------------------------
  def draw_actor_graphic(actor, x, y)
    draw_character(actor.character_name, actor.character_index, x, y)
  end
  #--------------------------------------------------------------------------
  # ● アクターの顔グラフィック描画
  #--------------------------------------------------------------------------
  def draw_actor_face(actor, x, y, enabled = true)
    draw_face(actor.face_name, actor.face_index, x, y, enabled)
  end
  #--------------------------------------------------------------------------
  # ● 名前の描画
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, x, y, width = 112)
    change_color(hp_color(actor))
    draw_text(x, y, width, line_height, actor.name)
  end
  #--------------------------------------------------------------------------
  # ● 職業の描画
  #--------------------------------------------------------------------------
  def draw_actor_class(actor, x, y, width = 112)
    change_color(normal_color)
    draw_text(x, y, width, line_height, actor.class.name)
  end
  #--------------------------------------------------------------------------
  # ● 二つ名の描画
  #--------------------------------------------------------------------------
  def draw_actor_nickname(actor, x, y, width = 180)
    change_color(normal_color)
    draw_text(x, y, width, line_height, actor.nickname)
  end
  #--------------------------------------------------------------------------
  # ● レベルの描画
  #--------------------------------------------------------------------------
  def draw_actor_level(actor, x, y)
    change_color(system_color)
    draw_text(x, y, 32, line_height, Vocab::level_a)
    change_color(normal_color)
    draw_text(x + 32, y, 24, line_height, actor.level, 2)
  end
  #--------------------------------------------------------------------------
  # ● ステートおよび強化／弱体のアイコンを描画
  #--------------------------------------------------------------------------
  def draw_actor_icons(actor, x, y, width = 96)
    icons = (actor.state_icons + actor.buff_icons)[0, width / 24]
    icons.each_with_index {|n, i| draw_icon(n, x + 24 * i, y) }
  end
  #--------------------------------------------------------------------------
  # ● 現在値／最大値を分数形式で描画
  #     current : 現在値
  #     max     : 最大値
  #     color1  : 現在値の色
  #     color2  : 最大値の色
  #--------------------------------------------------------------------------
  def draw_current_and_max_values(x, y, width, current, max, color1, color2)
    change_color(color1)
    xr = x + width
    if width < 96
      draw_text(xr - 40, y, 42, line_height, current, 2)
    else
      draw_text(xr - 92, y, 42, line_height, current, 2)
      change_color(color2)
      draw_text(xr - 52, y, 12, line_height, "/", 2)
      draw_text(xr - 42, y, 42, line_height, max, 2)
    end
  end
  #--------------------------------------------------------------------------
  # ● HP の描画
  #--------------------------------------------------------------------------
  def draw_actor_hp(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.hp_rate, hp_gauge_color1, hp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::hp_a)
    draw_current_and_max_values(x, y, width, actor.hp, actor.mhp,
      hp_color(actor), normal_color)
  end
  #--------------------------------------------------------------------------
  # ● MP の描画
  #--------------------------------------------------------------------------
  def draw_actor_mp(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.mp_rate, mp_gauge_color1, mp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::mp_a)
    draw_current_and_max_values(x, y, width, actor.mp, actor.mmp,
      mp_color(actor), normal_color)
  end
  #--------------------------------------------------------------------------
  # ● TP の描画
  #--------------------------------------------------------------------------
  def draw_actor_tp(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.tp_rate, tp_gauge_color1, tp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::tp_a)
    change_color(tp_color(actor))
    draw_text(x + width - 42, y, 42, line_height, actor.tp.to_i, 2)
  end
  #--------------------------------------------------------------------------
  # ● シンプルなステータスの描画
  #--------------------------------------------------------------------------
  def draw_actor_simple_status(actor, x, y)
    draw_actor_name(actor, x, y)
    draw_actor_level(actor, x, y + line_height * 1)
    draw_actor_icons(actor, x, y + line_height * 2)
    draw_actor_class(actor, x + 120, y)
    draw_actor_hp(actor, x + 120, y + line_height * 1)
    draw_actor_mp(actor, x + 120, y + line_height * 2)
  end
  #--------------------------------------------------------------------------
  # ● 能力値の描画
  #--------------------------------------------------------------------------
  def draw_actor_param(actor, x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 120, line_height, Vocab::param(param_id))
    change_color(normal_color)
    draw_text(x + 120, y, 36, line_height, actor.param(param_id), 2)
  end
  #--------------------------------------------------------------------------
  # ● アイテム名の描画
  #     enabled : 有効フラグ。false のとき半透明で描画
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
  end
  #--------------------------------------------------------------------------
  # ● 通貨単位つき数値（所持金など）の描画
  #--------------------------------------------------------------------------
  def draw_currency_value(value, unit, x, y, width)
    cx = text_size(unit).width
    change_color(normal_color)
    draw_text(x, y, width - cx - 2, line_height, value, 2)
    change_color(system_color)
    draw_text(x, y, width, line_height, unit, 2)
  end
  #--------------------------------------------------------------------------
  # ● 能力値変化の描画色取得
  #--------------------------------------------------------------------------
  def param_change_color(change)
    return power_up_color   if change > 0
    return power_down_color if change < 0
    return normal_color
  end
end
