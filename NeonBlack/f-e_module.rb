##-----------------------------------------------------------------------------
## Effects and Features names module v1.0a
## Created by Neon Black
##
## For both commercial and non-commercial use as long as credit is given to
## Neon Black and any additional authors.  Licensed under Creative Commons
## CC BY 3.0 - http://creativecommons.org/licenses/by/3.0/.
##-----------------------------------------------------------------------------

## Imported ID.  Revision 3.9.2013.
$imported ||= {}
$imported["CP_FEATURES_EFFECTS"] = 1.0
module CP
module VOCAB

##-----------------------------------------------------------------------------
## This module is a scripter's resource to easily access names of features and
## effects.  It does some general handling of features and such is meant to
## provide a single config option for the user end rather than requiring them
## to redo vocab options for features in numerous scripts.
##-----------------------------------------------------------------------------

##-----------------------------------------------------------------------------
## Has not been tested with and may not be compatible with Tsukihime's Effects
## Manager and Features Manager.  Compatability and use with them is planned in
## the future.
##-----------------------------------------------------------------------------

##-----------------------------------------------------------------------------
##    Config:
## Below is where you can name the different features.  There are several tags
## that will change automatically when a script calls the vocab option.  These
## are as follows:
##
##  <i> - Changes into a term used by the feature or effect.  For example, it
##        would change into the name of an element for an element related
##        feature.
##  <n> - Displays a number as either a normal positive number, or a negative
##        number.  Used for non-percentage values.
##  <+n> - Displays a number the same as above, but always displays the
##         operator.  In other words a positive number will display with a + in
##         front of it.
##  <n%> - Displays a number as a percentage.  If this is used on a normal
##         number, the number will be multiplied by 100, so avoid this.
##  <+n%> - Same as above but always displays the operator.
##  <+an%> - Displays the number as an "adjusted percent" based on a default
##           value of 100%.  This takes the base percentage and subtracts 100
##           from it, for example, 120% would display as +20% when using this.
##  <in%> - Similar to <+an%> except it increases the number by 100%.  This can
##          be used in cases where an item decreases a stat from a base of 100%
##          and you want it to display a flat percentage rather than a negative
##          value.  As an example, a value of -10% would become 90%.
##
## NOTE: For features you can also use the tags <n2>, <+n2>, <n2%>, <+n2%>,
##       <+an2%>, and <in2%>.  These are used for features which can have 2
##       values instead of just one.  It's important to note that if an effect
##       does not have a second value, nothing will be shown, not even 0.
##------
## The following hashes have a 4 digit method of identifying the vocab to use
## for base features and effects.  From the user's point of view:
##
##  12003
##      1 - This number is the PAGE the feature or effect appears on.
##      2 - This number is the RADIO BUTTON of the effect on it's page.
##    003 - If the feature has a drop down menu, this is it's position in the
##          menu starting with 1.  You can use 000 instead as a catch-all for
##          the feature.  Vocabs that end in numbers other than 000 have
##          priority over vocabs that end in 000. (See effect 21001 for an
##          example of this)
##          NOTE: For drop downs that reference skills or states, the drop down
##          actually starts at 2 instead of 1 in my listing, so if you want a
##          special vocab for a certain skill or state, add 1 to the item's ID
##          when determining the number for the vocab in the hash.  Avoid using
##          skill/state 999 and over because this will cause issues.
##-----------------------------------------------------------------------------

