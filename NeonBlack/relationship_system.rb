##----------------------------------------------------------------------------##
## The Legend of NeonBlack's Maus Romancing Sa-Ga Script v1.0
## Created by Neon Black
##
## For both commercial and non-commercial use as long as credit is given to
## Neon Black and any additional authors.  Licensed under Creative Commons
## CC BY 3.0 - http://creativecommons.org/licenses/by/3.0/.
##----------------------------------------------------------------------------##
                                                                              ##
##----------------------------------------------------------------------------##
##    Revision Info:
## v1.0 - 3.3.2013
##  Wrote and debugged main script
##----------------------------------------------------------------------------##
                                                                              ##
$imported ||= {}                                                              ##
$imported["CP_RELATIONSHIP"] = 1.0                                            ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Instructions:
## Place this script in the script editor below "Materials" and above "Main".
## This script requires Neon Black's Features and Effects name module.  You can
## obtain it from http://cphouseset.wordpress.com/modules/.  If you do not
## import it, you will get errors.
##
## This script allows additional features to be gained via relationships between
## two characters.  The names, descriptions, and power of the features can be
## modified by the script as well as numerous other conditions.  This script
## has both note tags and script calls that allow it to work.  These are as
## follows.
##
##------
##    Notebox Tags:
##
## relationship[+5 atk]  -or-  friends[-1% def]  -or-  lovers[+5.5% mmp]  -etc-
##  - The main tag used by this script and by far the most useful.  The tag can
##    be used to define if the bonus should apply to friends, lovers, or all
##    relationship types.  You can set any value, positive or negative, whole or
##    decimal, percentage or integer.  The last section of the code is the 3
##    letter name of the stat to modify.  Any stat from page 2 of a features
##    box may be used.  By default, all bonuses are added only when BOTH party
##    members are in the battle party.  At this time, extra parameter scripts
##    will not work with this script.
## relationship[skill 5]  -etc-
##  - Allows a skill to be learned when a relation ship is formed.  The skill
##    will be learned as long as relationship type and party conditions are met
##    so it is advised to use additional parameters for this tag (see below).
##    The "relationship" value of this tag can be replaced with "lovers" or
##    "friends" like the tag above.
## friends[weapon 2]  -or-  lovers[armor 3]  -etc-
##  - Allows weapons or armours of certain types to be equipped even if the
##    actor would not normally be able to equip them.  All the same rules as
##    skills above apply.
## for actor[3]  -or-  for actor[1, 2, 3]
##  - Allows additional parameters to be added to a bonus that allow only
##    certain actors to recieve the bonus.  This tag goes immediately after the
##    bonus you want to tag, for example:  relationship[+1% mmp] for actor[2]
## for level[4]  -or-  for level[3+]  -or-  for level[1-5]
##  - Allows additional parameters to be added to a bonus that prevent the bonus
##    from being added unless the relationship level is in the specified range.
##    This works similar to the tag above.
## <relationship party>  -and-  </relationship party>
##  - Allows all bonuses between the tags to be used as long as both party
##    members are in the party, even if they are not in the battle party
##    together.
## <relationship constant>  -and-  </relationship constant>
##  - Similar to the tags above, however all bonuses between these tags are
##    ALWAYS active, even if the actors are not in the party together.
## gender[male]  -and-  gender[female]
##  - Used to determine the base gender of a character.  By default, same sex
##    couples are friends and opposite sex couples are lovers.  If the
##    HOMOSEXUAL option is disabled, same sex couples can only reach the defined
##    cap in the lovers catagory.
##
##------
##    Script Calls:
##
## Relationship.open
##  - Quite simply, opens the status screen.
## Relationship.exp(actor1, actor2, exp)
##  - Used to alter the exp of a relationship.  The exp can be positive or
##    negative.  All other normal things that would happen occur automatically.
## Relationship.type(actor1, actor2, :switch)
##  - Used to change the type of relationship two actors are in.  This
##    automatically breaks a max level relationship if one has been established.
##    Note that :switch will switch the type of relationship from/to both
##    friends/lovers, while you can use :lovers or :friends to define the type
##    to switch to manually.
## Relationship.level(actor1, actor2)  -or-  Check.relationship_level(a1, a2)
##  - Gets the relationship level of two actors.  Can be used for conditional
##    script calls and such.
## Relationship.between(actor1, actor2)  -or-  Check.relationship_between(a, b)
##  - Gets the type of relationship two actors are in.  Returns a value of
##    either :lovers or :friends.
##----------------------------------------------------------------------------##
                                                                              ##
