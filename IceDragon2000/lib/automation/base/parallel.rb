# Parallel automations update all there internal Automations together,
# it reports being alive if any internal component is alive.
module Automation
  class Parallel < Batch
    def update(target)
      unless @list.empty?
        dead = []
        @list.each do |automation|
          automation.update(target)
          dead << automation if automation.dead?
        end
        unless dead.empty?
          dead.each do |automation|
            @list.delete(automation)
          end
        end
      end
      super(target)
    end

    type :parallel
  end
end
