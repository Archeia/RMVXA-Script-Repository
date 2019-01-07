##-----------------------------------------------------------------------------
## Stat Formulae and Regent Stats v1.0a
## Created by Neon Black
##
## For both commercial and non-commercial use as long as credit is given to
## Neon Black and any additional authors.  Licensed under Creative Commons
## CC BY 3.0 - http://creativecommons.org/licenses/by/3.0/.
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v1.0a - 9.12.2013
##  Added critical multiplier
## v1.0 - 9.11.2013
##  Wrote and debugged main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported ||= {}                                                              ##
$imported["RegentStatFormulae"] = 1.0                                         ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the script editor below "Materials" and above "Main".
## This script allows you to create formulae in certain noteboxes to change
## stats under certain conditions.  It also allows you to create your own
## custom stats known as "regent stats" which can be directly affected by
## things such as states and equips.  The tags are listed below.
##
##------
## hp formula[100]  -or-  mp formula[level * 10 + mat]  -etc-
##  - Sets a particular parameter, ex-parameter, or sp-parameter to a value
##    based on the number or value between the brackets.  This formula can be
##    anything including a script, similar to how damage formulae work for
##    skills.  Be careful not to include stats in each other's formulae since
##    it will cause an infinite loop and crash.  Valid values for stats
##    include:
##    hp, mhp, mp, mmp, atk, def, mat, mdf, agi, luk, hit, eva, cri, cev, mev,
##    mrf, cnt, hrg, mrg, trg, tgr, grd, rec, pha, mcr, tcr, pdr, mdr, fdr, exr
##    Note that hp and mhp both refer to max HP, same as mp and mmp.  Also note
##    that EX and SP parameters are assumed to be percentages with these tags.
##    This means that a final value of 50 represents 50%, etc.
##    This tag applies to actors, classes, and enemies.  Actor tags take
##    priority over class tags.
##
## crit base[3]  -or-  critcal base[1.0 + 0.01 * level]  -etc-
##  - The base multiplier for critical hit damage.  This is the number the
##    damage is multiplier by when a critical hit is struck.  This works in
##    much the same way that normal stats do.
##    This tag applies to actors, classes, and enemies.  Actor tags take
##    priority over class tags.
##
## crit damage + 1  -or-  critical damage ** level / 10 + 1  -etc-
##  - This tag works like a feature on any item with features.  This tag allows
##    a calculation to be applied to the base critical hit multiplier while the
##    feature is applied to the battler.  The formula may be applied in one of
##    6 different ways:
##     +  The formula is added to the base after it is calculated.
##     -  The formula is subtracted from the base after it is calculated.
##     *  The base is multiplied by the formula.
##     /  The base is divided by the formula.
##     ** The base is raised to the power of the formula.
##     %  The base divided by the formula and the remainder returned (modulus).
##    The features are applied in no particular order, so be aware that
##    addition could occur before multiplication.  The formula (after the first
##    operator) is always calculated before anything is done to the base value.
##
## regent value[:key] base[100]  -or-  regent[:key] base[agi + level]  -etc-
##  - Sets a base for a regent value.  Much like the stat formula tag, this tag
##    can use any formula between the brackets.  All regent values have a key
##    to identify them.  This key must start with a colon followed by a letter,
##    then may contain any combination of letters, numbers, and underscores.
##    For example, rather than :key you could use a key named :fire_power or
##    something similar.  This key can then be used to access the regent value
##    later.  If a battler does not have a regent value and one is pulled, it
##    uses the default value set in config.
##    This tag applies to actors, classes, and enemies.  Actor tags take
##    priority over class tags.
##
## regent value[:key] + 500  -or-  regent[:key] * agi + atk  -etc-
##  - Creates a feature on actors, classes, equips, enemies, or states that
##    modifies a regent stat from it's base.  The stat's base has a formula
##    applied to it in one or 6 different ways:
##     +  The formula is added to the base after it is calculated.
##     -  The formula is subtracted from the base after it is calculated.
##     *  The base is multiplied by the formula.
##     /  The base is divided by the formula.
##     ** The base is raised to the power of the formula.
##     %  The base divided by the formula and the remainder returned (modulus).
##    The features are applied in no particular order, so be aware that
##    addition could occur before multiplication.  The formula (after the first
##    operator) is always calculated before anything is done to the base value.
##
##------
## The regent stats are stored under the method "v" on a battler.  This means
## they can be quickly accessed by using .v[:key] in any kind of script call.
## For example, to use it in a damage formula, you may use a formula such as:
## a.atk + a.v[:bonus] - b.def / 2
## To get a value from actor ID 3 and store it in a variable, you could use
## a script set in variable control and use the following:
## $game_actors[3].v[:training]
## There is no real limit to how regent values can be used, so get creative.
##----------------------------------------------------------------------------##
                                                                              ##
