#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Class System
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Change (Actor, Class)
# ** Script Type   : Class System, Class Leveling, Subclass
# ** Date Created  : 03/02/2011
# ** Date Modified : 07/02/2011
# ** Script Tag    : IEO-013(ClassSystem)
# ** Difficulty    : Medium, Hard, Lunatic
# ** Version       : 1.1
# ** IEO ID        : 013
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
# ** CREDITS/USED STUFF/EDITING
#-*--------------------------------------------------------------------------*-#
# You may:
# Edit and Adapt this script as long you credit aforementioned author(s).
#
# You may not:
# Claim this as your own work, or redistribute without the consent of the author.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#-*--------------------------------------------------------------------------*-#
# Class Changing, Class Leveling, Subclasses (yes multiple subclasses)
# If your looking for all or any of these, This here script has it.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTRUCTIONS
#-*--------------------------------------------------------------------------*-#
# Enemy Notetags
#   <weapon idn: weapon_id>
#   Sets the weapon for the enemy
#   EG
#   <weapon id1: 1>
#   Sets the enemy's primary weapon to weapon 1
#   <weapon id2: 1>
#   Sets the enemy's secondary weapon to weapon 2, only if two_sword_style is true
#   Else, this will use the weapon_id as a armor_id
#------------------------------------------------------------------------------#
#==============================================================================#
# ** COMPATABLITIES
#-*--------------------------------------------------------------------------*-#
#
# Well has only been tested with the DBS.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INSTALLATION
#-*--------------------------------------------------------------------------*-#
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
#
#-*--------------------------------------------------------------------------*-#
# Below
#   Materials
#   CBS
#
# Above
#   Main
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGES
#-*--------------------------------------------------------------------------*-#
# Classes
#   RPG::Enemy
#     new-method :ieo015_enemycache
#     new-method :armor_id1
#     new-method :armor_id2
#     new-method :armor_id3
#     new-method :armor_id4
#   Game_Enemy
#     alias      :initialize
#     overwrite  :base_atk
#     overwrite  :base_def
#     overwrite  :base_spi
#     overwrite  :base_agi
#     overwrite  :hit
#     overwrite  :eva
#     overwrite  :cri
#     overwrite  :atk_animation_id
#     overwrite  :atk_animation_id2
#     overwrite  :fast_attack
#     overwrite  :dual_attack
#     overwrite  :prevent_critical
#     overwrite  :half_mp_cost
#     new-method :weapons
#     new-method :armors
#     new-method :equips
#     new-method :two_swords_style
#     new-method :auto_hp_recover
#     new-method :do_auto_recovery
#     new-method :double_exp_gain
#   Game_Troop
#     new-method :do_auto_recovery
#   Scene_Title
#     alias      :load_database
#     alias      :load_bt_database
#     new-method :load_ieo015_cache
#   Scene_Battle
#     alias      :turn_end
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#-*--------------------------------------------------------------------------*-#
# (DD/MM/YYYY)
#  03/02/2011 - V1.0  Started and Finished Script
#  07/01/2011 - V1.1  Added Subclasses
#  07/02/2011 - V1.2  Formatted Code
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#
#  May cause a few issues with skill learning.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
$imported ||= {}
$imported["IEO-ClassSystem"] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, "ScriptName"]]
$ieo_script = {} if $ieo_script == nil
$ieo_script[[13, "ClassSystem"]] = 1.1
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# ** IEO::CLASS_SYSTEM
#==============================================================================#
module IEO
  module CLASS_SYSTEM
#==============================================================================#
#                      Start Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
    PARAMETERS = ['maxhp', 'maxmp', 'atk', 'def', 'spi', 'agi']

    SLIDY_WINDOWS = true

    ACTOR_CLASS_MAXLEVELS = { }
    # The key for this is an actor's id
    ACTOR_CLASS_MAXLEVELS[0] = {
      0 => 20 }

    CLASS_PARAMS_SETUP = { }
    # Class 0 is used as the default class, serving as a point for
    # all undeclared classes.
    CLASS_PARAMS_SETUP[0] = {
    # :stat  => rank
      :maxhp => :c,
      :maxmp => :c,
      :atk   => :c,
      :def   => :c,
      :spi   => :c,
      :agi   => :c,
    }

    RANKS = {
      :a => Proc.new { |level| val = level * 5 + rand(3) },
      :b => Proc.new { |level| val = level * 4 + rand(2) },
      :c => Proc.new { |level| val = level * 3 + rand(2) },
      :d => Proc.new { |level| val = level * 2 + rand(1) },
      :e => Proc.new { |level| val = level * 1 + rand(1) }
    }

    USE_CLASS_GROWTH  = true
    USE_CLASS_PARAMS  = true
    CLASS_LEVELING = true
    CLASS_GROWTH_RATE = 100
    CLASS_GROWTH = { }
    CLASS_GROWTH[0] = {
    # :stat  => rank
      :maxhp => 100,
      :maxmp => 100,
      :atk   => 100,
      :def   => 100,
      :spi   => 100,
      :agi   => 100,
    }

    USE_SUBCLASSES        = true
    SUBCLASS_COUNT        = 2

    USE_SUBCLASS_PARAMS   = [true, false]
    USE_SUBCLASS_SKILLS   = [true, true]
    USE_SUBCLASS_GROWTHS  = [true, false]

    SUBCLASS_POINT_RATES  = [80, 60]
    SUBCLASS_EXP_RATES    = [75, 50]
    SUBCLASS_GROWTH_RATES = [70, 40]
    SUBCLASS_GROWTH = {}
    SUBCLASS_GROWTH[0] = {
    # :stat  => rank
      :maxhp => 100,
      :maxmp => 100,
      :atk   => 100,
      :def   => 100,
      :spi   => 100,
      :agi   => 100,
    }
#==============================================================================#
#                        End Primary Customization
#------------------------------------------------------------------------------#
#==============================================================================#
    module_function
