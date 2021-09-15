#==============================================================================#
# ** Yggdrasil 1x6 - Engine (Full)
#------------------------------------------------------------------------------#
# ** Created by    : IceDragon (http://www.rpgmakervx.net/)
# ** Script-Status : CBS (Custom Battle System)
# ** Script Type   : Engine (ABS Base)
# ** Date Created  : 10/11/2010
# ** Date Modified : 12/03/2011
# ** Version       : 1.6c
#------------------------------------------------------------------------------#
#==============================================================================#
# ** INTRODUCTION
#------------------------------------------------------------------------------#
# So hello there, thank you for looking at Yggdrasil 1.6 (or 1x6)
# This is NOT an update for the 1.x series really.
# This was meant to be Yggdrasil 2, but I scrapped that.
# Anyway 1.6 removes the "Attack" system that was present in the older versions.
# Also the Action system as been directly implemented into it.
# All nessecary scripts are included (Such as Hud, Item, Skills etc..etc)
# In addition, the engine has a built in Stat Cache (!!!)
# Overall this version was meant to be a performance update/ungrade.
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** FEATURES
#------------------------------------------------------------------------------#
#  *I'll fill this when I feel like it*
#------------------------------------------------------------------------------#
#==============================================================================#
# ** RECOMMENDED
#------------------------------------------------------------------------------#
#
# IRME - Icy Random Map Encounters
#
# YEM Keyboard Input (Has been merged with the current Yggdrasil Version)
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** CHANGE LOG
#------------------------------------------------------------------------------#
#
# (MM/DD/YYYY)
#  10/11/2010 - BETA  Started Script
#  11/09/2010 - V1.0  Finished Script
#  11/15/2010 - V1.1  A whole lot of stuff happened
#                     Several bug fixes, new features (Too many to list)
#  ??/??/???? - V1.2  Several Improvements and BugFixes
#  12/17/2010 - V1.3  AI improvements, AI can now use skills
#  02/19/2011 - V1.4  So many changes, I tottaly forgot,
#                     Main things though, Targetting has been changed slightly
#                     Some fixes (Which I don't remember) have been done.
#  07/01/2011 - V1.59 Started Revamping entire code.
#  10/14/2011 - V1.6  Finished 1.6
#  11/30/2011 - V1.6a Fixed 3 bugs, added 5 new feature:
#                     BUGS:
#                       Stats didn't change when equipment was changed.
#                       Disabling the Shift System would cause an error.
#                       Disabling the level up window would cause an error
#                     NEW:
#                       Added pickup sounds:
#                         <pksfx: filename, vol, pit>
#                       Added popup enabling and disabling (For event comments)
#                         <enable pop>
#                         <disable pop> or <no pop>
#                       Added Bar Hiding (For event comments)
#                         <hide hp bar> ; <show hp bar>
#                         <hide mp bar> ; <show mp bar>
#                       Added changable attack animation for enemies:
#                         <atk animation id: n>
#                       Added extended drops for enemies:
#                         <drop item n>
#                         item_id: n
#                         weapon_id: n
#                         armor_id: n
#                         prob: n
#                         </drop item>
# 12/02/2011 - V1.6b  Added 4 new features, fixed 1 bug, housekeeping
#                     BUGS:
#                       Event Bars would hang in top right hand corner
#                     NEW:
#                       Wrote Hud Wrapper, added hud position procs
#                       Added Random class (for whatever reason)
#                       Added gold randomization for enemies. (BAM)
#                         <gold variation: n>
#                       Added Guarding: (How long will the guard action take)
#                         action_guard
#                         ["GUARD", [frames]]
#                         guard: frames
#                         While Guarding all other actions are blocked.
#                         You can make certain skills and items guardable (can be guarded against)
#                         <guardable>
#                     CLEAN:
#                       Rewrote Introduction
#                       Removed unused constants
# 12/03/2011 - V1.6c  Added 2 new features, fixed 4 bug, 2 changes
#                     NEW:
#                       Added Equipment icons for enemies
#                         <use equipment> Very important
#                         <equip icon x: wep y>
#                         <equip icon x: arm y>
#                         <equip icon x: skill y>
#                         <equip icon x: item y>
#                         <equip icon x: y>
#                       Added "AFFECTED" target type for "TARGET" action
#                         This returns a list of the targets that where last
#                         affected, by a _effect
#
#                     BUGS:
#                       Marshalling errors when you tried to save the game, while a poptext was present
#                       target_selection would malfunction on game reload
#                       Fixed multiple referencing errors that would occur on game reload
#                       roam_xy had an error in it resulting only 1 event being sent back
#                     CHANGES:
#                       Handles are now refreshed on game load to fix some errors
#                       Equipment handles have been stripped of there parents
#
#------------------------------------------------------------------------------#
#==============================================================================#
# ** KNOWN ISSUES
#------------------------------------------------------------------------------#
#  Becareful when using:
#  <action n>
#  </action>
#  It is very sensitive (even whitespace can destroy your action) D:
#  If you aren't confident stick to the <action n= string> method
#
#  Due to the size of the script, any error that occurs in the script MAY
#  not be located on the correct line.
#  I will split the script (AGAIN) later, to fix this problem.
#
#------------------------------------------------------------------------------#
$imported ||= {}
$simport.r 'yggdrasil', '1.6.0', 'A Switchable ABS Battle System'
#==============================================================================#
# ** YGG
#==============================================================================#
module YGG
#==============================================================================#
#                           Start Customization
#------------------------------------------------------------------------------#
#==============================================================================#
  #--------------------------------------------------------------------------#
  # * ABS_SYSTEM_SWITCH
  #--------------------------------------------------------------------------#
  # This is the switch which controls Yggdrasil
  # If you set this constant to nil, Yggdrasil will always be active.
  #--------------------------------------------------------------------------#
    ABS_SYSTEM_SWITCH = 2

  #--------------------------------------------------------------------------#
  # * ITEM_MAP
  #--------------------------------------------------------------------------#
  # Currently this is not used for 1.6, but its still nice to have it
  # just in case XD
  #--------------------------------------------------------------------------#
    ITEM_MAP = 2

  #--------------------------------------------------------------------------#
  # * DONT_SCAN_EVENTS
  #--------------------------------------------------------------------------#
  # Because events can either be allies or enemies, this tends to be a
  # bit slow for each event, you can disable event scanning,
  # so the events can only target the player.
  #--------------------------------------------------------------------------#
    DONT_SCAN_EVENTS = true

  #--------------------------------------------------------------------------#
  # * FULL_FIELD_SCAN
  #--------------------------------------------------------------------------#
  # *Warning this may cause Lag*
  # Events will scan all around them for targets
  # That means infront, behind, and beside
  #--------------------------------------------------------------------------#
    FULL_FIELD_SCAN = true

  #--------------------------------------------------------------------------#
  # * DIE_WAIT_TIME
  #--------------------------------------------------------------------------#
  # Time in frames for events to die.
  # Default is 30
  #--------------------------------------------------------------------------#
    DIE_WAIT_TIME = 30

  #--------------------------------------------------------------------------#
  # * DRAW_RANGES
  #--------------------------------------------------------------------------#
  # Should the ranges for attacks/skills/etc be drawn?
  #--------------------------------------------------------------------------#
    DRAW_RANGES = false

  #--------------------------------------------------------------------------#
  # * ALL_DEAD_GAMEOVER
  #--------------------------------------------------------------------------#
  # >.> Quite Obviously you will set this to true..
  # I don't even know why I made a constant for it anyway...
  # When this is true, if all party members are dead, the Gameover will
  # be triggered.
  #--------------------------------------------------------------------------#
    ALL_DEAD_GAMEOVER = true

  #--------------------------------------------------------------------------#
  # * TOTAL_WILD_ANIMS
  #--------------------------------------------------------------------------#
  # In addition to each characters own animations, Yggdrasil has a wild anim
  # set, where these animations are stand alone and can be triggered from
  # anywhere on the map.
  # Note greater numbers means more anims that can be shown at a time
  # This will increase the number of updates and may result in Lagging.
  # I reccomend keeping it around 8 to 16
  #--------------------------------------------------------------------------#
    TOTAL_WILD_ANIMS = 16

  #--------------------------------------------------------------------------#
  # * STATE_TURN_COUNTER
  #--------------------------------------------------------------------------#
  # This is used for state turns, in other words how many frames make a turn
  # Default is 240
  #--------------------------------------------------------------------------#
    STATE_TURN_COUNTER = 480 #240

  #--------------------------------------------------------------------------#
  # * SLIP_DAMAGE_FREQUENCY
  #--------------------------------------------------------------------------#
  # How often should slip damage occur
  #--------------------------------------------------------------------------#
    SLIP_DAMAGE_FREQUENCY = 5

  #--------------------------------------------------------------------------#
  # * ACTION_BUTTONS
  #--------------------------------------------------------------------------#
  # Yggdrasil 1x6 uses unlimited buttons instead of 3 ( 1.0..1.5 series )
  #--------------------------------------------------------------------------#
    # // Jump to (YGG_PlayerInputConfig)

  #--------------------------------------------------------------------------#
  # * TEXT_POP
  #--------------------------------------------------------------------------#
  # As of 1.6 TEXT POP is now built into the main script.
  #--------------------------------------------------------------------------#
    USE_TEXT_POP = true
    # Copied from BEM So you can recycle
    POPUP_SETTINGS = {
      :hp_dmg     => "%s",        # SprintF for HP damage.
      :hp_heal    => "+%s",       # SprintF for HP healing.
      :mp_dmg     => "%s SP",     # SprintF for MP damage.
      :mp_heal    => "+%s SP",    # SprintF for MP healing.
      :critical   => "CRITICAL!", # Text display for critical hit.
      :missed     => "MISS",      # Text display for missed attack.
      :evaded     => "EVADE!",    # Text display for evaded attack.
      :nulled     => "NULLED",    # Text display for nulled attack.
      :add_state  => "+%s",       # SprintF for added states.
      :rem_state  => "-%s",       # SprintF for removed states.

      :exp_pop    => "Exp: %s",   # SprintF for Exp Pops.
      :lvl_pop    => "Level %s",  # SprintF for Level Pops.
      :guard      => "Guard!!!",
    } # Do Not Remove

  #--------------------------------------------------------------------------#
  # * POPUP_RULES
  #--------------------------------------------------------------------------#
  # Text Properties
  # "Bold"      = Pop will be drawn Bold
  # "Italic"    = Pop will be drawn with Italics
  # "Shadow"    = Pop will be drawn with Shadows
  # "No Bold"   = Pop will not be drawn Bold
  # "No Italic" = Pop will not be drawn with Italics
  # "No Shadow" = Pop will not be drawn with Shadow
  #
  # Font names is an array of font names (If the first one isn't present on
  # the system, the next one is used, if non are present from the array
  # the default is used)
  #--------------------------------------------------------------------------#
    COLOR_SETS = {#Ally                      Damage
      :hp_no_dmg => [Color.new(180, 205, 180), Color.new(180, 205, 180)],
      :hp_dmg    => [Color.new(128, 128, 240), Color.new(240, 128, 128)],
      :hp_heal   => [Color.new(144, 238, 144), Color.new(198, 238, 144)],

      :mp_no_dmg => [Color.new(180, 180, 205), Color.new(180, 180, 205)],
      :mp_dmg    => [Color.new(199, 21 , 112), Color.new(199, 21 , 112)],
      :mp_heal   => [Color.new(173, 216, 230), Color.new(173, 216, 230)],
    }

    POPUP_RULES = {
    #
   #"something"=> [fontsize, [color, color], [text_properties], [font_names]]
      "HP_NO_DMG"=> [16, COLOR_SETS[:hp_no_dmg]  , [           ], [          ]],
      "HP_DMG"   => [21, COLOR_SETS[:hp_dmg]     , [           ], [          ]],
      "HP_HEAL"  => [21, COLOR_SETS[:hp_heal]    , ["Italic"   ], [          ]],

      "MP_NO_DMG"=> [16, COLOR_SETS[:mp_no_dmg]  , [           ], [          ]],
      "MP_DMG"   => [21, COLOR_SETS[:mp_dmg]     , [           ], [          ]],
      "MP_HEAL"  => [21, COLOR_SETS[:mp_heal]    , ["Italic"   ], [          ]],

      "MISSED"   => [19, Color.new(176, 196, 222), ["Italic"   ], [          ]],
      "EVADED"   => [19, Color.new(198, 198, 198), ["Italic"   ], [          ]],
      "NULLED"   => [19, Color.new(255, 160, 122), ["Bold"     ], [          ]],

      "ADD_STATE"=> [26, Color.new(255, 255, 224), ["No Shadow"], [          ]],
      "REM_STATE"=> [26, Color.new(250, 250, 210), ["No Shadow"], [          ]],

      "EXP_POP"  => [18, Color.new(255, 215, 0  ), [           ], [          ]],
      "LVL_POP"  => [21, Color.new(180, 215, 255), [           ], [          ]],

      "CRITICAL" => [24, Color.new(220, 20 , 60 ), ["Bold"     ], [          ]],

      "GUARD"    => [21, Color.new(198, 198, 202), ["Bold"     ], [          ]],
    } # Do Not Remove

  #--------------------------------------------------------------------------#
  # * CRITICAL_FONTSIZE_ADD
  #--------------------------------------------------------------------------#
  # When a critcial is done how much should be added to the Damage pop's
  # font size
  #--------------------------------------------------------------------------#
    CRITICAL_FONTSIZE_ADD = 4

  #--------------------------------------------------------------------------#
  # * SHOW_CRITICAL
  #--------------------------------------------------------------------------#
  # Should the "Critical" text be drawn when it is done?
  #--------------------------------------------------------------------------#
    SHOW_CRITICAL = true

  #--------------------------------------------------------------------------#
  # * SHOW_GUARD
  #--------------------------------------------------------------------------#
  # Should the "Guard" text be drawn when it is done?
  #--------------------------------------------------------------------------#
    SHOW_GUARD = true

  #--------------------------------------------------------------------------#
  # * LEVEL_UP_ALERT
  #--------------------------------------------------------------------------#
  # Should something happen on level up?
  #--------------------------------------------------------------------------#
    LEVEL_UP_ALERT = false

  #--------------------------------------------------------------------------#
  # * ANIM_ON_LEVEL
  #--------------------------------------------------------------------------#
  # Animation used for level up. If set to 0, no anim is played
  # This is disabled if LEVEL_UP_ALERT = false
  #--------------------------------------------------------------------------#
    ANIM_ON_LEVEL = 0 # 257

  #--------------------------------------------------------------------------#
  # * POP_LEVEL_UP
  #--------------------------------------------------------------------------#
  # Should a text pop with Level Up be used?
  # This is disabled if LEVEL_UP_ALERT = false
  #--------------------------------------------------------------------------#
    POP_LEVEL_UP = false

  #--------------------------------------------------------------------------#
  # * POP_EXP
  #--------------------------------------------------------------------------#
  # Should a text pop be used for EXP?
  #--------------------------------------------------------------------------#
    POP_EXP = true

  #--------------------------------------------------------------------------#
  # * EXP_GAINING_METHOD
  #--------------------------------------------------------------------------#
  # 0 Dead   - When the target is defeated the character gains EXP
  # 1 Per Hit- On every successful hit, exp is gained
  #--------------------------------------------------------------------------#
    EXP_GAINING_METHOD = 0

  #--------------------------------------------------------------------------#
  # * EXP_PER_HIT_FORMULA
  #--------------------------------------------------------------------------#
  # If you have no idea about scripting, don't touch this.
  #--------------------------------------------------------------------------#
    EXP_PER_HIT_FORMULA = Proc.new { |damage, atker, defer| defer.exp * damage / defer.maxhp}

  #--------------------------------------------------------------------------#
  # * EXP_SAHRE_METHOD
  #--------------------------------------------------------------------------#
  # 0 Active Member Only - Only the active member gains EXP
  # 1 All Members Equal  - All members gain EXP
  # 2 All Members Split  - The EXP is split amongst all Members
  #--------------------------------------------------------------------------#
    # 0 Only Active Member, 1 All Members Equal, 2 All Members Spilt
    EXP_SAHRE_METHOD = 1

  #--------------------------------------------------------------------------#
  # * GOLD_DROP_ICON
  #--------------------------------------------------------------------------#
  # This is the icon that is used for gold drops
  #--------------------------------------------------------------------------#
    GOLD_DROP_ICON = 147

  #--------------------------------------------------------------------------#
  # * DROP_SCATTER_DISTANCE
  #--------------------------------------------------------------------------#
  # This is how far a drop can be placed from its origin
  #--------------------------------------------------------------------------#
    DROP_SCATTER_DISTANCE = 3

  #--------------------------------------------------------------------------#
  # * ITEM_FADE_TIME
  #--------------------------------------------------------------------------#
  # How long, in frames until an item drop fades out
  #--------------------------------------------------------------------------#
    ITEM_FADE_TIME = 480

  #--------------------------------------------------------------------------#
  # * GOLD_FADE_TIME
  #--------------------------------------------------------------------------#
  # How long, in frames until an gold drop fades out
  #--------------------------------------------------------------------------#
    GOLD_FADE_TIME = 640

  #--------------------------------------------------------------------------#
  # * DROP_FADE_THRESHOLD
  #--------------------------------------------------------------------------#
  # When this frame is reached the drop will begin to fade out
  #--------------------------------------------------------------------------#
    DROP_FADE_THRESHOLD = 60
  #--------------------------------------------------------------------------#
  # * USE_SHIFT_SYSTEM (YGG_ShiftSystem)
  #--------------------------------------------------------------------------#
  # Unlike its predecessors, 1.6 has a built-in Shift System
  # This simply allows the quick changing between characters
  #--------------------------------------------------------------------------#
    USE_SHIFT_SYSTEM = false

  #--------------------------------------------------------------------------#
  # * HUD
  #--------------------------------------------------------------------------#
  # Options for HUD
  #--------------------------------------------------------------------------#
    USE_HUD = true
    HUD_SWITCH = 1

    HUD_POSITION_PROCS = {
    # :symbol     => Proc.new { [   x,   y,   z] },
      :main       => Proc.new { [ -12, Graphics.height-48, 1000] },
      :back       => Proc.new { [   0,   0,   0] },
      :hp_bar     => Proc.new { [ 232,  12,   3] },
      :mp_bar     => Proc.new { [ 232,  28,   3] },
      :exp_bar    => Proc.new { [  40,   9,   3] },
      :shift_bar  => Proc.new { [ 384,   9,   3] },
      :charge_bar => Proc.new { [ 472,   9,   3] },
      :sprite     => Proc.new { [ 196,   8,   3] },
      :skill_icon => Proc.new { |i| [  36 + i * 32,  16,   3] },
      :item_icon  => Proc.new { |i| [ 376 + i * 32,  16,   3] }
    }

  #--------------------------------------------------------------------------#
  # * HP/MP Bars
  #--------------------------------------------------------------------------#
  # Options for HP/MP Bars
  #--------------------------------------------------------------------------#
    USE_STAT_BARS = true # // Use Bars?
    USE_HPBAR     = true
    USE_MPBAR     = false

  #--------------------------------------------------------------------------#
  # * DROPS_WINDOW (YGG_DropsWindow)
  #--------------------------------------------------------------------------#
  # Options for drops window
  #--------------------------------------------------------------------------#
    USE_DROPS_WINDOW    = true
    # //                  [ x, y, z, width ]
    DROPS_WINDOW_SIZE   = [ 544-164, 416-72, 200, 160 ]
    DROPS_WINDOW_SWITCH = 1 # // Currently Linked with Hud

  #--------------------------------------------------------------------------#
  # * DROPS_SFX (Special Thanks to Nicke (Niclas) for the idea)
  #--------------------------------------------------------------------------#
  # Options for SFX when a drop is taken up
  # (You can override this using: <pickup sfx: filename, vol, pitch>)
  #--------------------------------------------------------------------------#
  # // Set any of these to nil to disable it                              // #
    SOUND_MONEY = RPG::SE.new( "SYS-Shop002", 60, 100 )    # // Sound effect for acquiring money.
    SOUND_ITEM  = RPG::SE.new( "XINFX-Pickup02", 50, 100 ) # // Sound effect for acquiring items.

  #--------------------------------------------------------------------------#
  # * USE_LEVEL_UP_WINDOW (YGG_LevelUpWindow)
  #--------------------------------------------------------------------------#
  # 0 - No Window (OFF), 1 - Small Strip, 2 - Stop Frame Full Info
  #--------------------------------------------------------------------------#
    USE_LEVEL_UP_WINDOW = 0

  #--------------------------------------------------------------------------#
  # * FULL_INTEGRATION
  #--------------------------------------------------------------------------#
  # Allow Yggdrasil to overwrite many core methods, to optimize is performance
  #--------------------------------------------------------------------------#
  # // Enabling this may cause normal battle operations to malfunction
  # // This option is reccommend for a strict YGG game
  #--------------------------------------------------------------------------#
    FULL_INTEGRATION = true

# oo========================================================================oo #
# // Actions \\                                                             // #
# oo========================================================================oo #
  ACTION_LIST = {}
# oo========================================================================oo #
# // Default Actions \\ DO NOT MESS WITH THESE                              // #
# oo========================================================================oo #

# oo========================================================================oo #
  ACTION_LIST["HIT_ANIM"] = [
    ["TARGET"       , ["AFFECTED"]                    ],
    ["ANIMATION"    , [171, "TARGETS", "WILD"]        ]
  ]
# // Normal Attack # For Default
  ACTION_LIST["NULL_ACTION"] = []

  ACTION_LIST["NORMAL_ATTACK"] = [
    ["RANGE"        , ["ADD", 0, 1]                   ],
    ["TARGET"       , ["RANGE"]                       ],
    ["SUBTARGET"    , ["ALLIES"]                      ],
    ["ANIMATION"    , ["ATTACK", "POS", "WILD", 0, 1] ],
    ["ATTACK EFFECT", ["USER", "TARGETS"]             ],
    ["ACTION"       , ["HIT_ANIM"]                    ]
  ]

  ACTION_LIST["GUARD_ACTION"] = [
    ["ANIMATION"    , [85, "USER", "WILD"]            ],
    ["GUARD"    , [3]                                 ], # // Set Guard for 3 frames
  ]

  ACTION_LIST["ESCAPE_ACTION"] = [
  ]

  ACTION_LIST["WAIT_ACTION"] = [
    ["PARENT WAIT"  , [20]                            ]
  ]

# oo========================================================================oo #
# // Normal Attack # For Enemies
  ACTION_LIST["NULL_ACTION_EN"] = [] # // Unused D:

  ACTION_LIST["NORMAL_ATTACK_EN"] = [
    ["RANGE"        , ["ADD", 0, 1]                   ],
    ["TARGET"       , ["RANGE"]                       ],
    ["SUBTARGET"    , ["ALLIES"]                      ],
    ["ANIMATION"    , ["ATTACK", "POS", "WILD", 0, 1] ],
    ["ATTACK EFFECT", ["USER", "TARGETS"]             ],
    ["ACTION"       , ["HIT_ANIM"]                    ]
  ]

  ACTION_LIST["GUARD_ACTION_EN"] = [
    ["GUARD"    , [3]                                 ], # // Set Guard for 3 frames
  ]

  ACTION_LIST["ESCAPE_ACTION_EN"] = [
  ]

  ACTION_LIST["WAIT_ACTION_EN"] = [
    ["PARENT WAIT"  , [20]                            ]
  ]
