# ╔══════════════════════════════════════════════════════╦═══════╤═══════════╗
# ║ Tales of Graces Title System -                       ║ v1.00 │ (6/02/13) ║
# ║   Titles Volume 2: State and Element Bonuses         ╠═══════╧═══════════╝
# ╚══════════════════════════════════════════════════════╝
# Script by:
#     Mr. Bubble ( http://mrbubblewand.wordpress.com/ )
#--------------------------------------------------------------------------
# All titles in this volume requires the script "Arbitrary Records"
# found at http://mrbubblewand.wordpress.com/
#
# This volume also has many examples on how to use Preset Ranks.
# Preset Ranks are defined in the Main Script. Please refer
# to the Preset Ranks documention to understand how they
# are defined.
#
# Examine these titles and learn how to create your own variations.
#--------------------------------------------------------------------------
#      Changelog   
#--------------------------------------------------------------------------
# v1.00 : Initial release. (6/02/2013)
#--------------------------------------------------------------------------
#      Installation & Requirements
#--------------------------------------------------------------------------
# Install this script in the Materials section in your project's
# script editor below the main script script "Tales of Graces Title 
# System".
#
# This script also requires the script "Arbitrary Records" installed
# in your script editor.
#--------------------------------------------------------------------------
#      Terms and Conditions   
#--------------------------------------------------------------------------
# Please do not repost this script elsewhere without permission. 
# Free for non-commercial use. For commercial use, contact me first.
#
# Newest versions of this script can be found at 
#                                           http://mrbubblewand.wordpress.com/
#=============================================================================

$imported ||= {}
$imported["BubsTitlesVolume2"] = 1.00

