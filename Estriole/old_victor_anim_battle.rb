#==============================================================================
# ** Victor Engine - Animated Battle
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v beta - 2012.01.28 > Beta relase
#  v 1.00 - 2012.03.08 > Full relase
#  v 1.01 - 2012.03.11 > Better automatic facing direction handling
#                      > Added tags to control intro and victory poses
#                      > Added tags to assign equipment icons for enemies
#  v 1.02 - 2012.03.15 > Fixed enemies turing back when unmovable
#                      > Better active battler handling
#  v 1.03 - 2012.03.19 > Fixed last text error on fast damage skill
#                      > Fixed bug if number of members exceeds battle members
#  v 1.04 - 2012.03.21 > Fixed pose freeze error
#  v 1.05 - 2012.05.20 > Compatibility with Map Turn Battle
#  v 1.06 - 2012.05.22 > Compatibility with Passive States
#  v 1.07 - 2012.05.24 > Compatibility with State Auto Apply
#                      > Added note tags for cast poses
#  v 1.08 - 2012.05.25 > Fixed Counter and Reflect endless loop
#                      > Fixed freeze at the battle end
#  v 1.09 - 2012.06.17 > Fixed throw wait and effect animation
#                      > Fixed icons placement (Thanks to Fomar0153)
#                      > Fixed directions of actions
#                      > Fixed battle log showing too fast
#                      > Fixed freeze when escaping
#                      > Improved Dual Wielding options
#------------------------------------------------------------------------------
#  This script provides a totally customized animated battle system.
# This script allows a full customization of actions sequences, spritesheet
# and many things related to in battle display.
# This script ins't newbie friendly, be *VERY CAREFUL* with the settings.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.24 or higher
#
# * Overwrite methods
#   class Game_BattlerBase
#     def refresh
#
#   class Game_Battler < Game_BattlerBase
#     def dead?
#
#   class Game_Actor < Game_Battler
#     def perform_collapse_effect
#     def perform_damage_effect
#
#   class Game_Enemy < Game_Battler
#     def perform_damage_effect
#
#   class Sprite_Battler < Sprite_Base
#     def update_bitmap
#     def init_visibility
#     def update_origin
#
#   class Spriteset_Battle
#     def create_actors
#
#   class Window_BattleLog < Window_Selectable
#     def wait_and_clear
#     def wait
#     def back_to(line_number)
#     def display_added_states(target)
#
#   class Scene_Battle < Scene_Base
#     def abs_wait_short
#     def process_action
#     def apply_item_effects(target, item)
#     def execute_action
#     def use_item
#     def show_animation(targets, animation_id)
#     def invoke_counter_attack(target, item)
#     def invoke_magic_reflection(target, item)
#     def apply_substitute(target, item)
#
# * Alias methods
#   class << BattleManager
#     def init_members
#     def battle_end(result)
#     def process_victory
#     def process_escape
#     def process_abort
#
#   class Game_Screen
#     def clear_tone
#     def update
#
#   class Game_Battler < Game_BattlerBase
#     def initialize
#     def item_apply(user, item)
#     def make_damage_value(user, item)
#     def regenerate_hp
#     def die
#     def revive
#
#   class Game_Actor < Game_Battler
#     def param_plus(param_id)
# 
#   class Game_Enemy < Game_Battler
#     def perform_collapse_effect
#
#   class Sprite_Battler < Sprite_Base
#     def initialize(viewport, battler = nil)
#     def update_effect
#     def revert_to_normal
#     def setup_new_effect
#
#   class Spriteset_Battle
#     def initialize
#     def update
#     def dispose
#     def create_pictures
#     def create_viewports
#     def update_viewports
#
#   class Window_BattleLog < Window_Selectable
#     def add_text(text)
#
#   class Scene_Battle < Scene_Base
#     def create_spriteset
#     def update_basic
#     def turn_end
#     def next_command
#     def prior_command
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#------------------------------------------------------------------------------
# Weapons note tags:
#   Tags to be used on Weapons note boxes. 
#
#  <attack pose: action>
#   Changes the normal attack pose when using a weapon with this tag
#     action : action name
#
#  <dual pose: action>
#   Changes the double attack pose when using a weapon with this tag
#     action : action name
#
#  <skill pose: action>
#   Changes the physical skill pose when using a weapon with this tag
#     action : action name
#
#  <magic pose: action>
#   Changes the magical skill pose when using a weapon with this tag
#     action : action name
#
#  <item pose: action>
#   Changes the item pose when using a weapon with this tag
#     action : action name
#
#  <advance pose: action>
#   Changes the movement for actions when using a weapon with this tag
#   this change the movement of all actions that have movement (by default
#   only normal attacks and physical skills)
#     action : movement type name
#
#------------------------------------------------------------------------------
# Skills and Items note tags:
#   Tags to be used on Skills and Items note boxes. 
#
#  <action pose: action>
#   Changes the pose of the skill or item with this tag
#     action : action name
# 
#  <action movement>
#   By default, only physical skills have movement. So, if you want to add
#   movement to non-physical skills and items, add this tag.
#
#  <allow dual attack>
#   By default, skills and items do a single hit even if the character is
#   dual wielding, adding this tag to the skill will allow the actor to
#   attack twice when dual wielding. This only if the action don't use a
#   custom pose.
#
#------------------------------------------------------------------------------
# Actors note tags:
#   Tags to be used on Actors note boxes.
#
#  <no intro>
#   This tag will make the actor display no intro pose at the battle start.
#   By default, all actor display intro pose
#
#  <no victory>
#   This tag will make the actor display no victory pose at the battle start.
#   By default, all actors display victory pose
#
#------------------------------------------------------------------------------
# Enemies note tags:
#   Tags to be used on Enemies note boxes.
#
#  <intro pose>
#   This tag will make the enemy display intro pose at the battle start.
#   By default, no enemy display intro pose
#
#  <victory pose>
#   This tag will make the enemy display victory pose at the battle start.
#   By default, no enemy display victory pose
#
#  <weapon x: y>
#   This allows to display weapons for enemies when using the pose value
#   'icon: weapon *'.
#     x : the slot index of the weapon (1: right hand, 2: left hand)
#     y : the incon index
#
#  <armor x: y>
#   This allows to display armors for enemies when using the pose value
#   'icon: armor *'.
#     x : the slot index of the armor (1: shield, 2: helm, 3: armor, 4: acc)
#     y : the incon index
#
#------------------------------------------------------------------------------
# Actors, Enemies, Classes, States, Weapons and Armors note tags:
#   Tags to be used on Actors, Enemies, Classes, States, Weapons and Armors
#   note boxes.
#
#  <unmovable> 
#   This tag allows to make a totally unmovable battler. The battler will not
#   move to attack, neither be can forced to move by any action.
#  
#  <use dual attack>
#   By default, the attack when dual wielding calls the action sequence from
#   the equiped weapons. Adding this tag will make the actor use the custom
#   dual attack sequence <action: dual attack, reset>
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
# 
#  <no intro>
#   When called, the next battle will have no intro pose.
#
#  <no victory>
#   When called, the next battle will have no victory pose.
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  More detailed info about the settings can be found at:
#   http://victorscripts.wordpress.com/
#
#  From version 1.09 and later the dual attack pose is opitional, if not set
#  the actor will use the default attack for each weapon instead (wich
#  allows to use weapons with totally different poses), also it's possible 
#  to setup skills to inherit the double attack effect. So you can make
#  you physical single hit skills to deal 2 strikes if dual wielding.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Initialize Variables
  #--------------------------------------------------------------------------
  VE_ACTION_SETTINGS = {} # Don't remove or change
  #--------------------------------------------------------------------------
  # * Animated battler sufix
  #   When using sprites, add this to the animated sprite sheet of the battler,
  #   that way you can keep the original battler a single sprite and make 
  #   easier to setup their position on the troop
  #--------------------------------------------------------------------------
  VE_SPRITE_SUFIX = "[anim]"
  #--------------------------------------------------------------------------
  # * Intro fade
  #   When true, there will be a small fade effect on the battlers during
  #   the battle start (like RMXP default battle)
  #--------------------------------------------------------------------------
  VE_BATTLE_INTRO_FADE = true
  #--------------------------------------------------------------------------
  # * Default sprite settings
  #   This is the settings for all battler graphics that doesn't have
  #   their own custom setting
  #--------------------------------------------------------------------------
  VE_DEFAULT_SPRITE = {
  # Basic Settings
  # name:   value,
    frames: 4,        # Number of frames
    rows:   14,       # Number of rows
    mirror: false,    # Mirror battler when facing right
    invert: false,    # Invert the battler graphic
    mode:   :sprite,  # Graphic style (:sprite or :chasert)
    action: nil,      # Action settings

  # Main Poses
  # name:       row,
    idle:      1,   # Idle pose
    guard:     2,   # Guard pose
    evade:     2,   # Evade pose
    danger:    3,   # Low HP pose
    hurt:      4,   # Damage pose
    attack:    5,   # Physical attack pose
    use:       6,   # No type use pose
    item:      6,   # Item use pose
    skill:     7,   # Skill use pose
    magic:     8,   # Magic use pose
    advance:   9,   # Advance pose
    retreat:   10,  # Retreat pose
    escape:    10,  # Escape pose
    victory:   11,  # Victory pose
    intro:     12,  # Battle start pose
    dead:      13,  # Incapacited pose
    ready:     nil, # Ready pose
    itemcast:  nil, # Item cast pose
    skillcast: nil, # Skill cast pose
    magiccast: nil, # Magic cast pose
    command:   nil, # Command pose
    input:     nil, # Input pose
    cancel:    nil, # Cancel pose
    # You can add other pose names and call them within the action settings
    # use only lowcase letters
  } # Don't remove
  #--------------------------------------------------------------------------
  # * Custom sprite settings
  #   Theses settings are set individually based on the battler graphic
  #   filename (even if using the charset mode, the setting will be based
  #   on the battler name, so it's suggested to use the same name for
  #   the battler and charset graphic when using charset mode)
  #   Any value from the default setting can be used, if a value is not set
  #   it's automatically uses the value from basic setting
  #--------------------------------------------------------------------------
  VE_SPRITE_SETTINGS = {
  # 'Filename' => {settings},
  #
  # 'Sample 1' => {frames: 4, rows: 14, mirror: true, mode: :sprite,
  #                action: nil},
  # 'Sample 2' => {frames: 3, rows: 4, mirror: true, invert: false,
  #                mode: :charset, action: :charset},
  # 'Sample 3' => {frames: 3, rows: 4, mirror: false, invert: false,
  #                mode: :charset, action: :kaduki},
    'Scorpion'  => {frames: 4, rows: 14, mirror: true, mode: :sprite,
                    action: nil},
    'Warrior_m' => {frames: 4, rows: 14, mirror: false, mode: :sprite,
                    action: :default},
    'Actor1'    => {frames: 3, rows: 4, mirror: false, invert: false,
                    mode: :charset, action: :charset},
    '$Actor4'   => {frames: 3, rows: 4, mirror: true, invert: false,
                    mode: :charset, action: :kaduki},
    '$Slime'    => {frames: 3, rows: 4, mirror: false, invert: false,
                    mode: :charset, action: :charset},
    '$Imp'      => {frames: 3, rows: 4, mirror: false, invert: false,
                    mode: :charset, action: :charset},                    
    'Wizard_f'  => {frames: 3, rows: 4, mirror: false, invert: false,
                    mode: :charset, action: :charset},
    'Hero_m'    => {frames: 4, rows: 14, mirror: false, mode: :sprite,
                    action: :default},
    'Thief_m'   => {frames: 3, rows: 4, mirror: true, invert: false,
                    mode: :charset, action: :kaduki},
  } # Don't remove
  #--------------------------------------------------------------------------
  # * Settings Used For all battlers that doesn't have specific settings
  #--------------------------------------------------------------------------
  VE_DEFAULT_ACTION = "
  
    # Pose displayed when idle
    <action: idle, loop>
    pose: self, row idle, all frames, wait 8;
    wait: 32;
    </action>
  
    # Pose displayed when incapacited
    <action: dead, loop>
    pose: self, row dead, all frames, wait 8;
    wait: 32;
    </action>
  
    # Pose displayed when hp is low
    <action: danger, loop>
    pose: self, row danger, all frames, wait 8;
    wait: 32;
    </action>
  
    # Pose displayed when guarding
    <action: guard, loop>
    pose: self, row guard, all frames, wait 12;
    wait: 48;
    </action>
  
    # Pose displayed during the battle start
    <action: intro, reset>
    pose: self, row intro, all frames, wait 16;
    wait: 64;
    </action>
  
    # Pose displayed during battle victory
    <action: victory, wait>
    pose: self, row victory, all frames, wait 16;
    wait: 64;
    </action>
  
    # Pose displayed while waiting to perfom actions
    <action: ready, loop>
    pose: self, row ready, frame 1;
    wait: 32;
    </action>
    
    # Pose displayed while waiting to perfom item actions
    <action: item cast, loop>
    pose: self, row itemcast, frame 1;
    wait: 32;
    </action>
    
    # Pose displayed while waiting to perfom skill actions
    <action: skill cast, loop>
    pose: self, row skillcast, frame 1;
    wait: 32;
    </action>
    
    # Pose displayed while waiting to perfom magic actions
    <action: magic cast, loop>
    pose: self, row magiccast, frame 1;
    wait: 32;
    </action>
    
    # Pose displayed before inputing commands
    <action: command, reset>
    </action>
    
    # Pose displayed after inputing commands
    <action: input, reset>
    </action>
    
    # Pose displayed when cancel inputing commands
    <action: cancel, reset>
    </action>
    
    # Pose displayed when recive damage
    <action: hurt, reset>
    pose: self, row hurt, all frames, wait 4;
    wait: 16
    </action>
  
    # Pose displayed when evading attacks
    <action: evade, reset>
    pose: self, row evade, all frames, wait 4;
    wait: 16;
    </action>
  
    # Pose displayed when a attack miss
    <action: miss, reset>
    </action>
  
    # Pose displayed when reviving
    <action: revive, reset>
    </action>
  
    # Pose displayed when dying
    <action: die, reset>
    </action>
  
    # Make the target inactive (important, avoid change)
    <action: inactive>
    inactive;
    </action>
  
    # Finish offensive action (important, avoid change)
    <action: finish>
    finish;
    </action>
  
    # Set action advance
    <action: advance, reset>
    action: self, move to target;
    wait: action;
    </action>
    
    # Movement to target
    <action: move to target, reset>
    wait: targets, movement;
    wait: animation;
    move: self, move to;
    direction: targets;
    jump: self, move, height 7;
    pose: self, row advance, all frames, wait 4;
    wait: movement;
    </action>
    
    # Step foward movement
    <action: step foward, reset>
    wait: targets, movement;
    wait: animation;
    move: self, step foward, speed 6;
    pose: self, row advance, all frames, wait 4;
    wait: movement;
    </action>
    
    # Step backward movement
    <action: step backward, reset>
    wait: animation;
    move: self, step backward, speed 6;
    pose: self, row retreat, all frames, wait 4, invert;
    wait: movement;
    </action>

    # Return to original spot
    <action: retreat, reset>
    move: self, retreat;
    pose: self, row retreat, all frames, wait 4, invert;
    jump: self, move, height 7;
    wait: movement;
    direction: default;
    </action>
    
    # Move outside of the screen
    <action: escape, reset>
    move: self, escape;
    pose: self, row retreat, all frames, wait 4, invert;
    wait: movement;
    </action>
    
    # Pose used for Defend command
    <action: defend, reset>
    pose: self, row guard, all frames, wait 8;
    wait: 4;
    anim: targets, effect;
    wait: 4;
    effect: 100%;
    wait: 20;
    </action>
    
    # Pose for physical attacks
    <action: attack, reset>
    wait: targets, movement;
    pose: self, row attack, all frames, wait 4;
    wait: 4;
    anim: targets, weapon;
    wait: 8;
    effect: 100%;
    wait: 20;
    </action>
    
    # Pose for physical attack with two weapons
    <action: dual attack, reset>
    wait: targets, movement;
    pose: self, row attack, all frames, wait 4;
    wait: 4;
    anim: targets, weapon 1;
    wait: 8;
    effect: 75%, weapon 1;
    wait: 4;
    wait: animation;
    pose: self, row skill, all frames, wait 4;
    wait: 8;
    anim: targets, weapon 2;
    wait: 4;
    effect: 75%, weapon 2;
    wait: 20;
    </action>
        
    # Pose for using actions without type
    <action: use, reset>
    wait: targets, movement;
    wait: animation;
    pose: self, row item, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 4;
    effect: 100%;
    wait: 20;
    </action>
    
    # Pose for item use
    <action: item, reset>
    wait: targets, movement;
    wait: animation;
    pose: self, row direction, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 4;
    effect: 100%;
    wait: 20;
    </action>
    
    # Pose for magical skill use
    <action: magic, reset>
    wait: targets, movement;
    wait: animation;
    pose: self, row magic, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: 100%;
    wait: 20;
    </action>
    
    # Pose for physical skill use
    <action: skill, reset>
    wait: targets, movement;
    pose: self, row attack, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: 100%;
    wait: 20;
    </action>
    
    # Pose for counter attack activation (important, avoid change)
    <action: counter on, reset>
    counter: self, on;
    wait: counter;
    </action>
    
    # Pose for counter attack deactivation (important, avoid change)
    <action: counter off, reset>
    counter: targets, off;
    </action>
    
    # Pose for magic reflection
    <action: reflection, reset>
    wait: animation;
    wait: 4;
    anim: self, effect;
    wait: 8;
    effect: 100%;
    wait: animation;
    </action>
    
    # Pose for substitution activation (important, avoid change)
    <action: substitution on, reset>
    move: self, substitution, teleport;
    wait: movement;
    </action>
    
    # Pose for substitution deactivation
    <action: substitution off, reset>
    move: self, retreat, speed 15;
    </action>
    
    # Pose for the skill 'Dual Attack'
    <action: double attack, reset>
    wait: targets, movement;
    pose: self, row attack, all frames, wait 4;
    wait: 4;
    anim: targets, weapon;
    wait: 8;
    effect: 75%;
    wait: 4;
    wait: animation;
    pose: self, row skill, all frames, wait 4;
    wait: 8;
    anim: targets, weapon;
    wait: 4;
    effect: 75%;
    wait: 20;
    </action>
    
    # Pose for the skills 'Life Drain' and 'Manda Drain'
    <action: drain, reset>
    wait: targets, movement;
    wait: animation;
    pose: self, row magic, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: 100%;
    wait: 20;
    action: targets, user drain;
    wait: action;
    </action>

    # Pose for the targets of the skills 'Life Drain' and 'Manda Drain'
    <action: user drain, reset>
    throw: self, icon 187, return, revert, init y -12, end y -12;
    wait: self, throw;
    drain: self;
    wait: animation;
    </action>    
    
    # Pose for the sample skill 'Throw Weapon'
    <action: throw weapon, reset>
    wait: targets, movement;
    pose: self, row attack, all frames, wait 4;
    action: targets, target throw;
    wait: action;
    </action>
    
    # Pose for the targets of the sample skill 'Throw Weapon'
    <action: target throw, reset>
    throw: self, weapon, arc 12, spin +45, init y -12, end y -12;
    wait: self, throw;
    throw: self, weapon, arc 12, spin +45, return, revert, init y -12, end y -12;
    anim: self, weapon;
    effect: self, 100%;
    wait: self, throw;
    wait: animation;
    </action>
    
    # Pose for the sample skill 'Lightning Strike'
    <action: lightning strike, 5 times>
    wait: targets, movement;
    direction: targets;
    pose: self, row attack, frame 1, all frames, wait 2;
    move: self, x -48, speed 50;
    anim: targets, effect;
    effect: 20%;
    </action>
    
    # Pose for the sample skill 'Tempest'
    <action: tempest, reset>
    wait: targets, movement;
    wait: animation;
    pose: self, row magic, all frames, wait 4;
    wait: 4;
    tone: black, high priority, duration 20;
    wait: tone;
    movie: name 'Tempest', white, high priority;
    tone: clear, high priority, duration 20;
    wait: 15;
    anim: targets, effect;
    flash: screen, duration 10; 
    effect: 100%;
    wait: 20;
    </action>
    
    # Pose for the sample skill 'Meteor'
    <action: meteor, reset>
    wait: targets, movement;
    wait: animation;
    pose: self, row magic, all frames, wait 4;
    wait: 4;
    tone: black, high priority, duration 20;
    wait: tone;
    movie: name 'Meteor';
    tone: clear, high priority, duration 20;
    anim: targets, effect;
    wait: 20;
    effect: 100%;
    wait: 20;
    </action>
    
    # Pose for 'Bow' type weapons
    <action: bow, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row attack, all frames, wait 4;
    action: targets, arrow;
    wait: action;
    </action>
    
    # Pose for the targets of 'Bow' attack
    <action: arrow, reset>
    throw: self, image 'Arrow', arc 10, angle 45, init x -6, init y -12;
    wait: self, throw;
    anim: self, weapon;
    effect: self, 100%;
    wait: animation;
    </action>
    
    # Movement to target for the skill 'Aura Blade'
    <action: aura blade move to, reset>
    wait: targets, movement;
    pose: self, row magic, all frames, wait 2;
    anim: id 81;
    wait: animation;
    </action>
    
    # Pose for the skill 'Aura Blade'
    <action: aura blade, reset>
    wait: targets, movement;
    pose: self, row magic, all frames, wait 2;
    anim: id 81;
    wait: animation;
    pose: self, row advance, all frames, wait 2;
    move: move to;
    wait: movement;
    jump: height 16;
    wait: 12;
    pose: self, row attack, frame 1;
    freeze: duration 40;
    anim: self, id 66;
    wait: self, freeze;
    wait: 4;
    pose: self, row attack, all frames, wait 2;
    wait: 4;
    anim: targets, effect;
    flash: screen, duration 8;
    wait: 8;
    effect: 75%, weapon;
    flash: screen, duration 8;
    wait: 4;
    </action>
    
    "
  #--------------------------------------------------------------------------
  # * Sample settings used for battlers tagged as 'charset'
  #--------------------------------------------------------------------------
  VE_ACTION_SETTINGS[:charset] = "
    # Pose displayed when idle
    <action: idle, loop>
    pose: self, row direction, frame 2;
    wait: 16;
    </action>
  
    # Pose displayed when incapacited
    <action: dead, loop>
    pose: self, row 4, frame 2, angle -90, x -16, y -12;
    wait: 32;
    </action>
  
    # Pose displayed when hp is low
    <action: danger, loop>
    pose: self, row direction, frame 2;
    wait: 16;
    </action>
  
    # Pose displayed when guarding
    <action: guard, loop>
    icon: self, shield, y +8, above;
    pose: self, row direction, frame 1;
    wait: 16;
    </action>
  
    # Pose displayed during the battle start
    <action: intro, reset>
    pose: self, row direction, frame 2;
    wait: 64;
    </action>
  
    # Pose displayed during battle victory
    <action: victory, wait>
    pose: self, row 2, frame 2;
    wait: 2;
    pose: self, row 4, frame 2;
    wait: 2;
    pose: self, row 3, frame 2;
    wait: 2;
    pose: self, row 1, frame 2;
    wait: 2;
    pose: self, row 2, frame 2;
    wait: 2;
    pose: self, row 4, frame 2;
    wait: 2;
    pose: self, row 3, frame 2;
    wait: 2;
    pose: self, row 1, frame 2;
    wait: 2;
    jump: self, height 8, speed 8;
    wait: 10
    </action>
  
    # Pose displayed while waiting to perfom actions
    <action: ready, loop>
    pose: self, row direction, all frames, return, wait 8;
    wait: 32;
    </action>
    
    # Pose displayed while waiting to perfom item actions
    <action: item cast, loop>
    pose: self, row direction, all frames, return, wait 8;
    wait: 32;
    </action>
    
    # Pose displayed while waiting to perfom skill actions
    <action: skill cast, loop>
    pose: self, row direction, all frames, return, wait 8;
    wait: 32;
    </action>
    
    # Pose displayed while waiting to perfom magic actions
    <action: magic cast, loop>
    pose: self, row direction, all frames, return, wait 8;
    wait: 32;
    </action>
    
    # Pose displayed before inputing commands
    <action: command, reset>
    action: self, step foward;
    wait: action;
    </action>
    
    # Pose displayed after inputing commands
    <action: input, reset>
    action: self, step backward;
    wait: action;
    </action>
    
    # Pose displayed when cancel inputing commands
    <action: cancel, reset>
    action: self, step backward;
    wait: action;
    </action>
    
    # Pose displayed when recive damage
    <action: hurt, reset>
    move: self, retreat, teleport;
    direction: active;
    pose: self, row direction, all frames, wait 4, return;
    move: self, step backward, speed 4;
    wait: movement;
    pose: self, row direction, frame 2;
    wait: 4;
    pose: self, row direction, all frames, wait 4, return;
    move: self, step foward, speed 5;
    wait: movement;
    direction: default;
    </action>
  
    # Pose displayed when evading attacks
    <action: evade, reset>
    move: self, retreat, teleport;
    direction: active;
    pose: self, row 1, frame 2;
    move: self, step backward, speed 4;
    jump: self, move;
    wait: movement;
    pose: self, row direction, frame 2;
    wait: 4;
    pose: self, row direction, all frames, wait 4, return;
    move: self, step foward, speed 5;
    wait: movement;
    direction: default;
    </action>
  
    # Pose displayed when a attack miss
    <action: miss, reset>
    </action>
  
    # Pose displayed when reviving
    <action: revive, reset>
    </action>
  
    # Pose displayed when dying
    <action: die, reset>
    </action>
  
    # Make the target inactive (important, avoid change)
    <action: inactive>
    inactive;
    </action>
  
    # Finish offensive action (important, avoid change)
    <action: finish>
    finish;
    </action>

    # Set action advance
    <action: advance, reset>
    action: self, move to target;
    wait: action;
    </action>
    
    # Movement to target
    <action: move to target, reset>
    wait: targets, movement;
    wait: animation;
    move: self, move to;
    direction: targets;
    pose: self, row direction, all frames, return, wait 4;
    wait: movement;
    </action>
    
    # Step foward movement
    <action: step foward, reset>
    wait: targets, movement;
    wait: animation;
    move: self, step foward, speed 6;
    pose: self, row direction, all frames, return, wait 4;
    wait: movement;
    </action>

    # Step backward movement
    <action: step backward, reset>
    wait: animation;
    move: self, step backward, speed 6;
    pose: self, row direction, all frames, return, wait 4;
    wait: movement;
    </action>

    # Return to original spot
    <action: retreat, reset>
    direction: return;
    move: self, retreat;
    pose: self, row direction, all frames, return, wait 4;
    wait: movement;
    direction: default;
    </action>
    
    # Move outside of the screen
    <action: escape, reset>
    move: self, escape;
    pose: self, row direction, all frames, return, wait 4;
    wait: movement;
    </action>
    
    # Pose used for Defend command
    <action: defend, reset>
    pose: self, row direction, all frames, wait 8;
    wait: 4;
    anim: targets, effect;
    wait: 4;
    effect: 100%;
    wait: 20;
    </action>
    
    # Pose for physical attacks
    <action: attack, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row direction, all frames, wait 2, y +1;
    icon: weapon, angle -90, x +12, y -16;
    icon: weapon, angle -45, x +6, y -16;
    icon: weapon, angle 0, x -6;
    anim: targets, weapon;
    icon: weapon, angle 45, x -10, y +8;
    effect: 100%;
    wait: 20;
    icon: delete;
    </action>
    
    # Pose for physical attack with two weapons
    <action: dual attack, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row direction, all frames, wait 2, y +1;
    icon: weapon, angle -90, x +12, y -16;
    icon: weapon, angle -45, x +6, y -16;
    icon: weapon, angle 0, x -6;
    anim: targets, weapon;
    icon: weapon, angle 45, x -10, y +8;
    effect: 75%, weapon;
    wait: animation;
    icon: delete;
    direction: targets;
    pose: self, row direction, all frames, wait 2, revert, y +1;
    icon: weapon 2, angle -90, x +12, y -16;
    icon: weapon 2, angle -45, x +6, y -16;
    icon: weapon 2, angle 0;
    anim: targets, weapon;
    icon: weapon 2, angle 45, x -6, y +8;
    effect: 75%, weapon 2;
    wait: 20;
    icon: delete;
    </action>
    
    # Pose for using actions without type
    <action: use, reset>
    wait: targets, movement;
    action: self, step foward;
    pose: self, row direction, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 4;
    effect: 100%;
    wait: 20;
    action: self, step backward;
    </action>
    
    # Pose for item use
    <action: item, reset>
    wait: targets, movement;
    action: self, step foward;
    wait: 10;
    pose: self, row direction, frame 1;
    icon: action, x -8, above;
    wait: 4;
    pose: self, row direction, frame 2;
    icon: action, x -4, y -4, above;
    wait: 4;
    pose: self, row direction, frame 3;
    icon: action, y -8, above;
    wait: 4;
    pose: self, row direction, frame 2;
    icon: action, y -8, x +4, above;
    wait: 12;
    icon: delete;
    pose: self, row direction, frame 1;
    throw: targets, action, arc 10, init y -8;
    wait: targets, throw;
    anim: targets, effect;
    wait: 4;
    effect: 100%;
    wait: 20;
    action: self, step backward;
    </action>
    
    # Pose for magical skill use
    <action: magic, reset>
    wait: targets, movement;
    action: self, step foward;
    direction: targets;
    pose: self, row direction, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: 100%;
    wait: 20;
    action: self, step backward;
    </action>
    
    # Pose for physical skill use
    <action: skill, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row direction, all frames, wait 2;
    icon: weapon, angle -90, x +12, y -16;
    icon: weapon, angle -45, x +6, y -16;
    icon: weapon, angle 0, x -6;
    anim: targets, effect;
    icon: weapon, angle 45, x -10, y +8;
    effect: 100%;
    wait: 20;
    icon: delete;
    </action>
    
    # Pose for counter attack activation (important, avoid change)
    <action: counter off, reset>
    counter: targets, off;
    </action>

    # Pose for counter attack deactivation (important, avoid change)
    <action: counter on, reset>
    counter: self, on;
    wait: counter;
    </action>
    
    # Pose for magic reflection
    <action: reflection, reset>
    wait: animation;
    wait: 4;
    anim: self, effect;
    wait: 8;
    effect: 100%;
    wait: animation;
    </action>
    
    # Pose for substitution activation (important, avoid change)
    <action: substitution on, reset>
    move: self, substitution, teleport;
    wait: movement;
    </action>
    
    # Pose for substitution deactivation (important, avoid change)
    <action: substitution off, reset>
    move: self, retreat, teleport;
    </action>
    
    # Pose for the skill 'Dual Attack'
    <action: dual attack, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row direction, all frames, wait 2, y +1;
    icon: weapon, angle -90, x +12, y -16;
    icon: weapon, angle -45, x +6, y -16;
    icon: weapon, angle 0, x -6;
    anim: targets, effect;
    icon: weapon, angle 45, x -10, y +8;
    effect: 100%;
    wait: animation;
    icon: delete;
    direction: targets;
    pose: self, row direction, all frames, wait 2, revert, y +1;
    icon: weapon, angle -90, x +12, y -16;
    icon: weapon, angle -45, x +6, y -16;
    icon: weapon, angle 0;
    anim: targets, effect;
    icon: weapon, angle 45, x -6, y +8;
    effect: 100%;
    wait: 20;
    icon: delete;
    </action>
    
    # Pose for the skills 'Life Drain' and 'Mana Drain'
    <action: drain, reset>
    wait: targets, movement;
    wait: animation;
    direction: targets;
    pose: self, row direction, all frames, wait 4;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: 100%;
    wait: 20;
    action: targets, user drain;
    wait: action;
    </action>

    # Pose for the targets of the skills 'Life Drain' and 'Mana Drain
    <action: user drain, reset>
    throw: self, icon 187, return, revert, init y -12, end y -12;
    wait: self, throw;
    drain: self;
    wait: animation;
    </action>    
    
    # Pose for the sample skill 'Throw Weapon'
    <action: throw weapon, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row direction, frame 1;
    pose: self, row direction, frame 2;
    action: targets, target throw;
    pose: self, row direction, frame 3;
    wait: action;
    </action>
    
    # Pose for the targets of the sample skill 'Throw Weapon'
    <action: target throw, reset>
    throw: self, weapon, arc 12, spin +45, init y -12, end y -12;
    wait: self, throw;
    throw: self, weapon, arc 12, spin +45, return, revert, init y -12, end y -12;
    anim: self, weapon;
    effect: self, 100%;
    wait: self, throw;
    wait: animation;
    </action>
    
    # Pose for the sample skill 'Lightning Strike'
    <action: lightning strike, 5 times>
    wait: targets, movement;
    direction: targets;
    pose: self, row direction, frame 3, y +1;
    move: self, x -48, speed 50;
    icon: weapon, angle 45, x -12, y +8;
    anim: targets, effect;
    effect: 20%;
    icon: delete;
    </action>
    
    # Pose for the sample skill 'Tempest'
    <action: tempest, reset>
    wait: targets, movement;
    wait: animation;
    pose: self, row direction, all frames, wait 4;
    wait: 4;
    tone: black, high priority, duration 20;
    wait: tone;
    movie: name 'Tempest', white, high priority;
    tone: clear, high priority, duration 20;
    wait: 15;
    anim: targets, effect;
    flash: screen, duration 10; 
    effect: 100%;
    wait: 20;
    </action>
    
    # Pose for the sample skill 'Meteor'
    <action: meteor, reset>
    wait: targets, movement;
    wait: animation;
    pose: self, row direction, all frames, wait 4;
    wait: 4;
    tone: black, high priority, duration 20;
    wait: tone;
    movie: name 'Meteor';
    tone: clear, high priority, duration 20;
    anim: targets, effect;
    wait: 20;
    effect: 100%;
    wait: 20;
    </action>
    
    # Pose for 'Claw' type weapons
    <action: claw, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row direction, all frames, wait 3, y +1;
    icon: weapon, angle -45, x +16, y -16;
    icon: weapon, angle -30, x +10, y -16;
    icon: weapon, angle -15, x -2;
    anim: targets, weapon;
    icon: weapon, angle 0, x -6, y +8;
    effect: 100%;
    wait: 20;
    icon: delete;
    </action>
    
    # Pose for 'Spear' type weapons
    <action: spear, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row direction, all frames, wait 3, y +1;
    icon: weapon, angle 45, x +12, y +8;
    icon: weapon, angle 45, x +12, y +8;
    icon: weapon, angle 45, x 0, y +8;
    anim: targets, weapon;
    icon: weapon, angle 45, x -12, y +8;
    effect: 100%;
    wait: 20;
    icon: delete;
    </action>
    
    # Pose for 'Gun' type weapons
    <action: gun, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row direction, all frames, wait 3;
    icon: weapon, angle -135, x +12, y -16;
    icon: weapon, angle -105, x +6, y -10;
    icon: weapon, angle -75, x 0, y -2;
    icon: weapon, angle -45, x -6, y +4;
    wait: 30;
    sound: name 'Gun1';
    pose: self, row direction, frame 3;
    icon: weapon, angle -75, x 0, y -2;
    pose: self, row direction, frame 2;
    icon: weapon, angle -105, x +6, y -10;
    pose: self, row direction, frame 1;
    anim: targets, weapon;
    icon: weapon, angle -135, x +12, y -16;
    effect: 100%;
    wait: 20;
    icon: delete;
    </action>
    
    # Pose for 'Bow' type weapons
    <action: bow, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row 2, all frames, sufix _3, wait 4;
    icon: image 'Bow1', x +6, above;
    icon: image 'Bow2', x +6, above;
    icon: image 'Bow3', x +6, above;
    wait: 10;
    icon: image 'Bow2', x +6, above;
    icon: image 'Bow1', x +6, above;
    action: targets, arrow;
    wait: action;
    </action>

    # Pose for the targets of 'Bow' attack
    <action: arrow, reset>
    throw: self, image 'Arrow', arc 10, angle 45, init x -6, init y -12;
    wait: self, throw;
    anim: self, weapon;
    effect: self, 100%;
    wait: animation;
    </action>
        
    "
  #--------------------------------------------------------------------------
  # * Sample settings used for battlers tagged as 'kaduki' style
  #--------------------------------------------------------------------------
  VE_ACTION_SETTINGS[:kaduki] = "
  
    # Pose displayed when idle
    <action: idle, loop>
    pose: self, row 1, all frames, sufix _1, return, loop, wait 16;
    wait: pose;
    </action>
  
    # Pose displayed when incapacited
    <action: dead, loop>
    pose: self, row 4, all frames, sufix _2, return, loop, wait 8;
    wait: pose;
    </action>
  
    # Pose displayed when hp is low
    <action: danger, loop>
    pose: self, row 3, all frames, sufix _1, return, loop, wait 16;
    wait: pose;
    </action>
  
    # Pose displayed when guarding
    <action: guard, loop>
    icon: self, shield, y +8, above;
    pose: self, row 4, frame 3, sufix _1;
    wait: 16;
    </action>
  
    # Pose displayed during the battle start
    <action: intro, reset>
    pose: self, row 1, frame 2, sufix _1;
    wait: 12;
    </action>
  
    # Pose displayed during battle victory
    <action: victory, wait>
    pose: self, row 1, all frames, sufix _2, wait 8;
    wait: pose;
    </action>
  
    # Pose displayed while waiting to perfom actions
    <action: ready, loop>
    pose: self, row 1, frame 2, sufix _1;
    wait: 24;
    </action>
    
    # Pose displayed while waiting to perfom item actions
    <action: item cast, loop>
    pose: self, row 1, frame 2, sufix _1;
    wait: 24;
    </action>
    
    # Pose displayed while waiting to perfom skill actions
    <action: skill cast, loop>
    pose: self, row 1, frame 2, sufix _1;
    wait: 24;
    </action>
    
    # Pose displayed while waiting to perfom magic actions
    <action: magic cast, loop>
    pose: self, row 4, all frames, sufix _3, loop, wait 8;
    wait: pose;
    </action>
    
    # Pose displayed before inputing commands
    <action: command, reset>
    action: self, step foward;
    wait: action;
    </action>
    
    # Pose displayed after inputing commands
    <action: input, reset>
    action: self, step backward;
    wait: action;
    </action>
    
    # Pose displayed when cancel inputing commands
    <action: cancel, reset>
    action: self, step backward;
    wait: action;
    </action>
        
    # Pose displayed when recive damage
    <action: hurt, reset>
    move: self, retreat, teleport;
    pose: self, row 2, all frames, sufix _1, wait 4;
    move: self, step backward, speed 4;
    wait: movement;
    pose: self, row direction, frame 2;
    wait: 4;
    pose: self, row 4, all frames, wait 4, return, sufix _1;
    move: self, step foward, speed 5;
    wait: movement;
    </action>
  
    # Pose displayed when evading attacks
    <action: evade, reset>
    pose: self, row 2, sufix _2, all frames, wait 4,;
    move: self, step backward, speed 4;
    jump: self, move;
    wait: movement;
    pose: self, row 1, frame 2, sufix _2;
    wait: 4;
    pose: self, row 4, all frames, wait 4, return, sufix _1;
    move: self, step foward, speed 5;
    wait: movement;
    </action>
  
    # Pose displayed when a attack miss
    <action: miss, reset>
    </action>
  
    # Pose displayed when reviving
    <action: revive, reset>
    </action>
  
    # Pose displayed when dying
    <action: die, reset>
    </action>
    
    # Make the target inactive (important, avoid change)
    <action: inactive>
    inactive;
    </action>
  
    # Finish offensive action (important, avoid change)
    <action: finish>
    finish;
    </action>
    
    # Set action advance
    <action: advance, reset>
    action: self, move to target;
    wait: action;
    </action>
    
    # Movement to target
    <action: move to target, reset>
    wait: targets, movement;
    wait: animation;
    move: self, move to;
    direction: targets;
    pose: self, row 4, all frames, sufix _1, return, loop, wait 8;
    wait: movement;
    </action>
    
    # Step foward movement
    <action: step foward, reset>
    wait: targets, movement;
    wait: animation;
    move: self, step foward, speed 6;
    pose: self, row 4, all frames, sufix _1, return, wait 8;
    wait: movement;
    </action>

    # Step backward movement
    <action: step backward, reset>
    wait: animation;
    move: self, step backward, speed 6;
    pose: self, row 4, all frames, sufix _1, return, wait 8;
    </action>
    
    # Return to original spot
    <action: retreat, reset>
    direction: return;
    move: self, retreat;
    pose: self, row 4, all frames, sufix _1, return, loop, wait 8;
    wait: movement;
    direction: default;
    </action>
    
    # Move outside of the screen
    <action: escape, reset>
    move: self, escape;
    pose: self, row 4, all frames, sufix _1, return, wait 8;
    wait: movement;
    </action>
    
    # Pose used for Defend command
    <action: defend, reset>
    pose: self, row 4, frame 2, sufix _1;
    icon: self, shield, y +8, above;
    pose: self, row 4, frame 3, sufix _1;
    wait: 4;
    anim: targets, effect;
    wait: 4;
    effect: 100%;
    wait: 20;
    </action>
    
    # Pose for physical attacks
    <action: attack, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: weapon, angle -90, x +12, y -16;
    icon: weapon, angle -45, x +6, y -16;
    icon: weapon, angle 0, x -6;
    anim: targets, weapon;
    icon: weapon, angle 45, x -10, y +8;
    effect: 100%;
    wait: 20;
    icon: delete;
    </action>
    
    # Pose for physical attack with two weapons
    <action: dual attack, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: weapon, angle -180, x +12, y -16;
    icon: weapon, angle -135, x +12, y -16;
    icon: weapon, angle -90, x +12, y -16;
    icon: weapon, angle -45, x +6, y -16;
    icon: weapon, angle 0, x -6;
    anim: targets, weapon 1;
    icon: weapon, angle 45, x -10, y +8;
    effect: 75%, weapon 1;
    wait: animation;
    icon: delete;
    direction: targets;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: weapon 2, angle -180, x +12, y -16;
    icon: weapon 2, angle -135, x +12, y -16;
    icon: weapon 2, angle -90, x +12, y -16;
    icon: weapon 2, angle -45, x +6, y -16;
    icon: weapon 2, angle 0;
    anim: targets, weapon 2;
    icon: weapon 2, angle 45, x -6, y +8;
    effect: 75%, weapon 2;
    wait: 20;
    icon: delete;
    </action>
    
    # Pose for using actions without type
    <action: use, reset>
    wait: targets, movement;
    wait: animation;
    action: self, step foward;
    pose: self, row 2, all frames, sufix _3, wait 3;
    wait: 4;
    anim: targets, effect;
    wait: 4;
    effect: 100%;
    wait: 20;
    action: self, step backward;
    </action>
    
    # Pose for item use
    <action: item, reset>
    wait: targets, movement;
    wait: animation;
    action: self, step foward;
    wait: 10;
    pose: self, row 2, all frames, sufix _3, wait 3;
    icon: action, x -8, above;
    wait: 4;
    icon: action, x -4, y -4, above;
    wait: 4;
    icon: action, y -8, above;
    wait: 4;
    icon: action, y -8, x +4, above;
    wait: 12;
    pose: self, row 1, all frames, sufix _3, wait 2;
    icon: delete;
    throw: targets, action, arc 10, init y -8;
    wait: targets, throw;
    anim: targets, effect;
    wait: 4;
    effect: 100%;
    wait: 20;
    action: self, step backward;
    </action>
    
    # Pose for magical skill use
    <action: magic, reset>
    wait: targets, movement;
    wait: animation;
    action: self, step foward;
    direction: targets;
    pose: self, row 3, all frames, sufix _3, wait 3;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: 100%;
    wait: 20;
    action: self, step backward;
    </action>
    
    # Pose for physical skill use
    <action: skill, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: weapon, angle -90, x +12, y -16;
    icon: weapon, angle -45, x +6, y -16;
    icon: weapon, angle 0, x -6;
    anim: targets, weapon;
    icon: weapon, angle 45, x -10, y +8;
    effect: 100%;
    wait: 20;
    icon: delete;
    </action>
    
    # Pose for counter attack activation (important, avoid change)
    <action: counter on, reset>
    counter: self, on;
    wait: counter;
    </action>

    # Pose for counter attack deactivation (important, avoid change)
    <action: counter off, reset>
    counter: targets, off;
    </action>
    
    # Pose for magic reflection
    <action: reflection, reset>
    wait: animation;
    wait: 4;
    anim: self, effect;
    wait: 8;
    effect: 100%;
    wait: animation;
    </action>
    
    # Pose for substitution activation (important, avoid change)
    <action: substitution on, reset> 
    move: self, substitution, teleport;
    wait: movement;
    </action>
    
    # Pose for substitution deactivation
    <action: substitution off, reset>
    move: self, retreat, speed 15;
    </action>

    # Pose for the skill 'Dual Attack'
    <action: dual attack, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: weapon, angle -180, x +12, y -16;
    icon: weapon, angle -135, x +12, y -16;
    icon: weapon, angle -90, x +12, y -16;
    icon: weapon, angle -45, x +6, y -16;
    icon: weapon, angle 0, x -6;
    anim: targets, effect;
    icon: weapon, angle 45, x -10, y +8;
    effect: 100%;
    wait: animation;
    icon: delete;
    direction: targets;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: weapon, angle -180, x +12, y -16;
    icon: weapon, angle -135, x +12, y -16;
    icon: weapon, angle -90, x +12, y -16;
    icon: weapon, angle -45, x +6, y -16;
    icon: weapon, angle 0;
    anim: targets, effect;
    icon: weapon, angle 45, x -6, y +8;
    effect: 100%;
    wait: 20;
    icon: delete;
    </action>
    
    # Pose for the skills 'Life Drain' and 'Manda Drain'
    <action: drain, reset>
    wait: targets, movement;
    wait: animation;
    direction: targets;
    pose: self, row 3, all frames, sufix _3, wait 3;
    wait: 4;
    anim: targets, effect;
    wait: 8;
    effect: 100%;
    wait: 20;
    action: targets, user drain;
    wait: action;
    </action>

    # Pose for the targets of the skills 'Life Drain' and 'Manda Drain'
    <action: user drain, reset>
    throw: self, icon 187, return, revert, init y -12, end y -12;
    wait: self, throw;
    drain: self;
    wait: animation;
    </action>    
    
    # Pose for the sample skill 'Throw Weapon'
    <action: throw weapon, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row 1, all frames, sufix _3, wait 3;
    wait: 3;
    action: targets, target throw;
    wait: action;
    </action>
    
    # Pose for the targets of the sample skill 'Throw Weapon'
    <action: target throw, reset>
    throw: self, weapon, arc 12, spin +45, init y -12, end y -12;
    wait: self, throw;
    throw: self, weapon, arc 12, spin +45, return, revert, init y -12, end y -12;
    anim: self, weapon;
    effect: self, 100%;
    wait: self, throw;
    wait: animation;
    </action>
    
    # Pose for the sample skill 'Lightning Strike'
    <action: lightning strike, 10 times>
    wait: targets, movement;
    direction: targets;
    pose: self, row 1, frame 3, sufix _3, y +1;
    move: self, x -48, speed 50;
    icon: weapon, angle 45, x -12, y +8;
    anim: targets, effect;
    effect: 20%;
    icon: delete;
    </action>
    
    # Pose for the sample skill 'Tempest'
    <action: tempest, reset>
    wait: targets, movement;
    wait: animation;
    pose: self, row 3, all frames, sufix _3, wait 3;
    wait: 4;
    tone: black, high priority, duration 20;
    wait: tone;
    movie: name 'Tempest', white, high priority;
    tone: clear, high priority, duration 20;
    wait: 15;
    anim: targets, effect;
    flash: screen, duration 10; 
    effect: 100%;
    wait: 20;
    </action>
    
    # Pose for the sample skill 'Meteor'
    <action: meteor, reset>
    wait: targets, movement;
    wait: animation;
    pose: self, row 3, all frames, sufix _3, wait 3;
    wait: 4;
    tone: black, high priority, duration 20;
    wait: tone;
    movie: name 'Meteor';
    tone: clear, high priority, duration 20;
    anim: targets, effect;
    wait: 20;
    effect: 100%;
    wait: 20;
    </action>
    
    # Pose for 'Claw' type weapons
    <action: claw, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: weapon, angle -45, x +16, y -16;
    icon: weapon, angle -30, x +10, y -16;
    icon: weapon, angle -15, x -2;
    anim: targets, weapon;
    icon: weapon, angle 0, x -6, y +8;
    effect: 100%;
    wait: 20;
    icon: delete;
    </action>
    
    # Pose for 'Spear' type weapons
    <action: spear, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row 1, all frames, sufix _3, wait 3, y +1;
    icon: weapon, angle 45, x +12, y +8;
    icon: weapon, angle 45, x +12, y +8;
    icon: weapon, angle 45, x 0, y +8;
    anim: targets, weapon;
    icon: weapon, angle 45, x -12, y +8;
    effect: 100%;
    wait: 20;
    icon: delete;
    </action>
    
    # Pose for 'Gun' type weapons
    <action: gun, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row 1, all frames, sufix _3, wait 3;
    icon: weapon, angle -135, x +12, y -16;
    icon: weapon, angle -105, x +6, y -10;
    icon: weapon, angle -75, x 0, y -2;
    icon: weapon, angle -45, x -6, y +4;
    wait: 30;
    sound: name 'Gun1';
    pose: self, row 1, frame 3, sufix _3;
    icon: weapon, angle -75, x -6, y -2;
    pose: self, row 1, frame 2, sufix _3;
    icon: weapon, angle -105, y -10;
    pose: self, row 1, frame 1, sufix _3;
    anim: targets, effect;
    effect: 100%;
    wait: 20;
    icon: delete;
    </action>
    
    # Pose for 'Bow' type weapons
    <action: bow, reset>
    wait: targets, movement;
    direction: targets;
    pose: self, row 2, all frames, sufix _3, wait 4;
    icon: image 'Bow1', x +6, above;
    icon: image 'Bow2', x +6, above;
    icon: image 'Bow3', x +6, above;
    wait: 10;
    icon: image 'Bow2', x +6, above;
    icon: image 'Bow1', x +6, above;
    action: targets, arrow;
    wait: action;
    </action>
    
    # Pose for the targets of 'Bow' attack
    <action: arrow, reset>
    throw: self, image 'Arrow', arc 10, angle 45, init x -6, init y -12;
    wait: self, throw;
    anim: self, weapon;
    effect: self, 100%;
    wait: animation;
    </action>

    # Movement to target for the skill 'Aura Blade'
    <action: aura blade move to, reset>
    wait: targets, movement;
    wait: animation;
    move: self, move to, x +52;
    direction: targets;
    pose: self, row 4, all frames, sufix _1, return, wait 8;
    wait: movement;
    </action>
    
    # Pose for the skill 'Aura Blade'
    <action: aura blade, reset>
    wait: targets, movement;
    pose: self, row 4, sufix _3, all frames, wait 8, loop;
    anim: id 81;
    wait: animation;
    pose: self, row 2, sufix _3, all frames, wait 3, y +1;
    icon: weapon, angle 45, x -6, y +6;
    icon: weapon, angle 30, x -10, y +0;
    icon: weapon, angle 15, x -14, y -6;
    icon: weapon, angle 0, x -10, y -10;
    wait: 30;
    anim: id 110;
    wait: animation;
    wait: 30;
    move: self, x -144, speed 15;
    pose: self, row 1, sufix _3, all frames, wait 3, y +1;
    icon: weapon, angle -90, x +12, y -16;
    icon: weapon, angle -45, x +6, y -16;
    icon: weapon, angle 0, x -6;
    icon: weapon, angle 45, x -10, y +8;
    anim: targets, effect;
    effect: 100%;
    wait: 20;
    </action>

    "
  #--------------------------------------------------------------------------
  # * required
  #   This method checks for the existance of the basic module and other
  #   VE scripts required for this script to work, don't edit this
  #--------------------------------------------------------------------------
  def self.required(name, req, version, type = nil)
    if !$imported[:ve_basic_module]
      msg = "The script '%s' requires the script\n"
      msg += "'VE - Basic Module' v%s or higher above it to work properly\n"
      msg += "Go to http://victorscripts.wordpress.com/ to download this script."
      msgbox(sprintf(msg, self.script_name(name), version))
      exit
    else
      self.required_script(name, req, version, type)
    end
  end
  #--------------------------------------------------------------------------
  # * script_name
  #   Get the script name base on the imported value, don't edit this
  #--------------------------------------------------------------------------
  def self.script_name(name, ext = "VE")
    name = name.to_s.gsub("_", " ").upcase.split
    name.collect! {|char| char == ext ? "#{char} -" : char.capitalize }
    name.join(" ")
  end
