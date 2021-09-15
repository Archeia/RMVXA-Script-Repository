#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - Exectine"
#-define HDR_GDC :dc=>"04/28/2012"
#-define HDR_GDM :dm=>"05/26/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"1.0"
#-inject gen_script_header HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
$simport.r 'iei/exectine', '0.1.0', 'IEI Exectine'
#-inject gen_module_header 'IEI::Exectine'
module IEI
  module Exectine
    module Constants
      EXC_NULL     = 0 # // No Skill Execution
      EXC_NORMAL   = 1 # // Normal MP/HP/TP
      EXC_ALCHEMY  = 2 # // Equivalent Exchange
      EXC_CHARGE   = 3 # // Charge
      EXC_SEQUENCE = 4 # // Sequenced
    end

    module Include
      include Constants

      def pre_init_iei
        super
        @exc_types = Hash.new
        @exc_types.default = EXC_NORMAL
      end

      def skill_exc(skill_id)
        @exc_types[skill_id]
      end

      def skill_cost_payable?(skill)
        case skill_exc skill.id
        when EXC_NULL     ; true
        when EXC_NORMAL   ; super skill
        when EXC_ALCHEMY  ;
        when EXC_CHARGE   ; skill_charged? skill
        when EXC_SEQUENCE ; true
        end
      end

      def skill_charged?(skill)
        @skl_charges[skill.id] >= 100
      end

      def set_skill_charge(id, n)
        @skl_charges[id] = (@skl_charges[id] + n).clamp(0,100)
      end
    end
  end
end
