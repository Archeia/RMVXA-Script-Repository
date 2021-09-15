#encoding:UTF-8
#==============================================================================#
# ** IEO(Icy Engine Omega) - Passive States
#-*--------------------------------------------------------------------------*-#
# ** Author        : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : Change (State, Battler)
# ** Script Type   : State Modifier
# ** Date Created  : 09/04/2011
# ** Date Modified : 09/11/2011
# ** Script Tag    : IEO-017(PassiveStates)
# ** Difficulty    : Medium, Hard, Lunatic
# ** Version       : 1.0
# ** IEO ID        : 017
#-*--------------------------------------------------------------------------*-#

#==============================================================================#
# $imported - Is mostly used by Japanese RPG Maker XP/VX scripters.
#             This acts as a flag, or signal to show that "x" script is present.
#             This is used for compatability with other future scripts.
($imported ||= {})['IEO-PassiveStates'] = true
#==============================================================================#
# $ieo_script - This is a hash specific to IEO scripts
#               they work just like the $imported, but there key is slightly
#               different, it is an array conatining an integer
#               and a string, since IEO script all have an ID, the value
#               is the scripts version number.
#               A version number of nil, or 0 means the script isn't present
# EG. $ieo_script[[ScriptID, 'ScriptName']]
($ieo_script ||= {})[[17, 'PassiveStates']] = 1.0
#-*--------------------------------------------------------------------------*-#
#==============================================================================#
#==============================================================================#
# ** IEO::SLIPDAMAGE
#==============================================================================#
module IEO
  module PassiveStates
    CLASS_PERMA_STATES = {}

    CLASS_PERMA_STATES[1] = [17, 18, 19]
    CLASS_PERMA_STATES[11] = [17]

    def self.post_load_database
      objs = [$data_states, $data_classes]
      objs.each do |group|
        group.reject(&:nil?).each do |obj|
          #obj.ieo017_statecache if obj.is_a?(RPG::State)
          obj.ieo017_classcache if obj.is_a?(RPG::Class)
        end
      end
    end
  end
end

#==============================================================================#
# ** RPG::Class
#==============================================================================#
class RPG::Class
  attr_accessor :perma_passives

  def ieo017_classcache
    @perma_passives = []
    per = IEO::PassiveStates::CLASS_PERMA_STATES[@id]
    @perma_passives += per unless per.nil?
  end
end

#==============================================================================#
# ** Game_Battler
#==============================================================================#
class Game_Battler
  alias :ieo017_gmbt_initialize :initialize unless $@
  def initialize(*args, &block)
    ieo017_gmbt_initialize(*args, &block)
    @passives = {}
  end

  def learn_passive(pid)
    @passives[pid] = $data_states[pid].deep_clone if @passives[pid].nil?
  end

  def passive_states
    []
  end

  alias :ieo017_gmb_states :states unless $@
  def states(*args, &block)
    ieo017_gmb_states(*args, &block) | passive_states
  end
end

#==============================================================================#
# ** Game_Actor
#==============================================================================#
class Game_Actor
  def class_passives
    self.class.perma_passives.reduce([]) { |r, s| r << $data_states[s] }
  end

  def passive_states
    super | class_passives
  end
end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------#
  # * alias method :load_database
  #--------------------------------------------------------------------------#
  alias :ieo017_sct_load_database :load_database unless $@
  def load_database
    ieo017_sct_load_database
    IEO::PassiveStates.post_load_database
  end

  #--------------------------------------------------------------------------#
  # * alias method :load_bt_database
  #--------------------------------------------------------------------------#
  alias :ieo017_sct_load_bt_database :load_database unless $@
  def load_bt_database
    ieo017_sct_load_bt_database
    IEO::PassiveStates.post_load_database
  end
end
#==============================================================================#
IEO::REGISTER.log_script(17, "PassiveStates", 1.0) if $imported["IEO-Register"]
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
