#encoding:UTF-8
# ISSS01 - General Load 1.0
#==============================================================================#
# ** ISS - S-GeneralLoad
#==============================================================================#
# ** Date Created  : 08/01/2011
# ** Date Modified : 08/01/2011
# ** Created By    : IceDragon
# ** For Game      : Code JIFZ
# ** ID            : S01
# ** Version       : 1.0
# ** Requires      : ISS000 - Core(1.1 or above)
#==============================================================================#
($imported ||= {})["ISS-GeneralLoad"] = true
#==============================================================================#
# ** ISS
#==============================================================================#
module ISS
end

#==============================================================================#
# ** Game_Event
#==============================================================================#
class Game_Event
  ISS.get_scripts_of_type( :event ).each { |sid| iss_nullcache :event, sid }

  alias :isss01_ge_setup :setup unless $@
  def setup( *args, &block )
    isss01_ge_setup( *args, &block )
    isss01_eventcaches
  end

  def isss01_eventcaches
    scripts = ISS.get_scripts_of_type( :event )
    scripts.each { |sid| self.send("iss#{"%03d"%sid}_eventcache_start") }
    unless @list.nil?
      ISS.each_comment( @list ) do |comment|
        break if comment =~ /<stopcache>/i
        scripts.each { |sid| self.send("iss#{"%03d"%sid}_eventcache_check", comment) }
      end
    end
    scripts.each { |sid| self.send("iss#{"%03d"%sid}_eventcache_end") }
  end
end

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
