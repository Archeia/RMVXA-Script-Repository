#Skill Features v1.0a
#----------#
#Features: Allows you to add features to skills, useful for support skills.
#
#Usage:    Usage:
#           You can have as many features as you want, set up in notes:
#           <FEATURE code id value>
#          But what are the codes, ids, and values?? Don't worry, it's right here:
#
#           Element Rate   = 11, element_id, float value
#           Debuff Rate    = 12, param_id, float value
#           State Rate     = 13, state_id, float value
#           State Resist   = 14, state_id, 0
#
#           Parameter      = 21, param_id, float value
#           Ex-Parameter   = 22, exparam_id, float value
#           Sp-Parameter   = 23, spparam_id, float value
#
#           Atk Element    = 31, element_id, 0
#           Atk State      = 32, state_id, float value
#           Atk Speed      = 33, 0, value
#           Atk Times+     = 34, 0, value
#
#           Add Skill Type = 41, skill_type, 0
#          Seal Skill Type = 42, skill_type, 0
#           Add Skill      = 43, skill_id, 0
#           Seal Skill     = 44, skill_id, 0
#
#           Equip Weapon   = 51, weapon_skill, 0
#           Equip Armor    = 52, armor_skill, 0
#           Fix Equip      = 53, item_type, 0
#           Seal Equip     = 54, item_type, 0
#           Slot Type      = 55, 1, 0
#
#           Action Times+  = 61, 0, value
#           Special Flag   = 62, flag_id, 0
#          Collapse Effect = 62, flag_id, 0
#           Party Ability  = 63, flag_id, 0
#
#     float value = percentage value where 1 = 100%, 0.75 = 75%, and 1.25 = 125%
#     param_id, 0=hp, 1=mp, 2=atk, 3=def, 4=mat, 5=mdf, 6=agi, 7=luk
#
#     Examples: <FEATURE 21 2 1.5> which would increase atk to 150%
#               <FEATURE 62 0 0>   which makes the item give the auto-battle flag
#               <FEATURE 32 1 0.5> which gives a 50% of applying death state
#
#----------#
#-- Script by: Vlue of Daimonious Tails
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)

class Game_Actor
  def feature_objects
    super + [actor] + [self.class] + equips.compact + skills
  end
  def features(code)
    if code == FEATURE_SKILL_ADD
      return all_features_noskills.select {|ft| ft.code == code }
    else
      return all_features.select {|ft| ft.code == code }
    end
  end
  def all_features_noskills
    feature_objects_noskills.inject([]) {|r, obj| r + obj.features }
  end
  def feature_objects_noskills
    states + [actor] + [self.class] + equips.compact
  end
end

class RPG::Skill
  def features
    all_features = []
    note = self.note.clone
    note =~ /<FEATURE (\d+) (\d+) (\d+.\d+|\d+)>/
    while $1
      all_features.push(RPG::BaseItem::Feature.new($1.to_i,$2.to_i,$3.to_f))
      note[note.index("FEAT")] = "*"
      note =~ /<FEATURE (\d+) (\d+) (\d+.\d+|\d+)>/
    end
    all_features
  end
end