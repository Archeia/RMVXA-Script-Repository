module Automation
  class Lister
    def initialize(parent)
      @parent = parent
      @list = []
    end

    def clear
      @list.each { |a| @parent.remove_automation_by_id(a.id) }
      @list.clear
    end

    def a(type, *args)
      automation = Automation::Base.components[type].new(*args)
      @list << automation
      @parent.add_automation(automation)
      automation
    end

    def self.component(sym)
      define_method(sym) do |*args|
        a(sym, *args)
      end
    end

    Automation::Base.components.keys.each { |k| component k }
  end
end