#==============================================================================#
#                        Start Lunatic Customization
#------------------------------------------------------------------------------#
#==============================================================================#
    #--------------------------------------------------------------------------#
    # class_p_gain
    #--------------------------------------------------------------------------#
    # This method is called from battle and battlers when a skill/item effect
    # is done.
    #--------------------------------------------------------------------------#
    def class_p_gain(type, battler, obj = nil, user = nil)
      result = 0
      case type
      # ---------------------------------------------------------------------- #
      when :attack # type and battler are valid
        result = 5
        result += rand(10)
      # ---------------------------------------------------------------------- #
      when :guard # type and battler are valid
        result = 2
        result += rand(10)
      # ---------------------------------------------------------------------- #
      when :skill # type and battler are valid
        result = 5
        result += rand(10)
      # ---------------------------------------------------------------------- #
      when :item # type and battler are valid
        result = 10
        result += rand(10)
      # ---------------------------------------------------------------------- #
      when :use # type, battler, obj, user are all valid
        result = obj.class_p
      # ---------------------------------------------------------------------- #
      end
      # ---------------------------------------------------------------------- #
      battler.increase_classpoints(result)
      # ---------------------------------------------------------------------- #
      return result # Doesn't do anything really, but just for the sake of it
    end

    #--------------------------------------------------------------------------#
    # class_p_gain
    #--------------------------------------------------------------------------#
    # This method is called from battle and battlers when a skill/item effect
    # is done.
    #--------------------------------------------------------------------------#
    def class_exp_gain(type, battler, obj = nil, user = nil)
      result = 0
      case type
      # ---------------------------------------------------------------------- #
      when :attack # type and battler are valid
        result = 5
        result += rand(10)
      # ---------------------------------------------------------------------- #
      when :guard # type and battler are valid
        result = 2
        result += rand(10)
      # ---------------------------------------------------------------------- #
      when :skill # type and battler are valid
        result = 5
        result += rand(10)
      # ---------------------------------------------------------------------- #
      when :item # type and battler are valid
        result = 10
        result += rand(10)
      # ---------------------------------------------------------------------- #
      when :use # type, battler, obj, user are all valid
        result = obj.class_exp
      # ---------------------------------------------------------------------- #
      end
      # ---------------------------------------------------------------------- #
      battler.increase_classexp(result)
      # ---------------------------------------------------------------------- #
      return result # Doesn't do anything really, but just for the sake of it
    end

    def class_exp_max(obj, class_id)
      return 9999999
    end

    def class_p_max(obj, class_id)
      return 5000
    end

    def class_explist(lvlcls, class_id)
      #@exp_list[1] = @exp_list[100] = 0
      #m = actor.exp_basis
      #n = 0.75 + actor.exp_inflation / 200.0;
      #for i in 2..99
      #  @exp_list[i] = @exp_list[i-1] + Integer(m)
      #  m *= 1 + n;
      #  n *= 0.9;
      #end
      max = lvlcls.maxlevel
      result = Array.new(max+1)
      for i in 0..(max+1)
        result[i] = i * 50 + (i*10) # // Level * 50 + (level*10)
      end
      result[0] = result[max] = 0
      return result
    end

    def class_maxlevel(lvlcls, class_id)
      if ACTOR_CLASS_MAXLEVELS.has_key?(lvlcls.battler.id)
        cll = ACTOR_CLASS_MAXLEVELS[lvlcls.battler.id]
      else
        cll = ACTOR_CLASS_MAXLEVELS[0]
      end
      return cll[class_id] if cll.has_key?(class_id)
      return cll[0]
    end

    def class_parameter_ranks(class_id)
      return CLASS_PARAMS_SETUP[class_id] if CLASS_PARAMS_SETUP.has_key?(class_id)
      return CLASS_PARAMS_SETUP[0]
    end

    def assign_class_parameters(lvlcls, class_id)
      parameters = {}
      ref_param = class_parameter_ranks(class_id)
      for pr in PARAMETERS # Each Parameter
        pr = pr.to_sym
        parameters[pr] = Array.new(lvlcls.maxlevel)
        for i in 0..lvlcls.maxlevel
          #                [parameter][level]
          parameters[pr][i] = RANKS[ref_param[pr]].call(i)
        end
      end
      return parameters
    end

    #--------------------------------------------------------------------------#
    # * new method :use_subclasses?
    #--------------------------------------------------------------------------#
    def use_subclasses?(actor) ; return USE_SUBCLASSES ; end
    #--------------------------------------------------------------------------#
    # * new method :class_params?
    #--------------------------------------------------------------------------#
    def class_params?(actor)       ; return USE_CLASS_PARAMS        ; end
    #--------------------------------------------------------------------------#
    # * new method :class_growth?
    #--------------------------------------------------------------------------#
    def class_growth?(actor)       ; return USE_CLASS_GROWTH        ; end

    #--------------------------------------------------------------------------#
    # * new method :subclass_params?
    #--------------------------------------------------------------------------#
    def subclass_params?(n, actor) ; return USE_SUBCLASS_PARAMS[n]  ; end
    #--------------------------------------------------------------------------#
    # * new method :subclass_skills?
    #--------------------------------------------------------------------------#
    def subclass_skills?(n, actor) ; return USE_SUBCLASS_SKILLS[n]  ; end
    #--------------------------------------------------------------------------#
    # * new method :subclass_growth?
    #--------------------------------------------------------------------------#
    def subclass_growth?(n, actor) ; return USE_SUBCLASS_GROWTHS[n] ; end

    #--------------------------------------------------------------------------#
    # * new method :class_growth_rate
    #--------------------------------------------------------------------------#
    def class_growth_rate(actor)
      return CLASS_GROWTH_RATE
    end

    #--------------------------------------------------------------------------#
    # * new method :class_growth
    #--------------------------------------------------------------------------#
    def class_growth(actor)
      return CLASS_GROWTH[actor.class_id] if CLASS_GROWTH.has_key?(actor.class_id)
      return CLASS_GROWTH[0]
    end

    #--------------------------------------------------------------------------#
    # * new method :subclass_growth_rate
    #--------------------------------------------------------------------------#
    def subclass_growth_rate(n, actor)
      return SUBCLASS_GROWTH_RATES[n]
    end

    #--------------------------------------------------------------------------#
    # * new method :subclass_point_rate
    #--------------------------------------------------------------------------#
    def subclass_point_rate(n, actor)
      return SUBCLASS_POINT_RATES[n]
    end

    #--------------------------------------------------------------------------#
    # * new method :subclass_exp_rate
    #--------------------------------------------------------------------------#
    def subclass_exp_rate(n, actor)
      return SUBCLASS_EXP_RATES[n]
    end

    #--------------------------------------------------------------------------#
    # * new method :subclass_growth
    #--------------------------------------------------------------------------#
    def subclass_growth(n, actor)
      return SUBCLASS_GROWTH[actor.subclass_id(n)] if SUBCLASS_GROWTH.has_key?(actor.subclass_id(n))
      return SUBCLASS_GROWTH[0]
    end
    #--------------------------------------------------------------------------#
    # * new method :subclass_size
    #--------------------------------------------------------------------------#
    def subclass_size(actor) ; return SUBCLASS_COUNT ; end
#==============================================================================#
#                        End Lunatic Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  end
end

