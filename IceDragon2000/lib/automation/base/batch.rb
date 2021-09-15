module Automation
  class Batch < Base
    def initialize(*automations)
      @olist = automations.reverse
      super()
    end

    def reset_list
      @list = @olist.dup
      @list.each(&:reset)
    end

    def reset
      reset_list
      super
    end

    def add_automation(automation)
      @olist << automation
      self
    end

    def automata
      yield Automation::Lister.new(self); reset; self
    end

    def dead?
      @list.empty?
    end

    type :batch
  end
end
