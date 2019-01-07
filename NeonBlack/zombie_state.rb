class Game_BattlerBase
  def rec; check_for_zombie ? sparam(2) * -1 : sparam(2); end
  def check_for_zombie; @states.any? {|st| $data_states[st].zombie}; end
end


class RPG::State < RPG::BaseItem
  ZOMB = /\[zombie\]/i
  attr_reader :zombie
  
  def set_zombie
    return if @zombie_check; @zombie_check = true
    @zombie = false
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when ZOMB
        @zombie = true
      end
    end
  end
end

module DataManager
  class << self
    alias load_database_cpz load_database unless $@
  end
  
  def self.load_database
    load_database_cpz
    check_zomb
  end

  def self.check_zomb
    groups = [$data_states]
    for group in groups
      for obj in group
        next if obj == nil
        obj.set_zombie if obj.is_a?(RPG::State)
      end
    end
  end
end