end

$imported ||= {}
$imported[:ve_animated_battle] = 1.01
Victor_Engine.required(:ve_animated_battle, :ve_basic_module, 1.13, :above)
Victor_Engine.required(:ve_animated_battle, :ve_actor_battlers, 1.00, :bellow)
Victor_Engine.required(:ve_animated_battle, :ve_animations_settings, 1.00, :bellow)


# $imported ||= {}
# $imported[:ve_animated_battle] = 1.09
# Victor_Engine.required(:ve_animated_battle, :ve_basic_module, 1.24, :above)
# Victor_Engine.required(:ve_animated_battle, :ve_actor_battlers, 1.00, :bellow)
# Victor_Engine.required(:ve_animated_battle, :ve_animations_settings, 1.00, :bellow)
# Victor_Engine.required(:ve_animated_battle, :ve_passive_states, 1.00, :bellow)
# Victor_Engine.required(:ve_animated_battle, :ve_map_battle, 1.00, :bellow)
# Victor_Engine.required(:ve_animated_battle, :ve_state_cancel, 1.00, :bellow)
# Victor_Engine.required(:ve_animated_battle, :ve_tech_points, 1.00, :bellow)
# Victor_Engine.required(:ve_animated_battle, :ve_trait_control, 1.00, :bellow)
# Victor_Engine.required(:ve_animated_battle, :ve_mp_level, 1.00, :bellow)
# Victor_Engine.required(:ve_animated_battle, :ve_automatic_battlers, 1.00, :bellow)
# Victor_Engine.required(:ve_animated_battle, :ve_state_auto_apply, 1.00, :bellow)
# Victor_Engine.required(:ve_animated_battle, :ve_element_states, 1.00, :bellow)