#==============================================================================#
# ** IEO::CLASS_SYSTEM::LevelClass
#==============================================================================#
module IEO
  module CLASS_SYSTEM

    SKILL_HASHMODE = false
    #SKILL_HASHMODE = IEO::SKILL_LEVEL::HASHMODE if $imported["IEO-SkillLevelSystem"]

    class LevelClass

      #--------------------------------------------------------------------------#
      # * Public Instance Variables
      #--------------------------------------------------------------------------#
      attr_reader   :battler
      attr_reader   :class_id
      attr_reader   :rpgclass
      attr_reader   :exp
      attr_reader   :exp_list
      attr_reader   :level
      attr_reader   :maxlevel
      attr_reader   :points
      attr_reader   :maxpoints
      attr_accessor :parameters

      #--------------------------------------------------------------------------#
      # * overwrite method :initialize
      #--------------------------------------------------------------------------#
      def initialize(battler, class_id)
        @battler    = battler
        @class_id   = class_id
        @rpgclass   = $data_classes[@class_id].clone
        @level      = 0
        @maxlevel   = IEO::CLASS_SYSTEM.class_maxlevel(self, @class_id)
        @exp        = 0
        @expmax     = IEO::CLASS_SYSTEM.class_exp_max(self, @class_id)
        @exp_list   = IEO::CLASS_SYSTEM.class_explist(self, @class_id)
        @points     = 0
        @maxpoints  = IEO::CLASS_SYSTEM.class_p_max(self, @class_id)
        @parameters = IEO::CLASS_SYSTEM.assign_class_parameters(self, @class_id)
        @skills     = []
        @skl_skills = []
        @skl_skills = {} if ::IEO::CLASS_SYSTEM::SKILL_HASHMODE
        for i in 0..@level
          learn_skills(i)
        end
      end

      #--------------------------------------------------------------------------#
      # * new method :skills_array
      #--------------------------------------------------------------------------#
      def skills_array ; return @skills end

      #--------------------------------------------------------------------------#
      # * new method :skill_can_use?
      #--------------------------------------------------------------------------#
      def skill_can_use?(skill)
        return false if skill.nil?
        return false unless @skl_skills.include?(skill) if $imported["IEO-SkillLevelSystem"]
        return false unless @skills.include?(skill.id)
        return true
      end

      #--------------------------------------------------------------------------#
      # * new method :skills
      #--------------------------------------------------------------------------#
      def skills
        result = []
        if $imported["IEO-SkillLevelSystem"]
          if ::IEO::CLASS_SYSTEM::SKILL_HASHMODE
            @skills.each { |i|
            learn_skl_skill(skill_id) unless @skl_skills.has_key?(i)
            result << @skl_skills[i]
          }
          else
            result = @skl_skills
          end
          return result
        end
        for i in @skills.compact
          result << $data_skills[i]
        end
        return result.compact
      end

      #--------------------------------------------------------------------------#
      # * new method :change_exp
      #--------------------------------------------------------------------------#
      def change_exp(exp)
        last_level = @level
        last_skills = skills
        @exp = [[exp, @expmax].min, 0].max
        while @exp >= @exp_list[@level+1] and @exp_list[@level+1] > 0
          level_up
        end
        while @exp < @exp_list[@level]
          level_down
        end
      end

      #--------------------------------------------------------------------------#
      # * new method :exp=
      #--------------------------------------------------------------------------#
      def exp=(val)
        change_exp(val)
      end

      #--------------------------------------------------------------------------#
      # * new method :snap_exp
      #--------------------------------------------------------------------------#
      def snap_exp # // Used to set exp to current level
        @exp = @exp_list[@level]
      end

      #--------------------------------------------------------------------------#
      # * new method :points=
      #--------------------------------------------------------------------------#
      def points=(val)
        @points = [[val, @maxpoints].min, 0].max
      end

      #--------------------------------------------------------------------------#
      # * new method :next_exp
      #--------------------------------------------------------------------------#
      def next_exp
        return @exp_list[@level+1] - @exp_list[@level]
      end

      #--------------------------------------------------------------------------#
      # * new method :level_exp
      #--------------------------------------------------------------------------#
      def level_exp
        return @exp - @exp_list[@level]
      end

      #--------------------------------------------------------------------------#
      # * new method :change_level
      #--------------------------------------------------------------------------#
      def change_level(new_level)
        @level = [[new_level, @maxlevel].min, 0].max
        learn_skills(@level)
      end

      #--------------------------------------------------------------------------#
      # * new method :level_up
      #--------------------------------------------------------------------------#
      def level_up(n=1)
        @level = [[@level + n, @maxlevel].min, 0].max
        learn_skills(@level)
      end

      #--------------------------------------------------------------------------#
      # * new method :level_down
      #--------------------------------------------------------------------------#
      def level_down(n=1)
        level_up(-n)
      end

      #--------------------------------------------------------------------------#
      # * new method :learn_skills
      #--------------------------------------------------------------------------#
      def learn_skills(level)
        for learning in @rpgclass.learnings
          learn_skill(learning.skill_id) if learning.level == level
        end
      end

      #--------------------------------------------------------------------------#
      # * new method :create_skl_skills
      #--------------------------------------------------------------------------#
      def create_skl_skills
        if ::IEO::CLASS_SYSTEM::SKILL_HASHMODE
          @skl_skills = { }
        else
          @skl_skills = [ ]
        end
      end

      #--------------------------------------------------------------------------#
      # * new method :learn_skill
      #--------------------------------------------------------------------------#
      def learn_skill(skill_id)
        create_skl_skills if @skl_skills.nil?
        unless @skills.include?(skill_id)
          @skills.push(skill_id) ; @skills.sort!
          learn_skl_skill(skill_id)
        end
      end

      #--------------------------------------------------------------------------#
      # * new method :learn_skl_skill
      #--------------------------------------------------------------------------#
      def learn_skl_skill(skill_id)
        duski = $data_skills[skill_id].clone ; duski.skl_skill = true
        if ::IEO::CLASS_SYSTEM::SKILL_HASHMODE
          @skl_skills[skill_id] = duski.clone
        else
          @skl_skills << duski.clone
        end
      end

      #--------------------------------------------------------------------------#
      # * new method :stat
      #--------------------------------------------------------------------------#
      def stat(nstat)
        case nstat.to_sym
        when :maxhp
          return @parameters[:maxhp][@level]
        when :maxmp
          return @parameters[:maxmp][@level]
        when :atk
          return @parameters[:atk][@level]
        when :def
          return @parameters[:def][@level]
        when :spi
          return @parameters[:spi][@level]
        when :agi
          return @parameters[:agi][@level]
        else
          return @parameters[nstat][@level]
        end
      end

    end
  end
end

#==============================================================================#
# ** IEO::Icon
#==============================================================================#
module IEO
  module Icon

    module_function

    def clssys(obj)   ; return 0 ; end
    def class(n)      ; return 0 ; end
    def classcmd      ; return 0 ; end

  end
#==============================================================================#
# ** IEO::Vocab
#==============================================================================#
  module Vocab

    module_function

    def classcmd(n)
      case n
      when 0 ; return "Class"
      when 1 ; return "Subclass"
      when 2 ; return "Support"
      end
    end

  end
end

#==============================================================================#
# ** IEO::REGEXP::CLASS_SYSTEM
#==============================================================================#
module IEO
  module REGEXP
    module CLASS_SYSTEM
      module ITEM
        CLASS_P   = /<(?:CLASS_P|CLASS P):[ ]*([\+\-]\d+)>/i
        CLASS_EXP = /<(?:CLASS_EXP|CLASS EXP):[ ]*([\+\-]\d+)>/i
      end
      module SKILL
        CLASS_P   = /<(?:CLASS_P|class p):[ ]*([\+\-]\d+)>/i
        CLASS_EXP = /<(?:CLASS_EXP|class exp):[ ]*([\+\-]\d+)>/i
        CLASS_LVL = /<(?:CLASS_LEVEL|class level):[ ]*(\d+)>/i
        CLASS_PCT = /<(?:CLASS_PCOST|class pcost):[ ]*(\d+)>/i
      end
      module ENEMY
        CLASS_P   = /<(?:CLASS_P|CLASS P):[ ]*(\d+)>/i
        CLASS_EXP = /<(?:CLASS_EXP|CLASS EXP):[ ]*(\d+)>/i
      end
    end
  end
end

#==============================================================================#
# ** RPG::Item
#==============================================================================#
class RPG::Item

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :class_p
  attr_accessor :class_exp

  #--------------------------------------------------------------------------#
  # * new method :ieo013_itemcache
  #--------------------------------------------------------------------------#
  def ieo013_itemcache
    @class_p   = 0
    @class_exp = 0
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when IEO::REGEXP::CLASS_SYSTEM::ITEM::CLASS_P
      @class_p = $1.to_i
    when IEO::REGEXP::CLASS_SYSTEM::ITEM::CLASS_EXP
      @class_exp = $1.to_i
    end }
    @ieo013_itemcache_complete = true
  end

end

#==============================================================================#
# ** RPG::Skill
#==============================================================================#
class RPG::Skill

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :class_p
  attr_accessor :class_exp
  attr_accessor :skl_skill

  #--------------------------------------------------------------------------#
  # * new method :ieo013_skillcache
  #--------------------------------------------------------------------------#
  def ieo013_skillcache
    @class_p   = 0
    @class_exp = 0
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when IEO::REGEXP::CLASS_SYSTEM::SKILL::CLASS_P
      @class_p = $1.to_i
    when IEO::REGEXP::CLASS_SYSTEM::SKILL::CLASS_EXP
      @class_exp = $1.to_i
    end }
    @ieo013_skillcache_complete = true
  end

end

#==============================================================================#
# ** RPG::Enemy
#==============================================================================#
class RPG::Enemy

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :class_p
  attr_accessor :class_exp

  #--------------------------------------------------------------------------#
  # * new method :ieo013_enemycache
  #--------------------------------------------------------------------------#
  def ieo013_enemycache
    @class_p   = 0
    @class_exp = 0
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when IEO::REGEXP::CLASS_SYSTEM::ENEMY::CLASS_P
      @class_p = $1.to_i
    when IEO::REGEXP::CLASS_SYSTEM::ENEMY::CLASS_EXP
      @class_exp = $1.to_i
    end }
    @ieo013_enemycache_complete = true
  end

end

#==============================================================================#
# ** RPG::Class0
#==============================================================================#
class RPG::Class0 < RPG::Class

  #--------------------------------------------------------------------------#
  # * super method :initialize
  #--------------------------------------------------------------------------#
  def initialize
    super
    @id = 0
    @name = "--------"
  end

end

#==============================================================================#
# ** Game_System
#==============================================================================#
class Game_System

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :class_leveling

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias :ieo013_gs_initialize :initialize unless $@
  def initialize
    ieo013_gs_initialize
    @class_leveling = IEO::CLASS_SYSTEM::CLASS_LEVELING
  end

end