module CP           # Do not touch                                            ##
module RELATIONSHIP #  these lines.                                           ##
                                                                              ##
##----------------------------------------------------------------------------##
##    Config:
## The config options are below.  You can set these depending on the flavour of
## your game.  Each option is explained in a bit more detail above it.
##
##------
# This hash contains the info for each level of friendship.  The key is the
# level.  The first value is the exp required to reach that level, the second
# value is the name of that level, the third value is the description for the
# level, and the last value is the bonus multiplier for the level.
FRIEND_LEVELS ={
  1 => [1,  "Stranger",      "Only just met each other",          0.0],
  2 => [5,  "Aquaintance",   "Know about each other at best",     0.0],
  3 => [10, "Party Member",  "Just work together",                1.0],
  4 => [15, "Friends",       "Are friendly with each other",      2.0],
  5 => [20, "Good Friends",  "Trust each other",                  3.0],
  6 => [25, "Teammate",      "Would go to the other's aid",       4.0],
  7 => [35, "Best Friends",  "Rush to each other's aid",          6.0],
  8 => [45, "Partners",      "Trust each other with their lives", 8.0],
}

# Same as above, but for lover levels.
LOVER_LEVELS ={
  1  => [1,  "Stranger",      "Only just met each other",       0.0],
  2  => [5,  "Aquaintance",   "Know about each other at best",  0.0],
  3  => [10, "Party Member",  "Just work together",             1.0],
  4  => [15, "Friends",       "Are friendly with each other",   2.0],
  5  => [20, "Good Friends",  "Trust each other",               3.0],
  6  => [25, "Crush",         "Share a mutual attraction",      4.0],
  7  => [30, "Close",         "Getting to know each other",     5.0],
  8  => [35, "Dating",        "Getting to know each other",     6.0],
  9  => [40, "Lovers",        "Certain of each other's love",   8.0],
  10 => [45, "Soul Mate",     "Bound by fate",                 10.0],
}

# And finally rival levels for negative amounds of EXP.  This array starts at 0
# and goes DOWN into the negatives.
ENEMY_LEVELS ={
   0 => [0,   "Annoyance", "Barely tolerate each other",  0.0],
  -1 => [-10, "Rival",     "Fed up with each other",      0.0],
  -2 => [-25, "Enemy",     "Do not get along at all",    -1.0],
}

# The caps for all other relationships of the same type when a relationship has
# reached max in that catagory.
FRIEND_CAP = 6
LOVER_CAP = 5

# The minimum levels required for a name and rank to appear in the menu.
FRIEND_MIN = 4
LOVER_MIN = 6

# If this is set to true, if a lover has not reached the minimum lover level to
# appear in the menu, but has enough EXP that they are the highest relationship
# AND they have reached the minimum level required for friends, they will appear
# as a friend.  If you are confused by this option, please just turn it off.
LOVER_AS_FRIEND = true

# The symbol that separates the name and relationship ranking when a lover or
# friend is drawn in a window.  Ignore the misspelling.
SEPERATOR = '-'

# The text to display when no characters can be classified as a closest relation
# of some sort.
NO_FRIEND = "Lone Wolf"
NO_LOVER = "Single"
NO_ENEMY = "No Enemies"

# While this value is false, same sex couples cannot go above LOVER_CAP in the
# lovers catagory.  If it is set to true, they function the same as opposite
# sex couples.  This is only to prevent bugs and not meant to portray any way
# of thinking.
HOMOSEXUAL = false

# This option determines if the character's lover is displayed in the status
# screen.  This will display right below the equips if it is enabled.
STATUS_SCREEN = true

# Define if a menu option can be used to access a page displaying all
# relationship bonuses.  Also allows you to name this option.
USE_MENU = true
MENU_NAME = "Relationships"

# Used in the scene mentioned above to display the closest friend and lover.
FRIEND_NAME = "Closest Friend"
LOVER_NAME = "Closest Relationship"
##----------------------------------------------------------------------------##
                                                                              ##
                                                                              ##
##----------------------------------------------------------------------------##
## The following lines are the actual core code of the script.  While you are
## certainly invited to look, modifying it may result in undesirable results.
## Modify at your own risk!
###----------------------------------------------------------------------------


end
end