module CPStatFormulae ## Do not touch this line                               ##
##----------------------------------------------------------------------------##
##    Config:
## The config options are below.  You can set these depending on the flavour of
## your game.  Each option is explained in a bit more detail above it.
##
##------
# This value is the base value for regent values when a base is not defined in
# a notebox.
BaseRegentValue = 100

# This range affects the critical multiplier.  This is the min and max values
# the critical hit damage may be multiplied by as well as the default base
# value.
CritMinMax = [1.5, 5]
CritBase = 3

# This hash stores the min and max values for stats on ACTORS.  This allows the
# default values to be broken.  Note that only normal parameters can be limited
# in this way.
ActorMinMax ={
  :mhp => [1, 9999],
  :mmp => [0, 9999],
  :atk => [1, 999],
  :def => [1, 999],
  :mat => [1, 999],
  :mdf => [1, 999],
  :agi => [1, 999],
  :luk => [1, 999],
}

# This hash stores the min and max values for stats on ENEMIES.  This allows
# the default values to be broken.  Again, this only works for parameters.
EnemyMinMax ={
  :mhp => [1, 999999],
  :mmp => [0, 9999],
  :atk => [1, 999],
  :def => [1, 999],
  :mat => [1, 999],
  :mdf => [1, 999],
  :agi => [1, 999],
  :luk => [1, 999],
}
##----------------------------------------------------------------------------##
                                                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------
  
  
  ## The basic bits used for REGEXP by certain objects.
  def base_stat_formulae
    set_base_stat_formulae unless @base_stat_formulae
    return @base_stat_formulae
  end
  
  def set_base_stat_formulae
    @base_stat_formulae = {}
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when /(hp|mhp|mp|mmp|atk|def|mat|mdf|agi|luk) formula\[(.+)\]/i
        i = $1.to_sym.downcase; i = i == :hp ? :mhp : i == :mp ? :mmp : i
        @base_stat_formulae[i] = $2.to_s
      when /(hit|eva|cri|cev|mev|mrf|cnt|hrg|mrg|trg) formula\[(.+)\]/i
        @base_stat_formulae[$1.to_sym.downcase] = $2.to_s
      when /(tgr|grd|rec|pha|mcr|tcr|pdr|mdr|fdr|exr) formula\[(.+)\]/i
        @base_stat_formulae[$1.to_sym.downcase] = $2.to_s
      end
    end
  end
  
  def base_crit_damage_form
    set_base_regent_formulae unless @base_regent_formulae
    return @base_crit_damage_val
  end
  
  def base_regent_formulae
    set_base_regent_formulae unless @base_regent_formulae
    return @base_regent_formulae
  end
  
  def set_base_regent_formulae
    @base_regent_formulae = {}
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when /(?:regent value|regent)?\[:(\w+)\] base\[(.+)\]/i
        @base_regent_formulae[$1.to_sym] = $2.to_s
      when /crit(?:ical)? base\[(.+)\]/i
        @base_crit_damage_val = $1.to_s
      end
    end
  end
end