#==============================================================================
# ** Object
#------------------------------------------------------------------------------
#  This class is the superclass of all other classes.
#==============================================================================

class Object
  #--------------------------------------------------------------------------
  # * New method: custom_pose
  #--------------------------------------------------------------------------
  def custom_pose(type)
    note =~ /<#{type.upcase} POSE: (\w[\w ]+)>/i ? make_symbol($1) : nil
  end
end

#==============================================================================
# ** BattleManager
#------------------------------------------------------------------------------
#  This module handles the battle processing
#==============================================================================

class << BattleManager
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :old_tone
  #--------------------------------------------------------------------------
  # * Alias method: init_members
  #--------------------------------------------------------------------------
  alias :init_members_ve_animated_battle :init_members
  def init_members
    $game_party.members.each {|member| member.clear_poses }
    init_members_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: battle_end
  #--------------------------------------------------------------------------
  alias :battle_end_ve_animated_battle :battle_end
  def battle_end(result)
    $game_party.members.each {|member| member.clear_poses }
    $game_system.no_intro   = false
    $game_system.no_victory = false
    battle_end_ve_animated_battle(result)
  end
  #--------------------------------------------------------------------------
  # * Alias method: process_victory
  #--------------------------------------------------------------------------
  alias :process_victory_ve_animated_battle :process_victory
  def process_victory
    process_battle_end_pose($game_party)
    process_victory_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: process_defeat
  #--------------------------------------------------------------------------
  alias :process_defeat_ve_animated_battle :process_defeat
  def process_defeat
    process_battle_end_pose($game_troop)
    process_defeat_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: process_escape
  #--------------------------------------------------------------------------
  alias :process_escape_ve_animated_battle :process_escape
  def process_escape
    @escaping = true
    success   = process_escape_ve_animated_battle
    @escaping = false
    return success
  end
  #--------------------------------------------------------------------------
  # * Alias method: process_abort
  #--------------------------------------------------------------------------
  alias :process_abort_ve_animated_battle :process_abort
  def process_abort
    process_escape_pose if @escaping
    process_abort_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * New method: process_battle_end_pose
  #--------------------------------------------------------------------------
  def process_battle_end_pose(party)
    SceneManager.scene.log_window_clear
    SceneManager.scene.update_basic while party.not_in_position?
    SceneManager.scene.update_basic
    party.movable_members.each do |member| 
      next if $game_system.no_victory || !member.victory_pose?
      member.clear_loop_poses
      member.call_pose(:victory)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: process_escape_pose
  #--------------------------------------------------------------------------
  def process_escape_pose
    $game_party.movable_members.each do |member| 
      member.clear_loop_poses
      member.call_pose(:escape)
    end
    SceneManager.scene.abs_wait(5)
    SceneManager.scene.update_basic while $game_party.moving?    
    SceneManager.scene.close_window
    Graphics.fadeout(30)
  end
  #--------------------------------------------------------------------------
  # * New method: set_active_pose
  #--------------------------------------------------------------------------
  def set_active_pose
    return unless actor
    actor.set_active_pose
    actor.reset_pose
  end
  #--------------------------------------------------------------------------
  # * New method: clear_active_pose
  #--------------------------------------------------------------------------
  def clear_active_pose
    return unless actor
    actor.active_pose = nil
    actor.reset_pose
  end
  #--------------------------------------------------------------------------
  # * New method: active
  #--------------------------------------------------------------------------
  def active
    SceneManager.scene_is?(Scene_Battle) ? SceneManager.scene.active : nil
  end
  #--------------------------------------------------------------------------
  # * New method: targets
  #--------------------------------------------------------------------------
  def targets
    return [] unless active
    active.action_targets
  end
end

#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles system-related data. Also manages vehicles and BGM, etc.
# The instance of this class is referenced by $game_system.
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :no_intro
  attr_accessor :no_victory
  attr_accessor :intro_fade
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_animated_battle :initialize
  def initialize
    initialize_ve_animated_battle
    @intro_fade = VE_BATTLE_INTRO_FADE
  end
end

#==============================================================================
# ** Game_Screen
#------------------------------------------------------------------------------
#  This class handles screen maintenance data, such as change in color tone,
# flashes, etc. It's used within the Game_Map and Game_Troop classes.
#==============================================================================

class Game_Screen
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :low_tone
  attr_reader   :high_tone
  attr_accessor :old_tone
  attr_accessor :old_low_tone
  attr_accessor :old_high_tone
  #--------------------------------------------------------------------------
  # * Alias method: clear_tone
  #--------------------------------------------------------------------------
  alias :clear_tone_ve_animated_battle :clear_tone
  def clear_tone
    clear_tone_ve_animated_battle
    @low_tone  = Tone.new
    @high_tone = Tone.new
    @low_tone_target  = Tone.new
    @high_tone_target = Tone.new
    @low_tone_duration  = 0
    @high_tone_duration = 0
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_animated_battle :update
  def update
    update_ve_animated_battle
    low_update_tone
    high_update_tone
  end
  #--------------------------------------------------------------------------
  # * New method: start_low_tone_change
  #--------------------------------------------------------------------------
  def start_low_tone_change(tone, duration)
    @low_tone_target = tone.clone
    @low_tone_duration = duration
    @low_tone = @low_tone_target.clone if @low_tone_duration == 0
  end
  #--------------------------------------------------------------------------
  # * New method: start_high_tone_change
  #--------------------------------------------------------------------------
  def start_high_tone_change(tone, duration)
    @high_tone_target = tone.clone
    @high_tone_duration = duration
    @high_tone = @high_tone_target.clone if @high_tone_duration == 0
  end
  #--------------------------------------------------------------------------
  # * New method: low_update_tone
  #--------------------------------------------------------------------------
  def low_update_tone
    if @low_tone_duration > 0
      d    = @low_tone_duration
      tone = @low_tone_target
      @low_tone.red   = (@low_tone.red   * (d - 1) + tone.red)   / d
      @low_tone.green = (@low_tone.green * (d - 1) + tone.green) / d
      @low_tone.blue  = (@low_tone.blue  * (d - 1) + tone.blue)  / d
      @low_tone.gray  = (@low_tone.gray  * (d - 1) + tone.gray)  / d
      @low_tone_duration -= 1
    end
  end  
  #--------------------------------------------------------------------------
  # * New method: high_update_tone
  #--------------------------------------------------------------------------
  def high_update_tone
    if @high_tone_duration > 0
      d    = @high_tone_duration
      tone = @high_tone_target
      @high_tone.red   = (@high_tone.red   * (d - 1) + tone.red)   / d
      @high_tone.green = (@high_tone.green * (d - 1) + tone.green) / d
      @high_tone.blue  = (@high_tone.blue  * (d - 1) + tone.blue)  / d
      @high_tone.gray  = (@high_tone.gray  * (d - 1) + tone.gray)  / d
      @high_tone_duration -= 1
    end
  end
  #--------------------------------------------------------------------------
  # * New method: tone_change?
  #--------------------------------------------------------------------------
  def tone_change?
    @tone_duration > 0 || @low_tone_duration > 0 || @high_tone_duration > 0
  end
end

#==============================================================================
# ** Game_ActionResult
#------------------------------------------------------------------------------
#  This class handles the results of actions. This class is used within the
# Game_Battler class.
#==============================================================================

class Game_ActionResult
  #--------------------------------------------------------------------------
  # * New method: damage_value_adjust
  #--------------------------------------------------------------------------
  def damage_value_adjust(value, item)
    @hp_damage *= value
    @mp_damage *= value
    @hp_damage = @hp_damage.to_i
    @mp_damage = [@battler.mp, @mp_damage.to_i].min
    @hp_drain = @hp_damage if item.damage.drain?
    @mp_drain = @mp_damage if item.damage.drain?
    @hp_drain = [@battler.hp, @hp_drain].min
  end
  #--------------------------------------------------------------------------
  # * New method: setup_drain
  #--------------------------------------------------------------------------
  def setup_drain(user)
    user.hp_drain += @hp_drain
    user.mp_drain += @mp_drain
    @hp_drain = 0
    @mp_drain = 0
  end
end

#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  This class handles battlers. It's used as a superclass of the Game_Battler
# classes.
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Overwrite method: refresh
  #--------------------------------------------------------------------------
  def refresh
    state_resist_set.each {|state_id| erase_state(state_id) }
    @hp = [[@hp, mhp].min, 0].max
    @mp = [[@mp, mmp].min, 0].max
    die if @dying && !immortal?
    return if @dying
    valid = @hp == 0 && !immortal?
    valid ? add_state(death_state_id) : remove_state(death_state_id)
    reset_pose
  end
