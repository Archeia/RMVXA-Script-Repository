#Yanfly Engine Ace - Ace Battle Engine + Sleek Gauges by Vlue
class Window_BattleStatus < Window_Selectable
  alias ynfbs_refresh refresh
  def refresh
    if !@dummy_window
      @dummy_window = Window_BaseLH.new(self.x,self.y,self.width,self.height)
      @dummy_window.viewport = self.viewport
      @dummy_window.opacity = 0
      @dummy_window.contents.font.size = YEA::BATTLE::BATTLESTATUS_TEXT_FONT_SIZE
    end
    @dummy_window.contents.clear
    ynfbs_refresh
  end
  def draw_actor_hp(actor, dx, dy, width = 124)
    @dummy_window.draw_actor_hp(actor, dx, dy, width,8)
  end
  def draw_actor_mp(actor, dx, dy, width = 124)
    @dummy_window.draw_actor_mp(actor, dx, dy+3, width,8)
  end
  def draw_actor_tp(actor, dx, dy, width = 124)
    @dummy_window.draw_actor_tp(actor, dx, dy+3, width,8)
  end
  alias gauge2_update update
  def update
    gauge2_update
    @dummy_window.update if @dummy_window
  end
  def close
    super
    @dummy_window.close if @dummy_window
  end
end

class Window_BattleStatusAid < Window_BattleStatus
  alias ynfbs_refresh refresh
  def refresh
    if !@dummy_window
      @dummy_window = Window_BaseLH.new(self.x,self.y,self.width,self.height)
      @dummy_window.viewport = self.viewport
      @dummy_window.opacity = 0
      @dummy_window.contents.font.size = YEA::BATTLE::BATTLESTATUS_TEXT_FONT_SIZE
      @dummy_window.hide
    end
    @dummy_window.contents.clear
    ynfbs_refresh
  end
  def hide
    super
    @dummy_window.hide if @dummy_window
  end
  def show
    super
    @dummy_window.show if @dummy_window
  end
end

class Window_BaseLH < Window_Base
  def line_height
    self.contents ? contents.font.size : 24
  end
end