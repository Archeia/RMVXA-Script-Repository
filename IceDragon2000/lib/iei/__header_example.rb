#-define SKPVERSION#=0x10000
#-define HDR_TYP#=:type=>"class"
#-define HDR_GNM#=:name=>"IEI - Something"
#-define HDR_GDC#=:dc=>"27/06/2012"
#-define HDR_GDM#=:dm=>"27/06/2012"
#-define HDR_GAUT#=:author=>"IceDragon"
#-define HDR_VER#=:version=>"SKPVERSION"
#-inject gen_script_header_wotail HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
#-inject gen_spacer
#-inject gen_script_des 'Requirements'

#-inject gen_script_des 'Introduction' 

#-inject gen_script_des 'Instruction Manual'

#-inject gen_script_des 'Reference Manual'  
  
#-inject gen_script_header_tail