#==============================================================================#
# ** Game_Battler
#==============================================================================#
class Game_Battler

  #--------------------------------------------------------------------------#
  # * alias method :skill_effect
  #--------------------------------------------------------------------------#
  alias :ieo013_skill_effect :skill_effect unless $@
  def skill_effect(user, skill)
    ieo013_skill_effect(user, skill)
    IEO::CLASS_SYSTEM.class_p_gain(:use, self, skill, user)
    IEO::CLASS_SYSTEM.class_exp_gain(:use, self, skill, user) if $game_system.class_leveling
  end

  #--------------------------------------------------------------------------#
  # * alias method :item_effect
  #--------------------------------------------------------------------------#
  alias :ieo013_item_effect :item_effect unless $@
  def item_effect(user, item)
    ieo013_item_effect(user, item)
    IEO::CLASS_SYSTEM.class_p_gain(:use, self, item, user)
    IEO::CLASS_SYSTEM.class_exp_gain(:use, self, item, user) if $game_system.class_leveling
  end

end

#==============================================================================#
# ** Game_Enemy
#==============================================================================#
class Game_Enemy < Game_Battler

  #--------------------------------------------------------------------------#
  # * alias method :initialize
  #--------------------------------------------------------------------------#
  alias ieo013_initialize initialize unless $@
  def initialize(index, enemy_id)
    @class_p = 0
    @class_p_limit = 0
    @class_exp = 0
    @class_exp_limit = 0
    ieo013_initialize(index, enemy_id)
    @class_p = enemy.class_p
    @class_p_limit = IEO::CLASS_SYSTEM.class_p_max(self, nil)
    @class_exp = enemy.class_exp
    @class_exp_limit = IEO::CLASS_SYSTEM.class_exp_max(self, nil)
  end

  #--------------------------------------------------------------------------#
  # * new method :class_p_limit
  #--------------------------------------------------------------------------#
  def class_p_limit ; return @class_p_limit end
  #--------------------------------------------------------------------------#
  # * new method :class_p
  #--------------------------------------------------------------------------#
  def class_p       ; return Integer(@class_p) end
  #--------------------------------------------------------------------------#
  # * new method :class_p=
  #--------------------------------------------------------------------------#
  def class_p=(val) ; @class_p = Integer([[val, 0].max, class_p_limit].min) end

  #--------------------------------------------------------------------------#
  # * new method :class_exp_limit
  #--------------------------------------------------------------------------#
  def class_exp_limit ; return @class_exp_limit end
  #--------------------------------------------------------------------------#
  # * new method :class_exp
  #--------------------------------------------------------------------------#
  def class_exp       ; return Integer(@class_exp) end
  #--------------------------------------------------------------------------#
  # * new method :class_exp=
  #--------------------------------------------------------------------------#
  def class_exp=(val) ; @class_exp = Integer([[val, 0].max, class_exp_limit].min) end

  #--------------------------------------------------------------------------#
  # * new method :increase_classpoints
  #--------------------------------------------------------------------------#
  def increase_classpoints(n) ; self.class_p += n end
  #--------------------------------------------------------------------------#
  # * new method :decrease_classpoints
  #--------------------------------------------------------------------------#
  def decrease_classpoints(n) ; increase_classpoints(-n) end
  #--------------------------------------------------------------------------#
  # * new method :increase_classexp
  #--------------------------------------------------------------------------#
  def increase_classexp(n) ; self.class_exp += n end
  #--------------------------------------------------------------------------#
  # * new method :decrease_classexp
  #--------------------------------------------------------------------------#
  def decrease_classexp(n) ; increase_classexp(-n) end

end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :unlocked_classes
  attr_accessor :unlocked_subclasses
  attr_accessor :subclass_ids
  attr_accessor :frozen_subclasses
  attr_accessor :frozen_classes
  attr_accessor :lock_class_change
  attr_accessor :lock_subclass_change

  #--------------------------------------------------------------------------#
  # * alias method :setup
  #--------------------------------------------------------------------------#
  alias ieo013_setup setup unless $@
  def setup(actor_id)
    setup_class_hashes
    @block_class = true
    ieo013_setup(actor_id)
    @block_class = false
  end

  #--------------------------------------------------------------------------#
  # * alias method :class
  #--------------------------------------------------------------------------#
  alias :ieo013_class :class unless $@
  def class
    unlock_class(@class_id) if @unlocked_classes[@class_id].nil?
    if @block_class
      t_class    = ieo013_class
      temp_class = Marshal.load(Marshal.dump(t_class)) # // Deep Clone
      temp_class.learnings = []
      return temp_class
    end
    return @unlocked_classes[@class_id] if @unlocked_classes.has_key?(@class_id)
    return ieo013_class
  end

  #--------------------------------------------------------------------------#
  # * new method :subclass_id
  #--------------------------------------------------------------------------#
  def subclass_id(n)
    return @subclass_ids[n]
  end

  #--------------------------------------------------------------------------#
  # * new method :set_subclass
  #--------------------------------------------------------------------------#
  def set_subclass(n, id)
    @subclass_ids[n] = id
  end

  #--------------------------------------------------------------------------#
  # * new method :subclass
  #--------------------------------------------------------------------------#
  def subclass(n)
    unlock_subclass( n, subclass_id(n)) if @unlocked_subclasses[n][subclass_id(n)].nil?
    return @unlocked_subclasses[n][subclass_id(n)]
  end

  #--------------------------------------------------------------------------#
  # * new method :subclasses?
  #--------------------------------------------------------------------------#
  def subclasses?
    return IEO::CLASS_SYSTEM.use_subclasses?(self)
  end

  #--------------------------------------------------------------------------#
  # * new method :subclass_size
  #--------------------------------------------------------------------------#
  def subclass_size
    return @subclass_ids.size
  end

  #--------------------------------------------------------------------------#
  # * new method :setup_class_hashes
  #--------------------------------------------------------------------------#
  def setup_class_hashes
    @levelclasses        = { }     if @levelclasses.nil?
    @unlocked_classes    = { }     if @unlocked_classes.nil?
    if @unlocked_subclasses.nil?
      @unlocked_subclasses = Array.new(IEO::CLASS_SYSTEM.subclass_size( self ))
      @unlocked_subclasses.map! { {} }
    end
    if @subclass_ids.nil?
      @subclass_ids        = Array.new(IEO::CLASS_SYSTEM.subclass_size( self ))
      @subclass_ids.map! { 0 }
    end
    @frozen_classes      = [ ]     if @frozen_classes.nil?
    @lock_class_change   = false
    if @frozen_subclasses.nil?
      @frozen_subclasses   = Array.new(IEO::CLASS_SYSTEM.subclass_size( self ))
      @frozen_subclasses.map! { {} }
    end
    @lock_subclass_change = Array.new(IEO::CLASS_SYSTEM.subclass_size( self )).map! { false }
    @class_hashes_complete = true
  end

  #--------------------------------------------------------------------------#
  # * new method :setup_class_data
  #--------------------------------------------------------------------------#
  def setup_class_data(class_id)
    setup_class_hashes unless @class_hashes_complete
    if @levelclasses[class_id].nil?
      @levelclasses[class_id] = IEO::CLASS_SYSTEM::LevelClass.new(self, class_id)
    end
  end

  #--------------------------------------------------------------------------#
  # * new method :level_class
  #--------------------------------------------------------------------------#
  def level_class(class_id)
    return nil unless class_id > 0
    setup_class_data(class_id)
    return @levelclasses[class_id]
  end

  #--------------------------------------------------------------------------#
  # * new method :increase_classpoints
  #--------------------------------------------------------------------------#
  def increase_classpoints(n)
    level_class(@class_id).points += n
    for ni in 0...(self.subclass_size)
      i = self.subclass_id(ni)
      val = Integer(n * IEO::CLASS_SYSTEM.subclass_point_rate(ni, self).to_f / 100.0)
      level_class(i).points += val if i > 0
    end if self.subclasses?
  end
  #--------------------------------------------------------------------------#
  # * new method :decrease_classpoints
  #--------------------------------------------------------------------------#
  def decrease_classpoints(n) ; increase_classpoints(-n) end
  #--------------------------------------------------------------------------#
  # * new method :increase_classexp
  #--------------------------------------------------------------------------#
  def increase_classexp(n)
    level_class(@class_id).exp += n
    for ni in 0...(self.subclass_size)
      i = self.subclass_id(ni)
      val = Integer(n * IEO::CLASS_SYSTEM.subclass_exp_rate(ni, self).to_f / 100.0)
      level_class(i).exp += val if i > 0
    end if self.subclasses?
  end
  #--------------------------------------------------------------------------#
  # * new method :decrease_classexp
  #--------------------------------------------------------------------------#
  def decrease_classexp(n) ; increase_classexp(-n) end

  #--------------------------------------------------------------------------#
  # * overwrite method :level_up
  #--------------------------------------------------------------------------#
  def level_up
    @level += 1
    if IEO::CLASS_SYSTEM.class_growth?(self)
      rate   = IEO::CLASS_SYSTEM.class_growth_rate(self)
      growth = IEO::CLASS_SYSTEM.class_growth(self)
      growth.keys.each do |key|
        str = key.to_s
        on = self.send(str)
        n = Integer(on * growth[key].to_f / 100.0)
        n -= on
        n = Integer(n * rate.to_f / 100.0)
        self.send(str"+=", n)
      end
    end
    for ni in 0...(self.subclass_size)
      if IEO::CLASS_SYSTEM.subclass_growth?(ni, self)
        rate   = IEO::CLASS_SYSTEM.subclass_growth_rate(ni, self)
        growth = IEO::CLASS_SYSTEM.subclass_growth(ni, self)
        growth.keys.each do |key|
          str = key.to_s
          on = self.send(str)
          n = Integer(on * growth[key].to_f / 100.0)
          n -= on
          n = Integer(n * rate.to_f / 100.0)
          self.send(str"+=", n)
        end
      end
    end if self.subclasses?
    #unless $game_system.class_leveling
    #  level_classes
    #end
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :class_id=
  #--------------------------------------------------------------------------#
  def class_id=(class_id)
    @class_id = class_id
    for i in 0..4     # Remove unequippable items
      change_equip(i, nil) unless equippable?(equips[i])
    end
    setup_class_data(class_id)
    unlock_class(class_id)
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :unlock_class
  #--------------------------------------------------------------------------#
  def unlock_class(class_id)
    return unless class_id > 0
    @unlocked_classes[class_id] = $data_classes[class_id]
  end

  #--------------------------------------------------------------------------#
  # * overwrite method :unlock_subclass
  #--------------------------------------------------------------------------#
  def unlock_subclass(n, class_id)
    return unless class_id > 0
    @unlocked_subclasses[n][class_id] = $data_classes[class_id]
  end

  #--------------------------------------------------------------------------#
  # * alias method :skill_learn?
  #--------------------------------------------------------------------------#
  alias ieo013_skill_learn? skill_learn? unless $@
  def skill_learn?(skill)
    return true if level_class(@class_id ).skill_can_use?( skill)
    return ieo013_skill_learn?(skill)
  end

  #--------------------------------------------------------------------------#
  # * alias method :skills
  #--------------------------------------------------------------------------#
  alias :ieo013_ga_skills :skills unless $@
  def skills
    result = []
    for n in 0...(self.subclass_size)
      i = self.subclass_id(n)
      result |= level_class(i).skills if i > 0 if IEO::CLASS_SYSTEM.subclass_skills?(n, self)
    end if self.subclasses?
    return ieo013_ga_skills | level_class(@class_id).skills | result
  end

  #--------------------------------------------------------------------------#
  # * alias methods :base_*
  #--------------------------------------------------------------------------#
  IEO::CLASS_SYSTEM::PARAMETERS.each do |meth|
    module_eval(%Q(
      alias :ieo013_base_#{meth} :base_#{meth} unless $@
      def base_#{meth}
        n = ieo013_base_#{meth}
        n += level_class(@class_id).stat("#{meth}") if IEO::CLASS_SYSTEM.class_params?(self)
        for ni in 0...(self.subclass_size)
          i = self.subclass_id(ni)
          n += level_class(i).stat("#{meth}") if i > 0 if IEO::CLASS_SYSTEM.subclass_params?(ni, self)
        end if self.subclasses?
        return Integer(n)
      end
    ), 'ieo/013_class_system/game_actor/params', 1)
  end

