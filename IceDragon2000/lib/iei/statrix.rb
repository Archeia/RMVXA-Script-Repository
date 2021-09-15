#-define SKPVERSION 0x10000
#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - Statrix"
#-define HDR_GDC :dc=>"07/07/2012"
#-define HDR_GDM :dm=>"07/07/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"SKPVERSION"
#-inject gen_script_header_wotail HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
#-inject gen_spacer
#-inject gen_script_header_tail
$simport.r 'iei/statrix', '1.0.0', 'IEI Statrix'
#-inject gen_class_header 'IEI::Statrix'
module IEI
  module Statrix
#-inject gen_function_des 'Start Customization'
    RATE_ID = {
      'mhp' => 0,
      'mmp' => 1,
      'atk' => 2,
      'def' => 3,
      'mat' => 4,
      'mdf' => 5,
      'agi' => 6,
      'luk' => 7,
    }
#-inject gen_function_des 'End Customization'

    def self.objs_param_rate param_id,objs
      objs.inject(1.0) do |r,obj| r *= obj.param_rate[param_id] end
    end

  end
end

#-inject gen_class_header 'RPG::EquipItem'
class RPG::EquipItem

  def param_rate
    unless @param_rate
      @param_rate = []
      IEI::RATE_ID.each_pair do |name,id|
        @param_rate[id] = (@note.match(/\<#{name}(?:[_ ]?rate)?:\s*(\d+)\%\>/i)||[0,100])[1].to_i/100.0
      end
    end
    @param_rate
  end

end

#-inject gen_class_header 'Game::Battler'
class Game::Battler

  def equips
    []
  end unless method_defined?(:equips)

  alias iei_statrix_param_rate param_rate
  def param_rate param_id
    iei_statrix_param_rate(param_id) * IEI::Statrix.objs_param_rate(param_id,equips)
  end

end
#-inject gen_script_footer
