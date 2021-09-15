#
# EDOS/lib/mixin/automatable.rb
#   by IceDragon
module Mixin
  module Automatable
    def init_automations
      @automations = []
    end

    def dispose_automations
      clear_automations
    end

    def clear_automations(type=nil)
      if type
        @automations.reject! { |a| a.type == type }
      else
        @automations.clear
      end
    end

    def remove_automation_by_id(id)
      @automations.reject! { |o| o.id == id }
    end

    def add_automation(automation)
      @automations << automation
      self
    end

    def automata
      yield Automation::Lister.new(self)
    end

    def update_automations
      unless @automations.empty?
        dead = []
        @automations.each do |automation|
          automation.update(self)
          dead << automation if automation.dead?
        end
        unless dead.empty?
          dead.each do |automation|
            @automations.delete(automation)
          end
        end
      end
    end

    def automating?(type=nil)
      if type
        return @automations.any? { |a| a.type == type }
      else
        return !@automations.empty?
      end
    end

    private :init_automations
    private :dispose_automations
    private :update_automations
  end
end