end

#==============================================================================#
# ** Game_Troop
#==============================================================================#
class Game_Troop < Game_Unit

  #--------------------------------------------------------------------------#
  # * new-method :distribute_classpoints
  #--------------------------------------------------------------------------#
  def distribute_classpoints
    class_p = 0
    for member in dead_members.compact        ; class_p += member.class_p end
    for member in $game_party.members.compact ; member.increase_classpoints(class_p) end
  end

  #--------------------------------------------------------------------------#
  # * new-method :distribute_classexp
  #--------------------------------------------------------------------------#
  def distribute_classexp
    class_exp = 0
    for member in dead_members.compact        ; class_exp += member.class_exp end
    for member in $game_party.members.compact ; member.increase_classexp(class_exp) end
  end

end

#==============================================================================#
# ** Game_Interpreter
#==============================================================================#
class Game_Interpreter

  #--------------------------------------------------------------------------#
  # * new-method :unlock_class
  #--------------------------------------------------------------------------#
  def unlock_class(actor_id, class_id)
    $game_actors[actor_id].unlock_class(class_id)
  end

  #--------------------------------------------------------------------------#
  # * new-method :freeze_class
  #--------------------------------------------------------------------------#
  def freeze_class(actor_id, class_id)
    $game_actors[actor_id].frozen_classes[class_id] = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :unfreeze_class
  #--------------------------------------------------------------------------#
  def unfreeze_class(actor_id, class_id)
    $game_actors[actor_id].frozen_classes[class_id] = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :lock_class_change
  #--------------------------------------------------------------------------#
  def lock_class_change(actor_id)
    $game_actors[actor_id].lock_class_change = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :unlock_class_change
  #--------------------------------------------------------------------------#
  def unlock_class_change(actor_id)
    $game_actors[actor_id].lock_class_change = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :unlock_subclass
  #--------------------------------------------------------------------------#
  def unlock_subclass(actor_id, n, class_id)
    $game_actors[actor_id].unlock_subclass(n, class_id)
  end

  #--------------------------------------------------------------------------#
  # * new-method :freeze_subclass
  #--------------------------------------------------------------------------#
  def freeze_subclass(actor_id, n, class_id)
    $game_actors[actor_id].frozen_subclasses[n][class_id] = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :unfreeze_subclass
  #--------------------------------------------------------------------------#
  def unfreeze_subclass(actor_id, n, class_id)
    $game_actors[actor_id].frozen_subclasses[n][class_id] = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :lock_subclass_change
  #--------------------------------------------------------------------------#
  def lock_subclass_change(actor_id, n)
    $game_actors[actor_id].lock_subclass_change[n] = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :unlock_subclass_change
  #--------------------------------------------------------------------------#
  def unlock_subclass_change(actor_id, n)
    $game_actors[actor_id].lock_subclass_change[n] = false
  end

end