module DataManager
  class << self
    alias :cp_rshp_setup_new_game :setup_new_game
    alias :cp_rshp_setup_battle :setup_battle_test
  end
  
  def self.setup_new_game(*args)
    cp_rshp_setup_new_game(*args)
    $game_party.all_members.each { |m| m.recover_all }
  end
  
  def self.setup_battle_test(*args)
    cp_rshp_setup_battle(*args)
    $game_party.all_members.each { |m| m.recover_all }
  end
end

module SceneManager
  class << self
    alias :cp_rshp_run :run unless method_defined?(:cp_rshp_run)
  end
  
  def self.run
    cp_module_check_features
    cp_rshp_run
  end
  
  def self.cp_module_check_features
    return if $imported["CP_FEATURES_EFFECTS"]
    a1 = "One or more scripts require Neon Black's Features and Effects module."
    a2 = "This can be obtained at http://cphouseset.wordpress.com/modules/"
    a3 = "Please add this module and try again."
    a4 = "Please contact the creator of the game to resolve this issue."
    if $TEST || $BTEST
      msgbox "#{a1}/n#{a2}/n#{a3}"
      Thread.new{system("start http://cphouseset.wordpress.com/modules/#features")}
    else
      msgbox "#{a1}/n#{a4}"
    end
  end
end

module Relationship
  def self.exp(act1, act2, exp)
    old_lvl = $game_party.relationship_level(act1, act2)
    mlvl = $game_party.change_rlevel_exp(act1, act2, exp)
    if $game_party.relationship_level(act1, act2) < mlvl
      $game_party.break_relationship(act1, act2)
    elsif exp >= 0
      $game_party.make_relationship(act1, act2)
    end
    if old_lvl != $game_party.relationship_level(act1, act2)
      $game_party.reset_relationship
    end
  end
  
  def self.type(act1, act2, val = :switch)
    $game_party.break_relationship(act1, act2)
    mlvl = $game_party.relationship_type_switch(act1, act2, val)
    if $game_party.relationship_level(act1, act2) >= mlvl
      $game_party.make_relationship(act1, act2)
    end
    $game_party.reset_relationship
  end
  
  def self.level(act1, act2)
    $game_party.relationship_level(act1, act2)
  end
  
  def self.between(act1, act2)
    $game_party.relationship_type(act1, act2)
  end
  
  def self.open
    SceneManager.call(Scene_RelationshipStatus)
  end
end

module Check
  def self.relationship(act1, act2)
    [relationship_between(act1, act2), relationship_level(act1, act2)]
  end
  
  def self.relationship_level(act1, act2)
    $game_party.relationship_level(act1, act2)
  end
  
  def self.relationship_between(act1, act2)
    $game_party.relationship_type(act1, act2)
  end
end

class Game_Actors
  def each
    make_all_actors
    @data.each do |actor|
      next unless actor
      yield actor
    end
  end
  
  def size
    make_all_actors
    @data.size
  end
  
  def make_all_actors
    return if @all_setup; @all_setup = true
    $data_actors.each_with_index do |act, id|
      next unless act
      @data[id] ||= Game_Actor.new(id)
    end
  end
end

