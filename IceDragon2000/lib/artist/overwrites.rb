class Artist
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_item_icon(item, x, y, enabled)
    change_color(Palette['white'], enabled)
    old_font = contents.font.name
    #contents.font.name = ["Microsoft YaHei"]
    draw_text(x + 24, y, width, line_height, item.name)
    contents.font.name = old_font
  end

  def draw_face(face_name, face_index, x, y, enabled = true)
    bitmap = Cache.face(face_name)
    rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    #bitmap.dispose
  end

  def draw_actor_hp( actor, x, y, width = 124 )
    draw_entity_hp(
      :battler => actor,
      :x => x,
      :y => y,
      :width => width
    )
  end
  #--------------------------------------------------------------------------
  # ● MP の描画
  #--------------------------------------------------------------------------
  def draw_actor_mp( actor, x, y, width = 124 )
    draw_entity_mp(
      :battler => actor,
      :x => x,
      :y => y,
      :width => width
    )
  end
end