Features ={

# NEW FEATURES - Base Stats
#  These are not actually in the engine by default.  These are used by certain
#  of Neon Black's script for features that add an exact number of a parameter.
 1000 => "<+n> <i>",

# Page 1 - Resistances
11000 => "<i> Resist <n%>",
12000 => "<i> Sturdy <n%>",
13000 => "<i> Resist <n%>",
14000 => "<i> Immune",

# Page 2 - Parameters
#  The second and third options (EX-Parameters and XP-Parameters) have terms not
#  defined in the database.  They may be defeined here.
21000 => "<i> <+an%>",
22001 => "Hit Rate <+n%>",
22002 => "Evasion <+n%>",
22003 => "Critical <+n%>",
22004 => "Crit Evade <+n%>",
22005 => "Magic Evade <+n%>",
22006 => "Magic Reflect <+n%>",
22007 => "Counter <+n%>",
22008 => "HP Regen <+n%>",
22009 => "MP Regen <+n%>",
22010 => "TP Regen <+n%>",
23001 => "Agro <n%>",
23002 => "Guard Effect <n%>",
23003 => "Recovery Effect <n%>",
23004 => "Alchemy <n%>",
23005 => "MP Cost <n%>",
23006 => "TP Charge <n%>",
23007 => "Physical Rate <n%>",
23008 => "Magical Rate <n%>",
23009 => "Floor Damage <n%>",
23010 => "EXP Rate <n%>",

# Page 3 - Attack Effects
31000 => "<i> Strike",
32000 => "<i> Strike <+n%>",
33000 => "Speed <n>",
34000 => "Hits <n>",

# Page 4 - Skills
41000 => "<i> Caster",
42000 => "<i> Seal",
43000 => "Cast <i>",
44000 => "Seal <i>",

# Page 5 - Equips
51000 => "Equip <i>",
52000 => "Equip <i>",
53000 => "Lock <i>",
54000 => "Seal <i>",
55000 => "Dual-wield",

# Page 6 - Special
#  These have special types of terms that cannot be defined in the database.
#  Define them here.  NOTE: There is no 6301 (page 6, feature 3, option 1)
#  because it is the default death animation.  The drop down menu starts at
#  2 instead of 1 (6302).
61000 => "Added Action <n%>",
62001 => "Auto-fight",
62002 => "Strong Guard",
62003 => "True Knight",
62004 => "Save TP",
63002 => "Boss Collapse",
63003 => "Instant Collapse",
63004 => "Don't Collapse",
64001 => "Sneaking",
64002 => "Warding",
64003 => "Prevention",
64004 => "Surprising",
64005 => "x2 Gold",
64006 => "x2 Drop",
}

Effects ={

# Page 1 - Recovery
#  This is the only page that by default has 2 values.  Remember to use <n2%>
#  or a similar tag with 2 for these.
11000 => "Recover <n%><n2> <i>",
12000 => "Recover <n%><n2> <i>",
13000 => "Gain <n> <i>",

# Page 2 - States
#  Option 2101 is slightly different.  If you do not have a line 21001 here, you
#  will get a crash.  The "Normal Attack" state is used to reference all states
#  that can be applied by features and is option 1 in this case.
21000 => "Add <i> <n%>",
21001 => "Add Weapon States",
22000 => "Remove <i> <n%>",

# Page 3 - Buffs
31000 => "Buff <i> <n> turns",
32000 => "Debuff <i> <n> turns",
33000 => "Remove <i> buff",
34000 => "Remove <i> debuff",

# Page 4 - Special
#  Note that effect 44000 is used to call a common event.  In this case <i>
#  designates the common event's name.
41000 => "Escape Battle",
42000 => "<+n> <i>",
43000 => "Learn <i>",
44000 => "<i>",
}
##-----------------------------------------------------------------------------

##-----------------------------------------------------------------------------
##    For Scripters:
## This module currently only has a single real use.  You can quickly get the
## name of the effect or feature you're looking at by using the .vocab method.
## This will return a string similar to one of the strings above with the user's
## desired information.
##
## There are planned to be several other features, but they are not currently
## implimented.
##-----------------------------------------------------------------------------


###--------------------------------------------------------------------------###
#  The following lines are the actual core code of the script.  While you are  #
#  certainly invited to look, modifying it may result in undesirable results.  #
#  Modify at your own risk!                                                    #
###--------------------------------------------------------------------------###


  def self.feformat(voc, item = "", num = 0, num2 = 0)
    vp = num >= 0 ? '+' : ''
    vp2 = num2 >= 0 ? '+' : ''
    voc.gsub!(/<i>/i,     item)                                      #  <i>
    voc.gsub!(/<n>/i,     num == 0 ? "" : "#{num.to_i.to_s}")        #  <n>
    voc.gsub!(/<\+?n>/i,  "#{vp}#{num.to_i.to_s}")                   #  <+n>
    voc.gsub!(/<n\%>/i,   num == 0 ? "" : "#{(num * 100).to_i}%")    #  <n%>
    voc.gsub!(/<\+n\%>/i, "#{vp}#{(num * 100).to_i}%")               #  <+n%>
    voc.gsub!(/<n2>/i,     num2 == 0 ? "" : "#{num2.to_i.to_s}")     #  <n2>
    voc.gsub!(/<\+?n2>/i,  "#{vp2}#{num2.to_i.to_s}")                #  <+n2>
    voc.gsub!(/<n2\%>/i,   num2 == 0 ? "" : "#{(num2 * 100).to_i}%") #  <n%2>
    voc.gsub!(/<\+n2\%>/i, "#{vp2}#{(num2 * 100).to_i}%")            #  <+n%2>
    vp = num >= 1 ? '+' : ''
    vp2 = num2 >= 1 ? '+' : ''
    voc.gsub!(/<\+an\%>/i, "#{vp}#{(num * 100 - 100).to_i}%")        #  <+an%>
    voc.gsub!(/<\+an2\%>/i, "#{vp2}#{(num2 * 100 - 100).to_i}%")     #  <+an2%>
    voc.gsub!(/<\in\%>/i, "#{(num * 100 + 100).to_i}%")              #  <in%>
    voc.gsub!(/<\in2\%>/i, "#{(num2 * 100 + 100).to_i}%")            #  <in2%>
    voc
  end