class Game_BattlerBase
  ## Sets up the regent stats object for battlers.
  alias :cp_091113_init :initialize
  def initialize(*args)
    cp_091113_init(*args)
    @value_regents = ValueRegents.new(self)
  end
  
  def v
    @value_regents
  end
  
  ## This method allows classes that are not a superclass or subclass of a
  ## battler to properly evaluate in the battler's object enviroment, including
  ## a rescue value (as it almost certainly will be needed for newbies.
  def evaluate_stats(formula, rescue_value = 0)
    eval(formula) rescue rescue_value
  end
end

class Game_Battler < Game_BattlerBase
  alias :cp_091113_make_damage_value :make_damage_value
  def make_damage_value(user, item)
    @user_for_crit_value = user
    cp_091113_make_damage_value(user, item)
  end
  
  def apply_critical(damage)
    value = @user_for_crit_value.apply_crit_features
    mn, mx = *CPStatFormulae::CritMinMax
    damage * [mn, [mx, value].min].max
  end
  
  def apply_crit_features
    base = base_crit_damage
    features(:crit_damage).each do |fet|
      begin
        evsect = evaluate_stats(fet.value, :error_out)
        next if evsect == :error_out
        base = eval("#{base} #{fet.data_id} #{evsect}")
      rescue
        next
      end
    end
    return base
  end
end

##------
## Overwrites parameter based methods on actors.
class Game_Actor < Game_Battler
  def param_min(param_id)
    box = CPStatFormulae::ActorMinMax[RPG.parameter_symbol(param_id)]
    return box.nil? ? super(param_id) : box[0]
  end
  
  def param_max(param_id)
    box = CPStatFormulae::ActorMinMax[RPG.parameter_symbol(param_id)]
    return box.nil? ? super(param_id) : box[1]
  end
  
  def param_base(param_id)
    value = actor.base_stat_formulae[RPG.parameter_symbol(param_id)]
    return self.class.param_base(param_id, self) if value.nil?
    evaluate_stats(value)
  end
  
  def xparam(xparam_id)
    value = actor.base_stat_formulae[RPG.ex_parameter_symbol(xparam_id)]
    value ||= self.class.xparam_base(xparam_id)
    value = value.nil? ? 0 : evaluate_stats(value)
    value.to_f / 100 + super(xparam_id)
  end
  
  def sparam(sparam_id)
    value = actor.base_stat_formulae[RPG.sp_parameter_symbol(sparam_id)]
    value ||= self.class.sparam_base(sparam_id)
    value = value.nil? ? 100 : evaluate_stats(value, 100)
    value.to_f / 100 * super(sparam_id)
  end
  
  def base_crit_damage
    value = actor.base_crit_damage_form
    value ||= self.class.base_crit_damage_form
    base = CPStatFormulae::CritBase
    return value.nil? ? base : evaluate_stats(value, base)
  end
  
  def base_regent_value(key)
    value = actor.base_regent_formulae[key]
    value ||= self.class.base_regent_value(key)
    rvfloor = CPStatFormulae::BaseRegentValue
    value = value.nil? ? rvfloor : evaluate_stats(value, rvfloor)
    return value
  end
end

##------
## Overwrites parameter based methods on enemies.
class Game_Enemy < Game_Battler
  def param_min(param_id)
    box = CPStatFormulae::EnemyMinMax[RPG.parameter_symbol(param_id)]
    return box.nil? ? super(param_id) : box[0]
  end
  
  def param_max(param_id)
    box = CPStatFormulae::EnemyMinMax[RPG.parameter_symbol(param_id)]
    return box.nil? ? super(param_id) : box[1]
  end
  
  def param_base(param_id)
    value = enemy.base_stat_formulae[RPG.parameter_symbol(param_id)]
    return enemy.params[param_id] if value.nil?
    evaluate_stats(value)
  end
  
  def xparam(xparam_id)
    value = enemy.base_stat_formulae[RPG.ex_parameter_symbol(xparam_id)]
    value = value.nil? ? 0 : evaluate_stats(value)
    value.to_f / 100 + super(xparam_id)
  end
  
  def sparam(sparam_id)
    value = enemy.base_stat_formulae[RPG.sp_parameter_symbol(sparam_id)]
    value = value.nil? ? 100 : evaluate_stats(value, 100)
    value.to_f / 100 * super(sparam_id)
  end
  
  def base_crit_damage
    value = enemy.base_crit_damage_form
    base = CPStatFormulae::CritBase
    return value.nil? ? base : evaluate_stats(value, base)
  end
  
  def base_regent_value(key)
    value = enemy.base_regent_formulae[key]
    rvfloor = CPStatFormulae::BaseRegentValue
    value = value.nil? ? rvfloor : evaluate_stats(value, rvfloor)
    return value
  end