end

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :row
  attr_accessor :frame
  attr_accessor :timing
  attr_accessor :freeze
  attr_accessor :invisible
  attr_accessor :direction
  attr_accessor :move_speed
  attr_accessor :jumping
  attr_accessor :shake
  attr_accessor :pose_list
  attr_accessor :immortals
  attr_accessor :hp_drain
  attr_accessor :mp_drain
  attr_accessor :attack_flag
  attr_accessor :damage_flag
  attr_accessor :result_flag
  attr_accessor :target_list
  attr_accessor :dual_flag
  attr_accessor :spin
  attr_accessor :angle
  attr_accessor :sufix
  attr_accessor :active
  attr_accessor :targets
  attr_accessor :teleport
  attr_accessor :x_adj
  attr_accessor :y_adj
  attr_accessor :call_anim
  attr_accessor :call_effect
  attr_accessor :call_end
  attr_accessor :animation
  attr_accessor :countered
  attr_accessor :substitution
  attr_accessor :action_targets
  attr_accessor :active_pose
  attr_accessor :pose_loop_anim
  attr_accessor :previous_action
  attr_accessor :icon_list
  attr_accessor :throw_list
  attr_accessor :current_item
  attr_accessor :target_position
  attr_accessor :current_position
  attr_accessor :default_position
  #--------------------------------------------------------------------------
  # * Overwrite method: dead?
  #--------------------------------------------------------------------------
  def dead?
    super && !immortal?
  end
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_animated_battle :initialize
  def initialize
    init_anim_battlers_variables
    initialize_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: item_apply
  #--------------------------------------------------------------------------
  alias :item_apply_ve_animated_battle :item_apply
  def item_apply(user, item)
    item_apply_ve_animated_battle(user, item)
    call_damage_pose(item, user) if movable?
    @substitution    = false
    user.result_flag = @result.hit? ? :hit : :miss
  end
  #--------------------------------------------------------------------------
  # * Alias method: make_damage_value
  #--------------------------------------------------------------------------
  alias :make_damage_value_ve_animated_battle :make_damage_value
  def make_damage_value(user, item)
    make_damage_value_ve_animated_battle(user, item)
    @result.damage_value_adjust(user.damage_flag, item) if user.damage_flag
    @result.setup_drain(user)
  end
  #--------------------------------------------------------------------------
  # * Alias method: regenerate_hp
  #--------------------------------------------------------------------------
  alias :regenerate_hp_ve_animated_battle :regenerate_hp
  def regenerate_hp
    regenerate_hp_ve_animated_battle
    call_pose(:hurt, :clear) if @result.hp_damage > 0 && movable?
  end
  #--------------------------------------------------------------------------
  # * Alias method: die
  #--------------------------------------------------------------------------
  alias :die_ve_animated_battle :die
  def die
    return @dying = true if immortal?
    call_pose(:die, :clear)
    @dying = false
    die_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: revive
  #--------------------------------------------------------------------------
  alias :revive_ve_animated_battle :revive
  def revive
    call_pose(:revive, :clear)
    revive_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * New method: init_anim_battlers_variables
  #--------------------------------------------------------------------------
  def init_anim_battlers_variables
    clear_poses
  end
  #--------------------------------------------------------------------------
  # * New method: clear_poses
  #--------------------------------------------------------------------------
  def clear_poses
    @sufix = ""
    @row   = 0
    @frame = 0
    @angle = 0
    @spin  = 0
    @x_adj = 0
    @y_adj = 0
    @hp_drain = 0
    @mp_drain = 0
    @direction  = 2
    @move_speed = 1.0
    @pose_list  = []
    @targets    = []
    @immortals  = []
    @throw_list = []
    @icon_list  = {}
    @timing     = {}
    @action_targets = []
    clear_shake
    clear_position
  end
  #--------------------------------------------------------------------------
  # * New method: immortal?
  #--------------------------------------------------------------------------
  def immortal?
    return false unless $game_party.in_battle
    members = $game_troop.members + $game_party.battle_members
    members.any? {|member| member.immortals.include?(self) }
  end
  #--------------------------------------------------------------------------
  # * New method: clear_shake
  #--------------------------------------------------------------------------
  def clear_shake
    @shake_power = 0
    @shake_speed = 0
    @shake_duration = 0
    @shake_direction = 1
    @shake = 0
  end
  #--------------------------------------------------------------------------
  # * New method: clear_position
  #--------------------------------------------------------------------------
  def clear_position
    @target_position  = {x: 0, y: 0, h: 0, j: 0}
    @current_position = {x: 0, y: 0, h: 0, j: 0}
    @default_position = {x: 0, y: 0, h: 0, j: 0}
  end
  #--------------------------------------------------------------------------
  # * New method: call_pose
  #--------------------------------------------------------------------------
  def call_pose(symbol, insert = nil, item = nil, battler = nil)
    skip_pose if insert == :clear && pose_name_list.first == symbol
    pose  = make_string(symbol)
    note  = item ? item.note : ""
    notes = get_all_poses(note)
    code  = "ACTION: #{pose}((?: *, *[\\w ]+)+)?"
    setup_pose(symbol, notes, code, insert, battler)
  end
  #--------------------------------------------------------------------------
  # * New method: get_all_poses
  #--------------------------------------------------------------------------
  def get_all_poses(note = "")
    note + get_all_notes + battler_settings + default_settings
  end
  #--------------------------------------------------------------------------
  # * New method: default_settings
  #--------------------------------------------------------------------------
  def default_settings
    VE_DEFAULT_ACTION
  end
  #--------------------------------------------------------------------------
  # * New method: battler_settings
  #--------------------------------------------------------------------------
  def battler_settings
    VE_ACTION_SETTINGS[battler_mode] ? VE_ACTION_SETTINGS[battler_mode] : ""
  end
  #--------------------------------------------------------------------------
  # * New method: battler_mode
  #--------------------------------------------------------------------------
  def battler_mode
    sprite_value(:action)
  end
  #--------------------------------------------------------------------------
  # * New method: sprite_value
  #--------------------------------------------------------------------------
  def sprite_value(value)
    sprite_settings[value] ? sprite_settings[value] : VE_DEFAULT_SPRITE[value]
  end
  #--------------------------------------------------------------------------
  # * New method: sprite_settings
  #--------------------------------------------------------------------------
  def sprite_settings
    VE_SPRITE_SETTINGS[@battler_name] ? VE_SPRITE_SETTINGS[@battler_name] :
    VE_DEFAULT_SPRITE
  end
  #--------------------------------------------------------------------------
  # * New method: setup_pose
  #--------------------------------------------------------------------------
  def setup_pose(pose, notes, code, insert, battler)
    regexp = /<#{code}>((?:[^<]|<[^\/])*)<\/ACTION>/im
    if notes.gsub(/\r\n/i, "") =~ regexp
      time, last = get_values($1)
      value = setup_value($2, battler == :skip ? nil : battler)
      return if value.empty?
      time.times do
        list = {pose: pose, next: last, value: value.dup, battler: battler}
        insert ? @pose_list.unshift(list) : @pose_list.push(list)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: pose_name_list
  #--------------------------------------------------------------------------
  def pose_name_list
    @pose_list.collect {|pose| pose[:pose]}
  end
  #--------------------------------------------------------------------------
  # * New method: pose_name
  #--------------------------------------------------------------------------
  def pose_name
    pose_name_list.first
  end
  #--------------------------------------------------------------------------
  # * New method: skip_pose
  #--------------------------------------------------------------------------
  def skip_pose
    @current_pose = pose_name
    @pose_list.shift while @current_pose == pose_name && !@pose_list.empty?
  end
  #--------------------------------------------------------------------------
  # * New method: get_values
  #--------------------------------------------------------------------------
  def get_values(value)
    if value
      time = value =~ /([^,]+) TIMES/i ? [eval($1), 1].max : 1
      last = value =~ /(\w[\w ]+)/i    ? make_symbol($1)   : nil
      [time, last]
    else
      [1]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: clear_loop_poses
  #--------------------------------------------------------------------------
  def clear_loop_poses
    @pose_list.delete_if {|pose| pose[:next] == :loop }
  end
  #--------------------------------------------------------------------------
  # * New method: battler
  #--------------------------------------------------------------------------
  def battler
    @pose[:battler] ? @pose[:battler] : self
  end
  #--------------------------------------------------------------------------
  # * New method: states_pose
  #--------------------------------------------------------------------------
  def states_pose
    $data_states.compact.collect {|state| state.custom_pose("STATE") }.compact
  end
  #--------------------------------------------------------------------------
  # * New method: setup_value
  #--------------------------------------------------------------------------
  def setup_value(settings, battler)
    values = []
    settings.scan(/(\w+)(?:: ([^;]+)[;\n\r])?/i) do |type, value|
      values.push(set_pose_value(type, value ? value : "", battler))
    end
    values
  end
  #--------------------------------------------------------------------------
  # * New method: set_pose_value
  #--------------------------------------------------------------------------
  def set_pose_value(type, value, battler)
    @pose = {}
    @pose[:battler] = battler
    @pose[:type]  = make_symbol(type)
    @pose[:hit]   = value =~ /HIT ONLY/i  ? true : false
    @pose[:miss]  = value =~ /MISS ONLY/i ? true : false
    @pose[:count] = setup_count($1) if value =~ /COUNT (\d+(?: *, *\d+)*)/i
    set_pose_setting("#{type} #{value}")
    @pose
  end
  #--------------------------------------------------------------------------
  # * New method: setup_count
  #--------------------------------------------------------------------------
  def setup_count(value)
    result = []
    value.scan(/(\d+)/i) { result.push($1.to_i) }
    result
  end
  #--------------------------------------------------------------------------
  # * New method: set_pose_setting
  #--------------------------------------------------------------------------
  def set_pose_setting(value)
    case value
    when /^POSE (.*)/i then set_pose($1)
    when /^WAIT (.*)/i then set_wait($1)
    when /^MOVE (.*)/i then set_move($1)
    when /^JUMP (.*)/i then set_jump($1)
    when /^ANIM (.*)/i then set_anim($1)
    when /^ICON (.*)/i then set_icon($1)
    when /^LOOP (.*)/i then set_loop($1)
    when /^TONE (.*)/i then set_tone($1)
    when /^HIDE (.*)/i then set_hide($1)
    when /^THROW (.*)/i then set_throw($1)
    when /^SOUND (.*)/i then set_sound($1)
    when /^PLANE (.*)/i then set_plane($1)
    when /^FLASH (.*)/i then set_flash($1)
    when /^SHAKE (.*)/i then set_shake($1)
    when /^MOVIE (.*)/i then set_movie($1)
    when /^COUNT (.*)/i then set_count($1)
    when /^ACTION (.*)/i then set_action($1)
    when /^FREEZE (.*)/i then set_freeze($1)
    when /^EFFECT (.*)/i then set_effect($1)
    when /^PICTURE (.*)/i then set_picture($1)
    when /^COUNTER (.*)/i then set_counter($1)
    when /^DIRECTION (.*)/i then set_direction($1)
    when /^TRANSITION (.*)/i then set_transition($1)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_pose
  #--------------------------------------------------------------------------
  def set_pose(value)
    @pose[:target] = set_targets(value)
    @pose[:row]    = battler.set_row(value)
    @pose[:sufix]  = battler.set_sufix(value)
    @pose[:angle]  = value =~ /ANGLE ([+-]?\d+)/i  ? $1.to_i : 0
    @pose[:spin]   = value =~ /SPIN ([+-]?\d+)/i   ? $1.to_i : 0
    @pose[:frame]  = value =~ /FRAME (\d+)/i ? $1.to_i : 1
    @pose[:x] = value =~ /X ([+-]?\d+)/i   ? $1.to_i : 0
    @pose[:y] = value =~ /Y ([+-]?\d+)/i   ? $1.to_i : 0
    if value =~ /(\d+|ALL) FRAMES?/i
      w = [value =~ /WAIT (\d+)/i ? $1.to_i : 1, 1].max
      f = /(\d+) FRAMES/i ? $1.to_i : :all
      l = value =~ /LOOP/i   ? true : false
      r = value =~ /RETURN/i ? true : false
      v = value =~ /REVERT/i ? true : false
      i = value =~ /INVERT/i ? true : false
      result = {wait: w, time: w, frame: f, loop: l, return: r, revert: v, 
                invert: i}
    else
      result = {invert: value =~ /INVERT/i ? true : false}
    end
    @pose[:pose] = result
  end
  #--------------------------------------------------------------------------
  # * New method: set_wait(
  #--------------------------------------------------------------------------
  def set_wait(value)
    @pose[:target] = set_targets(value)
    value.scan(/(\w+)/i) do
      value = $1.downcase
      next if ["target","actor","friend","enemy", "user","self"].include?(value)
      case value
      when /(\d+)/i
        @pose[:time] = $1.to_i
        @pose[:wait] = $1.to_i
      when /(\w+)/i
        @pose[:time] = make_symbol($1)
        @pose[:wait] = make_symbol($1)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_move
  #--------------------------------------------------------------------------
  def set_move(value)
    regexp = /(MOVE TO|STEP FOWARD|STEP BACKWARD|RETREAT|ESCAPE|SUBSTITUTION)/i
    @pose[:value]  = make_symbol($1) if value =~ regexp
    @pose[:target] = battler.set_targets(value)
    @pose[:x]      = value =~ /X ([+-]?\d+)/i ? $1.to_i : 0
    @pose[:y]      = value =~ /Y ([+-]?\d+)/i ? $1.to_i : 0
    @pose[:h]      = value =~ /HEIGHT (\d+)/i ? $1.to_i : 0
    @pose[:speed]  = value =~ /SPEED (\d+)/i  ? $1.to_i / 10.0 : 1.0
    @pose[:targets]  = BattleManager.targets if @pose[:value] == :move_to
    @pose[:teleport] = value =~ /TELEPORT/i
  end
  #--------------------------------------------------------------------------
  # * New method: set_jump
  #--------------------------------------------------------------------------
  def set_jump(value)
    @pose[:target] = set_targets(value)
    @pose[:move]   = value =~ /MOVE/i
    @pose[:height] = value =~ /HEIGHT (\d+)/i ? [$1.to_i, 1].max : 5
    @pose[:speed]  = value =~ /SPEED (\d+)/i  ? [$1.to_i, 1].max : 10
  end
  #--------------------------------------------------------------------------
  # * New method: set_count
  #--------------------------------------------------------------------------
  def set_count(value)
    @pose[:add]  = value =~ /ADD (\d+)/i    ? $1.to_i : 0
    @pose[:rand] = value =~ /RANDOM (\d+)/i ? $1.to_i : 1
    @pose[:max]  = value =~ /MAX (\d+)/i    ? $1.to_i : 1
  end
  #--------------------------------------------------------------------------
  # * New method: set_action
  #--------------------------------------------------------------------------
  def set_action(value)
    @pose[:target] = set_targets(value)
    value.scan(/(\w[\w ]+)/) do
      not_action = ["target","actor","friend","enemy", "user","self"]
      next if not_action.include?($1.downcase)
      @pose[:action] = make_symbol($1)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_freeze
  #--------------------------------------------------------------------------
  def set_freeze(value)
    @pose[:target]   = set_targets(value)
    @pose[:duration] = value =~ /DURATION (\d+)/i ? [$1.to_i, 1].max : 1
  end
  #--------------------------------------------------------------------------
  # * New method: set_sound
  #--------------------------------------------------------------------------
  def set_sound(value)
    @pose[:name]   = value =~ /NAME #{get_filename}/i ? $1 : ""
    @pose[:volume] = value =~ /VOLUME (\d+)/i ? $1.to_i : 100
    @pose[:pitch]  = value =~ /PITCH (\d+)/i  ? $1.to_i : 100
  end
  #--------------------------------------------------------------------------
  # * New method: set_hide
  #--------------------------------------------------------------------------
  def set_hide(value)
    @pose[:all_battler] = true if value =~ /ALL BATTLERS/i
    @pose[:all_enemies] = true if value =~ /ALL ENEMIES/i
    @pose[:all_friends] = true if value =~ /ALL FRIENDS/i
    @pose[:all_targets] = true if value =~ /ALL TARGETS/i
    @pose[:not_targets] = true if value =~ /NOT TARGETS/i
    @pose[:exc_user] = true if value =~ /EXCLUDE USER/i
    @pose[:inc_user] = true if value =~ /INCLUDE USER/i
    @pose[:unhide]   = true if value =~ /UNHIDE/i
  end
  #--------------------------------------------------------------------------
  # * New method: set_anim
  #--------------------------------------------------------------------------
  def set_anim(value)
    @pose[:target] = set_targets(value)
    item = battler.current_item ? battler.current_item : nil
    case value
    when /CAST/i
      cast = item && $imported[:ve_cast_animation]
      anim = cast ? battler.cast_animation_id(item) : 0
      @pose[:anim] = anim
    when /EFFECT/i
      @pose[:anim] = item ? item.animation_id : 0
    when /ID (\d+)/i
      @pose[:anim] = $1.to_i
    when /WEAPON(?: *(\d+)?)?/i
      dual = @dual_flag || ($1 && $1.to_i == 2)
      @pose[:anim] = battler.atk_animation_id1
      @pose[:anim] = battler.atk_animation_id2 if dual
    else
      @pose[:anim] = 0
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_icon
  #--------------------------------------------------------------------------
  def set_icon(value)
    @pose[:target] = set_targets(value)
    @pose[:index]  = value =~ /INDEX ([+-]?\d+)/i      ? $1.to_i : 0
    @pose[:image]  = value =~ /IMAGE #{get_filename}/i ? $1.to_s : nil
    @pose[:delete] = value =~ /DELETE/i ? true : false
    @pose[:above]  = value =~ /ABOVE/i  ? true : false
    return if @pose[:delete]
    set_action_icon(value)
    @pose[:x] = value =~ /X ([+-]?\d+)/i  ? $1.to_i : 0
    @pose[:y] = value =~ /Y ([+-]?\d+)/i  ? $1.to_i : 0
    @pose[:a] = value =~ /ANGLE ([+-]?\d+)/i   ? $1.to_i : 0
    @pose[:o] = value =~ /OPACITY (\d+)/i      ? $1.to_i : 255
    @pose[:spin] = value =~ /SPIN ([+-]\d+)/i  ? $1.to_i : 0
    @pose[:fin]  = value =~ /FADE IN (\d+)/i   ? $1.to_i : 0
    @pose[:fout] = value =~ /FADE OUT (\d+)/i  ? $1.to_i : 0
    @pose[:izm]  = value =~ /INIT ZOOM (\d+)/i ? $1.to_i / 100.0 : 1.0
    @pose[:ezm]  = value =~ /END ZOOM (\d+)/i  ? $1.to_i / 100.0 : 1.0
    @pose[:szm]  = value =~ /ZOOM SPD (\d+)/i  ? $1.to_i / 100.0 : 0.1
  end
  #--------------------------------------------------------------------------
  # * New method: set_picture
  #--------------------------------------------------------------------------
  def set_picture(value)
    @pose[:id] = value =~ /ID (\d+)/i ? [$1.to_i, 1].max : 1
    @pose[:delete] = value =~ /DELETE/i ? true : false
    return if @pose[:delete]
    name = value =~ /NAME #{get_filename}/i ? $1.to_s : ""
    orig = value =~ /CENTER/i ? 1 : 0
    x    = value =~ /POS X ([+-]?\d+)/i ? $1.to_i : 0
    y    = value =~ /POS Y ([+-]?\d+)/i ? $1.to_i : 0
    zoom_x  = value =~ /ZOOM X ([+-]?\d+)/i ? $1.to_i : 100.0
    zoom_y  = value =~ /ZOOM X ([+-]?\d+)/i ? $1.to_i : 100.0
    opacity = value =~ /OPACITY (\d+)/i     ? $1.to_i : 255
    blend   = value =~ /BLEND ([+-]\d+)/i   ? $1.to_i : 0
    duration = value =~ /DURATION (\d+)/i    ? $1.to_i : 0
    if value =~ /SHOW/i
      @pose[:show] = [name, orig, x, y, zoom_x, zoom_y, opacity, blend]
    elsif value =~ /MOVE/i
      @pose[:move] = [orig, x, y, zoom_x, zoom_y, opacity, blend, duration]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_plane
  #--------------------------------------------------------------------------
  def set_plane(value)
    @pose[:delete]   = value =~ /DELETE/i ? true : false
    @pose[:duration] = value =~ /DURATION (\d+)/i ? $1.to_i : 0
    return if @pose[:delete]
    name = value =~ /NAME #{get_filename}/i ? $1.to_s : ""
    x    = value =~ /MOVE X ([+-]?\d+)/i ? $1.to_i : 0
    y    = value =~ /MOVE Y ([+-]?\d+)/i ? $1.to_i : 0
    z    = value =~ /Z ([+-]?\d+)/i      ? $1.to_i : 100
    zoom_x  = value =~ /ZOOM X (\d+)/i   ? $1.to_i : 100.0
    zoom_y  = value =~ /ZOOM Y (\d+)/i   ? $1.to_i : 100.0
    opacity = value =~ /OPACITY (\d+)/i  ? $1.to_i : 160
    blend   = value =~ /BLEND (\d+)/i    ? $1.to_i : 0
    duration = @pose[:duration]
    @pose[:list] = [name, x, y, z, zoom_x, zoom_y, opacity, blend, duration]
  end
  #--------------------------------------------------------------------------
  # * New method: set_throw
  #--------------------------------------------------------------------------
  def set_throw(value)
    @pose[:target] = set_targets(value)
    @pose[:image]  = value =~ /IMAGE #{get_filename}/i ? $1.to_s : nil
    set_action_icon(value)
    @pose[:revert] = value =~ /REVERT/i
    @pose[:return] = value =~ /RETURN/i
    @pose[:init_x] = value =~ /INIT X ([+-]?\d+)/i ? $1.to_i : 0
    @pose[:init_y] = value =~ /INIT Y ([+-]?\d+)/i ? $1.to_i : 0
    @pose[:end_x]  = value =~ /END X ([+-]?\d+)/i  ? $1.to_i : 0
    @pose[:end_y]  = value =~ /END Y ([+-]?\d+)/i  ? $1.to_i : 0
    @pose[:anim]   = value =~ /ANIM (\d+)/i    ? $1.to_i : nil
    @pose[:arc]    = value =~ /ARC (\d+)/i     ? $1.to_i : 0
    @pose[:speed]  = value =~ /SPEED (\d+)/i   ? $1.to_i / 10.0 : 1.0
    @pose[:spin] = value =~ /SPIN ([+-]\d+)/i  ? $1.to_i : 0
    @pose[:fin]  = value =~ /FADE IN (\d+)/i   ? $1.to_i : 0
    @pose[:fout] = value =~ /FADE OUT (\d+)/i  ? $1.to_i : 0
    @pose[:izm]  = value =~ /INIT ZOOM (\d+)/i ? $1.to_i / 100.0 : 1.0
    @pose[:ezm]  = value =~ /END ZOOM (\d+)/i  ? $1.to_i / 100.0 : 1.0
    @pose[:szm]  = value =~ /ZOOM SPD (\d+)/i  ? $1.to_i / 100.0 : 0.1
    @pose[:z] = value =~ /Z ([+-]?\d+)/i  ? $1.to_i : 0
    @pose[:o] = value =~ /OPACITY (\d+)/i ? $1.to_i : 255
    @pose[:a] = value =~ /ANGLE (\d+)/i   ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # * New method: set_action_icon
  #--------------------------------------------------------------------------
  def set_action_icon(value)
    id = @dual_flag ? 2 : 1 
    icon = weapon_icon(id)      if value =~ /WEAPON/i 
    icon = weapon_icon($1.to_i) if value =~ /WEAPON (\d+)/i
    icon = armor_icon($1.to_i)  if value =~ /ARMOR (\d+)/i
    icon = armor_icon(1)        if value =~ /SHIELD/i
    icon = action_icon if value =~ /ACTION/i
    icon = $1.to_i     if value =~ /ICON (\d+)/i
    @pose[:icon] = icon ? icon : 0
  end
  #--------------------------------------------------------------------------
  # * New method: set_shake
  #--------------------------------------------------------------------------
  def set_shake(value)
    @pose[:target] = set_targets(value)
    @pose[:screen] = value =~ /SCREEN/i ? true : false
    power = value =~ /POWER (\d+)/i ? [$1.to_i, 2].max : 5
    speed = value =~ /SPEED (\d+)/i ? [$1.to_i, 2].max : 5
    duration = value =~ /DURATION (\d+)/i ? [$1.to_i, 1].max : 10
    @pose[:shake] = [power / 2.0, speed / 2.0, duration]
  end
  #--------------------------------------------------------------------------
  # * New method: set_movie
  #--------------------------------------------------------------------------
  def set_movie(value)
    @pose[:name] = value =~ /NAME #{get_filename}/i ? $1.to_s : ""
    set_tone(value)
  end
  #--------------------------------------------------------------------------
  # * New method: set_tone
  #--------------------------------------------------------------------------
  def set_tone(value)
    r = value =~ /RED ([+-]?\d+)/i   ? $1.to_i : 0
    g = value =~ /GREEN ([+-]?\d+)/i ? $1.to_i : 0
    b = value =~ /BLUE ([+-]?\d+)/i  ? $1.to_i : 0
    a = value =~ /GRAY ([+-]?\d+)/i  ? $1.to_i : 0
    tone  = [r, g, b, a]
    tone  = [ 255,  255,  255, 0] if value =~ /WHITE/i
    tone  = [-255, -255, -255, 0] if value =~ /BLACK/i
    @pose[:tone]  = Tone.new(*tone)
    @pose[:clear] = true if value =~ /CLEAR/i
    @pose[:duration] = value =~ /DURATION (\d+)/i ? $1.to_i : 0
    @pose[:priority] = :normal
    @pose[:priority] = :high if value =~ /HIGH PRIORITY/i
    @pose[:priority] = :low  if value =~ /LOW PRIORITY/i
  end
  #--------------------------------------------------------------------------
  # * New method: set_flash
  #--------------------------------------------------------------------------
  def set_flash(value)
    @pose[:target] = set_targets(value)
    @pose[:screen] = value =~ /SCREEN/i ? true : false
    r = value =~ /RED (\d+)/i   ? $1.to_i : 255
    g = value =~ /GREEN (\d+)/i ? $1.to_i : 255
    b = value =~ /BLUE (\d+)/i  ? $1.to_i : 255
    a = value =~ /ALPHA (\d+)/i ? $1.to_i : 160
    duration = value =~ /DURATION (\d+)/i ? [$1.to_i, 1].max : 10
    @pose[:flash] = [Color.new(r, g, b, a), duration]
  end
  #--------------------------------------------------------------------------
  # * New method: set_loop
  #--------------------------------------------------------------------------
  def set_loop(value)
    @pose[:target]    = set_targets(value)
    @pose[:loop_anim] = value =~ /ANIM (\d+)/i ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # * New method: set_effect
  #--------------------------------------------------------------------------
  def set_effect(value)
    @pose[:target] = set_targets(value)
    @pose[:damage] = $1.to_i / 100.0  if value =~ /(\d+)%/i
    @pose[:weapon] = [$1.to_i, 1].max if value =~ /WEAPON (\d+)/i
  end
  #--------------------------------------------------------------------------
  # * New method: set_counter
  #--------------------------------------------------------------------------
  def set_counter(value)
    @pose[:target]  = set_targets(value)
    @pose[:counter] = true  if value =~ /ON/i 
    @pose[:counter] = false if value =~ /OFF/i 
  end
  #--------------------------------------------------------------------------
  # * New method: set_direction
  #--------------------------------------------------------------------------
  def set_direction(value)
    @pose[:active]    = true if value =~ /ACTIVE/i
    @pose[:targets]   = true if value =~ /TARGETS/i
    @pose[:return]    = true if value =~ /RETURN/i
    @pose[:default]   = true if value =~ /DEFAULT/i
    @pose[:direction] = 2 if value =~ /DOWN/i
    @pose[:direction] = 4 if value =~ /LEFT/i
    @pose[:direction] = 6 if value =~ /RIGHT/i
    @pose[:direction] = 8 if value =~ /UP/i
  end
  #--------------------------------------------------------------------------
  # * New method: set_direction
  #--------------------------------------------------------------------------
  def set_transition(value)
    @pose[:prepare]  = true if value =~ /PREPARE/i
    @pose[:execute]  = true if value =~ /EXECUTE/i
    @pose[:duration] = value =~ /DURATION (\d+)/i ? $1.to_i : 40
    @pose[:name]     = value =~ /NAME #{get_filename}/i ? $1.to_s : ""
  end
  #--------------------------------------------------------------------------
  # * New method: set_targets
  #--------------------------------------------------------------------------
  def set_targets(value)
    case value
    when /SELF/i
      [self]
    when /ACTOR ([^>,;]+)/i
      actor = $game_actors[eval($1)]
      $game_party.battle_members.include?(actor) ? [actor] : []
    when /FRIEND ([^>,;]+)/i
      [$game_party.battle_members[eval($1)]].compact
    when /ENEMY ([^>,;]+)/i
      [$game_troop.members[eval($1)]].compact
    when /RANDOM ENEMY/i
      battler.opponents_unit.members.random
    when /RANDOM FRIEND/i
      battler.friends_unit.members.random
    when /ALL ENEMIES/i
      battler.opponents_unit.members
    when /ALL FRIENDS/i
      battler.friends_unit.members
    when /TARGETS/i
      battler.action_targets.dup
    when /USER/i
      [battler]
    else
      nil
    end
  end
  #--------------------------------------------------------------------------
  # * New method: set_row
  #--------------------------------------------------------------------------
  def set_row(value)
    pose = battler.sprite_value(make_symbol($1)) if value =~ /ROW (\w+)/i
    pose = :direction if value =~ /ROW DIRECTION/i
    pose = $1.to_i    if value =~ /ROW (\d+)/i
    pose ? pose : 0
  end
  #--------------------------------------------------------------------------
  # * New method: set_sufix
  #--------------------------------------------------------------------------
  def set_sufix(value)
    pose = value =~ /SUFIX ([\[\]\w]+)/i ? $1.to_s : ""
    if pose.downcase == "[direction]"
      pose = case direction
      when 2 then "[down]"
      when 4 then "[left]"
      when 6 then "[right]"
      when 8 then "[up]"
      end
    end
    pose
  end
  #--------------------------------------------------------------------------
  # * New method: weapon_icon
  #--------------------------------------------------------------------------
  def weapon_icon(index)
    battler.actor? ? actor_weapon_icon(index) : enemy_weapon_icon(index)
  end
  #--------------------------------------------------------------------------
  # * New method: actor_weapon_icon
  #--------------------------------------------------------------------------
  def actor_weapon_icon(index)
    battler.weapons[index - 1] ? battler.weapons[index - 1].icon_index : nil
  end
  #--------------------------------------------------------------------------
  # * New method: enemy_weapon_icon
  #--------------------------------------------------------------------------
  def enemy_weapon_icon(index)
    note =~ /<WEAPON #{index}: (\d+)>/i ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # * New method: armor_icon
  #--------------------------------------------------------------------------
  def armor_icon(index)
    battler.actor? ? actor_armor_icon(index) : enemy_armor_icon(index)
  end
  #--------------------------------------------------------------------------
  # * New method: equip_list
  #--------------------------------------------------------------------------
  def actor_armor_icon(index)
    slot = battler.equip_slots[index]
    return nil unless slot && slot != 0 && battler.equip_list[slot]
    equip = battler.equip_list[slot]
    equip.object ? equip.object.icon_index : nil
  end
  #--------------------------------------------------------------------------
  # * New method: equip_list
  #--------------------------------------------------------------------------
  def enemy_armor_icon(index)
    note =~ /<ARMOR #{index}: (\d+)>/i ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # * New method: equip_list
  #--------------------------------------------------------------------------
  def equip_list
    @equips
  end
  #--------------------------------------------------------------------------
  # * New method: action_icon
  #--------------------------------------------------------------------------
  def action_icon
    current_item ? current_item.icon_index : 0
  end
  #--------------------------------------------------------------------------
  # * New method: active?
  #--------------------------------------------------------------------------
  def active?
    @active
  end
  #--------------------------------------------------------------------------
  # * New method: down?
  #--------------------------------------------------------------------------
  def down?
    @direction == 2
  end
  #--------------------------------------------------------------------------
  # * New method: left?
  #--------------------------------------------------------------------------
  def left?
    @direction == 4
  end
  #--------------------------------------------------------------------------
  # * New method: right?
  #--------------------------------------------------------------------------
  def right?
    @direction == 6
  end
  #--------------------------------------------------------------------------
  # * New method: up?
  #--------------------------------------------------------------------------
  def up?
    @direction == 8
  end
  #--------------------------------------------------------------------------
  # * New method: target_direction
  #--------------------------------------------------------------------------
  def target_direction(x, y, current = nil)
    position = current ? current : current_position
    relative_x = position[:x] - x
    relative_y = position[:y] - y
    if isometric?
      @direction = 2 if relative_x > 0 && relative_y < 0
      @direction = 4 if relative_x > 0 && relative_y > 0
      @direction = 6 if relative_x < 0 && relative_y < 0
      @direction = 8 if relative_x < 0 && relative_y > 0
    elsif relative_y.abs > relative_x.abs || frontview?
      @direction = relative_y < 0 ? 2 : 8
    elsif relative_x.abs >= relative_y.abs || sideview?
      @direction = relative_x < 0 ? 6 : 4
    end
  end
  #--------------------------------------------------------------------------
  # * New method: adjust_position
  #--------------------------------------------------------------------------
  def adjust_position(value)
    if isometric?
      x, y =  value, -value * 0.75 if down?
      x, y =  value,  value * 0.75 if left?
      x, y = -value, -value * 0.75 if right?
      x, y = -value,  value * 0.75 if up?
    else
      x, y = 0, -value if down?
      x, y =  value, 0 if left?
      x, y = -value, 0 if right?
      x, y = 0,  value if up?
    end
    @target_position[:x] += x.to_i
    @target_position[:y] += y.to_i
  end
  #--------------------------------------------------------------------------
  # * New method: position_fix
  #--------------------------------------------------------------------------
  def position_fix
    value =  16 if left?  || up?
    value = -16 if right? || down?
    target_position[rand(2) == 0 ? :x : :y] += value
  end
  #--------------------------------------------------------------------------
  # * New method: sharing_position?
  #--------------------------------------------------------------------------
  def sharing_position?
    units = $game_troop.members + $game_party.battle_members
    list  = units.select do |target|
      target != self && target.target_position == target_position
    end
    !list.empty?
  end
  #--------------------------------------------------------------------------
  # * New method: sideview?
  #--------------------------------------------------------------------------
  def sideview?
    $imported[:ve_actor_battlers] && VE_BATTLE_FORMATION == :side
  end
  #--------------------------------------------------------------------------
  # * New method: frontview?
  #--------------------------------------------------------------------------
  def frontview?
    $imported[:ve_actor_battlers] && VE_BATTLE_FORMATION == :front
  end
  #--------------------------------------------------------------------------
  # * New method: isometric
  #--------------------------------------------------------------------------
  def isometric?
    $imported[:ve_actor_battlers] && VE_BATTLE_FORMATION == :iso
  end
  #--------------------------------------------------------------------------
  # * New method: action_direction
  #--------------------------------------------------------------------------
  def action_direction
    units = BattleManager.targets
    target_x = units.collect {|member| member.current_position[:x] }.average
    target_y = units.collect {|member| member.current_position[:y] }.average
    target_direction(target_x, target_y)
  end
  #--------------------------------------------------------------------------
  # * New method: target_distance
  #--------------------------------------------------------------------------
  def target_distance(symbol)
    @target_position[symbol] - @current_position[symbol]
  end
  #--------------------------------------------------------------------------
  # * New method: moving?
  #--------------------------------------------------------------------------
  def moving?
    @current_position != @target_position
  end
  #--------------------------------------------------------------------------
  # * New method: damage_pose?
  #--------------------------------------------------------------------------
  def damage_pose?
    pose_name == :hurt || pose_name == :miss || pose_name == :evade ||
    pose_name == :critical
  end
  #--------------------------------------------------------------------------
  # * New method: origin?
  #--------------------------------------------------------------------------
  def origin?
    @current_position[:x] != screen_x || @current_position[:y] != screen_y
  end
  #--------------------------------------------------------------------------
  # * New method: activate
  #--------------------------------------------------------------------------
  def activate
    return unless current_action && current_action.item
    @active = true
    @active_pose = nil
    @action_targets = current_action.make_targets.compact.dup
    setup_immortals
  end
  #--------------------------------------------------------------------------
  # * New method: setup_immortals
  #--------------------------------------------------------------------------
  def setup_immortals
    @action_targets.each {|target| immortals.push(target) unless target.dead? }
    immortals.uniq!
  end
  #--------------------------------------------------------------------------
  # * New method: deactivate
  #--------------------------------------------------------------------------
  def deactivate
    @active = false
    @attack_flag = nil
    @result_flag = nil
    @call_end = true
    immortals = @immortals.dup
    @immortals.clear
    immortals.each {|member| member.refresh }
    @action_targets.clear
  end
  #--------------------------------------------------------------------------
  # * New method: action_pose
  #--------------------------------------------------------------------------
  def action_pose(item)
    activate
    @current_item = item
    call_action_poses
  end
  #--------------------------------------------------------------------------
  # * New method: call_action_poses
  #--------------------------------------------------------------------------
  def call_action_poses
    item = @current_item
    clear_loop_poses
    set_action_pose
    call_pose(:inactive)
    call_custom_pose("RETREAT", :retreat, item) if need_move?(item)
  end
  #--------------------------------------------------------------------------
  # * New method: set_action_pose
  #--------------------------------------------------------------------------
  def set_action_pose
    set_attack_pose(false)
    set_attack_pose(true) if double_attack? && !use_dual_attack?
    @attack_flag = (double_attack? && !use_dual_attack?) ? 1 : nil
  end
  #--------------------------------------------------------------------------
  # * New method: call_attack_pose
  #--------------------------------------------------------------------------
  def set_attack_pose(dual)
    item = @current_item
    @dual_flag = dual
    call_move_pose("ADVANCE", :advance, dual) if need_move?(item)
    call_pose(setup_pose_type(dual), false, item)
    call_pose(:finish, false)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_pose_type
  #--------------------------------------------------------------------------
  def setup_pose_type(dual = false)
    item = @current_item
    pose = weapons_pose("USE"  , :use, dual)
    pose = weapons_pose("ITEM" , :item, dual)    if item.item?
    pose = weapons_pose("MAGIC", :magic, dual)   if item.magical?
    pose = weapons_pose("SKILL", :skill, dual)   if item.physical?
    pose = weapons_pose("ATTACK", :attack, dual) if item_attack?(item)
    pose = weapons_pose("DUAL"  , :dual_attack)  if use_dual_attack?
    pose = :defend if item_defend?(item)
    pose = custom_pose("ACTION", pose, item)
    pose = custom_pose("ITEM"  , pose, item) if item.item?
    pose = custom_pose("MAGIC" , pose, item) if item.magical?
    pose = custom_pose("SKILL" , pose, item) if item.physical?
    pose
  end
  #--------------------------------------------------------------------------
  # * New method: item_attack?
  #--------------------------------------------------------------------------
  def item_attack?(item)
    item.skill? && item.id == attack_skill_id
  end
  #--------------------------------------------------------------------------
  # * New method: item_defend?
  #--------------------------------------------------------------------------
  def item_defend?(item)
    item.skill? && item.id == guard_skill_id
  end
  #--------------------------------------------------------------------------
  # * New method: use_dual_attack?
  #--------------------------------------------------------------------------
  def use_dual_attack?
    get_all_notes =~ /<USE DUAL ATTACK>/i && double_attack?
  end
  #--------------------------------------------------------------------------
  # * New method: double_attack?
  #--------------------------------------------------------------------------
  def double_attack?
    item = @current_item
    actor? && dual_wield? && weapons.size > 1 && (item_attack?(item) ||
    (item && item.note =~ /<ALLOW DUAL ATTACK>/i))
  end
  #--------------------------------------------------------------------------
  # * New method: weapons_pose
  #--------------------------------------------------------------------------
  def weapons_pose(type, pose, dual = false)
    valid = actor? ? weapons : []
    list  = valid.collect { |item| item.custom_pose(type) }
    list.shift if dual
    list.empty? || !pose_exist?(list.first) ? pose : list.first
  end
  #--------------------------------------------------------------------------
  # * New method: custom_pose
  #--------------------------------------------------------------------------
  def custom_pose(type, pose, item)
    note   = item ? item.note : ""
    custom = item.custom_pose(type)
    custom && pose_exist?(custom, note) ? custom : pose
  end
  #--------------------------------------------------------------------------
  # * New method: pose_exist?
  #--------------------------------------------------------------------------
  def pose_exist?(pose, note = "")
    value  = "ACTION: #{make_string(pose)}"
    regexp = /<#{value}(?:(?: *, *[\w ]+)+)?>(?:[^<]|<[^\/])*<\/ACTION>/im
    get_all_poses(note) =~ regexp
  end
  #--------------------------------------------------------------------------
  # * New method: call_move_pose
  #--------------------------------------------------------------------------
  def call_move_pose(type, pose, dual)
    pose = weapons_pose(type, pose, dual) 
    pose = custom_pose(type, pose, @current_item)
    call_pose(pose, false, @current_item)
  end
  #--------------------------------------------------------------------------
  # * New method: call_custom_pose
  #--------------------------------------------------------------------------
  def call_custom_pose(type, pose, item)
    pose = custom_pose(type, pose, item)
    call_pose(pose, false, item)
  end
  #--------------------------------------------------------------------------
  # * New method: need_move?
  #--------------------------------------------------------------------------
  def need_move?(item)
    return false if unmovable?
    return true  if item.note =~ /<ACTION MOVEMENT>/i
    return true  if item.skill? && item.physical?
    return true  if item.skill? && item.id == attack_skill_id
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: call_damage_pose
  #--------------------------------------------------------------------------
  def call_damage_pose(item, user)
    call_pose(:hurt,     :clear, item, :skip) if hurt_pose?
    call_pose(:miss,     :clear, item, :skip) if @result.missed
    call_pose(:evade,    :clear, item, :skip) if @result.evaded
    call_pose(:critical, :clear, item, :skip) if @result.critical
    call_subsititution if @substitution
  end
  #--------------------------------------------------------------------------
  # * New method: hurt_pose?
  #--------------------------------------------------------------------------
  def hurt_pose?
    @result.hit? && @result.hp_damage > 0
  end
  #--------------------------------------------------------------------------
  # * New method: call_subsititution
  #--------------------------------------------------------------------------
  def call_subsititution
    call_pose(:substitution_on, true)
    2.times {sprite.update}
  end
  #--------------------------------------------------------------------------
  # * New method: set_active_pose
  #--------------------------------------------------------------------------
  def set_active_pose
    return if (!current_action || !current_action.item) && !current_item
    item = current_action.item ? current_action.item : current_item
    pose = :ready      if sprite_value(:ready)
    pose = :item_cast  if item.item?     && sprite_value(:itemcast)
    pose = :magic_cast if item.magical?  && sprite_value(:magiccast)
    pose = :skill_cast if item.physical? && sprite_value(:skillcast)
    pose = custom_pose("ITEM CAST", pose, item)  if pose && item.item?
    pose = custom_pose("MAGIC CAST", pose, item) if pose && item.magical?
    pose = custom_pose("SKILL CAST", pose, item) if pose && item.physical?
    @active_pose = pose
  end
  #--------------------------------------------------------------------------
  # * New method: command_pose
  #--------------------------------------------------------------------------
  def command_pose
    call_pose(:command, :clear) if sprite_value(:command)
  end
  #--------------------------------------------------------------------------
  # * New method: input_pose
  #--------------------------------------------------------------------------
  def input_pose
    call_pose(:input, :clear) if sprite_value(:input)
  end
  #--------------------------------------------------------------------------
  # * New method: cancel_pose
  #--------------------------------------------------------------------------
  def cancel_pose
    call_pose(:cancel, :clear) if sprite_value(:cancel)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_counter
  #--------------------------------------------------------------------------
  def setup_counter(target)
    target.skip_pose unless [:inactive, :retreat].include?(target.pose_name)
    target.call_pose(:counter_on, :clear)
    @action_targets = [target]
    setup_immortals
    @current_item = $data_skills[attack_skill_id]
    call_action_poses
    call_pose(:counter_off)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_reflect
  #--------------------------------------------------------------------------
  def setup_reflect(item)
    skip_pose unless [:reflection, :inactive, :retreat].include?(pose_name)
    @action_targets = [self]
    setup_immortals
    @current_item = item
    call_pose(:reflection, true, item)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_substitute
  #--------------------------------------------------------------------------
  def setup_substitute(target)
    skip_pose unless [:substitution_on, :inactive, :retreat].include?(pose_name)
    @action_targets = [target]
    @substitution   = true
    call_pose(:substitution_off, true)
  end
  #--------------------------------------------------------------------------
  # * New method: not_in_position?
  #--------------------------------------------------------------------------
  def not_in_position?
    pose_name == :retreat
  end
  #--------------------------------------------------------------------------
  # * New method: state_pose?
  #--------------------------------------------------------------------------
  def state_pose?
    state_pose
  end
  #--------------------------------------------------------------------------
  # * New method: state_pose
  #--------------------------------------------------------------------------
  def state_pose
    states.collect {|state| state.custom_pose("STATE") }.first
  end
  #--------------------------------------------------------------------------
  # * New method: reset_pose
  #--------------------------------------------------------------------------
  def reset_pose
    return unless $game_party.in_battle
    sprite.reset_pose if sprite
  end
  #--------------------------------------------------------------------------
  # * New method: frames
  #--------------------------------------------------------------------------
  def frames
    character_name[/\[F(\d+)\]/i] ? $1.to_i : 3
  end
  #--------------------------------------------------------------------------
  # * New method: drain_setup
  #--------------------------------------------------------------------------
  def drain_setup
    self.hp += @hp_drain
    self.mp += @mp_drain
    @result.hp_damage = -@hp_drain
    @result.mp_damage = -@mp_drain
    @hp_drain = 0
    @mp_drain = 0
    @damaged  = true if $imported[:ve_damage_pop]
  end
  #--------------------------------------------------------------------------
  # * New method: start_shake
  #--------------------------------------------------------------------------
  def start_shake(power, speed, duration)
    @shake_power = power
    @shake_speed = speed
    @shake_duration = duration
  end
  #--------------------------------------------------------------------------
  # * New method: update_shake
  #--------------------------------------------------------------------------
  def update_shake
    return unless shaking?
    delta  = (@shake_power * @shake_speed * @shake_direction) / 10.0
    clear  = @shake_duration <= 1 && @shake * (@shake + delta) < 0
    @shake = clear ? 0 : @shake + delta
    @shake_direction = -1 if @shake > @shake_power * 2
    @shake_direction = 1  if @shake < - @shake_power * 2
    @shake_duration -= 1
  end
  #--------------------------------------------------------------------------
  # * New method: update_freeze
  #--------------------------------------------------------------------------
  def update_freeze
    return if @freeze == 0 || !@freeze.numeric?
    @freeze -= 1
  end
  #--------------------------------------------------------------------------
  # * New method: shaking?
  #--------------------------------------------------------------------------
  def shaking?
    @shake_duration > 0 || @shake != 0
  end
  #--------------------------------------------------------------------------
  # * New method: frozen?
  #--------------------------------------------------------------------------
  def frozen?
    (@freeze.numeric? && @freeze > 0) || @freeze == :lock || unmovable?
  end
  #--------------------------------------------------------------------------
  # * New method: unmovable?
  #--------------------------------------------------------------------------
  def unmovable?
    get_all_notes =~ /<UNMOVABLE>/i
  end
  #--------------------------------------------------------------------------
  # * New method: active_direction
  #--------------------------------------------------------------------------
  def active_direction
    members = $game_troop.members + $game_party.battle_members
    units = members.select {|member| member.active? }
    x = units.collect {|member| member.screen_x }.average
    y = units.collect {|member| member.screen_y }.average
    target_direction(x, y, {x: screen_x, y: screen_y})
  end  
