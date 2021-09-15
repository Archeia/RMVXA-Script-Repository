#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - NoteEval"
#-define HDR_GDC :dc=>"04/28/2012"
#-define HDR_GDM :dm=>"05/26/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"0x01000"
#-inject gen_script_header HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
$simport.r 'iei/note_eval', '1.0.0', 'IEI Note Eval'
#-inject gen_module_header 'IEI::NoteEval'
#-inject gen_class_header 'RPG::BaseItem'
class RPG::BaseItem

  def note_eval
    get_note_folders(IEI::Core.mk_notefolder_tags("note[_ ]?eval")).each{|a|eval(a.join("\n"))}
  end

end
#-inject gen_script_footer
