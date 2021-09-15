#encoding:UTF-8
# ISS023 - Class Table Blocks
#==============================================================================#
# ** ISS, ClassTable, Blocks // forward declaration
#==============================================================================#
module ISS ; end ; class ISS::ClassTable < ::ISS::SystemTable ; module Blocks ; end ; end
#==============================================================================#
# ** ISS::ClassTable::Blocks
#==============================================================================#
module ISS::ClassTable::Blocks

#==============================================================================#
# ** BaseBlock
#==============================================================================#
  class BaseBlock < ::ISS::SystemTable::TableBlock

    def initialize
      super()
    end

    def runEffect(user)
    end

    def effect_to_s
      return ""
    end

  end

#==============================================================================#
# ** ClassBlock
#==============================================================================#
  class ClassBlock < BaseBlock

    attr_accessor :class_id

    def initialize(class_id)
      super()
      @class_id = class_id
    end

    def runEffect(user)
      user.unlock_class(@class_id)
    end

    def effect_to_s
      return "Class Unlocked: #{@class_id}"
    end

  end

#==============================================================================#
# ** StatBlock
#==============================================================================#
  class StatBlock < BaseBlock

    attr_accessor :stat, :value

    def initialize(stat, value)
      super()
      @stat  = stat
      @value = value
    end

    def runEffect(user)
      user.send(@stat.to_s+"=", user.send( @stat ) + @value)
    end

    def effect_to_s
      return "Stat #{@stat} increased by: #{@value}"
    end

  end

#==============================================================================#
# ** SkillBlock
#==============================================================================#
  class SkillBlock < BaseBlock

    attr_accessor :skill_id

    def initialize(skill_id)
      super()
      @skill_id = skill_id
    end

    def runEffect(user)
      user.learn_skill(@skill_id)
    end

    def effect_to_s
      return "Skill Learned: #{@skill_id}"
    end

  end

#==============================================================================#
# ** PassiveBlock
#==============================================================================#
  class PassiveBlock < BaseBlock

    attr_accessor :passive_id

    def initialize(passive_id)
      super()
      @passive_id = passive_id
    end

    def runEffect(user)
      user.learn_passive(@passive_id)
    end

    def effect_to_s
      return "Passive Learned: #{@passive_id}"
    end

  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