end

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Overwrite method: perform_collapse_effect
  #--------------------------------------------------------------------------
  def perform_collapse_effect
    if $game_party.in_battle
      reset_pose
      case collapse_type
      when 0
        @sprite_effect_type = :collapse
        Sound.play_enemy_collapse
      when 1
        @sprite_effect_type = :boss_collapse
        Sound.play_boss_collapse1
      when 2
        @sprite_effect_type = :instant_collapse
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: perform_damage_effect
  #--------------------------------------------------------------------------
  def perform_damage_effect
    $game_troop.screen.start_shake(5, 5, 10) unless use_sprite?
    Sound.play_actor_damage
  end
  #--------------------------------------------------------------------------
  # * Alias method: param_plus
  #--------------------------------------------------------------------------
  alias :param_plus_ve_animated_battle :param_plus
  def param_plus(param_id)
    if param_id > 1 && @attack_flag
      atk_equips.compact.inject(super) {|r, item| r += item.params[param_id] }
    else
      param_plus_ve_animated_battle(param_id)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: atk_feature_objects
  #--------------------------------------------------------------------------
  def atk_feature_objects
    list = @attack_flag ? atk_equips : equips.compact
    states + [actor] + [self.class] + list
  end
  #--------------------------------------------------------------------------
  # * New method: atk_all_features
  #--------------------------------------------------------------------------
  def atk_all_features
    atk_feature_objects.inject([]) {|r, obj| r + obj.features }
  end
  #--------------------------------------------------------------------------
  # * New method: atk_features
  #--------------------------------------------------------------------------
  def atk_features(code)
    atk_all_features.select {|ft| ft.code == code }
  end
  #--------------------------------------------------------------------------
  # * New method: atk_features_set
  #--------------------------------------------------------------------------
  def atk_features_set(code)
    atk_features(code).inject([]) {|r, ft| r |= [ft.data_id] }
  end
  #--------------------------------------------------------------------------
  # * New method: atk_elements
  #--------------------------------------------------------------------------
  def atk_elements
    set = atk_features_set(FEATURE_ATK_ELEMENT)
    set |= [1] if weapons.compact.empty?
    return set
  end
  #--------------------------------------------------------------------------
  # * New method: atk_states
  #--------------------------------------------------------------------------
  def atk_states
    atk_features_set(FEATURE_ATK_STATE)
  end
  #--------------------------------------------------------------------------
  # * New method: atk_equips
  #--------------------------------------------------------------------------
  def atk_equips
    ([weapons[@attack_flag - 1]] + armors).collect {|item| item }.compact
  end
  #--------------------------------------------------------------------------
  # * New method: default_direction
  #--------------------------------------------------------------------------
  def default_direction
    units = opponents_unit.members
    x = units.collect {|member| member.screen_x }.average
    y = units.collect {|member| member.screen_y }.average
    target_direction(x, y, {x: screen_x, y: screen_y})
  end
  #--------------------------------------------------------------------------
  # * New method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    return 0
  end
  #--------------------------------------------------------------------------
  # * New method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    return 0
  end
  #--------------------------------------------------------------------------
  # * New method: character_hue
  #--------------------------------------------------------------------------
  def character_hue
    hue
  end
  #--------------------------------------------------------------------------
  # * New method: intro_pose?
  #--------------------------------------------------------------------------
  def intro_pose?
    !(note =~ /<NO INTRO>/i)
  end
  #--------------------------------------------------------------------------
  # * New method: victory_pose?
  #--------------------------------------------------------------------------
  def victory_pose?
    !(note =~ /<NO VICTORY>/i)
  end