# oo========================================================================oo #
# // Skill Scopes                                                           // #
  # // None Scope Skill
  ACTION_LIST["NORMAL_OBJ0"] = [
    ["TARGET"      , ["USER"]                      ],
    ["ANIMATION"   , ["OBJ", "POS", "WILD", 0, 0]  ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // User Skill
  ACTION_LIST["NORMAL_OBJ1"] = [
    ["TARGET"      , ["USER"]                      ],
    ["ANIMATION"   , ["OBJ", "POS", "WILD", 0, 0]  ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Enemy Skill Single
  ACTION_LIST["NORMAL_OBJ2_1"] = [
    ["RANGE"       , ["ADD", 0, 1]                 ],
    ["TARGET"      , ["RANGE"]                     ],
    ["SUBTARGET"   , ["ALLIES"]                    ],
    ["ANIMATION"   , ["OBJ", "POS", "WILD", 0, 1]  ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Enemy Skill Dual
  ACTION_LIST["NORMAL_OBJ2_2"] = [
    ["RANGE"       , ["ADD", 0, 1]                 ],
    ["TARGET"      , ["RANGE"]                     ],
    ["SUBTARGET"   , ["ALLIES"]                    ],
    ["ANIMATION"   , ["OBJ", "POS", "WILD", 0, 1]  ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Enemy Skill Triple
  ACTION_LIST["NORMAL_OBJ2_3"] = [
    ["RANGE"       , ["ADD", 0, 1]                 ],
    ["TARGET"      , ["RANGE"]                     ],
    ["SUBTARGET"   , ["ALLIES"]                    ],
    ["ANIMATION"   , ["OBJ", "POS", "WILD", 0, 1]  ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Enemy Skill Random 1
  ACTION_LIST["NORMAL_OBJ2_R1"] = [
    ["TARGET"      , ["SCREEN"]                    ],
    ["SUBTARGET"   , ["ALLIES"]                    ],
    ["TARGET"      , ["RANDTARGET"]                ],
    ["ANIMATION"   , ["OBJ", "TARGET", "WILD"]     ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Enemy Skill Random 2
  ACTION_LIST["NORMAL_OBJ2_R2"] = [
    ["ACTION", ["NORMAL_OBJ2_R1"] ],
    ["ACTION", ["NORMAL_OBJ2_R1"] ]
  ]

  # // Enemy Skill Random 3
  ACTION_LIST["NORMAL_OBJ2_R3"] = [
    ["ACTION", ["NORMAL_OBJ2_R1"] ],
    ["ACTION", ["NORMAL_OBJ2_R1"] ],
    ["ACTION", ["NORMAL_OBJ2_R1"] ]
  ]

  # // Ally Skill
  ACTION_LIST["NORMAL_OBJ3_1"] = [
    ["RANGE"       , ["ADD", 0, 1]                 ],
    ["TARGET"      , ["RANGE"]                     ],
    ["SUBTARGET"   , ["ENEMIES"]                   ],
    ["ANIMATION"   , ["OBJ", "POS", "WILD", 0, 1]  ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Ally Skill Dual
  ACTION_LIST["NORMAL_OBJ3_2"] = [
    ["RANGE"       , ["ADD", 0, 1]                 ],
    ["TARGET"      , ["RANGE"]                     ],
    ["SUBTARGET"   , ["ENEMIES"]                   ],
    ["ANIMATION"   , ["OBJ", "POS", "WILD", 0, 1]  ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Ally Skill Triple
  ACTION_LIST["NORMAL_OBJ3_3"] = [
    ["RANGE"       , ["ADD", 0, 1]                 ],
    ["TARGET"      , ["RANGE"]                     ],
    ["SUBTARGET"   , ["ENEMIES"]                   ],
    ["ANIMATION"   , ["OBJ", "POS", "WILD", 0, 1]  ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Ally Skill Random 1
  ACTION_LIST["NORMAL_OBJ3_R1"] = [
    ["TARGET"      , ["SCREEN"]                    ],
    ["SUBTARGET"   , ["ENEMIES"]                   ],
    ["TARGET"      , ["RANDTARGET"]                ],
    ["ANIMATION"   , ["OBJ", "TARGET", "WILD"]     ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Ally Obj Random 2
  ACTION_LIST["NORMAL_OBJ3_R2"] = [
    ["ACTION", ["NORMAL_OBJ3_R1"] ],
    ["ACTION", ["NORMAL_OBJ3_R1"] ],
  ]

  # // Enemy Obj Random 3
  ACTION_LIST["NORMAL_OBJ3_R3"] = [
    ["ACTION", ["NORMAL_OBJ3_R1"] ],
    ["ACTION", ["NORMAL_OBJ3_R1"] ],
    ["ACTION", ["NORMAL_OBJ3_R1"] ],
  ]

  # // All Enemies
  ACTION_LIST["NORMAL_OBJ4"] = [
    ["TARGET"      , ["SCREEN"]                    ],
    ["SUBTARGET"   , ["ALLIES"]                    ],
    ["ANIMATION"   , ["OBJ", "TARGETS", "WILD"]    ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // All Allies
  ACTION_LIST["NORMAL_OBJ5"] = [
    ["TARGET"      , ["SCREEN"]                    ],
    ["SUBTARGET"   , ["ENEMIES"]                   ],
    ["ANIMATION"   , ["OBJ", "TARGETS", "WILD"]    ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Target Enemy Skill Single
  ACTION_LIST["NORMAL_OBJ2_T1"] = [
    ["TARGET"      , ["SCREEN"]                    ],
    ["SUBTARGET"   , ["ALLIES"]                    ],
    ["TARGET SELECT",[1, "TARGETS"]                ],
    ["ANIMATION"   , ["OBJ", "TARGETS", "WILD"]    ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Target Enemy Skill Dual
  ACTION_LIST["NORMAL_OBJ2_T2"] = [
    ["TARGET"      , ["SCREEN"]                    ],
    ["SUBTARGET"   , ["ALLIES"]                    ],
    ["TARGET SELECT",[1, "TARGETS"]                ],
    ["ANIMATION"   , ["OBJ", "TARGETS", "WILD"]    ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Target Enemy Skill Triple
  ACTION_LIST["NORMAL_OBJ2_T3"] = [
    ["TARGET"      , ["SCREEN"]                    ],
    ["SUBTARGET"   , ["ALLIES"]                    ],
    ["TARGET SELECT",[1, "TARGETS"]                ],
    ["ANIMATION"   , ["OBJ", "TARGETS", "WILD"]    ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Target Ally Skill
  ACTION_LIST["NORMAL_OBJ3_T1"] = [
    ["TARGET"      , ["SCREEN"]                    ],
    ["SUBTARGET"   , ["ENEMIES"]                   ],
    ["TARGET SELECT",[1, "TARGETS"]                ],
    ["ANIMATION"   , ["OBJ", "TARGETS", "WILD"]    ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Target Ally Skill Dual
  ACTION_LIST["NORMAL_OBJ3_T2"] = [
    ["TARGET"      , ["SCREEN"]                    ],
    ["SUBTARGET"   , ["ENEMIES"]                   ],
    ["TARGET SELECT",[1, "TARGETS"]                ],
    ["ANIMATION"   , ["OBJ", "TARGETS", "WILD"]    ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Target Ally Skill Triple
  ACTION_LIST["NORMAL_OBJ3_T3"] = [
    ["TARGET"      , ["SCREEN"]                    ],
    ["SUBTARGET"   , ["ENEMIES"]                   ],
    ["TARGET SELECT",[1, "TARGETS"]                ],
    ["ANIMATION"   , ["OBJ", "TARGETS", "WILD"]    ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ],
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ]
  ]

  # // Breath all targets in range
  ACTION_LIST["BREATH_ATTACK1"] = [
    ["RANGE"       , ["CREATE", 3, 0, 3, 2]        ], # // Point Range downward
    ["TARGET"      , ["RANGE"]                     ], # // Get all targets within range
    ["ANIMATION"   , ["OBJ", "POS", 0, 1]          ], # // Show animation infront
    ["OBJ EFFECT"  , ["USER", "TARGETS"]           ], # // Object Damage
  ]

# oo========================================================================oo #
# \\ End Default Actions //                                                 // #
# oo========================================================================oo #
#==============================================================================#
#                           End Customization
#------------------------------------------------------------------------------#
#==============================================================================#
end
#==============================================================================#
# ** YGG # // Forward Declarations
#==============================================================================#
module YGG
#==============================================================================#
# ** Handlers
#==============================================================================#
  module Handlers   ; end
#==============================================================================#
# ** Containers
#==============================================================================#
  module Containers ; end
#==============================================================================#
# ** MixIns
#==============================================================================#
  module MixIns     ; end
#==============================================================================#
# ** Objects
#==============================================================================#
  module Objects    ; end
#==============================================================================#
# ** Scenes
#==============================================================================#
  module Scenes     ; end
#==============================================================================#
# ** Sprites
#==============================================================================#
  module Sprites    ; end
#==============================================================================#
# ** REGEXP
#==============================================================================#
  module REGEXP     ; end
#==============================================================================#
# ** Windows
#==============================================================================#
  module Windows    ; end
#==============================================================================#
# ** Pos
#==============================================================================#
  class Pos ; end
#==============================================================================#
# ** Handlers::Screen
#==============================================================================#
  class Handlers::Screen < Pos ; end
#==============================================================================#
# ** Objects::Projectiles
#==============================================================================#
  module Objects::Projectiles ; end
#==============================================================================#
# ** Random
#==============================================================================#
  module Random

  #--------------------------------------------------------------------------#
  # * new-method :min_max
  #--------------------------------------------------------------------------#
    def self.min_max( min, max )
      return min + rand( max - min )
    end

  #--------------------------------------------------------------------------#
  # * new-method :variation
  #--------------------------------------------------------------------------#
    def self.variation( value, percent )
      new_value = rand(Integer(value * percent / 100.0))
      new_value = value + (rand(2) == 0 ? new_value : -new_value)
      return new_value
    end

  end
end

#==============================================================================#
# ** Color
#==============================================================================#
class Color

  #--------------------------------------------------------------------------#
  # * overwrite-method :to_a
  #--------------------------------------------------------------------------#
  def to_a()
    return self.red, self.green, self.blue, self.alpha
  end

end

#==============================================================================#
# ** YGG
#==============================================================================#
module YGG

  #--------------------------------------------------------------------------#
  # * new-method :__dump_font
  #--------------------------------------------------------------------------#
  def self.__dump_font( font )
    color = Color.new( 0, 0, 0 )
    color.set( *font.color.to_a )
    shad_color = Color.new( 0, 0, 0 )
    shad_color.set( *font.shadow_color.to_a )
    return Marshal.dump(
    {
      :color        => color,
      :shad_color   => shad_color,
      :name         => font.name.to_a.clone,
      :size         => font.size.to_i,
      :bold         => font.bold,
      :italic       => font.italic,
      :shadow       => font.shadow,
    } )
  end

end

#==============================================================================#
# ** Font
#==============================================================================#
class Font

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_writer :shadow_color

  #--------------------------------------------------------------------------#
  # * new-method :shadow_color
  #--------------------------------------------------------------------------#
  def shadow_color()
    @shadow_color ||= Color.new( 0, 0, 0 )
    return @shadow_color
  end

  #--------------------------------------------------------------------------#
  # * new-method :_dump
  #--------------------------------------------------------------------------#
  def _dump( depth )
    return YGG.__dump_font( self )
  end

  #--------------------------------------------------------------------------#
  # * new-class-method :_load
  #--------------------------------------------------------------------------#
  def self._load( str )
    settings          = Marshal.load( str )
    font              = ::Font.new()
    font.color        = settings[:color]
    font.shadow_color = settings[:shad_color]
    font.name         = settings[:name]
    font.size         = settings[:size]
    font.bold         = settings[:bold]
    font.italic       = settings[:italic]
    font.shadow       = settings[:shadow]
    return font
  end

end

require_relative 'util/keys'

module YGG
  def self.player_keys
    @player_keys ||= begin
      keys = YGG::Util::Keys.new
      keys.add(Win32::Keyboard::Keys::A)
      keys.add(Win32::Keyboard::Keys::D)
      keys.add(Win32::Keyboard::Keys::S)
      Win32::Keyboard::Keys::NUMBERS.each do |num|
        keys.add(num)
      end
      ::Input.components.push(keys)
      keys
    end
  end
end

#==============================================================================#
# ** YGG::MixIns::Player (YGG_PlayerInputConfig)
#==============================================================================#
module YGG::MixIns::Player
  #--------------------------------------------------------------------------#
  # * new-method :get_obj_actions
  #--------------------------------------------------------------------------#
  def get_obj_actions(obj, id)
    return [], [] if obj.nil?
    return obj.ygg_actions[id].to_a, obj.ygg_pre_actions[id].to_a
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_attack_input
  #--------------------------------------------------------------------------#
  def ygg_attack_input
    #return unless ygg_can_attack?
    return if $game_map.interpreter.running?
    return if ygg_battler.nil?
    if @guard_time > 0
      @guard_time += 1 if YGG.player_keys.pressed?(Win32::Keyboard::Keys::D)
      return
    end
    return if @action_handle.busy?
    acthand_ret = ygg_attack_input1              # // ASD Input
    acthand_ret = ygg_attack_input2(acthand_ret) # // Skill Input 1..5
    ygg_attack_input3(acthand_ret)               # // Item Input 6..9 and 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_attack_input1
  #--------------------------------------------------------------------------#
  def ygg_attack_input1
    act, pact = nil, nil
    obj = nil
    if YGG.player_keys.triggered?(Win32::Keyboard::Keys::A)
      return 0 unless ygg_battler.ygg_can_attack?()
      obj = ygg_battler.weapons[0]
      act, pact = *get_obj_actions( obj, 1 )
    elsif YGG.player_keys.triggered?(Win32::Keyboard::Keys::S) && ygg_battler.two_swords_style
      return 0 unless ygg_battler.ygg_can_attack?()
      obj = ygg_battler.weapons[1]
      act, pact = *get_obj_actions( obj, 1 )
    elsif YGG.player_keys.triggered?(Win32::Keyboard::Keys::D) && !ygg_battler.two_swords_style
      return 0 unless ygg_battler.ygg_can_attack?()
      obj = ygg_battler.armors[0]
      act, pact = *get_obj_actions( obj, 0 )
    end
    return 0 if act.nil?() || pact.nil?()
    return 0 if act.empty?() && pact.empty?()
    if pact.empty?()
      @action_handle.setup( act )
    else
      @action_handle.list_stack << act
      @action_handle.setup( pact )
    end
    @action_handle.execute( self )
    ygg_battler.cooldown += obj.user_charge_cap
    return 1
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_attack_input2
  #--------------------------------------------------------------------------#
  def ygg_attack_input2(acthand_ret)
    for i in 1..5
      act, pact, obj = nil, nil, nil
      if YGG.player_keys.triggered?(Win32::Keyboard::Keys::NUMBERS[i])
        slot_id = i-1
        obj = ygg_battler.skill_slot( slot_id )
        next unless ygg_battler.ygg_skill_can_use?( obj )
        act, pact = *get_obj_actions( obj, 0 )
      end
      next if act.nil? || pact.nil? || obj.nil?
      next if act.empty? && pact.empty?
      next unless skill_can_use?( obj )
      if pact.empty?
        hnd = ::YGG::Handlers::Action.new( self, [] ) ; hnd.setup( act )
        hnd.execute( self, [], { :skill_id => obj.id } )
        @free_act_handles << hnd
      else
        next if acthand_ret == 1
        @action_handle.list_stack << act
        @action_handle.setup( pact )
        @action_handle.execute( self, [], { :skill_id => obj.id } )
        acthand_ret = 1
      end
      ygg_battler.get_skill_handle( obj.id ).reset_time
      ygg_battler.cooldown += obj.user_charge_cap
      ygg_battler.ygg_use_skill( obj )
    end
    return acthand_ret
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_attack_input3
  #--------------------------------------------------------------------------#
  def ygg_attack_input3( acthand_ret )
    for i in (6..9).to_a+[0]
      act, pact, obj = nil, nil, nil
      if YGG.player_keys.triggered?(Win32::Keyboard::Keys::NUMBERS[i])
        slot_id = i==0 ? 10-6 : i-6
        obj = ygg_battler.item_slot( slot_id )
        next unless ygg_battler.ygg_item_can_use?( obj )
        act, pact = *get_obj_actions( obj, 0 )
      end
      next if act.nil? || pact.nil? || obj.nil?
      next if act.empty? && pact.empty?
      next unless item_can_use?( obj )
      if pact.empty?
        hnd = ::YGG::Handlers::Action.new( self, [] ) ; hnd.setup( act )
        hnd.execute( self, [], { :item_id => obj.id } )
        @free_act_handles << hnd
      else
        next if acthand_ret == 1
        @action_handle.list_stack << act
        @action_handle.setup( pact )
        @action_handle.execute( self, [], { :item_id => obj.id } )
        acthand_ret = 1
      end
      ygg_battler.get_item_handle( obj.id ).reset_time()
      ygg_battler.cooldown += obj.user_charge_cap
      ygg_battler.ygg_use_item( obj )
    end
    return acthand_ret
  end

  #--------------------------------------------------------------------------#
  # * new-method :skill_can_use?
  #--------------------------------------------------------------------------#
  def skill_can_use?( obj )
    return false if obj.nil?()
    return false if ygg_battler.nil?()
    return ygg_battler.skill_can_use?( obj )
  end

  #--------------------------------------------------------------------------#
  # * new-method :item_can_use?
  #--------------------------------------------------------------------------#
  def item_can_use?( obj )
    return false if obj.nil?()
    return false if ygg_battler.nil?()
    return $game_party.item_can_use?( obj )
  end

end

# // (YGG_AIEngine_Setup)
#==============================================================================#
# ** YGG::Handlers::AIEngines
#==============================================================================#
module YGG::Handlers::AIEngines
#==============================================================================#
# ** Base (Forward Declaration)
#==============================================================================#
  class Base           ; end
#==============================================================================#
# ** Default (Forward Declaration)
#==============================================================================#
  class Default < Base ; end
#==============================================================================#
# ** Guard (Forward Declaration)
#==============================================================================#
  class Guard < Base   ; end
#==============================================================================#
# ** Wall (Forward Declaration)
#==============================================================================#
  class Wall < Base    ; end
#==============================================================================#
# ** ImmortalVarBoss (Forward Declaration)
#==============================================================================#
  class ImmortalVarBoss < Base  ; end

  #--------------------------------------------------------------------------#
  # * ENGINES
  #--------------------------------------------------------------------------#
  # This hash contains references to the Engine's Class, NOT AN INSTANCE
  # of the class.
  #--------------------------------------------------------------------------#
  ENGINES = {
    # // Default AI that uses the Game_Battler's make_action
    # // to attack
    "default" => Default,         # // Default (Make Action) AI
    # // An AI that only attacks/moves/acts when an enemy enters its field
    "guard"   => Guard,           # // Specialized AI
    # // An AI that does nothing, but its HP slowly depletes
    "wall"    => Wall,
    # // An invincible boss, thats hp is controlled by a variable
    # // This is a 2nd level subclass
    "ivboss"  => ImmortalVarBoss,
  }

end

#==============================================================================#
# ** YGG::AI_ENGINES
#==============================================================================#
YGG::AI_ENGINES = YGG::Handlers::AIEngines::ENGINES

#==============================================================================#
# ** YGG::Handlers::AIEngines::Base
#==============================================================================#
class YGG::Handlers::AIEngines::Base

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :parent

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize(parent, setup_data = {})
    @parent = parent
    @update_time = 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :pause
  #--------------------------------------------------------------------------#
  def pause
    @paused = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :unpause
  #--------------------------------------------------------------------------#
  def unpause
    @paused = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
  def update
    return if @paused
    return if @parent.guard_time > 0
    @update_time = [@update_time - 1, 0].max
    ai_update if @update_time == 0
  end
end

#==============================================================================#
# ** YGG::Handlers::AIEngines::Default
#==============================================================================#
class YGG::Handlers::AIEngines::Default

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( parent, setup_data={} )
    super( parent, setup_data )
    @update_time_cap = (setup_data["update_time"] || 90).to_i
  end

  #--------------------------------------------------------------------------#
  # * new-method :ai_update
  #--------------------------------------------------------------------------#
  def ai_update()
    #return # // Remove this later
    return if @parent.ygg_battler.cooldown > 0
    return if @parent.ygg_battler.nil?()
    @parent.ygg_battler.make_action()
    case @parent.ygg_battler.action.kind
    when 0 # // Basic
      case @parent.ygg_battler.action.basic
      when 0 # // Attack
        @update_time = @update_time_cap / 3
        t = @parent.get_targets_nearby( 1, @parent.ygg_correct_target( "ENEMY" ) )
        return @update_time = @update_time_cap / 4 if t[0].nil?()
        @parent.turn_to_coord( t[0].x, t[0].y )
        @parent.action_handle.setup( @parent.ygg_battler.get_action_by_id( 0 ) )
        @parent.action_handle.execute( @parent )
      when 1 # // Guard
        @parent.action_handle.setup( @parent.ygg_battler.get_action_by_id( 1 ) )
        @parent.action_handle.execute( @parent )
      when 2 # // Escape
        @parent.action_handle.setup( @parent.ygg_battler.get_action_by_id( 2 ) )
        @parent.action_handle.execute( @parent )
      when 3 # // Wait
        @parent.action_handle.setup( @parent.ygg_battler.get_action_by_id( 3 ) )
        @parent.action_handle.execute( @parent )
      end
    when 1 # // Skill
      obj = $data_skills[@parent.ygg_battler.action.skill_id]
      return unless @parent.ygg_battler.ygg_skill_can_use?( obj )
      if obj.for_opponent?()
        t = @parent.get_targets_nearby( 1, @parent.ygg_correct_target( "ENEMY" ) )
      elsif obj.for_friend?()
        t = @parent.get_targets_nearby( 1, @parent.ygg_correct_target( "ALLY" ) )
      else
        t = @parent.get_targets_nearby( 1, "ALL" )
      end
      return @update_time = @update_time_cap / 4 if t[0].nil?()
      @parent.ygg_battler.ygg_use_skill( obj )
      @parent.turn_to_coord( t[0].x, t[0].y )
      @parent.action_handle.setup( obj.ygg_actions[0] )
      @parent.action_handle.execute( @parent, [],
        { :skill_id=> @parent.ygg_battler.action.skill_id } )
    when 2 # // Item Enemies cant use items
    end
    @update_time = @update_time_cap
  end

end

#==============================================================================#
# ** YGG::Handlers::AIEngines::Guard
#==============================================================================#
class YGG::Handlers::AIEngines::Guard

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( parent, setup_data={} )
    sd = setup_data
    super( parent, sd )
    setup_area( sd )
    @update_time_cap = (sd["update_time"] || 90).to_i
    @__temprect = []
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup_area
  #--------------------------------------------------------------------------#
  def setup_area( setup_data={} )
    # // area_id (id)
    @prox = setup_data["proxy_area"].to_i == 1
    if !setup_data["area_id"].nil?()
      @guard_area = Rect.new( *$data_areas[setup_data["area_id"].to_i].rect.to_a )
    # // area_x (center), area_y (center), area_range (center, relative side)
    elsif !setup_data["area_range"].nil?()
      ax  = (!setup_data["area_x"].nil?()) ? setup_data["area_x"].to_i : 0
      ay  = (!setup_data["area_y"].nil?()) ? setup_data["area_y"].to_i : 0
      rng = (!setup_data["area_range"].nil?()) ? setup_data["area_range"].to_i : 0
      @guard_area = Rect.new( ax-rng, ay-rng, rng*2, rng*2 )
    # // area_x (left), area_y (left), area_width (left), area_height (left)
    else
      @guard_area = Rect.new(
        (!setup_data["area_x"].nil?()) ? setup_data["area_x"].to_i : 0,
        (!setup_data["area_y"].nil?()) ? setup_data["area_y"].to_i : 0,
        (!setup_data["area_width"].nil?()) ? setup_data["area_width"].to_i : 0,
        (!setup_data["area_height"].nil?()) ? setup_data["area_height"].to_i : 0
      )
    end
    @__guardarea_data ||= {} ; @__guardarea_data.clear()
    @__guardarea_data["proxy_area"]  = setup_data["proxy_area"]
    @__guardarea_data["area_id"]     = setup_data["area_id"]
    @__guardarea_data["area_range"]  = setup_data["area_range"]
    @__guardarea_data["area_x"]      = setup_data["area_x"]
    @__guardarea_data["area_y"]      = setup_data["area_y"]
    @__guardarea_data["area_width"]  = setup_data["area_width"]
    @__guardarea_data["area_height"] = setup_data["area_height"]
  end

  #--------------------------------------------------------------------------#
  # * new-method :reset_area
  #--------------------------------------------------------------------------#
  def reset_area()
    setup_area( @__guardarea_data )
  end

  #--------------------------------------------------------------------------#
  # * new-method :ai_update
  #--------------------------------------------------------------------------#
  def ai_update()
    return if @parent.ygg_battler.nil?()
    @__temprect = @guard_area.to_vector4_a()
    @__temprect[0] += @prox ? @parent.x : 0
    @__temprect[1] += @prox ? @parent.y : 0
    @__temprect[2] += @prox ? @parent.x : 0
    @__temprect[3] += @prox ? @parent.y : 0
    bats = $game_yggdrasil.battlers_range( *@__temprect )
    unless bats.empty?()
      bats -= [@parent]
      unless bats.empty?()
        @parent.balloon_id = 1
        pro = Projectiles::Homing.new( @parent,
          ::YGG::PROJETILE_SETUP["ProjectileTest"].merge(
            { :target => bats[rand(bats.size)] } )
        )
        pro.moveto( @parent.x, @parent.y ) ; pro.set_direction( @parent.direction )
        $game_yggdrasil.add_projectile( pro )
      end
    end
    @update_time = @update_time_cap
  end

end

#==============================================================================#
# ** YGG::Handlers::AIEngines::Wall
#==============================================================================#
class YGG::Handlers::AIEngines::Wall

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( parent, setup_data={} )
    super( parent, setup_data )
    @burn_time = @burn_cap = setup_data["burn_cap"].to_i
    @death_anim = (setup_data["death_anim"] || 0).to_i
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :ai_update
  #--------------------------------------------------------------------------#
  def ai_update()
    return if @parent.ygg_battler.nil?()
    @burn_time = [@burn_time - 1, 0].max
    @parent.ygg_battler.hp -= [Integer(@parent.ygg_battler.maxhp / @burn_cap.to_f), 1].max + [@burn_time, 0].min.abs
    @parent.ygg_engage.engage( 300 )
    if @parent.ygg_battler.dead?()
      @parent.ygg_anims << @death_anim if @death_anim > 0
      $game_map.remove_event( @parent.id )
    end
  end

end

#==============================================================================#
# ** YGG::Handlers::AIEngines::Wall
#==============================================================================#
class YGG::Handlers::AIEngines::ImmortalVarBoss

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( parent, setup_data )
    super( parent, setup_data )
    @hp_var    = setup_data["hp_var"].to_i
    @maxhp_var = setup_data["maxhp_var"].to_i
    @mp_var    = setup_data["mp_var"].nil?() ? nil : setup_data["mp_var"].to_i
    @maxmp_var = setup_data["maxmp_var"].nil?() ? nil : setup_data["maxmp_var"].to_i
    @parent.ygg_invincible = true
    set_variables()
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_variables
  #--------------------------------------------------------------------------#
  def set_variables()
    return if @parent.ygg_battler.nil?()
    $game_variables[@hp_var] = @parent.ygg_battler.hp
    $game_variables[@maxhp_var] = @parent.ygg_battler.maxhp
    $game_variables[@mp_var] = @parent.ygg_battler.mp unless @mp_var.nil?()
    $game_variables[@maxmp_var] = @parent.ygg_battler.maxmp unless @maxmp_var.nil?()
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :ai_update
  #--------------------------------------------------------------------------#
  def ai_update()
    return if @parent.ygg_battler.nil?()
    @parent.ygg_battler.hp = $game_variables[@hp_var]
    $game_variables[@maxhp_var] = @parent.ygg_battler.maxhp
    $game_variables[@mp_var] = @parent.ygg_battler.mp unless @mp_var.nil?()
    $game_variables[@maxmp_var] = @parent.ygg_battler.maxmp unless @maxmp_var.nil?()
  end

end

# // (YGG_Projectiles)
Projectiles = YGG::Objects::Projectiles
#==============================================================================#
# ** YGG::Objects::Projectiles::Base
#==============================================================================#
class YGG::Objects::Projectiles::Base < ::Game_Character

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :character_name
  attr_accessor :character_index

  attr_accessor :through
  attr_accessor :action_name
  attr_accessor :direction
  attr_accessor :detonate_cap
  attr_accessor :move_cap
  attr_accessor :target_type

  attr_accessor :registered
  attr_accessor :action

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( parent, assignments )
    @parent          = parent
    super()
    # // Main Properties
    @character_name  = assignments[:character_name] || ""
    @character_index = (assignments[:character_index] || 0).to_i
    @through         = assignments[:through].nil?() ? true : assignments[:through]
    @move_speed      = (assignments[:move_speed] || 5).to_i

    # // Projectile Properties
    @detonate_cap    = (assignments[:detonate_cap] || -1).to_i
    @move_cap        = (assignments[:move_cap] || 5).to_i
    @target_type     = assignments[:target_type] || ""

    @terminated      = false
    @detonate_count  = 0
    @move_count      = 0

    @action_name     = assignments[:action_name] || ""
    @action          = assignments[:action] || ::YGG.get_action_list( @action_name )

    @affect_passage  = assignments[:affect_passage].nil?() ? false : assignments[:affect_passage]

    @registered      = false

    #assignments.keys.each { |key| self.send( key.to_s+"=", assignments[key] ) }
  end

  #--------------------------------------------------------------------------#
  # * new-method :trigger
  #--------------------------------------------------------------------------#
  def trigger() ; return nil ; end

  #--------------------------------------------------------------------------#
  # * new-method :hp_visible?
  #--------------------------------------------------------------------------#
  def hp_visible?() ; return false ; end

  #--------------------------------------------------------------------------#
  # * new-method :mp_visible?
  #--------------------------------------------------------------------------#
  def mp_visible?() ; return false ; end

  #--------------------------------------------------------------------------#
  # * new-method :__reload
  #--------------------------------------------------------------------------#
  def __reload()
    if registered?()
      pro_unregister() ; pro_register()
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :registered?
  #--------------------------------------------------------------------------#
  def registered?()
    return @registered
  end

  #--------------------------------------------------------------------------#
  # * new-method :pro_register
  #--------------------------------------------------------------------------#
  def pro_register()
    @registered = true ; $game_yggdrasil.add_passage_obj( self ) if @affect_passage
  end

  #--------------------------------------------------------------------------#
  # * new-method :pro_unregister
  #--------------------------------------------------------------------------#
  def pro_unregister()
    @registered = false ; $game_yggdrasil.remove_passage_obj( self )
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_register
  #--------------------------------------------------------------------------#
  def ygg_register()
    @ygg_registered = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_unregister
  #--------------------------------------------------------------------------#
  def ygg_unregister()
    $game_yggdrasil.remove_battler( self )
    @ygg_registered = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_attacker
  #--------------------------------------------------------------------------#
  def ygg_attacker()
    return @parent.ygg_attacker
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_boss
  #--------------------------------------------------------------------------#
  def ygg_boss?() ; return false ; end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_ally?
  #--------------------------------------------------------------------------#
  def ygg_ally?()
    return @parent.ygg_ally?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_enemy?
  #--------------------------------------------------------------------------#
  def ygg_enemy?()
    return @parent.ygg_enemy?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :passable?
  #--------------------------------------------------------------------------#
  def passable?( x, y )
    x = $game_map.round_x(x)
    y = $game_map.round_y(y)
    return false unless $game_map.valid?(x, y)
    return true if @through or debug_through?
    return false unless map_passable?( x, y )
    return true
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :check_event_trigger_touch
  #--------------------------------------------------------------------------#
  def check_event_trigger_touch( *args, &block ) ; end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
  def update()
    update_projectile() unless @wait_count > 0
    super()
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update_states
  #--------------------------------------------------------------------------#
  def update_states() ; end

  #--------------------------------------------------------------------------#
  # * overwrite-method :move_speed
  #--------------------------------------------------------------------------#
  def move_speed() ; return @move_speed ; end

  #--------------------------------------------------------------------------#
  # * new-method :update_projectile
  #--------------------------------------------------------------------------#
  def update_projectile()
    process_move() if can_move?()
    process_detonate() if can_detonate?()
    process_terminate() if can_terminate?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :actual_*x/y
  #--------------------------------------------------------------------------#
  def actual_x() ; return @real_x / 256 ; end
  def actual_y() ; return @real_y / 256 ; end

  #--------------------------------------------------------------------------#
  # * new-method :pos?
  #--------------------------------------------------------------------------#
  def pos?( x, y )
    return (actual_x == x && actual_y == y)
  end

  #--------------------------------------------------------------------------#
  # * new-method :target_xy?
  #--------------------------------------------------------------------------#
  def target_xy?( x, y )
    return !ygg_get_targets( x, y, ygg_correct_target( @target_type ), true ).empty?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :terminated?
  #--------------------------------------------------------------------------#
  def terminated?()
    return @terminated
  end

  #--------------------------------------------------------------------------#
  # * new-method :can_move?
  #--------------------------------------------------------------------------#
  def can_move?()
    return false if self.terminated?()
    return false if jumping?()
    return false if moving?()
    return false if (@move_cap > 0 && @move_count >= @move_cap)
    return true
  end

  #--------------------------------------------------------------------------#
  # * new-method :can_detonate?
  #--------------------------------------------------------------------------#
  def can_detonate?()
    return false if self.terminated?()
    return false if (@detonate_cap > 0 && @detonate_count >= @detonate_cap)
    return target_xy?( self.actual_x, self.actual_y )
  end

  #--------------------------------------------------------------------------#
  # * new-method :can_terminate?
  #--------------------------------------------------------------------------#
  def can_terminate?()
    return false if self.terminated?()
    return true if (@detonate_cap > 0 && @detonate_count >= @detonate_cap )
    return (@move_cap > 0 && @move_count >= @move_cap && !moving?())
  end

  #--------------------------------------------------------------------------#
  # * new-method :process_move
  #--------------------------------------------------------------------------#
  def process_move()
    @move_count += 1
  end

  #--------------------------------------------------------------------------#
  # * new-method :process_detonate
  #--------------------------------------------------------------------------#
  def process_detonate()
    @detonate_count += 1
    @action_handle.setup( @action )
    @action_handle.execute( self )
  end

  #--------------------------------------------------------------------------#
  # * new-method :process_terminate
  #--------------------------------------------------------------------------#
  def process_terminate()
    @terminated = true ; ygg_unregister()
  end

  #--------------------------------------------------------------------------#
  # * new-method :force_terminate
  #--------------------------------------------------------------------------#
  def force_terminate()
    @terminated = true
  end

end

#==============================================================================#
# ** YGG::Objects::Projectiles::Linear
#==============================================================================#
class YGG::Objects::Projectiles::Linear < ::YGG::Objects::Projectiles::Base

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( parent, assignments )
    super( parent, assignments )
  end

  #--------------------------------------------------------------------------#
  # * super-method :process_move
  #--------------------------------------------------------------------------#
  def process_move()
    move_forward()
    super()
  end

end

#==============================================================================#
# ** YGG::Objects::Projectiles::Hopping
#==============================================================================#
class YGG::Objects::Projectiles::Hopping < ::YGG::Objects::Projectiles::Base

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :jump_amount

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( parent, assignments )
    @jump_amount = (assignments[:jump_amount] || 1).to_i
    super( parent, assignments )
  end

  #--------------------------------------------------------------------------#
  # * super-method :process_move
  #--------------------------------------------------------------------------#
  def process_move()
    jump_forward( @jump_amount, 0 )
    super()
  end

end

#==============================================================================#
# ** YGG::Objects::Projectiles::Homing
#==============================================================================#
class YGG::Objects::Projectiles::Homing < ::YGG::Objects::Projectiles::Base

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :target
  attr_accessor :homing_range

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( parent, assignments )
    @homing_range = (assignments[:homing_range] || 5).to_i
    @target = assignments[:target]
    super( parent, assignments )
    set_target() if @target.nil?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :target_xy?
  #--------------------------------------------------------------------------#
  def target_xy?( x, y )
    self.pos?( @target.x, @target.y )
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_target
  #--------------------------------------------------------------------------#
  def set_target()
    @target = get_targets_nearby( @homing_range, ygg_correct_target( @target_type ) )[0]
  end

  #--------------------------------------------------------------------------#
  # * new-method :target_oor? # // target_out_of_range?
  #--------------------------------------------------------------------------#
  def target_oor?()
    return @homing_range == -1 ? false : (@target.distance_from( self ) > @homing_range)
  end

  #--------------------------------------------------------------------------#
  # * super-method :process_move
  #--------------------------------------------------------------------------#
  def process_move()
    move_toward_char( @target )
    super()
  end

  #--------------------------------------------------------------------------#
  # * super-method :can_terminate?
  #--------------------------------------------------------------------------#
  def can_terminate?()
    return true if target_oor?()
    super()
  end

end

#==============================================================================#
# ** YGG::Objects::Projectiles::Bomb
#==============================================================================#
class YGG::Objects::Projectiles::Bomb < ::YGG::Objects::Projectiles::Base

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :time

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( parent, assignments )
    @time = (assignments[:time] || 60).to_i
    super( parent, assignments )
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :target_xy?
  #--------------------------------------------------------------------------#
  def target_xy?( x, y )
    return true
  end

  #--------------------------------------------------------------------------#
  # * super-method :update_projectile
  #--------------------------------------------------------------------------#
  def update_projectile()
    @time = [@time-1, 0].max
    super()
  end

  #--------------------------------------------------------------------------#
  # * super-method :can_detonate?
  #--------------------------------------------------------------------------#
  def can_detonate?()
    return false unless super()
    return true if @time == 0
    return false
  end

end

#==============================================================================#
# ** YGG::Objects::Projectiles::GhostBullet
#==============================================================================#
class YGG::Objects::Projectiles::GhostBullet < ::YGG::Objects::Projectiles::Base

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( parent, assignments )
    super( parent, assignments )
  end

end

#==============================================================================#
# ** YGG::Objects::Projectiles::ActionPilot
#==============================================================================#
class YGG::Objects::Projectiles::ActionPilot < ::YGG::Objects::Projectiles::Base

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :pilot_list

  #--------------------------------------------------------------------------#
  # * super-method :update_projectile
  #--------------------------------------------------------------------------#
  def initialize( parent, assignments )
    @pilot_list = assignments[:pilot_list] || []
    super( parent, assignments )
    @pilot_index = 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_projectile
  #--------------------------------------------------------------------------#
  def update_projectile()
    @sleep_count = [@sleep_count - 1, 0].max
    return unless @sleep_count == 0
    while @pilot_index < @pilot_list.size
      act_set     = @pilot_list[@pilot_index]
      @action     = act_set[0]
      @parameters = act_set[1]
      for i in 0...@parameters.size() ; @parameters[i] = @parameters[i].to_s() ; end
      act_result = -1
      case @action.upcase()
      when "MOVE"
        act_result = pilot_move( @action, @parameters )
      when "DETONATE"
        act_result = pilot_detonate( @action, @parameters )
      when "TERMINATE"
        act_result = pilot_terminate( @action, @parameters )
      when "SEND"
        act_result = pilot_send( @action, @parameters )
      when "SLEEP"
        act_result = pilot_sleep( @action, @parameters )
      when "SCRIPT"
        act_result = pilot_script( @action, @parameters )
      when "WAIT"
        act_result = pilot_wait( @action, @parameters )
      end
      if act_result == -1
        puts "ERROR: -1 returned for pilot action #{self}"
      else
        puts "BING: #{act_result} returned for pilot action #{self}"
      end if YGG.debug_mode?
      @pilot_index += 1
      break if act_result == 1
    end
    return
  end

  #--------------------------------------------------------------------------#
  # * new-method :pilot_move
  #--------------------------------------------------------------------------#
  def pilot_move( action, parameters )
    character = self
    case parameters[0].upcase
    when "FORWARD"
      character.move_forward()
    when "BACKWARD"
      character.move_backward()
    when "UP"
      character.move_up()
    when "DOWN"
      character.move_down()
    when "LEFT"
      character.move_left()
    when "RIGHT"
      character.move_right()
    when "TURNUP", "TURN_UP", "TURN UP"
      character.turn_up()
    when "TURNDOWN", "TURN_DOWN", "TURN DOWN"
      character.turn_down()
    when "TURNLEFT", "TURN_LEFT", "TURN LEFT"
      character.turn_left()
    when "TURNRIGHT", "TURN_RIGHT", "TURN RIGHT"
      character.turn_right()
    when "TURNRIGHT90", "TURN_RIGHT_90", "TURN RIGHT 90"
      character.turn_right_90()
    when "TURNLEFT90", "TURN_LEFT_90", "TURN LEFT 90"
      character.turn_left_90()
    when "TURN180", "TURN_180", "TURN 180"
      character.turn_180()
    when "TURNTO", "TURN_TO", "TURN TO"
      target = nil
      character.turn_to_coord( target.x, target.y ) unless target.nil?()
    end
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :pilot_send
  #--------------------------------------------------------------------------#
  def pilot_send( action, parameters )
    case parameters[0]
    when "ONLY"
      self.send( parameters[1] )
    when "SET"
      self.send( parameters[1], *parameters.slice( 2, parameters.size ) )
    end
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :pilot_detonate
  #--------------------------------------------------------------------------#
  def pilot_detonate( action, parameters )
    process_detonate()
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :pilot_terminate
  #--------------------------------------------------------------------------#
  def pilot_terminate( action, parameters )
    process_terminate()
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :pilot_terminate
  #--------------------------------------------------------------------------#
  def pilot_script( action, parameters )
    eval( parameters.to_s )
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :pilot_sleep
  #--------------------------------------------------------------------------#
  def pilot_sleep( action, parameters )
    @sleep_count = parameters[0].to_i
    return 1
  end

  #--------------------------------------------------------------------------#
  # * new-method :pilot_wait
  #--------------------------------------------------------------------------#
  def pilot_wait( action, parameters )
    @wait_count = parameters[0].to_i
    return 0
  end

end

#==============================================================================#
# ** YGG
#==============================================================================#
module YGG

  PROJECTILE_MAP = {
    "linear"  => YGG::Objects::Projectiles::Linear,
    "hopping" => YGG::Objects::Projectiles::Hopping,
    "homing"  => YGG::Objects::Projectiles::Homing,
    "bomb"    => YGG::Objects::Projectiles::Bomb,
    "ghost"   => YGG::Objects::Projectiles::GhostBullet,
    "action"  => YGG::Objects::Projectiles::ActionPilot,
  }

  PROJETILE_SETUP = {}

end

#==============================================================================#
# ** YGG::Handlers::Equip
#==============================================================================#
class YGG::Handlers::Equip < YGG::Pos

  #--------------------------------------------------------------------------#
  # * Class Method(s)
  #--------------------------------------------------------------------------#

  #--------------------------------------------------------------------------#
  # * new-method :angle_change_list
  #--------------------------------------------------------------------------#
  def self.angle_change_list( start, add_target, wait, maxspeed=1, shorten=0 )
    result = []
    target = start + add_target
    rate = add_target.to_f / wait.to_f ; accel = 0
    ang = start
    (wait-shorten).times { |i|
      accel = maxspeed.to_f * i.to_f / wait.to_f
      if ang < target
        ang += rate.abs
        ang += accel ; ang = [ang, target].min
      elsif ang > target
        ang -= rate.abs
        ang -= accel ; ang = [ang, target].max
      else ; ang = target
      end
      result += [["CHANGE ANGLE", (ang)%360], ["WAIT", 1]]
    }
    return result
  end

  #--------------------------------------------------------------------------#
  # * new-method :move_to_list
  #--------------------------------------------------------------------------#
  def self.move_to_list( start, add_target, wait, axis, maxspeed=1, shorten=0 )
    result = []
    target = start + add_target
    rate = add_target.to_f / wait.to_f ; accel = 0
    pos = start
    (wait-shorten).times { |i|
      accel = maxspeed.to_f * i.to_f / wait.to_f
      if pos < target
        pos += rate.abs
        pos += accel ; pos = [pos, target].min
      elsif pos > target
        pos -= rate.abs
        pos -= accel ; pos = [pos, target].max
      else ; pos = target
      end
      result += [["MOVE", axis.upcase, pos], ["WAIT", 1]]
    }
    return result
  end

  #--------------------------------------------------------------------------#
  # * new-method :alternate_mix
  #--------------------------------------------------------------------------#
  def self.alternate_mix( *args )
    aresult = [] ; sizes = args.inject([]) { |result, array| result << array.size }
    sizes.max.times { |i| args.each { |array| aresult << array[i] unless array[i].nil?() } }
    return aresult
  end

  #--------------------------------------------------------------------------#
  # * Constant(s)
  #--------------------------------------------------------------------------#
  ACTIONS = {}
  # // Swing
  t  = 0
  at = 78
  ACTIONS["Swing1"]  = [["RESET"], ["SHOW"]]
  ACTIONS["Swing1"] += angle_change_list( t, at, 12 )
  ACTIONS["Swing1"] += [["HIDE"]]
  # // Swing + Return Swing
  ACTIONS["Swing2"]  = [["RESET"], ["SHOW"]]
  ACTIONS["Swing2"] += angle_change_list( t, at, 11, 24, 2 )
  ACTIONS["Swing2"] += angle_change_list( t+at, t-at, 11, 24, 2 )
  ACTIONS["Swing2"] += [["HIDE"]]
  # // Swing + Pull
  ACTIONS["Swing3"]  = [["RESET"], ["SHOW"]]
  ACTIONS["Swing3"] += angle_change_list( t, at, 11, 24, 2 )
  ACTIONS["Swing3"] += move_to_list( 0, -14, 8, "Y" )
  ACTIONS["Swing3"] += [["HIDE"]]

  # // Stab
  ACTIONS["Stab1"]   = [["RESET"], ["SHOW"]]
  ACTIONS["Stab1"]  += [["CHANGE ANGLE", 40]]
  ACTIONS["Stab1"]  += [["MOVE", "X", -5]]
  ACTIONS["Stab1"]  += move_to_list( 0,  -4, 5, "Y" )
  ACTIONS["Stab1"]  += move_to_list( -4, 8, 8, "Y" )
  ACTIONS["Stab1"]  += [["HIDE"]]

  ACTIONS["GRise1"] = [["RESET"], ["SHOW"]]
  ACTIONS["GRise1"] += move_to_list( 0, -8, 8, "Y" )
  ACTIONS["GRise1"] += [["WAIT FOR GUARD"]]
  ACTIONS["GRise1"] += move_to_list( 0, 8, 8, "Y" )
  ACTIONS["GRise1"] += [["HIDE"]]

end

#==============================================================================#
# ** YGG
#==============================================================================#
module YGG

  module_function()

  #--------------------------------------------------------------------------#
  # * new-method :silent_error?
  #--------------------------------------------------------------------------#
  def silent_error?() ; return false ; end
  def debug_mode?()   ; return false ; end

  #--------------------------------------------------------------------------#
  # * new-method :get_action_list
  #--------------------------------------------------------------------------#
  def get_action_list( action_name )
    unless YGG::ACTION_LIST.has_key?( action_name )
      return [] if silent_error?() # // Silent Error
      raise "Action List #{action_name} does not exist"
      exit
    end
    return ACTION_LIST[action_name]
  end

  # // User Functions

  #--------------------------------------------------------------------------#
  # * new-method :create_range_data
  #--------------------------------------------------------------------------#
  # If the range was done before, it is simply reloaded
  # rng    - Maximum Range
  # minrng - Minimum Range
  # type:
  #   0 - Diamond   < >
  #   1 - Cross      +
  #   2 - X          x
  #   3 - Breath     <
  #   4 - SnowFlake  *
  #   5 - Block     [ ]
  #   6 - Linear    ->
  # direction:
  #   2 - Down
  #   4 - Left
  #   6 - Right
  #   8 - Up
  #--------------------------------------------------------------------------#
  def create_range_data( rng, minrng=0, type=0, direction=2 )
    return Handlers::Range.createRange( rng, minrng, type, direction )
  end

  #--------------------------------------------------------------------------#
  # * new-method :offset_xy_list
  #--------------------------------------------------------------------------#
  def offset_xy_list( ox, oy, xy_list, direction=2 )
    return xy_list.inject([]) { |result, coords|
      result.push( offset_xy( ox, oy, coords, direction ) ) }
  end

  #--------------------------------------------------------------------------#
  # * new-method :offset_xy
  #--------------------------------------------------------------------------#
  def offset_xy( ox, oy, coords, direction=2 )
    result = []
    case direction
    when 2
      result = [ ox + coords[0], oy + coords[1] ]
    when 4
      result = [ ox - coords[1], oy - coords[0] ]
    when 6
      result = [ ox + coords[1], oy + coords[0] ]
    when 8
      result = [ ox - coords[0], oy - coords[1] ]
    end
    return result
  end

  #--------------------------------------------------------------------------#
  # * new-method :parse_event_list
  #--------------------------------------------------------------------------#
  def parse_event_list( list )
    return list
    # // Skip Parsing
    final_list = []
    list.each { |command|
      new_command = command.clone
      if [108, 408].include?( command.code )
        new_command = RPG::EventCommand.new
        new_command.indent = command.indent
        case command.parameters.to_s.upcase
        when "DETONATE"
          new_command.code = 1000
        end
      end
      final_list << new_command
    }
    return final_list
  end

#==============================================================================#
# // Main Classes
#==============================================================================#
# ** Pos
#==============================================================================#
  class Pos

    #--------------------------------------------------------------------------#
    # * Public Instance Variable(s)
    #--------------------------------------------------------------------------#
    attr_accessor :x, :y, :z # // X, Y, Z

    #--------------------------------------------------------------------------#
    # * new-method :initialize
    #--------------------------------------------------------------------------#
    def initialize( x, y, z=0 ) ; set( x, y, z ) end

    #--------------------------------------------------------------------------#
    # * new-method :set
    #--------------------------------------------------------------------------#
    def set( x, y, z=@z ) ; @x = x ; @y = y ; @z = z ; end

    #--------------------------------------------------------------------------#
    # * super-method :==
    #--------------------------------------------------------------------------#
    def ==( obj )
      return ( @x == obj.x &&
        @y == obj.y &&
        @z == obj.z ) if obj.kind_of?( self.class )
      return super( obj )
    end

  end

#==============================================================================#
# ** YGG::Handlers::Screen
#==============================================================================#
  class Handlers::Screen < Pos

    #--------------------------------------------------------------------------#
    # * Public Instance Variable(s)
    #--------------------------------------------------------------------------#
    attr_accessor :real_x, :real_y

    #--------------------------------------------------------------------------#
    # * super-method :initialize
    #--------------------------------------------------------------------------#
    def initialize( x, y, z=200 ) ; super( x, y, z ) ; moveto( x, y, z ) ; end

    #--------------------------------------------------------------------------#
    # * new-method :moveto
    #--------------------------------------------------------------------------#
    def moveto( x, y, z=@z )
      set( x % $game_map.width, y % $game_map.height, z )
      @real_x = @x * 256 ; @real_y = @y * 256
    end

    #--------------------------------------------------------------------------#
    # * new-method :screen_x
    #--------------------------------------------------------------------------#
    def screen_x()
      return ($game_map.adjust_x(@real_x) + 8007) / 8 - 1000 + 16
    end

    #--------------------------------------------------------------------------#
    # * new-method :screen_y
    #--------------------------------------------------------------------------#
    def screen_y()
      return ($game_map.adjust_y(@real_y) + 8007) / 8 - 1000 + 32
    end

    #--------------------------------------------------------------------------#
    # * new-method :screen_z
    #--------------------------------------------------------------------------#
    def screen_z() ; return @z ; end

  end

#==============================================================================#
# ** Handlers::CharPos
#==============================================================================#
  class Handlers::CharPos < Handlers::Screen

    #--------------------------------------------------------------------------#
    # * Public Instance Variable(s)
    #--------------------------------------------------------------------------#
    attr_accessor :fade_amount
    attr_accessor :fade_max

    #--------------------------------------------------------------------------#
    # * super-method :initialize
    #--------------------------------------------------------------------------#
    def initialize( x=0, y=0, z=0, fade_out=0, fade_amt=0 )
      super( x, y, z )
      @fade_out    = fade_out
      @fade_amount = @fade_max = fade_amt
    end

    #--------------------------------------------------------------------------#
    # * new-method :fader_type
    #--------------------------------------------------------------------------#
    def fader_type() ; return @fade_out ; end

    #--------------------------------------------------------------------------#
    # * new-method :setup_pos
    #--------------------------------------------------------------------------#
    def setup_pos( x, y ) ; moveto( @x, @y ) ; end

  end

#==============================================================================#
# ** Handlers::Range
#==============================================================================#
  class Handlers::Range

    #--------------------------------------------------------------------------#
    # * Class Variable
    #--------------------------------------------------------------------------#
    @@_recorded_ranges = { }

    #--------------------------------------------------------------------------#
    # * class-method :createRange
    #--------------------------------------------------------------------------#
    def self.createRange( rng, minrng=0, type=0, direction=2 )
      datarray = [ rng, minrng, type, direction ]
      unless @@_recorded_ranges.has_key?( datarray )
        result   = []
        case type
        when 0 # // Normal - Diamond <>
          for x in 0..rng
            for y in 0..rng
              next if x+y > rng
              next if x+y < minrng
              result << [ x,  y] ; result << [-x,  y]
              result << [ x, -y] ; result << [-x, -y]
            end
          end
        when 1 # // Cross +
          for x in 0..rng
            for y in 0..rng
              next if x+y > rng
              next if x+y < minrng
              result << [ x,  0] ; result << [-x,  0]
              result << [ 0, -y] ; result << [ 0,  y]
            end
          end
        when 2 # // X - x
          for x in 0..rng
            for y in 0..rng
              next if x+y > rng
              next if x+y < minrng
              result << [ x,  x] ; result << [-x, -x]
              result << [-y,  y] ; result << [ y, -y]
            end
          end
        when 3 # // Breath <
          for x in 0..rng
            for y in 0..rng
              next if x+y > rng
              next if x+y < minrng
              case direction
              when 2 ; result << [ x,  y] ; result << [-x,  y]
              when 4 ; result << [-x,  y] ; result << [-x, -y]
              when 6 ; result << [ x,  y] ; result << [ x, -y]
              when 8 ; result << [ x, -y] ; result << [-x, -y]
              end
            end
          end
        when 4 # // Snow Flake *
          for x in 0..rng
            next if x < minrng
            result << [ 0,  x] ; result << [ x,  0]
            result << [ 0, -x] ; result << [-x,  0]
            result << [ x,  x] ; result << [-x,  x]
            result << [ x, -x] ; result << [-x, -x]
          end
        when 5 # // Block []
          for x in 0..rng
            for y in 0..rng
              next if x < minrng && y < minrng
              result << [ x,  y] ; result << [-x,  y]
              result << [ x, -y] ; result << [-x, -y]
            end
          end
        when 6 # // Linear <-
          for x in 0..rng
            for y in 0..rng
              next if x+y > rng
              next if x+y < minrng
              case direction
              when 2 ; result << [ 0,  y]
              when 4 ; result << [-x,  0]
              when 6 ; result << [ x,  0]
              when 8 ; result << [ 0, -y]
              end
            end
          end
        end
        @@_recorded_ranges[datarray] = result.compact.uniq
      end
      return @@_recorded_ranges[datarray]
    end

  end

#==============================================================================#
# // YGG Construction
#==============================================================================#
# ** REGEXP
#==============================================================================#
  module REGEXP
#==============================================================================#
# ** EVENT
#==============================================================================#
    module EVENT
      # Event Tags
      ABS_ALLY         = /<(?:ABS_ALLY|abs ally):[ ]*(\d+)>/i
      ABS_ENEMY        = /<(?:ABS_ENEMY|abs enemy):[ ]*(\d+)>/i
      ABS_SET_AS_ALLY  = /<(?:SET_AS_ALLY|SET AS ALLY)>/i
      ABS_SET_AS_ENEMY = /<(?:SET_AS_ENEMY|SET AS ENEMY)>/i
      ABS_BOSS         = /<(?:ABS_BOSS|abs boss)>/i
      SELF_SWITCH      = /<(?:DEAD_SELF_SWITCH|dead self switch):[ ]*(\w+)>/i
      SWITCH           = /<(?:DEAD_SWITCH|dead switch):[ ]*(\d+)[ ]*,[ ]*(\w+)>/i
      NO_FADE_DEATH    = /<(?:NO_FADE_DEATH|no fade death)>/i
      INSTANT_DEATH    = /<(?:INSTANT_DEATH|instant death)>/i
      DEATH_ANIM       = /<(?:DEATH_ANIMATION_ID|death animation id|death anim|DEATH_ANIM):[ ]*(\d+)>/i
      INVINCIBLE       = /<(?:INVINCIBLE|IMMORTAL)>/i

      AI_ENGINE1       = /<(?:AI_ENGINE|AI ENGINE):[ ](.*)>/i
      AI_ENGINE2       = /<\/(?:AI_ENGINE|AI ENGINE)>/i
      ENABLE_POP       = /<(?:ENABLE_POP|ENABLE POP|ENABLEPOP)>/i
      DISABLE_POP      = /<(?:DISABLE_POP|DISABLE POP|DISABLEPOP|NO POP|NO_POP|NOPOP)>/i
      SHOW_HP_BAR      = /<(?:SHOW_HP_BAR|SHOW HP BAR|SHOWHPBAR)>/i
      HIDE_HP_BAR      = /<(?:HIDE_HP_BAR|HIDE HP BAR|HIDEHPBAR)>/i
      SHOW_MP_BAR      = /<(?:SHOW_MP_BAR|SHOW MP BAR|SHOWMPBAR)>/i
      HIDE_MP_BAR      = /<(?:HIDE_MP_BAR|HIDE MP BAR|HIDEMPBAR)>/i

      ONDEATH1         = /<(?:ON_DEATH|ON DEATH|ONDEATH):[ ](.*)>/i
      ONDEATH2         = /<\/(?:ON_DEATH|ON DEATH|ONDEATH)>/i
    end # // EVENT
#==============================================================================#
# ** BASE_ITEM
#==============================================================================#
    module BASE_ITEM
      # Equipment Tags
      ACTION_OPEN   = /<ACTION[ ]*(\d+)>/i
      ACTION_CLOSE  = /<\/ACTION>/i
      ACTION_ASSIGN = /<ACTION[ ]*(\d+)[ ]*\=[ ]*(.*)>/i

      PREACTION_OPEN   = /<PREACTION[ ]*(\d+)>/i
      PREACTION_CLOSE  = /<\/PREACTION>/i
      PREACTION_ASSIGN = /<PREACTION[ ]*(\d+)[ ]*\=[ ]*(.*)>/i

      ACTION_6      = /(.*):[ ](.*),[ ](.*),[ ](.*),[ ](.*),[ ](.*),[ ](.*)/i
      ACTION_5      = /(.*):[ ](.*),[ ](.*),[ ](.*),[ ](.*),[ ](.*)/i
      ACTION_4      = /(.*):[ ](.*),[ ](.*),[ ](.*),[ ](.*)/i
      ACTION_3      = /(.*):[ ](.*),[ ](.*),[ ](.*)/i
      ACTION_2      = /(.*):[ ](.*),[ ](.*)/i
      ACTION_1      = /(.*):[ ](.*)/i

      DROPS_ATTRACT = /<(?:ATTRACT_DROP|attract drop)s?>/i

      CHARGE_CAP    = /<(?:CHARGE_CAP|CHARGE CAP|COOLDOWN):[ ]*(\d+)>/i
    USER_CHARGE_CAP = /<(?:USER_CHARGE_CAP|USER CHARGE CAP|USER_COOLDOWN|USER COOLDOWN):[ ]*(\d+)>/i

      CANT_EQUIP    = /<(?:CANT_EQUIP_SLOT|CANT EQUIP SLOT)>/i

      PICKUP_SFX    = /<(?:PICKUP_SFX|PICKUP SFX|PKSFX):[ ](.*),[ ](\d+),[ ](\d+)>/i
    end
#==============================================================================#
# ** SKILL
#==============================================================================#
    module SKILL
      UTARGET_SELECT= /<(?:USE_TARGET_SELECT|USE TARGET SELECT)>/i
      GUARDABLE     = /<(?:GUARDABLE)>/i
      NOT_GUARDABLE = /<(?:NOT_GUARDABLE|NOT GUARDABLE|NOTGUARDABLE)>/i
    end # // BASE_ITEM
#==============================================================================#
# ** STATE
#==============================================================================#
    module STATE
      HOLD_TICKS = /<(?:HOLDTICKS|HOLD_TICKS|HOLD TICKS):[ ](\d+)>/i
      TONE       = /<TONE:[ ]([\+\-]?\d+),[ ]*([\+\-]?\d+),[ ]*([\+\-]?\d+),[ ]*(\d+)>/i
      MOVE_MOD   = /<(?:MOVEMOD|MOVE_MOD|MOVE MOD):[ ]([\+\-]\d+)>/i
      SLIP_FREQ  = /<(?:SLIPFREQ|SLIP_FREQ|SLIP FREQ):[ ](\d+)>/i
    end # // STATE
#==============================================================================#
# ** ENEMY
#==============================================================================#
    module ENEMY
      ATK_ANIMATION_ID = /<(?:ATK_ANIMATION_ID|ATK ANIMATION ID):[ ](\d+)>/i
      DROP_ITEM1       = /<(?:DROP_ITEM|DROP ITEM|DROPITEM)[ ](\d+)>/i
      DROP_ITEM2       = /<\/(?:DROP_ITEM|DROP ITEM|DROPITEM)>/i
      DROP_CLEAR       = /<(?:DROPS_CLEAR|DROPS CLEAR|DROPSCLEAR)>/i
      GOLD_VARI        = /<(?:GOLD_VARIATION|GOLD VARIATION):[ ](\d+)>/i
      EQUIP_ICONS      = /<(?:EQUIP_ICON|EQUIP ICON|EQUIPICON)s?[ ](\d+):[ ](.*)>/i
      USE_EQUIPMENT    = /<(?:USE_EQUIPMENT|USE EQUIPMENT|USEEQUIPMENT)>/i
      NO_EQUIPMENT     = /<(?:NO_EQUIPMENT|NO EQUIPMENT|NOEQUIPMENT)>/i
    end
  end # // REGEXP
end # // YGG

#==============================================================================#
# ** Vocab
#==============================================================================#
module Vocab

  #--------------------------------------------------------------------------#
  # * new-method :maxhp
  #--------------------------------------------------------------------------#
  def self.maxhp ; return self.hp ; end

  #--------------------------------------------------------------------------#
  # * new-method :maxmp
  #--------------------------------------------------------------------------#
  def self.maxmp ; return self.mp ; end

end

#==============================================================================#
# ** Array
#==============================================================================#
class Array

  #--------------------------------------------------------------------------#
  # * new-method :rotate
  #--------------------------------------------------------------------------#
  def rotate( n=1 ) ; dup.rotate!( n ) ; end unless method_defined? :rotate

  #--------------------------------------------------------------------------#
  # * new-method :rotate!
  #--------------------------------------------------------------------------#
  def rotate!( n=1 )
    return self if empty?
    n %= size
    concat( slice!( 0, n ) )
  end unless method_defined? :rotate!

end

#==============================================================================#
# ** Rect
#==============================================================================#
class Rect

  #--------------------------------------------------------------------------#
  # * new-method :to_a
  #--------------------------------------------------------------------------#
  def to_a() ; return self.x, self.y, self.width, self.height ; end

  #--------------------------------------------------------------------------#
  # * new-method :to_vector4_a
  #--------------------------------------------------------------------------#
  def to_vector4_a()
    return self.x, self.y, self.x + self.width, self.y + self.height
  end

end

#==============================================================================#
# ** YGG
#==============================================================================#
module YGG

  #--------------------------------------------------------------------------#
  # * new-method :get_action_from_line
  #--------------------------------------------------------------------------#
  def self.get_action_from_line( line )
    case line
    # // Exception
    when /SCRIPT:[ ](.*)/i
      result = [ "SCRIPT", [$1]               ]
    # // Regular Actions
    when ::YGG::REGEXP::BASE_ITEM::ACTION_6
      result = [ $1, [$2, $3, $4, $5, $6, $7] ]
    when ::YGG::REGEXP::BASE_ITEM::ACTION_5
      result = [ $1, [$2, $3, $4, $5, $6]     ]
    when ::YGG::REGEXP::BASE_ITEM::ACTION_4
      result = [ $1, [$2, $3, $4, $5]         ]
    when ::YGG::REGEXP::BASE_ITEM::ACTION_3
      result = [ $1, [$2, $3, $4]             ]
    when ::YGG::REGEXP::BASE_ITEM::ACTION_2
      result = [ $1, [$2, $3]                 ]
    when ::YGG::REGEXP::BASE_ITEM::ACTION_1
      result = [ $1, [$2]                     ]
    else
      result = [ line, []                     ]
    end # // case line
    return result
  end

end

#==============================================================================#
# ** YGG::Caches1x6
#==============================================================================#
module YGG::Caches1x6

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :ygg_actions, :ygg_pre_actions
  attr_accessor :ygg_target_range
  attr_accessor :drops_attraction
  attr_accessor :atk_act_name, :grd_act_name
  attr_accessor :charge_cap
  attr_accessor :user_charge_cap
  attr_accessor :cant_equip_slot

  #--------------------------------------------------------------------------#
  # * new-method :ygg_add_to_cache
  #--------------------------------------------------------------------------#
  def ygg_add_to_cache( array )
    unless @__pre_action
      @ygg_actions[@__current_action].push( array )
    else
      @ygg_pre_actions[@__current_action].push( array )
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :yggdrasil_1x6_cache
  #--------------------------------------------------------------------------#
  def yggdrasil_1x6_cache()
    yggdrasil_1x6_cache_start()
    self.note.split(/[\r\n]+/).each { |line| yggdrasil_1x6_cache_check( line ) }
    yggdrasil_1x6_cache_end()
  end

  #--------------------------------------------------------------------------#
  # * new-method :yggdrasil_1x6_cache_start
  #--------------------------------------------------------------------------#
  def yggdrasil_1x6_cache_start()
    @charge_cap      = 0
    @user_charge_cap = 0
    @atk_act_name    = ""
    @grd_act_name    = ""
    case self
    when RPG::Item
      # // Yeah ....
    when RPG::Weapon
      @atk_act_name = "Swing1"
    when RPG::Armor
      @grd_act_name = "GRise1"
    end
    @ygg_actions      = {}
    @ygg_pre_actions  = {}
    @ygg_target_range = 0
    @drops_attraction = false
    @__current_action = -1
    @__pre_action     = false
    @cant_equip_slot  = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :yggdrasil_1x6_cache_check
  #--------------------------------------------------------------------------#
  def yggdrasil_1x6_cache_check( line )
    case line
    # // Action
    when ::YGG::REGEXP::BASE_ITEM::ACTION_OPEN
      @__current_action = $1.to_i
      @ygg_actions[@__current_action] = []
      @__pre_action = false
    when ::YGG::REGEXP::BASE_ITEM::ACTION_CLOSE
      @__pre_action = false
      @__current_action = -1
    when ::YGG::REGEXP::BASE_ITEM::ACTION_ASSIGN
      @ygg_actions[$1.to_i] = ::YGG.get_action_list( $2 )
    # // Pre Action
    when ::YGG::REGEXP::BASE_ITEM::PREACTION_OPEN
      @__current_action = $1.to_i
      @ygg_pre_actions[@__current_action] = []
      @__pre_action = true
    when ::YGG::REGEXP::BASE_ITEM::PREACTION_CLOSE
      @__current_action = -1
      @__pre_action = false
    when ::YGG::REGEXP::BASE_ITEM::PREACTION_ASSIGN
      @ygg_pre_actions[$1.to_i] = ::YGG.get_action_list( $2 )

    when ::YGG::REGEXP::BASE_ITEM::DROPS_ATTRACT
      @drops_attraction = true
    when ::YGG::REGEXP::BASE_ITEM::CHARGE_CAP
      @charge_cap = $1.to_i
    when ::YGG::REGEXP::BASE_ITEM::USER_CHARGE_CAP
      @user_charge_cap = $1.to_i

    when ::YGG::REGEXP::BASE_ITEM::CANT_EQUIP
      @cant_equip_slot = true
    else
      if @__current_action > -1
        ygg_add_to_cache( ::YGG.get_action_from_line( line ) )
      end # // if current_action > -1
    end # // case line
  end

  #--------------------------------------------------------------------------#
  # * new-method :yggdrasil_1x6_cache_end
  #--------------------------------------------------------------------------#
  def yggdrasil_1x6_cache_end()
    @__current_action = nil ; @__pre_action = nil
  end

end

#==============================================================================#
# ** YGG::Containers::GoldItem
#==============================================================================#
class YGG::Containers::GoldItem

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :name
  attr_accessor :gold_amount
  attr_accessor :icon_index
  attr_accessor :pickup_sfx

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( amt )
    @name        = ::Vocab.gold
    @gold_amount = amt
    @icon_index  = ::YGG::GOLD_DROP_ICON
    @pickup_sfx  = ::YGG::SOUND_MONEY
  end

end

#==============================================================================#
# ** YGG::Handlers::Engage
#==============================================================================#
class YGG::Handlers::Engage

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :parent
  attr_accessor :bar_opacity

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( parent )
    @parent      = parent
    @cool_down   = 0
    @bar_opacity = 255
  end

  #--------------------------------------------------------------------------#
  # * new-method :engage
  #--------------------------------------------------------------------------#
  def engage( cool_down )
    @cool_down   = cool_down
    @bar_opacity = 255
  end

  #--------------------------------------------------------------------------#
  # * new-method :engaged?
  #--------------------------------------------------------------------------#
  def engaged? ; return @cool_down > 0 ; end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
  def update()
    update_cool_down()
    update_bar_opacity()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_cool_down
  #--------------------------------------------------------------------------#
  def update_cool_down()
    @cool_down = [@cool_down-1, 0].max
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_bar_opacity
  #--------------------------------------------------------------------------#
  def update_bar_opacity()
    if engaged?()
      @bar_opacity = [@bar_opacity+(255/60.0), 255].min
    else
      @bar_opacity = [@bar_opacity-(255/60.0), 0].max
    end
  end

end

#==============================================================================#
# ** YGG::Handlers::Equip
#==============================================================================#
class YGG::Handlers::Equip < YGG::Pos

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  #attr_accessor :parent
  attr_accessor :icon_index
  attr_accessor :eq_id
  attr_accessor :mirror
  attr_accessor :opacity, :visible
  attr_accessor :sox, :soy # // Sprite Offset
  attr_accessor :attack_action, :guard_action
  attr_accessor :direction
  attr_accessor :guard_time

  attr_writer   :angle

  #--------------------------------------------------------------------------#
  # * new-method :angle_debug # // DEBUG
  #--------------------------------------------------------------------------#
  def angle_debug()
    #@angle = (@angle + 1) % 360 if @eq_id == 0
    if Input.trigger?(Input::NUMBERS[1])
      @sox += 1
      puts @sox
    elsif Input.trigger?(Input::NUMBERS[2])
      @sox -= 1
      puts @sox
    elsif Input.trigger?(Input::NUMBERS[3])
      @soy += 1
      puts @soy
    elsif Input.trigger?(Input::NUMBERS[4])
      @soy -= 1
      puts @soy
    elsif Input.trigger?(Input::NUMBERS[5])
      @sox = 0
      puts @sox
    elsif Input.trigger?(Input::NUMBERS[6])
      @soy = 0
      puts @soy
    end if @parent.is_a?(Game_Player) if @eq_id == 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( eq_id )
    super( 0, 0, 0 )
    #@parent       = parent
    @eq_id        = eq_id
    @icon_index   = 0 #@parent.equip_icon( @eq_id )
    @list         = []
    @list_index   = 0
    @sox, @soy    = 20, 20
    @visible      = false
    @mirror       = false
    @angle_offset = 0
    @angle_mult   = 1
    @attack_action= ""
    @guard_action = ""
    @guard_time   = 0
    reset()
  end

  #--------------------------------------------------------------------------#
  # * new-method :refresh
  #--------------------------------------------------------------------------#
  def refresh()
    #@icon_index   = @parent.equip_icon( @eq_id )
  end

  #--------------------------------------------------------------------------#
  # * new-method :angle
  #--------------------------------------------------------------------------#
  def angle ; return (@angle * @angle_mult) + @angle_offset ; end

  #--------------------------------------------------------------------------#
  # * new-method :reset
  #--------------------------------------------------------------------------#
  def reset()
    @wait_count   = 0
    @opacity      = 255
    @ox, @oy, @oz = 0, 0, 0
    @angle        = 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :ox
  #--------------------------------------------------------------------------#
  def ox ; return @x + @ox + @sox ; end
  #--------------------------------------------------------------------------#
  # * new-method :oy
  #--------------------------------------------------------------------------#
  def oy ; return @y + @oy + @soy ; end
  #--------------------------------------------------------------------------#
  # * new-method :oz
  #--------------------------------------------------------------------------#
  def oz ; return @z + @oz ; end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
  def update()
    update_list()
    update_position()
  end

  #--------------------------------------------------------------------------#
  # * new-method :do_action
  #--------------------------------------------------------------------------#
  def do_action( name )
    #@icon_index    = @parent.equip_icon( @eq_id )
    @list = ACTIONS[name].clone ; @list_index = 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :do_attack
  #--------------------------------------------------------------------------#
  def do_attack()
    #@attack_action = @parent.equip_atk_act_name( @eq_id )
    do_action( @attack_action ) unless @attack_action == ""
  end

  #--------------------------------------------------------------------------#
  # * new-method :do_guard
  #--------------------------------------------------------------------------#
  def do_guard()
    #@guard_action  = @parent.equip_grd_act_name( @eq_id )
    do_action( @guard_action ) unless @guard_action == ""
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_position
  #--------------------------------------------------------------------------#
  def update_position()
    #self.angle_debug()
    case @eq_id
    when 0 # // Weapon
      oox, ooy = @ox, @oy
      case @direction #@parent.direction
      when 1 # // Down-Left
      when 2 # // Down
        @x, @y, @z = -28, -28, 20
        @sox, @soy    = 20, 20
        @ox, @oy = oox, ooy
        #@angle_offset = 0
        @angle_mult   = 1
        @mirror = false
      when 3 # // Down-Right
      when 4 # // Left
        @x, @y, @z = -24, -28, -20
        @sox, @soy    = 20, 20
        @ox, @oy = -ooy, -oox
        #@angle_offset = 0
        @angle_mult   = 1
        @mirror = false
      when 6 # // Right
        @x, @y, @z = -4, -28, 20
        @sox, @soy    = 5, 20
        @ox, @oy = ooy, oox
        #@angle_offset = 0
        @angle_mult   = -1
        @mirror = true
      when 7 # // Up-Left
      when 8 # // Up
        @x, @y, @z = 4, -28, -20
        @sox, @soy    = 5, 20
        @ox, @oy = -oox, ooy
        #@angle_offset = 0
        @angle_mult   = -1
        @mirror = true
      when 9 # // Up-Right
      end
    when 1 # // Shield
      case @direction #@parent.direction
      when 1 # // Down-Left
      when 2 # // Down
        @x, @y, @z = 0, -24, 20
        @mirror = true
      when 3 # // Down-Right
      when 4 # // Left
        @x, @y, @z = -16, -24, 20
        @mirror = false
      when 6 # // Right
        @x, @y, @z = -4, -28, -20
        @mirror = true
      when 7 # // Up-Left
      when 8 # // Up
        @x, @y, @z = -24, -24, -20
        @mirror = false
      when 9 # // Up-Right
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_list
  #--------------------------------------------------------------------------#
  def update_list()
    @wait_count = [@wait_count - 1, 0].max
    return unless @wait_count == 0
    while @list_index < @list.size
      ret_value = -1
      act = @list[@list_index]
      case act[0].upcase
      when "MOVE"
        case act[1].upcase
        when "X" ; @ox = act[2]
        when "Y" ; @oy = act[2]
        when "Z" ; @oz = act[2] # // For whatever reason
        end
        ret_value = 0
      when "CHANGEANGLE", "CHANGE_ANGLE", "CHANGE ANGLE"
        @angle = act[1]
        ret_value = 0
      when "RESET"
        reset()
        ret_value = 0
      when "CHANGEOPACITY", "CHANGE_OPACITY", "CHANGE OPACITY"
        @opacity = act[1]
        ret_value = 0
      when "SHOW"
        @visible = true
        ret_value = 0
      when "HIDE"
        @visible = false
        ret_value = 0
      when "WAIT FOR GUARD"
        return if @guard_time > 0
        ret_value = 0
      when "WAIT"
        @wait_count = act[1]
        ret_value = 1
      end
      @list_index += 1
      return if ret_value == 1
    end
  end

end

#==============================================================================#
# ** YGG::Handlers::BattleObj
#==============================================================================#
class YGG::Handlers::BattleObj

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :obj_id
  attr_accessor :type

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( id, type )
    @obj_id, @type = id, type ; @charge_time = 0 ;
    @dummy_obj = RPG::BaseItem.new() ; @dummy_obj.yggdrasil_1x6_cache()
  end

  #--------------------------------------------------------------------------#
  # * new-method :skill
  #--------------------------------------------------------------------------#
  def skill()
    return @type == :skill ? $data_skills[@obj_id] : nil
  end

  #--------------------------------------------------------------------------#
  # * new-method :item
  #--------------------------------------------------------------------------#
  def item()
    return @type == :item ? $data_items[@obj_id] : nil
  end

  #--------------------------------------------------------------------------#
  # * new-method :obj
  #--------------------------------------------------------------------------#
  def obj()
    return item() || skill() || @dummy_obj
  end

  #--------------------------------------------------------------------------#
  # * new-method :reset_time
  #--------------------------------------------------------------------------#
  def reset_time()
    @charge_time = cap
  end

  #--------------------------------------------------------------------------#
  # * new-method :time
  #--------------------------------------------------------------------------#
  def time()
    return @charge_time
  end

  #--------------------------------------------------------------------------#
  # * new-method :cap
  #--------------------------------------------------------------------------#
  def cap()
    return obj.charge_cap
  end

  #--------------------------------------------------------------------------#
  # * new-method :can_use?
  #--------------------------------------------------------------------------#
  def can_use?() ; return @charge_time == 0 ; end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
  def update()
    @charge_time = [@charge_time - 1, 0].max
  end

end

#==============================================================================#
# ** YGG::System (Battle Edits)
#==============================================================================#
class YGG::System

  #--------------------------------------------------------------------------#
  # * new-method :action_attack
  #--------------------------------------------------------------------------#
  def action_attack( settings={} )
    user_ev, targets_ev = settings[:user], settings[:targets]
    user = user_ev.ygg_battler
    targets_ev.each { |target|
      next if target.ygg_invincible
      bat = target.ygg_battler
      next if bat.nil?()
      bat.ygg_guard = target.guard_time > 0
      bat.attack_effect( user )
      target.ygg_engage.engage( 180 )
      YGG::PopText.create_pop( { :character => target, :type => :attack_damage } ) if target.pop_enabled?() if YGG::USE_TEXT_POP
      action_gain_exp( user, bat, user_ev, YGG::POP_EXP ) unless bat.actor?() if user.actor?()
      bat.ygg_guard = false
    }
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_skill
  #--------------------------------------------------------------------------#
  def action_skill( settings={} )
    user_ev, targets_ev, obj = settings[:user], settings[:targets], settings[:obj]
    targets = targets_ev.inject([]) { |r, e| r << e.ygg_battler }
    targets.compact!() ; user = user_ev.ygg_battler
    targets_ev.each { |target|
      next if target.ygg_invincible
      bat = target.ygg_battler
      next if bat.nil?()
      bat.ygg_guard = target.guard_time > 0 && obj.guardable
      bat.skill_effect( user, obj )
      target.ygg_engage.engage( 180 )
      YGG::PopText.create_pop( { :character => target, :type => :skill_damage } ) if target.pop_enabled?() if YGG::USE_TEXT_POP
      action_gain_exp( user, bat, user_ev, YGG::POP_EXP ) unless bat.actor?() if user.actor?()
      bat.ygg_guard = false
    }
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_item
  #--------------------------------------------------------------------------#
  def action_item( settings={} )
    user_ev, targets_ev, obj = settings[:user], settings[:targets], settings[:obj]
    targets = targets_ev.inject([]) { |r, e| r << e.ygg_battler }
    targets.compact!() ; user = user_ev.ygg_battler
    targets_ev.each { |target|
      next if target.ygg_invincible
      bat = target.ygg_battler
      next if bat.nil?()
      bat.ygg_guard = target.guard_time > 0 && obj.guardable
      bat.item_effect( user, obj )
      target.ygg_engage.engage( 180 )
      YGG::PopText.create_pop( { :character => target, :type => :item_damage } ) if target.pop_enabled?() if YGG::USE_TEXT_POP
      action_gain_exp( user, bat, user_ev, YGG::POP_EXP ) unless bat.actor?() if user.actor?()
      bat.ygg_guard = false
    }
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_gain_exp
  #--------------------------------------------------------------------------#
  def action_gain_exp( receivee, bat, event=nil, show=true )
    case YGG::EXP_GAINING_METHOD
    when 0 # // Dead
      return unless bat.dead?()
      exp = bat.exp
    when 1 # // Per Hit
      exp = YGG::EXP_PER_HIT_FORMULA.call(
        bat.hp_damage+receivee.mp_damage, receivee, bat )
    end
    return if exp == 0
    old_level = receivee.level
    case YGG::EXP_SAHRE_METHOD
    when 0 # Active Member Only
      receivee.gain_exp( exp, false )
    when 1 # All Members Equal
      ($game_party.members-[receivee]).each { |mem| mem.gain_exp( exp, false ) }
      receivee.gain_exp( exp, false )
    when 2 # All Members Split
      mems = ($game_party.members-[receivee])
      exp /= mems.size+1
      mems.each { |mem| mem.gain_exp( exp, false ) }
      receivee.gain_exp( exp, false )
    end
    action_level_up( receivee, old_level, event, YGG::POP_LEVEL_UP ) if old_level != receivee.level
    unless event.nil?()
      ::YGG::PopText.create_pop(
        { :character => event, :type => :gain_exp, :parameters => [exp] }
      ) if YGG::USE_TEXT_POP
    end if show
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_level_up
  #--------------------------------------------------------------------------#
  def action_level_up( receivee, old_level, event=nil, show=true )
    $scene.level_up_window.show_level_up( receivee, old_level ) if YGG::USE_LEVEL_UP_WINDOW > 0
    unless event.nil?()
      if ::YGG::LEVEL_UP_ALERT
        event.ygg_anims << ::YGG::ANIM_ON_LEVEL unless ::YGG::ANIM_ON_LEVEL == 0
      end
      ::YGG::PopText.create_pop(
        { :character => event, :type => :level_up, :parameters => [old_level] }
      ) if show if YGG::USE_TEXT_POP
    end
  end

end

#==============================================================================#
# ** YGG::Handlers::Action
#==============================================================================#
class YGG::Handlers::Action

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :list
  attr_accessor :list_stack
  attr_accessor :skill_id, :item_id
  attr_accessor :user_event
  attr_accessor :target_events
  attr_accessor :parent_event

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( parent, list=[] )
    @parent_event = parent
    @interpreter  = ::Game_Interpreter.new()
    @list_stack   = [] ; setup( list ) ; execute( nil, [], { :skip_first_update=>true } )
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup
  #--------------------------------------------------------------------------#
  def setup( list=[] )
    @list        = list.clone
    @active_list = @list.clone
  end

  #--------------------------------------------------------------------------#
  # * new-method :busy?
  #--------------------------------------------------------------------------#
  def busy?()
    return @list_index < @active_list.size || @interpreter.running?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :execute
  #--------------------------------------------------------------------------#
  def execute( user_event, starting_targets=[], start_values={} )
    @active_list    = @list.clone
    @wait_count     = start_values[:wait_count] || 0
    @skill_id       = start_values[:skill_id] || 0
    @item_id        = start_values[:item_id] || 0
    @range          = start_values[:range] || []
    @target_events  = starting_targets
    @user_event     = user_event
    @wait_for_comev = false
    @list_index     = 0

    @affected_targets = []

    update() unless start_values[:skip_first_update]
  end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
  def update()
    @interpreter.update()
    return if @interpreter.running?() && @wait_for_comev
    @wait_count = [@wait_count-1, 0].max
    update_action() if @wait_count == 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_action
  #--------------------------------------------------------------------------#
  def update_action()
    unless @list_stack.empty?()
      setup( @list_stack.shift() )
      execute( @user_event, @target_events,
       {
        :skill_id => @skill_id,
        :item_id  => @item_id,
        :range    => @range
       }
      )
    end if @list_index >= @active_list.size
    while @list_index < @active_list.size
      #break if act_set.nil?()
      @action, @parameters = *@active_list[@list_index]
      #for i in 0...@parameters.size() ; @parameters[i] = @parameters[i].to_s() ; end
      act_result = -1
      #puts sprintf("ACTION: %s", @action)
      #puts sprintf("PARAMETERS: %s", @parameters)
      case @action.upcase()
      # // action: action_name
      when "ACTION", "ACTIONLIST", "ACTION LIST", "ACTION_LIST"
        act_result = action_actionlist( @action, @parameters )
      when "ANIMATION"
        act_result = action_animation( @action, @parameters )
      when "COMMONEVENT", "COMMON_EVENT", "COMMON EVENT"
        act_result = action_common_event( @action, @parameters )
      when "ATTACKEFFECT", "ATTACK_EFFECT", "ATTACK EFFECT"
        act_result = action_effect( @action, @parameters )
      when "SKILLEFFECT", "SKILL_EFFECT", "SKILL EFFECT"
        act_result = action_effect( @action, @parameters )
      when "ITEMEFFECT", "ITEM_EFFECT", "ITEM EFFECT"
        act_result = action_effect( @action, @parameters )
      when "OBJEFFECT", "OBJ_EFFECT", "OBJ EFFECT"
        eff = @skill_id > 0 ? "SKILL_EFFECT" : nil
        eff = @item_id > 0 ? "ITEM_EFFECT" : "" if eff.nil?()
        act_result = action_effect( eff, @parameters+["PRESET"] )
      when "GUARD"
        act_result = action_guard( @action, @parameters )
      when "CHARGE", "COOLDOWN"
        act_result = action_charge( @action, @parameters )
      when "RANGE"
        act_result = action_range( @action, @parameters )
      when "TARGET"
        action_target( @action, @parameters )
        act_result = 0
      when "SUBTARGET"
        act_result = action_subtargets( @action, @parameters )
      when "TARGET_SELECT", "TARGET SELECT", "TARGETSELECT"
        act_result = action_target_select( @action, @parameters )
      when "SET_ORIGIN", "SET ORIGIN", "SETORIGIN"
        act_result = action_origin( @action, @parameters )
      when "MOVE"
        act_result = action_move( @action, @parameters )
      when "JUMP"
        act_result = action_jump( @action, @parameters )
      when "SETITEM", "SET_ITEM", "SET ITEM"
        act_result = action_set_item( @action, @parameters )
      when "SETSKILL", "SET_SKILL", "SET SKILL"
        act_result = action_set_skill( @action, @parameters )
      when "PROJECTILE"
        act_result = action_projectile( @action, @parameters )
      when "SCRIPT"
        act_result = action_script( @action, @parameters )
      when "THROUGH"
        act_result = action_through( @action, @parameters )
      when "PARENTWAIT", "PARENT_WAIT", "PARENT WAIT"
        act_result = action_parent_wait( @action, @parameters )
      when "WAIT", "WAIT_FOR_EVENT", "WAIT FOR ANIMATION"
        act_result = action_wait( @action, @parameters )
      when "SE"
        act_result = action_se( @action, @parameters )
      when "ME"
        act_result = action_me( @action, @parameters )
      else
        act_result = extended_actions( @action, @parameters )
      end
      if act_result == -1
        puts "ERROR: -1 returned for action #{self}"
      else
        puts "BING: #{act_result} returned for action #{self}"
      end if YGG.debug_mode?
      @list_index += 1
      break if act_result == 1
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :extended_actions
  #--------------------------------------------------------------------------#
  def extended_actions( action, parameters )
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_set_skill
  #--------------------------------------------------------------------------#
  def action_set_skill( action, parameters )
    @skill_id = parameters[0].to_i
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_set_item
  #--------------------------------------------------------------------------#
  def action_set_item( action, parameters )
    @item_id = parameters[0].to_i
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_actionlist
  #--------------------------------------------------------------------------#
  def action_actionlist( action, parameters )
    @active_list = @active_list.slice(0, @list_index+1) +
      ::YGG.get_action_list( parameters[0] ) +
      @active_list.slice( @list_index+1, @active_list.size )
    @list_index += 1
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_animation
  #--------------------------------------------------------------------------#
  def action_animation( action, parameters )
    p0 = parameters[0].to_s.upcase()
    p1 = parameters[1].upcase()
    p2 = parameters[2].upcase()

    id = 0
    case p0
    when "OBJ"
      id = $data_skills[@skill_id].animation_id if @skill_id > 0
      id = $data_items[@item_id].animation_id    if @item_id > 0
      id = @user_event.ygg_battler.atk_animation_id() if id == -1
    when "ATK", "ATTACK"
      id = @user_event.ygg_battler.atk_animation_id()
    else
      id = p0.to_i
    end

    case p1
    when "POS"
      event = @user_event
      x, y = *YGG.offset_xy(
       event.x, event.y,
       [parameters[3].to_i(), parameters[4].to_i()],
       event.direction )
      targets = action_target( "TARGET", ["MAP_XY", x, y], true )
      case p2
      when "NORMAL"
        targets.each { |t| t.animation_id = id }
      when "WILD"
        $scene.push_ygg_anim( id, x, y, targets, false ) if $scene.is_a?( Scene_Map )
      end
    else
      action_target( "TARGET", [p1] ).each { |t|
        case p2
        when "NORMAL" ; t.animation_id = id
        when "WILD"   ; t.ygg_anims.push( id )
        end
      }
    end
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_origin
  #--------------------------------------------------------------------------#
  def action_origin( action, parameters )
    action_target( "TARGET", parameters, true ).each { |character|
      character.set_orgin() }
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_move
  #--------------------------------------------------------------------------#
  def action_move( action, parameters )
    targets = action_target( "TARGET", [parameters[0]], true )
    targets.each { |character|
      case parameters[1].upcase
      when "FORWARD"
        character.move_forward()
      when "BACKWARD"
        character.move_backward()
      when "UP"
        character.move_up()
      when "DOWN"
        character.move_down()
      when "LEFT"
        character.move_left()
      when "RIGHT"
        character.move_right()
      when "TO"
        case parameters[2]
        when "ORIGIN"
          character.moveto( character.origin.x, character.origin.y )
        else
          prms = parameters.slice( 2, parameters.size )
          action_targets( "TARGET", prms, true ).each { |target|
            character.moveto( target.x, target.y )
          }
        end
      when "TOXY", "TO_XY", "TO XY"
        dist, sway = parameters[2], parameters[3]
        case character.direction
        when 2 # // Down
          x, y = character.x+sway, character.y+dist
        when 4 # // Left
          x, y = character.x-dist, character.y+sway
        when 6 # // Right
          x, y = character.x+dist, character.y-sway
        when 8 # // Up
          x, y = character.x-sway, character.y-dist
        end
        character.moveto( x, y )
      when "TOMAPXY", "TO_MAP_XY", "TO MAP XY"
        character.moveto( parameters[2].to_i, parameters[3].to_i )
      when "TURNUP", "TURN_UP", "TURN UP"
        character.turn_up()
      when "TURNDOWN", "TURN_DOWN", "TURN DOWN"
        character.turn_down()
      when "TURNLEFT", "TURN_LEFT", "TURN LEFT"
        character.turn_left()
      when "TURNRIGHT", "TURN_RIGHT", "TURN RIGHT"
        character.turn_right()
      when "TURNRIGHT90", "TURN_RIGHT_90", "TURN RIGHT 90"
        character.turn_right_90()
      when "TURNLEFT90", "TURN_LEFT_90", "TURN LEFT 90"
        character.turn_left_90()
      when "TURN180", "TURN_180", "TURN 180"
        character.turn_180()
      when "TURNTO", "TURN_TO", "TURN TO"
        prms = parameters.slice( 2, parameters.size )
        action_targets( "TARGET", prms, true ).each { |target|
          character.turn_to_coord( target.x, target.y ) }
      end
    }
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_jump
  #--------------------------------------------------------------------------#
  def action_jump( action, parameters )
    users = action_target( "TARGET", parameters[0], true )
    users.each { |character|
      case parameters[1].upcase
      when "XY"
        character.jump( parameters[2].to_i, parameters[3].to_i )
      else
        action_target( "TARGET", parameters[1], true ).each { |t|
          character.jump_to_char( t )
        }
      end
    }
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_charge
  #--------------------------------------------------------------------------#
  def action_charge( action, parameters )
    targets = action_target( "TARGET", parameters[0], true )
    value = parameters[2].upcase == "MAX" ? t.ygg_battler.cooldown_max : parameters[2].to_i
    case parameters[1].upcase
    when "ADD"
      targets.each { |t| t.ygg_battler.cooldown += value }
    when "SUB"
      targets.each { |t| t.ygg_battler.cooldown -= value }
    when "SET"
      targets.each { |t| t.ygg_battler.cooldown  = value }
    end
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_common_event
  #--------------------------------------------------------------------------#
  def action_common_event( action, parameters )
    case parameters[0].upcase
    when "SKILL"
      common_event_id = $data_skills[parameters[1].to_i].common_event_id
    when "ITEM"
      common_event_id = $data_items[parameters[1].to_i].common_event_id
    when "OBJ"
      if @skill_id > 0
        action_common_event( "COMMON_EVENT", ["SKILL", @skill_id, parameters[2]] )
      elsif @item_id > 0
        action_common_event( "COMMON_EVENT", ["ITEM", @item_id, parameters[2]] )
      end
      return
    when "ID"
      common_event_id = parameters[1].to_i
    end
    @interpreter.setup( $data_common_events[common_event_id].list )
    @wait_for_comev = parameters[2].to_s.upcase == "WAIT"
    return @wait_for_comev ? 1 : 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_range
  #--------------------------------------------------------------------------#
  def action_range( action, parameters )
    case parameters[0].upcase
    when "ADD"
      @range.push( [ parameters[1].to_i, parameters[2].to_i ] )
    when "SUB"
      @range -= [[ parameters[1].to_i, parameters[2].to_i ]]
    when "CLEAR"
      @range.clear()
    when "CREATE"
      rng, minrng, type = parameters[1].to_i, parameters[2].to_i, parameters[3].to_i
      target = action_target( "TARGET", [parameters[4].to_s], true )[0]
      direction = target.nil?() ? parameters[4].to_i : target.direction
      @range = YGG.create_range_data( rng, minrng, type, direction )
    end
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_target
  #--------------------------------------------------------------------------#
  def action_target( action, parameters, return_only=false )
    raise "Parameter is not an array" unless parameters.is_a?( Array )
    targets = []
    case parameters[0].upcase()
    when "AFFECTED"
      targets = @affected_targets
    when "PARENT"
      targets = [ @parent_event ]
    when "USER"
      targets = [ @user_event ]
    when "TARGET"
      targets = [ @target_events[0] ]
    when "TARGETS"
      targets = @target_events
    when "ALLIES"
      targets = @target_events.inject([]) { |r, e| r.push( e ) if @user_event.ally_character?( e ) ; r }
    when "ENEMIES"
      targets = @target_events.inject([]) { |r, e| r.push( e ) if @user_event.enemy_character?( e ) ; r }
    when "RANDTARGET"
      targets = action_target( "TARGET", ["TARGETS"], true )
      targets = [targets[rand(targets.size)]]
    when "RANDALLY"
      targets = action_target( "TARGET", ["ALLIES"], true )
      targets = [targets[rand(targets.size)]]
    when "RANDENEMY"
      targets = action_target( "TARGET", ["ENEMIES"], true )
      targets = [targets[rand(targets.size)]]
    when "SCREEN", "ONSCREEN", "ON_SCREEN"
      $game_yggdrasil.battlers.each { |ev|
        targets.push( ev ) if ev.limitedOnScreen?()
      }
    when "OFFSCREEN", "OFF_SCREEN"
      $game_yggdrasil.battlers.each { |ev|
        targets.push( ev ) if !ev.limitedOnScreen?()
      }
    when "MAP_XY"
      xy_list = [ [parameters[1].to_i, parameters[2].to_i] ]
      targets = @user_event.get_target_events( xy_list )
    when "XY"
      xy_list = [ [parameters[1].to_i, parameters[2].to_i] ]
      xy_list = YGG::offset_xy_list( @user_event.x, @user_event.y, xy_list, @user_event.direction )
      targets = @user_event.get_target_events( xy_list )
    when "RANGE"
      xy_list = @range
      xy_list = YGG::offset_xy_list( @user_event.x, @user_event.y, xy_list, @user_event.direction )
      targets = @user_event.get_target_events( xy_list )
    end
    targets = targets.compact.uniq
    @target_events = targets unless return_only
    return targets
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_subtargets
  #--------------------------------------------------------------------------#
  def action_subtargets( action, parameters )
    @target_events -= action_target( "TARGET", parameters, true )
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_target_select
  #--------------------------------------------------------------------------#
  def action_target_select( action, parameters )
    if @parent_event.ai_operated?()
      targs = action_target( "TARGET", parameters.slice( 1, parameters.size ) ).sort_by { rand }
      result = [] ; for i in 0...parameters[0].to_i ; result.push( targs[i] ) ; end
      @target_events = result.compact.uniq
    else
      @target_events = $game_yggdrasil.start_target_selection( parameters[0].to_i,
        action_target( "TARGET", parameters.slice( 1, parameters.size ), true ) )
    end
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_effect
  #--------------------------------------------------------------------------#
  def action_effect( action, parameters )
    users   = action_target( "TARGET", [parameters[0]], true )
    targets = action_target( "TARGET", [parameters[1]], true )
    case action.upcase()
    when "ATTACKEFFECT", "ATTACK_EFFECT", "ATTACK EFFECT"
      users.each { |user|
        user.equip_handle( 0 ).do_attack()
        $game_yggdrasil.action_attack(
          { :user => user, :targets => targets }
        )
      }
    when "SKILLEFFECT", "SKILL_EFFECT", "SKILL EFFECT"
      users.each { |user|
        case parameters[2].upcase()
        when "PRESET", "OBJ"
          sid = @skill_id
        else ; sid = parameters[2].to_i
        end
        $game_yggdrasil.action_skill(
          { :user => user, :targets => targets, :obj => $data_skills[sid] }
        )
      }
    when "ITEMEFFECT", "ITEM_EFFECT", "ITEM EFFECT"
      users.each { |user|
        case parameters[2].upcase()
        when "PRESET", "OBJ"
          iid = @item_id
        else ; iid = parameters[2].to_i
        end
        $game_yggdrasil.action_item(
          { :user => user, :targets => targets, :obj => $data_items[iid] }
        )
      }
    end
    @affected_targets.clear()
    (users).each { |t|
      t.ygg_battler.clear_action_results() unless t.ygg_battler.nil?() unless t.nil?()
    }
    (targets).each { |t|
      @affected_targets << t unless (t.ygg_battler.skipped ||
        t.ygg_battler.missed ||
        t.ygg_battler.evaded) unless t.ygg_battler.nil?()
      t.ygg_battler.clear_action_results() unless t.ygg_battler.nil?() unless t.nil?()
    }
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_guard
  #--------------------------------------------------------------------------#
  def action_guard( action, parameters )
    @user_event.guard_time = parameters[0].to_i
    @user_event.equip_handle( 1 ).do_guard()
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_projectile
  #--------------------------------------------------------------------------#
  def action_projectile( action, parameters )
    users = action_target( "TARGET", [parameters[0]], true )
    case parameters[1].upcase
    when "PARENT"
      direction = action_target( "TARGET", ["PARENT"], true )[0].direction
    when "USER"
      direction = action_target( "TARGET", ["USER"], true )[0].direction
    when "TARGET"
      direction = action_target( "TARGET", ["TARGET"], true )[0].direction
    else
      direction = parameters[1].to_i
    end
    projectile = ::YGG::PROJECTILE_MAP[parameters[2].to_s]
    setup_code = ::YGG::PROJETILE_SETUP[parameters[3].to_s]
    sp_code    = (parameters[4] || 0).to_s.to_i
    users.each { |user|
      pro = projectile.new( user, setup_code )
      case sp_code
      when 0
        pro.moveto( user.x, user.y )
      when 1
        pro.moveto( *user.get_xy_infront( 1, 0 ) )
      when 2
        pro.moveto( *user.get_xy_infront( -1, 0 ) )
      end
      pro.set_direction( direction )
      $game_yggdrasil.add_projectile( pro )
    }
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_script
  #--------------------------------------------------------------------------#
  def action_script( action, parameters )
    user    = action_target( "TARGET", ["USER"] )
    target  = action_target( "TARGET", ["TARGET"] )
    targets = action_target( "TARGET", ["TARGETS"] )
    eval( parameters.to_s )
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_through
  #--------------------------------------------------------------------------#
  def action_through( action, parameters )
    targets = action_target( "TARGET", [parameters[0]] )
    case parameters[1].upcase
    when "TRUE", "ON", "YES"
      targets.each { |t| t.set_through( true ) }
    when "FALSE", "OFF", "NO"
      targets.each { |t| t.set_through( false ) }
    end
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_parent_wait
  #--------------------------------------------------------------------------#
  def action_parent_wait( action, parameters )
    @user_event.wait_count = parameters[0].to_i
    return 1
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_wait
  #--------------------------------------------------------------------------#
  def action_wait( action, parameters )
    case action.upcase
    when "WAIT FOR ANIMATION"
      @wait_count = $data_animations[parameters[0].to_i].frame_max * ::Sprite_Base::RATE
    when "WAIT"
      @wait_count = parameters[0].to_i
    end
    return 1
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_se
  #--------------------------------------------------------------------------#
  def action_se( action, parameters )
    RPG::SE.new( parameters[0].to_s, parameters[1].to_i, parameters[2].to_i ).play()
    return 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :action_me
  #--------------------------------------------------------------------------#
  def action_me( action, parameters )
    RPG::ME.new( parameters[0].to_s, parameters[1].to_i, parameters[2].to_i ).play()
    return 0
  end

end

# // (YGG_MC) - Mix Code
#==============================================================================#
# // RMVX Mixins
#==============================================================================#
# ** RPG::Animation
#==============================================================================#
class RPG::Animation

  #----------------------------------------------------------------------------#
  # * new-method :cell_count
  #----------------------------------------------------------------------------#
  def cell_count
    16
  end unless method_defined? :cell_count

end

#==============================================================================#
# ** RPG::BaseItem
#==============================================================================#
class RPG::BaseItem

  include YGG::Caches1x6

  #----------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #----------------------------------------------------------------------------#
  attr_accessor :pickup_sfx

  #----------------------------------------------------------------------------#
  # * new-method :pickup_sfx
  #----------------------------------------------------------------------------#
  def pickup_sfx()
    @pickup_sfx ||= self.note =~ YGG::REGEXP::BASE_ITEM::PICKUP_SFX ?
      RPG::SE.new( $1, $2.to_i, $3.to_i ) : ::YGG::SOUND_ITEM
    return @pickup_sfx
  end

  #----------------------------------------------------------------------------#
  # * new-method :drops_attraction?
  #----------------------------------------------------------------------------#
  def drops_attraction?() ; return @drops_attraction ; end

end

#==============================================================================#
# ** RPG::Armor
#==============================================================================#
class RPG::Armor

  #----------------------------------------------------------------------------#
  # * super-method :drops_attraction?
  #----------------------------------------------------------------------------#
  def yggdrasil_1x6_cache_end()
    super()
    @ygg_actions[0] ||= ::YGG.get_action_list( "GUARD_ACTION" )
  end

end

#==============================================================================#
# ** RPG::UsableItem
#==============================================================================#
class RPG::UsableItem

  #----------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #----------------------------------------------------------------------------#
  attr_accessor :guardable

  #----------------------------------------------------------------------------#
  # * super-method :yggdrasil_1x6_cache_start
  #----------------------------------------------------------------------------#
  def yggdrasil_1x6_cache_start()
    super()
    @__use_target_select = false
    @guardable = false
  end

  #----------------------------------------------------------------------------#
  # * super-method :yggdrasil_1x6_cache_check
  #----------------------------------------------------------------------------#
  def yggdrasil_1x6_cache_check( line )
    super( line )
    case line
    when ::YGG::REGEXP::SKILL::UTARGET_SELECT
      @__use_target_select = true
    when ::YGG::REGEXP::SKILL::GUARDABLE
      @guardable = true
    when ::YGG::REGEXP::SKILL::NOT_GUARDABLE
      @guardable = false
    end
  end

  #----------------------------------------------------------------------------#
  # * super-method :yggdrasil_1x6_cache_end
  #----------------------------------------------------------------------------#
  def yggdrasil_1x6_cache_end()
    super()
    case @scope
    when 0     # // None
      @ygg_actions[0] ||= ::YGG.get_action_list( "NORMAL_OBJ0" ).clone
    when 11    # // User
      @ygg_actions[0] ||= ::YGG.get_action_list( "NORMAL_OBJ1" ).clone
    when 1     # // 1 Enemy
      @ygg_actions[0] ||= @__use_target_select ?
        ::YGG.get_action_list( "NORMAL_OBJ2_T1" ).clone :
        ::YGG.get_action_list( "NORMAL_OBJ2_1" ).clone
    when 3     # // 1 Enemy Dual
      @ygg_actions[0] ||= @__use_target_select ?
        ::YGG.get_action_list( "NORMAL_OBJ2_T2" ).clone :
        ::YGG.get_action_list( "NORMAL_OBJ2_2" ).clone
    when 4     # // 1 Random Enemy
      @ygg_actions[0] ||= ::YGG.get_action_list( "NORMAL_OBJ2_R1" ).clone
    when 5     # // 2 Random Enemies
      @ygg_actions[0] ||= ::YGG.get_action_list( "NORMAL_OBJ2_R2" ).clone
    when 6     # // 3 Random Enemies
      @ygg_actions[0] ||= ::YGG.get_action_list( "NORMAL_OBJ2_R3" ).clone
    when 7, 9  # // 1 Ally
      @ygg_actions[0] ||= @__use_target_select ?
        ::YGG.get_action_list( "NORMAL_OBJ3_T1" ).clone :
        ::YGG.get_action_list( "NORMAL_OBJ3_1" ).clone
    when 2     # // All Enemies
      @ygg_actions[0] ||= ::YGG.get_action_list( "NORMAL_OBJ4" ).clone
    when 8, 10 # // All Allies
      @ygg_actions[0] ||= ::YGG.get_action_list( "NORMAL_OBJ5" ).clone
    end
  end

end

#==============================================================================#
# ** RPG::Enemy
#==============================================================================#
class RPG::Enemy

  include YGG::Caches1x6

  #----------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #----------------------------------------------------------------------------#
  attr_accessor :atk_animation_id
  attr_accessor :atk_animation_id2
  attr_accessor :drop_items
  attr_accessor :gold_variation
  attr_accessor :equip_icons
  attr_accessor :use_equipment
  attr_accessor :atk_act_name
  attr_accessor :grd_act_name
  #----------------------------------------------------------------------------#
  # * super-method :yggdrasil_1x6_cache_check
  #----------------------------------------------------------------------------#
  def yggdrasil_1x6_cache_start()
    super()
    @drop_items   ||= []  ; @__drop_id = -1
    @__drop         = nil ; @__drop_reading = false
    @gold_variation = 0
    @equip_icons    = Array.new( 2, 0 )
    @use_equipment  = false
    @atk_act_name, @grd_act_name = "Swing1", "GRise1"
  end

  #----------------------------------------------------------------------------#
  # * super-method :yggdrasil_1x6_cache_check
  #----------------------------------------------------------------------------#
  def yggdrasil_1x6_cache_check( line )
    super( line )
    case line
    when YGG::REGEXP::ENEMY::ATK_ANIMATION_ID
      @atk_animation_id = $1.to_i
    when YGG::REGEXP::ENEMY::DROP_ITEM2
      @drop_items[@__drop_id] = @__drop if @__drop_id > -1
      @__drop_id = -1 ; @__drop = nil ; @__drop_reading = false
    when YGG::REGEXP::ENEMY::DROP_ITEM1
      @__drop_id = $1.to_i ; @__drop = DropItem.new() ; @__drop_reading = true
    when YGG::REGEXP::ENEMY::DROP_CLEAR
      @drop_items.clear()
    when YGG::REGEXP::ENEMY::GOLD_VARI
      @gold_variation = $1.to_i
    when YGG::REGEXP::ENEMY::EQUIP_ICONS
      icon = 0
      eq_id = $1.to_i
      n = $2
      case n
      when /(?:WEP|WEAPON)[ ](\d+)/i
        icon = $data_weapons[$1.to_i].icon_index
      when /(?:ARM|ARMOR)[ ](\d+)/i
        icon = $data_armors[$1.to_i].icon_index
      when /(?:SKL|SKILL)[ ](\d+)/i
        icon = $data_skills[$1.to_i].icon_index
      when /(?:ITE|ITEM)[ ](\d+)/i
        icon = $data_items[$1.to_i].icon_index
      else
        icon = n.to_i
      end
      @equip_icons[eq_id] = icon
    when YGG::REGEXP::ENEMY::USE_EQUIPMENT
      @use_equipment = true
    when YGG::REGEXP::ENEMY::NO_EQUIPMENT
      @use_equipment = false
    else
      if @__drop_reading
        case line
        # // Type of the drop item (0: none, 1: item, 2: weapon, 3: armor)
        when /kind:[ ](\d+)/i
          @__drop.kind = $1.to_i
        when /(?:item_id|item id|itemid):[ ](\d+)/i
          @__drop.kind = 1 ; @__drop.item_id = $1.to_i
        when /(?:weapon_id|weapon id|weaponid):[ ](\d+)/i
          @__drop.kind = 2 ; @__drop.weapon_id = $1.to_i
        when /(?:armor_id|armor id|armorid):[ ](\d+)/i
          @__drop.kind = 3 ; @__drop.armor_id = $1.to_i
        when /(?:denom|denominator|prob|probability):[ ](\d+)/i
          @__drop.denominator = $1.to_i
        end
      end
    end
  end

  #----------------------------------------------------------------------------#
  # * super-method :yggdrasil_1x6_cache_end
  #----------------------------------------------------------------------------#
  def yggdrasil_1x6_cache_end()
    super()
    @atk_animation_id  ||= 1
    @atk_animation_id2 ||= 0
    @ygg_actions[0]    ||= ::YGG.get_action_list( "NORMAL_ATTACK_EN" ) # // Attack Action
    @ygg_actions[1]    ||= ::YGG.get_action_list( "GUARD_ACTION_EN" )  # // Guard Action
    @ygg_actions[2]    ||= ::YGG.get_action_list( "ESCAPE_ACTION_EN" ) # // Escape Action
    @ygg_actions[3]    ||= ::YGG.get_action_list( "WAIT_ACTION_EN" )   # // Wait Action
    @drop_items[1]     ||= @drop_item1
    @drop_items[2]     ||= @drop_item2
    # // Match Drop Items D: We dont want mismatch and chaos >:
    @drop_item1 = @drop_items[1]
    @drop_item2 = @drop_items[2]
  end

end

#==============================================================================#
# ** RPG::State
#==============================================================================#
class RPG::State

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :hold_ticks
  attr_accessor :effect_tone
  attr_accessor :tone_effect
  attr_accessor :move_mod

  #----------------------------------------------------------------------------#
  # * new-method :yggdrasil_1x6_cache
  #----------------------------------------------------------------------------#
  def yggdrasil_1x6_cache()
    yggdrasil_1x6_cache_start()
    self.note.split(/[\r\n]+/).each { |line| yggdrasil_1x6_cache_check( line ) }
    yggdrasil_1x6_cache_end()
  end

  #----------------------------------------------------------------------------#
  # * new-method :yggdrasil_1x6_cache_start
  #----------------------------------------------------------------------------#
  def yggdrasil_1x6_cache_start()
    @hold_ticks  = self.hold_turn * ::YGG::STATE_TURN_COUNTER
    @move_mod    = 0
    @effect_tone = Tone.new( 0, 0, 0, 0 )
    @tone_effect = false
    @slip_freq   = ::YGG::SLIP_DAMAGE_FREQUENCY
  end

  #----------------------------------------------------------------------------#
  # * new-method :yggdrasil_1x6_cache_check
  #----------------------------------------------------------------------------#
  def yggdrasil_1x6_cache_check( line )
    case line
    when ::YGG::REGEXP::STATE::HOLD_TICKS
      @hold_ticks = $1.to_i
    when ::YGG::REGEXP::STATE::TONE
      @effect_tone = ::Tone.new( $1.to_i, $2.to_i, $3.to_i, $4.to_i )
      @tone_effect = true
    when ::YGG::REGEXP::STATE::MOVE_MOD
      @move_mod = $1.to_i
    when ::YGG::REGEXP::STATE::SLIP_FREQ
      @slip_freq = $1.to_i
    end
  end

  #----------------------------------------------------------------------------#
  # * new-method :yggdrasil_1x6_cache_end
  #----------------------------------------------------------------------------#
  def yggdrasil_1x6_cache_end()
  end

  #----------------------------------------------------------------------------#
  # * new-method :slip_freq
  #----------------------------------------------------------------------------#
  def slip_freq()
    return self.slip_damage ? @slip_freq : 0
  end

end

#==============================================================================#
# ** YGG::System ($game_yggdrasil)
#==============================================================================#
class YGG::System

  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  ITEMS_MAPID = ::YGG::ITEM_MAP

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :passage_objs

  attr_reader :projectiles
  attr_reader :new_projectiles

  attr_reader :new_poptexts

  attr_reader :active_ranges
  attr_reader :battlers

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize()
    setup_map( -1 )
  end

  #--------------------------------------------------------------------------#
  # * new-method :hud
  #--------------------------------------------------------------------------#
  def hud()
    @hud ||= YGG::Handlers::HudWrapper.new()
    return @hud
  end

  #--------------------------------------------------------------------------#
  # * new-method :add_pop
  #--------------------------------------------------------------------------#
  def add_pop( poptext, x, y, z=1 )
    return unless ::YGG::USE_TEXT_POP
    pop = ::YGG::PopHandler.new( poptext, x, y, z )
    @pop_texts.push( pop )
    @new_poptexts  << pop
    return pop
  end

  #--------------------------------------------------------------------------#
  # * new-method :remove_pop
  #--------------------------------------------------------------------------#
  def remove_pop( pop_handler )
    pop_handler.force_complete!()
    @pop_texts.delete( pop_handler )
    @new_poptexts.delete( pop_handler )
    return pophandler
  end

  #--------------------------------------------------------------------------#
  # * new-method :add_projectile
  #--------------------------------------------------------------------------#
  def add_projectile( projectile )
    @projectiles << projectile
    @new_projectiles << projectile
    projectile.pro_register()
    return projectile
  end

  #--------------------------------------------------------------------------#
  # * new-method :remove_projectile
  #--------------------------------------------------------------------------#
  def remove_projectile( projectile )
    @projectiles.delete( projectile )
    @new_projectiles.delete( projectile )
    projectile.pro_unregister()
    projectile.force_terminate()
    return projectile
  end

  #--------------------------------------------------------------------------#
  # * new-method :add_battler
  #--------------------------------------------------------------------------#
  def add_battler( b ) ; @battlers |= [b] ; end

  #--------------------------------------------------------------------------#
  # * new-method :remove_battler
  #--------------------------------------------------------------------------#
  def remove_battler( b ) ; @battlers -= [b] ; end

  #--------------------------------------------------------------------------#
  # * new-method :flush_battlers
  #--------------------------------------------------------------------------#
  def flush_battlers()
    @battlers.clear()
  end

  #--------------------------------------------------------------------------#
  # * new-method :add_passage_obj
  #--------------------------------------------------------------------------#
  def add_passage_obj( obj )
    @passage_objs |= [obj]
  end

  #--------------------------------------------------------------------------#
  # * new-method :remove_passage_obj
  #--------------------------------------------------------------------------#
  def remove_passage_obj( obj )
    @passage_objs -= [obj]
  end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
  def update()
    update_poptexts()
    update_drops()
    update_roam_events()
    update_projectiles()
    update_hud()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_hud
  #--------------------------------------------------------------------------#
  def update_hud()
    self.hud.update()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_roam_events
  #--------------------------------------------------------------------------#
  def update_roam_events()
    @roam_events.each { |ev| ev.update() }
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_projectiles
  #--------------------------------------------------------------------------#
  def update_projectiles()
    @projectiles = @projectiles.inject([]) { |result, pro|
      unless pro.terminated?() ; pro.update() ; result << pro
      else ; @new_projectiles.delete( pro ) ; pro.registered = false ; end
      result
    } unless @projectiles.empty?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :pop_texts
  #--------------------------------------------------------------------------#
  def update_poptexts()
    @pop_texts = @pop_texts.inject([]) { |result, pop|
      pop.update() ; result << pop unless pop.complete?() ; result
    } unless @pop_texts.empty?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :pop_texts
  #--------------------------------------------------------------------------#
  def pop_texts() ; return @pop_texts ; end

  #--------------------------------------------------------------------------#
  # * new-method :roam_xy
  #--------------------------------------------------------------------------#
  def roam_xy( x, y )
    return (
      @roam_events +
      @passage_objs).inject([]) { |r, ev| r << ev if ev.pos?( x, y ) ; r }
  end

  #--------------------------------------------------------------------------#
  # * new-method :battlers_xy
  #--------------------------------------------------------------------------#
  def battlers_xy( x, y )
    return @battlers.inject([]) { |result, b| result << b if b.pos?( x, y ) ; result }
  end

  #--------------------------------------------------------------------------#
  # * new-method :battlers_range
  #--------------------------------------------------------------------------#
  def battlers_range( x1, y1, x2, y2 )
    return @battlers.inject([]) { |result, b|
      result << b if b.x.between?( x1, x2 ) && b.y.between?( y1, y2 ) ; result }
  end

  #--------------------------------------------------------------------------#
  # * new-method :on?
  #--------------------------------------------------------------------------#
  if ::YGG::ABS_SYSTEM_SWITCH.nil?()
    def on?() ; return true ; end
  else
    def on?() ; return $game_switches[::YGG::ABS_SYSTEM_SWITCH] ; end
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup_map
  #--------------------------------------------------------------------------#
  def setup_map( map_id )
    @map_id          = map_id
    @pop_texts     ||= [] ; @pop_texts.clear()
    @new_poptexts  ||= [] ; @new_poptexts.clear()
    @battlers      ||= [] ; @battlers.each { |b| b.ygg_unregister() } ; @battlers.clear()
    @active_drops  ||= [] ; @active_drops.clear()
    @active_ranges ||= [] ; @active_ranges.clear()
    @projectiles   ||= [] ; @projectiles.clear()
    @new_projectiles||=[] ; @new_projectiles.clear()
    @roam_events   ||= [] ; @roam_events.clear()
    @passage_objs  ||= [] ; @passage_objs.clear()
  end

  #--------------------------------------------------------------------------#
  # * new-method :get_map
  #--------------------------------------------------------------------------#
  def get_map( map_id )
    $game_map.get_map( map_id )
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup_itemmap
  #--------------------------------------------------------------------------#
  def setup_itemmap()
    if $items_map.nil?()
      $items_map = get_map( ITEMS_MAPID )
      $items_map.events.values.each { |ev| ev.pages.each { |pg|
        pg.list = YGG.parse_event_list( pg.list ) } }
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_drops
  #--------------------------------------------------------------------------#
  def create_drops( x, y, dropee )
    place_drops( x, y, dropee.items, dropee.gold )
  end

  #--------------------------------------------------------------------------#
  # * new-method :place_drops
  #--------------------------------------------------------------------------#
  def place_drops( x, y, item_set, gold = nil )
    drops = []
    for dr in item_set.compact
      cc = YGG::Drop_Character.new( dr, YGG::ITEM_FADE_TIME )
      fail_count = 0
      dx, dy = x, y
      loop do
        x_r = rand(YGG::DROP_SCATTER_DISTANCE)
        y_r = rand(YGG::DROP_SCATTER_DISTANCE)
        x_r = -x_r if rand(2) == 0
        y_r = -y_r if rand(2) == 0
        dx = x + x_r
        dy = y + y_r
        if fail_count > 20 ; break dx, dy = x, y ; end
        break if $game_map.passable?( dx, dy )
        fail_count += 1
      end
      cc.moveto( dx, dy )
      drops.push( cc )
    end
    unless gold.nil?() || gold.eql?( 0 )
      cc = YGG::Drop_Character.new( YGG::Containers::GoldItem.new( gold ), YGG::GOLD_FADE_TIME )
      cc.moveto( x, y )
      drops.push( cc )
    end
    drops.each { |char|
      @active_drops.push( char ) ;
      $scene.spriteset.add_drop_sprite( char ) if $scene.is_a?( Scene_Map )
    }
    return drops
  end

  #--------------------------------------------------------------------------#
  # * new-method :items_map
  #--------------------------------------------------------------------------#
  def items_map() ; return $items_map ; end

  #--------------------------------------------------------------------------#
  # * alias-method :update_drops
  #--------------------------------------------------------------------------#
  def update_drops()
    @active_drops = @active_drops.inject([]) { |result, dr| dr.update()
      result.push( dr ) unless dr.timeout?() ; result } unless @active_drops.empty?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :active_drops
  #--------------------------------------------------------------------------#
  def active_drops() ; return @active_drops ; end

  #--------------------------------------------------------------------------#
  # * new-method :drops_xy
  #--------------------------------------------------------------------------#
  def drops_xy( x, y )
    return self.active_drops.inject([]) { |result, dr|
      result.push(dr) if dr.pos?(x, y) ; result }
  end

end

#==============================================================================#
# // Start Yggdrasil MixIn Code
#==============================================================================#
YGG::Containers::Drops = Struct.new( :items, :gold )
#==============================================================================#
# ** YGG::MixIns::Actor
#==============================================================================#
module YGG::MixIns::Actor

  #--------------------------------------------------------------------------#
  # * new-method :create_drops_object
  #--------------------------------------------------------------------------#
  def create_drops_object()
    return ::YGG::Containers::Drops.new( [], 0 )
  end

end

#==============================================================================#
# ** YGG::MixIns::Enemy
#==============================================================================#
module YGG::MixIns::Enemy

  #--------------------------------------------------------------------------#
  # * new-method :create_drops_object
  #--------------------------------------------------------------------------#
  def create_drops_object()
    return ::YGG::Containers::Drops.new( self.all_drops, self.calc_gold )
  end

end

#==============================================================================#
# ** YGG::MixIns::Movement
#==============================================================================#
module YGG::MixIns::Movement

  #--------------------------------------------------------------------------#
  # * new-method :distance_from
  #--------------------------------------------------------------------------#
  def distance_from( obj )
    return (obj.x - self.x).abs + (obj.y - self.y).abs
  end

  #--------------------------------------------------------------------------#
  # * Jump to XY
  #--------------------------------------------------------------------------#
  def jump_to_xy( tx, ty )
    jump( tx-self.x, ty-self.y )
  end

  #--------------------------------------------------------------------------#
  # * Jump to Character
  #--------------------------------------------------------------------------#
  def jump_to_char( char )
    jump_to_xy( char.x, char.y )
  end

  #--------------------------------------------------------------------------#
  # * Jump to Event
  #--------------------------------------------------------------------------#
  def jump_to_event( event_id )
    jump_to_char( $game_map.events[event_id] )
  end

  #--------------------------------------------------------------------------#
  # * new-method :jump_forward
  #--------------------------------------------------------------------------#
  def jump_forward( amount, offset )
    case direction
    when 2
      jump( offset, amount )
    when 4
      jump( -amount, offset )
    when 6
      jump( amount, -offset )
    when 8
      jump( -offset, -amount )
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :jump_backward
  #--------------------------------------------------------------------------#
  def jump_backward( amount, offset )
    jump_forward( -amount, -offset )
  end

  #--------------------------------------------------------------------------#
  # * new-method :distance_x_from_tx
  #--------------------------------------------------------------------------#
  def distance_x_from_tx( tx )
    sx = @x - tx
    if $game_map.loop_horizontal?         # When looping horizontally
      if sx.abs > $game_map.width / 2     # Larger than half the map width?
        sx -= $game_map.width             # Subtract map width
      end
    end
    return sx
  end

  #--------------------------------------------------------------------------#
  # * new-method :distance_y_from_ty
  #--------------------------------------------------------------------------#
  def distance_y_from_ty( ty )
    sy = @y - ty
    if $game_map.loop_vertical?           # When looping vertically
      if sy.abs > $game_map.height / 2    # Larger than half the map height?
        sy -= $game_map.height            # Subtract map height
      end
    end
    return sy
  end

  #--------------------------------------------------------------------------#
  # * new-method :move_toward_xy
  #--------------------------------------------------------------------------#
  def move_toward_xy( x, y )
    move_8d = false
    sx = distance_x_from_tx(x)
    sy = distance_y_from_ty(y)
    if move_8d
      # // Need to work on it
    else
      if sx != 0 or sy != 0
        if sx.abs > sy.abs                  # Horizontal distance is longer
          sx > 0 ? move_left : move_right   # Prioritize left-right
          if @move_failed and sy != 0
            sy > 0 ? move_up : move_down
          end
        else                                # Vertical distance is longer
          sy > 0 ? move_up : move_down      # Prioritize up-down
          if @move_failed and sx != 0
            sx > 0 ? move_left : move_right
          end
        end
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :move_away_from_xy
  #--------------------------------------------------------------------------#
  def move_away_from_xy( x, y )
    move_8d = false
    sx = distance_x_from_tx(x)
    sy = distance_y_from_ty(y)
    if move_8d
      # // Need to work on it
    else
      if sx != 0 or sy != 0
        if sx.abs > sy.abs                  # Horizontal distance is longer
          sx > 0 ? move_right : move_left   # Prioritize left-right
          if @move_failed and sy != 0
            sy > 0 ? move_down : move_up
          end
        else                                # Vertical distance is longer
          sy > 0 ? move_down : move_up      # Prioritize up-down
          if @move_failed and sx != 0
            sx > 0 ? move_right : move_left
          end
        end
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :move_toward_char
  #--------------------------------------------------------------------------#
  def move_toward_char( char )
    move_toward_xy( char.x, char.y )
  end

  #--------------------------------------------------------------------------#
  # * new-method :move_away_from_xy
  #--------------------------------------------------------------------------#
  def move_away_from_char( char )
    move_away_from_xy( char.x, char.y )
  end

  #--------------------------------------------------------------------------#
  # * new-method :move_toward_event
  #--------------------------------------------------------------------------#
  def move_toward_event( event_id )
    move_toward_char( $game_map.events[event_id] )
  end

  #--------------------------------------------------------------------------#
  # * new-method :move_away_from_event
  #--------------------------------------------------------------------------#
  def move_away_from_event( event_id )
    move_away_from_char( $game_map.events[event_id] )
  end

  #--------------------------------------------------------------------------#
  # * new-method :thrust_wait
  #--------------------------------------------------------------------------#
  def thrust_wait( t=30 ) ; @wait_count = t ; end

  #--------------------------------------------------------------------------#
  # * new-method :half_down
  #--------------------------------------------------------------------------#
  def half_down( turn_ok=true )
    turn_down if turn_ok
    @y = $game_map.round_y(@y + 0.5)
    @real_y = ((@y - 0.5)*256)
    @move_failed = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :half_left
  #--------------------------------------------------------------------------#
  def half_left( turn_ok=true )
    turn_left if turn_ok
    @x = $game_map.round_x(@x-0.5)
    @real_x = ((@x+0.5)*256)
    @move_failed = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :half_right
  #--------------------------------------------------------------------------#
  def half_right( turn_ok=true )
    turn_right if turn_ok
    @x = $game_map.round_x(@x+0.5)
    @real_x = ((@x-0.5)*256)
    @move_failed = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :half_up
  #--------------------------------------------------------------------------#
  def half_up( turn_ok=true )
    turn_up if turn_ok
    @y = $game_map.round_y(@y-0.5)
    @real_y = ((@y+0.5)*256)
    @move_failed = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :half_forward
  #--------------------------------------------------------------------------#
  def half_forward()
    case @direction
    when 2 ; half_down
    when 4 ; half_left
    when 6 ; half_right
    when 8 ; half_up
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :half_backward
  #--------------------------------------------------------------------------#
  def half_backward()
    last_direction_fix = @direction_fix
    @direction_fix = true
    case @direction
    when 2;  half_up
    when 4;  half_right
    when 6;  half_left
    when 8;  half_down
    end
    @direction_fix = last_direction_fix
  end

  #--------------------------------------------------------------------------#
  # * new-method :free_move_toward_target
  #--------------------------------------------------------------------------#
  def free_move_toward_target( t_x, t_y )
    sx = fr_distance_x_from(t_x)
    sy = fr_distance_y_from(t_y)
    if sx != 0 or sy != 0
      if sx.abs > sy.abs                  # Horizontal distance is longer
        sx > 0 ? free_left : free_right   # Prioritize left-right
        if @move_failed and sy != 0
          sy > 0 ? free_up : free_down
        end
      else                                # Vertical distance is longer
        sy > 0 ? free_up : free_down      # Prioritize up-down
        if @move_failed and sx != 0
          sx > 0 ? free_left : free_right
        end
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :fr_distance_x_from
  #--------------------------------------------------------------------------#
  def fr_distance_x_from( targ_x )
    sx = self.x - targ_x
    if $game_map.loop_horizontal?         # When looping horizontally
      if sx.abs > $game_map.width / 2     # Larger than half the map width?
        sx -= $game_map.width             # Subtract map width
      end
    end
    return sx
  end

  #--------------------------------------------------------------------------#
  # * new-method :fr_distance_y_from
  #--------------------------------------------------------------------------#
  def fr_distance_y_from( targ_y )
    sy = self.y - targ_y
    if $game_map.loop_vertical?           # When looping vertically
      if sy.abs > $game_map.height / 2    # Larger than half the map height?
        sy -= $game_map.height            # Subtract map height
      end
    end
    return sy
  end

  #--------------------------------------------------------------------------#
  # * new-method :limited_down
  #--------------------------------------------------------------------------#
  def limited_down( orx, ory, limit, dist=1 )
    dist_x = fr_distance_x_from(orx)
    dist_y = fr_distance_y_from(ory) + dist
    move_down() if (dist_x.abs + dist_y.abs) < limit
    return (dist_x.abs + dist_y.abs)
  end

  #--------------------------------------------------------------------------#
  # * new-method :limited_up
  #--------------------------------------------------------------------------#
  def limited_up( orx, ory, limit, dist=1 )
    dist_x = fr_distance_x_from(orx)
    dist_y = fr_distance_y_from(ory) - dist
    move_up() if (dist_x.abs + dist_y.abs) < limit
    return (dist_x.abs + dist_y.abs)
  end

  #--------------------------------------------------------------------------#
  # * new-method :limited_left
  #--------------------------------------------------------------------------#
  def limited_left( orx, ory, limit, dist=1 )
    dist_x = fr_distance_x_from(orx) - dist
    dist_y = fr_distance_y_from(ory)
    move_left() if (dist_x.abs + dist_y.abs) < limit
    return (dist_x.abs + dist_y.abs)
  end

  #--------------------------------------------------------------------------#
  # * new-method :limited_right
  #--------------------------------------------------------------------------#
  def limited_right( orx, ory, limit, dist=1 )
    dist_x = fr_distance_x_from(orx) + dist
    dist_y = fr_distance_y_from(ory)
    move_right() if (dist_x.abs + dist_y.abs) < limit
    return (dist_x.abs + dist_y.abs)
  end

  #--------------------------------------------------------------------------#
  # * new-method :thrust_down
  #--------------------------------------------------------------------------#
  def thrust_down()
    dudspeed = @move_speed
    @move_speed = 6
    half_down()
    thrust_wait()
    half_up( false )
    @move_speed = dudspeed
  end

  #--------------------------------------------------------------------------#
  # * new-method :thrust_up
  #--------------------------------------------------------------------------#
  def thrust_up()
    dudspeed = @move_speed
    @move_speed = 6
    half_up()
    thrust_wait()
    half_down( false )
    @move_speed = dudspeed
  end

  #--------------------------------------------------------------------------#
  # * new-method :thrust_left
  #--------------------------------------------------------------------------#
  def thrust_left()
    dudspeed = @move_speed
    @move_speed = 6
    half_left()
    thrust_wait()
    half_right( false )
    @move_speed = dudspeed
  end

  #--------------------------------------------------------------------------#
  # * new-method :thrust_right
  #--------------------------------------------------------------------------#
  def thrust_right()
    dudspeed = @move_speed
    @move_speed = 6
    half_right()
    thrust_wait()
    half_left( false )
    @move_speed = dudspeed
  end

  #--------------------------------------------------------------------------#
  # * new-method :thrust_forward
  #--------------------------------------------------------------------------#
  def thrust_forward()
    case @direction
    when 2 ; thrust_down()
    when 4 ; thrust_left()
    when 6 ; thrust_right()
    when 8 ; thrust_up()
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :thrust_backward
  #--------------------------------------------------------------------------#
  def thrust_backward()
    last_direction_fix = @direction_fix
    @direction_fix = true
    case @direction
    when 2 ; thrust_up
    when 4 ; thrust_right
    when 6 ; thrust_left
    when 8 ; thrust_down
    end
    @direction_fix = last_direction_fix
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_dodge
  #--------------------------------------------------------------------------#
  def ygg_dodge()
    last_direction_fix = @direction_fix
    @direction_fix = true
    dodge_val = rand(2)
    case @direction
    when 2, 8; dodge_val == 0 ? thrust_left() : thrust_right()
    when 4, 6; dodge_val == 0 ? thrust_up() : thrust_down()
    end
    @direction_fix = last_direction_fix
  end

  #--------------------------------------------------------------------------#
  # * new-method :free_down
  #--------------------------------------------------------------------------#
  def free_down( turn_ok=true )
    if passable?(@x, @y.round.to_i+0.1)                  # Passable
      turn_down
      @y = $game_map.round_y(@y+0.1)
      @real_y = (@y-0.1)*256
      increase_steps
      @move_failed = false
    else                                    # Impassable
      turn_down if turn_ok
      check_event_trigger_touch(@x, @y.round+1)   # Touch event is triggered?
      @move_failed = true
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :free_left
  #--------------------------------------------------------------------------#
  def free_left( turn_ok=true )
    if passable?(@x.round.to_i-1, @y)                  # Passable
      turn_left
      @x = $game_map.round_x(@x-0.1)
      @real_x = (@x+0.1)*256
      increase_steps
      @move_failed = false
    else                                    # Impassable
      turn_left if turn_ok
      check_event_trigger_touch(@x.round-1, @y)   # Touch event is triggered?
      @move_failed = true
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :free_right
  #--------------------------------------------------------------------------#
  def free_right( turn_ok=true )
    if passable?(@x.round.to_i+1, @y)                  # Passable
      turn_right
      @x = $game_map.round_x(@x+0.1)
      @real_x = (@x-0.1)*256
      increase_steps
      @move_failed = false
    else                                    # Impassable
      turn_right if turn_ok
      check_event_trigger_touch(@x.round+1, @y)   # Touch event is triggered?
      @move_failed = true
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :free_up
  #--------------------------------------------------------------------------#
  def free_up( turn_ok=true )
    if passable?(@x, @y.truncate-1)                  # Passable
      turn_up
      @y = $game_map.round_y(@y-0.1)
      @real_y = (@y+0.1)*256
      increase_steps
      @move_failed = false
    else                                    # Impassable
      turn_up if turn_ok
      check_event_trigger_touch(@x, @y.truncate-1)   # Touch event is triggered?
      @move_failed = true
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :hit_away
  #--------------------------------------------------------------------------#
  def hit_away( atk_direction )
    def_speed = @move_speed
    @move_speed = 6
    case atk_direction
    when 2
      turn_up
      move_backward
    when 4
      turn_right
      move_backward
    when 6
      turn_left
      move_backward
    when 8
      turn_down
      move_backward
    end
    @move_speed = def_speed
  end

  #--------------------------------------------------------------------------#
  # * new-method :turn_to_coord
  #--------------------------------------------------------------------------#
  def turn_to_coord( sx, sy )
    if sx > self.x and sy == self.y    ; turn_right()
    elsif sx < self.x and sy == self.y ; turn_left()
    elsif sx == self.x and sy > self.y ; turn_down()
    elsif sx == self.x and sy < self.y ; turn_up()
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_origin
  #--------------------------------------------------------------------------#
  def set_origin()
    @origin ||= ::YGG::Pos.new( self.x, self.y ) ; @origin.set( self.x, self.y )
  end

  #--------------------------------------------------------------------------#
  # * new-method :get_xy_infront
  #--------------------------------------------------------------------------#
  def get_xy_infront( dist, sway )
    case direction
    when 2 # // Down
      return [x+sway, y+dist]
    when 4 # // Left
      return [x-dist, y+sway]
    when 6 # // Right
      return [x+dist, y-sway]
    when 8 # // Up
      return [x-sway, y-dist]
    end
  end

end

#==============================================================================#
# ** YGG::MixIns::Battle
#==============================================================================#
module YGG::MixIns::Battle

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :ygg_delay_max

  #--------------------------------------------------------------------------#
  # * new-method :ai_operated?
  #--------------------------------------------------------------------------#
  def ai_operated?()
    return @ai_operated
  end

  #--------------------------------------------------------------------------#
  # * new-method :hp_visible?
  #--------------------------------------------------------------------------#
  def hp_visible?()
    return $game_yggdrasil.on?() && @hp_visible
  end

  #--------------------------------------------------------------------------#
  # * new-method :mp_visible?
  #--------------------------------------------------------------------------#
  def mp_visible?()
    return $game_yggdrasil.on?() && @mp_visible
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_can_move?
  #--------------------------------------------------------------------------#
  def ygg_can_move?() ; return true ; end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_attacker | ygg_battler
  #--------------------------------------------------------------------------#
  def ygg_attacker() ; return nil ; end
  def ygg_battler()  ; return ygg_attacker() ; end

  #--------------------------------------------------------------------------#
  # * new-method :wild_type?
  #--------------------------------------------------------------------------#
  def wild_type?() ; return false ; end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_enemy?
  #--------------------------------------------------------------------------#
  def ygg_enemy?() ; return false ; end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_ally?
  #--------------------------------------------------------------------------#
  def ygg_ally?() ; return false ; end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_death
  #--------------------------------------------------------------------------#
  def ygg_death() ; end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_boss?
  #--------------------------------------------------------------------------#
  def ygg_boss?() ; return false end

  #--------------------------------------------------------------------------#
  # * new-method :process_extension_actions
  #--------------------------------------------------------------------------#
  def process_extension_actions() ; end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_can_attack?
  #--------------------------------------------------------------------------#
  def ygg_can_attack?() ; return true ; end

  #--------------------------------------------------------------------------#
  # * new-method :targetable?
  #--------------------------------------------------------------------------#
  def targetable?( target )
    return false if self.ygg_battler.nil?()
    return true if target.upcase == "ALL"
    return true if self.ygg_ally?() && target == "ALLY"
    return true if self.ygg_enemy?() && target == "ENEMY"
    return false
  end

  #--------------------------------------------------------------------------#
  # * new-method :ally_character?
  #--------------------------------------------------------------------------#
  def ally_character?( char )
    return true if self.ygg_ally?() && char.ygg_ally?()
    return true if self.ygg_enemy?() && char.ygg_enemy?()
    return false
  end

  #--------------------------------------------------------------------------#
  # * new-method :enemy_character?
  #--------------------------------------------------------------------------#
  def enemy_character?( char )
    return !ally_character?( char )
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_correct_target
  #--------------------------------------------------------------------------#
  def ygg_correct_target( target )
    return "ALLY" if self.ygg_enemy?() && target =~ /ENEMY/i
    return "ENEMY" if self.ygg_enemy?() && target =~ /ALLY/i
    return target
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_abs_update
  #--------------------------------------------------------------------------#
  def ygg_abs_update()
    @guard_time = [@guard_time - 1, 0].max
  end
# ---------------------------------------------------------------------------- #
# Calculations

  #--------------------------------------------------------------------------#
  # * new-method :Get Targets
  #--------------------------------------------------------------------------#
  # This is used to get all targets at a given location
  # l_x - x coordiante
  # l_y - y coordiante
  # target - "A", "E", "N", "W"
  # exclude_self - If the target that is encountered, happens to be the
  #                user, should they be ignored?
  #--------------------------------------------------------------------------#
  def ygg_get_targets( l_x=0, l_y=0, target="ALL", exclude_self = false )
    objects = $game_yggdrasil.battlers_xy( l_x, l_y ).inject([]) { |result, event|
      if event.targetable?( target )
        result.push( event )
      end unless (exclude_self && event == self)
      result
    }
    if $game_player.pos?( l_x, l_y ) and $game_player.targetable?( target )
      objects.push( $game_player )
    end unless (exclude_self && $game_player == self)
    return objects
  end

# ---------------------------------------------------------------------------- #
# Processes
  #--------------------------------------------------------------------------#
  # * new-method :update_battler
  #--------------------------------------------------------------------------#
  def update_battler()
    update_states()
    self.ygg_battler.update_obj_handles()
    self.ygg_battler.update_cooldown()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_states
  #--------------------------------------------------------------------------#
  def update_states()
    self.ygg_battler.update_states
  end

# ---------------------------------------------------------------------------- #
# Yggdrasil Battle Actions

  #--------------------------------------------------------------------------#
  # * new-method :get_targets_nearby
  #--------------------------------------------------------------------------#
  def get_targets_nearby( range=1, type ="ALL" )
    coords = []
    if YGG::FULL_FIELD_SCAN
      coords.concat( YGG.create_range_data( range ) )
    else
      case direction
      when 2
        for i in 0..range
          coords.push( [0, i] )
        end
      when 4
        for i in 0..range
          coords.push( [-i, 0] )
        end
      when 6
        for i in 0..range
          coords.push( [i, 0] )
        end
      when 8
        for i in 0..range
          coords.push( [0, -i] )
        end
      end
    end
    for coo in coords
      o = ygg_get_targets( coo[0]+self.x, coo[1]+self.y, type, true )
      return o unless o.empty?()
    end
    return []
  end

end

#==============================================================================#
# ** YGG::MixIns::AI
#==============================================================================#
module YGG::MixIns::AI
  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :ai_engine

  #--------------------------------------------------------------------------#
  # * new-method :setup_ai_engine
  #--------------------------------------------------------------------------#
  def setup_ai_engine( engine, setup_data={} )
    @ai_engine = engine.new( self, setup_data )
  end

  #--------------------------------------------------------------------------#
  # * new-method :terminate_ai_engine
  #--------------------------------------------------------------------------#
  def terminate_ai_engine
    @ai_engine = nil
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_update_ai
  #--------------------------------------------------------------------------#
  def ygg_update_ai
    @ai_engine.update unless @ai_engine.nil?
  end
end

#==============================================================================#
# ** YGG::MixIns::Player
#==============================================================================#
module YGG::MixIns::Player

  #--------------------------------------------------------------------------#
  # * new-method :drop_attraction?
  #--------------------------------------------------------------------------#
  def drop_attraction?()
    return self.ygg_battler.drops_attraction? unless self.ygg_battler.nil?
    return false
  end

end
#==============================================================================#
# // Mix In
class Game_Actor     ; include YGG::MixIns::Actor    ; end
class Game_Enemy     ; include YGG::MixIns::Enemy    ; end
class Game_Character ; include YGG::MixIns::Movement ; end
class Game_Character ; include YGG::MixIns::Battle   ; end
class Game_Event     ; include YGG::MixIns::AI       ; end
class Game_Player    ; include YGG::MixIns::Player   ; end
#==============================================================================#
#==============================================================================#
# ** Game_Character
#==============================================================================#
class Game_Character

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :use_equipment

  attr_accessor :ygg_atk_delay
  attr_accessor :ygg_atk_delay_max
  attr_accessor :ygg_anims

  attr_accessor :move_speed_mod
  attr_accessor :tone
  attr_accessor :zoom_x, :zoom_y
  attr_accessor :wait_count

  attr_accessor :ygg_invincible
  attr_accessor :guard_time

  attr_reader :action_handle

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ygg_gmc_mixin_initialize :initialize
  def initialize( *args, &block )
    ygg_gmc_mixin_initialize( *args, &block )
    ygg_initialize()
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_initialize
  #--------------------------------------------------------------------------#
  def ygg_initialize()
    @use_equipment     = false
    @equipment_handles = [::YGG::Handlers::Equip.new( 0 ),
                          ::YGG::Handlers::Equip.new( 1 )]
    @action_handle     = ::YGG::Handlers::Action.new( self, [] )
    @free_act_handles  = []
    @ygg_registered    = false

    @ygg_boss          = false
    @ygg_anims         = []
    @ygg_slip_counter  = 0
    @ygg_invincible    = false

    @move_speed_mod    = 0

    reset_tone()

    @zoom_x, @zoom_y   = 1.0, 1.0

    @ai_operated       = false
    @hp_visible        = true
    @mp_visible        = true

    @guard_time        = 0

    ygg_register if $game_yggdrasil.on?
  end

  #--------------------------------------------------------------------------#
  # * new-method :refresh_handles
  #--------------------------------------------------------------------------#
  def refresh_handles
    @equipment_handles.each do |hnd|
      hnd.refresh
    end
    @action_handle.parent_event = self
  end

  #--------------------------------------------------------------------------#
  # * new-method :pop_enabled?
  #--------------------------------------------------------------------------#
  def pop_enabled?() ; return true ; end

  #--------------------------------------------------------------------------#
  # * new-method :reset_tone
  #--------------------------------------------------------------------------#
  def reset_tone()
    @tone              = Tone.new( 0, 0, 0, 0 )
    @target_tone       = Tone.new( 0, 0, 0, 0 )
    @tone_time         = 60.0
  end

  #--------------------------------------------------------------------------#
  # * new-method :screen_rect
  #--------------------------------------------------------------------------#
  def screen_rect()
    @screen_rect ||= Rect.new( -32, -32, Graphics.width, Graphics.height )
    return @screen_rect
  end unless method_defined? :screen_rect

  #--------------------------------------------------------------------------#
  # * new-method :onScreen?
  #--------------------------------------------------------------------------#
  def onScreen?()
    r = self.screen_rect
    return self.screen_x.between?( r.x, r.width ) && self.screen_y.between?( r.y, r.height )
  end

  #--------------------------------------------------------------------------#
  # * new-method :limitedOnScreen?
  #--------------------------------------------------------------------------#
  def limitedOnScreen?()
    return false unless screen_x.between?( 0, Graphics.width ) && screen_y.between?( 0, Graphics.height )
    return true
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :collide_with_characters?
  #--------------------------------------------------------------------------#
  def collide_with_characters?( x, y )
    for event in $game_map.events_xy( x, y )          # Matches event position
      unless event.through                          # Passage OFF?
        return true if event.priority_type == 1     # Target is normal char
      end
    end
    if @priority_type == 1                          # Self is normal char
      return true if $game_player.pos_nt?(x, y)     # Matches player position
      return true if $game_map.boat.pos_nt?(x, y)   # Matches boat position
      return true if $game_map.ship.pos_nt?(x, y)   # Matches ship position
    end
    return false
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update_move
  #--------------------------------------------------------------------------#
  def update_move()
    distance = 2 ** self.move_speed   # Convert to movement distance
    distance *= 2 if dash?        # If dashing, double it
    @real_x = [@real_x - distance, @x * 256].max if @x * 256 < @real_x
    @real_x = [@real_x + distance, @x * 256].min if @x * 256 > @real_x
    @real_y = [@real_y - distance, @y * 256].max if @y * 256 < @real_y
    @real_y = [@real_y + distance, @y * 256].min if @y * 256 > @real_y
    update_bush_depth unless moving?
    if @walk_anime
      @anime_count += 1.5
    elsif @step_anime
      @anime_count += 1
    end
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update_animation
  #--------------------------------------------------------------------------#
  def update_animation()
    speed = self.move_speed + (dash? ? 1 : 0)
    if @anime_count > 18 - speed * 2
      if not @step_anime and @stop_count > 0
        @pattern = @original_pattern
      else
        @pattern = (@pattern + 1) % 4
      end
      @anime_count = 0
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :extra_speed_mod
  #--------------------------------------------------------------------------#
  def extra_speed_mod()
    return self.ygg_battler.nil?() ? 0 : ygg_battler.move_mod
  end

  #--------------------------------------------------------------------------#
  # * new-method :move_speed
  #--------------------------------------------------------------------------#
  def move_speed()
    return @move_speed + @move_speed_mod + extra_speed_mod
  end

  #--------------------------------------------------------------------------#
  # * new-method :equip_handle
  #--------------------------------------------------------------------------#
  def equip_handle( eq_id ) ; @equipment_handles[eq_id] ; end

  #--------------------------------------------------------------------------#
  # * new-method :equip_icon
  #--------------------------------------------------------------------------#
  def equip_icon( eq_id )
    return 0 if self.ygg_battler.nil?()
    return self.ygg_battler.equip_icon( eq_id )
  end

  #--------------------------------------------------------------------------#
  # * new-method :equip_atk_act_name
  #--------------------------------------------------------------------------#
  def equip_atk_act_name( eq_id )
    return "" if self.ygg_battler.nil?()
    return self.ygg_battler.equip_atk_act_name( eq_id )
  end

  #--------------------------------------------------------------------------#
  # * new-method :equip_grd_act_name
  #--------------------------------------------------------------------------#
  def equip_grd_act_name( eq_id )
    return "" if self.ygg_battler.nil?()
    return self.ygg_battler.equip_grd_act_name( eq_id )
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :ygg_gmc_mixin_update :update
  def update( *args, &block )
    ygg_gmc_mixin_update( *args, &block )
    if self.ygg_battler.nil?()
      ygg_unregister() if @ygg_registered
    else
      abs_on = $game_system.yggdrasil_on?()
      if abs_on
        @target_tone = self.ygg_battler.effect_tone
        if self.ygg_battler.character_need_refresh
          self.ygg_battler.character_need_refresh = false
        end
        ygg_register() unless @ygg_registered
        @equipment_handles.each { |eq|
          eq.icon_index    = self.equip_icon( eq.eq_id )
          eq.attack_action = self.equip_atk_act_name( eq.eq_id )
          eq.guard_action  = self.equip_grd_act_name( eq.eq_id )
          eq.direction     = self.direction
          eq.guard_time    = self.guard_time
          eq.update() }
        self.ygg_engage.update() unless self.ygg_engage.nil?()
        @action_handle.update()
        @free_act_handles = @free_act_handles.inject([]) { |r, h|
          h.update() ; r << h if h.busy?() ; r
        } unless @free_act_handles.empty?()
      end
    end
    [:red, :green, :blue, :gray].each { |s|
      v1, v2 = @tone.send(s), @target_tone.send(s)
      if v1 > v2
        @tone.send( s.to_s+"=", [v1-(255.0/@tone_time), v2].max )
      elsif v1 < v2
        @tone.send( s.to_s+"=", [v1+(255.0/@tone_time), v2].min )
      end
    }
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_engage
  #--------------------------------------------------------------------------#
  def ygg_engage()
    return ygg_battler.ygg_engage
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_register
  #--------------------------------------------------------------------------#
  def ygg_register()
    $game_yggdrasil.add_battler( self )
    @ygg_registered = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_unregister
  #--------------------------------------------------------------------------#
  def ygg_unregister()
    $game_yggdrasil.remove_battler( self )
    @ygg_registered = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :get_target_events
  #--------------------------------------------------------------------------#
  def get_target_events( xy_list )
    return xy_list.inject([]) { |result, point|
      result + $game_yggdrasil.battlers_xy( *point )
    }
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_through
  #--------------------------------------------------------------------------#
  def set_through( bool ) ; @through = bool ; end

end

# // (YGG_VG)
#==============================================================================#
# // Start Yggdrasil Visual Code
#==============================================================================#
# ** YGG
#==============================================================================#
module YGG
#==============================================================================#
# ** YGG::Sprites::ValueBar_Base
#==============================================================================#
  class Sprites::ValueBar_Base < ::Sprite

    BAR_DRAW_MODE = 0 # // 0 Use 2 sprites, 1 Draw onto base

    #--------------------------------------------------------------------------#
    # * super-method :initialize
    #--------------------------------------------------------------------------#
    def initialize( parent, base_name, bar_name, value_proc, max_proc )
      super( parent.viewport )
      @parent       = parent
      @base_name    = base_name
      @bar_name     = bar_name
      case BAR_DRAW_MODE
      when 0
        self.bitmap   = Cache.system( base_name )
        @bar          = ::Sprite_Base.new( self.viewport )
        @bar.bitmap   = Cache.system( bar_name )
        @bar.x        = self.x       = @parent.x
        @bar.y        = self.y       = @parent.y
        @bar.visible  = self.visible = @parent.visible
      when 1
        base_ref      = Cache.system( base_name )
        self.bitmap   = Bitmap.new( base_ref.width, base_ref.height )
      end
      @value_proc     = value_proc
      @max_proc       = max_proc
      @last_value     = -1
      @last_max       = -1
      @offsets        = ::YGG::Pos.new( 0, 0, 0 )
      @baroffsets     = ::YGG::Pos.new( 0, 0, 1 )
    end

    #--------------------------------------------------------------------------#
    # * super-method :dispose
    #--------------------------------------------------------------------------#
    def dispose()
      case BAR_DRAW_MODE
      when 0
        @bar.dispose()
      when 1
        self.bitmap.dispose()
      end
      super()
    end

  case BAR_DRAW_MODE
  when 0

    #--------------------------------------------------------------------------#
    # * super-method :update
    #--------------------------------------------------------------------------#
    def update()
      super()
      val = @value_proc.call() #* 100
      max = @max_proc.call() #* 100
      if (val != @last_value || max != @last_max)
        if max.eql?( 0 )
          @bar.src_rect.width = 0
        else
          bar_width = @bar.bitmap.width * val / max
          @bar.src_rect.width = bar_width
        end
        @last_value = val
        @last_max   = max
      end
      pox = @parent.src_rect.width / 2 - (@parent.src_rect.width +
        self.bitmap.width) / 2
      @bar.x       = @baroffsets.x + self.x       = @parent.x + pox + @offsets.x
      @bar.y       = @baroffsets.y + self.y       = @parent.y + @offsets.y
      @bar.z       = @baroffsets.z + self.z       = @parent.z + @offsets.z
      @bar.visible = self.visible# = @parent.visible
      @bar.opacity = self.opacity
    end

  when 1

    #--------------------------------------------------------------------------#
    # * super-method :update
    #--------------------------------------------------------------------------#
    def update()
      super()
      val = @value_proc.call() #* 100
      max = @max_proc.call() #* 100
      if (val != @last_value || max != @last_max)
        self.bitmap.clear()
        base = Cache.system( @base_name )
        bar  = Cache.system( @bar_name )
        self.bitmap.blt( 0, 0, base, base.rect )
        unless max.eql?( 0 )
          bar_width = bar.width * val / max
          rect = bar.rect.clone()
          rect.width = bar_width
          self.bitmap.blt( @baroffsets.x, @baroffsets.y, bar, rect )
        end
        @last_value = val
        @last_max   = max
      end
      pox = @parent.src_rect.width / 2 - (@parent.src_rect.width +
      self.bitmap.width) / 2
      self.x       = @parent.x + pox + @offsets.x
      self.y       = @parent.y + @offsets.y
      self.z       = @parent.z + @offsets.z
      #self.visible = @parent.visible
    end

  end

  end
#==============================================================================#
# ** YGG::Sprites::HpBar
#==============================================================================#
  class Sprites::HpBar < Sprites::ValueBar_Base

    #--------------------------------------------------------------------------#
    # * super-method :initialize
    #--------------------------------------------------------------------------#
    def initialize( parent )
      val_proc = Proc.new { @parent.character.ygg_attacker.hp }
      max_proc = Proc.new { @parent.character.ygg_attacker.maxhp }
      base_name= "1x6Graphics/EventBarBase"
      if parent.character.ygg_attacker.actor?()
        bar_name = "1x6Graphics/EventBar2"
      else
        bar_name = "1x6Graphics/EventBar3"
      end
      super( parent, base_name, bar_name, val_proc, max_proc )
      @offsets.set( 0, 0, 0 )
      @baroffsets.set( 1, 1, 0 )
    end

    #--------------------------------------------------------------------------#
    # * super-method :update
    #--------------------------------------------------------------------------#
    def update()
      self.opacity = @parent.character.ygg_engage.bar_opacity
      self.visible = @parent.character.hp_visible?() && @parent.visible
      super()
    end

  end
#==============================================================================#
# ** YGG::Sprites::MpBar
#==============================================================================#
  class Sprites::MpBar < Sprites::ValueBar_Base

    #--------------------------------------------------------------------------#
    # * super-method :initialize
    #--------------------------------------------------------------------------#
    def initialize( parent )
      val_proc = Proc.new { @parent.character.ygg_attacker.mp }
      max_proc = Proc.new { @parent.character.ygg_attacker.maxmp }
      base_name= "1x6Graphics/EventBarBase"
      bar_name = "1x6Graphics/EventBar5"
      super( parent, base_name, bar_name, val_proc, max_proc )
      @offsets.set( 0, 6, 0 )
      @baroffsets.set( 1, 1, 1 )
    end

    #--------------------------------------------------------------------------#
    # * super-method :update
    #--------------------------------------------------------------------------#
    def update()
      #self.opacity = @parent.character.ygg_engage.bar_opacity
      self.visible = @parent.character.mp_visible?() && @parent.visible
      super()
    end

  end

end

#==============================================================================#
# ** Sprite_Character
#==============================================================================#
class Sprite_Character < Sprite_Base

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ygg1x6_hpmp_spc_initialize :initialize
  def initialize( *args )
    ygg1x6_hpmp_spc_initialize( *args )
    create_bars()
    update_bars()
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_bars
  #--------------------------------------------------------------------------#
  def create_bars()
    unless @character.ygg_battler.nil?()
      create_hp_bar() if @hp_bar.nil?() if ::YGG::USE_HPBAR
      create_mp_bar() if @mp_bar.nil?() if ::YGG::USE_MPBAR
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_hp_bar
  #--------------------------------------------------------------------------#
  def create_hp_bar()
    return if @character.ygg_battler.nil?()
    @hp_bar = ::YGG::Sprites::HpBar.new( self )
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_mp_bar
  #--------------------------------------------------------------------------#
  def create_mp_bar()
    return if @character.ygg_battler.nil?()
    @mp_bar = ::YGG::Sprites::MpBar.new( self )
  end

  #--------------------------------------------------------------------------#
  # * alias-method :dispose
  #--------------------------------------------------------------------------#
  alias :ygg1x6_hpmp_spc_dispose :dispose
  def dispose()
    dispose_bars()
    ygg1x6_hpmp_spc_dispose()
  end

  #--------------------------------------------------------------------------#
  # * new-method :dispose_bars
  #--------------------------------------------------------------------------#
  def dispose_bars()
    dispose_hp_bar() unless @hp_bar.nil?()
    dispose_mp_bar() unless @mp_bar.nil?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :dispose_hp_bar
  #--------------------------------------------------------------------------#
  def dispose_hp_bar() ; @hp_bar.dispose() ; @hp_bar = nil ; end

  #--------------------------------------------------------------------------#
  # * new-method :dispose_mp_bar
  #--------------------------------------------------------------------------#
  def dispose_mp_bar() ; @mp_bar.dispose() ; @mp_bar = nil ; end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :ygg1x6_hpmp_spc_update :update
  def update()
    ygg1x6_hpmp_spc_update()
    update_bars() unless @character.nil?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_bars
  #--------------------------------------------------------------------------#
  def update_bars()
    update_hp_bar() unless @hp_bar.nil?()
    update_mp_bar() unless @mp_bar.nil?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_hp_bar
  #--------------------------------------------------------------------------#
  def update_hp_bar()
    if @hp_bar.nil?() && !@character.ygg_attacker.nil?()
      create_hp_bar()
    elsif !@hp_bar.nil?() && @character.ygg_attacker.nil?()
      dispose_hp_bar()
    end
    @hp_bar.update() unless @hp_bar.nil?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_mp_bar
  #--------------------------------------------------------------------------#
  def update_mp_bar()
    if @mp_bar.nil?() && !@character.ygg_attacker.nil?()
      create_mp_bar()
    elsif !@mp_bar.nil?() && @character.ygg_attacker.nil?()
      dispose_mp_bar()
    end
    @mp_bar.update() unless @mp_bar.nil?()
  end

end if ::YGG::USE_STAT_BARS

#==============================================================================#
# ** YGG
#==============================================================================#
module YGG
#==============================================================================#
# ** PopText
#==============================================================================#
  PopText = Struct.new( :text, :font, :move_rule )
#==============================================================================#
  class PopText

  #--------------------------------------------------------------------------#
  # * new-class-method :create_pop
  #--------------------------------------------------------------------------#
    def self.create_pop( setup_data={} )
      character  = setup_data[:character]
      bat        = setup_data[:battler] || (character.nil?() ? nil : character.ygg_battler)
      type       = setup_data[:type] || :nil
      parameters = setup_data[:parameters] || []
      move_rule  = :default
      pop_stack  = []
      font_size_add = 0
      case type
      when :attack_damage, :skill_damage, :item_damage
        case type
        when :attack_damage
          move_rule = bat.critical ? :shatter : :attack_default
        when :skill_damage
          move_rule = bat.critical ? :shatter : :skill_default
        when :item_damage
          move_rule = bat.critical ? :shatter : :item_default
        end
        font_size_add += ::YGG::CRITICAL_FONTSIZE_ADD if bat.critical
        if bat.hp_damage > 0
          rule = YGG::POPUP_RULES["HP_DMG"]
          text = sprintf( YGG::POPUP_SETTINGS[:hp_dmg], bat.hp_damage.abs )
        elsif bat.hp_damage < 0
          rule = YGG::POPUP_RULES["HP_HEAL"]
          text = sprintf( YGG::POPUP_SETTINGS[:hp_heal], bat.hp_damage.abs )
        elsif bat.missed
          rule = YGG::POPUP_RULES["MISSED"]
          text = YGG::POPUP_SETTINGS[:missed]
        elsif bat.evaded
          rule = YGG::POPUP_RULES["EVADED"]
          text = YGG::POPUP_SETTINGS[:evaded]
        elsif bat.skipped
          rule = YGG::POPUP_RULES["NULLED"]
          text = YGG::POPUP_SETTINGS[:nulled]
        elsif bat.hp_damage == 0
          rule = YGG::POPUP_RULES["HP_NO_DMG"]
          text = sprintf( YGG::POPUP_SETTINGS[:hp_dmg], bat.hp_damage.abs )
        end
        pop_stack << [text, rule, move_rule]
        pop_stack << [YGG::POPUP_SETTINGS[:critical],
                      YGG::POPUP_RULES["CRITICAL"],
                      :crit_default] if bat.critical if YGG::SHOW_CRITICAL
        pop_stack << [POPUP_SETTINGS[:guard],
                      YGG::POPUP_RULES["GUARD"],
                      :guard_default] if bat.guarding?() if YGG::SHOW_GUARD
        if type == :skill_damage || type == :item_damage
          skip_stack = false
          if bat.mp_damage > 0
            rule = YGG::POPUP_RULES["MP_DMG"]
            text = sprintf( YGG::POPUP_SETTINGS[:mp_dmg], bat.mp_damage.abs )
          elsif bat.mp_damage < 0
            rule = YGG::POPUP_RULES["MP_HEAL"]
            text = sprintf( YGG::POPUP_SETTINGS[:mp_heal], bat.mp_damage.abs )
          elsif bat.missed
            skip_stack = true
            #rule = YGG::POPUP_RULES["MISSED"]
            #text = YGG::POPUP_SETTINGS[:missed]
          elsif bat.evaded
            skip_stack = true
            #rule = YGG::POPUP_RULES["EVADED"]
            #text = YGG::POPUP_SETTINGS[:evaded]
          elsif bat.skipped
            skip_stack = true
            #rule = YGG::POPUP_RULES["NULLED"]
            #text = YGG::POPUP_SETTINGS[:nulled]
          elsif bat.mp_damage == 0
            skip_stack = true
          #  rule = YGG::POPUP_RULES["MP_NO_DMG"]
          #  text = sprintf( YGG::POPUP_SETTINGS[:mp_dmg], bat.mp_damage.abs )
          end
          pop_stack << [text, rule, move_rule] unless skip_stack
        end
      when :gain_exp
        rule = YGG::POPUP_RULES["EXP_POP"]
        text = sprintf( YGG::POPUP_SETTINGS[:exp_pop], parameters[0] )
        move_rule = :exp_default
        pop_stack << [text, rule, move_rule]
      when :level_up
        rule = YGG::POPUP_RULES["LVL_POP"]
        text = sprintf( YGG::POPUP_SETTINGS[:lvl_pop], parameters[0] )
        move_rule = :lvl_default
        pop_stack << [text, rule, move_rule]
      when :custom
        rule = [
          setup_data[:font_size] || Font.default_size,
          setup_data[:font_color] || Font.default_color,
          setup_data[:font_name] || Font.default_name,
          [(setup_data[:font_bold] || Font.default_bold) ? "BOLD" : "NO BOLD",
           (setup_data[:font_italic] || Font.default_italic) ? "ITALIC" : "NO ITALIC",
           (setup_data[:font_shadow] || Font.default_shadow) ? "SHADOW" : "NO SHADOW"
          ],
          setup_data[:font_name]
        ]
        pop_stack << [setup_data[:text] || "", rule, setup_data[:move_rule] || :default]
      end
      pop_stack.each { |pop|
        text, rule, move_rule = *pop
        font        = Font.new()
        proprule    = rule[2].inject([]) { |r, s| s.upcase }
        colors      = rule[1].kind_of?( Array ) ? rule[1] : [rule[1], rule[1]]
        font.name   = rule[3].empty? ? Font.default_name : rule[3]
        font.size   = (rule[0] || Font.default_size) + font_size_add
        font.bold   = proprule.include?("BOLD")
        font.italic = proprule.include?("ITALIC")
        font.shadow = proprule.include?("SHADOW")
        font.bold   = false if proprule.include?("NO BOLD")
        font.italic = false if proprule.include?("NO ITALIC")
        font.shadow = false if proprule.include?("NO SHADOW")
        font.color  = bat.nil?() ? colors[1] : (bat.actor?() ? colors[1] : colors[0])
        $game_yggdrasil.add_pop( PopText.new( text, font, move_rule ), character.x, character.y )
      }
    end

  end

#==============================================================================#
# ** PopHandler
#==============================================================================#
  class PopHandler < ::YGG::Handlers::Screen

    class BounceHandle

    #--------------------------------------------------------------------------#
    # * Public Instance Variable(s)
    #--------------------------------------------------------------------------#
      attr_accessor :x, :y
      attr_accessor :ox, :oy

      attr_accessor :x_velocity, :y_velocity
      attr_accessor :x_boost, :y_boost
      attr_accessor :x_add, :y_add

      attr_accessor :cap_duration
      attr_accessor :finished
      attr_accessor :pause_update
      attr_accessor :gravity
      attr_accessor :floor_val

    #--------------------------------------------------------------------------#
    # * Constant(s)
    #--------------------------------------------------------------------------#
      GRAVITY = 0.58
      TRANSEPARENT_START = 0
      TRANSEPARENT_X_SLIDE = 0

    #--------------------------------------------------------------------------#
    # * new-method :initialize
    #--------------------------------------------------------------------------#
      def initialize( setup_data={} )
        @start_settings = [setup_data[:x] || 0, setup_data[:y] || 0, 0, 0]
        @cap_duration = setup_data[:cap_duration] || 80
        @x_velocity = setup_data[:x_velocity] || 0.4
        @y_velocity = setup_data[:y_velocity] || 1.5
        @x_boost    = setup_data[:x_boost] || 8
        @y_boost    = setup_data[:y_boost] || 4
        @x_add      = setup_data[:x_add] || 0
        @y_add      = setup_data[:y_add] || 4
        @gravity    = setup_data[:gravity] || GRAVITY
        @floor_val  = setup_data[:floor_val] || 0
        reset()
      end

    #--------------------------------------------------------------------------#
    # * new-method :reset
    #--------------------------------------------------------------------------#
      def reset()
        @x, @y, @ox, @oy = *@start_settings
        @finished = false
        @pause_update = false
        prep_pop()
      end

    #--------------------------------------------------------------------------#
    # * new-method :x_init_velocity
    #--------------------------------------------------------------------------#
      def x_init_velocity()
        return @x_velocity * ( rand(@x_boost) + @x_add )
      end

    #--------------------------------------------------------------------------#
    # * new-method :y_init_velocity
    #--------------------------------------------------------------------------#
      def y_init_velocity()
        return @y_velocity * ( rand(@y_boost) + @y_add )
      end

    #--------------------------------------------------------------------------#
    # * new-method :prep_pop
    #--------------------------------------------------------------------------#
      def prep_pop()
        @now_x_speed = x_init_velocity
        @now_y_speed = y_init_velocity
        @potential_x_energy = 0.0
        @potential_y_energy = 0.0
        @speed_off_x = rand(2)
        @pop_duration = @cap_duration
      end

    #--------------------------------------------------------------------------#
    # * new-method :update
    #--------------------------------------------------------------------------#
      def update()
        return if @finished or @pause_update
        if @pop_duration <= TRANSEPARENT_START
          @x += TRANSEPARENT_X_SLIDE if @speed_off_x == 0
          @x -= TRANSEPARENT_X_SLIDE if @speed_off_x == 1
        end
        n = @oy + @now_y_speed
        if n <= @floor_val #0
          @now_y_speed *= -1
          @now_y_speed /=  2
          @now_x_speed /=  2
        end
        @oy = [n, @floor_val].max
        @potential_y_energy += @gravity
        speed                = @potential_y_energy.floor
        @now_y_speed        -= speed
        @potential_y_energy -= speed
        @potential_x_energy += @now_x_speed
        speed                = @potential_x_energy.floor
        @ox                 += speed if @speed_off_x == 0
        @ox                 -= speed if @speed_off_x == 1
        @potential_x_energy -= speed
        @pop_duration       -= 1
        if @pop_duration == 0
          @finished = true
        end
      end

    end

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
    attr_accessor :ox, :oy, :oz
    attr_accessor :width, :height
    attr_accessor :zoom_x, :zoom_y
    attr_accessor :opacity

    attr_accessor :poptext
    attr_accessor :completed

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
    def initialize( poptext, x, y, z )
      super( x, y, z )
      @frame     = 0
      @poptext   = poptext
      @ox        = 0
      @oy        = 0
      @oz        = 0
      @width     = 128
      @height    = 32
      @opacity   = 255
      @zoom_x    = 1.0
      @zoom_y    = 1.0
      @completed = false
      @bounce_handle = BounceHandle.new( { :x => 0, :y => 0 } )
    end

  #--------------------------------------------------------------------------#
  # * new-method :complete?()
  #--------------------------------------------------------------------------#
    def complete?() ; return @completed ; end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
    def update()
      case @poptext.move_rule
      when :default
        case @frame
        when 0..10
          @ox += 2
        when 11..20
          @ox -= 2
        when 21..40
          @oy -= 2
        when 41..60
          @oy -= 4
          @opacity -= 255 / 20
        when 61
          @completed = true
        end
      when :attack_default, :skill_default, :item_default
        @bounce_handle.update()
        @ox, @oy = @bounce_handle.ox, -@bounce_handle.oy
        @completed = @bounce_handle.finished
      when :exp_default
        case @frame
        when 0...1
          @oy -= 16
        when 1..32
          @oy += 1
        when 33..64
          @opacity -= 255 / 32
        when 65
          @completed = true
        end
      when :lvl_default
        case @frame
        when 0..64
          @ox -= 1
        when 65..96
          @opacity -= 255 / 32
        when 97
          @completed = true
        end
      when :crit_default
        case @frame
        when 0...1
          @oy -= 16
        when 1..32
          @oy -= 2
          @zoom_x += 1.0 / 32
          @zoom_y = @zoom_x
        when 33..64
          @opacity -= 255 / 32
          @zoom_x -= 1.0 / 32
          @zoom_y = @zoom_x
        when 65
          @completed = true
        end
      when :guard_default
        case @frame
        when 0...1
          @oy -= 16
        when 1..32
          @oy -= 2
          @zoom_x += 0.5 / 32
          @zoom_y = @zoom_x
        when 33..64
          @opacity -= 255 / 32
          @zoom_x -= 0.5 / 32
          @zoom_y = @zoom_x
        when 65
          @completed = true
        end
      when :shatter
        case @frame
        when 0..5
          @ox += 3
        when 6..10
          @ox -= 3
        when 11..30
          @ox += 3
          @oy -= 1
          @opacity -= 255 / 80
        when 31..50
          @ox -= 3
          @oy -= 1
          @opacity -= 255 / 80
        when 51..60
          @opacity -= 255 / 40
        when 61
          @completed = true
        end
      end
      @frame += 1
    end

  #--------------------------------------------------------------------------#
  # * new-method :screen_|x/y/z
  #--------------------------------------------------------------------------#
    def screen_x() ; return super() + @ox      ; end
    def screen_y() ; return super() + @oy + 32 ; end
    def screen_z() ; return super() + @oz      ; end

  end

#==============================================================================#
# ** PopSprite
#==============================================================================#
  class PopSprite < ::Sprite

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
    attr_accessor :pophandler
    attr_accessor :completed

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
    def initialize( viewport, pophandler )
      super( viewport )
      @pophandler      = pophandler
      self.bitmap      = Bitmap.new( @pophandler.width, @pophandler.height )
      self.ox          = @pophandler.width / 2
      self.bitmap.font = @pophandler.poptext.font.clone
      self.bitmap.draw_text( 0, 0, @pophandler.width, 24, @pophandler.poptext.text, 1 )
    end

  #--------------------------------------------------------------------------#
  # * new-method :dispose
  #--------------------------------------------------------------------------#
    def dispose()
      @pophandler = nil
      unless self.bitmap.nil?()
        self.bitmap.font = Font.new()
        self.bitmap.dispose()
      end
      self.bitmap = nil
      super()
    end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
    def update()
      super()
      self.x       = @pophandler.screen_x
      self.y       = @pophandler.screen_y
      self.z       = @pophandler.screen_z
      self.zoom_x  = @pophandler.zoom_x
      self.zoom_y  = @pophandler.zoom_y
      self.opacity = @pophandler.opacity
      @completed   = @pophandler.completed
    end

  end
#==============================================================================#
# ** PopSpriteset
#==============================================================================#
  class PopSpriteset

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
    def initialize( viewport )
      @viewport = viewport
      @pop_sprites = []
      create_pops()
    end

  #--------------------------------------------------------------------------#
  # * new-method :create_pops
  #--------------------------------------------------------------------------#
    def create_pops()
      $game_yggdrasil.new_poptexts.clear()
      $game_yggdrasil.pop_texts.each { |hnd| add_pop( hnd ) }
    end

  #--------------------------------------------------------------------------#
  # * new-method :dispose
  #--------------------------------------------------------------------------#
    def dispose()
      @pop_sprites.each { |sp| sp.dispose() }
      @pop_sprites.clear()
    end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
    def update()
      unless $game_yggdrasil.new_poptexts.empty?()
        $game_yggdrasil.new_poptexts.each { |hnd| add_pop( hnd ) }
        $game_yggdrasil.new_poptexts.clear()
      end
      @pop_sprites = @pop_sprites.inject([]) { |result, sprite|
        sprite.update() ; sprite.dispose() if sprite.completed
        result << sprite unless sprite.disposed?() ; result
      } unless @pop_sprites.empty?()
    end

  #--------------------------------------------------------------------------#
  # * new-method :add_pop
  #--------------------------------------------------------------------------#
    def add_pop( pophandler )
      @pop_sprites << PopSprite.new( @viewport, pophandler )
    end

  end

end

#==============================================================================#
# ** Spriteset_Map
#==============================================================================#
class Spriteset_Map

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :poptext_spriteset

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  alias :ygg_spm_ptxt_initialize :initialize
  def initialize( *args, &block )
    ygg_spm_ptxt_initialize( *args, &block )
    create_poptext_spriteset()
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_poptext_spriteset
  #--------------------------------------------------------------------------#
  def create_poptext_spriteset()
    @poptext_spriteset = YGG::PopSpriteset.new( @viewport2 )
  end

  #--------------------------------------------------------------------------#
  # * alias-method :dispose
  #--------------------------------------------------------------------------#
  alias :ygg_spm_ptxt_dispose :dispose
  def dispose( *args, &block )
    @poptext_spriteset.dispose() unless @poptext_spriteset.nil?()
    ygg_spm_ptxt_dispose( *args, &block )
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :ygg_spm_ptxt_update :update
  def update( *args, &block )
    ygg_spm_ptxt_update( *args, &block )
    @poptext_spriteset.update() unless @poptext_spriteset.nil?()
  end

end if ::YGG::USE_TEXT_POP

# // (YGG_DropsWindow)
#==============================================================================#
# ** YGG::Drops_Window
#==============================================================================#
class YGG::Drops_Window < ::Sprite

  #--------------------------------------------------------------------------#
  # * Constant(s)
  #--------------------------------------------------------------------------#
  CHANGE_MAX  = 90  # 120
  FADE_LIMIT  = 30  # 30
  FADE_SPEED  = 40  # 60
  WLH         = 24
  BORDER_SIZE = 2

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :cleared

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( setup_data={}, viewport=nil )
    super( viewport )
    width = setup_data[:width] || 128
    @background = Sprite.new( self.viewport )
    @background.bitmap = Bitmap.new( width, WLH )
    @background.bitmap.fill_rect( BORDER_SIZE, BORDER_SIZE,
      width-(BORDER_SIZE*2), WLH-(BORDER_SIZE*2),
      Color.new( 0, 0, 0 ) )
    @background.bitmap.blur() ; @background.bitmap.blur()
    @background.opacity = 198
    self.bitmap = Bitmap.new( width, WLH )
    self.src_rect.set( 0, 0, width, WLH )
    @change_time = 0
    @cleared = false
    self.x, self.y, self.z = setup_data[:x] || 0, setup_data[:y] || 0, setup_data[:z] || 200
  end

  #--------------------------------------------------------------------------#
  # * super-method :dispose
  #--------------------------------------------------------------------------#
  def dispose()
    unless @background.nil?()
      @background.bitmap.dispose() ; @background.dispose()
    end
    self.bitmap.dispose()
    super()
  end

  #--------------------------------------------------------------------------#
  # * super-method :x=
  #--------------------------------------------------------------------------#
  def x=( new_x )
    super( new_x )
    @background.x = self.x
  end

  #--------------------------------------------------------------------------#
  # * super-method :y=
  #--------------------------------------------------------------------------#
  def y=( new_y )
    super( new_y )
    @background.y = self.y
  end

  #--------------------------------------------------------------------------#
  # * super-method :z=
  #--------------------------------------------------------------------------#
  def z=( new_z )
    super( new_z+1 )
    @background.z = new_z
  end

  #--------------------------------------------------------------------------#
  # * super-method :viewport=
  #--------------------------------------------------------------------------#
  def viewport=( new_viewport )
    super( new_viewport )
    @background.viewport = self.viewport
  end

  #--------------------------------------------------------------------------#
  # * super-method :visible=
  #--------------------------------------------------------------------------#
  def visible=( new_visible )
    super( new_visible )
    @background.visible = self.visible
  end

  #--------------------------------------------------------------------------#
  # * new-method :draw_icon
  #--------------------------------------------------------------------------#
  def draw_icon( icon_index, x, y, enabled = true )
    bitmap = Cache.system( "Iconset" )
    rect = Rect.new( icon_index % 16 * 24, icon_index / 16 * 24, 24, 24 )
    self.bitmap.blt( x, y, bitmap, rect, enabled ? 255 : 128 )
  end unless method_defined? :draw_icon

  #--------------------------------------------------------------------------#
  # * new-method :draw_currency_value
  #--------------------------------------------------------------------------#
  def draw_currency_value( value, x, y, width )
    cx = self.bitmap.text_size( Vocab::gold ).width
    self.bitmap.font.color = Color.new( 255, 255, 255 )
    self.bitmap.draw_text( x, y, width-cx-2, WLH, value, 2 )
    self.bitmap.font.color = Color.new( 255, 255, 176 )
    self.bitmap.draw_text( x, y, width, WLH, Vocab::gold, 2 )
  end unless method_defined? :draw_currency_value

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
  def update()
    super()
    @change_time -= 1 unless @change_time == 0
    if @change_time <= FADE_LIMIT
      self.opacity -= 255.0 / FADE_SPEED
    else
      self.opacity += 255.0 / FADE_SPEED
    end
    if @change_time <= 0
      unless @cleared
        self.bitmap.clear()
        @cleared = true
      end
      unless $game_player.ygg_gained_items.empty?
        obj = $game_player.ygg_gained_items.shift
        draw_icon( obj.icon_index, 4, 0 )
        self.bitmap.font.color = Color.new( 255, 255, 255 )
        self.bitmap.font.size  = 18
        self.bitmap.draw_text( 28, 0, self.width + 32, WLH, obj.name )
        if obj.is_a?( ::YGG::Containers::GoldItem )
          cc = obj.gold_amount
          draw_currency_value( cc, 0, 0, self.width - 4 )
        end
        @cleared = false
        @change_time = CHANGE_MAX
      end
    end
  end

end

#==============================================================================#
# ** YGG::Sprites::Animation
#==============================================================================#
class YGG::Sprites::Animation < ::YGG::Handlers::Screen

  #--------------------------------------------------------------------------#
  # * Constants
  #--------------------------------------------------------------------------#
  RATE = 3 # // RMVX Default is 4
  RATE = ::Sprite_Base::RATE if $imported["IEO-BugFixesUpgrades"] || $imported["CoreFixesUpgradesMelody"]

  #--------------------------------------------------------------------------#
  # * Class Variable(s)
  #--------------------------------------------------------------------------#
  @@animations = []
  @@_reference_count = {}

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :completed
  attr_accessor :looped_anim
  attr_accessor :started_anim
  attr_accessor :viewport
  attr_accessor :ox, :oy
  attr_accessor :opacity

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( viewport=nil )
    super( 0, 0, 0 )
    @viewport           = viewport
    @animation          = nil
    @animation_bitmap1  = nil
    @animation_bitmap2  = nil
    @animation_duration = 0     # Remaining animation time
    @started_anim       = false
    @looped_anim        = false
    @completed          = true
    @targets            = []
    @ox, @oy            = -16, -32
    @opacity            = 255
  end

  #--------------------------------------------------------------------------#
  # * new-method :animation?
  #--------------------------------------------------------------------------#
  def animation? ; return !@animation.nil?() ; end

  #--------------------------------------------------------------------------#
  # * new-method :width
  #--------------------------------------------------------------------------#
  def width ; return 32 ; end

  #--------------------------------------------------------------------------#
  # * new-method :height
  #--------------------------------------------------------------------------#
  def height ; return 32 ; end

  #--------------------------------------------------------------------------#
  # * new-method :cell_limit
  #--------------------------------------------------------------------------#
  def cell_limit ; 4 ; end

  #--------------------------------------------------------------------------#
  # * new-method :flash
  #--------------------------------------------------------------------------#
  def flash( color, duration )
    @targets.each { |sp| sp.flash( color, duration ) unless sp.disposed?() }
  end

  #--------------------------------------------------------------------------#
  # * new-method :screen_rect
  #--------------------------------------------------------------------------#
  def screen_rect()
    @screen_rect ||= Rect.new( -32, -32, Graphics.width, Graphics.height )
    return @screen_rect
  end

  #--------------------------------------------------------------------------#
  # * new-method :onScreen?
  #--------------------------------------------------------------------------#
  def onScreen?()
    r = self.screen_rect
    return self.screen_x.between?( r.x, r.width ) && self.screen_y.between?( r.y, r.height )
  end

  #--------------------------------------------------------------------------#
  # * new-method :limitedOnScreen?
  #--------------------------------------------------------------------------#
  def limitedOnScreen?()
    return false unless screen_x.between?( 0, Graphics.width ) && screen_y.between?( 0, Graphics.height )
    return true
  end

  #--------------------------------------------------------------------------#
  # * new-method :play_anim
  #--------------------------------------------------------------------------#
  def play_anim( anim_id, targets=[] )
    set_targets( targets ) ; animation = $data_animations[anim_id]
    raise "Animation #{anim_id} does not exist" if ::YGG.debug_mode?() && animation.nil?()
    animation = RPG::Animation.new if animation.nil?() if ::YGG.silent_error?()
    start_animation( animation )
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup_pos
  #--------------------------------------------------------------------------#
  def setup_pos( x, y, looped = false )
    self.moveto( x, y )
    @looped_anim = looped
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_targets
  #--------------------------------------------------------------------------#
  def set_targets( new_targets )
    @targets.clear() ; @targets += new_targets
    @targets = @targets.flatten.uniq.compact
  end

  #--------------------------------------------------------------------------#
  # * new-method :load_animation_bitmap
  #--------------------------------------------------------------------------#
  def load_animation_bitmap()
    animation1_name    = @animation.animation1_name
    animation1_hue     = @animation.animation1_hue
    animation2_name    = @animation.animation2_name
    animation2_hue     = @animation.animation2_hue
    @animation_bitmap1 = Cache.animation(animation1_name, animation1_hue)
    @animation_bitmap2 = Cache.animation(animation2_name, animation2_hue)
    if @@_reference_count.include?(@animation_bitmap1)
      @@_reference_count[@animation_bitmap1] += 1
    else
      @@_reference_count[@animation_bitmap1] = 1
    end
    if @@_reference_count.include?(@animation_bitmap2)
      @@_reference_count[@animation_bitmap2] += 1
    else
      @@_reference_count[@animation_bitmap2] = 1
    end
    Graphics.frame_reset()
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :start_animation
  #--------------------------------------------------------------------------#
  def start_animation(animation, mirror = false)
    dispose_animation
    @animation = animation
    return if @animation.nil?
    @animation_mirror = mirror
    @animation_duration = @animation.frame_max * RATE + 1
    load_animation_bitmap
    @animation_sprites = []
    @cell_count = [animation.cell_count, self.cell_limit].min
    if @animation.position != 3 || !@@animations.include?(animation)
      for i in 0...@cell_count
        sprite = ::Sprite.new(viewport)
        sprite.visible = false
        @animation_sprites.push(sprite)
      end
      unless @@animations.include?(animation)
        @@animations.push(animation)
      end
    end
    update_animation_position
    @started_anim = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :dispose
  #--------------------------------------------------------------------------#
  def dispose() ; dispose_animation() ; end

  #--------------------------------------------------------------------------#
  # * new-method :dispose_animation
  #--------------------------------------------------------------------------#
  def dispose_animation()
    if @animation_bitmap1 != nil
      @@_reference_count[@animation_bitmap1] -= 1
      if @@_reference_count[@animation_bitmap1] == 0
        @animation_bitmap1.dispose
      end
    end
    if @animation_bitmap2 != nil
      @@_reference_count[@animation_bitmap2] -= 1
      if @@_reference_count[@animation_bitmap2] == 0
        @animation_bitmap2.dispose()
      end
    end
    @animation_sprites.each { |sprite| sprite.dispose } unless @animation_sprites.nil?()
    @animation_sprites = nil
    @animation = nil
    @animation_bitmap1 = nil
    @animation_bitmap2 = nil
  end

  #--------------------------------------------------------------------------#
  # * new-method: update
  #--------------------------------------------------------------------------#
  def update()
    update_animation() if @animation != nil
    @@animations.clear
  end

  #--------------------------------------------------------------------------#
  # * new-method: update_animation
  #--------------------------------------------------------------------------#
  def update_animation()
    @animation_duration -= 1
    update_animation_position() if @animation_duration > 0
    return unless @animation_duration % RATE == 0
    if @animation_duration > 0
      frame_index = @animation.frame_max - ((@animation_duration+RATE-1)/RATE)
      animation_set_sprites( @animation.frames[frame_index] )
      for timing in @animation.timings
        next unless timing.frame == frame_index
        animation_process_timing( timing )
      end
      return
    end
    return start_animation( @animation ) if @looped_anim
    dispose_animation()
  end

  #--------------------------------------------------------------------------#
  # * new-method :animation_set_sprites
  #--------------------------------------------------------------------------#
  def animation_set_sprites( frame )
    cell_data = frame.cell_data
    for i in 0...@cell_count
      sprite = @animation_sprites[i]
      next if sprite.nil?()
      pattern = cell_data[i, 0]
      if pattern == nil or pattern == -1
        sprite.visible = false
        next
      end
      unless self.onScreen?()
        sprite.visible = false
        next
      end
      if pattern < 100
        sprite.bitmap = @animation_bitmap1
      else
        sprite.bitmap = @animation_bitmap2
      end
      sprite.visible = true
      sprite.src_rect.set( pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192 )
      if @animation_mirror
        sprite.x = @animation_ox - cell_data[i, 1]
        sprite.y = @animation_oy + cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x = @animation_ox + cell_data[i, 1]
        sprite.y = @animation_oy + cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      sprite.z = self.screen_z + 300 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method: animation_process_timing
  #--------------------------------------------------------------------------#
  def animation_process_timing( timing )
    timing.se.play()
    case timing.flash_scope
    when 1
      self.flash( timing.flash_color, timing.flash_duration * RATE )
    when 2
      self.viewport.flash( timing.flash_color, timing.flash_duration * RATE ) unless self.viewport.nil?()
    when 3
      self.flash( nil, timing.flash_duration * RATE )
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_animation_position
  #--------------------------------------------------------------------------#
  def update_animation_position()
    unless self.onScreen?()
      @animation_ox = -Graphics.width
      @animation_oy = -Graphics.height
      return
    end
    if @animation.position == 3
      if self.viewport.nil?()
        @animation_ox = Integer(Graphics.width) / 2
        @animation_oy = Integer(Graphics.height) / 2
      else
        @animation_ox = self.viewport.rect.width / 2
        @animation_oy = self.viewport.rect.height / 2
      end
    else
      @animation_ox = self.screen_x + self.ox + self.width / 2
      @animation_oy = self.screen_y + self.oy + self.height / 2
      if @animation.position == 0
        @animation_oy -= self.height / 2
      elsif @animation.position == 2
        @animation_oy += self.height / 2
      end
    end
  end

end

#==============================================================================#
# ** YGG::Sprites::Pos
#==============================================================================#
class YGG::Sprites::Pos < ::Sprite

# // Customize Start
  #--------------------------------------------------------------------------#
  # * Constant(s)
  #--------------------------------------------------------------------------#
  COLOR1    = Color.new( 128, 128, 255 ) # Main Color
  COLOR2    = Color.new( 255, 178, 178 ) # Flash Color
  FLASHTIME = 60
# // Customize End
  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :completed
  attr_accessor :pos_data

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( pos_data, viewport = nil )
    @completed    = false
    super( viewport )
    @use_sprite = true
    @pos_data = pos_data
    self.x = @pos_data.screen_x ; self.y = @pos_data.screen_y
    self.z = 1
    self.bitmap = Bitmap.new( 32, 32 )
    rect = Rect.new(1, 1, 30, 30)
    self.bitmap.fill_rect( rect, COLOR1 )
    self.ox = 16 ; self.oy = 32
  end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
  def update()
    return if @completed
    self.x = @pos_data.screen_x()
    self.y = @pos_data.screen_y()
    self.z = @pos_data.screen_z()
    case @pos_data.fader_type
    when 0
      self.opacity -= 255 / @pos_data.fade_max
      @pos_data.fade_amount -= 1 unless @pos_data.fade_amount == 0
      @completed = true if @pos_data.fade_amount == 0
    end
    super()
  end

end

#==============================================================================#
# ** YGG::Sprites::Icon
#==============================================================================#
class YGG::Sprites::Icon < ::Sprite

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  ICON_WIDTH  = 24
  ICON_HEIGHT = 24

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :ref_object

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( viewport, ref_object )
    super( viewport )
    @ref_object = ref_object
    self.bitmap = Cache.system( "Iconset" )
    @icon_index = -1
    update_bitmap()
  end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
  def update()
    super() ; update_bitmap() ; update_position()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_position
  #--------------------------------------------------------------------------#
  def update_position()
    self.x = @ref_object.screen_x
    self.y = @ref_object.screen_y
    self.z = @ref_object.screen_z
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_bitmap
  #--------------------------------------------------------------------------#
  def update_bitmap()
    if @ref_object.icon_index != @icon_index
      @icon_index = @ref_object.icon_index
      self.src_rect.set(
       @icon_index % 16 * ICON_WIDTH ,
       @icon_index / 16 * ICON_HEIGHT,
       ICON_WIDTH, ICON_HEIGHT )
    end
  end

end

#==============================================================================#
# ** YGG::Sprites::EquipIcon
#==============================================================================#
class YGG::Sprites::EquipIcon < ::YGG::Sprites::Icon

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( viewport, character, eqhnd_id )
    @eqhnd_id = eqhnd_id
    @parent   = character
    super( viewport, equip_handle() )
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :equip_handle
  #--------------------------------------------------------------------------#
  def equip_handle() ; return @parent.character.equip_handle( @eqhnd_id ) ; end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update_position
  #--------------------------------------------------------------------------#
  def update_position()
    self.ox, self.oy = @ref_object.sox, @ref_object.soy
    self.x = @parent.x + @ref_object.ox
    self.y = @parent.y + @ref_object.oy
    self.z = @parent.z + @ref_object.oz
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_angle
  #--------------------------------------------------------------------------#
  def update_angle()
    self.angle  = @ref_object.angle
    self.mirror = @ref_object.mirror
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_visible
  #--------------------------------------------------------------------------#
  def update_visible()
    self.visible = @ref_object.visible
    self.opacity = @ref_object.opacity
  end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
  def update()
    @ref_object = equip_handle()
    super()
    update_angle()
    update_visible()
  end

end

#==============================================================================#
# ** YGG::Sprites::CharacterIcon
#==============================================================================#
class YGG::Sprites::CharacterIcon < ::YGG::Sprites::Icon

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :self_timeout

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( viewport, character = nil )
    super( viewport, character )
    @icon_index = 0
    self.ox = 12
    self.oy = 24
    @ready_to_remove = false
    @self_timeout = 120
    update
  end

  #--------------------------------------------------------------------------#
  # * new-method :ready_to_remove?
  #--------------------------------------------------------------------------#
  def ready_to_remove?() ; return @ready_to_remove ; end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
  def update()
    super()
    @self_timeout    = @ref_object.icon_time_out
    @ready_to_remove = true if @self_timeout == 0
    self.visible     = @ref_object.visible
    self.opacity     = @ref_object.opacity
  end

end

#==============================================================================#
# ** Sprite_Character
#==============================================================================#
class Sprite_Character < Sprite_Base

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ygg_spc_initialize :initialize
  def initialize( *args, &block )
    ygg_spc_initialize( *args, &block )
    create_equipment()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :dispose
  #--------------------------------------------------------------------------#
  alias :ygg_spc_dispose :dispose
  def dispose( *args, &block )
    ygg_spc_dispose( *args, &block )
    dispose_equipment()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :ygg_spc_update :update
  def update( *args, &block )
    ygg_spc_update( *args, &block )
    unless @equipment.nil?()
      if @character.use_equipment && @equipment.empty?() ; create_equipment()
      elsif !@character.use_equipment && !@equipment.empty?() ; dispose_equipment()
      end
      update_equipment()
    end
    if $scene.is_a?( Scene_Map )
      @character.ygg_anims.each { |aid| $scene.push_ygg_anim( aid, @character.x, @character.y ) }
      @character.ygg_anims.clear()
    end
    self.tone = @character.tone
    self.zoom_x = @character.zoom_x
    self.zoom_y = @character.zoom_y
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_equipment
  #--------------------------------------------------------------------------#
  def create_equipment()
    @equipment = []
    if @character.use_equipment
      @equipment[0] = YGG::Sprites::EquipIcon.new( self.viewport, self, 0 ) # Weap
      @equipment[1] = YGG::Sprites::EquipIcon.new( self.viewport, self, 1 ) # Shld
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :dispose_equipment
  #--------------------------------------------------------------------------#
  def dispose_equipment()
    @equipment.each { |e| e.dispose() } ; @equipment.clear()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_equipment
  #--------------------------------------------------------------------------#
  def update_equipment() ; @equipment.each { |e| e.update() } ; end

end

#==============================================================================#
# ** YGG::Sprites::Projectile
#==============================================================================#
class ::YGG::Sprites::Projectile < Sprite_Character

  #--------------------------------------------------------------------------#
  # * overwrite-method :create_bars
  #--------------------------------------------------------------------------#
  def create_bars()  ; end

  #--------------------------------------------------------------------------#
  # * overwrite-method :dispose_bars
  #--------------------------------------------------------------------------#
  def dispose_bars() ; end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update_bars
  #--------------------------------------------------------------------------#
  def update_bars()  ; end

end

#==============================================================================#
# ** Spriteset_Map
#==============================================================================#
class Spriteset_Map

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :anim_viewport # Viewport used by Ygg Anims
  attr_accessor :character_sprites
  attr_accessor :projectile_sprites
  attr_accessor :range_sprites
  attr_accessor :drop_sprites
  attr_accessor :ygg_anims
  attr_accessor :viewport1, :viewport2, :viewport3

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ygg_anim_ssm_initialize :initialize
  def initialize( *args, &block )
    ygg_anim_ssm_initialize( *args, &block )
    @disposed = false
    create_projectiles()
    create_anims()
    create_ranges()
    create_drops()
  end

  #--------------------------------------------------------------------------#
  # * new-method :get_character
  #--------------------------------------------------------------------------#
  def get_character( ev )
    @character_sprites.each { |s| return s if s.character == ev }
  end

  #--------------------------------------------------------------------------#
  # * new-method :disposed?
  #--------------------------------------------------------------------------#
  def disposed?() ; return @disposed ; end

  #--------------------------------------------------------------------------#
  # * alias-method :dispose
  #--------------------------------------------------------------------------#
  alias :ygg_anim_ssm_dispose :dispose
  def dispose( *args, &block )
    ygg_anim_ssm_dispose( *args, &block )
    @projectile_sprites.each { |spr| ; spr.dispose() } unless @projectile_sprites.nil?()
    @ygg_anims.each { |anim| ; anim.dispose()        } unless @ygg_anims.nil?()
    @range_sprites.each { |rng| ; rng.dispose()      } unless @range_sprites.nil?()
    @drop_sprites.each { |dr| ; dr.dispose()         } unless @drop_sprites.nil?()
    @projectile_sprites = nil ; @ygg_anims          = nil
    @range_sprites      = nil ; @drop_sprites       = nil
    @disposed = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_drops
  #--------------------------------------------------------------------------#
  def create_drops()
    drops = $game_map.active_drops
    @drop_sprites = drops.inject([]) { |result, char|
      spr = YGG::Sprites::CharacterIcon.new( @viewport1, char )
      spr.self_timeout = char.icon_time_out
      result.push( spr )
    }
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_ranges
  #--------------------------------------------------------------------------#
  def create_ranges()
    @range_sprites = $game_map.active_ranges.inject([]) { |result, range|
      result.push( YGG::Sprites::Pos.new( range, @viewport1 ) )
    }
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_projectiles
  #--------------------------------------------------------------------------#
  def create_projectiles()
    @projectile_sprites = []
    $game_yggdrasil.new_projectiles.clear()
    $game_yggdrasil.projectiles.each { |pro| add_projectile_sprite( pro ) }
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_anims
  #--------------------------------------------------------------------------#
  def create_anims()
    @ygg_anims = []
    for i in 0...YGG::TOTAL_WILD_ANIMS
      anim = ::YGG::Sprites::Animation.new( @anim_viewport )
      @ygg_anims.push( anim )
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :push_anim
  #--------------------------------------------------------------------------#
  def push_anim( anim_id, x, y, targets=[], looped=false )
    return if @disposed
    for anim in @ygg_anims#.compact()
      unless anim.animation?
        anim.setup_pos( x, y, looped )
        anim.play_anim( anim_id,
          targets.inject([]) { |r, e| r << get_character( e ) } )
        return anim
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :add_projectile_sprite
  #--------------------------------------------------------------------------#
  def add_projectile_sprite( projectile )
    return if @disposed
    return nil if projectile.nil?()
    spr = ::YGG::Sprites::Projectile.new( @viewport1, projectile )
    @projectile_sprites.push( spr )
    return spr
  end

  #--------------------------------------------------------------------------#
  # * new-method :range
  #--------------------------------------------------------------------------#
  def add_range_sprite( range )
    return if @disposed
    return nil if range.nil?()
    sprite = ::YGG::Sprites::Pos.new( range, @viewport1 )
    @range_sprites.push( sprite )
    return spr
  end

  #--------------------------------------------------------------------------#
  # * new-method :add_drop_sprite
  #--------------------------------------------------------------------------#
  def add_drop_sprite( char )
    return if @disposed
    return nil if char.nil?()
    spr = YGG::Sprites::CharacterIcon.new( @viewport1, char )
    spr.self_timeout = char.icon_time_out
    @drop_sprites.push( spr )
    return spr
  end

  #--------------------------------------------------------------------------#
  # * alias-method :create_viewports
  #--------------------------------------------------------------------------#
  alias :ygg_anim_ssm_create_viewports :create_viewports
  def create_viewports( *args, &block )
    ygg_anim_ssm_create_viewports( *args, &block )
    @anim_viewport = Viewport.new( 0, 0, Graphics.width, Graphics.height )
    @anim_viewport.z = 100
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :ygg_anim_ssm_update :update
  def update( *args, &block )
    return if @disposed
    ygg_anim_ssm_update( *args, &block )
    update_anims()       unless @ygg_anims.nil?()
    update_projectiles() unless @projectile_sprites.nil?()
    update_ranges()      unless @range_sprites.nil?()
    update_drops()       unless @drop_sprites.nil?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_anims
  #--------------------------------------------------------------------------#
  def update_anims()
    @ygg_anims.each { |anim| anim.update() if anim.animation?() }
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_projectiles
  #--------------------------------------------------------------------------#
  def update_projectiles()
    unless $game_yggdrasil.new_projectiles.empty?()
      $game_yggdrasil.new_projectiles.each { |pro| add_projectile_sprite( pro ) }
      $game_yggdrasil.new_projectiles.clear()
    end
    @projectile_sprites = @projectile_sprites.inject([]) { |result, spr|
      spr.update() ; spr.dispose() if spr.character.terminated?()
      result << spr unless spr.disposed?() ; result
    } unless @projectile_sprites.empty?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_ranges
  #--------------------------------------------------------------------------#
  def update_ranges()
    @range_sprites = @range_sprites.inject([]) { |result, rng|
      ran.update()
      if ran.completed()
        $game_map.active_ranges.delete( ran.pos_data ) ; ran.dispose()
      else ; ran.update() ; end
      result << rng unless ran.disposed?() ; result
    } unless @range_sprites.empty?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_drops
  #--------------------------------------------------------------------------#
  def update_drops()
    @drop_sprites = @drop_sprites.inject([]) { |result, dr|
      dr.ready_to_remove?() ? dr.dispose() : dr.update()
      result << dr unless dr.disposed?() ; result
    } unless @drop_sprites.empty?()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update_viewports
  #--------------------------------------------------------------------------#
  alias :ygg_anim_ssm_update_viewports :update_viewports
  def update_viewports( *args, &block )
    ygg_anim_ssm_update_viewports( *args, &block )
    @anim_viewport.update() unless @anim_viewport.nil?()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :dispose_viewports
  #--------------------------------------------------------------------------#
  alias :ygg_anim_ssm_dispose_viewports :dispose_viewports
  def dispose_viewports( *args, &block )
    ygg_anim_ssm_dispose_viewports( *args, &block )
    @anim_viewport.dispose() unless @anim_viewport.nil?() ; @anim_viewport = nil
  end

end

# // (YGG_SC) - System Code
#==============================================================================#
# // Start Yggdrasil Main Code
#==============================================================================#
# ** Game System
#==============================================================================#
class Game_System

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :ygg_hit_count
  attr_accessor :ygg_hit_down_wait

  attr_accessor :draw_damage_ranges
  attr_accessor :gameover_alldead

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ygg_gs_initialize :initialize
  def initialize( *args, &block )
    ygg_gs_initialize( *args, &block )
    @ygg_hit_count      = 0
    @ygg_hit_down_wait  = 0
    @draw_damage_ranges = YGG::DRAW_RANGES
    @gameover_alldead   = YGG::ALL_DEAD_GAMEOVER
  end

  #--------------------------------------------------------------------------#
  # * new-method :gameover_alldead?
  #--------------------------------------------------------------------------#
  def gameover_alldead?() ; return @gameover_alldead end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :ygg_gs_update :update
  def update( *args, &block )
    ygg_gs_update( *args, &block )
    unless $game_message.visible
      @ygg_hit_down_wait -= 1 unless @ygg_hit_down_wait == 0
      @ygg_hit_count = 0 if @ygg_hit_down_wait == 0
    end if $scene.is_a?( Scene_Map )
  end

  #--------------------------------------------------------------------------#
  # * mew-method :control_self_switch
  #--------------------------------------------------------------------------#
  def control_self_switch( map_id, event_id, switch, value )
    $game_self_switches[[map_id, event_id, switch]] = value
    $game_map.need_refresh = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :yggdrasil_on?
  #--------------------------------------------------------------------------#
  def yggdrasil_on?() ; return $game_yggdrasil.on?() ; end

end

#==============================================================================#
# ** Game Battler
#==============================================================================#
class Game_Battler

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :character_need_refresh
  attr_accessor :ygg_slip_counter

  attr_accessor :ygg_engage

  attr_accessor :skill_slot_size, :item_slot_size

  attr_accessor :ygg_guard

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ygg_gb_initialize :initialize
  def initialize( *args, &block )
    ygg_gb_initialize( *args, &block )
    @state_ticks      = {}
    @ygg_slip_counter = 0
    @ygg_engage       = ::YGG::Handlers::Engage.new( self )
    @skill_slot_size, @item_slot_size =  5, 5
    @skill_slots    , @item_slots     = [], []
    @skill_handles  , @item_handles   = {}, {}
    @ygg_guard = false
    @cooldown, @cooldown_max, = 0, 300
    clear_stat_cache()
    clear_item_slots()
    clear_skill_slots()
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :skill_can_use?
  #--------------------------------------------------------------------------#
  def skill_can_use?( skill )
    return false unless skill.is_a?( RPG::Skill )
    return false unless movable?()
    return false if silent?() and skill.spi_f > 0
    return false if calc_mp_cost( skill ) > mp
    if $game_temp.in_battle
      return skill.battle_ok?()
    elsif $game_system.yggdrasil_on?() and $scene.is_a?( Scene_Map )
      return skill.battle_ok?()
    else
      return skill.menu_ok?()
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :guarding?
  #--------------------------------------------------------------------------#
  def guarding?()
    return @action.guard?() || @ygg_guard
  end

  #--------------------------------------------------------------------------#
  # * new-method :get_action_by_id
  #--------------------------------------------------------------------------#
  def get_action_by_id( id )
    return []
  end

  #--------------------------------------------------------------------------#
  # ** new-method :ygg_range
  #--------------------------------------------------------------------------#
  def ygg_range ; return 0 end

  #--------------------------------------------------------------------------#
  # ** new-method :drops_attraction?
  #--------------------------------------------------------------------------#
  def drops_attraction? ; return false end

  #--------------------------------------------------------------------------#
  # ** new-method :equip_icon
  #--------------------------------------------------------------------------#
  def equip_icon( eq_id ) ; return 0 ; end

  #--------------------------------------------------------------------------#
  # * new-method :equip_atk_act_name
  #--------------------------------------------------------------------------#
  def equip_atk_act_name( eq_id ) ; return "" ; end

  #--------------------------------------------------------------------------#
  # * new-method :equip_grd_act_name
  #--------------------------------------------------------------------------#
  def equip_grd_act_name( eq_id ) ; return "" ; end

  #--------------------------------------------------------------------------#
  # * alias-method :maxhp/maxmp/atk/def/spi/agi
  #--------------------------------------------------------------------------#
  [:maxhp, :maxmp, :atk, :def, :spi, :agi].each { |m|
    module_eval( %Q(
    alias :ygg_gb_#{m.to_s} #{m}
    def #{m.to_s}( *args, &block )
      @cached_#{m.to_s} ||= ygg_gb_#{m.to_s}( *args, &block )
      return @cached_#{m.to_s}
    end

    alias :ygg_gb_#{m.to_s}_set #{m}=
    def #{m.to_s}=( new_value )
      @cached_#{m.to_s} = nil if new_value != @cached_#{m.to_s}
      ygg_gb_#{m.to_s}_set( new_value )
    end
    ) )
  }

  #--------------------------------------------------------------------------#
  # * new-method :clear_stat_cache
  #--------------------------------------------------------------------------#
  def clear_stat_cache()
    @cached_maxhp = nil
    @cached_maxmp = nil
    @cached_atk   = nil
    @cached_def   = nil
    @cached_spi   = nil
    @cached_agi   = nil

    @cached_move  = nil
    @cached_tone  = nil
    @cached_slip  = nil
    @cached_slip_freq = nil

    @cached_level_exp = nil
    @cached_next_level_exp = nil

    @character_need_refresh = true
  end

  #--------------------------------------------------------------------------#
  # * alias-method :recover_all
  #--------------------------------------------------------------------------#
  alias :ygg_gb_recover_all :recover_all
  def recover_all( *args, &block )
    clear_stat_cache()
    ygg_gb_recover_all( *args, &block )
  end

if ::YGG::FULL_INTEGRATION

  #--------------------------------------------------------------------------#
  # * alias-method :add_state
  #--------------------------------------------------------------------------#
  alias :ygg_gb_fi_add_state :add_state
  def add_state( state_id )
    sti = state_ignore?( state_id )
    ygg_gb_fi_add_state( state_id )
    state = $data_states[state_id]
    return if state.nil?() ; return if sti
    @state_ticks[state_id] = state.hold_ticks unless state.id == 1
  end

  #--------------------------------------------------------------------------#
  # * alias-method :remove_state
  #--------------------------------------------------------------------------#
  alias :ygg_gb_fi_remove_state :remove_state
  def remove_state( state_id )
    ygg_gb_fi_remove_state( state_id )
    @state_ticks.delete( state_id )
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update_state_ticks
  #--------------------------------------------------------------------------#
  def update_state_ticks()
    @state_ticks.keys.clone.each { |key|
      state = $data_states[key]
      if state.nil?() ; @state_ticks.delete(key) ; next ; end
      @state_ticks[key] -= 1
      remove_state( key ) if @state_ticks[key] < 0 && rand(100) < state.auto_release_prob
    }
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :slip_damage?
  #--------------------------------------------------------------------------#
  def slip_damage?()
    @cached_slip ||= self.states.any?() { |s| s.slip_damage }
    return @cached_slip
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :slip_damage_effect
  #--------------------------------------------------------------------------#
  def slip_damage_effect()
    self.hp -= 1 if slip_damage? and @hp > 0
  end

end # // Full Integration

  #--------------------------------------------------------------------------#
  # * overwrite-method :item_growth_effect
  #--------------------------------------------------------------------------#
  def item_growth_effect( user, item )
    if item.parameter_type > 0 and item.parameter_points != 0
      case item.parameter_type
      when 1  # Maximum HP
        @maxhp_plus += item.parameter_points
        @cached_maxhp = nil
      when 2  # Maximum MP
        @maxmp_plus += item.parameter_points
        @cached_maxmp = nil
      when 3  # Attack
        @atk_plus += item.parameter_points
        @cached_atk = nil
      when 4  # Defense
        @def_plus += item.parameter_points
        @cached_def = nil
      when 5  # Spirit
        @spi_plus += item.parameter_points
        @cached_spi = nil
      when 6  # Agility
        @agi_plus += item.parameter_points
        @cached_agi = nil
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * alias-method :add_state
  #--------------------------------------------------------------------------#
  alias :ygg_gb_add_state :add_state
  def add_state( *args, &block )
    old_states = self.states
    ygg_gb_add_state( *args, &block )
    clear_stat_cache() unless self.states == old_states
  end

  #--------------------------------------------------------------------------#
  # * alias-method :remove_state
  #--------------------------------------------------------------------------#
  alias :ygg_gb_remove_state :remove_state
  def remove_state( *args, &block )
    old_states = self.states
    ygg_gb_remove_state( *args, &block )
    clear_stat_cache() unless self.states == old_states
  end

  #--------------------------------------------------------------------------#
  # * new-method :move_mod
  #--------------------------------------------------------------------------#
  def move_mod()
    @cached_move ||= self.states.inject(0) { |r, s| r+s.move_mod }
    return @cached_move
  end

  #--------------------------------------------------------------------------#
  # * new-method :effect_tone
  #--------------------------------------------------------------------------#
  def effect_tone()
    if @cached_tone.nil?()
      @cached_tone = ::Tone.new( 0, 0, 0, 0 )
      self.states.each { |s|
        if s.tone_effect ; @cached_tone = s.effect_tone ; break ; end }
    end
    return @cached_tone
  end

  #--------------------------------------------------------------------------#
  # * new-method :slip_frequency
  #--------------------------------------------------------------------------#
  def slip_frequency()
    if @cached_slip_freq.nil?()
      r = 1 ; count = 1
      self.states.each { |s|
        if s.slip_freq != 0
          count += 1 ; r += s.slip_freq
        end
      }
      @cached_slip_freq = r / count
    end
    return @cached_slip_freq
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_states
  #--------------------------------------------------------------------------#
if ::YGG::FULL_INTEGRATION

  def update_states()
    update_state_ticks()
    update_slip_damage()  if (Graphics.frame_count % slip_frequency) == 0
  end

else

  def update_states()
    @ygg_slip_counter = [@ygg_slip_counter-1, 0].max
    if @ygg_slip_counter == 0
      remove_states_auto() ; update_slip_damage()
      @ygg_slip_counter = YGG::STATE_TURN_COUNTER
    end
  end

end

  #--------------------------------------------------------------------------#
  # * new-method :update_slip_damage
  #--------------------------------------------------------------------------#
  def update_slip_damage()
    if slip_damage?()
      slip_damage_effect() ; self.ygg_engage.engage( 30 )
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :skill_slot_valid?
  #--------------------------------------------------------------------------#
  def skill_slot_valid?( i )
    return i.between?( 0, @skill_slot_size-1 )
  end

  #--------------------------------------------------------------------------#
  # * new-method :item_slot_valid?
  #--------------------------------------------------------------------------#
  def item_slot_valid?( i )
    return i.between?( 0, @item_slot_size-1 )
  end

  #--------------------------------------------------------------------------#
  # * new-method :skill_slot
  #--------------------------------------------------------------------------#
  def skill_slot( i )
    return nil unless skill_slot_valid?( i )
    return $data_skills[(@skill_slots[i].obj_id)]
  end

  #--------------------------------------------------------------------------#
  # * new-method :skill_slots
  #--------------------------------------------------------------------------#
  def skill_slot_skills()
    result = []
    @skill_slot_size.times { |i| result << skill_slot( i ) } ; return result
  end

  #--------------------------------------------------------------------------#
  # * new-method :item_slot
  #--------------------------------------------------------------------------#
  def item_slot( i )
    return nil unless item_slot_valid?( i )
    return $data_items[(@item_slots[i].obj_id)]
  end

  #--------------------------------------------------------------------------#
  # * new-method :item_slot_items
  #--------------------------------------------------------------------------#
  def item_slot_items()
    result = []
    @item_slot_size.times { |i| result << item_slot( i ) } ; return result
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_skill_slot
  #--------------------------------------------------------------------------#
  def set_skill_slot( i, sid )
    return unless skill_slot_valid?( i )
    @skill_slots[i] = get_skill_handle( sid )
  end

  #--------------------------------------------------------------------------#
  # * new-method :set_item_slot
  #--------------------------------------------------------------------------#
  def set_item_slot( i, iid )
    return unless item_slot_valid?( i )
    @item_slots[i] = get_item_handle( iid )
  end

  #--------------------------------------------------------------------------#
  # * new-method :clear_skill_slots
  #--------------------------------------------------------------------------#
  def clear_skill_slots()
    @skill_slot_size.times { |i| set_skill_slot( i, 0 ) }
  end

  #--------------------------------------------------------------------------#
  # * new-method :clear_item_slots
  #--------------------------------------------------------------------------#
  def clear_item_slots()
    @item_slot_size.times { |i| set_item_slot( i, 0 ) }
  end

  #--------------------------------------------------------------------------#
  # * new-method :get_skill_handle
  #--------------------------------------------------------------------------#
  def get_skill_handle( sid )
    @skill_handles[sid] ||= ::YGG::Handlers::BattleObj.new( sid, :skill )
    return @skill_handles[sid]
  end

  #--------------------------------------------------------------------------#
  # * new-method :get_item_handle
  #--------------------------------------------------------------------------#
  def get_item_handle( iid )
    @item_handles[iid] ||= ::YGG::Handlers::BattleObj.new( iid, :item )
    return @item_handles[iid]
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_obj_handles
  #--------------------------------------------------------------------------#
  def update_obj_handles()
    (@skill_slots+@item_slots).each { |hnd| hnd.update() }
  end

  #--------------------------------------------------------------------------#
  # * new-method :cooldown
  #--------------------------------------------------------------------------#
  attr_reader :cooldown

  #--------------------------------------------------------------------------#
  # * new-method :cooldown=
  #--------------------------------------------------------------------------#
  def cooldown=( cool )
    @cooldown = [cool, @cooldown_max].min
  end

  #--------------------------------------------------------------------------#
  # * new-method :cooldown_max
  #--------------------------------------------------------------------------#
  def cooldown_max() ; @cooldown_max ; end

  #--------------------------------------------------------------------------#
  # * new-method :cap_cooldown
  #--------------------------------------------------------------------------#
  def cap_cooldown()
    @cooldown = @cooldown_max
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_cooldown
  #--------------------------------------------------------------------------#
  def update_cooldown()
    @cooldown = [@cooldown - 1, 0].max
  end

  #--------------------------------------------------------------------------#
  # * new-method :cooling_down?
  #--------------------------------------------------------------------------#
  def cooling_down?() ; return @cooldown > 0 ; end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_can_attack?
  #--------------------------------------------------------------------------#
  def ygg_can_attack?() ;
    return false if cooling_down?()
    return true
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_skill_can_use?
  #--------------------------------------------------------------------------#
  def ygg_skill_can_use?( obj )
    return false if cooling_down?()
    return false unless skill_can_use?( obj )
    return get_skill_handle( obj.id ).can_use?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_item_can_use?
  #--------------------------------------------------------------------------#
  def ygg_item_can_use?( obj )
    return false if cooling_down?()
    return false unless item_can_use?( obj )
    return get_item_handle( obj.id ).can_use?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :item_can_use?
  #--------------------------------------------------------------------------#
  def item_can_use?( obj )
    return $game_party.item_can_use?( obj )
  end unless method_defined? :item_can_use?

  #--------------------------------------------------------------------------#
  # * new-method :ygg_use_skill
  #--------------------------------------------------------------------------#
  def ygg_use_skill( obj )
    self.mp -= calc_mp_cost( obj )
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_use_item
  #--------------------------------------------------------------------------#
  def ygg_use_item( obj )
    $game_party.consume_item( obj )
  end

end

#==============================================================================#
# ** Game Actor
#==============================================================================#
class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------#
  # * alias-method :level_up
  #--------------------------------------------------------------------------#
  alias :ygg_gb_level_up :level_up
  def level_up( *args, &block )
    clear_stat_cache()
    ygg_gb_level_up( *args, &block )
    clear_stat_cache()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :level_down
  #--------------------------------------------------------------------------#
  alias :ygg_gb_level_down :level_down
  def level_down( *args, &block )
    clear_stat_cache()
    ygg_gb_level_down( *args, &block )
    clear_stat_cache()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :change_equip
  #--------------------------------------------------------------------------#
  alias :ygg_gb_change_equip :change_equip
  def change_equip( *args, &block )
    clear_stat_cache()
    ygg_gb_change_equip( *args, &block )
    clear_stat_cache()
  end

  #--------------------------------------------------------------------------#
  # * ygg_target_range
  #--------------------------------------------------------------------------#
  def ygg_target_range()
    eq = weapons[0]
    eq.nil?() ? 0 : eq.ygg_target_range
  end

  #--------------------------------------------------------------------------#
  # * new-method :drops_attraction?
  #--------------------------------------------------------------------------#
  def drops_attraction?() ; equips.compact.any? { |eq| eq.drops_attraction?() } ; end

  #--------------------------------------------------------------------------#
  # * new-method :equip_icon
  #--------------------------------------------------------------------------#
  def equip_icon( eq_id )
    if self.two_swords_style
      weps = weapons
      return weps[eq_id].nil?() ? 0 : weps[eq_id].icon_index
    else
      weps = [weapons[0], armors[0]]
      return weps[eq_id].nil?() ? 0 : weps[eq_id].icon_index
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :equip_atk_act_name
  #--------------------------------------------------------------------------#
  def equip_atk_act_name( eq_id )
    if self.two_swords_style
      weps = weapons
    else
      weps = [weapons[0], armors[0]]
    end
    return weps[eq_id].nil?() ? "" : weps[eq_id].atk_act_name
  end

  #--------------------------------------------------------------------------#
  # * new-method :equip_grd_act_name
  #--------------------------------------------------------------------------#
  def equip_grd_act_name( eq_id )
    if self.two_swords_style
      weps = weapons
    else
      weps = [weapons[0], armors[0]]
    end
    return weps[eq_id].nil?() ? "" : weps[eq_id].grd_act_name
  end

  #--------------------------------------------------------------------------#
  # * alias-method :change_exp
  #--------------------------------------------------------------------------#
  alias :ygg_gb_change_exp :change_exp
  def change_exp( *args, &block )
    ygg_gb_change_exp( *args, &block )
    @cached_level_exp = nil
    @cached_next_level_exp = nil
  end

  #--------------------------------------------------------------------------#
  # * new-method :level_exp
  #--------------------------------------------------------------------------#
  def level_exp()
    @cached_level_exp ||= @exp - @exp_list[@level]
    return @cached_level_exp
  end

  #--------------------------------------------------------------------------#
  # * new-method :next_level_exp
  #--------------------------------------------------------------------------#
  def next_level_exp()
    @cached_next_level_exp ||= @exp_list[@level+1] - @exp_list[@level]
    return @cached_next_level_exp
  end

end

#==============================================================================#
# ** Game Enemy
#==============================================================================#
class Game_Enemy < Game_Battler

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ygg_gmen_initialize :initialize
  def initialize( *args, &block )
    ygg_gmen_initialize( *args, &block )
    @skill_slot_size = 0
    skillz = []
    enemy.actions.each { |act| if act.kind == 1 ; skillz << act.skill_id ; end }
    @skill_slot_size = skillz.size
    for i in 0...@skill_slot_size ; set_skill_slot( i, skillz[i] ) ; end
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :use_equipment
  #--------------------------------------------------------------------------#
  def use_equipment() ; return enemy.use_equipment ; end

  #--------------------------------------------------------------------------#
  # * new-method :equip_icon
  #--------------------------------------------------------------------------#
  def equip_icon( eq_id )
    return enemy.equip_icons[eq_id]
  end

  #--------------------------------------------------------------------------#
  # * new-method :equip_atk_act_name
  #--------------------------------------------------------------------------#
  def equip_atk_act_name( eq_id )
    return enemy.atk_act_name
  end

  #--------------------------------------------------------------------------#
  # * new-method :equip_grd_act_name
  #--------------------------------------------------------------------------#
  def equip_grd_act_name( eq_id )
    return enemy.grd_act_name
  end

  #--------------------------------------------------------------------------#
  # * new-method :calc_gold
  #--------------------------------------------------------------------------#
  def calc_gold()
    return Integer( YGG::Random.variation( gold, enemy.gold_variation ) )
  end

  #--------------------------------------------------------------------------#
  # * new-method :gain_exp
  #--------------------------------------------------------------------------#
  def gain_exp( exp, show ) ; end unless method_defined? :gain_exp

  #--------------------------------------------------------------------------#
  # * new-method :get_action_by_id
  #--------------------------------------------------------------------------#
  def get_action_by_id( id )
    return enemy.ygg_actions[id]
  end

  #--------------------------------------------------------------------------#
  # * new-method :all_drops
  #--------------------------------------------------------------------------#
  def all_drops()
    dro = []
    for di in self.enemy.drop_items.compact
      next if di.kind == 0 ; next if rand(di.denominator) != 0
      case di.kind
      when 1 ; dro.push($data_items[di.item_id])
      when 2 ; dro.push($data_weapons[di.weapon_id])
      when 3 ; dro.push($data_armors[di.armor_id])
      end
    end
    more_drops.compact.each { |mri|
      for num in 1..mri[2] ; dro.push(mri[0]) if rand(mri[1]).to_i == 0 ; end
    } if $imported["IEX_Rand_Drop"]
    return dro
  end

  #--------------------------------------------------------------------------#
  # * new-method :atk_animation_id
  #--------------------------------------------------------------------------#
  def atk_animation_id ; return enemy.atk_animation_id ; end

  #--------------------------------------------------------------------------#
  # * new-method :atk_animation_id2
  #--------------------------------------------------------------------------#
  def atk_animation_id2 ; return enemy.atk_animation_id2 ; end

end

#==============================================================================#
# ** Game_Party
#==============================================================================#
class Game_Party

  #--------------------------------------------------------------------------#
  # * alias-method :on_player_walk
  #--------------------------------------------------------------------------#
  alias :ygg1x6_gmpt_on_player_walk :on_player_walk
  def on_player_walk( *args, &block )
    unless $game_system.yggdrasil_on?()
      ygg1x6_gmpt_on_player_walk( *args, &block )
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_slip_damage
  #--------------------------------------------------------------------------#
  def ygg_slip_damage()
    ($game_party.members-[$game_player.ygg_battler]).each { |m| m.update_states() }
  end

end

#==============================================================================#
# ** Game Map
#==============================================================================#
class Game_Map

  #--------------------------------------------------------------------------#
  # * new-method :get_map
  #--------------------------------------------------------------------------#
  def get_map( map_id )
    return load_data( sprintf("Data/Map%03d.rvdata", map_id) )
  end unless method_defined? :get_map

  #--------------------------------------------------------------------------#
  # * alias-method :events_xy
  #--------------------------------------------------------------------------#
  alias :ygg_gmm_events_xy :events_xy
  def events_xy( x, y )
    return ygg_gmm_events_xy( x, y ) + $game_yggdrasil.roam_xy( x, y )
  end

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :ygg_gmm_setup :setup
  def setup( *args, &block )
    $game_player.ygg_unregister()
    ygg_gmm_setup( *args, &block )
    ygg_setup()
    $game_player.ygg_register()
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_setup
  #--------------------------------------------------------------------------#
  def ygg_setup()
    $game_yggdrasil.setup_map( self.map_id )
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup_itemmap
  #--------------------------------------------------------------------------#
  def setup_itemmap()
    $game_yggdrasil.setup_itemmap()
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_drops
  #--------------------------------------------------------------------------#
  def create_drops( x, y, dropee )
    $game_yggdrasil.create_drops( x, y, dropee )
  end

  #--------------------------------------------------------------------------#
  # * new-method :place_drops
  #--------------------------------------------------------------------------#
  def place_drops( x, y, item_set, gold = nil )
    return $game_yggdrasil.place_drops( x, y, item_set, gold )
  end

  #--------------------------------------------------------------------------#
  # * new-method :items_map
  #--------------------------------------------------------------------------#
  def items_map() ; return $items_map ; end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  #alias :ygg_gm_update :update
  #def update( *args, &block )
  #  ygg_gm_update( *args, &block )
  #  update_drops()
  #end

  #--------------------------------------------------------------------------#
  # * new-method :active_drops
  #--------------------------------------------------------------------------#
  def active_drops() ; return $game_yggdrasil.active_drops ; end

  #--------------------------------------------------------------------------#
  # * new-method :active_ranges
  #--------------------------------------------------------------------------#
  def active_ranges() ; return $game_yggdrasil.active_ranges ; end

  #--------------------------------------------------------------------------#
  # * new-method :projectiles
  #--------------------------------------------------------------------------#
  def projectiles() ; return $game_yggdrasil.projectiles ; end

  #--------------------------------------------------------------------------#
  # * new-method :drops_xy
  #--------------------------------------------------------------------------#
  def drops_xy( x, y )
    return $game_yggdrasil.drops_xy( x, y )
  end

end

#==============================================================================#
# ** Game Event
#==============================================================================#
class Game_Event < Game_Character

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ygg_ge_initialize :initialize
  def initialize( *args, &block )
    ygg_ge_initialize( *args, &block )
    @ai_operated        = true
  end

  #--------------------------------------------------------------------------#
  # * alias-method :erase
  #--------------------------------------------------------------------------#
  alias :ygg_gme_erase :erase
  def erase( *args, &block )
    terminate_ai_engine()
    ygg_unregister() ; ygg_gme_erase( *args, &block )
  end

  #--------------------------------------------------------------------------#
  # * alias-method :setup
  #--------------------------------------------------------------------------#
  alias :ygg_gme_setup :setup
  def setup( *args, &block )
    @dont_scan_events = YGG::DONT_SCAN_EVENTS
    @ygg_cache_complete = false
    ygg_gme_setup( *args, &block )
    ygg_event_cache()
  end

  #--------------------------------------------------------------------------#
  # * new-method :pop_enabled?
  #--------------------------------------------------------------------------#
  def pop_enabled?()
    return @ygg_pop_enabled
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_event_cache
  #--------------------------------------------------------------------------#
  def ygg_event_cache()
    ygg_event_cache_start()
    for i in 0..@list.size
      next if @list[i].nil?()
      if [108, 408].include?( @list[i].code )
        @list[i].parameters.to_s.split(/[\r\n]+/).each { |line|
          ygg_event_cache_check( line )
        }
      end
    end unless @list.nil?()
    ygg_event_cache_end()
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_event_cache_start
  #--------------------------------------------------------------------------#
  def ygg_event_cache_start()
    @ygg_cache_complete     = false
    @ygg_battler            = nil
    @ygg_ally               = false
    @ygg_enemy              = false
    @ygg_boss               = false
    @ygg_invincible         = false
    @ygg_pop_enabled        = true
    @hp_visible             = true
    @mp_visible             = true
    @ygg_ondeath            = []

    @ygg_fading_death       = true  # // Depreceated
    @ygg_instant_death      = false # // Depreceated
    @ygg_dead_switches      = []    # // Depreceated
    @ygg_dead_self_switches = []    # // Depreceated
    @ygg_dieing             = false # // Depreceated
    @die_count_down         = 255   # // Depreceated
    @ygg_death_anim         = 0     # // Depreceated

    setup_ai_engine( YGG::Handlers::AIEngines::Default, {} )

    @__aiengine, @__aieng_setup_data = nil, {}
    @__read_aiengine = 0

    @__read_ondeath = 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_event_cache_check
  #--------------------------------------------------------------------------#
  def ygg_event_cache_check( line )
    case line
    when YGG::REGEXP::EVENT::SELF_SWITCH
      @ygg_dead_self_switches.push($1.to_s.upcase)
    when YGG::REGEXP::EVENT::SWITCH
      @ygg_dead_switches.push([$1.to_i, $2.to_s])
    when YGG::REGEXP::EVENT::INVINCIBLE
      @ygg_invincible = true
    when YGG::REGEXP::EVENT::NO_FADE_DEATH
      @ygg_fading_death = false
    when YGG::REGEXP::EVENT::INSTANT_DEATH
      @ygg_instant_death = true
    when YGG::REGEXP::EVENT::ABS_ALLY
      return if $game_actors[$1.to_i].nil?()
      setup_ygg_battler( $game_actors[$1.to_i], :actor )
    when YGG::REGEXP::EVENT::ABS_ENEMY
      return if $data_enemies[$1.to_i].nil?()
      setup_ygg_battler( Game_Enemy.new(0, $1.to_i), :enemy )
    when YGG::REGEXP::EVENT::ABS_SET_AS_ALLY
      @ygg_enemy = !@ygg_ally = true
    when YGG::REGEXP::EVENT::ABS_SET_AS_ENEMY
      @ygg_ally = !@ygg_enemy = true
    when YGG::REGEXP::EVENT::ABS_BOSS
      @ygg_boss = true
    when YGG::REGEXP::EVENT::DEATH_ANIM
      @ygg_death_anim = $1.to_i
    when YGG::REGEXP::EVENT::AI_ENGINE1
      @__aiengine = ::YGG::AI_ENGINES[$1.to_s.downcase]
      @__read_aiengine = 1
    when YGG::REGEXP::EVENT::AI_ENGINE2
      @__read_aiengine = 0
    when YGG::REGEXP::EVENT::ENABLE_POP
      @ygg_pop_enabled = true
    when YGG::REGEXP::EVENT::DISABLE_POP
      @ygg_pop_enabled = false
    when YGG::REGEXP::EVENT::SHOW_HP_BAR
      @hp_visible = true
    when YGG::REGEXP::EVENT::HIDE_HP_BAR
      @hp_visible = false
    when YGG::REGEXP::EVENT::SHOW_MP_BAR
      @mp_visible = true
    when YGG::REGEXP::EVENT::HIDE_MP_BAR
      @mp_visible = false
    when YGG::REGEXP::EVENT::ONDEATH1
      @__read_ondeath = 1
    when YGG::REGEXP::EVENT::ONDEATH2
      @__read_ondeath = 0
    else
      if @__read_aiengine == 1
        case line
        when /(.*)\=[ ](.*)/i
          @__aieng_setup_data[$1] = $2
        end
      elsif @__read_ondeath == 1
        @ygg_ondeath << ::YGG.get_action_from_line( line )
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_event_cache_end
  #--------------------------------------------------------------------------#
  def ygg_event_cache_end()
    setup_ai_engine( @__aiengine, @__aieng_setup_data ) unless @__aiengine.nil?()
    @__read_aiengine, @__aiengine, @__aieng_setup_data = 0, nil, {}
    @ygg_cache_complete = true
    #setup_target_group()
  end

  #--------------------------------------------------------------------------#
  # * new-method :setup_ygg_battler
  #--------------------------------------------------------------------------#
  def setup_ygg_battler( battler, type=:actor )
    @ygg_battler = battler
    case type
    when :actor ; @ygg_enemy = !@ygg_ally = true
    when :enemy ; @ygg_ally  = !@ygg_enemy = true
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :terminate_ygg_battler
  #--------------------------------------------------------------------------#
  def terminate_ygg_battler()
    @ygg_battler = nil
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_attacker
  #--------------------------------------------------------------------------#
  def ygg_attacker() ; @ygg_battler || super ; end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_ally?
  #--------------------------------------------------------------------------#
  def ygg_ally?() ; return @ygg_ally ; end

  #--------------------------------------------------------------------------#
  # * new-method :Is an enemy?
  #--------------------------------------------------------------------------#
  def ygg_enemy? ; return @ygg_enemy ; end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_boss?
  #--------------------------------------------------------------------------#
  def ygg_boss? ; return @ygg_boss ; end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_death
  #--------------------------------------------------------------------------#
  def ygg_death()
    ygg_enemy?() ? Sound.play_enemy_collapse() : Sound.play_actor_collapse()
    create_drops()
    @ygg_battler = nil
    @ygg_boss    = false
    @ygg_dieing  = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_drops
  #--------------------------------------------------------------------------#
  def create_drops()
    $game_map.create_drops( self.x, self.y, ygg_battler.create_drops_object() )
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :ygg_gme_update :update
  def update()
    ygg_gme_update()
    ygg_abs_update() if $game_system.yggdrasil_on?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_abs_update
  #--------------------------------------------------------------------------#
  def ygg_abs_update()
    super()
    unless self.ygg_battler.nil?()
      update_battler()
      if ygg_attacker.dead? ; ygg_death()
      else                  ; ygg_update_ai()
      end
    end
    if @ygg_dieing
      if @ygg_instant_death
        @die_count_down = 0
      elsif @ygg_fading_death
        @opacity = @die_count_down -= 255 / YGG::DIE_WAIT_TIME
      else
        @die_count_down -= 255 / YGG::DIE_WAIT_TIME
      end
      if @die_count_down <= 0
        @ygg_dieing = false
        ygg_perform_death()
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_perform_death
  #--------------------------------------------------------------------------#
  # Hp == 0 .'. Dead. If no switch is present the event is simply erased
  # If IRME is present, and the event is generated the irme_die is called
  # Therefore the event is removed.
  #--------------------------------------------------------------------------#
  if $imported["IRME_Event_Generator"]
    def ygg_perform_death()
      ygg_death_operations()
      if @ygg_dead_self_switches.empty? and @ygg_dead_switches.empty? # If no switches are present do normal erasing
        unless @generator_id.nil?()
          self.irme_die()
        else
          self.erase
        end
      end
    end
  else
    def ygg_perform_death()
      ygg_death_operations()
      if @ygg_dead_self_switches.empty? and @ygg_dead_switches.empty? # If no switches are present do normal erasing
        self.erase()
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_death_operations
  #--------------------------------------------------------------------------#
  def ygg_death_operations()
    @ygg_anims.push(@ygg_death_anim) if @ygg_death_anim > 0
    if !@ygg_dead_self_switches.empty?() or !@ygg_dead_switches.empty?()
      @ygg_dead_self_switches.compact.each { |selswit|
        $game_system.control_self_switch( $game_map.map_id, @id, selswit, true )
      }
      @ygg_dead_switches.compact.each { |swit|
        swit_id = swit[0]
        case swit[1].to_s
        when /(?:TRUE|ON)/i
          $game_switches[swit_id] = true
          $game_map.need_refresh = true
        when /(?:FALSE|OFF)/i
          $game_switches[swit_id] = false
          $game_map.need_refresh = true
        end
      }
      $game_map.need_refresh = true
    end
  end

end

#==============================================================================#
# ** Game Player
#==============================================================================#
class Game_Player < Game_Character

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :ygg_gained_items

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ygg_gmp_initialize :initialize
  def initialize( *args, &block )
    ygg_gmp_initialize( *args, &block )
    @ygg_targeting_mode = false
    @ygg_remote_sprite  = nil
    @ygg_old_actor      = nil
    @ygg_old_target_pos = [0, 0]
    @ygg_gained_items   = []
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :ygg_gmp_update :update
  def update( *args, &block )
    abs_on = $game_system.yggdrasil_on?()
    if abs_on
      ygg_abs_update()
      ygg_update_pickup()
    end
    ygg_gmp_update( *args, &block )
    if abs_on
      @ygg_old_actor = $game_party.members[0]
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_update_pickup
  #--------------------------------------------------------------------------#
  def ygg_update_pickup()
    $game_map.drops_xy( self.x, self.y ).compact.each { |dr|
      self.ygg_gain_drop( dr.drop ) ; dr.drop_remove() }
  end

  #--------------------------------------------------------------------------#
  # * new-method :gain_drop
  #--------------------------------------------------------------------------#
  def ygg_gain_drop( drop )
    return if drop.nil?()
    drop.pickup_sfx.play() unless drop.pickup_sfx.nil?()
    @ygg_gained_items << drop
    @ygg_gained_items.shift() while @ygg_gained_items.size > 20 # // remove really old drops to save memory
    if drop.is_a?( YGG::Containers::GoldItem )
      $game_party.gain_gold( drop.gold_amount )
    else
      $game_party.gain_item( drop, 1 )
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_abs_update
  #--------------------------------------------------------------------------#
  def ygg_abs_update()
    super()
    unless self.ygg_battler.nil?()
      update_battler() ; ygg_attack_input()
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_attacker
  #--------------------------------------------------------------------------#
  def ygg_attacker() ; return $game_party.members[0] ; end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_ally?, ygg_enemy?, ygg_wild?, ygg_boss?
  #--------------------------------------------------------------------------#
  def ygg_ally?  ; return true  ; end
  def ygg_enemy? ; return false ; end
  def ygg_wild?  ; return false ; end
  def ygg_boss?  ; return false ; end

  #--------------------------------------------------------------------------#
  # * new-method :ygg_can_move?
  #--------------------------------------------------------------------------#
  def ygg_can_move?() ; super() ; end

  #--------------------------------------------------------------------------#
  # * overwrite-method :use_equipment
  #--------------------------------------------------------------------------#
  def use_equipment ; return true ; end

end

#==============================================================================#
# ** YGG::Drop_Character
#==============================================================================#
class YGG::Drop_Character < YGG::Handlers::Screen

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :icon_index
  attr_accessor :ready_to_remove
  attr_accessor :icon_time_out
  attr_accessor :opacity
  attr_accessor :visible

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( object, time = 640 )
    super( 0, 0, 0 )
    @drop_object     = object
    @icon_index      = @drop_object.icon_index
    @icon_time_out   = time
    @icon_fade_thres = YGG::DROP_FADE_THRESHOLD
    @opacity         = 255
    @visible         = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :pos?
  #--------------------------------------------------------------------------#
  def pos?( tx, ty ) ; return (self.x == tx && self.y == ty) ; end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
  def update()
    @icon_time_out   = [@icon_time_out-1, 0].max
    @ready_to_remove = true if @icon_time_out <= 0
    @opacity -= 255 / 60 if @icon_time_out <= @icon_fade_thres
    if $game_player.drop_attraction?()
      if $game_player.x > self.x    ; self.x = [self.x-0.1, $game_player.x].min
      elsif $game_player.x < self.x ; self.x = [self.x-0.1, $game_player.x].max
      end
      if $game_player.y > self.y    ; self.y = [self.y-0.1, $game_player.y].min
      elsif $game_player.y < self.y ; self.y = [self.y-0.1, $game_player.y].max
      end
      @real_x = self.x*256 ; @real_y = self.y*256
    end
  end

  #--------------------------------------------------------------------------#
  # * super-method :drop_remove
  #--------------------------------------------------------------------------#
  def drop_remove()
    @drop_object = nil
    @icon_index = 0
    @icon_time_out = 0
  end

  #--------------------------------------------------------------------------#
  # * new-method :timeout?
  #--------------------------------------------------------------------------#
  def timeout? ; return @icon_time_out == 0 end

  #--------------------------------------------------------------------------#
  # * new-method :drop
  #--------------------------------------------------------------------------#
  def drop ; return @drop_object end

end

#==============================================================================#
# ** Scene_Title
#==============================================================================#
class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias-method :load_database
  #--------------------------------------------------------------------------#
  alias :ygg_sct_load_database :load_database
  def load_database()
    ygg_sct_load_database()
    load_ygg_database()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :load_bt_database
  #--------------------------------------------------------------------------#
  alias :ygg_sct_load_bt_database :load_bt_database
  def load_bt_database()
    ygg_sct_load_bt_database()
    load_ygg_database()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :load_ygg_database
  #--------------------------------------------------------------------------#
  def load_ygg_database()
    data = []
    data += $data_items
    data += $data_skills
    data += $data_enemies
    data += $data_weapons
    data += $data_armors
    data += $data_states
    data.compact.each { |obj| obj.yggdrasil_1x6_cache() }
  end

  #--------------------------------------------------------------------------#
  # * alias-method :create_game_objects
  #--------------------------------------------------------------------------#
  alias :ygg_sct_ptxt_create_game_objects :create_game_objects
  def create_game_objects()
    $game_yggdrasil = YGG::System.new()
    ygg_sct_ptxt_create_game_objects()
  end

end

#==============================================================================#
# ** Scene_Map
#==============================================================================#
class Scene_Map < Scene_Base

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :spriteset

  #--------------------------------------------------------------------------#
  # * new-method :push_ygg_anim
  #--------------------------------------------------------------------------#
  def push_ygg_anim( anim_id, x, y, targets=[], looped = false )
    @spriteset.push_anim( anim_id, x, y, targets, looped ) unless @spriteset.nil?()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :ygg_scm_update :update
  def update( *args, &block )
    ygg_scm_update( *args, &block )
    $game_yggdrasil.update()
    $game_party.ygg_slip_damage() if $game_yggdrasil.on?()
    $game_yggdrasil.gameover_process() if $game_party.all_dead?() if $game_system.gameover_alldead?()
  end

if ::YGG::USE_DROPS_WINDOW

  #--------------------------------------------------------------------------#
  # * alias-method :start
  #--------------------------------------------------------------------------#
  alias :ygg_drop_win_start :start
  def start( *args, &block )
    ygg_drop_win_start( *args, &block )
    create_drops_window()
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_drops_window
  #--------------------------------------------------------------------------#
  def create_drops_window()
    size = YGG::DROPS_WINDOW_SIZE
    @drops_logging = YGG::Drops_Window.new(
      { :x => size[0], :y => size[1], :z => size[2], :width => size[3] }, nil )
    @drops_logging.visible = $game_yggdrasil.drops_window_visible?()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :terminate
  #--------------------------------------------------------------------------#
  alias :ygg_drop_win_terminate :terminate
  def terminate( *args, &block )
    @drops_logging.dispose() unless @drops_logging.nil?() ; @drops_logging = nil
    ygg_drop_win_terminate( *args, &block )
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :ygg_drop_win_update :update
  def update( *args, &block )
    unless @drops_logging.nil?()
      @drops_logging.visible = $game_yggdrasil.drops_window_visible?()
      @drops_logging.update()
    end
    ygg_drop_win_update( *args, &block )
  end

end # // Drops Window

end

# // (YGG_ShiftSystem)
if YGG::USE_SHIFT_SYSTEM
#==============================================================================#
# ** Game_Party
#==============================================================================#
class Game_Party < Game_Unit

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :actors

end

#==============================================================================#
# ** YGG::Handlers::Shift
#==============================================================================#
class YGG::Handlers::Shift

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :shift_time
  attr_accessor :shift_cap

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize()
    @shift_time = 0
    @shift_cap  = Graphics.frame_rate*5
  end

  #--------------------------------------------------------------------------#
  # * new-method :reset_shift_time
  #--------------------------------------------------------------------------#
  def reset_shift_time() ; @shift_time = @shift_cap ; end

  #--------------------------------------------------------------------------#
  # * new-method :time
  #--------------------------------------------------------------------------#
  def time() ; return @shift_time ; end

  #--------------------------------------------------------------------------#
  # * new-method :cap
  #--------------------------------------------------------------------------#
  def cap() ; return @shift_cap ; end

  #--------------------------------------------------------------------------#
  # * new-method :can_shift?
  #--------------------------------------------------------------------------#
  def can_shift?() ; return @shift_time == 0 ; end

  #--------------------------------------------------------------------------#
  # * new-method :swap_actors
  #--------------------------------------------------------------------------#
  def swap_actors( target_index, swap_index )
    target_id = $game_party.actors[target_index]
    swap_id = $game_party.actors[swap_index]
  end

  #--------------------------------------------------------------------------#
  # * new-method :rotate_actors
  #--------------------------------------------------------------------------#
  def rotate_actors( n=1 )
    $game_party.actors.rotate!( n )
  end

  #--------------------------------------------------------------------------#
  # * new-method :perform_shift
  #--------------------------------------------------------------------------#
  def perform_shift( n )
    rotate_actors( n ) ;
    $game_player.ygg_anims << 81
    $game_player.thrust_backward()
    $game_player.refresh()
    reset_shift_time()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
  def update()
    @shift_time = [@shift_time - 1, 0].max
    update_shift() if can_shift?
    perform_shift( 1 ) while $game_party.members[0].dead?() unless $game_party.all_dead?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :update_shift
  #--------------------------------------------------------------------------#
  def update_shift()
    if Input.trigger?( Input::R )
      perform_shift( 1 )
    elsif Input.trigger?( Input::L )
      perform_shift( -1 )
    end
  end

end

#==============================================================================#
# ** YGG::System
#==============================================================================#
class YGG::System

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_accessor :shift_system

  #--------------------------------------------------------------------------#
  # * alias-method :initialize
  #--------------------------------------------------------------------------#
  alias :ygg_shift_sys_initialize :initialize
  def initialize( *args, &block )
    ygg_shift_sys_initialize( *args, &block )
    @shift_system = ::YGG::Handlers::Shift.new()
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :ygg_shift_sys_update :update
  def update( *args, &block )
    ygg_shift_sys_update( *args, &block )
    @shift_system.update()
  end

end

end

# // (YGG_LevelUpWindow)
if YGG::USE_LEVEL_UP_WINDOW > 0
#==============================================================================#
# ** YGG::Windows::Level_Up
#==============================================================================#
class YGG::Windows::Level_Up < ::Sprite

  #--------------------------------------------------------------------------#
  # * Constant(s)
  #--------------------------------------------------------------------------#
  WLH = 20
  BORDER_SIZE = 2

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( x, y, width, viewport=nil )
    super( viewport )
    @background = Sprite.new( self.viewport )
    @background.bitmap = Bitmap.new( width, WLH )
    @background.bitmap.fill_rect( BORDER_SIZE, BORDER_SIZE,
      width-(BORDER_SIZE*2), WLH-(BORDER_SIZE*2),
      Color.new( 0, 0, 0 ) )
    @background.bitmap.blur() ; @background.bitmap.blur()
    @background.opacity = 198
    self.bitmap = Bitmap.new( width, WLH*7 )
    self.src_rect.set( 0, 0, width, WLH )
    @count = 0 ; @index = 0
    self.x, self.y, self.z = x, y, 9999
    @target_opacity = 0
  end

  #--------------------------------------------------------------------------#
  # * super-method :dispose
  #--------------------------------------------------------------------------#
  def dispose()
    unless @background.nil?()
      @background.bitmap.dispose() ; @background.dispose()
    end
    self.bitmap.dispose()
    super()
  end

  #--------------------------------------------------------------------------#
  # * super-method :x=
  #--------------------------------------------------------------------------#
  def x=( new_x )
    super( new_x )
    @background.x = self.x
  end

  #--------------------------------------------------------------------------#
  # * super-method :y=
  #--------------------------------------------------------------------------#
  def y=( new_y )
    super( new_y )
    @background.y = self.y
  end

  #--------------------------------------------------------------------------#
  # * super-method :z=
  #--------------------------------------------------------------------------#
  def z=( new_z )
    super( new_z+1 )
    @background.z = new_z
  end

  #--------------------------------------------------------------------------#
  # * super-method :viewport=
  #--------------------------------------------------------------------------#
  def viewport=( new_viewport )
    super( new_viewport )
    @background.viewport = self.viewport
  end

  #--------------------------------------------------------------------------#
  # * super-method :visible=
  #--------------------------------------------------------------------------#
  def visible=( new_visible )
    super( new_visible )
    @background.visible = self.visible
  end

  #--------------------------------------------------------------------------#
  # * super-method :show_level_up
  #--------------------------------------------------------------------------#
  def show_level_up( battler, old_level )
    self.bitmap.clear()
    @count = 0 ; @index = 0 ; @last_index = -1
    stats = [:maxhp, :maxmp, :atk, :def, :spi, :agi]
    self.bitmap.font.size = 16
    self.bitmap.draw_text( 0, 0, self.width, WLH,
      sprintf( "%s: %s > %s", Vocab.level, old_level, battler.level ) )
    for i in 0...stats.size
      stat = stats[i]
      self.bitmap.draw_text( 0, WLH+(WLH*i), self.width, 20,
        sprintf( "%s: %s", Vocab.send( stat ), battler.send( stat ) ) )
    end
    @target_opacity = 198
    self.visible = true
  end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
  def update()
    super()
    return if @index >= 8
    @count += 1
    @index += 1 if @count % 60 == 0
    if @index >= 7
      @target_opacity = 0
      self.visible = false
    else
      if @index != @last_index
        self.src_rect.set( 0, WLH*@index, self.width, WLH )
        @last_index = @index
      end
    end
    if @background.opacity > @target_opacity
      @background.opacity = [@background.opacity - (255/30.0), @target_opacity].max
    elsif @background.opacity < @target_opacity
      @background.opacity = [@background.opacity + (255/30.0), @target_opacity].min
    end
  end

end

#==============================================================================#
# ** Scene_Map
#==============================================================================#
class Scene_Map < Scene_Base

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_accessor :level_up_window

  #--------------------------------------------------------------------------#
  # * alias-method :start
  #--------------------------------------------------------------------------#
  alias :ygg_lvl_up_win_scm_start :start
  def start( *args, &block )
    ygg_lvl_up_win_scm_start( *args, &block )
    @level_up_window = YGG::Windows::Level_Up.new( 0, 0, 128 )
  end

  #--------------------------------------------------------------------------#
  # * alias-method :terminate
  #--------------------------------------------------------------------------#
  alias :ygg_lvl_up_win_scm_terminate :terminate
  def terminate( *args, &block )
    ygg_lvl_up_win_scm_terminate( *args, &block )
    @level_up_window.dispose() unless @level_up_window.nil?() ; @level_up_window = nil
  end

  #--------------------------------------------------------------------------#
  # * alias-method :update
  #--------------------------------------------------------------------------#
  alias :ygg_lvl_up_win_scm_update :update
  def update( *args, &block )
    ygg_lvl_up_win_scm_update( *args, &block )
    @level_up_window.update() unless @level_up_window.nil?()
  end

end

end # // Level Up Window

#==============================================================================#
# ** Scene_File
#==============================================================================#
class Scene_File < Scene_Base

  #--------------------------------------------------------------------------#
  # * alias-method :write_save_data
  #--------------------------------------------------------------------------#
  alias :ygg_scnf_ptxt_write_save_data :write_save_data
  def write_save_data( file )
    ygg_scnf_ptxt_write_save_data( file )
    Marshal.dump( $game_yggdrasil,      file )
  end

  #--------------------------------------------------------------------------#
  # * alias-method :read_save_data
  #--------------------------------------------------------------------------#
  alias :ygg_scnf_ptxt_read_save_data :read_save_data
  def read_save_data( file )
    ygg_scnf_ptxt_read_save_data( file )
    $game_yggdrasil = Marshal.load( file )
    $game_yggdrasil.__on_load()
  end

end

# // (Skill/Item Setting) // #
#==============================================================================#
# ** YGG::Windows::ActorObjSlots
#==============================================================================#
class ::YGG::Windows::ActorObjSlots < ::Window_Selectable

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( actor, x, y, width, height )
    super( x, y, width, height )
    @actor = actor
    @column_max = 1
    self.active = false
    self.index  = 0
    refresh()
  end

  #--------------------------------------------------------------------------#
  # * new-method :enabled?
  #--------------------------------------------------------------------------#
  def enabled?( index )
    return !@data[index].nil?()
  end

  #--------------------------------------------------------------------------#
  # * new-method :obj
  #--------------------------------------------------------------------------#
  def obj( i=@index ) ; return @data[i] ; end

  #--------------------------------------------------------------------------#
  # * new-method :get_objs
  #--------------------------------------------------------------------------#
  def get_objs()
    return []
  end

  #--------------------------------------------------------------------------#
  # * new-method :refresh
  #--------------------------------------------------------------------------#
  def refresh()
    @data     = get_objs()
    @item_max = @data.size
    @data_enabled = []
    create_contents()
    for i in 0...@item_max
      @data_enabled[i] = enabled?( i )
      draw_item( i )
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :selective_refresh
  #--------------------------------------------------------------------------#
  def selective_refresh()
    newdata   = get_objs()
    @item_max = newdata.size
    if @data.size != @item_max
      @data.clear()
      create_contents()
    end
    for i in 0...newdata.size
      if newdata[i] != @data[i] || @data_enabled[i] != enabled?( i )
        @data[i] = newdata[i]
        @data_enabled[i] = enabled?( i )
        draw_item( i )
      end
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :draw_item
  #--------------------------------------------------------------------------#
  def draw_item( index )
    rect = item_rect( index )
    obj  = @data[index]
    enabled = enabled?( index )
    self.contents.clear_rect( rect )
    self.contents.font.color = normal_color
    self.contents.font.color.alpha -= 128 unless enabled
    unless obj.nil?()
      draw_item_name( obj, rect.x, rect.y, enabled )
    else
      draw_icon( 98, rect.x, rect.y )
      rect.x += 24
      self.contents.draw_text( rect, "----------------" )
    end
  end

  #--------------------------------------------------------------------------#
  # * kill-method :cursor_pagedown
  #--------------------------------------------------------------------------#
  def cursor_pagedown() ; end

  #--------------------------------------------------------------------------#
  # * kill-method :cursor_pageup
  #--------------------------------------------------------------------------#
  def cursor_pageup() ; end

end

#==============================================================================#
# ** YGG::Windows::ItemList
#==============================================================================#
class ::YGG::Windows::ItemList < ::YGG::Windows::ActorObjSlots

  #--------------------------------------------------------------------------#
  # * new-method :item
  #--------------------------------------------------------------------------#
  def item() ; return obj() ; end

  #--------------------------------------------------------------------------#
  # * new-method :enabled?
  #--------------------------------------------------------------------------#
  def enabled?( index )
    return false if @actor.item_slot_items.include?( @data[index] )
    return false if @data[index].cant_equip_slot unless @data[index].nil?()
    return super( index )
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :get_objs
  #--------------------------------------------------------------------------#
  def get_objs()
    return [nil] + ($game_party.items.inject([]) { |r, i| r << i if i.is_a?(RPG::Item) }) + [nil]
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update_help
  #--------------------------------------------------------------------------#
  def update_help()
    @help_window.set_text(item.nil?() ? "" : item.description)
  end

end

#==============================================================================#
# ** YGG::Windows::SkillList
#==============================================================================#
class ::YGG::Windows::SkillList < ::YGG::Windows::ActorObjSlots

  #--------------------------------------------------------------------------#
  # * new-method :skill
  #--------------------------------------------------------------------------#
  def skill() ; return obj() ; end

  #--------------------------------------------------------------------------#
  # * super-method :enabled?
  #--------------------------------------------------------------------------#
  def enabled?( index )
    return false if @actor.skill_slot_skills.include?( @data[index] )
    return false if @data[index].cant_equip_slot unless @data[index].nil?()
    return super( index )
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :get_objs
  #--------------------------------------------------------------------------#
  def get_objs()
    return [nil] + @actor.skills() + [nil]
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update_help
  #--------------------------------------------------------------------------#
  def update_help
    @help_window.set_text(skill.nil? ? "" : skill.description)
  end
end

#==============================================================================#
# ** YGG::Windows::ActorItemSlots
#==============================================================================#
class ::YGG::Windows::ActorItemSlots < ::YGG::Windows::ActorObjSlots
  #--------------------------------------------------------------------------#
  # * new-method :item
  #--------------------------------------------------------------------------#
  def item
    obj
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :get_objs
  #--------------------------------------------------------------------------#
  def get_objs
    @actor.item_slot_items
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update_help
  #--------------------------------------------------------------------------#
  def update_help
    @help_window.set_text(item ? item.description : "")
  end
end

#==============================================================================#
# ** YGG::Windows::ActorSkillSlots
#==============================================================================#
class ::YGG::Windows::ActorSkillSlots < ::YGG::Windows::ActorObjSlots
  #--------------------------------------------------------------------------#
  # * new-method :skill
  #--------------------------------------------------------------------------#
  def skill
    obj
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :get_objs
  #--------------------------------------------------------------------------#
  def get_objs
    return @actor.skill_slot_skills
  end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update_help
  #--------------------------------------------------------------------------#
  def update_help
    @help_window.set_text(skill ? skill.description : "")
  end
end

# // Is there a good reason why I haven't super classes these? YES
#==============================================================================#
# ** YGG::Scenes::ObjSet
#==============================================================================#
class ::YGG::Scenes::ObjSet < ::Scene_Base
  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( actor, called=:map, return_index=0 )
    super()
    # ---------------------------------------------------- #
    @actor = nil
    @act_index = 0
    @index_call = false
    # ---------------------------------------------------- #
    if actor.kind_of?(Game_Battler)
      @actor = actor
    elsif actor != nil
      @actor = $game_party.members[actor]
      @act_index = actor
      @index_call = true
    end
    @calledfrom = called
    @return_index = return_index
  end

  #--------------------------------------------------------------------------#
  # * new-method :start
  #--------------------------------------------------------------------------#
  def start
    super
  end

  #--------------------------------------------------------------------------#
  # * new-method :return_scene
  #--------------------------------------------------------------------------#
  def return_scene
    case @calledfrom
    when :map
      $scene = Scene_Map.new
    when :menu
      $scene = Scene_Menu.new( @return_index )
    end
  end

  #--------------------------------------------------------------------------#
  # * super-method :terminate
  #--------------------------------------------------------------------------#
  def terminate
    super
    dispose_menu_background
    @help_window.dispose unless @help_window.nil?
    @help_window = nil
    @obj_window.dispose unless @obj_window.nil?
    @obj_window = nil
    @slot_window.dispose unless @slot_window.nil?
    @slot_window = nil
    @status_window.dispose unless @status_window.nil?
    @status_window = nil
  end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
  def update
    super
    update_menu_background
    @obj_window.update
    @slot_window.update
    # // Basic Update
    if Input.trigger?(Input::B)
      command_cancel
    elsif Input.trigger?(Input::R) && @index_call
      command_next
    elsif Input.trigger?(Input::L) && @index_call
      command_prev
    # // Actual Input
    elsif Input.trigger?(Input::C)
      command_accept
    elsif Input.trigger?(Input::Z)
      # // Used to pop extended help window, if I ever implement it
    elsif Input.trigger?(Input::X) || Input.trigger?(Input::LEFT)
      command_prevslot
    elsif Input.trigger?(Input::Y) || Input.trigger?(Input::RIGHT)
      command_nextslot
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :command_cancel
  #--------------------------------------------------------------------------#
  def command_cancel
    Sound.play_cancel
    return_scene
  end

  #--------------------------------------------------------------------------#
  # * new-method :command_next
  #--------------------------------------------------------------------------#
  def command_next
    Sound.play_decision
    $scene = self.class.new(
      (@act_index+1) % $game_party.members.size, @calledfrom, @return_index )
  end

  #--------------------------------------------------------------------------#
  # * new-method :command_prev
  #--------------------------------------------------------------------------#
  def command_prev
    Sound.play_decision
    $scene = self.class.new(
      (@act_index-1) % $game_party.members.size, @calledfrom, @return_index )
  end

  #--------------------------------------------------------------------------#
  # * new-method :command_nextslot
  #--------------------------------------------------------------------------#
  def command_nextslot
    Sound.play_cursor
    @slot_window.index = (@slot_window.index + 1) % @slot_window.item_max
  end

  #--------------------------------------------------------------------------#
  # * new-method :command_prevslot
  #--------------------------------------------------------------------------#
  def command_prevslot
    Sound.play_cursor
    @slot_window.index = (@slot_window.index - 1) % @slot_window.item_max
  end

  #--------------------------------------------------------------------------#
  # * new-method :command_accept
  #--------------------------------------------------------------------------#
  def command_accept
  end
end

#==============================================================================#
# ** YGG::Scenes::ItemSet
#==============================================================================#
class ::YGG::Scenes::ItemSet < ::YGG::Scenes::ObjSet
  #--------------------------------------------------------------------------#
  # * super-method :start
  #--------------------------------------------------------------------------#
  def start
    super
    create_menu_background
    @help_window   = ::Window_Help.new
    @status_window = ::Window_SkillStatus.new(0, 56, @actor)
    @obj_window   = ::YGG::Windows::ItemList.new(
      @actor,
      Graphics.width / 2, 112,
      Graphics.width / 2, Graphics.height - 112)
    @obj_window.help_window = @help_window
    @slot_window   = ::YGG::Windows::ActorItemSlots.new(
      @actor,
      0, 112,
      Graphics.width / 2, Graphics.height - 112)
    @obj_window.active = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :command_accept
  #--------------------------------------------------------------------------#
  def command_accept
    if @obj_window.enabled?(@obj_window.index) || @obj_window.obj.nil?
      Sound.play_decision
      id = @obj_window.item ? @obj_window.item.id@obj_window.item.id : 0
      @actor.set_item_slot( @slot_window.index, id )
      @obj_window.selective_refresh #.draw_item( @obj_window.index )
      @slot_window.refresh
    else
      Sound.play_buzzer
    end
  end
end

# // Scene_ItemSet.new( actor, called_from, [return_index)]
Scene_ItemSet = YGG::Scenes::ItemSet

#==============================================================================#
# ** YGG::Scenes::SkillSet
#==============================================================================#
class ::YGG::Scenes::SkillSet < ::YGG::Scenes::ObjSet

  #--------------------------------------------------------------------------#
  # * super-method :start
  #--------------------------------------------------------------------------#
  def start
    super()
    create_menu_background()
    @help_window   = ::Window_Help.new()
    @status_window = ::Window_SkillStatus.new( 0, 56, @actor )
    @obj_window    = ::YGG::Windows::SkillList.new(
      @actor,
      Graphics.width/2, 112,
      Graphics.width/2, Graphics.height-112 )
    @obj_window.help_window = @help_window
    @slot_window   = ::YGG::Windows::ActorSkillSlots.new(
      @actor,
      0, 112,
      Graphics.width/2, Graphics.height-112 )
    @obj_window.active = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :command_accept
  #--------------------------------------------------------------------------#
  def command_accept()
    if @obj_window.enabled?( @obj_window.index ) || @obj_window.obj.nil?()
      Sound.play_decision
      id = @obj_window.skill.nil?() ? 0 : @obj_window.skill.id
      @actor.set_skill_slot( @slot_window.index, id )
      @obj_window.selective_refresh() #draw_item( @obj_window.index )
      @slot_window.refresh()
    else
      Sound.play_buzzer()
    end
  end

end
# // Scene_SkillSet.new( actor, called_from, [return_index)]
Scene_SkillSet = YGG::Scenes::SkillSet

# // (YGG_HudSetting) // #
module YGG ; end ; module YGG::Handlers ; end

#==============================================================================#
# ** YGG::Handlers::HudWrapper
#==============================================================================#
class YGG::Handlers::HudWrapper

  #--------------------------------------------------------------------------#
  # * Constant(s)
  #--------------------------------------------------------------------------#
  DEFAULTS = {
    :hp        => 0,
    :maxhp     => 1,
    :mp        => 0,
    :maxmp     => 1,
    :shift     => 0,
    :maxshift  => 1,
    :charge    => 0,
    :maxcharge => 1,
    :exp       => 0,
    :maxexp    => 1,
  }

  POSITIONS = YGG::HUD_POSITION_PROCS

  DEFAULTS.keys.each { |key| define_method(key) { return @values[key] } }

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
  attr_reader :actor
  attr_accessor :need_refresh

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize()
    @values = {}
    @actor  = nil
    @need_refresh = false
    load_defaults()
  end

  #--------------------------------------------------------------------------#
  # * new-method :load_defaults
  #--------------------------------------------------------------------------#
  def refresh()
    @need_refresh = false
  end

  #--------------------------------------------------------------------------#
  # * new-method :load_defaults
  #--------------------------------------------------------------------------#
  def load_defaults()
    DEFAULTS.each_pair { |key, value| @values[key] = value }
  end

  #--------------------------------------------------------------------------#
  # * new-method :actor=
  #--------------------------------------------------------------------------#
  def actor=( new_actor )
    if new_actor != @actor ; @actor = new_actor ; update() ; end
  end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
  def update()
    if @actor != $game_player.ygg_battler
      @actor = $game_player.ygg_battler ; @need_refresh = true
    end
    if @actor.nil?()
      @values[:hp]        = DEFAULTS[:hp]
      @values[:maxhp]     = DEFAULTS[:maxhp]
      @values[:mp]        = DEFAULTS[:mp]
      @values[:maxmp]     = DEFAULTS[:maxmp]
      @values[:charge]    = DEFAULTS[:charge]
      @values[:maxcharge] = DEFAULTS[:maxcharge]
      @values[:exp]       = DEFAULTS[:exp]
      @values[:maxexp]    = DEFAULTS[:maxexp]
    else
      @values[:hp]        = @actor.hp
      @values[:maxhp]     = @actor.maxhp
      @values[:mp]        = @actor.mp
      @values[:maxmp]     = @actor.maxmp
      @values[:charge]    = @actor.cooldown
      @values[:maxcharge] = @actor.cooldown_max
      @values[:exp]       = @actor.level_exp
      @values[:maxexp]    = @actor.next_level_exp
    end
    if shift_valid?()
      @values[:shift]     = $game_yggdrasil.shift_system.time
      @values[:maxshift]  = $game_yggdrasil.shift_system.cap
    else
      @values[:shift]     = DEFAULTS[:shift]
      @values[:maxshift]  = DEFAULTS[:maxshift]
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :shift_valid?
  #--------------------------------------------------------------------------#
  def shift_valid?()
    return ::YGG::USE_SHIFT_SYSTEM
  end

  #--------------------------------------------------------------------------#
  # * new-method :get_obj_xyz
  #--------------------------------------------------------------------------#
  def get_obj_xyz( *args )
    return POSITIONS[args[0]].call( *args.slice( 1, args.size ) )
  end

if ::YGG::HUD_SWITCH.nil?() || ::YGG::HUD_SWITCH == 0

  #--------------------------------------------------------------------------#
  # * new-method :hud_visible?
  #--------------------------------------------------------------------------#
  def visible?() ; return true ; end

else

  #--------------------------------------------------------------------------#
  # * new-method :hud_visible?
  #--------------------------------------------------------------------------#
  def visible?()
    return $game_switches[::YGG::HUD_SWITCH]
  end

end

end

#==============================================================================#
# ** YGG::Handlers::Hud
#==============================================================================#
class ::YGG::Handlers::Hud
#==============================================================================#
# ** SpriteMix
#==============================================================================#
  module SpriteMix
  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
    attr_accessor :add_x, :add_y, :add_z

  #--------------------------------------------------------------------------#
  # * super-method :set_add_xyz
  #--------------------------------------------------------------------------#
    def set_add_xyz( ax, ay, az )
      @add_x, @add_y, @add_z = ax, ay, az
    end

  end
#==============================================================================#
# ** Sprite_Back
#==============================================================================#
  class Sprite_Back < ::Sprite

    include SpriteMix

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
    def initialize( viewport )
      @add_x, @add_y, @add_z = 0, 0, 0
      super( viewport )
    end

  end

#==============================================================================#
# ** Sprite_Icon
#==============================================================================#
  class Sprite_Icon < ::Sprite

    include SpriteMix

  #--------------------------------------------------------------------------#
  # * Constant(s)
  #--------------------------------------------------------------------------#
    ICON_SIZE = [24, 24]

  #--------------------------------------------------------------------------#
  # * Public Instance Variable(s)
  #--------------------------------------------------------------------------#
    attr_reader :icon_index
    attr_accessor :active_effect

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
    def initialize( viewport=nil )
      @add_x, @add_y, @add_z = 0, 0, 0
      super( viewport )
      self.bitmap = Cache.system( "Iconset" )
      self.icon_index = 0
      @active_effect = "none"
    end

  #--------------------------------------------------------------------------#
  # * new-method :icon_index=
  #--------------------------------------------------------------------------#
    def icon_index=( new_index )
      return if @icon_index == new_index
      self.src_rect.set(
       new_index % 16 * ICON_SIZE[0], new_index / 16 * ICON_SIZE[1],
       ICON_SIZE[0], ICON_SIZE[1] )
      @icon_index = new_index
    end

  #--------------------------------------------------------------------------#
  # * overwrite-method :update
  #--------------------------------------------------------------------------#
    def update()
      case @active_effect
      when "fadeout"
        self.opacity -= 255 / 30.0
        @active_effect = "none" if self.opacity == 0
      when "fadein"
        self.opacity += 255 / 30.0
        @active_effect = "none" if self.opacity == 255
      end
    end

  end

#==============================================================================#
# ** Sprite_ValueBar
#==============================================================================#
  class Sprite_ValueBar < ::Sprite

    include SpriteMix

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
    attr_accessor :value, :max

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
    def initialize( viewport=nil )
      @add_x, @add_y, @add_z = 0, 0, 0
      super( viewport )
      @value = 0 ; @max = 1
    end

  #--------------------------------------------------------------------------#
  # * super-method :update
  #--------------------------------------------------------------------------#
    def update()
      super()
      self.src_rect.width = self.bitmap.width * @value / [@max, 1].max unless self.bitmap.nil?()
    end

  end

#==============================================================================#
# ** Sprite_TinyPortrait
#==============================================================================#
  class Sprite_TinyPortrait < ::Sprite

  include SpriteMix

  #--------------------------------------------------------------------------#
  # * super-method :initialize
  #--------------------------------------------------------------------------#
    def initialize( viewport=nil )
      @add_x, @add_y, @add_z = 0, 0, 0
      super( viewport )
    end

  #--------------------------------------------------------------------------#
  # * new-method :refresh
  #--------------------------------------------------------------------------#
    def refresh( character_name, character_index )
      self.bitmap = Cache.character( character_name )
      sign = character_name[/^[\!\$]./]
      if sign != nil and sign.include?('$')
        cw = bitmap.width / 3
        ch = bitmap.height / 4
      else
        cw = bitmap.width / 12
        ch = bitmap.height / 8
      end
      n = character_index
      self.src_rect.set( (n%4*3+1)*cw, (n/4*4)*ch, cw, ch )
    end

  end

  #--------------------------------------------------------------------------#
  # * Public Instance Variables
  #--------------------------------------------------------------------------#
  attr_reader :viewport
  attr_reader :x, :y, :z
  attr_reader :visible

  #--------------------------------------------------------------------------#
  # * new-method :initialize
  #--------------------------------------------------------------------------#
  def initialize( x=0, y=0, z=0 )
    @visible = true
    @disposed = false
    @x, @y, @z = x, y, z
    create_all()
    refresh()
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_all
  #--------------------------------------------------------------------------#
  def create_all()
    @skill_setsize = 5#@actor.skill_slot_size
    @item_setsize  = 5#@actor.item_slot_size
    create_skills()
    create_items()
    @back_sprite = Sprite_Back.new( self.viewport )
    @back_sprite.bitmap = Cache.system( "1x6Hud2" )
    @hp_sprite   = Sprite_ValueBar.new( self.viewport )
    @hp_sprite.bitmap = Cache.system( "1x6Hud_HpBar" )
    @mp_sprite   = Sprite_ValueBar.new( self.viewport )
    @mp_sprite.bitmap = Cache.system( "1x6Hud_MpBar" )
    # // Extended
    @exp_sprite   = Sprite_ValueBar.new( self.viewport )
    @exp_sprite.bitmap = Cache.system( "1x6Hud_ExpBar" )
    @shift_sprite   = Sprite_ValueBar.new( self.viewport )
    @shift_sprite.bitmap = Cache.system( "1x6Hud_ShiftBar" )
    @charge_sprite   = Sprite_ValueBar.new( self.viewport )
    @charge_sprite.bitmap = Cache.system( "1x6Hud_ChargeBar" )
    @portrait_sprite = Sprite_TinyPortrait.new( self.viewport )
    @sprites = [@back_sprite, @hp_sprite, @mp_sprite, @portrait_sprite]
    @sprites+= [@exp_sprite, @shift_sprite, @charge_sprite]
    @__hud_wrapper = $game_yggdrasil.hud
  end

  #--------------------------------------------------------------------------#
  # * new-method :disposed?
  #--------------------------------------------------------------------------#
  def disposed?() ; return @disposed ; end

  #--------------------------------------------------------------------------#
  # * new-method :dispose
  #--------------------------------------------------------------------------#
  def dispose()
    each_sprite { |s| s.dispose() }
    @back_sprite = nil ; @hp_sprite = nil ; @mp_sprite = nil
    @skills = nil ; @items = nil
    @disposed = true
  end

  #--------------------------------------------------------------------------#
  # * new-method :refresh
  #--------------------------------------------------------------------------#
  def refresh()
    @portrait_sprite.refresh(
      @__hud_wrapper.actor.nil?() ? "" : @__hud_wrapper.actor.character_name,
      @__hud_wrapper.actor.nil?() ?  0 : @__hud_wrapper.actor.character_index )
    refresh_add_xyz()
    refresh_xyz()
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_skills
  #--------------------------------------------------------------------------#
  def create_skills()
    @skills = Array.new( @skill_setsize ).map! { Sprite_Icon.new( self.viewport ) }
    for i in 0...@skills.size
      @skills[i].bush_opacity = 48
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :create_items
  #--------------------------------------------------------------------------#
  def create_items()
    @items = Array.new( @item_setsize ).map! { Sprite_Icon.new( self.viewport ) }
    for i in 0...@items.size
      @items[i].bush_opacity = 48
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :each_sprite
  #--------------------------------------------------------------------------#
  def each_sprite()
    (@sprites+@skills.to_a+@items.to_a).each { |s| yield s unless s.nil?() }
  end

  #--------------------------------------------------------------------------#
  # * new-method :x=
  #--------------------------------------------------------------------------#
  def x=( new_x )
    @x = new_x ; refresh_x()
  end

  #--------------------------------------------------------------------------#
  # * new-method :visible=
  #--------------------------------------------------------------------------#
  def visible=( new_visible )
    @visible = new_visible ; refresh_visible()
  end

  #--------------------------------------------------------------------------#
  # * new-method :y=
  #--------------------------------------------------------------------------#
  def y=( new_y )
    @y = new_y ; refresh_y()
  end

  #--------------------------------------------------------------------------#
  # * new-method :z=
  #--------------------------------------------------------------------------#
  def z=( new_z )
    @z = new_z ; refresh_z()
  end

  #--------------------------------------------------------------------------#
  # * new-method :viewport=
  #--------------------------------------------------------------------------#
  def viewport=( new_viewport )
    @viewport = new_viewport
    each_sprite { |s| s.viewport = @viewport }
  end

  #--------------------------------------------------------------------------#
  # * new-method :refresh_x
  #--------------------------------------------------------------------------#
  def refresh_x()
    each_sprite { |s| s.x = @x + s.add_x }
  end

  #--------------------------------------------------------------------------#
  # * new-method :refresh_y
  #--------------------------------------------------------------------------#
  def refresh_y()
    each_sprite { |s| s.y = @y + s.add_y }
  end

  #--------------------------------------------------------------------------#
  # * new-method :refresh_z
  #--------------------------------------------------------------------------#
  def refresh_z()
    each_sprite { |s| s.z = @z + s.add_z }
  end

  #--------------------------------------------------------------------------#
  # * new-method :refresh_add_xyz
  #--------------------------------------------------------------------------#
  def refresh_add_xyz()
    @back_sprite.set_add_xyz(     *@__hud_wrapper.get_obj_xyz( :back ) )
    @hp_sprite.set_add_xyz(       *@__hud_wrapper.get_obj_xyz( :hp_bar ) )
    @mp_sprite.set_add_xyz(       *@__hud_wrapper.get_obj_xyz( :mp_bar ) )
    @portrait_sprite.set_add_xyz( *@__hud_wrapper.get_obj_xyz( :sprite ) )
    @exp_sprite.set_add_xyz(      *@__hud_wrapper.get_obj_xyz( :exp_bar ) )
    @shift_sprite.set_add_xyz(    *@__hud_wrapper.get_obj_xyz( :shift_bar ) )
    @charge_sprite.set_add_xyz(   *@__hud_wrapper.get_obj_xyz( :charge_bar ) )
    for i in 0...@skills.size
      @skills[i].set_add_xyz(     *@__hud_wrapper.get_obj_xyz( :skill_icon, i ) )
    end
    for i in 0...@items.size
      @items[i].set_add_xyz(      *@__hud_wrapper.get_obj_xyz( :item_icon, i ) )
    end
  end

  #--------------------------------------------------------------------------#
  # * new-method :refresh_xyz
  #--------------------------------------------------------------------------#
  def refresh_xyz()
    each_sprite { |s| s.x, s.y, s.z = @x + s.add_x, @y + s.add_y, @z + s.add_z }
  end

  #--------------------------------------------------------------------------#
  # * new-method :refresh_visible
  #--------------------------------------------------------------------------#
  def refresh_visible()
    each_sprite { |s| s.visible = @visible }
  end

  #--------------------------------------------------------------------------#
  # * new-method :update
  #--------------------------------------------------------------------------#
  def update()
    if @__hud_wrapper.need_refresh
      @__hud_wrapper.refresh() ; refresh()
    end
    @hp_sprite.value, @hp_sprite.max = @__hud_wrapper.hp, @__hud_wrapper.maxhp
    @mp_sprite.value, @mp_sprite.max = @__hud_wrapper.mp, @__hud_wrapper.maxmp
    @exp_sprite.value, @exp_sprite.max = @__hud_wrapper.exp, @__hud_wrapper.maxexp
    @shift_sprite.value, @shift_sprite.max = @__hud_wrapper.shift, @__hud_wrapper.maxshift
    @charge_sprite.value, @charge_sprite.max = @__hud_wrapper.charge, @__hud_wrapper.maxcharge
    @hp_sprite.update()
    @mp_sprite.update()
    @exp_sprite.update()
    @shift_sprite.update()
    @charge_sprite.update()
    unless @__hud_wrapper.actor.nil?()
      for i in 0...@skills.size
        obj = @__hud_wrapper.actor.skill_slot( i )
        hnd = @__hud_wrapper.actor.get_skill_handle( obj.nil?() ? 0 : obj.id )
        sprite = @skills[i]
        sprite.tone.gray = 255.0 * hnd.time.to_f / [hnd.cap, 1].max
        sprite.bush_depth = sprite.height * hnd.time.to_f / [hnd.cap, 1].max
        icon_index = obj.nil?() ? 0 : obj.icon_index
        if sprite.icon_index != icon_index
          if sprite.active_effect == "none" && sprite.opacity == 0
            sprite.icon_index = icon_index
            sprite.active_effect = "fadein"
          elsif sprite.active_effect == "none" && sprite.opacity > 0
            sprite.opacity = 0 if sprite.icon_index == 0
            sprite.active_effect = "fadeout"
          end
        end
        sprite.update()
      end
      for i in 0...@items.size
        obj = @__hud_wrapper.actor.item_slot( i )
        hnd = @__hud_wrapper.actor.get_item_handle( obj.nil?() ? 0 : obj.id )
        sprite = @items[i]
        sprite.tone.gray = 255.0 * hnd.time.to_f / [hnd.cap, 1].max
        sprite.bush_depth = sprite.height * hnd.time.to_f / [hnd.cap, 1].max
        icon_index = obj.nil?() ? 0 : obj.icon_index
        if sprite.icon_index != icon_index
          if sprite.active_effect == "none" && sprite.opacity == 0
            sprite.icon_index = icon_index
            sprite.active_effect = "fadein"
          elsif sprite.active_effect == "none" && sprite.opacity > 0
            sprite.opacity = 0 if sprite.icon_index == 0
            sprite.active_effect = "fadeout"
          end
        end
        sprite.update()
      end
    end
  end

end