end

##-----
## Allows all classes to hold regent features rather than specifying simply
## certain classes at a single time.
class RPG::BaseItem
  include CPStatFormulae
  
  alias :cp_091113_features :features
  def features
    add_regent_value_features
    return cp_091113_features
  end
 
  def add_regent_value_features
    return if @regent_features_made; @regent_features_made = true
    note.split(/[\r\n]+/).each do |line|
      case line
      when /(?:regent value|regent)?\[:(\w+)\] (\+|-|\*\*|\*|\/|%) (.+)/i
        s = [$2.to_s, $3.to_s]
        f = RPG::BaseItem::Feature.new(:regent_value, $1.to_sym, s)
        @features.push(f)
      when /crit(?:ical)? damage (\+|-|\*\*|\*|\/|%) (.+)/i
        f = RPG::BaseItem::Feature.new(:crit_damage, $1.to_s, $2.to_s)
        @features.push(f)
      end
    end
  end
end

## Gives actors and enemies base stat tags.
class RPG::Actor < RPG::BaseItem
  include CPStatFormulae
end

class RPG::Enemy < RPG::BaseItem
  include CPStatFormulae
end

##------
## Gives classes (in game type) base tags and changes how they refer to stats.
class RPG::Class < RPG::BaseItem
  include CPStatFormulae
  
  def param_base(param_id, actor)
    value = base_stat_formulae[RPG.parameter_symbol(param_id)]
    return params[param_id, actor.level] if value.nil?
    actor.evaluate_stats(value)
  end
  
  def xparam_base(xparam_id)
    base_stat_formulae[RPG.ex_parameter_symbol(xparam_id)]
  end
  
  def sparam_base(sparam_id)
    base_stat_formulae[RPG.sp_parameter_symbol(sparam_id)]
  end
  
  def base_regent_value(key)
    base_regent_formulae[key]
  end
end

## Adds a few handlers for determining symbols from a type of number.
module RPG
  def self.parameter_symbol(param_id)
    [:mhp, :mmp, :atk, :def, :mat, :mdf, :agi, :luk][param_id]
  end
  
  def self.ex_parameter_symbol(xparam_id)
    [:hit, :eva, :cri, :cev, :mev, :mrf, :cnt, :hrg, :mrg, :trg][xparam_id]
  end
  
  def self.sp_parameter_symbol(sparam_id)
    [:tgr, :grd, :rec, :pha, :mcr, :tcr, :pdr, :mdr, :fdr, :exr][sparam_id]
  end
end

##------
## The regent value class.  This is used to add up all types of features
## together when needed and return a regent value.  This is only actually used
## when the value is called rather than holding them all at the same time.
class ValueRegents
  def initialize(member)
    @member = member
  end
  
  def [](key)
    base = @member.base_regent_value(key)
    @member.features(:regent_value).each do |fet|
      next unless fet.data_id == key
      begin
        evsect = @member.evaluate_stats(fet.value[1], :error_out)
        next if evsect == :error_out
        base = eval("#{base} #{fet.value[0]} #{evsect}")
      rescue
        next
      end
    end
    return base
  end
end
 
 
##-----------------------------------------------------------------------------
##  End of script.
##-----------------------------------------------------------------------------