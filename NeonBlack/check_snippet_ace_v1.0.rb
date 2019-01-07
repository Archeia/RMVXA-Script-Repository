###--------------------------------------------------------------------------###
#  Equipment and Skill Check Ace Scriptlet                                     #
#  Version 1.0                                                                 #
#                                                                              #
#      Credits:                                                                #
#  Original code by: Neonblack                                                 #
#  Modified by:                                                                #
#                                                                              #
#  This work is licensed under the Creative Commons Attribution 3.0 Unported   #
#  License. To view a copy of this license, visit                              #
#  http://creativecommons.org/licenses/by/3.0/.                                #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Revision information:                                                   #
#  V1.0 - 4.15.2012                                                            #
#   Converted from VX                                                          #
###--------------------------------------------------------------------------###

###--------------------------------------------------------------------------###
#      Instructions:                                                           #
#  This snippet adds the simple function to evaluate certain properties        #
#  related to the party that were not previously available.  These include     #
#  such things as checking if the party has particular items or weapons or     #
#  checking certain stats.  This can be used with script calls, in actual      #
#  scripts, or with the conditional branch script option.  This is meant to    #
#  be a scripters resource.                                                    #
###-----                                                                -----###
#      Usage:                                                                  #
#                                                                              #
#   Check.armour(x[, y]) -or- Check.armor(x[, y])                              #
#     - Used to check if the party has a particular piece of armour equipped   #
#       or not.  Use "x" to define the ID of the armour to check for.  "y" is  #
#       an optional value and does not need to be defined.  If "y" is "true"   #
#       then the ENTIRE party must be wearing the armour.  By default it is    #
#       false.                                                                 #
#                                                                              #
#   Check.weapon(x[, y])                                                       #
#     - Used to check if the party has a particular weapon equipped or not.    #
#       Use "x" to define the ID of the weapon to check for.  "y" is an        #
#       optional value and does not need to be defined.  If "y" is "true"      #
#       then the ENTIRE party must be wearing the weapon.  By default it is    #
#       false.                                                                 #
#                                                                              #
#   Check.skill(x[, y])                                                        #
#     - Used to check if the party has a particular skill learned or not.      #
#       Use "x" to define the ID of the skill to check for.  "y" is an         #
#       optional value and does not need to be defined.  If "y" is "true"      #
#       then the ENTIRE party must have learned the skill.  By default it is   #
#       false.                                                                 #
#                                                                              #
#   Check.state(x[, y])                                                        #
#     - Used to check if the party has a particular state afflicted or not.    #
#       Use "x" to define the ID of the state to check for.  "y" is an         #
#       optional value and does not need to be defined.  If "y" is "true"      #
#       then the ENTIRE party must be afflicted with the state.  By default    #
#       it is false.                                                           #
#                                                                              #
#   Check.stat[(x, y)]                                                         #
#     - Used to check the value of a certain stat.  Replace "stat" with one    #
#       of the following:                                                      #
#         atk, def, mat, mdf, agi, luk, hit, eva, cri, cev, mev, mrf, cnt,     #
#         hp, mp, mhp, mmp, perhp, permp, level                                #
#       "perhp" and "permp" are percentage checks that return a percent.       #
#       This method returns an integer rather than true or false.  There are   #
#       two arguments that can be used.  "x" defines the range of the value    #
#       to return where -1 = return lowest, 0 = return average, and            #
#       1 = return highest.  Be default, the highest value is returned.        #
#       "y" defines the variable to return the value to.  This can be useful   #
#       if you want to tell the player one of these values.                    #
###--------------------------------------------------------------------------###


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###



