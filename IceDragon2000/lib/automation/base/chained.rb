module Automation
  class Chained < Batch
    def update(target)
      unless @list.empty?
        if c = @list.first
          @list.shift until (@list.first && !@list.first.dead?) || @list.empty? if c.dead?
        end
        automation = @list.first
        automation.update(target) if automation
      end
      super(target)
    end

    type :chained
  end
end