end # VOCAB

module Features
  def self.get_feature(name, perc = "")
    case name.downcase
    when "mhp", "hp"; return perc != '%' ? [1, 0] : [21, 0]
    when "mmp", "mp"; return perc != '%' ? [1, 1] : [21, 1]
    when "atk"; return perc != '%' ? [1, 2] : [21, 2]
    when "def"; return perc != '%' ? [1, 3] : [21, 3]
    when "mat"; return perc != '%' ? [1, 4] : [21, 4]
    when "mdf"; return perc != '%' ? [1, 5] : [21, 5]
    when "agi"; return perc != '%' ? [1, 6] : [21, 6]
    when "luk"; return perc != '%' ? [1, 7] : [21, 7]
    when "hit"; return [22, 0]
    when "eva"; return [22, 1]
    when "cri"; return [22, 2]
    when "cev"; return [22, 3]
    when "mev"; return [22, 4]
    when "mrf"; return [22, 5]
    when "cnt"; return [22, 6]
    when "hrg"; return [22, 7]
    when "mrf"; return [22, 8]
    when "trg"; return [22, 9]
    when "tgr"; return [23, 0]
    when "grd"; return [23, 1]
    when "rec"; return [23, 2]
    when "pha"; return [23, 3]
    when "mcr"; return [23, 4]
    when "tcr"; return [23, 5]
    when "pdr"; return [23, 6]
    when "mdr"; return [23, 7]
    when "fdr"; return [23, 8]
    when "exr"; return [23, 9]
    else
      return nil unless $imported["Feature_Manager"]
      code = FeatureManager.get_feature_code(code.to_sym) rescue code = nil
      return code ? [code, 0] : nil
    end
  end
  
  def self.term_name(code, data_id)
    case code
    when 1, 12, 21
      return Vocab.param(data_id) || ""
    when 11, 31
      return $data_system.elements[data_id] || ""
    when 13, 14, 32
      return $data_states[data_id].name || ""
    when 43, 44
      return $data_skills[data_id].name || ""
    when 41, 42
      return $data_system.skill_types[data_id] || ""
    when 51
      return $data_system.weapon_types[data_id] || ""
    when 52
      return $data_system.armor_types[data_id] || ""
    when 53, 54
      return Vocab.etype(data_id) || ""
    else
      return ""
    end
  end
end # Features

module Effects
  def self.term_name(code, data_id)
    case code
    when 11
      return Vocab::hp_a
    when 12
      return Vocab::mp_a
    when 13
      return Vocab::tp_a
    when 21, 22
      return data_id == 0 ? "Normal Attack" : $data_states[data_id].name || ""
    when 31, 32, 33, 34, 42
      return Vocab.param(data_id) || ""
    when 43
      return $data_skills[data_id].name || ""
    when 44
      return $data_common_events[data_id].name || ""
    else
      return ""
    end
  end
end # Effects
end # CP

class RPG::BaseItem::Feature
  def vocab
    if @code.is_a?(Fixnum)
      n = @code * 1000 + (data_id + 1)
      i = @code * 1000
    else
      n = i = @code
    end
    voc = nil
    voc = CP::VOCAB::Features[n].dup if CP::VOCAB::Features.include?(n)
    voc ||= CP::VOCAB::Features[i].dup if CP::VOCAB::Features.include?(i)
    return "" if voc.nil?
    term = CP::Features.term_name(@code, @data_id)
    result = CP::VOCAB.feformat(voc, term, @value)
    return result
  end
end

class RPG::UsableItem::Effect
  def vocab
    if @code.is_a?(Fixnum)
      n = @code * 1000 + (@data_id + 1)
      i = @code * 1000
    else
      n = i = @code
    end
    voc = nil
    voc = CP::VOCAB::Effects[n].dup if CP::VOCAB::Effects.include?(n)
    voc ||= CP::VOCAB::Effects[i].dup if CP::VOCAB::Effects.include?(i)
    return "" if voc.nil?
    term = CP::Effects.term_name(@code, @data_id)
    result = CP::VOCAB.feformat(voc, term, @value1, @value2)
  end
end

class Game_BattlerBase
  FEATURE_BASE_PARAM = 1
  
  alias cp_featurevocab_param_plus param_plus
  def param_plus(param_id)
    cp_featurevocab_param_plus(param_id) +
    features_sum(FEATURE_BASE_PARAM, param_id)
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###