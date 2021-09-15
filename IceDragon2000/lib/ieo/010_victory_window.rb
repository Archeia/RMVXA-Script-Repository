#encoding:UTF-8
# IEO-010(Victory Window)
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # * Victory Processing
  #--------------------------------------------------------------------------
  def process_victory
    @info_viewport.visible = false
    @message_window.visible = true
    RPG::BGM.stop
    $game_system.battle_end_me.play
    unless $BTEST
      $game_temp.map_bgm.play
      $game_temp.map_bgs.play
    end
    display_exp_and_gold
    display_drop_items
    display_level_up
    battle_end(0)
  end
  
  #--------------------------------------------------------------------------
  # * Display Gained Experience and Gold
  #--------------------------------------------------------------------------
  def display_exp_and_gold
    exp = $game_troop.exp_total
    gold = $game_troop.gold_total
    $game_party.gain_gold(gold)
    text = sprintf(Vocab::Victory, $game_party.name)
    $game_message.texts.push('\|' + text)
    if exp > 0
      text = sprintf(Vocab::ObtainExp, exp)
      $game_message.texts.push('\.' + text)
    end
    if gold > 0
      text = sprintf(Vocab::ObtainGold, gold, Vocab::gold)
      $game_message.texts.push('\.' + text)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * Display Gained Drop Items
  #--------------------------------------------------------------------------
  def display_drop_items
    drop_items = $game_troop.make_drop_items
    for item in drop_items
      $game_party.gain_item(item, 1)
      text = sprintf(Vocab::ObtainItem, item.name)
      $game_message.texts.push(text)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * Display Level Up
  #--------------------------------------------------------------------------
  def display_level_up
    exp = $game_troop.exp_total
    for actor in $game_party.existing_members
      last_level = actor.level
      last_skills = actor.skills
      actor.gain_exp(exp, true)
    end
    wait_for_message
  end
  
end  