module Check
  def self.armor(check_arm, all = false)
    return armour(check_arm, all)
  end
  
  def self.armour(check_arm, all = false)
    for i in 0...$game_party.members.size
      chars = $game_party.members[i]
      result = (chars.armors.include?($data_armors[check_arm]))
      break if result == true unless all
      break if result == false if all
    end
    return result
  end
  
  def self.weapon(check_wep, all = false)
    for i in 0...$game_party.members.size
      chars = $game_party.members[i]
      result = (chars.weapons.include?($data_weapons[check_wep]))
      break if result == true unless all
      break if result == false if all
    end
    return result
  end
  
  def self.skill(check_ski, all = false)
    for i in 0...$game_party.members.size
      chars = $game_party.members[i]
      result = (chars.skill_learn?($data_skills[check_ski]))
      break if result == true unless all
      break if result == false if all
    end
    return result
  end
  
  def self.state(check_sta, all = false)
    for i in 0...$game_party.members.size
      chars = $game_party.members[i]
      result = (chars.state?(check_sta))
      break if result == true unless all
      break if result == false if all
    end
    return result
  end
  
  def self.atk(lah = 1, var = nil)
    return cstat(1, lah, var)
  end
  
  def self.def(lah = 1, var = nil)
    return cstat(2, lah, var)
  end
  
  def self.mat(lah = 1, var = nil)
    return cstat(3, lah, var)
  end
  
  def self.mdf(lah = 1, var = nil)
    return cstat(4, lah, var)
  end
  
  def self.agi(lah = 1, var = nil)
    return cstat(5, lah, var)
  end
  
  def self.luk(lah = 1, var = nil)
    return cstat(6, lah, var)
  end
  
  def self.mhp(lah = 1, var = nil)
    return cstat(7, lah, var)
  end
  
  def self.mmp(lah = 1, var = nil)
    return cstat(8, lah, var)
  end
  
  def self.hit(lah = 1, var = nil)
    return cstat(9, lah, var)
  end
  
  def self.eva(lah = 1, var = nil)
    return cstat(10, lah, var)
  end
  
  def self.cri(lah = 1, var = nil)
    return cstat(11, lah, var)
  end
  
  def self.cev(lah = 1, var = nil)
    return cstat(12, lah, var)
  end
  
  def self.mev(lah = 1, var = nil)
    return cstat(13, lah, var)
  end
  
  def self.mrf(lah = 1, var = nil)
    return cstat(14, lah, var)
  end
  
  def self.cnt(lah = 1, var = nil)
    return cstat(15, lah, var)
  end
  
  def self.hp(lah = 1, var = nil)
    return cstat(16, lah, var)
  end
  
  def self.mp(lah = 1, var = nil)
    return cstat(17, lah, var)
  end
  
  def self.level(lah = 1, var = nil)
    return cstat(100, lah, var)
  end
  
  def self.perhp(lah = 1, var = nil)
    return cstat(101, lah, var)
  end
  
  def self.permp(lah = 1, var = nil)
    return cstat(102, lah, var)
  end
  
  def self.cstat(stat, lah, var)
    var = nil if var < 1
    vi = 0
    si = $game_party.members.size
    for i in 0...$game_party.members.size
      chars = $game_party.members[i]
      vn = rstat(stat, chars)
      case lah
      when 0
        vi = vn if vn < vi or vi == 0
      when 1
        vi += vn
      when 2
        vi = vn if vi < vn
      end
    end
    vi /= si if lah == 1
    $game_variables[var] = Integer(vi) if var != nil
    return Integer(vi)
  end
  
  def self.rstat(stat, chars)
    case stat
    when 1
      return chars.atk
    when 2
      return chars.def
    when 3
      return chars.mat
    when 4
      return chars.mdf
    when 5
      return chars.agi
    when 6
      return chars.luk
    when 7
      return chars.mhp
    when 8
      return chars.mmp
    when 9
      return chars.hit
    when 10
      return chars.eva
    when 11
      return chars.cri
    when 12
      return chars.cev
    when 13
      return chars.mev
    when 14
      return chars.mrf
    when 15
      return chars.cnt
    when 16
      return chars.hp
    when 17
      return chars.mp
    when 100
      return chars.level
    when 101
      cs = chars.hp
      ms = chars.mhp
      rs = cs * 100 / ms
      return rs
    when 102
      cs = chars.mp
      ms = chars.mmp
      rs = cs * 100 / ms
      return rs
    end
  end
end

       # I overcomplicate things, no?
###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###