class Game_Actor < Game_Battler
  alias :cp_rshp_init :initialize
  def initialize(*args)
    cp_rshp_init(*args)
    @relationship_bonuses = {}
  end
  
  def reset_relationship
    @relationship_bonuses = {}
    relationship_features
    refresh
  end
  
  alias :cp_rshp_features :all_features
  def all_features
    cp_rshp_features + relationship_features
  end
  
  def relationship_features
    return [] unless @relationship_bonuses
    battle_party_rsfeatures + current_party_rsfeatures + all_party_rsfeatures
  end
  
  def battle_party_rsfeatures
    result = []
    return result unless $game_party.battle_members.include?(self)
    $game_party.battle_members.each do |mem|
      next if mem.nil? || mem.id == self.id
      result += mem.relationship_bonuses(@actor_id, :battle)
    end
    result
  end
  
  def current_party_rsfeatures
    result = []
    return result unless $game_party.all_members.include?(self)
    $game_party.all_members.each do |mem|
      next if mem.nil? || mem.id == self.id
      result += mem.relationship_bonuses(@actor_id, :party)
    end
    result
  end
  
  def all_party_rsfeatures
    result = []
    $game_actors.each do |mem|
      next if mem.nil? || mem.id == self.id
      result += mem.relationship_bonuses(@actor_id, :game)
    end
    result
  end
  
  def rsfeatures_total_others
    results = {}
    $game_actors.each do |mem|
      next if mem.nil? || mem.id == self.id
      results[mem.id] = []
      mem.relationship_bonuses(@actor_id, :battle).each do |ft|
        results[mem.id].push([:battle, ft])
      end
      mem.relationship_bonuses(@actor_id, :party).each do |ft|
        results[mem.id].push([:party, ft])
      end
      mem.relationship_bonuses(@actor_id, :game).each do |ft|
        results[mem.id].push([:game, ft])
      end
    end
    return results
  end
  
  def relationship_bonuses(id, scope)
    @relationship_bonuses = {} if @relationship_bonuses.nil?
    return @relationship_bonuses[id][scope] if @relationship_bonuses.include?(id)
    make_relationship_features(@actor_id, id)
    return @relationship_bonuses[id][scope]
  end
  
  def make_relationship_features(host, id)
    @relationship_bonuses[id] = {:battle=>[], :party=>[], :game=>[]}
    rlevel = $game_party.relationship_level(host, id)
    multi = $game_party.relationship_multiplier(host, id)
    rtype = $game_party.relationship_type(host, id, false)
    actor.relationship_features.each do |scope, array|
      array.each do |item|
        next unless item[4] == rtype || item[4] == :relationship
        next if !item[5][:actor].empty? && !item[5][:actor].include?(id)
        next unless level_from_array(rlevel, item[5][:level])
        @relationship_bonuses[id][scope].push(get_feature_from_array(item, multi))
      end
      @relationship_bonuses[id][scope].compact!
    end
  end
  
  def level_from_array(rlevel, lvl)
    case lvl
    when /(\d+)[-](\d+)/i
      return rlevel >= $1.to_i && rlevel <= $2.to_i
    when /(\d+)[\+]/i
      return rlevel >= $1.to_i
    when /(\d+)/i
      return rlevel == $1.to_i
    else
      return true
    end
  end
  
  def get_feature_from_array(array, multi)
    case array[0]
    when :stat
      return nil unless multi != 0
      codes = CP::Features.get_feature(array[3], array[2])
      return nil unless codes
      ft = RPG::BaseItem::Feature.new(codes[0], codes[1], array[1] * multi)
    when :skill
      ft = RPG::BaseItem::Feature.new(43, array[1], 0)
    when :weapon
      ft = RPG::BaseItem::Feature.new(51, array[1], 0)
    when :armor, :armour
      ft = RPG::BaseItem::Feature.new(52, array[1], 0)
    end
    return ft
  end
  
  def gender
    unless @composite_male.nil?
      return @composite_male ? :male : :female
    else
      return actor.gender
    end
  end
end

