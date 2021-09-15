module Katana
  class SceneLoggerPatch
    attr_reader :logger

    def initialize(logger)
      @logger = logger
    end

    def patch(scene)
      scene.logger = @logger.new(scene: "#{scene}")
    end
  end

  module Scenes
    class Base
      attr_accessor :logger
      attr_accessor :scene_manager
      attr_accessor :data_manager

      def initialize
        @logger = Moon::Logfmt::NullLogger
        @scene_manager = nil
        @data_manager = nil
      end

      def dead?
        !@process_fiber
      end

      def invoke
        @started = false
        @process_fiber = Fiber.new do
          main
          @process_fiber = nil
        end
      end

      def release
        return unless @started
        @logger.write at: 'pre_terminate'
        pre_terminate
        @logger.write at: 'terminate'
        terminate
      end

      def resume(delta)
        @process_fiber.resume(delta) if @process_fiber
      end

      def main
        @logger.write at: 'start'
        start
        @started = true
        @logger.write at: 'post_start'
        post_start
        @logger.write at: 'updating'
        loop do
          d = Fiber.yield
          update_basic
          update
        end
      end

      def start

      end

      def post_start
        perform_transition
        Input.update
      end

      def scene_changing?
        scene_manager.scene != self
      end

      def update_basic
      end

      def update
      end

      def pre_terminate
      end

      def terminate
        Graphics.freeze
      end

      def transition_speed
        10
      end

      def perform_transition
        Graphics.transition(transition_speed)
      end
    end
  end
end