#==============================================================================#
# ** Window_Base
#==============================================================================#
class Window_Base < Window

  #--------------------------------------------------------------------------#
  # * overwrite-method :draw_actor_class
  #--------------------------------------------------------------------------#
  def draw_actor_class(actor, x, y)
    draw_actor_class_strip(actor, x, y)
    #draw_level_class(actor, actor.class_id, x, y, 102)
  end

  #--------------------------------------------------------------------------#
  # * new-method :draw_actor_class_strip
  #--------------------------------------------------------------------------#
  def draw_actor_class_strip(actor, x, y)
    lvlcs = []
    lvlcs << actor.level_class(actor.class_id)
    icons = []
    icons << IEO::Icon.class(actor.class_id)
    actor.subclass_ids.each { |id|
      lvlcs << actor.level_class(id)
      icons << IEO::Icon.class(id)
    }
    xo = x
    self.contents.font.size  = 14
    self.contents.font.color = power_up_color
    self.contents.font.bold  = true
    for i in 0...icons.size
      icon = icons[i]
      draw_icon(icon, x+(i*24), y)
      self.contents.draw_text( x+(i*24), y, 24, 24,
       sprintf("%s%s", Vocab.level_a, lvlcs[i].level )
       ) unless lvlcs[i].nil? if $game_system.class_leveling
    end
    self.contents.font.color = normal_color
    self.contents.font.size = Font.default_size
    self.contents.font.bold = Font.default_bold
    if $game_system.class_leveling
      xo = x+(icons.size*24)
      ys = 24 / lvlcs.size
      for i in 0...lvlcs.size
        lvlc = lvlcs[i]
        next if lvlc.nil?
        rect = Rect.new(xo, y+(i*ys), 42, ys)
        draw_grad_bar(rect.clone, lvlc.level_exp, lvlc.next_exp,
         mp_gauge_color1, mp_gauge_color2, gauge_back_color,
         2, true)
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :draw_level_class
  #--------------------------------------------------------------------------#
  def draw_level_class(actor, class_id, x, y, width=112, enabled=true)
    #self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    lvlc = actor.level_class(class_id)
    clvl = lvlc.level
    icon = IEO::Icon.class(class_id)
    oxz  = icon.eql?(0) ? 0 : 20
    rect = Rect.new(x+oxz, y+12, width-oxz, 8)
    if $game_system.class_leveling
      draw_grad_bar(rect.clone, lvlc.level_exp, lvlc.next_exp,
        mp_gauge_color1, mp_gauge_color2, gauge_back_color,
        2, true)
      self.contents.font.size = 16
    else
      self.contents.font.size = 18
    end
    draw_icon(icon, x, y, enabled)
    if icon > 0
      x+=24 ; rect.width -= 24
    end
    clls = lvlc.rpgclass
    y += 4 unless $game_system.class_leveling
    self.contents.draw_text(x, y-4, rect.width, WLH, clls.name)
    self.contents.draw_text(x, y+4, rect.width+16, WLH, sprintf("%s%d", Vocab.level_a, clvl), 2) if $game_system.class_leveling
  end

  #--------------------------------------------------------------------------#
  # * new-method :draw_actor_class_p
  #--------------------------------------------------------------------------#
  def draw_actor_class_p(actor, crect)
    draw_skl_p(actor.level_class(actor.class_id), crect)
  end

  #--------------------------------------------------------------------------#
  # * new-method :draw_class_p
  #--------------------------------------------------------------------------#
  def draw_class_p(lvlclass, crect)
    self.contents.font.size = 14
    draw_icon(IEO::Icon.clssys(:class_p), crect.x+crect.width-32, crect.y)
    crect.y -= 4 ; crect.width -= 34
    self.contents.draw_text(crect, lvlclass.points, 2)
  end

end

#==============================================================================#
# ** Window_ClassCommmand
#==============================================================================#
class Window_ClassCommmand < Window_Selectable

  #--------------------------------------------------------------------------#
  # * initialize
  #--------------------------------------------------------------------------#
  def initialize(x, y, width, commands)
    @icon_only = true
    height = 56
    height += 24 if @icon_only
    super(x, y, width, height)
    @commands   = commands
    @column_max = [@commands.size, 1].max
    @item_max   = @commands.size
    @spacing    = 2
    refresh
    self.index  = 0
  end

  #--------------------------------------------------------------------------#
  # * command
  #--------------------------------------------------------------------------#
  def command ; return @commands[index] ; end

  #--------------------------------------------------------------------------#
  # * refresh
  #--------------------------------------------------------------------------#
  def refresh
    create_contents
    for i in 0...@item_max ; draw_item(i) ; end
    @last_index = -1
  end

  #--------------------------------------------------------------------------
  # * Get rectangle for displaying items
  #     index : item number
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = @icon_only ? 24 : (contents.width + @spacing) / @column_max - @spacing
    rect.height = @icon_only ? 24 : WLH
    rect.x = index % @column_max * (rect.width + @spacing)
    rect.y = (index / @column_max * rect.height)
    return rect
  end

  #--------------------------------------------------------------------------
  # * Draw Item
  #     index   : item number
  #     enabled : enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  def draw_item(index, enabled = true)
    rect = item_rect(index)
    #rect.x += 4
    #rect.width -= 8
    self.contents.clear_rect(rect)
    icon = IEO::Icon.classcmd(@commands[index])
    text = IEO::Vocab.classcmd(@commands[index])
    draw_icon(icon, rect.x, rect.y, enabled)
    if icon > 0
      rect.x += 24
      rect.width -= 24
    end
    self.contents.draw_text(rect, text) unless @icon_only
  end

  #--------------------------------------------------------------------------#
  # * update
  #--------------------------------------------------------------------------#
  def update
    super
    if @last_index != self.index
      @last_index = self.index
      rect = Rect.new(0, 24, self.contents.width, WLH)
      self.contents.clear_rect(rect)
      if @last_index > -1
        text = IEO::Vocab.classcmd(@commands[index])
        self.contents.draw_text(rect, text)
      end
    end if @icon_only
  end

end

#==============================================================================#
# ** Window_ActorClassStat
#==============================================================================#
class Window_ActorClassStat < Window_Base

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_reader :actor
  attr_reader :class_filter

  #--------------------------------------------------------------------------#
  # * change_targetClass
  #--------------------------------------------------------------------------#
  def initialize(x, y, width, height, actor = nil)
    super(x, y, width, height)
    self.actor = actor
    @class_filter = 0
    refresh
  end

  #--------------------------------------------------------------------------#
  # * class_filter=
  #--------------------------------------------------------------------------#
  def class_filter=(val)
    if val != @class_filter
      @class_filter = val
      #refresh
    end
  end

  #--------------------------------------------------------------------------#
  # * update_data
  #--------------------------------------------------------------------------#
  def update_data(new_actor, new_class_id)
    new_class_id       = 0 if new_class_id.nil?
    new_class_id       = new_class_id.id if new_class_id.is_a?(RPG::Class)
    skip_refresh = false
    if @actor != new_actor
      self.actor = new_actor
      skip_refresh = true
    end
    if (@class_filter == 0 ?
     (@dupactor.class_id != new_class_id) :
     (@dupactor.subclass_id(@class_filter-1) != new_class_id))
      change_targetClass(new_class_id, skip_refresh)
    end
  end

  #--------------------------------------------------------------------------#
  # * change_targetClass
  #--------------------------------------------------------------------------#
  def change_targetClass(new_class_id, skip_refresh = false)
    new_class_id       = 0 if new_class_id.nil?
    new_class_id       = new_class_id.id if new_class_id.is_a?(RPG::Class)
    @dupactor          = Marshal.load(Marshal.dump(@actor))
    case @class_filter
    when 0
      @dupactor.class_id = new_class_id
    else
      @dupactor.set_subclass(@class_filter-1, new_class_id)
    end
    refresh unless skip_refresh
  end

  #--------------------------------------------------------------------------#
  # * actor=
  #--------------------------------------------------------------------------#
  def actor=(new_actor)
    return if new_actor.nil?
    @actor    = new_actor
    @dupactor = @actor.clone
    refresh
  end

  #--------------------------------------------------------------------------#
  # * refresh
  #--------------------------------------------------------------------------#
  def refresh
    create_contents
    return if @actor.nil?
    stats = IEO::CLASS_SYSTEM::PARAMETERS
    rect = Rect.new(4, 4, self.contents.width-24, WLH)
    case @class_filter
    when 0
      cls1 = @actor.class.id
      cls2 = @dupactor.class.id
    else
      cls1 = @actor.subclass_id(@class_filter-1)
      cls2 = @dupactor.subclass_id(@class_filter-1)
    end
    draw_level_class(@actor, cls1, rect.x, rect.y) if cls1 > 0
    draw_level_class(@actor, cls2, rect.x+rect.width-96, rect.y) if cls2 > 0
    coun = 1
    for st in stats
      self.contents.font.size = 18
      rect = Rect.new(4, 4+(24*coun), self.contents.width, WLH)
      coun += 1
      self.contents.font.color = normal_color
      self.contents.draw_text(rect, st.upcase)
      rect.x += 64 ; rect.width -= 72
      st1 = @actor.send(st)
      st2 = @dupactor.send(st)
      self.contents.font.size = 16
      self.contents.draw_text(rect, st1)
      self.contents.font.size = 18
      next if cls2 == 0
      if st2 > st1
        self.contents.draw_text(rect, "<", 1)
        self.contents.font.color = power_up_color
      elsif st1 > st2
        self.contents.draw_text(rect, ">", 1)
        self.contents.font.color = knockout_color
      else
        self.contents.draw_text(rect, "=", 1)
        self.contents.font.color = system_color
      end
      self.contents.font.size = 16
      self.contents.draw_text(rect, st2, 2)
    end
  end

