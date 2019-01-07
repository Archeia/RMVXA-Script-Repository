###-----------------------------------------------------------------------------
#  Non-targetable State v1.0
#  Created by Neon Black
#  V1.0 - 3.14.2013 - Version created for release
#  For both commercial and non-commercial use as long as credit is given to
#  Neon Black and any additional authors.  Licensed under Creative Commons
#  CC BY 4.0 - http://creativecommons.org/licenses/by/4.0/
#
#  To use this script, simply tag anything with features with the tag
#  <no target> in the brackets.  A target with this feature cannot be the
#  the target of anything until only non-targetable battlers are all dead.
#  You can also tag enemies with the tag <never target> and these enemies
#  cannot be targetted at all.  They do not need to be killed to win the
#  battle.
###-----------------------------------------------------------------------------


class RPG::BaseItem
  alias_method "cp_031514_features", "features"
  def features(*args)
    cp_031514_features(*args)
    make_no_target_features unless @made_no_target_features
    return @features
  end
  
  def make_no_target_features
    @made_no_target_features = true
    self.note.split(/[\r\n]+/).each do |line|
      case line
      when /<no target>/i
        @features.push(RPG::BaseItem::Feature.new(:no_target, 0, 1))
      when /<never target>/i
        @features.push(RPG::BaseItem::Feature.new(:never_target, 0, 1))
      end
    end
  end
end


class Game_BattlerBase
  def no_target?
    features_sum_all(:no_target) > 0.0
  end
  
  def never_target?
    features_sum_all(:never_target) > 0.0
  end
  
  def cp_targ_ok
    alive? && !no_target? && !never_target?
  end
  
  def cp_targ_no
    alive? && no_target? && !never_target?
  end
end


class Game_Unit
  def alive_members
    target_ok = members.select {|member| member.cp_targ_ok }
    target_no = members.select {|member| member.cp_targ_no }
    return target_ok.empty? ? target_no : target_ok
  end
end