module Bubs
  module ToGTitleSystem
  
  TITLE ||= {} # <- Leave this alone, do not delete or modify.
  
  # The following "X-State" titles show how you can define hybrid
  # ranks using both full rank definitions and preset defintions.
  #
  # Actors earn these titles by being hit by these status states
  # a defined amount of times.
  
  #---------------------------
  TITLE[:poisonproof] = {
    :name => "Poisonproof",
    :icon => 161,
    :description => "A title that offers poison resistance. Because\n" +
                    "constantly losing HP is bad for your health.",
    :condition => "@records.added_state_count[2] >= 1",
    1 => [ 100,  :xpoison_10],
    2 => [ 300,  35, "MDF +3",  "",  "@bonus[:mmp] += 5"],
    3 => [ 600,  :xpoison_10],
    4 => [1000,  37, "MDF +5",  "",  "@bonus[:mhp] += 15"],
    5 => [1500,  :xpoison_10],
  }
  #---------------------------
  TITLE[:blindproof] = {
    :name => "Blindproof",
    :icon => 161,
    :description => "A title that offers blind resistance. Because\n" +
                    "you don't play the piano.",
    :condition => "@records.added_state_count[3] >= 5",
    1 => [ 100,  :xblind_10],
    2 => [ 300,  37, "MDF +3",  "",  "@bonus[:mdf] += 3"],
    3 => [ 600,  :xblind_10],
    4 => [1000,  37, "MDF +5",  "",  "@bonus[:mdf] += 5"],
    5 => [1500,  :xblind_10],
  }
  #---------------------------
  TITLE[:silenceproof] = {
    :name => "Silenceproof",
    :icon => 161,
    :description => "A title that offers silence resistance. Because\n" +
                    "really, who doesn't like casting spells?",
    :condition => "@records.added_state_count[4] >= 2",
    1 => [ 100,  :xsilence_10],
    2 => [ 300,  37, "MDF +3",   "",  "@bonus[:mdf] += 3"],
    3 => [ 600,  :xsilence_10],
    4 => [1000,  37, "MDF +5",   "",  "@bonus[:mdf] += 5"],
    5 => [1500,  :xsilence_10],
  }
  #---------------------------
  TITLE[:confuseproof] = {
    :name => "Confuseproof",
    :icon => 161,
    :description => "A title that offers confuse resistance. Because\n" +
                    "the battlefield is confusing enough.",
    :condition => "@records.added_state_count[5] >= 2",
    1 => [ 100,  :xconfuse_10],
    2 => [ 300,  37, "MDF +3",  "",  "@bonus[:mdf] += 3"],
    3 => [ 600,  :xconfuse_10],
    4 => [1000,  37, "MDF +5",  "",  "@bonus[:mdf] += 5"],
    5 => [1500,  :xconfuse_10],
  }
  #---------------------------
  TITLE[:sleepproof] = {
    :name => "Sleepproof",
    :icon => 161,
    :description => "A title that offers sleep resistance. Because\n" +
                    "sleep is for the weak.",
    :condition => "@records.added_state_count[6] >= 2",
    1 => [ 100, :xsleep_10],
    2 => [ 300,  37, "MDF +3",  "",  "@bonus[:mdf] += 3"],
    3 => [ 600, :xsleep_10],
    4 => [1000,  37, "MDF +5",  "",  "@bonus[:mdf] += 5"],
    5 => [1500, :xsleep_10],
  }
  #---------------------------
  TITLE[:paralysisproof] = {
    :name => "Paralysisproof",
    :icon => 161,
    :description => "A title that offers paralysis resistance. Because\n" +
                    "shaking all the time is a serious drag.",
    :condition => "@records.added_state_count[7] >= 2",
    1 => [ 100, :xparalysis_10], 
    2 => [ 300,  37, "MDF +3",     "",   "@bonus[:mdf] += 3"],
    3 => [ 600, :xparalysis_10],
    4 => [1000,  37, "MDF +5",     "",   "@bonus[:mdf] += 5"],
    5 => [1500, :xparalysis_10],
  }
  #---------------------------
  TITLE[:stunproof] = {
    :name => "Stunproof",
    :icon => 161,
    :description => "A title that offers stun resistance. Because\n" +
                    "you should only be stunned by beauty.",
    :condition => "@records.added_state_count[8] >= 2",
    1 => [ 100,  :xstun_10],
    2 => [ 300,  37, "MDF +3", "",  "@bonus[:mdf] += 3"],
    3 => [ 600,  :xstun_10],
    4 => [1000,  37, "MDF +5", "",  "@bonus[:mdf] += 5"],
    5 => [1500,  :xstun_10],
  }

  # The following "X-Element" titles show how you can define title
  # ranks using only preset rank definitions.
  # 
  # Be default, these "X-Element" titles require that the actor
  # be hit by that type of element at least 10 times.
  
  #---------------------------
  TITLE[:fireproof] = {
    :name => "Fireproof",
    :icon => 510,
    :description => "A title that offers fire resistance.\n" +
                    "Awarded after being hit by fire.",
    :condition => "@records.element_hurt_count[3] >= 1",
    1 => [ 100, :xfire_5],
    2 => [ 300, :energy_15],
    3 => [ 600, :xfire_5],
    4 => [1000, :vitality_30],
    5 => [1500, :xfire_5],
  }
  #---------------------------
  TITLE[:iceproof] = {
    :name => "Iceproof",
    :icon => 510,
    :description => "A title that offers ice resistance.\n" +
                    "Awarded after being hit by ice.",
    :condition => "@records.element_hurt_count[4] >= 1",
    1 => [ 100, :xice_5],
    2 => [ 300, :energy_15],
    3 => [ 600, :xice_5],
    4 => [1000, :vitality_30],
    5 => [1500, :xice_5],
  }
  #---------------------------
  TITLE[:thunderproof] = {
    :name => "Thunderproof",
    :icon => 510,
    :description => "A title that offers thunder resistance.\n" +
                    "Awarded after being hit by thunder.",
    :condition => "@records.element_hurt_count[5] >= 1",
    1 => [ 100, :xthunder_5],
    2 => [ 300, :energy_15],
    3 => [ 600, :xthunder_5],
    4 => [1000, :vitality_30],
    5 => [1500, :xthunder_5],
  }
  #---------------------------
  TITLE[:waterproof] = {
    :name => "Waterproof",
    :icon => 510,
    :description => "A title that offers water resistance.\n" +
                    "Awarded after being hit by water.",
    :condition => "@records.element_hurt_count[6] >= 1",
    1 => [ 100, :xwater_5],
    2 => [ 300, :energy_15],
    3 => [ 600, :xwater_5],
    4 => [1000, :vitality_30],
    5 => [1500, :xwater_5],
  }
  #---------------------------
  TITLE[:earthproof] = {
    :name => "Earthproof",
    :icon => 510,
    :description => "A title that offers earth resistance.\n"+
                    "Awarded after being hit by earth.",
    :condition => "@records.element_hurt_count[7] >= 1",
    1 => [ 100, :xearth_5],
    2 => [ 300, :energy_15],
    3 => [ 600, :xearth_5],
    4 => [1000, :vitality_30],
    5 => [1500, :xearth_5],
  }
  #---------------------------
  TITLE[:windproof] = {
    :name => "Windproof",
    :icon => 510,
    :description => "A title that offers wind resistance.\n" +
                    "Awarded after being hit by wind.",
    :condition => "@records.element_hurt_count[8] >= 1",
    1 => [ 100, :xwind_5],
    2 => [ 300, :energy_15],
    3 => [ 600, :xwind_5],
    4 => [1000, :vitality_30],
    5 => [1500, :xwind_5],
  }
  #---------------------------
  TITLE[:holyproof] = {
    :name => "Holyproof",
    :icon => 510,
    :description => "A title that offers holy resistance.\n"+
                    "Awarded after being hit by light.",
    :condition => "@records.element_hurt_count[9] >= 1",
    1 => [ 100, :xholy_5],
    2 => [ 300, :energy_15],
    3 => [ 600, :xholy_5],
    4 => [1000, :vitality_30],
    5 => [1500, :xholy_5],
  }
  #---------------------------
  TITLE[:darkproof] = {
    :name => "Darkproof",
    :icon => 510,
    :description => "A title that offers dark resistance.\n"+
                    "Awarded after being hit by darkness.",
    :condition => "@records.element_hurt_count[10] >= 1",
    1 => [ 100, :xdark_5],
    2 => [ 300, :energy_15],
    3 => [ 600, :xdark_5],
    4 => [1000, :vitality_30],
    5 => [1500, :xdark_5],
  }
  #---------------------------
  TITLE[:slime_hunter] = {
    :name => "Slime Hunter",
    :icon => 126,
    :description => "Slimes are the scourge of the fantasy universe!\n" +
                    "Earned after slaying 2 Slimes",
    :condition => "@records.enemy_kill_count[1] >= 2",
    1 => [ 100,  :energy_15],
    2 => [ 300,  :xwater_5],
    3 => [ 600,  :xpoison_10],
    4 => [1000,  :xwater_5],
    5 => [1500,  :energy_15],
  }

  end # module ToGTitleSystem
end # module Bubs