end

#==============================================================================#
# ** Window_CSL_ActorStrip
#==============================================================================#
class Window_CSL_ActorStrip < Window_Selectable

  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  ITEM_RECT = Rect.new(0, 0, 40, 40)
  CHARACTER_RECT = Rect.new(4, 4, 32, 32)

  #--------------------------------------------------------------------------#
  # * initialize
  #--------------------------------------------------------------------------#
  def initialize(x, y)
    super(x, y, Graphics.width, CHARACTER_RECT.height+ITEM_RECT.height) # 64
    self.index = 0
    @spacing = 4 ; @item_max = 1 ; @column_max = 1
    refresh
  end

  #--------------------------------------------------------------------------#
  # * actor
  #--------------------------------------------------------------------------#
  def actor ; return @data[self.index] end

  #--------------------------------------------------------------------------#
  # * item_rect
  #--------------------------------------------------------------------------#
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = ITEM_RECT.width
    rect.height = ITEM_RECT.height

    wd = (rect.width + @spacing) * @column_max
    ofx = (self.contents.width - wd) / 2

    rect.x = index % @column_max * (rect.width + @spacing) + ofx
    rect.y = (index / @column_max * rect.height)

    return rect
  end

  #--------------------------------------------------------------------------#
  # * refresh
  #--------------------------------------------------------------------------#
  def refresh
    @data = $game_party.members.compact
    @item_max = @data.size
    @column_max = [[1, @item_max].max, 12].min
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end

  #--------------------------------------------------------------------------#
  # * draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index, enabled = true)
    irect = item_rect(index)
    crect = irect.dup
    crect.x    += CHARACTER_RECT.x     ; crect.y     += CHARACTER_RECT.y
    crect.width = CHARACTER_RECT.width ; crect.height = CHARACTER_RECT.height
    self.contents.clear_rect(irect)
    mem = @data[index]
    return if mem.nil?
    # ---------------------------------------------------- #
    draw_actor_sprite(mem, crect.x, crect.y, enabled)
    #crect.width = irect.width
    # ---------------------------------------------------- #
    #draw_actor_skl_p(mem, crect.clone)
    # ---------------------------------------------------- #
  end

end

#==============================================================================#
# ** Window_Classlist
#==============================================================================#
class Window_Classlist < Window_Selectable

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :actor
  attr_accessor :class_filter

  #--------------------------------------------------------------------------#
  # * initialize
  #--------------------------------------------------------------------------#
  def initialize(x, y, width, height, actor = nil)
    super(x, y, width, height)
    @actor = actor
    @data  = {}
    self.index = 0
    @column_max = 1
    @class_filter = 0
    @last_filter = 0
    refresh
  end

  #--------------------------------------------------------------------------#
  # * valid_class?
  #--------------------------------------------------------------------------#
  def valid_class?(index=self.index)
    case @class_filter
    when 0
      return false if @actor.lock_class_change
      return false if @actor.subclass_ids.any? { |c| c == sclass(index).id }
      return false if @actor.frozen_classes[sclass(index).id] == true
    else
      return false if @actor.lock_subclass_change[@class_filter-1]
      return false if @actor.class_id == sclass(index).id
      return false if @actor.frozen_subclasses[n][sclass(index).id] == true
      for n in 0...(@actor.subclass_size)
        next if n == @class_filter-1
        i = @actor.subclass_id(n)
        return false if i == sclass(index).id
      end
    end
    return true
  end

  #--------------------------------------------------------------------------#
  # * sclass
  #--------------------------------------------------------------------------#
  def sclass(index=self.index) ; return @data[index] end

  #--------------------------------------------------------------------------#
  # * refresh
  #--------------------------------------------------------------------------#
  def refresh
    @last_filter = @class_filter
    @data = []
    case @class_filter
    when 0
      @data = @actor.unlocked_classes.values unless @actor.nil?
    else
      @data = @actor.unlocked_subclasses[@class_filter-1].values + [RPG::Class0.new] unless @actor.nil?
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end

  #--------------------------------------------------------------------------#
  # * draw_item
  #--------------------------------------------------------------------------#
  def draw_item(index)
    rect = item_rect(index)
    obj  = @data[index]
    self.contents.clear_rect(rect)
    return if obj.nil?
    enabled = valid_class?(index)
    self.contents.font.color = normal_color
    case @class_filter
    when 0
      if @actor.class == obj
        rect.x += 24 ; rect.width -= 24
      end
      self.contents.font.color = system_color if @actor.frozen_classes.include?(obj.id)
    else
      if @actor.subclass(@class_filter-1) == obj
        rect.x += 24 ; rect.width -= 24
      end unless obj.is_a?(RPG::Class0)
      self.contents.font.color = system_color if @actor.frozen_subclasses[@class_filter-1].include?(obj.id)
    end
    if !obj.is_a?(RPG::Class0)
      draw_level_class(@actor, obj.id, rect.x, rect.y, rect.width-52, enabled)
      draw_class_p(@actor.level_class(obj.id), rect)
    else
      self.contents.draw_text(rect, obj.name)
    end
  end

  #--------------------------------------------------------------------------#
  # * update
  #--------------------------------------------------------------------------#
  def update
    super
    self.index = [[self.index, @item_max-1].min, 0].max
    refresh if @last_filter != @class_filter
  end

end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias method :load_database
  #--------------------------------------------------------------------------#
  alias :ieo013_load_database :load_database unless $@
  def load_database
    ieo013_load_database
    load_ieo013_cache
  end

  #--------------------------------------------------------------------------#
  # * alias method :load_bt_database
  #--------------------------------------------------------------------------#
  alias :ieo013_load_bt_database :load_database unless $@
  def load_bt_database
    ieo013_load_bt_database
    load_ieo013_cache
  end

  #--------------------------------------------------------------------------#
  # * new method :load_ieo011_cache
  #--------------------------------------------------------------------------#
  def load_ieo013_cache
    objs = [ $data_items, $data_skills, $data_enemies ]
    objs.each { |group| group.each { |obj| next if obj.nil?
      obj.ieo013_itemcache if obj.is_a?(RPG::Item)
      obj.ieo013_skillcache if obj.is_a?(RPG::Skill)
      obj.ieo013_enemycache if obj.is_a?(RPG::Enemy) } }
  end

end

#==============================================================================#
# ** Scene_Battle
#==============================================================================#
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------#
  # * new method :perform_classpoint_gain
  #--------------------------------------------------------------------------#
  def perform_classpoint_gain(type = :attack, battler = nil)
    return if battler.nil?
    IEO::CLASS_SYSTEM.class_p_gain(type, battler)
  end

  #--------------------------------------------------------------------------#
  # * alias method :execute_action_attack
  #--------------------------------------------------------------------------#
  alias :ieo013_execute_action_attack :execute_action_attack unless $@
  def execute_action_attack
    ieo013_execute_action_attack
    perform_classpoint_gain(:attack, @active_battler)
  end

  #--------------------------------------------------------------------------#
  # * alias method :execute_action_guard
  #--------------------------------------------------------------------------#
  alias :ieo013_execute_action_guard :execute_action_guard unless $@
  def execute_action_guard
    ieo013_execute_action_guard
    perform_classpoint_gain(:guard, @active_battler)
  end

  #--------------------------------------------------------------------------#
  # * alias method :execute_action_skill
  #--------------------------------------------------------------------------#
  alias :ieo013_execute_action_skill :execute_action_skill unless $@
  def execute_action_skill
    ieo013_execute_action_skill
    perform_classpoint_gain(:skill, @active_battler)
  end

  #--------------------------------------------------------------------------#
  # * alias method :execute_action_item
  #--------------------------------------------------------------------------#
  alias :ieo013_execute_action_item :execute_action_item unless $@
  def execute_action_item
    ieo013_execute_action_item
    perform_classpoint_gain(:item, @active_battler)
  end

  #--------------------------------------------------------------------------#
  # * alias method :battle_end
  #--------------------------------------------------------------------------#
  alias :ieo013_battle_end :battle_end unless $@
  def battle_end(result)
    $game_troop.distribute_classpoints
    $game_troop.distribute_classexp if $game_system.class_leveling
    ieo013_battle_end(result)
  end