end

#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemy characters. It's used within the Game_Troop class
# ($game_troop).
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Overwrite method: perform_damage_effect
  #--------------------------------------------------------------------------
  def perform_damage_effect
    Sound.play_enemy_damage
  end
  #--------------------------------------------------------------------------
  # * Alias method: perform_collapse_effect
  #--------------------------------------------------------------------------
  alias :perform_collapse_effect_ve_animated_battle :perform_collapse_effect
  def perform_collapse_effect
    reset_pose
    perform_collapse_effect_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * New method: character_name
  #--------------------------------------------------------------------------
  def character_name
    @character_name = @battler_name
    @character_name
  end
  #--------------------------------------------------------------------------
  # * New method: character_hue
  #--------------------------------------------------------------------------
  def character_hue
    @character_hue = @battler_hue
    @character_hue
  end
  #--------------------------------------------------------------------------
  # * New method: character_index
  #--------------------------------------------------------------------------
  def character_index
    return 0
  end
  #--------------------------------------------------------------------------
  # * New method: visual_items
  #--------------------------------------------------------------------------
  def visual_items
    [default_part]
  end
  #--------------------------------------------------------------------------
  # * New method: default_part
  #--------------------------------------------------------------------------
  def default_part
    {name: character_name, index1: character_index, index2: character_index,
     hue: character_hue, priority: 0}
  end
  #--------------------------------------------------------------------------
  # * New method: default_direction
  #--------------------------------------------------------------------------
  def default_direction
    units = opponents_unit.battle_members
    x = units.collect {|member| member.screen_x }.average
    y = units.collect {|member| member.screen_y }.average
    target_direction(x, y, {x: screen_x, y: screen_y})
  end
  #--------------------------------------------------------------------------
  # * New method: intro_pose?
  #--------------------------------------------------------------------------
  def intro_pose?
    note =~ /<INTRO POSE>/i
  end
  #--------------------------------------------------------------------------
  # * New method: victory_pose?
  #--------------------------------------------------------------------------
  def victory_pose?
    note =~ /<VICTORY POSE>/i
  end
end

#==============================================================================
# ** Game_Unit
#------------------------------------------------------------------------------
#  This class handles units. It's used as a superclass of the Game_Party and
# Game_Troop classes.
#==============================================================================

class Game_Unit
  #--------------------------------------------------------------------------
  # * New method: moving?
  #--------------------------------------------------------------------------
  def not_in_position?
    movable_members.any? {|member| member.not_in_position? }
  end
  #--------------------------------------------------------------------------
  # * New method: moving?
  #--------------------------------------------------------------------------
  def moving?
    movable_members.any? {|member| member.moving? }
  end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Alias method: comment_call
  #--------------------------------------------------------------------------
  alias :comment_call_ve_animated_battle :comment_call
  def comment_call
    call_animated_battle_comments
    comment_call_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * New method: call_animated_battle_comments
  #--------------------------------------------------------------------------
  def call_animated_battle_comments
    $game_system.no_intro   = true if note =~ /<no intro>/i
    $game_system.no_victory = true if note =~ /<no victory>/i
  end
end

