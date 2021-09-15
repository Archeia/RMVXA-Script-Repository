#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - Eventrix : Loginix"
#-define HDR_GDC :dc=>"22/06/2012"
#-define HDR_GDM :dm=>"22/06/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"1.0"
#-inject gen_script_header HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
$simport.r 'iei/loginix', '1.0.0', 'IEI Loginix'
#-inject gen_module_header 'Eventrix'
module Eventrix
  module Loginix
    def and a, b
      a and b ? true : false
    end

    def or a, b
      a or b ? true : false
    end

    def buffer a
      !!a
    end

    def invert a
      !a
    end

    def nand a,b
      a and b ? false : true
    end

    def nor a,b
      a or b ? false : true
    end

    def xor a,b
      a or b and not a and b ? true : false
    end

    def xnor a,b
      a and b or !a and !b ? true : false
    end

    def switch_bool operand,sid
      bool = $game.switches[sid]
      case operand.upcase
      when 'INVERT', '!'
        bool = !bool
      when 'BUFFER', '@'
        bool = !!bool
      end
      bool
    end
    #@mapping = {
    #  and: method 'And',
    #  or: method 'Or',
    #  buffer: method 'Buffer',
    #  invert: method 'Invert',
    #  nand: method 'NAnd',
    #  nor: method 'NOr',
    #  xor: method 'XOr',
    #  xnor: method 'XNOr'
    #}
    #attr_reader :mapping

    extend self
  end
  # // Behaves like a Conditional Branch
  # // Place above a conditional branch, this overrides the original branching.
  # // DO NOT PLACE ANYTHING BETWEEN THE LOGINIX AND THE CONDITIONAL BRANCH
  # // EG:
  # //   LGNIX: AND @1 @2
  # //   your regular conditional branch
  gates = '(AND|OR|NAND|NOR|XOR|XNOR)'
  param = '(?:(BUFFER|\@|INVERT|\!):?)?(\d+)'

  add_command mk_uniq_code, /\A(?:LOGINIX|LGNIX)\:\s#{gates}\s#{param}\s#{param}/i, [:drop_next] do
    exparams = @params.first
    loginix = Eventrix::Loginix
    param1 = loginix.switch_bool exparams[2], exparams[3].to_i
    param2 = loginix.switch_bool exparams[4], exparams[5].to_i
    result = case exparams[1].upcase # // Logic
      when 'AND'  then loginix.and param1, param2
      when 'OR'   then loginix.or param1, param2
      when 'NAND' then loginix.nand param1, param2
      when 'NOR'  then loginix.nor param1, param2
      when 'XOR'  then loginix.xor param1, param2
      when 'XNOR' then loginix.xnor param1, param2
    end

    @branch[@indent] = result
    command_skip if !@branch[@indent]
  end
end