class Game_Party < Game_Unit
  def reset_relationship
    $game_actors.each { |m| m.reset_relationship }
  end
  
  def relationship_type(act1, act2, rrival = true)
    a1, a2 = [act1, act2].sort
    init_relationship_table unless @relationship_table
    table_type, exp_level = @relationship_table[[a1, a2]]
    return table_type unless rrival
    return exp_level > 0 ? table_type : :rivals
  end
  
  def relationship_level(act1, act2)
    a1, a2 = [act1, act2].sort
    init_relationship_table unless @relationship_table
    table_type, exp_level = @relationship_table[[a1, a2]]
    return 0 if table_type.nil? || exp_level.nil?
    if table_type == :friends
      top = @friends_hash[a1] ? @friends_hash[a1] == a2 : true 
    elsif table_type == :lovers
      top = false if !CP::RELATIONSHIP::HOMOSEXUAL &&
                     $game_actors[a1].gender == $game_actors[a2].gender
      top = @lovers_hash[a1] ? @lovers_hash[a1] == a2 : true
    end
    return [make_rlevel(table_type, exp_level),
            make_rcap(table_type, top || true)].min
  end
  
  def make_rlevel(type, exp)
    if exp > 0
      lvl = 1
      cp_relate_hashes(type).each do |key, array|
        lvl = key if key > lvl && exp >= array[0]
      end
    else
      lvl = 0
      cp_relate_hashes(:rivals).each do |key, array|
        lvl = key if key < lvl && exp <= array[0]
      end
    end
    return lvl
  end
  
  def change_rlevel_exp(act1, act2, exp)
    a1, a2 = [act1, act2].sort
    init_relationship_table unless @relationship_table
    type = @relationship_table[[a1, a2]][0]
    @relationship_table[[a1, a2]][1] += exp
    check_relationship_cap(a1, a2, type)
    return cp_relate_hashes(type).keys.max
  end
  
  def check_relationship_cap(act1, act2, type = nil)
    a1, a2 = [act1, act2].sort
    table_type, exp = @relationship_table[[a1, a2]]
    if type == :friends
      return if table_type != type ||
                (@friends_hash[a1].nil? && @friends_hash[a2].nil?) ||
                (@friends_hash[a1] == a2 && @friends_hash[a2] == a1)
      cap = CP::RELATIONSHIP::FRIEND_CAP
    elsif type == :lovers
      return if table_type != type ||
                (@lovers_hash[a1].nil? && @lovers_hash[a2].nil?) ||
                (@lovers_hash[a1] == a2 && @lovers_hash[a2] == a1)
      cap = CP::RELATIONSHIP::LOVER_CAP
    else
      return
    end
    mexp = cp_relate_hashes(type)[cap][0]
    @relationship_table[[a1, a2]][1] = mexp if exp > mexp
  end
  
  def relationship_type_switch(act1, act2, val)
    a1, a2 = [act1, act2].sort
    init_relationship_table unless @relationship_table
    type = @relationship_table[[a1, a2]][0]
    case val
    when :switch
      if type == :lovers
        @relationship_table[[a1, a2]][0] = :friends
      elsif type == :friends
        @relationship_table[[a1, a2]][0] = :lovers
      end
    when :lovers
      @relationship_table[[a1, a2]][0] = :lovers
    when :friends
      @relationship_table[[a1, a2]][0] = :friends
    end
    return cp_relate_hashes(@relationship_table[[a1, a2]][0]).keys.max
  end
  
  def make_rcap(type, top)
    lvl = 999
    if type == :lovers
      lvl = CP::RELATIONSHIP::LOVER_CAP unless top
    elsif type == :friends
      lvl = CP::RELATIONSHIP::FRIEND_CAP unless top
    end
    return lvl
  end
  
  def relationship_multiplier(act1, act2)
    init_relationship_table unless @relationship_table
    rlevel = relationship_level(act1, act2)
    a1, a2 = [act1, act2].sort
    table_type = relationship_type(a1, a2)
    multi = cp_relate_hashes(table_type)[rlevel][3] rescue multi = 0
    return multi
  end
  
  def break_relationship(act1, act2)
    a1, a2 = [act1, act2].sort
    table_type, exp_level = @relationship_table[[a1, a2]]
    case table_type
    when :friends
      return unless @friends_hash[a1] == a2 && @friends_hash[a2] == a1
      @friends_hash[a1] = nil
      @friends_hash[a2] = nil
    when :lovers
      return unless @lovers_hash[a1] == a2 && @lovers_hash[a2] == a1
      @lovers_hash[a1] = nil
      @lovers_hash[a2] = nil
    end
  end
  
  def make_relationship(act1, act2)
    a1, a2 = [act1, act2].sort
    table_type, exp_level = @relationship_table[[a1, a2]]
    case table_type
    when :friends
      return unless @friends_hash[a1].nil? && @friends_hash[a2].nil?
      @friends_hash[a1] = a2
      @friends_hash[a2] = a1
    when :lovers
      return unless @lovers_hash[a1].nil? && @lovers_hash[a2].nil?
      @lovers_hash[a1] = a2
      @lovers_hash[a2] = a1
    end
    $game_actors.each do |a3|
      next if a3.nil? || a3.id == a1 || a3.id == a2
      check_relationship_cap(a1, a3.id, table_type)
      check_relationship_cap(a2, a3.id, table_type)
    end
  end
  
  def cp_relate_hashes(table)
    case table
    when :lovers
      return CP::RELATIONSHIP::LOVER_LEVELS
    when :friends
      return CP::RELATIONSHIP::FRIEND_LEVELS
    when :rivals
      return CP::RELATIONSHIP::ENEMY_LEVELS
    else
      return {}
    end
  end
  
  def init_relationship_table
    @relationship_table = {}
    @lovers_hash = {}
    @friends_hash = {}
    $game_actors.each do |a1|
      next unless a1
      @lovers_hash[a1] = nil
      @friends_hash[a1] = nil
      $game_actors.each do |a2|
        next if !a2 || a1.id >= a2.id
        status = a1.gender == a2.gender ? :friends : :lovers
        exp = 1
        @relationship_table[[a1.id, a2.id]] = [status, exp]
      end
    end
  end
  
  def greatest_relationship(act, type)
    if type == :friends
      return @friends_hash[act] if @friends_hash[act]
    elsif type == :lovers
      return @lovers_hash[act] if @lovers_hash[act]
    end
    result = 0
    exp = nil
    $game_actors.each do |a|
      next if a.nil? || a.id == act
      rt = relationship_type(a.id, act)
      rl = relationship_level(a.id, act)
      next if !CP::RELATIONSHIP::LOVER_AS_FRIEND && type != rt
      next if (type == :lovers && !@lovers_hash[a.id].nil? &&
               @lovers_hash[a.id] != act) || (type == :friends &&
               !@friends_hash[a.id].nil? && @friends_hash[a.id] != act)
      a1, a2 = [a.id, act].sort
      next if type == :lovers && (rt != :lovers ||
              rl < CP::RELATIONSHIP::LOVER_MIN)
      next if type == :friends && (rl < CP::RELATIONSHIP::FRIEND_MIN ||
              (rt == :lovers && rl >= CP::RELATIONSHIP::LOVER_MIN))
      _, aex = @relationship_table[[a1, a2]]
      next unless exp.nil? || aex.abs > exp.abs
      result, exp = a.id, aex
    end
    return result
  end
