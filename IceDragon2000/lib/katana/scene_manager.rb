$simport.r('katana/scene_manager', '1.0.0', 'Specialized SceneManager for the Katana framework')

module Katana
  class SceneManagerPatch
    attr_reader :scene_manager

    def initialize(scene_manager)
      @scene_manager = scene_manager
    end

    def patch(scene)
      scene.scene_manager = @scene_manager
    end
  end

  class SceneManager
    attr_accessor :logger
    attr_accessor :patches
    attr_accessor :stack
    attr_reader :scene

    def initialize(options = {})
      @logger = options.fetch(:logger, Moon::Logfmt::NullLogger)
      @patches = [SceneManagerPatch.new(self)]
      @clk = Katana::Clock.new
      @stack = []
      @scene = nil
    end

    def dead?
      !@scene
    end

    def patch(scn)
      @logger.write fn: 'patch', scene: scn.class.name
      @patches.each do |mwd|
        mwd.patch scn
      end
      scn
    end
    private :patch

    def release(scn)
      return unless scn
      @logger.write fn: 'release', scene: scn.class.name
      scn.release
      scn
    end
    private :release

    def invoke(scn)
      return unless scn
      @logger.write fn: 'invoke', scene: scn.class.name
      scn.invoke
      scn
    end
    private :invoke

    def switch(scn)
      @logger.write fn: 'switch', old: @scene.class.name, new: scn.class.name
      old = @scene
      @scene = scn
      release old
      invoke @scene
    end
    private :switch

    def change(scn)
      @logger.write fn: 'change', scene: scn.class.name
      switch patch(scn)
    end

    def push(scn)
      @logger.write fn: 'push', scene: scn.class.name
      @stack.push @scene
      switch patch(scn)
    end

    def pop
      # release the current scene
      @logger.write fn: 'pop', scene: @scene.class.name
      switch @stack.pop
    end

    def tick
      @scene.resume @clk.restart
    end
  end
end