#==============================================================================
# ** Sprite_Battler
#------------------------------------------------------------------------------
#  This sprite is used to display battlers. It observes a instance of the
# Game_Battler class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :battler
  attr_reader   :battler_name
  #--------------------------------------------------------------------------
  # * Overwrite method: update_bitmap
  #--------------------------------------------------------------------------
  def update_bitmap
    setup_bitmap if graphic_changed?
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: init_visibility
  #--------------------------------------------------------------------------
  def init_visibility
    @battler_visible = !@battler.hidden?
    self.opacity = 0 unless @battler_visible
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: update_origin
  #--------------------------------------------------------------------------
  def update_origin
    update_rect if bitmap
    update_icon
    update_throw
  end
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_animated_battle :initialize
  def initialize(viewport, battler = nil)
    initialize_ve_animated_battle(viewport, battler)
    init_variables
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_effect
  #--------------------------------------------------------------------------
  alias :update_effect_ve_animated_battle :update_effect
  def update_effect
    setup_collapse
    update_effect_ve_animated_battle
    update_pose
    update_pose_loop_anim if $imported[:ve_loop_animation]
  end
  #--------------------------------------------------------------------------
  # * Alias method: revert_to_normal
  #--------------------------------------------------------------------------
  alias :revert_to_normal_ve_animated_battle :revert_to_normal
  def revert_to_normal
    revert_to_normal_ve_animated_battle
    update_rect if bitmap
  end
  #--------------------------------------------------------------------------
  # * Alias method: setup_new_effect
  #--------------------------------------------------------------------------
  alias :setup_new_effect_ve_animated_battle :setup_new_effect
  def setup_new_effect
    if @battler_visible && !@invisible && @battler.invisible
      @invisible = true
      @effect_type = :disappear
      @effect_duration = 12
    elsif @battler_visible && @invisible && !@battler.invisible
      @invisible = false
      @effect_type = :appear
      @effect_duration = 12
    end
    setup_new_effect_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * New method: init_variables
  #--------------------------------------------------------------------------
  def init_variables
    @spin  = 0
    @frame = 0
    @sufix = ""
    @pose_sufix = ""
    @anim_sufix = VE_SPRITE_SUFIX
    @pose_count   = 0
    @frame_width  = 0
    @frame_height = 0
    @pose_value   = {}
    @icon_list    = {}
    @throw_list   = []
    start_effect(:appear) if $game_system.intro_fade && !@battler.hidden?
    @battler.clear_poses
    setup_positions
  end
  #--------------------------------------------------------------------------
  # * New method: setup_collapse
  #--------------------------------------------------------------------------
  def setup_collapse
    if @battler.dead? && !@dead
      @battler.perform_collapse_effect
      @dead = true
    elsif @dead && !@battler.dead?
      @dead = false
    end
  end
  #--------------------------------------------------------------------------
  # * New method: subject
  #--------------------------------------------------------------------------
  def subject
    @pose_battler ? @pose_battler : @battler
  end
  #--------------------------------------------------------------------------
  # * New method: sprite_value
  #--------------------------------------------------------------------------
  def sprite_value(value)
    @battler.sprite_value(value)
  end
  #--------------------------------------------------------------------------
  # * New method: graphic_changed?
  #--------------------------------------------------------------------------
  def graphic_changed?
    actor_name_change? || battler_name_change? || misc_change?
  end
  #--------------------------------------------------------------------------
  # * New method: actor_name_change?
  #--------------------------------------------------------------------------
  def actor_name_change?
    use_charset? && (@battler_name != @battler.character_name ||
    @battler_index != @battler.character_index ||
    @battler_hue   != @battler.character_hue)
  end
  #--------------------------------------------------------------------------
  # * New method: battler_name_change?
  #--------------------------------------------------------------------------
  def battler_name_change?
    !use_charset? && (@battler_name != @battler.battler_name ||
    @battler_hue  != @battler.battler_hue)
  end
  #--------------------------------------------------------------------------
  # * New method: misc_change?
  #--------------------------------------------------------------------------
  def misc_change?
    (visual_equip? && @visual_items != @battler.visual_items) ||
    @sufix != @battler.sufix || @direction != @battler.direction
  end
  #--------------------------------------------------------------------------
  # * New method: use_charset?
  #--------------------------------------------------------------------------
  def use_charset?
    sprite_value(:mode) == :charset
  end
  #--------------------------------------------------------------------------
  # * New method: visual_equip?
  #--------------------------------------------------------------------------
  def visual_equip?
    $imported[:ve_visual_equip]
  end
  #--------------------------------------------------------------------------
  # * New method: setup_bitmap
  #--------------------------------------------------------------------------
  def setup_bitmap
    if use_charset?
      @battler_name  = @battler.character_name 
      @battler_hue   = @battler.character_hue
      @battler_index = @battler.character_index
    else
      @battler_name  = @battler.battler_name
      @battler_hue   = @battler.battler_hue
    end
    @sufix        = @battler.sufix
    @direction    = @battler.direction
    @visual_items = @battler.visual_items.dup if visual_equip?
    init_bitmap
    init_frame
    init_visibility
  end
  #--------------------------------------------------------------------------
  # * New method: init_bitmap
  #--------------------------------------------------------------------------
  def init_bitmap
    case sprite_value(:mode)
    when :charset
      if visual_equip?
        args = [@battler_name, @battler_hue, @visual_items, sufix]
        self.bitmap = Cache.character(*args)
      else
        self.bitmap = Cache.character(get_character_name, @battler_hue)
      end
    when :single
      self.bitmap = Cache.battler(get_battler_name, @battler_hue)
    when :sprite
      self.bitmap = Cache.battler(get_battler_name, @battler_hue)
    else
      self.bitmap = Cache.battler(@battler_name, @battler_hue)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: sufix
  #--------------------------------------------------------------------------
  def sufix
    case sprite_value(:mode)
    when :charset then @sufix
    when :sprite  then @anim_sufix + @sufix
    else @sufix
    end
  end
  #--------------------------------------------------------------------------
  # * New method: get_battler_name
  #--------------------------------------------------------------------------
  def get_battler_name
    name = @battler_name + sufix
    battler_exist?(name) ? name : @battler_name
  end
  #--------------------------------------------------------------------------
  # * New method: get_character_name
  #--------------------------------------------------------------------------
  def get_character_name
    name = @battler_name + sufix
    character_exist?(name) ? name : @battler_name
  end
  #--------------------------------------------------------------------------
  # * New method: init_frame
  #--------------------------------------------------------------------------
  def init_frame
    @frame_width  = bitmap.width  / frame_number
    @frame_height = bitmap.height / row_number
  end
  #--------------------------------------------------------------------------
  # * New method: frame_number
  #--------------------------------------------------------------------------
  def frame_number
    return @battler.frames     if single_char?
    return @battler.frames * 4 if multi_char?
    return 1 unless battler_exist?(@battler_name + sufix)
    return sprite_value(:frames) if sprite_value(:mode) == :sprite
    return 1
  end
  #--------------------------------------------------------------------------
  # * New method: row_number
  #--------------------------------------------------------------------------
  def row_number
    return 4 if single_char?
    return 8 if multi_char?
    return 1 unless battler_exist?(@battler_name + sufix)
    return sprite_value(:rows) if sprite_value(:mode) == :sprite
    return 1
  end
  #--------------------------------------------------------------------------
  # * New method: single_char?
  #--------------------------------------------------------------------------
  def single_char?
    use_charset? && (single_normal? && !visual_equip?)
  end
  #--------------------------------------------------------------------------
  # * New method: multi_char?
  #--------------------------------------------------------------------------
  def multi_char?
    use_charset? && (multi_normal? || visual_equip?)
  end
  #--------------------------------------------------------------------------
  # * New method: single_normal?
  #--------------------------------------------------------------------------
  def single_normal?
    !visual_equip? && @battler_name[/^[!]?[$]./]
  end
  #--------------------------------------------------------------------------
  # * New method: multi_normal?
  #--------------------------------------------------------------------------
  def multi_normal?
    !visual_equip? && !@battler_name[/^[!]?[$]./]
  end
  #--------------------------------------------------------------------------
  # * New method: get_sign
  #--------------------------------------------------------------------------
  def get_sign
    @visual_items.any? {|part| !part[:name][/^[!]?[$]./] }
  end
  #--------------------------------------------------------------------------
  # * New method: update_rect
  #--------------------------------------------------------------------------
  def update_rect
    setup_frame
    setup_rect
    self.ox = @frame_width / 2
    self.oy = @frame_height
    self.mirror = pose_mirror
  end
  #--------------------------------------------------------------------------
  # * New method: pose_mirror
  #--------------------------------------------------------------------------
  def pose_mirror
    mirror = sprite_value(:invert)
    mirror = !mirror if @battler.timing && @battler.timing[:invert]
    mirror = !mirror if right? && sprite_value(:mirror)
    mirror
  end
  #--------------------------------------------------------------------------
  # * New method: down?
  #--------------------------------------------------------------------------
  def down?
    @battler.down?
  end
  #--------------------------------------------------------------------------
  # * New method: left?
  #--------------------------------------------------------------------------
  def left?
    @battler.left?
  end
  #--------------------------------------------------------------------------
  # * New method: right?
  #--------------------------------------------------------------------------
  def right?
    @battler.right?
  end
  #--------------------------------------------------------------------------
  # * New method: up?
  #--------------------------------------------------------------------------
  def up?
    @battler.up?
  end
  #--------------------------------------------------------------------------
  # * New method: setup_frame
  #--------------------------------------------------------------------------
  def setup_frame
    return if no_pose?
    value = @battler.timing
    value[:time] -= 1
    value[:time] = value[:wait] if value[:time] == 0
    return if value[:time] != value[:wait]
    max = value[:frame] == :all ? sprite_value(:frames) : value[:frame]
    @frame += 1
    if value[:return]
      @battler.frame = returing_value(@frame, max - 1)
      reset_frame if !value[:loop] && @battler.frame == 0
    else
      @frame %= max
      @battler.frame = value[:revert] ? max - 1 - @frame : @frame
      reset_frame if !value[:loop] && (@frame >= max - 1 || @frame == 0)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: no_pose?
  #--------------------------------------------------------------------------
  def no_pose?
    @battler.timing.empty? || !@battler.timing[:time]
  end
  #--------------------------------------------------------------------------
  # * New method: reset_frame
  #--------------------------------------------------------------------------
  def reset_frame
    invert = @battler.timing[:invert]
    @battler.timing = {invert: invert}
    @frame = 0
    @spin  = 0
  end
  #--------------------------------------------------------------------------
  # * New method: setup_rect
  #--------------------------------------------------------------------------
  def setup_rect
    sign =  @battler_name[/^[$]./]
    if use_charset? && !sign
      index = @battler_index
      frame = (index % 4 * @battler.frames + @battler.frame) * @frame_width
      row   = (index / 4 * 4 + @battler.row) * @frame_height
    else
      frame = [[@battler.frame, 0].max, frame_number - 1].min * @frame_width
      row   = [[@battler.row,   0].max,   row_number - 1].min * @frame_height
    end
    self.src_rect.set(frame, row, @frame_width, @frame_height)
  end  
  #--------------------------------------------------------------------------
  # * New method: update_pose
  #--------------------------------------------------------------------------
  def update_pose
    setup_pose
    update_next_pose
  end
  #--------------------------------------------------------------------------
  # * New method: update_next_pose
  #--------------------------------------------------------------------------
  def update_next_pose
    next_pose unless @pose
    return if !@pose || !@pose[:type].is_a?(Symbol)
    update_pose_type
    next_pose unless @waiting
  end
  #--------------------------------------------------------------------------
  # * New method: setup_pose
  #--------------------------------------------------------------------------
  def setup_pose
    @current_pose = pose_list.first
    return unless @current_pose
    clear   = changed_pose?
    @frame  = 0 if changed_pose?
    battler = @current_pose[:battler]
    @pose_battler = battler unless battler == :skip
    @pose_value   = @current_pose[:value]
    @pose = @pose_value.first
    @battler.icon_list.clear if clear && @battler.pose_name != :inactive
  end
  #--------------------------------------------------------------------------
  # * New method: changed_pose?
  #--------------------------------------------------------------------------
  def changed_pose?
    @pose_value != @current_pose[:value]
  end
  #--------------------------------------------------------------------------
  # * New method: pose_list
  #--------------------------------------------------------------------------
  def pose_list
    @battler.pose_list
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_type
  #--------------------------------------------------------------------------
  def update_pose_type
    @waiting = false
    return if @pose[:hit]   && @battler.result_flag != :hit
    return if @pose[:miss]  && @battler.result_flag != :miss
    return if @pose[:count] && pose_skip
    eval("update_pose_#{@pose[:type]}")
  end
  #--------------------------------------------------------------------------
  # * New method: pose_skip
  #--------------------------------------------------------------------------
  def pose_skip
    @pose[:count].any? { |value| value.between?(@prev_count, @pose_count) }
  end 
  #--------------------------------------------------------------------------
  # * New method: next_pose
  #--------------------------------------------------------------------------
  def next_pose
    return unless @current_pose
    case @current_pose[:next]
    when :loop
      @pose_value.next_item
    when :wait
      @pose_value.shift unless @pose_value.size <= 1
    when :reset
      @pose_value.shift
      reset_pose if @pose_value.empty?
    when Symbol
      @pose_value.shift
      @battler.call_pose(@current_pose[:next]) if @pose_value.empty?
    else
      last_value = @pose_value.shift
    end
    @pose_value.unshift(last_value) if @pose_value.empty? && pose_list.empty?
    @battler.pose_list.shift if @pose_value.empty?
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_wait
  #--------------------------------------------------------------------------
  def update_pose_wait
    case @pose[:time]
    when :animation
      @waiting = SceneManager.scene.spriteset.animation?
    when :action
      @waiting = SceneManager.scene.spriteset.action?(subject)
    when :movement
      @waiting = get_target.any? {|target| target.moving? }
    when :origin
      @waiting = get_target.any? {|target| target.origin? }
    when :counter
      @waiting = get_target.any? {|target| target.countered }
    when :substitution
      @waiting = get_target.any? {|target| target.substitution }
    when :tone
      @waiting = $game_troop.screen.tone_change?
    when :throw
      @waiting = get_target.any? {|target| target.sprite.throwing? }
    when :pose
      @waiting = !no_pose?
    when :freeze
      @waiting = get_target.any? {|target| target.frozen? }
    when :log
      @waiting = SceneManager.scene.log_window_wait?
    else
      @pose[:time] -= 1
      @pose[:time] = @pose[:wait] if @pose[:time] == 0
      @waiting = @pose[:time] != @pose[:wait]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_clear
  #--------------------------------------------------------------------------
  def update_pose_clear
    battler.pose_list.clear
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_action
  #--------------------------------------------------------------------------
  def update_pose_action
    get_target.each do |target|
      target.clear_loop_poses
      target.call_pose(@pose[:action], :clear, @battler.current_item, @battler) 
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_finish
  #--------------------------------------------------------------------------
  def update_pose_finish
    @battler.attack_flag += 1 if @battler.attack_flag
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_anim
  #--------------------------------------------------------------------------
  def update_pose_anim
    subject.targets = get_target
    subject.call_anim = true
    subject.animation = @pose[:anim]
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_effect
  #--------------------------------------------------------------------------
  def update_pose_effect
    subject.call_effect = true
    subject.damage_flag = @pose[:damage]
    subject.attack_flag = @pose[:weapon] if @pose[:weapon]
    if @pose[:target]
      subject.target_list ||= []
      subject.target_list += @pose[:target]
    else
      subject.target_list = subject.targets.dup
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_loop
  #--------------------------------------------------------------------------
  def update_pose_loop
    get_target.each {|target| target.pose_loop_anim = @pose[:loop_anim] }
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_reset
  #--------------------------------------------------------------------------
  def update_pose_reset
    @battler.actions[0] = @battler.previous_action if @pose[:action]
    reset_pose if @pose[:pose]
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_plane
  #--------------------------------------------------------------------------
  def update_pose_plane
    if @pose[:delete]
      SceneManager.scene.spriteset.delete_plane(@pose[:duration])
    elsif @pose[:list]
      SceneManager.scene.spriteset.action_plane(*@pose[:list])
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_sound
  #--------------------------------------------------------------------------
  def update_pose_sound
    se = RPG::SE.new(@pose[:name], @pose[:volume], @pose[:pitch])
    se.play
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_pose
  #--------------------------------------------------------------------------
  def update_pose_pose
    get_target.each do |target|
      target.row    = @pose[:row] - 1           if @pose[:row].is_a?(Numeric)
      target.row    = target.direction / 2  - 1 if @pose[:row].is_a?(Symbol)
      target.sufix  = @pose[:sufix]
      target.angle  = @pose[:angle]
      target.spin   = @pose[:spin]
      target.x_adj  = @pose[:x]
      target.y_adj  = @pose[:y]
      target.timing = @pose[:pose]
      target.frame  = @pose[:frame] - 1
      target.frame %= target.sprite_value(:frames)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_move
  #--------------------------------------------------------------------------
  def update_pose_move
    get_target.each do |target|
      target.teleport = @pose[:teleport]
      setup_target_position(target)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_counter
  #--------------------------------------------------------------------------
  def update_pose_counter
    get_target.each {|target| target.countered = @pose[:counter] }
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_substitution
  #--------------------------------------------------------------------------
  def update_pose_substitution
    get_target.each {|target| target.substitution = @pose[:substitution] }
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_jump
  #--------------------------------------------------------------------------
  def update_pose_jump
    get_target.each do |target|
      if @pose[:move]
        x_plus = (target.target_distance(:x) / 32.0).abs
        y_plus = (target.target_distance(:y) / 32.0).abs
        speed = Math.sqrt((x_plus ** 2) + (y_plus ** 2)) / @battler.move_speed
        target.jumping[:speed] = @pose[:height] * 5.0 / [speed, 1].max
      else
        target.jumping[:speed] = @pose[:speed]
      end
      target.jumping[:height] = @pose[:height]
      target.jumping[:count]  = target.jumping[:height] * 2  
    end    
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_inactive
  #--------------------------------------------------------------------------
  def update_pose_inactive
    subject.deactivate
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_count
  #--------------------------------------------------------------------------
  def update_pose_count
    @prev_count = @pose_count
    @pose_count += @pose[:add] + rand(@pose[:rand])
    @prev_count = 0 if @pose_count > @pose[:max]
    @pose_count %= @pose[:max]
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_direction
  #--------------------------------------------------------------------------
  def update_pose_direction
    dir = [subject.screen_x, subject.screen_y]
    subject.target_direction(*dir) if @pose[:return]
    subject.action_direction       if @pose[:targets]
    subject.default_direction      if @pose[:default]
    subject.active_direction       if @pose[:active]
    subject.direction = @pose[:direction] if @pose[:direction]
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_icon
  #--------------------------------------------------------------------------
  def update_pose_icon
    get_target.each do |target|
      if @pose[:delete]
        target.icon_list.delete(@pose[:index])
      else
        target.icon_list[@pose[:index]] = @pose.dup
      end
      target.sprite.update_icon
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_picture
  #--------------------------------------------------------------------------
  def update_pose_picture
    if @pose[:show]
      $game_troop.screen.pictures[@pose[:id]].show(*@pose[:show])
    elsif @pose[:move]
      $game_troop.screen.pictures[@pose[:id]].move(*@pose[:move])
    elsif @pose[:delete]
     $game_troop.screen.pictures[@pose[:id]].erase
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_throw
  #--------------------------------------------------------------------------
  def update_pose_throw
    get_target.each do |target|
      value = @pose.dup
      value[:user] = subject.sprite
      target.throw_list.push(value.dup)
      target.sprite.update_throw
    end   
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_shake
  #--------------------------------------------------------------------------
  def update_pose_shake
    if @pose[:screen]
      $game_troop.screen.start_shake(*@pose[:shake])
    else
      get_target.each {|target| target.start_shake(*@pose[:shake]) }
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_flash
  #--------------------------------------------------------------------------
  def update_pose_flash
    if @pose[:screen]
      $game_troop.screen.start_flash(*@pose[:flash])
    else
      get_target.each {|target| target.sprite.flash(*@pose[:flash]) }
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_freeze
  #--------------------------------------------------------------------------
  def update_pose_freeze
    get_target.each {|target| target.freeze = @pose[:duration] }
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_movie
  #--------------------------------------------------------------------------
  def update_pose_movie
    Graphics.play_movie("Movies/" + @pose[:name]) if @pose[:name] != ""
    update_pose_tone
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_drain
  #--------------------------------------------------------------------------
  def update_pose_drain
    get_target.each do |target|
      target.drain_setup if target.hp_drain != 0 || target.mp_drain != 0
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_transition
  #--------------------------------------------------------------------------
  def update_pose_transition
    if @pose[:prepare]
      Graphics.freeze
    elsif @pose[:execute]
      time  = @pose[:duration]
      name  = "Graphics/System/" + @pose[:name]
      value = @pose[:name] == "" ? [time] : [time, name]
      Graphics.transition(*value)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_hide
  #--------------------------------------------------------------------------
  def update_pose_hide
    hidden_list.each {|target| target.invisible = !@pose[:unhide] }
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_tone
  #--------------------------------------------------------------------------
  def update_pose_tone
    eval("update_#{@pose[:priority]}_tone")
  end
  #--------------------------------------------------------------------------
  # * New method: hidden_list
  #--------------------------------------------------------------------------
  def hidden_list
    list = []
    if @pose[:all_battler]
      list += $game_party.battle_members + $game_troop.members
    elsif @pose[:all_enemies]
      list += @battler.opponents_unit
    elsif @pose[:all_friends]
      list += @battler.friends_unit
    elsif @pose[:all_targets]
      list += @battler.action_targets
    elsif @pose[:not_targets]
      battlers = $game_party.battle_members + $game_troop.members
      targets  = @battler.action_targets
      list += battlers - targets
    end
    if @pose[:exc_user]
      list -= [@battler]
    elsif @pose[:inc_user]
      list += [@battler]
    end
    list
  end
  #--------------------------------------------------------------------------
  # * New method: update_low_tone
  #--------------------------------------------------------------------------
  def update_low_tone
    screen = $game_troop.screen
    screen.old_low_tone = screen.low_tone.dup unless screen.old_low_tone
    tone = @pose[:clear] ? screen.old_low_tone.dup : @pose[:tone] 
    $game_troop.screen.old_low_tone = nil if @pose[:clear]
    $game_troop.screen.start_low_tone_change(tone, @pose[:duration])
  end
  #--------------------------------------------------------------------------
  # * New method: update_normal_tone
  #--------------------------------------------------------------------------
  def update_normal_tone
    screen = $game_troop.screen
    screen.old_tone = screen.tone.dup unless screen.old_tone
    tone = @pose[:clear] ? $game_troop.screen.old_tone.dup : @pose[:tone] 
    $game_troop.screen.old_tone = nil if @pose[:clear]
    $game_troop.screen.start_tone_change(tone, @pose[:duration])
  end
  #--------------------------------------------------------------------------
  # * New method: update_high_tone
  #--------------------------------------------------------------------------  
  def update_high_tone
    screen = $game_troop.screen
    screen.old_high_tone = screen.high_tone.dup unless screen.old_high_tone
    tone = @pose[:clear] ? screen.old_high_tone.dup : @pose[:tone] 
    $game_troop.screen.old_high_tone = nil if @pose[:clear]
    $game_troop.screen.start_high_tone_change(tone, @pose[:duration])
  end
  #--------------------------------------------------------------------------
  # * New method: setup_target_position
  #--------------------------------------------------------------------------
  def setup_target_position(target)
    return unless @battler.use_sprite?
    if @pose[:value] == :move_to
      setup_move_to_target_position(target)
    elsif @pose[:value] == :step_foward
      setup_step_foward_position(target)
    elsif @pose[:value] == :step_backward
      setup_step_backward_position(target)
    elsif @pose[:value] == :escape
      setup_escape_position(target)
    elsif @pose[:value] == :retreat
      setup_retreat_position(target)
    elsif @pose[:value] == :substitution
      setup_substitution_position(target)
    end
    return if @waiting
    target.position_fix while target.sharing_position?
    setup_final_target_position(target)
    target.target_position = target.current_position.dup if target.unmovable?
  end
  #--------------------------------------------------------------------------
  # * New method: setup_move_to_target_position
  #--------------------------------------------------------------------------
  def setup_move_to_target_position(target)
    targets = @pose[:targets].select {|member| member.use_sprite? }
    return if targets.empty?
    return @waiting = true if targets.any? {|member| member.moving?}
    return @waiting = true if targets.any? {|member| member.damage_pose?}
    x = targets.collect {|member| member.current_position[:x]}.average
    y = targets.collect {|member| member.current_position[:y]}.average
    target.target_position[:x] = x
    target.target_position[:y] = y
    target.target_direction(x, y)
    target.adjust_position(32)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_step_foward_position
  #--------------------------------------------------------------------------
  def setup_step_foward_position(target)
    target.adjust_position(-48)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_step_backward_position
  #--------------------------------------------------------------------------
  def setup_step_backward_position(target)
    target.adjust_position(48)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_escape_position
  #--------------------------------------------------------------------------
  def setup_escape_position(target)
    target.adjust_position(320)
    position = target.target_position
    target.target_direction(position[:x], position[:y])
  end
  #--------------------------------------------------------------------------
  # * New method: setup_retreat_position
  #--------------------------------------------------------------------------
  def setup_retreat_position(target)
    return if target.target_position[:x] == target.screen_x &&
              target.target_position[:y] == target.screen_y
    target.target_position[:x] = target.screen_x
    target.target_position[:y] = target.screen_y
    position = target.target_position
    target.target_direction(position[:x], position[:y])
  end  
  #--------------------------------------------------------------------------
  # * New method: setup_substitution_position
  #--------------------------------------------------------------------------
  def setup_substitution_position(target)
    battler = target.action_targets.first
    target.target_position = battler.current_position.dup
    x = battler.left? ? -16 : battler.right? ? 16 : 0
    y = battler.up?   ? -16 : battler.down?  ? 16 : 1
    target.target_position[:x] += x
    target.target_position[:y] += y
  end
  #--------------------------------------------------------------------------
  # * New method: setup_final_target_positio
  #--------------------------------------------------------------------------
  def setup_final_target_position(target)
    if target.left? || target.right?
      target.target_position[:x] += target.left? ? @pose[:x] : -@pose[:x]
      target.target_position[:y] += @pose[:y]
    elsif target.up? || target.down?
      target.target_position[:y] += target.up? ? @pose[:x] : -@pose[:x]
      target.target_position[:x] += @pose[:y]
    end
    target.target_position[:h] += @pose[:h]
    target.move_speed = @pose[:speed]
  end
  #--------------------------------------------------------------------------
  # * New method: reset_pose
  #--------------------------------------------------------------------------
  def reset_pose
    reset_frame
    next_pose = get_idle_pose
    @pose_count = 0
    @battler.clear_loop_poses
    @battler.call_pose(next_pose)
    update_icon
    setup_pose
  end
  #--------------------------------------------------------------------------
  # * New method: get_idle_pose
  #--------------------------------------------------------------------------
  def get_idle_pose
    pose = :idle
    pose = :danger if @battler.danger?
    pose = @battler.state_pose  if @battler.state_pose?
    pose = :guard  if @battler.guard?
    pose = @battler.active_pose if @battler.active_pose
    pose = :dead   if @battler.dead?
    pose
  end
  #--------------------------------------------------------------------------
  # * New method: get_target
  #--------------------------------------------------------------------------
  def get_target
    @pose[:target] ? @pose[:target] : [subject]
  end
  #--------------------------------------------------------------------------
  # * New method: setup_positions
  #--------------------------------------------------------------------------
  def setup_positions
    positions = {x: @battler.screen_x, y: @battler.screen_y, h: 0, j: 0}
    @battler.target_position  = positions.dup
    @battler.current_position = positions.dup
    @battler.default_position = positions.dup
    @battler.jumping = {count: 0, height: 0, speed: 10}
    reset_pose
  end
  #--------------------------------------------------------------------------
  # * New method: position
  #--------------------------------------------------------------------------
  def position
    @battler.current_position
  end
  #--------------------------------------------------------------------------
  # * New method: update_position
  #--------------------------------------------------------------------------
  def update_position
    update_misc
    update_movement
    update_jumping
    self.x  = position[:x] + adjust_x
    self.y  = position[:y] + adjust_y
    self.z = @battler.screen_z
    self.ox = @frame_width / 2
    self.oy = @frame_height + position[:h] + position[:j] 
    @spin += 1 if Graphics.frame_count % 2 == 0
    self.angle  = @battler.angle + @battler.spin * @spin
  end
  #--------------------------------------------------------------------------
  # * New method: update_misc
  #--------------------------------------------------------------------------
  def update_misc
    @battler.update_shake
    @battler.update_freeze
  end
  #--------------------------------------------------------------------------
  # * New method: adjust_x
  #--------------------------------------------------------------------------
  def adjust_x
    @battler.x_adj + [1, -1].random * rand(@battler.shake + 1)
  end
  #--------------------------------------------------------------------------
  # * New method: adjust_y
  #--------------------------------------------------------------------------
  def adjust_y
    @battler.y_adj + [1, -1].random * rand(@battler.shake + 1)
  end
  #--------------------------------------------------------------------------
  # * New method: update_movement
  #--------------------------------------------------------------------------
  def update_movement
    return if @battler.frozen? || !@battler.moving?
    @battler.teleport ? update_teleport_movement : update_normal_movement
  end
  #--------------------------------------------------------------------------
  # * New method: update_teleport_movement
  #--------------------------------------------------------------------------
  def update_teleport_movement
    @battler.current_position[:x] = @battler.target_position[:x]
    @battler.current_position[:y] = @battler.target_position[:y]
    @battler.current_position[:h] = [@battler.target_position[:h], 0].max
    @battler.teleport = false
  end
  #--------------------------------------------------------------------------
  # * New method: update_normal_movement
  #--------------------------------------------------------------------------
  def update_normal_movement
    distance = set_distance
    move     = {x: 1.0, y: 1.0, h: 1.0}
    if distance[:x].abs < distance[:y].abs
      move[:x] = 1.0 / (distance[:y].abs.to_f / distance[:x].abs)
    elsif distance[:y].abs < distance[:x].abs
      move[:y] = 1.0 / (distance[:x].abs.to_f / distance[:y].abs)
    elsif distance[:h].abs < distance[:x].abs
      move[:h] = 1.0 / (distance[:x].abs.to_f / distance[:h].abs)
    end
    speed = set_speed(distance)
    x = move[:x] * speed[:x]
    y = move[:y] * speed[:y]
    h = move[:h] * speed[:h]
    set_movement(x, y, h)
  end
  #--------------------------------------------------------------------------
  # * New method: set_distance
  #--------------------------------------------------------------------------
  def set_distance
    x = @battler.target_distance(:x)
    y = @battler.target_distance(:y)
    h = @battler.target_distance(:h)
    {x: x, y: y, h: h}
  end
  #--------------------------------------------------------------------------
  # * New method: set_speed
  #--------------------------------------------------------------------------
  def set_speed(distance)
    move_speed = @battler.move_speed
    x = move_speed * (distance[:x] == 0 ? 0 : (distance[:x] > 0 ? 8 : -8))
    y = move_speed * (distance[:y] == 0 ? 0 : (distance[:y] > 0 ? 8 : -8))
    h = move_speed * (distance[:h] == 0 ? 0 : (distance[:h] > 0 ? 8 : -8))
    {x: x, y: y, h: h}
  end
  #--------------------------------------------------------------------------
  # * New method: set_movement
  #--------------------------------------------------------------------------
  def set_movement(x, y, h)
    target  = @battler.target_position
    current = @battler.current_position
    current[:x] += x
    current[:y] += y
    current[:h] += h
    current[:x] = target[:x] if in_distance?(current[:x], target[:x], x)
    current[:y] = target[:y] if in_distance?(current[:y], target[:y], y)
    current[:h] = target[:h] if in_distance?(current[:h], target[:h], h)
  end
  #--------------------------------------------------------------------------
  # * New method: in_distance?
  #--------------------------------------------------------------------------
  def in_distance?(x, y, z)
    x.between?(y - z - 1, y + z + 1)
  end
  #--------------------------------------------------------------------------
  # * New method: update_jumping
  #--------------------------------------------------------------------------
  def update_jumping
    return if @battler.jumping[:count] == 0 || @battler.frozen?
    jump = @battler.jumping
    jump[:count] = [jump[:count] - (1 * jump[:speed] / 10.0), 0].max.to_f
    count = jump[:count]
    speed = jump[:speed]
    peak  = jump[:height]
    result = (peak ** 2 - (count - peak).abs ** 2) / 2
    @battler.current_position[:j] = [result, 0].max
  end
  #--------------------------------------------------------------------------
  # * New method: update_icon
  #--------------------------------------------------------------------------
  def update_icon
    @battler.icon_list.each do |key, value|
      icon = @icon_list[key] 
      @icon_list[key] = Sprite_Icon.new(self, value) if !icon
      icon.refresh       if icon && value[:icon] != icon.icon
      icon.value = value if icon && icon.value != value
    end
    @icon_list.each do |key, value|
      value.update
      delete_icon(key) if value && !@battler.icon_list[key]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_throw
  #--------------------------------------------------------------------------
  def update_throw
    @battler.throw_list.each do |value|
      @throw_list.push(Sprite_Throw.new(self, value.dup))
      @battler.throw_list.delete(value)
    end
    @throw_list.each_with_index do |value, index|
      value.update
      delete_throw(index) if value.disposing? 
    end
    @throw_list.compact!
  end
  #--------------------------------------------------------------------------
  # * New method: delete_icon
  #--------------------------------------------------------------------------
  def delete_icon(key)
    @icon_list[key].dispose
    @icon_list.delete(key)
  end
  #--------------------------------------------------------------------------
  # * New method: delete_throw
  #--------------------------------------------------------------------------
  def delete_throw(index)
    @throw_list[index].dispose
    @throw_list.delete_at(index)
  end
  #--------------------------------------------------------------------------
  # * New method: throwing?
  #--------------------------------------------------------------------------
  def throwing?
    !@throw_list.empty?
  end
  #--------------------------------------------------------------------------
  # * New method: update_pose_loop_anim
  #--------------------------------------------------------------------------
  def update_pose_loop_anim
    if @battler.pose_loop_anim && !loop_anim?(:pose_anim)
      @pose_name_list = @battler.pose_name_list.first
      animation = {type: :pose_anim, anim: @battler.pose_loop_anim, loop: 1}     
      add_loop_animation(animation)
    end
    if @battler.pose_loop_anim && loop_anim?(:pose_anim) && 
       @pose_name_list != @battler.pose_name_list.first
      @pose_loop_anim = nil
      @battler.pose_loop_anim = nil
      end_loop_anim(:pose_anim)
    end
  end
end

#==============================================================================
# ** Spriteset_Battle
#------------------------------------------------------------------------------
#  This class brings together battle screen sprites. It's used within the
# Scene_Battle class.
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # * Overwrite method: create_actors
  #--------------------------------------------------------------------------
  def create_actors
    @actor_sprites = $game_party.battle_members.reverse.collect do |actor|
      Sprite_Battler.new(@viewport1, actor)
    end
    @actors_party = $game_party.battle_members.dup
  end
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_animated_battle :initialize
  def initialize
    init_action_plane
    initialize_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_animated_battle :update
  def update
    update_ve_animated_battle
    update_action_plane
  end
  #--------------------------------------------------------------------------
  # * Alias method: dispose
  #--------------------------------------------------------------------------
  alias :dispose_ve_animated_battle :dispose
  def dispose
    dispose_ve_animated_battle
    dispose_action_plane
  end
  #--------------------------------------------------------------------------
  # * Alias method: create_pictures
  #--------------------------------------------------------------------------
  alias :create_pictures_ve_animated_battle :create_pictures
  def create_pictures
    battler_sprites.each {|battler| battler.setup_positions }
    create_pictures_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: create_viewports
  #--------------------------------------------------------------------------
  alias :create_viewports_ve_animated_battle :create_viewports
  def create_viewports
    create_viewports_ve_animated_battle
    @viewport4   = Viewport.new
    @viewport4.z = 200
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_viewports
  #--------------------------------------------------------------------------
  alias :update_viewports_ve_animated_battle :update_viewports
  def update_viewports
    update_viewports_ve_animated_battle
    @viewport1.ox = [1, -1].random * rand($game_troop.screen.shake)
    @viewport1.oy = [1, -1].random * rand($game_troop.screen.shake)
    @back1_sprite.tone.set($game_troop.screen.low_tone) if @back1_sprite
    @back2_sprite.tone.set($game_troop.screen.low_tone) if @back2_sprite
    @viewport4.tone.set($game_troop.screen.high_tone)
  end
  #--------------------------------------------------------------------------
  # * New method: action?
  #--------------------------------------------------------------------------
  def action?(subject)
    battler_sprites.compact.any? do |sprite|
      sprite.subject == subject && sprite.battler != subject
    end
  end
  #--------------------------------------------------------------------------
  # * New method: init_action_plane
  #--------------------------------------------------------------------------
  def init_action_plane
    @action_plane = Action_Plane.new(@viewport1)
  end
  #--------------------------------------------------------------------------
  # * New method: update_action_plane
  #--------------------------------------------------------------------------
  def update_action_plane
    @action_plane.update
  end
  #--------------------------------------------------------------------------
  # * New method: dispose_action_plane
  #--------------------------------------------------------------------------
  def dispose_action_plane
    @action_plane.dispose
  end
  #--------------------------------------------------------------------------
  # * New method: action_plane
  #--------------------------------------------------------------------------
  def action_plane(name, x, y, z, zx, zy, opacity, blend, duration)
    @action_plane.setup(name, x, y, z, zx, zy, opacity, blend, duration)
  end
  #--------------------------------------------------------------------------
  # * New method: delete_plane
  #--------------------------------------------------------------------------
  def delete_plane(duration)
    @action_plane.delete(duration)
  end
