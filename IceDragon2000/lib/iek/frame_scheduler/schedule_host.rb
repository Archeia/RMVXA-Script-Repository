$simport.r 'iek/frame_scheduler/scheduler_host', '1.0.0', 'Scheduler Mixin' do |h|
  h.depend 'iek/frame_scheduler', '>= 1.0.0'
end

class FrameScheduler
  module SchedulerHost
    def init_scheduler
      @scheduler = FrameScheduler.new
    end

    def update_scheduler
      @scheduler.update
    end
  end
end
