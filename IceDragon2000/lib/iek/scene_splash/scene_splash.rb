$simport.r 'iek/scene_splash', '1.0.0', 'Splash Screen' do |h|
  h.depend! 'iek/frame_scehduler', '>= 1.0.0'
  h.depend! 'iek/frame_scehduler/scheduler_host', '>= 1.0.0'
end

class Scene_Splash < Scene_Base
  include FrameScheduler::SchedulerHost

  def initialize
    super
    init_scheduler
  end

  def start
    super
    create_all

    make_splash_stack

    @bgm.play

    schedule
  end

  def make_splash_stack
    @splashes = []
  end

  def schedule
    @scheduler.every "1s" do
      execute_splash @splashes.pop
    end
  end

  def create_all
    create_bgm
    create_sprite
  end

  def create_bgm
    @bgm = RPG::BGM.new("Splash", 100, 100)
  end

  def create_sprite
    @sprite = Sprite_Base.new
  end

  def update_basic
    super
    update_scheduler
  end

  def execute_splash(splash)
  end
end