end

#==============================================================================
# ** Window_BattleLog
#------------------------------------------------------------------------------
#  This window shows the battle progress. Do not show the window frame.
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # * Overwrite method: wait_and_clear
  #--------------------------------------------------------------------------
  def wait_and_clear
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: wait
  #--------------------------------------------------------------------------
  def wait
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: back_to
  #--------------------------------------------------------------------------
  def back_to(line_number)
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: display_added_states
  #--------------------------------------------------------------------------
  def display_added_states(target)
    target.result.added_state_objects.each do |state|
      state_msg = target.actor? ? state.message1 : state.message2
      next if state_msg.empty?
      replace_text(target.name + state_msg)
      wait
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: wait_and_clear
  #--------------------------------------------------------------------------
  alias :add_text_ve_animated_battle :add_text
  def add_text(text)
    skip_second_line while @lines.size > max_line_number
    add_text_ve_animated_battle(text)
  end
  #--------------------------------------------------------------------------
  # * New method: skip_second_line
  #--------------------------------------------------------------------------
  def skip_second_line
    first_line = @lines.shift
    @lines.shift
    @lines.unshift(first_line)
  end
  #--------------------------------------------------------------------------
  # * New method: wait_message_end
  #--------------------------------------------------------------------------
  def wait_message_end
    @method_wait.call(message_speed) if @method_wait && line_number > 0
    clear
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :subject
  #--------------------------------------------------------------------------
  # * Overwrite method: abs_wait_short
  #--------------------------------------------------------------------------
  def abs_wait_short
    update_for_wait
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: apply_item_effects
  #--------------------------------------------------------------------------
  def apply_item_effects(target, item)
    target.item_apply(@subject, item)
    refresh_status
    @log_window.display_action_results(target, item)
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: execute_action
  #--------------------------------------------------------------------------
  def execute_action
    @subject.activate
    use_item
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: use_item
  #--------------------------------------------------------------------------
  def use_item
    item = @subject.current_action.item
    @log_window.display_use_item(@subject, item)
    @subject.action_pose(item)
    @subject.use_item(item)
    refresh_status
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: show_animation
  #--------------------------------------------------------------------------
  def show_animation(targets, animation_id)
    if animation_id < 0
      show_animated_battle_attack_animation(targets)
    else
      show_normal_animation(targets, animation_id)
    end
    wait_for_animation
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: invoke_counter_attack
  #--------------------------------------------------------------------------
  def invoke_counter_attack(target, item)
    if target == @subject
      apply_item_effects(apply_substitute(target, item), item)
      return
    end
    target.setup_counter(@subject)
    @counter_flag.push(target)
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: invoke_magic_reflection
  #--------------------------------------------------------------------------
  def invoke_magic_reflection(target, item)
    if target == @subject
      apply_item_effects(apply_substitute(target, item), item)
      return
    end
    @subject.setup_reflect(item)
    @reflect_flag.push(target)
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: apply_substitute
  #--------------------------------------------------------------------------
  def apply_substitute(target, item)
    if check_substitute(target, item)
      substitute = target.friends_unit.substitute_battler
      if substitute && target != substitute
        @substitution = {target: target, substitute: substitute}
        substitute.setup_substitute(target)
        return substitute
      end
    end
    target
  end
  #--------------------------------------------------------------------------
  # * Alias method: create_spriteset
  #--------------------------------------------------------------------------
  alias :create_spriteset_ve_animated_battle :create_spriteset
  def create_spriteset
    create_spriteset_ve_animated_battle
    setup_spriteset
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_basic
  #--------------------------------------------------------------------------
  alias :update_basic_ve_animated_battle :update_basic
  def update_basic
    update_basic_ve_animated_battle
    update_sprite_action
  end
  #--------------------------------------------------------------------------
  # * Alias method: process_action
  #--------------------------------------------------------------------------
  alias :process_action_ve_animated_battle :process_action
  def process_action
    return if active?
    process_action_ve_animated_battle
  end
  #--------------------------------------------------------------------------
  # * Alias method: turn_end
  #--------------------------------------------------------------------------
  alias :turn_end_ve_animated_battle :turn_end
  def turn_end
    turn_end_ve_animated_battle
    @spriteset.battler_sprites.each {|sprite| sprite.reset_pose }
  end
  #--------------------------------------------------------------------------
  # * Alias method: next_command
  #--------------------------------------------------------------------------
  alias :next_command_ve_animated_battle :next_command
  def next_command
    BattleManager.set_active_pose
    BattleManager.actor.input_pose   if BattleManager.actor
    next_command_ve_animated_battle
    BattleManager.actor.command_pose if BattleManager.actor
  end
  #--------------------------------------------------------------------------
  # * Alias method: prior_command
  #--------------------------------------------------------------------------
  alias :prior_command_ve_animated_battle :prior_command
  def prior_command
    BattleManager.actor.cancel_pose  if BattleManager.actor
    prior_command_ve_animated_battle
    BattleManager.clear_active_pose
    BattleManager.actor.command_pose if BattleManager.actor
  end
  #--------------------------------------------------------------------------
  # * New method: close_window
  #--------------------------------------------------------------------------
  def close_window
    abs_wait(10)
    update_for_wait while @message_window.openness > 0
    $game_message.clear
  end
  #--------------------------------------------------------------------------
  # * New method: setup_spriteset
  #--------------------------------------------------------------------------
  def setup_spriteset
    battlers = $game_party.battle_members + $game_troop.members
    battlers.each {|member| member.default_direction }
    members = $game_party.movable_members + $game_troop.movable_members
    members.each do |member| 
      next if $game_system.no_intro || !member.intro_pose?
      member.call_pose(:intro, :clear)
    end
    2.times { @spriteset.update }
  end
  #--------------------------------------------------------------------------
  # * New method: log_window_wait?
  #--------------------------------------------------------------------------
  def log_window_wait?
    @log_window.line_number > 0
  end
  #--------------------------------------------------------------------------
  # * New method: log_window_clear
  #--------------------------------------------------------------------------
  def log_window_clear
    @log_window.clear
  end
  #--------------------------------------------------------------------------
  # * New method: show_animated_battle_attack_animation
  #--------------------------------------------------------------------------
  def show_animated_battle_attack_animation(targets)
    if @subject.actor? || $imported[:ve_actor_battlers]
      show_normal_animation(targets, @subject.atk_animation_id1, false)
    else
      Sound.play_enemy_attack
      abs_wait_short
    end
  end
  #--------------------------------------------------------------------------
  # * New method: next_subject?
  #--------------------------------------------------------------------------
  def next_subject?
    !@subject || !@subject.current_action
  end
  #--------------------------------------------------------------------------
  # * New method: active?
  #--------------------------------------------------------------------------
  def active?
    members = $game_troop.members + $game_party.battle_members
    members.any? {|member| member.active? }
  end
  #--------------------------------------------------------------------------
  # * New method: active?
  #--------------------------------------------------------------------------
  def active
    members = $game_troop.members + $game_party.battle_members
    members.select {|member| member.active? }.first
  end
  #--------------------------------------------------------------------------
  # * New method: update_sprite_action
  #--------------------------------------------------------------------------
  def update_sprite_action
    @old_subject = @subject
    battlers = $game_party.battle_members + $game_troop.members
    battlers.each do |subject|
      @subject = subject
      call_animation if @subject.call_anim
      call_effect    if @subject.call_effect
      call_end       if @subject.call_end
    end
    @subject = @old_subject
  end
  #--------------------------------------------------------------------------
  # * New method: call_animation
  #--------------------------------------------------------------------------
  def call_animation
    @subject.call_anim = false
    animation = @subject.animation
    @subject.animation = 0
    show_animation(@subject.targets, animation)
  end
  #--------------------------------------------------------------------------
  # * New method: call_effect
  #--------------------------------------------------------------------------
  def call_effect
    @counter_flag = []
    @reflect_flag = []
    @substitution = nil
    @subject.call_effect = false
    targets = @subject.target_list.dup
    item    = @subject.current_item
    @subject.target_list.clear
    targets.each {|target| item.repeats.times { invoke_item(target, item) } }
    @counter_flag.each {|target| @log_window.display_counter(target, item) }
    @reflect_flag.each {|target| @log_window.display_reflection(target, item) }
    if @substitution
      substitute = @substitution[:substitute]
      target     = @substitution[:target]
      @log_window.display_substitute(substitute, target) 
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_end
  #--------------------------------------------------------------------------
  def call_end
    @subject.call_end = false
    process_action_end if @subject.alive?
    @log_window.wait_message_end
  end
end

#==============================================================================
# ** Sprite_Object
#------------------------------------------------------------------------------
#  This the base sprite used to display icons and throw animations.
#==============================================================================

class Sprite_Object < Sprite_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :value
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    @right    = @battler.right?
    @left     = @battler.left?
    @down     = @battler.down?
    @up       = @battler.up?
    @spin     = 0
    @zooming  = 0
    @fade_in  = 0
    @fade_out = 0
    self.zoom_x = value[:izm]
    self.zoom_y = value[:izm]
  end
  #--------------------------------------------------------------------------
  # * update
  #--------------------------------------------------------------------------
  def update
    super
    update_zoom
    update_angle
    update_opacity
    update_position
  end
  #--------------------------------------------------------------------------
  # * update_opacity
  #--------------------------------------------------------------------------
  def update_opacity
    if value[:fin] > 0
      @fade_in += 1
      self.opacity = [@fade_in * value[:fin], value[:o]].min
    elsif value[:fout] > 0
      @fade_out += 1
      self.opacity = [value[:o] - @fade_out * value[:fin], 0].max
    else
      self.opacity =  value[:o]
    end
  end
  #--------------------------------------------------------------------------
  # * update_angle
  #--------------------------------------------------------------------------
  def update_angle
    @spin += 1 if Graphics.frame_count % 2 == 0
    self.angle  = value[:a] + value[:spin] * @spin
    self.angle *= -1 if @right 
    self.angle -= 90 if @up
    self.angle += 90 if @down
    self.angle  = 360 + self.angle if self.angle < 0
  end
  #--------------------------------------------------------------------------
  # * update_zoom
  #--------------------------------------------------------------------------
  def update_zoom
    if self.zoom_x < value[:ezm]
      @zooming += 1
      self.zoom_x = [value[:izm] + @zooming * value[:szm], value[:ezm]].min
      self.zoom_y = [value[:izm] + @zooming * value[:szm], value[:ezm]].min
    elsif self.zoom_x > value[:ezm]
      @zooming += 1
      self.zoom_x = [value[:izm] - @zooming * value[:szm], value[:ezm]].max
      self.zoom_y = [value[:izm] - @zooming * value[:szm], value[:ezm]].max
    end
  end
  #--------------------------------------------------------------------------
  # * icon
  #--------------------------------------------------------------------------
  def icon
    value[:icon]
  end
  #--------------------------------------------------------------------------
  # * icon_changed?
  #--------------------------------------------------------------------------
  def icon_changed?
    @icon_value != (value[:image] ?  value[:image] : icon)
  end
  #--------------------------------------------------------------------------
  # * setup_icon
  #--------------------------------------------------------------------------
  def setup_icon
    @icon_value = value[:image] ?  value[:image].dup : icon
    if value[:image]
      self.bitmap = Cache.picture(value[:image])
      self.src_rect.set(0, 0, bitmap.width, bitmap.height)
      @icon_ox = bitmap.width  / 2
      @icon_oy = bitmap.height / 2
    else
      self.bitmap = Cache.system("Iconset")
      self.src_rect.set(icon % 16 * 24, icon / 16 * 24, 24, 24)
      @icon_ox = 12
      @icon_oy = 12
    end
  end  
end

#==============================================================================
# ** Sprite_Icon
#------------------------------------------------------------------------------
#  This sprite is used to display icons.
#==============================================================================

class Sprite_Icon < Sprite_Object
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize(battler, value)
    @battler = battler
    @value   = value.dup
    super(battler.viewport)
    setup_icon
  end
  #--------------------------------------------------------------------------
  # * update_position
  #--------------------------------------------------------------------------
  def update_position
    setup_icon if icon_changed?
    self.x  = @battler.x
    self.y  = @battler.y + (value[:above] ? 1 : -1)
    self.z  = @battler.z 
    self.ox = @icon_ox 
    self.oy = @icon_oy
    if @right || @left
      angle_move(:x, (@right ? adjust_x : -adjust_x))
      angle_move(:y, adjust_y)
    elsif @up || @down
      angle_move(:x, (@down ? adjust_y : -adjust_y))
      angle_move(:y, (@down ? adjust_x : -adjust_x) - 8)
    end
    self.mirror = @right
  end
  #--------------------------------------------------------------------------
  # * angle_move
  #--------------------------------------------------------------------------
  def angle_move(axis, amount)
    a = (360 - angle) * Math::PI / 180
    cos = Math.cos(a)
    sin = Math.sin(a)
    self.ox += (axis == :x ? -cos : -sin) * amount
    self.oy += (axis == :x ?  sin : -cos) * amount
  end
  #--------------------------------------------------------------------------
  # * adjust_x
  #--------------------------------------------------------------------------
  def adjust_x
    @battler.ox / 2 - value[:x] 
  end
  #--------------------------------------------------------------------------
  # * adjust_y
  #--------------------------------------------------------------------------
  def adjust_y
    value[:y] - position[:h] - position[:j] - @battler.oy / 2
  end
  #--------------------------------------------------------------------------
  # * position
  #--------------------------------------------------------------------------
  def position
    @battler.position
  end
end

#==============================================================================
# ** Sprite_Throw
#------------------------------------------------------------------------------
#  This sprite is used to display throw animations.
#==============================================================================

class Sprite_Throw < Sprite_Object
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize(target, settings)
    @battler = settings[:user]
    @target  = target
    @value   = settings.dup
    super(target.viewport)
    setup_throw
  end
  #--------------------------------------------------------------------------
  # * setup_throw
  #--------------------------------------------------------------------------
  def setup_throw
    set_initial_position
    setup_arc
    setup_icon
    setup_animation if $imported[:ve_loop_animation] && value[:anim]
  end
  #--------------------------------------------------------------------------
  # * set_initial_position
  #--------------------------------------------------------------------------
  def set_initial_position
    if value[:return]
      @current_position = @target.position.dup
      @target_position  = @battler.position.dup
      init_ox = @target.right?  ? -value[:init_x] : value[:init_x]
      init_oy = @target.up?     ? -value[:init_y] : value[:init_y]
      end_ox  = @battler.right? ? -value[:end_x]  : value[:end_x]
      end_oy  = @battler.up?    ? -value[:end_y]  : value[:end_y]
    else
      @current_position = @battler.position.dup
      @target_position  = @target.position.dup
      init_ox = @battler.right? ? -value[:init_x] : value[:init_x]
      init_oy = @battler.up?    ? -value[:init_x] : value[:init_x]
      end_ox  = @target.right?  ? -value[:end_x]  : value[:end_x]
      end_oy  = @target.up?     ? -value[:end_y]  : value[:end_y]
    end
    @current_position[:x] += value[:init_x] + init_ox
    @current_position[:y] += value[:init_y] + init_oy
    @target_position[:x]  += value[:end_x]  + end_ox
    @target_position[:y]  += value[:end_y]  + end_oy
    @initial_position = @current_position.dup
  end
  #--------------------------------------------------------------------------
  # * setup_arc
  #--------------------------------------------------------------------------
  def setup_arc
    @arc = {}
    x_plus = (target_distance(:x) / 32.0).abs
    y_plus = (target_distance(:y) / 32.0).abs
    speed = Math.sqrt((x_plus ** 2) + (y_plus ** 2)) / value[:speed]
    @arc[:speed]  = value[:arc] * 5.0 / [speed, 1].max
    @arc[:height] = value[:arc]
    @arc[:count]  = value[:arc] * 2
    @current_position[:a] = 0
  end
  #--------------------------------------------------------------------------
  # * setup_icon
  #--------------------------------------------------------------------------
  def setup_icon
    super
    self.angle = value[:a]
  end
  #--------------------------------------------------------------------------
  # * setup_animation
  #--------------------------------------------------------------------------
  def setup_animation
    animation = {type: :throw, anim: value[:anim], loop: 1}
    add_loop_animation(animation)
  end
  #--------------------------------------------------------------------------
  # * update
  #--------------------------------------------------------------------------
  def update
    super
    update_move
    update_arc
  end
  #--------------------------------------------------------------------------
  # * update_move
  #--------------------------------------------------------------------------
  def update_move
    distance = set_distance
    move     = {x: 1.0, y: 1.0}
    if distance[:x].abs < distance[:y].abs
      move[:x] = 1.0 / (distance[:y].abs.to_f / distance[:x].abs)
    elsif distance[:y].abs < distance[:x].abs
      move[:y] = 1.0 / (distance[:x].abs.to_f / distance[:y].abs)
    end
    speed = set_speed(distance)
    x = move[:x] * speed[:x]
    y = move[:y] * speed[:y]
    set_movement(x, y)
  end
  #--------------------------------------------------------------------------
  # * set_distance
  #--------------------------------------------------------------------------
  def set_distance
    {x: target_distance(:x), y: target_distance(:y)}
  end
  #--------------------------------------------------------------------------
  # * target_distance
  #--------------------------------------------------------------------------
  def target_distance(symbol)
    @target_position[symbol] - @current_position[symbol]
  end
  #--------------------------------------------------------------------------
  # * set_speed
  #--------------------------------------------------------------------------
  def set_speed(distance)
    x = value[:speed] * (distance[:x] == 0 ? 0 : (distance[:x] > 0 ? 8 : -8))
    y = value[:speed] * (distance[:y] == 0 ? 0 : (distance[:y] > 0 ? 8 : -8))
    {x: x, y: y}
  end
  #--------------------------------------------------------------------------
  # * set_movement
  #--------------------------------------------------------------------------
  def set_movement(x, y)
    target  = @target_position
    current = @current_position
    current[:x] += x
    current[:y] += y
    current[:x] = target[:x] if in_distance?(current[:x], target[:x], x)
    current[:y] = target[:y] if in_distance?(current[:y], target[:y], y)
  end
  #--------------------------------------------------------------------------
  # * in_distance?
  #--------------------------------------------------------------------------
  def in_distance?(x, y, z)
    x.between?(y - z - 1, y + z + 1)
  end
  #--------------------------------------------------------------------------
  # * update_arc
  #--------------------------------------------------------------------------
  def update_arc
    return if @arc[:count] == 0
    @arc[:count] = [@arc[:count] - (1 * @arc[:speed] / 10.0), 0].max.to_f
    count = @arc[:count]
    speed = @arc[:speed]
    peak  = @arc[:height]   
    result = (peak ** 2 - (count - peak).abs ** 2) / 2
    @current_position[:a] = value[:revert] ? -result : result
  end
  #--------------------------------------------------------------------------
  # * update_position
  #--------------------------------------------------------------------------
  def update_position
    setup_icon if icon_changed?
    self.x = current[:x]
    self.y = current[:y] - current[:h] - current[:a]
    self.z = @battler.z + value[:z]
    self.ox = @icon_ox
    self.oy = @icon_oy
    self.mirror = @right || @up
  end
  #--------------------------------------------------------------------------
  # * current
  #--------------------------------------------------------------------------
  def current
    @current_position
  end
  #--------------------------------------------------------------------------
  # * target
  #--------------------------------------------------------------------------
  def target
    @target_position
  end
  #--------------------------------------------------------------------------
  # * disposing?
  #--------------------------------------------------------------------------
  def disposing?
    current[:x] == target[:x] && current[:y] == target[:y]
  end
end

#==============================================================================
# ** Action_Plane
#------------------------------------------------------------------------------
#  
#==============================================================================

class Action_Plane < Plane
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    @settings = {x: 0, y: 0, opacity: 0, zoom_x: 1.0, zoom_y: 1.0}
    @duration = 1
  end
  #--------------------------------------------------------------------------
  # * dispose
  #--------------------------------------------------------------------------
  def dispose
    bitmap.dispose if bitmap
    super
  end
  #--------------------------------------------------------------------------
  # * setup
  #--------------------------------------------------------------------------
  def setup(name, x, y, z, zoom_x, zoom_y, opacity, blend, duration)
    self.bitmap = Cache.picture(name)
    self.z = z
    @settings[:x] = x
    @settings[:y] = y
    @settings[:zoom_x]  = zoom_x / 100.0
    @settings[:zoom_y]  = zoom_y / 100.0
    @settings[:opacity] = opacity
    @blend_type = blend
    @delete     = false
    @duration   = [duration, 1].max
  end
  #--------------------------------------------------------------------------
  # * delete
  #--------------------------------------------------------------------------
  def delete(duration = 60)
    @settings[:opacity] = 0
    @duration = [duration, 1].max
    @delete   = true
  end
  #--------------------------------------------------------------------------
  # * value
  #--------------------------------------------------------------------------
  def value
    @settings
  end
  #--------------------------------------------------------------------------
  # * update
  #--------------------------------------------------------------------------
  def update
    update_position
    update_opacity
    update_zoom
    update_delete
    @duration -= 1 if @duration > 0
  end
  #--------------------------------------------------------------------------
  # * update_position
  #--------------------------------------------------------------------------
  def update_position
    self.ox += value[:x]
    self.oy += value[:y]
  end
  #--------------------------------------------------------------------------
  # * update_opacity
  #--------------------------------------------------------------------------
  def update_opacity
    return if @duration == 0
    d = @duration
    self.opacity = (self.opacity * (d - 1) + value[:opacity]) / d
  end
  #--------------------------------------------------------------------------
  # * update_zoom
  #--------------------------------------------------------------------------
  def update_zoom
    return if @duration == 0
    d = @duration
    self.zoom_x = (self.zoom_x * (d - 1) + value[:zoom_x]) / d
    self.zoom_y = (self.zoom_y * (d - 1) + value[:zoom_y]) / d
  end
  #--------------------------------------------------------------------------
  # * update_delete
  #--------------------------------------------------------------------------
  def update_delete
    return if !@delete || @duration > 0
    self.bitmap.dispose
    self.bitmap = nil
    @settings   = {x: 0, y: 0, opacity: 0, zoom_x: 100.0, zoon_y: 100.0}
    @blend_type = 0
    @delete = false
  end
end