end

class Scene_Menu < Scene_MenuBase
  alias :cp_rshp_form_ok :on_formation_ok
  def on_formation_ok(*args)
    cp_rshp_form_ok(*args)
    $game_party.all_members.each { |m| m.refresh }
    @status_window.refresh
  end
end

##------
## Scenes and windows below.
##------

class Scene_RelationshipStatus < Scene_MenuBase
  def start
    super
    draw_all_windows
  end
  
  def draw_all_windows
    @top_window = Window_RelationshipTop.new(@actor)
    @bonus_window = Window_RelationshipBonus.new(@top_window)
    @bonus_window.set_handler(:ok,       method(:select_actor))
    @bonus_window.set_handler(:cancel,   method(:return_scene))
    @bonus_window.set_handler(:pagedown, method(:next_actor))
    @bonus_window.set_handler(:pageup,   method(:prev_actor))
  end
  
  def select_actor
    @actor = $game_actors[@bonus_window.valid_partners.keys[@bonus_window.index]]
    on_actor_change
  end
  
  def on_actor_change
    @top_window.actor = @actor
    @top_window.refresh
    @bonus_window.refresh
    @bonus_window.activate
  end
end

class Scene_Menu < Scene_MenuBase
  alias :cp_rshp_cc_window :create_command_window
  def create_command_window
    cp_rshp_cc_window
    @command_window.set_handler(:cp_rshp, method(:command_personal))
  end
  
  alias :cp_rshp_personal_ok :on_personal_ok
  def on_personal_ok
    cp_rshp_personal_ok
    case @command_window.current_symbol
    when :cp_rshp
      Relationship.open
    end
  end
end