end

#==============================================================================#
# ** Scene_ClassChange
#==============================================================================#
class Scene_ClassChange < Scene_Base

  include IEX::SCENE_ACTIONS if $imported["IEX_SceneActions"]

  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  SLIDY_WINDOWS = IEO::CLASS_SYSTEM::SLIDY_WINDOWS
  SLIDY_WINDOWS = ($imported["IEX_SceneActions"] && SLIDY_WINDOWS)

  #--------------------------------------------------------------------------#
  # * initialize
  #--------------------------------------------------------------------------#
  def initialize(actor, called = :map, return_index=0)
    super
    # ---------------------------------------------------- #
    @calledfrom = called
    @return_index = return_index
    # ---------------------------------------------------- #
    @actor = nil
    @act_index = 0
    @index_call = false
    # ---------------------------------------------------- #
    if actor.kind_of?(Game_Battler)
      @actor = actor
    elsif actor != nil
      @actor = $game_party.members[actor]
      @act_index = actor
      @index_call = true
    end
    # ---------------------------------------------------- #
  end

  #--------------------------------------------------------------------------#
  # * start
  #--------------------------------------------------------------------------#
  def start
    # ---------------------------------------------------- #
    super
    create_menu_background
    # ---------------------------------------------------- #
    @iwps = [Graphics.width / 2, Graphics.height / 2,
      Graphics.width, Graphics.height]
    iwps  = @iwps
    # ---------------------------------------------------- #
    @windows = { }
    # ---------------------------------------------------- #
    @windows["Party"] = Window_CSL_ActorStrip.new(0, 0)
    @windows["Party"].active = false
    @windows["Party"].index = @act_index
    @windows["Party"].update_cursor
    # ---------------------------------------------------- #
    sh = iwps[1]
    @windows["Class"] = Window_Classlist.new( 0, @windows["Party"].height+56,
      iwps[0], sh, @windows["Party"].actor )
    # ---------------------------------------------------- #
    @windows["AStat"] = Window_ActorClassStat.new(
      @windows["Class"].width, @windows["Party"].height,
      iwps[0], iwps[3]-@windows["Party"].height )
    @windows["AStat"].update_data( @windows["Party"].actor,
     @windows["Class"].sclass )
    # ---------------------------------------------------- #
    #@windows["Level"] = Window_SKL_Level.new(
    #  0, @windows["Skill"].y + @windows["Skill"].height,
    #  iwps[0], iwps[3] - (@windows["Skill"].y + @windows["Skill"].height))
    # ---------------------------------------------------- #
    @windows["Command"] = Window_ClassCommmand.new(
      0, @windows["Party"].height,
      @windows["Class"].width, [0, 1, 2]
    )
    @windows["Class"].y = @windows["Command"].y + @windows["Command"].height
    # ---------------------------------------------------- #
    #(windows, value, rates=[DROP_RATE, RETURN_RATE], mult=1)
    if SLIDY_WINDOWS
      # ---------------------------------------------------- #
     # pull_windows_right(["SStat"], @windows["SStat"].width, [1, 1])
     # pull_windows_left(["Level", "Skill"], @windows["Skill"].width, [1, 1])
     # pull_windows_up(["Party"], @windows["Party"].height, [1, 1])
      # ---------------------------------------------------- #
    end
    @startup = true
    @class_filter = @windows["Command"].command
    # ---------------------------------------------------- #
  end

  #--------------------------------------------------------------------------#
  # * terminate
  #--------------------------------------------------------------------------#
  def terminate
    # ---------------------------------------------------- #
    super
    # ---------------------------------------------------- #
    dispose_menu_background
    # ---------------------------------------------------- #
    @windows.values.compact.each { |win| win.dispose }
    # ---------------------------------------------------- #
  end

  #--------------------------------------------------------------------------#
  # * change_class
  #--------------------------------------------------------------------------#
  def change_class(actor, class_id, filter)
    case filter
    when 0
      actor.class_id = class_id
    else
      actor.set_subclass(filter-1, class_id)
    end
    @windows["Class"].refresh
    @windows["AStat"].refresh
  end

  #--------------------------------------------------------------------------#
  # * return_scene
  #--------------------------------------------------------------------------#
  def return_scene
    if SLIDY_WINDOWS
      # ---------------------------------------------------- #
      #pull_windows_right(["SStat"], @windows["SStat"].width)
      #pull_windows_left(["Level", "Skill"], @windows["Skill"].width)
      #pull_windows_up(["Party"], @windows["Party"].height)
      # ---------------------------------------------------- #
    end
    case @calledfrom
    when :map
      $scene = Scene_Map.new
    when :menu
      $scene = Scene_Menu.new(@return_index)
    end
  end

  #--------------------------------------------------------------------------#
  # * update
  #--------------------------------------------------------------------------#
  def update
    update_party_shift
    if Input.trigger?(Input::B)
      return_scene
    elsif Input.trigger?(Input::C)
      return Sound.play_buzzer unless @windows["Class"].valid_class?
      Sound.play_equip
      change_class(@windows["Party"].actor, @windows["Class"].sclass.id, @windows["Command"].command)
    end
    # ---------------------------------------------------- #
    @windows["Command"].update
    fi = @windows["Command"].command
    if @class_filter != fi
      @class_filter = fi
      @windows["Class"].class_filter = @class_filter
      @windows["AStat"].class_filter = @class_filter
      @windows["AStat"].refresh
    end
    @windows["AStat"].update_data(@windows["Party"].actor, @windows["Class"].sclass)
    @windows["Party"].update
    @windows["Class"].update
    #for win in @windows.values.compact ; win.update if win.active end
    # ---------------------------------------------------- #
  end

  #--------------------------------------------------------------------------#
  # * update_party_shift
  #--------------------------------------------------------------------------#
  def update_party_shift
    # ---------------------------------------------------- #
    if Input.trigger?(Input::Y)
    # ---------------------------------------------------- #
      Sound.play_cursor
      @windows["Party"].index = (@windows["Party"].index + 1)
      @windows["Party"].index %= @windows["Party"].item_max
      @windows["Class"].actor = @windows["Party"].actor
      @windows["Class"].index = 0
      @windows["Class"].refresh
      @windows["AStat"].update_data(@windows["Party"].actor, @windows["Class"].sclass)
      @windows["AStat"].change_targetClass(@windows["Class"].sclass, true)
      @windows["AStat"].refresh
      Graphics.frame_reset
    # ---------------------------------------------------- #
    elsif Input.trigger?(Input::X)
    # ---------------------------------------------------- #
      Sound.play_cursor
      @windows["Party"].index = (@windows["Party"].index - 1)
      @windows["Party"].index %= @windows["Party"].item_max
      @windows["Class"].actor = @windows["Party"].actor
      @windows["Class"].index = 0
      @windows["Class"].refresh
      @windows["AStat"].update_data(@windows["Party"].actor, @windows["Class"].sclass)
      @windows["AStat"].change_targetClass(@windows["Class"].sclass, true)
      @windows["AStat"].refresh
      Graphics.frame_reset
    # ---------------------------------------------------- #
    end
  end

end
#==============================================================================#
IEO::REGISTER.log_script(13, "ClassSystem", 1.1) if $imported["IEO-Register"]
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
