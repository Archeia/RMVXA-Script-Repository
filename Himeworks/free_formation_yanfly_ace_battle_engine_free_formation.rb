#===============================================================================
# Compatibility patch for Free Formation with Yanfly's Ace Battle Engine.
# Place this below both scripts
#===============================================================================
class Window_BattleStatus
  
  def item_max
    $game_party.max_battle_members
  end
  
  def draw_item(index)
    return if index.nil?
    clear_item(index)
    actor = $game_party.member_at_position(index)
    rect = item_rect(index)
    return if actor.nil?
    draw_actor_face(actor, rect.x+2, rect.y+2, actor.alive?)
    draw_actor_name(actor, rect.x, rect.y, rect.width-8)
    draw_actor_action(actor, rect.x, rect.y)
    draw_actor_icons(actor, rect.x, line_height*1, rect.width)
    gx = YEA::BATTLE::BATTLESTATUS_HPGAUGE_Y_PLUS
    contents.font.size = YEA::BATTLE::BATTLESTATUS_TEXT_FONT_SIZE
    draw_actor_hp(actor, rect.x+2, line_height*2+gx, rect.width-4)
    if draw_tp?(actor) && draw_mp?(actor)
      dw = rect.width/2-2
      dw += 1 if $imported["YEA-CoreEngine"] && YEA::CORE::GAUGE_OUTLINE
      draw_actor_tp(actor, rect.x+2, line_height*3, dw)
      dw = rect.width - rect.width/2 - 2
      draw_actor_mp(actor, rect.x+rect.width/2, line_height*3, dw)
    elsif draw_tp?(actor) && !draw_mp?(actor)
      draw_actor_tp(actor, rect.x+2, line_height*3, rect.width-4)
    else
      draw_actor_mp(actor, rect.x+2, line_height*3, rect.width-4)
    end
  end
end