class Window_Base < Window
  def draw_actor_friend(actor, x, y, width = 180)
    act2 = $game_party.greatest_relationship(actor.id, :friends)
    unless act2 == 0
      rt = $game_party.relationship_type(actor.id, act2)
      lvl = $game_party.relationship_level(actor.id, act2)
      level = $game_party.cp_relate_hashes(rt)[lvl][1]
      draw_relationship(act2, level, x, y, width)
    else
      draw_text(x + 24, y, width, line_height, CP::RELATIONSHIP::NO_FRIEND)
    end
  end
  
  def draw_actor_lover(actor, x, y, width = 180)
    act2 = $game_party.greatest_relationship(actor.id, :lovers)
    unless act2 == 0
      rt = $game_party.relationship_type(actor.id, act2)
      lvl = $game_party.relationship_level(actor.id, act2)
      level = $game_party.cp_relate_hashes(rt)[lvl][1]
      draw_relationship(act2, level, x, y, width)
    else
      draw_text(x + 24, y, width, line_height, CP::RELATIONSHIP::NO_LOVER)
    end
  end
  
  def draw_actor_rival(actor, x, y, width = 180)
    act2 = $game_party.greatest_relationship(actor.id, :rivals)
    unless act2 == 0
      rt = $game_party.relationship_type(actor.id, act2)
      lvl = $game_party.relationship_level(actor.id, act2)
      level = $game_party.cp_relate_hashes(rt)[lvl][1]
      draw_relationship(act2, level, x, y, width)
    else
      draw_text(x + 24, y, width, line_height, CP::RELATIONSHIP::NO_ENEMY)
    end
  end
  
  def draw_relationship_between(act1, act2, x, y, width = 180)
    lvl = $game_party.relationship_level(act1, act2)
    case $game_party.relationship_type(act1, act2)
    when :lovers
      level = $game_party.cp_relate_hashes(:lovers)[lvl][1]
      txt = $game_party.cp_relate_hashes(:lovers)[lvl][2]
    when :friends
      level = $game_party.cp_relate_hashes(:friends)[lvl][1]
      txt = $game_party.cp_relate_hashes(:friends)[lvl][2]
    when :rivals
      level = $game_party.cp_relate_hashes(:rivals)[lvl][1]
      txt = $game_party.cp_relate_hashes(:rivals)[lvl][2]
    end
    draw_relationship(act2, level, x, y, width)
    lfs = contents.font.size
    contents.font.size = contents.font.size / 6 * 5
    draw_text(x, y + line_height, width, line_height, txt, 1)
    contents.font.size = lfs
  end
  
  def draw_relationship(actor, level, x, y, width)
    other = $game_actors[actor]
    return unless other
    draw_actor_icon(other, x, y)
    lfs = contents.font.size
    draw_text((x + width / 2) - 12, y, 24, line_height,
              CP::RELATIONSHIP::SEPERATOR, 1)
    contents.font.size = contents.font.size / 6 * 5
    draw_actor_name(other, x + 24, y, (width / 2) - 36)
    change_color(normal_color)
    draw_text((x + width / 2) + 12, y, width / 2 - 16, line_height, level)
    contents.font.size = lfs
  end
  
  def draw_actor_icon(actor, x, y)
    character_name = actor.character_name
    character_index = actor.character_index
    return unless character_name
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new(((n%4*3+1)*cw) + [(cw-24)/2, 0].max, (n/4*4)*ch,
                        [24, cw].min, 24)
    contents.blt(x, y, bitmap, src_rect)
  end
end

class Window_MenuCommand < Window_Command
  alias :cp_rshp_ocomm :add_original_commands
  def add_original_commands
    cp_rshp_ocomm
    if CP::RELATIONSHIP::USE_MENU
      add_command(CP::RELATIONSHIP::MENU_NAME, :cp_rshp, main_commands_enabled)
    end
  end
end

class Window_Status < Window_Selectable
  alias :cp_rshp_block3 :draw_block3
  def draw_block3(y)
    cp_rshp_block3(y)
    return unless CP::RELATIONSHIP::STATUS_SCREEN
    draw_actor_lover(@actor, 288, y + line_height * 5, 196)
  end
end

class Window_RelationshipTop < Window_Base
  attr_accessor :actor
  
  def initialize(actor)
    super(0, 0, Graphics.width, fitting_height(4))
    @actor = actor
    refresh
  end
  
  def refresh
    contents.clear
    draw_actor_face(@actor, 2, 0)
    draw_actor_name(@actor, 106, line_height, 180)
    draw_actor_nickname(@actor, 106, line_height * 2)
    draw_favorites_block(290, contents.width - 290)
  end
  
  def draw_favorites_block(x, width)
    change_color(system_color)
    draw_text(x, 0, width, line_height, CP::RELATIONSHIP::FRIEND_NAME)
    draw_text(x, line_height * 2, width, line_height,
              CP::RELATIONSHIP::LOVER_NAME)
    change_color(normal_color)
    draw_actor_friend(@actor, x, line_height, width)
    draw_actor_lover(@actor, x, line_height * 3, width)
  end
end

