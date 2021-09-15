#encoding:UTF-8
# ISS026 - Note Inject 1.0
#==============================================================================#
# ** ISS - Note Inject
#==============================================================================#
# ** Date Created  : 08/30/2011
# ** Date Modified : 09/03/2011
# ** Created By    : IceDragon
# ** For Game      : S.A.R.A
# ** ID            : 026
# ** Version       : 1.0
# ** Requires      : ISS000 - Core(2.1 or above)
#==============================================================================#
($imported ||= {})["ISS-NoteInject"] = true
#==============================================================================#
# ** ISS::NoteInject
#==============================================================================#
module ISS
  install_script(26, :database)
  module NoteInject
    # // Skill note Inject
    SNI = []
    SNI << [1..50, "<atlevel(max) icon_index: +96>"]

    SNIH = {}
    SNI.each { |a| a[0].to_a.each { |i| (SNIH[i] ||= []) << a[1] } }
  end
end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base

  alias :iss025_sct_load_database :load_database unless $@
  def load_database(*args, &block)
    iss025_sct_load_database(*args, &block)
    load_iss025_cache()
  end

  alias :iss025_sct_load_bt_database :load_bt_database unless $@
  def load_bt_database(*args, &block)
    iss025_sct_load_bt_database(*args, &block)
    load_iss025_cache()
  end

  def load_iss025_cache()
    $data_skills.each { |obj| iss025_cache_object(obj) }
  end

  def iss025_cache_object(obj)
    case obj
    when RPG::Skill
      return unless ISS::NoteInject::SNIH.has_key?(obj.id)
      ISS::NoteInject::SNIH[obj.id].each { |n| obj.note += "\n#{n}" }
    end
  end

end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
