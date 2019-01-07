##------
## This snippet fixes a compatibility issue between CP's Grade Victory Screen
## and Yanfly's JP Manager.  The proper ordering of these scripts is Grade
## Victory, JP Manager, then this patch.
##   - Neon Black - 12.30.2012
##------

if $imported["YEA-JPManager"] && $imported["CP_VICTORY"]  ## Checks imported.
module BattleManager  ## Alias the exp event.
  class << self; alias cp_yanfly_jp_fix_gain_exp gain_exp; end
  def self.gain_exp
    gain_jp  ## Give classes JP.
    cp_yanfly_jp_fix_gain_exp
  end
  
  def self.gain_jp  ## Shortened JP gain portion.
    amount = $game_troop.jp_total
    for member in $game_party.members
      member.earn_jp(amount)
    end
  end
end

class Window_VictoryMain < Window_Selectable
  alias cp_yanfly_basic_draw_item draw_item
  def draw_item(index)  ## Adds an additional text drawing segment.
    actor = $game_party.members[index]
    rect = item_rect(index)
    cp_yanfly_basic_draw_item(index)
    draw_actor_ap_add(actor, rect.x, rect.y + (104 - line_height * 0.8).to_i,
                      rect.width)
  end
  
  def draw_actor_ap_add(actor, x, y, width)  ## Draws the gained JP value.
    i = ($game_troop.jp_total * actor.jpr).to_i
    return if i <= 0
    vocab = sprintf(YEA::JP::VICTORY_AFTERMATH, i, Vocab.jp)
    change_color(power_up_color)
    draw_text(x, y, width, line_height, vocab, 1)
    change_color(normal_color)
  end
end
end