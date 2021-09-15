#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - KeyNValue"
#-define HDR_GDC :dc=>"04/28/2012"
#-define HDR_GDM :dm=>"05/26/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>'0x01000'
#-inject gen_script_header HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
$simport.r 'iei/key_and_value', '0.1.0', 'IEI Key and Value'
#-inject gen_class_header 'RPG::BaseItem'
class RPG::BaseItem
  def knv
    unless @knv
      str = "note[_ ]?knv"
      @knv = get_note_folders(IEI::Core.mk_notefolder_tags(str)).inject({}) do |r,a|
        a.each{|s|mtch = s.match(/(.*)=(.*)/i);r[s[1].downcase]=s[2] if(mtch)};r
      end
    end
    @knv
  end

  attr_writer :knv
end
#-inject gen_script_footer