class Window_RelationshipBonus < Window_Selectable
  def initialize(parent)
    @parent = parent
    h = Graphics.height - @parent.height
    super(@parent.x, @parent.y + @parent.height, Graphics.width, h)
    refresh
    activate
  end
  
  def col_max
    return 2
  end
  
  def item_max
    return valid_partners.size
  end
  
  def item_height
    return line_height * 2 if item_max <= 0
    return (valid_partners.values.collect{|s| s.size}.max + 2) * line_height + 8
  end
  
  def valid_partners
    return @parent.actor.rsfeatures_total_others.select do |k,v|
      $game_party.all_members.include?($game_actors[k]) || !v.empty?
    end
  end
  
  def refresh
    select(0)
    create_contents
    draw_all_items
  end
  
  def current_item_enabled?
    return false if item_max <= 0
    $game_party.all_members.include?($game_actors[valid_partners.keys[@index]])
  end
  
  def draw_item(index)
    rect = item_rect(index)
    rect.x += 2; rect.y += 4; rect.width -= 4
    act = valid_partners.keys[index]
    draw_relationship_between(@parent.actor.id, act, rect.x, rect.y,
                              rect.width)
    valid_partners.values[index].each_with_index do |array, i|
      text = array[1].vocab
      case array[0]
      when :battle
        tf = $game_party.battle_members.include?($game_actors[act]) &&
             $game_party.battle_members.include?(@parent.actor)
      when :party
        tf = $game_party.all_members.include?($game_actors[act]) &&
             $game_party.all_members.include?(@parent.actor)
      else
        tf = true
      end
      change_color(normal_color, tf)
      draw_text(rect.x + 2, rect.y + line_height * (i + 2), rect.width - 4,
                line_height, text)
    end
    change_color(normal_color)
  end
  
  def update_padding_bottom
  end
end

##------
## REGEXP and game objects below.
##------

module CP
module REGEXP
module RELATIONSHIP
  ##             $1 Type                         $2 Op. $3 1. $4 .1  $5 %  $6 stat
  STAT_MODIF_2  = /(relationship|friends|lovers)\[(\+|-)(\d+)(\.\d+)?(%?) (.{3})\]/i
  EXTRA_MODIF_2 = /(relationship|friends|lovers)\[(skill|weapon|armor|armour) (\d+)\]/i
  FOR_ACTOR_2   = /for (actor|level)\[([\d, ]+)\]/i
  FOR_LEVEL_2   = /for (level)\[(\d+)(\+|-)?(\d*)\]/i
  CONSTANT1_2   = /<relationship constant>/i
  CONSTANT2_2   = /<\/relationship constant>/i
  PARTY1_2      = /<relationship party>/i
  PARTY2_2      = /<\/relationship party>/i
  GENDER_2      = /gender\[(male|female)]/i
end
end
end

class RPG::Actor < RPG::BaseItem
  include CP::REGEXP::RELATIONSHIP
  
  def relationship_features
    create_reship_features if @relationship_features.nil?
    return @relationship_features
  end
  
  def gender
    create_reship_features if @gender_base.nil?
    return @gender_base
  end
  
  def create_reship_features
    @relationship_features = {:battle=>[], :party=>[], :game=>[]}
    @gender_base = :male
    type = :battle
    self.note.split(/[\r\n]+/i).each do |line|
      @reyash = nil
      case line
      when STAT_MODIF_2
        n = $3.to_f + $4.to_f
        fti = CP::Features.get_feature($6.to_s, $5.to_s)
        if [21, 23].include?(fti[0])
          n = $2.to_s == '-' ? (100.0 - n) / 100.0 :
              $2.to_s == '+' ? (n + 100.0) / 100.0 : n
        elsif fti[0] == 22
          n = $2.to_s == '-' ? -n / 100.0 :
              $2.to_s == '+' ? n / 100.0 : n
        else
          n *= -1 if $2.to_s == '-'
        end
        @reyash = [:stat,     n,       $5.to_s, $6.to_s, $1.to_sym]
        ext = {:actor => [], :level => "all"}
      when EXTRA_MODIF_2
        @reyash = [$2.to_sym, $3.to_i, nil,     nil,     $1.to_sym]
        ext = {:actor => [], :level => "0+"}
      when CONSTANT1_2
        type = :game if type == :battle
      when CONSTANT2_2
        type = :battle if type == :game
      when PARTY1_2
        type = :party if type == :battle
      when PARTY2_2
        type = :battle if type == :party
      when GENDER_2
        @gender_base = $1.to_sym
        next
      end
      next unless @reyash
      if line =~ FOR_ACTOR_2
        ext[$1.to_sym] = $2.to_s.delete(' ').split(/,/).collect {|i| i.to_i}
      end
      if line =~ FOR_LEVEL_2
        ext[$1.to_sym] = "#{$2.to_s}#{$3.to_s}#{$4.to_s}"
      end
      @reyash.push(ext)
      @relationship_features[type].push(@reyash)
    end
  end
end


###--------------------------------------------------------------------------###
#  End of script.                                                              #
###--------------------------------------------------------------------------###