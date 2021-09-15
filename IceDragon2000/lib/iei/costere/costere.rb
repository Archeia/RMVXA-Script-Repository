#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - Costere"
#-define HDR_GDC :dc=>"02/28/2012"
#-define HDR_GDM :dm=>"05/26/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"1.0"
#-inject gen_script_header HDR_TYP, HDR_GNM, HDR_GAUT, HDR_GDC, HDR_GDM, HDR_VER
($imported||={})['IEI::Costere'] = 0x10000
#-inject gen_class_header 'RPG::Skill::Cost'
class RPG::Skill
  class Cost
    module Constants
      TYPE_NULL = 0   # No Cost
      TYPE_HP   = 1   # HP Cost
      TYPE_MP   = 2   # MP Cost Default
      TYPE_TP   = 3   # TP Cost
      # (type, CALC_FIXED, cost_int)
      # (type, CALC_FIXED, [:variable,id])
      CALC_FIXED    = 1  # Default
      # (type, CALC_RATE, cost_rate, stat_sym)
      # (type, CALC_RATE, cost_rate, maxstat_sym)
      # (type, CALC_RATE, cost_rate, [:variable,id])
      CALC_RATE1  = 2  # (stat * cost_rate).to_i
      # (type, CALC_RATE, cost_mod, stat_sym, maxstat_sym)
      # (type, CALC_RATE, cost_mod, [:variable,id], maxstat_sym)
      # (type, CALC_RATE, cost_mod, [:variable,id], [:variable,id])
      CALC_RATE2  = 3  # (cost_mod * current / max.to_f).to_i
      # (type, CALC_SCRIPT, "script")
      CALC_SCRIPT = 99 # Just use a script
    end
    include Constants

    attr_reader :type

    def initialize(type, calc_type, *params)
      @type   = type || TYPE_MP
      @calc_type = calc_type || CALC_FIXED
      @params = params
    end

    def arg_real(arg, subject)
      t, v = arg
      case t
      when :variable then $game.variables[v]
      when :subject  then subject.send(v)
      else                v
      end
    end

    def arg2string(arg, subject)
      arg_real(arg, subject).to_s
    end

    def arg2float(arg, subject)
      arg_real(arg, subject).to_f
    end

    def arg2rate(arg, subject)
      arg2float(arg, subject) / (arg[0] == :variable ? 100.0 : 1.0)
    end

    def arg2int(arg, subject)
      arg2float(arg, subject).to_i
    end

    def calc(subject)
      case @calc_type
      when CALC_FIXED
        arg2int(@params[0], subject)
      when CALC_RATE1
        r  = arg2rate(@params[0], subject)
        n  = arg2int(@params[1], subject)
        (r * n).to_i
      when CALC_RATE2
        n1 = arg2float(@params[0], subject)
        n2 = arg2float(@params[1], subject)
        n3 = arg2float(@params[2], subject)
        (n1 * n2 / n3.to_f).to_i
      when CALC_SCRIPT
        v = $game.variables
        s = $game.switches
        eval(arg2string(@params[0], subject)).to_i
      else
        0
      end
    end

    def cost_string(subject)
      calc(subject).to_s
    end

    def to_i
      calc(nil).to_s
    end
  end

  def calc_hp_cost(subject)
    hp_cost.calc(subject)
  end

  def calc_mp_cost(subject)
    mp_cost.calc(subject)
  end

  def calc_tp_cost(subject)
    tp_cost.calc(subject)
  end

  def hp_cost
    unless @hp_cost.is_a?(Cost)
      @hp_cost = Cost.new(Cost::TYPE_HP, Cost::CALC_FIXED, [:nil, @hp_cost])
    end
    @hp_cost
  end

  def mp_cost
    unless @mp_cost.is_a?(Cost)
      @mp_cost = Cost.new(Cost::TYPE_MP, Cost::CALC_FIXED, [:nil, @mp_cost])
    end
    @mp_cost
  end

  def tp_cost
    unless @tp_cost.is_a?(Cost)
      @tp_cost = Cost.new(Cost::TYPE_TP, Cost::CALC_FIXED,[:nil, @tp_cost])
    end
    @tp_cost
  end

  attr_writer :hp_cost, :mp_cost, :tp_cost
end
