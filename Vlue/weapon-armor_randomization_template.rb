#Weapon/Armor Randomization v1.8
#----------#
#Features: Allow the stats of an item to be randomized, yay! Also can tack
#           on random prefixes and suffixes. Oooh, fancy.
#
#Usage:    Basic Usage:
#
#           Note tags for weapons and armors:
#
#            <HP amount>  <HP% amount>  <ATK amount>  <ATK% amount>
#            <MP amount>  <MP% amount>  <DEF amount>  <DEF% amount>
#          <MAT amount>  <MAT% amount>  <MDF amount>  <MDF% amount>
#          <AGI amount>  <AGI% amount>  <LUK amount>  <LUK% amount>
#          <PRICE amount> <PRICE% amount>
#
#           Where amount is the amount to be randomly added on, with % being
#             a percentage instead of specific.
#           Examples: <HP 500>  or  <HP% 10>
#
#           Script calls:
#            add_armor(base_id, amount)
#            add_weapon(base_id, amount)
#          
#           These script calls create a new version of the item of the base_id
#            number, with randomized stats as set in their note.
#
#          Advanced Usage:
#          
#           Note tags for weapons and armors:
#
#            <SUFFIX# rarity>    <PREFIX# rarity>
#
#           Where # is the id number of the affix and rarity is the chance of it
#            occuring with 100 always occuring and 1 almost never occuring.
#            Multiple affix notes can be added and the first one that passes it's
#            rarity chance will be added.
#           Examples: <PREFIX1 50>  or  <SUFFIX2 90>
#
#          The Complicated Part: (Affixes)
#           See that AFFIXES hash down there? That's where you set these up.
#           Basic setup is:
#             ID => { :symbol => data, },
#           You can have as many different symbols in there as you want, each
#            seperated by a comma, and don't forget the comma between each AFFIX
#            id.
#
#           Usable Symbols:
#          :name = "name"               :color = Color.new(r,g,b)
#          :nameP = "prefix name"       :nameS = "suffix name"
#          :rarity = value              #Arbitrary value
#          :animation = id      
#          :icon = id
#          :desc = "description"
#
#   :hp,   :mp,   :atk,   :def,   :mat,   :mdf,   :agi,   :luk    (random bonus)
#   :Shp,  :Smp,  :Satk,  :Sdef,  :Smat,  :Smdf,  :Sagi,  :Sluk   (static bonus)
#   :hpP,  :mpP,  :atkP,  :defP,  :matP,  :mdfP,  :agiP,  :lukP   (random % bonus)
#   :ShpP, :SmpP, :SatkP, :SdefP, :SmatP, :SmdfP, :SagiP, :SlukP  (static % bonus)
#   :hpA,  :mpA,  :atkA,  :defA,  :matA,  :mdfA,  :agiA,  :lukA   (random average bonus)
#   :ShpA, :SmpA, :SatkA, :SdefA, :SmatA, :SmdfA, :SagiA, :SlukA  (static average bonus)
#
#
#   :price, :Sprice, :priceP, :SpriceP
#
#       each of these goes :symbol = value
#
#          The fun part, :features
#           You can have as many features as you want, set up in an array:
#           :features = [[code, id, value],[code, id, value]] etc...
#          But what are the codes, ids, and values?? Don't worry, I found out:
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
#     Examples: [21, 2, 1.5] which would increase atk to 150%
#               [62, 0, 0]   which makes the item give the auto-battle flag
#               [32, 1, 0.5] which gives a 50% of applying death state
#
#----------#
#-- Script by: Vlue of Daimonious Tails
#
#- Questions or comments can be:
#    posted on the thread for the script
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#
#--- Free to use in any project, commercial or non-commercial, with credit given
# - - Though a donation's always a nice way to say thank you~ (I also accept actual thank you's)
 
AFFIXES = {
            #COLORS
            0 => { },
            1 => { :name => "Superior ", :color => Color.new(50,255,0),
            :ShpP => 25, :SmpP => 25, :SatkP => 25, :SdefP => 25,
            :SmatP => 25, :SmdfP => 25, :SagiP => 25, :SlukP => 25}, #UNCOMMON
            2 => { :name => "Rare ", :color => Color.new(50,100,235),
            :ShpP => 45, :SmpP => 45, :SatkP => 45, :SdefP => 45,
            :SmatP => 45, :SmdfP => 45, :SagiP => 45, :SlukP => 45}, #RARE
            3 => { :name => "Epic ", :color => Color.new(255,25,255),
            :ShpP => 70, :SmpP => 70, :SatkP => 70, :SdefP => 70,
            :SmatP => 70, :SmdfP => 70, :SagiP => 70, :SlukP => 70}, #EPIC
            4 => { :name => "Legendary ", :color => Color.new(255,175,75),
            :ShpP => 95, :SmpP => 95, :SatkP => 95, :SdefP => 95,
            :SmatP => 95, :SmdfP => 95, :SagiP => 95, :SlukP => 95}, #LEGENDARY
            
            5 => { },
            6 => { :name => " +1", 
            :ShpP => 10, :SmpP => 10, :SatkP => 10, :SdefP => 10,
            :SmatP => 10, :SmdfP => 10, :SagiP => 10, :SlukP => 10}, 
            7 => { :name => " +2", 
            :ShpP => 25, :SmpP => 25, :SatkP => 25, :SdefP => 25,
            :SmatP => 25, :SmdfP => 25, :SagiP => 25, :SlukP => 25}, 
            8 => { :name => " +3",
            :ShpP => 40, :SmpP => 40, :SatkP => 40, :SdefP => 40,
            :SmatP => 40, :SmdfP => 40, :SagiP => 40, :SlukP => 40},
            
            #ATK+
            10 => { :nameP => "Attacker's ", :nameS => " of Attack", :SatkA => 1},
            11 => { :nameP => "Strong ", :nameS => " of Strength", :SatkA => 1.5},
            12 => { :nameP => "Powerful ", :nameS => " of Power", :SatkA => 2},
            13 => { :nameP => "Violent ", :nameS => " of Violence", :SatkA => 2.5},
            14 => { :nameP => "Striking ", :nameS => " of Striking", :SatkA => 3},
            
            #DEF+
            15 => { :nameP => "Defensive ", :nameS => " of Defense", :SdefA => 1},
            16 => { :nameP => "Armored ", :nameS => " of Armor", :SdefA => 1.5},
            17 => { :nameP => "Barricaded ", :nameS => " of the Barricade", :SdefA => 2},
            18 => { :nameP => "Aegis ", :nameS => " of the Aegis", :SdefA => 2.5},
            19 => { :nameP => "Iron Hide ", :nameS => " of Iron Hide", :SdefA => 3},
            
            #INT+
            20 => { :nameP => "Smart ", :nameS => " of Smarts", :SmatA => 1},
            21 => { :nameP => "Intelligent ", :nameS => " of Intelligence", :SmatA => 1.5},
            22 => { :nameP => "Astute ", :nameS => " of Astuteness", :SmatA => 2},
            23 => { :nameP => "Brilliant ", :nameS => " of Brilliance", :SmatA => 2.5},
            24 => { :nameP => "Keen ", :nameS => " of Genius", :SmatA => 3},
            
            #MDF+
            25 => { :nameP => "Wise ", :nameS => " of Wisdom", :SmdfA => 1},
            26 => { :nameP => "Insightful ", :nameS => " of Foresight", :SmdfA => 1.5},
            27 => { :nameP => "Sage ", :nameS => " of the Sage", :SmdfA => 2},
            28 => { :nameP => "Warded ", :nameS => " of Warding", :SmdfA => 2.5},
            29 => { :nameP => "Prudent ", :nameS => " of Prudence", :SmdfA => 3},
            
            #AGI+
            30 => { :nameP => "Agile ", :nameS => " of Agility", :SagiA => 1},
            31 => { :nameP => "Dextrous ", :nameS => " of Dexterity", :SagiA => 1.5},
            32 => { :nameP => "Swift ", :nameS => " of Swiftness", :SagiA => 2},
            33 => { :nameP => "Speedy ", :nameS => " of Speed", :SagiA => 2.5},
            34 => { :nameP => "Fleet ", :nameS => " of Fleetness", :SagiA => 3},
            
            #LUK+
            35 => { :nameP => "Lucky ", :nameS => " of Luck", :SlukA => 1},
            36 => { :nameP => "Blessed ", :nameS => " of Blessings", :SlukA => 1.5},
            37 => { :nameP => "Karmic ", :nameS => " of Karma", :SlukA => 2},
            38 => { :nameP => "Dicey ", :nameS => " of the Dice", :SlukA => 2.5},
            39 => { :nameP => "Gambler's ", :nameS => " of Gambling", :SlukA => 3},
            
            #HP+
            40 => { :nameP => "Healthy ", :nameS => " of Health", :ShpA => 2},
            41 => { :nameP => "Hardy ", :nameS => " of Hardiness", :ShpA => 3},
            42 => { :nameP => "Robust ", :nameS => " of Robustness", :ShpA => 4},
            43 => { :nameP => "Stamina ", :nameS => " of Stamina", :ShpA => 5},
            44 => { :nameP => "Vigorous ", :nameS => " of Vigour", :ShpA => 6},
            
            #MP+
            45 => { :nameP => "Manawise ", :nameS => " of Mana", :SmpA => 2},
            46 => { :nameP => "Magical ", :nameS => " of Magic", :SmpA => 3},
            47 => { :nameP => "Soulful ", :nameS => " of the Soul", :SmpA => 4},
            48 => { :nameP => "Energized ", :nameS => " of Energy", :SmpA => 5},
            49 => { :nameP => "Azure ", :nameS => " of the Azure", :SmpA => 6},
            
            #ATK/DEF+
            50 => { :nameP => "Fighter's ", :nameS => " of the Fighter", 
                    :SatkA => 1,   :SdefA => 1},
            51 => { :nameP => "Soldier's ", :nameS => " of the Soldier", 
                    :SatkA => 1.25,:SdefA => 1.25},
            52 => { :nameP => "Strongman's ", :nameS => " of the Strong", 
                    :SatkA => 1.5, :SdefA => 1.5},
            53 => { :nameP => "Basher's ", :nameS => " of Bashing", 
                    :SatkA => 1.75,:SdefA => 1.75},
            54 => { :nameP => "Clawed ", :nameS => " of the Claw", 
                    :SatkA => 2,   :SdefA => 2},
            
            #INT/MDF+
            55 => { :nameP => "Magician's ", :nameS => " of the Magician", 
                    :SmatA => 1,   :SmdfA => 1},
            56 => { :nameP => "Wizard's ", :nameS => " of the Wizard", 
                    :SmatA => 1.25,:SmdfA => 1.25},
            57 => { :nameP => "Casters ", :nameS => " of Casting", 
                    :SmatA => 1.5, :SmdfA => 1.5},
            58 => { :nameP => "Warlock's ", :nameS => " of the Warlock", 
                    :SmatA => 1.75,:SmdfA => 1.75},
            59 => { :nameP => "Archmage's ", :nameS => " of the Arch Mage", 
                    :SmatA => 2,   :SmdfA => 2},
            
            #ATK/INT+
            60 => { :nameP => "The Jack's ", :nameS => " of the Jack", 
                    :SmatA => 1,   :SatkA => 1},
            61 => { :nameP => "Spellblade's ", :nameS => " of the Spellblade", 
                    :SmatA => 1.25,:SatkA => 1.25},
            62 => { :nameP => "Charged ", :nameS => " of Charging", 
                    :SmatA => 1.5, :SatkA => 1.5},
            63 => { :nameP => "The Owl ", :nameS => " of the Wise Owl", 
                    :SmatA => 1.75,:SatkA => 1.75},
            64 => { :nameP => "Artenzed ", :nameS => " of the Artenzer", 
                    :SmatA => 2,   :SatkA => 2},
            
            #DEF/MDF+
            65 => { :nameP => "The Walled ", :nameS => " of the Wall", 
                    :SdefA => 1,   :SmdfA => 1},
            66 => { :nameP => "Knight's ", :nameS => " of the Knight", 
                    :SdefA => 1.25,:SmdfA => 1.25},
            67 => { :nameP => "Gladiator's ", :nameS => " of the Gladiator", 
                    :SdefA => 1.5, :SmdfA => 1.5},
            68 => { :nameP => "Boar's Head ", :nameS => " of the Boar", 
                    :SdefA => 1.75,:SmdfA => 1.75},
            69 => { :nameP => "Bear Hide ", :nameS => " of the Bear", 
                    :SdefA => 2,   :SmdfA => 2},
            
            #AGI/LUK+
            70 => { :nameP => "The Hunter ", :nameS => " of the Hunter", 
                    :SagiA => 1,   :SlukA => 1},
            71 => { :nameP => "The Ranger ", :nameS => " of the Ranger", 
                    :SagiA => 1.25,:SlukA => 1.25},
            72 => { :nameP => "Swift Luck ", :nameS => " of Swift Luck", 
                    :SagiA => 1.5, :SlukA => 1.5},
            73 => { :nameP => "Snake Skin ", :nameS => " of the Snake", 
                    :SagiA => 1.75,:SlukA => 1.75},
            74 => { :nameP => "Dakarai ", :nameS => " of the Dakara", 
                    :SagiA => 2,   :SlukA => 2},
            
            #ATK/AGI
            75 => { :nameP => "Swift Strike ", :nameS => " of the Swift Strike", 
                    :SatkA => 1,   :SagiA => 1},
            76 => { :nameP => "Rougish ", :nameS => " of the Rogue", 
                    :SatkA => 1.25,:SagiA => 1.25},
            77 => { :nameP => "Brawler's ", :nameS => " of the Brawler", 
                    :SatkA => 1.5, :SagiA => 1.5},
            78 => { :nameP => "The Thief ", :nameS => " of the Thief", 
                    :SatkA => 1.75,:SagiA => 1.75},
            79 => { :nameP => "Nova's ", :nameS => " of Nova", 
                    :SatkA => 2,   :SagiA => 2},
            
            #INT/AGI+
            80 => { :nameP => "Wingtipped ", :nameS => " of the Wingtips", 
                    :SmatA => 1,   :SagiA => 1},
            81 => { :nameP => "Nightblade ", :nameS => " of the Nightblade", 
                    :SmatA => 1.25,:SagiA => 1.25},
            82 => { :nameP => "Swift Mind ", :nameS => " of the Swift Mind", 
                    :SmatA => 1.5, :SagiA => 1.5},
            83 => { :nameP => "Stalker ", :nameS => " of the Stalker", 
                    :SmatA => 1.75,:SagiA => 1.75},
            84 => { :nameP => "Delima's ", :nameS => " of Delima", 
                    :SmatA => 2,   :SagiA => 2},
            
            #HP/DEF+
            85 => { :nameP => "Lancer's ", :nameS => " of the Lancer", 
                    :ShpA => 2,  :SdefA => 1},
            86 => { :nameP => "Commando ", :nameS => " of the Commando", 
                    :ShpA => 2.5,:SdefA => 1.25},
            87 => { :nameP => "Defender's ", :nameS => " of the Defender", 
                    :ShpA => 3,  :SdefA => 1.5},
            88 => { :nameP => "Dragoon's ", :nameS => " of the Dragoon", 
                    :ShpA => 3.5,:SdefA => 1.75},
            89 => { :nameP => "Twisted ", :nameS => " of the Twisted", 
                    :ShpA => 4,  :SdefA => 2},
            
            #MP/MDF+
            90 => { :nameP => "Abjurer's ", :nameS => " of the Abjurer", 
                    :SmpA => 2,  :SmdfA => 1},
            91 => { :nameP => "Manazized ", :nameS => " of Manazize", 
                    :SmpA => 2.5,:SmdfA => 1.25},
            92 => { :nameP => "Bishop's ", :nameS => " of the Bishop", 
                    :SmpA => 3,  :SmdfA => 1.5},
            93 => { :nameP => "Illusionary  ", :nameS => " of Illusions", 
                    :SmpA => 3.5,:SmdfA => 1.75},
            94 => { :nameP => "Conjuring ", :nameS => " of Conjury", 
                    :SmpA => 4,  :SmdfA => 2},
            
            #HP/MP+
            95 => { :nameP => "Redoubt ", :nameS => " of Redoubt", 
                    :ShpA => 2,  :SmpA => 2},
            96 => { :nameP => "Vigourful ", :nameS => " of Great Vigour", 
                    :ShpA => 2.5,:SmpA => 2.5},
            97 => { :nameP => "Ancient ", :nameS => " of the Ancients", 
                    :ShpA => 3,  :SmpA => 3},
            98 => { :nameP => "Elderly ", :nameS => " of the Elder", 
                    :ShpA => 3.5,:SmpA => 3.5},
            99 => { :nameP => "Soulless ", :nameS => " of the Soulless", 
                    :ShpA => 4,  :SmpA => 4},
            
            #ATK+ INT-
            100 => { :nameP => "Bitter ", :nameS => " of Bitterment", 
                     :SatkA => 2,  :SmatA => -1},
            101 => { :nameP => "Fury ", :nameS => " of Fury", 
                     :SatkA => 2.5,:SmatA => -1.25},
            102 => { :nameP => "Resenting ", :nameS => " of the Resentful", 
                     :SatkA => 3,  :SmatA => -1.5},
            103 => { :nameP => "Furious ", :nameS => " of the Furious", 
                     :SatkA => 3.5,:SmatA => -1.75},
            104 => { :nameP => "Destroyer's ", :nameS => " of the Destroyer", 
                     :SatkA => 4,  :SmatA => -2},
            
            #ATK+ DEF-
            105 => { :nameP => "Reckless ", :nameS => " of the Reckless", 
                     :SatkA => 2,  :SdefA => -1},
            106 => { :nameP => "Ragged ", :nameS => " of the Ragged", 
                     :SatkA => 2.5,:SdefA => -1.25},
            107 => { :nameP => "Edged ", :nameS => " of the Double Edge", 
                     :SatkA => 3,  :SdefA => -1.5},
            108 => { :nameP => "Sharpened ", :nameS => " of Sharpness", 
                     :SatkA => 3.5,:SdefA => -1.75},
            109 => { :nameP => "Wrecking ", :nameS => " of Wrecking", 
                     :SatkA => 4,  :SdefA => -2},
            
            #ATK+ AGI-
            110 => { :nameP => "Sloth ", :nameS => "of the Sloth", 
                     :SatkA => 2,  :SagiA => -1},
            111 => { :nameP => "Congealed ", :nameS => " of Congealing", 
                     :SatkA => 2.5,:SagiA => -1.25},
            112 => { :nameP => "Heavy ", :nameS => " with Weight", 
                     :SatkA => 3,  :SagiA => -1.5},
            113 => { :nameP => "Hard Iron ", :nameS => " of Hard Iron", 
                     :SatkA => 3.5,:SagiA => -1.75},
            114 => { :nameP => "Adamntite ", :nameS => " of Adamantium", 
                     :SatkA => 4,  :SagiA => -2},
            
            #DEF+ ATK-
            115 => { :nameP => "Brass ", :nameS => " of Brass", 
                     :SdefA => 2,  :SatkA => -1},
            116 => { :nameP => "Blocking ", :nameS => " of Blocking", 
                     :SdefA => 2.5,:SatkA => -1.25},
            117 => { :nameP => "Parrying ", :nameS => " of Parrying", 
                     :SdefA => 3,  :SatkA => -1.5},
            118 => { :nameP => "Tactful ", :nameS => " of Tactics", 
                     :SdefA => 3.5,:SatkA => -1.75},
            119 => { :nameP => "Iron Bark ", :nameS => " of Iron Bark", 
                     :SdefA => 4,  :SatkA => -2},
            
            #DEF+ AGI-
            120 => { :nameP => "Turtle Shell ", :nameS => " of the Turtle", 
                     :SdefA => 2,  :SagiA => -1},
            121 => { :nameP => "Yew ", :nameS => " of Yew Bark", 
                     :SdefA => 2.5,:SagiA => -1.25},
            122 => { :nameP => "Familiar ", :nameS => " of the Familiar", 
                     :SdefA => 3,  :SagiA => -1.5},
            123 => { :nameP => "Striped ", :nameS => " of the Stripped", 
                     :SdefA => 3.5,:SagiA => -1.75},
            124 => { :nameP => "Charred ", :nameS => " of the Charred", 
                     :SdefA => 4,  :SagiA => -2},
            
            #INT+ ATK-
            125 => { :nameP => "Scholar's ", :nameS => " of the Scholar", 
                     :SmatA => 2,  :SatkA => -1},
            126 => { :nameP => "Learned ", :nameS => " of Learning", 
                     :SmatA => 2.5,:SatkA => -1.25},
            127 => { :nameP => "Witty ", :nameS => " of Wit", 
                     :SmatA => 3,  :SatkA => -1.5},
            128 => { :nameP => "Bright ", :nameS => " of the Bright", 
                     :SmatA => 3.5,:SatkA => -1.75},
            129 => { :nameP => "Mage's ", :nameS => " of the Mage", 
                     :SmatA => 4,  :SatkA => -2},
            
            #INT+ MDF-
            130 => { :nameP => "Near-sighted ", :nameS => " of Near Sight", 
                     :SmatA => 2,  :SmdfA => -1},
            131 => { :nameP => "Tunneler's ", :nameS => " of Tunneling", 
                     :SmatA => 2.5,:SmdfA => -1.25},
            132 => { :nameP => "Mole Whisker ", :nameS => " of the Mole", 
                     :SmatA => 3,  :SmdfA => -1.5},
            133 => { :nameP => "Dolphin Eye ", :nameS => " of the Dolphin", 
                     :SmatA => 3.5,:SmdfA => -1.75},
            134 => { :nameP => "Bra-injun's ", :nameS => " of Bra-injun", 
                     :SmatA => 4,  :SmdfA => -2},
            
            #INT+ DEF-
            135 => { :nameP => "Frail ", :nameS => " of Frailty", 
                     :SmatA => 2,  :SdefA => -1},
            136 => { :nameP => "Feeble ", :nameS => " of the Feeble", 
                     :SmatA => 2.5,:SdefA => -1.25},
            137 => { :nameP => "Slender ", :nameS => " of Slimness", 
                     :SmatA => 3,  :SdefA => -1.5},
            138 => { :nameP => "Brittle ", :nameS => " of Brittleness", 
                     :SmatA => 3.5,:SdefA => -1.75},
            139 => { :nameP => "Delicate ", :nameS => " of the Delicate", 
                     :SmatA => 4,  :SdefA => -2},
            
            #INT+ AGI-
            140 => { :nameP => "Farmer's ", :nameS => " of the Farmer", 
                     :SmatA => 2,  :SagiA => -1},
            141 => { :nameP => "Summoner's ", :nameS => " of the Summoner", 
                     :SmatA => 2.5,:SagiA => -1.25},
            142 => { :nameP => "Amazing ", :nameS => " of the Amazed", 
                     :SmatA => 3,  :SagiA => -1.5},
            143 => { :nameP => "Rennet ", :nameS => " of Rennet", 
                     :SmatA => 3.5,:SagiA => -1.75},
            144 => { :nameP => "Mindful ", :nameS => " of the Mind", 
                     :SmatA => 4,  :SagiA => -2},
            
            #MDF+ DEF-
            145 => { :nameP => "Shielded ", :nameS => " of the Shield", 
                     :SmdfA => 2,  :SdefA => -1},
            146 => { :nameP => "Conjured ", :nameS => " of the Conjured", 
                     :SmdfA => 2.5,:SdefA => -1.25},
            147 => { :nameP => "Resistant ", :nameS => " of Resistance", 
                     :SmdfA => 3,  :SdefA => -1.5},
            148 => { :nameP => "Screened ", :nameS => " of Screening", 
                     :SmdfA => 3.5,:SdefA => -1.75},
            149 => { :nameP => "Lief's ", :nameS => " of Lief", 
                     :SmdfA => 4,  :SdefA => -2},
            
            #MDF+ INT-
            150 => { :nameP => "Gifted ", :nameS => " of the Gifted", 
                     :SmdfA => 2,  :SmatA => -1},
            151 => { :nameP => "Willing ", :nameS => " of the Willing", 
                     :SmdfA => 2.5,:SmatA => -1.25},
            152 => { :nameP => "Fearful ", :nameS => " of the Fearful", 
                     :SmdfA => 3,  :SmatA => -1.5},
            153 => { :nameP => "Finest ", :nameS => " of the Finest", 
                     :SmdfA => 3.5,:SmatA => -1.75},
            154 => { :nameP => "Diviner's ", :nameS => " of the Diviner", 
                     :SmdfA => 4,  :SmatA => -2},
            
            #AGI+ ATK-
            155 => { :nameP => "Bard's ", :nameS => " of the Bard", 
                     :SagiA => 2,  :SatkA => -1},
            156 => { :nameP => "Songweave ", :nameS => " of the Song", 
                     :SagiA => 2.5,:SatkA => -1.25},
            157 => { :nameP => "Sound ", :nameS => " of Sound", 
                     :SagiA => 3,  :SatkA => -1.5},
            158 => { :nameP => "Singer's ", :nameS => " of Singing", 
                     :SagiA => 3.5,:SatkA => -1.75},
            159 => { :nameP => "Totakai's ", :nameS => " of Totokai", 
                     :SagiA => 4,  :SatkA => -2},
            
            #AGI+ DEF-
            160 => { :nameP => "Burglar's ", :nameS => " of the Burglar", 
                     :SagiA => 2,  :SdefA => -1},
            161 => { :nameP => "Leather ", :nameS => " of Leather", 
                     :SagiA => 2.5,:SdefA => -1.25},
            162 => { :nameP => "Tiger Fang ", :nameS => " of the Tiger", 
                     :SagiA => 3,  :SdefA => -1.5},
            163 => { :nameP => "Nightblade's ", :nameS => " of the Nightblade", 
                     :SagiA => 3.5,:SdefA => -1.75},
            164 => { :nameP => "Crood's ", :nameS => " of Crood", 
                     :SagiA => 4,  :SdefA => -2},
            
            #AGI+ LUK-
            165 => { :nameP => "Alacrity ", :nameS => " of Alacrity", 
                     :SagiA => 2,  :SlukA => -1},
            166 => { :nameP => "Brisk ", :nameS => " of Briskness", 
                     :SagiA => 2.5,:SlukA => -1.25},
            167 => { :nameP => "Lithe ", :nameS => " of Litheness", 
                     :SagiA => 3,  :SlukA => -1.5},
            168 => { :nameP => "Frisk ", :nameS => " of Friskyness", 
                     :SagiA => 3.5,:SlukA => -1.75},
            169 => { :nameP => "Acrobatic ", :nameS => " of Acrobatics", 
                     :SagiA => 4,  :SlukA => -2},
            
            #LUK+ AGI-
            170 => { :nameP => "Roller's ", :nameS => " of the High Roller", 
                     :SlukA => 2,  :SagiA => -1},
            171 => { :nameP => "Trapper's ", :nameS => " of the Trapper", 
                     :SlukA => 2.5,:SagiA => -1.25},
            172 => { :nameP => "Favoured ", :nameS => " of the Favoured", 
                     :SlukA => 3,  :SagiA => -1.5},
            173 => { :nameP => "Lady's ", :nameS => " of Lady Luck", 
                     :SlukA => 3.5,:SagiA => -1.75},
            174 => { :nameP => "Rabbit Foot ", :nameS => " of the Rabbit", 
                     :SlukA => 4,  :SagiA => -2},
            
            #DEF+ MP-
            175 => { :nameP => "Craven ", :nameS => " of the Craven", 
                     :SdefA => 2,  :SmpA => -2},
            176 => { :nameP => "Shelled ", :nameS => " of Shells", 
                     :SdefA => 2.5,:SmpA => -2.5},
            177 => { :nameP => "Slimy ", :nameS => " of Slime", 
                     :SdefA => 3,  :SmpA => -3},
            178 => { :nameP => "Demon Fang ", :nameS => " of Demons", 
                     :SdefA => 3.5,:SmpA => -3.5},
            179 => { :nameP => "Crevice ", :nameS => " of the Crevice", 
                     :SdefA => 4,  :SmpA => -4},
            
            #MDF+ HP-
            180 => { :nameP => "Weak ", :nameS => " of the Weak", 
                     :SmdfA => 2,  :ShpA => -2},
            181 => { :nameP => "Petal ", :nameS => " of Petals", 
                     :SmdfA => 2.5,:ShpA => -2.5},
            182 => { :nameP => "Carved ", :nameS => " of Carvings", 
                     :SmdfA => 3,  :ShpA => -3},
            183 => { :nameP => "Juggler's ", :nameS => " of the Juggler", 
                     :SmdfA => 3.5,:ShpA => -3.5},
            184 => { :nameP => "Kraine's ", :nameS => " of Kraine", 
                     :SmdfA => 4,  :ShpA => -4},
            
            #ATK+ HP-
            185 => { :nameP => "Raging ", :nameS => " of Rage", 
                     :SatkA => 2,  :ShpA => -2},
            186 => { :nameP => "Brash ", :nameS => " of Brashness", 
                     :SatkA => 2.5,:ShpA => -2.5},
            187 => { :nameP => "Beserker's ", :nameS => " of the Beserker", 
                     :SatkA => 3,  :ShpA => -3},
            188 => { :nameP => "Desperate ", :nameS => " of Desperation",
                     :SatkA => 3.5,:ShpA => -3.5},
            189 => { :nameP => "Grugg's ", :nameS => " of Grugg", 
                     :SatkA => 4,  :ShpA => -4},
            
            #INT+ MP-
            190 => { :nameP => "Compulsive ", :nameS => " of Compulsion", 
                     :SmatA => 2,  :SmpA => -2},
            191 => { :nameP => "Urgent ", :nameS => " of Urgency", 
                     :SmatA => 2.5,:SmpA => -2.5},
            192 => { :nameP => "Compelling ", :nameS => " of Compelling", 
                     :SmatA => 3,  :SmpA => -3},
            193 => { :nameP => "Rough ", :nameS => " of Roughness", 
                     :SmatA => 3.5,:SmpA => -3.5},
            194 => { :nameP => "Nahasi's ", :nameS => " of Nahasi", 
                     :SmatA => 4,  :SmpA => -4},
            
            #ATK- HP+
            195 => { :nameP => "Athletic ", :nameS => " of Athleticism", 
                     :ShpA => 4,  :SatkA => -1},
            196 => { :nameP => "Active ", :nameS => " of Activity", 
                     :ShpA => 5,  :SatkA => -1.25},
            197 => { :nameP => "Lively ", :nameS => " of Living", 
                     :ShpA => 6,  :SatkA => -1.5},
            198 => { :nameP => "Hearty ", :nameS => " of the Heart", 
                     :ShpA => 7,  :SatkA => -1.75},
            199 => { :nameP => "Prop ", :nameS => " of Props", 
                     :ShpA => 8,  :SatkA => -2},
            
            #INT- MP+
            200 => { :nameP => "Cleric's ", :nameS => " of the Cleric",  
                     :SmpA => 4,  :SmatA => -1},
            201 => { :nameP => "Priest's ", :nameS => " of the Priest", 
                     :SmpA => 5,  :SmatA => -1.25},
            202 => { :nameP => "Slacker's ", :nameS => " of the Slacker", 
                     :SmpA => 6,  :SmatA => -1.5},
            203 => { :nameP => "Lazy ", :nameS => " of the Lazy", 
                     :SmpA => 7,  :SmatA => -1.75},
            204 => { :nameP => "Sprat's ", :nameS => " of Sprat", 
                     :SmpA => 8,  :SmatA => -2},
            
            #INT- HP+
            205 => { :nameP => "Jive ", :nameS => " of the Jive", 
                     :ShpA => 4,  :SmatA => -1},
            206 => { :nameP => "Restitute ", :nameS => " of Restitution", 
                     :ShpA => 5,  :SmatA => -1.25},
            207 => { :nameP => "Turkey Beak ", :nameS => " of the Turkey", 
                     :ShpA => 6,  :SmatA => -1.5},
            208 => { :nameP => "Rawhide ", :nameS => " of Rawhide", 
                     :ShpA => 7,  :SmatA => -1.75},
            209 => { :nameP => "Otto's ", :nameS => " of Otto", 
                     :ShpA => 8,  :SmatA => -2},
            
            #ATK- MP+
            210 => { :name => "Feathered ", :nameS => " of Feathers", 
                     :SmpA => 4,  :SatkA => -1},
            211 => { :name => "Woven ", :nameS => " of the Weave", 
                     :SmpA => 5,  :SatkA => -1.25},
            212 => { :name => "Wrapped ", :nameS => " of the Wrap", 
                     :SmpA => 6,  :SatkA => -1.5},
            213 => { :name => "Strung ", :nameS => " of Strings", 
                     :SmpA => 7,  :SatkA => -1.75},
            214 => { :name => "Fram's ", :nameS => " of Fram", 
                     :SmpA => 8,  :SatkA => -2},
            
            #HP+ MP-
            215 => { :nameP => "Unbalanced ", :nameS => " of Unbalance", 
                     :ShpA => 4,  :SmpA => -2},
            216 => { :nameP => "Buccaneer's ", :nameS => " of the Buccaneer", 
                     :ShpA => 5,  :SmpA => -2.5},
            217 => { :nameP => "Koala Toe ", :nameS => " of the Koala", 
                     :ShpA => 6,  :SmpA => -3},
            218 => { :nameP => "Pirate's ", :nameS => " of the Pirate", 
                     :ShpA => 7,  :SmpA => -3.5},
            219 => { :nameP => "Dire Beast ", :nameS => " of the Dire", 
                     :ShpA => 8,  :SmpA => -4},
            
            #MP+ HP-
            220 => { :nameP => "Disturbed ", :nameS => " of Distrubance", 
                     :SmpA => 4,  :ShpA => -2},
            221 => { :nameP => "Classic ", :nameS => " of the Classics", 
                     :SmpA => 5,  :ShpA => -2.5},
            222 => { :nameP => "Joke ", :nameS => " of Jokes", 
                     :SmpA => 6,  :ShpA => -3},
            223 => { :nameP => "Cypress ", :nameS => " of Cypress", 
                     :SmpA => 7,  :ShpA => -3.5},
            224 => { :nameP => "Aloe Leaf ", :nameS => " of Aloe", 
                     :SmpA => 8,  :ShpA => -4},
            
            #ATK/DEF+ INT/MDF-
            225 => { :nameP => "Gnoll's ", :nameS => " of the Gnoll", 
              :SatkA => 2,    :SdefA => 2, :SmatA => -1,   :SmdfA => -1},
            226 => { :nameP => "Goblin's ", :nameS => " of the Goblin", 
              :SatkA => 2.5,  :SdefA => 2.5, :SmatA => -1.25,:SmdfA => -1.25},
            227 => { :nameP => "Troll's ", :nameS => " of the Troll", 
              :SatkA => 3,    :SdefA => 3, :SmatA => -1.5, :SmdfA => -1.5},
            228 => { :nameP => "Crusher's ", :nameS => " of the Crusher", 
              :SatkA => 3.5,  :SdefA => 3.5, :SmatA => -1.75,:SmdfA => -1.75},
            229 => { :nameP => "Giant's ", :nameS => " of the Giant", 
              :SatkA => 4,    :SdefA => 4, :SmatA => -2,   :SmdfA => -2},
            
            #INT/MDF+ ATK/DEF-
            230 => { :nameP => "Goldfish's ", :nameS => " of the Goldfish", 
              :SmatA => 2,    :SmdfA => 2, :SatkA => -1,   :SdefA => -1},
            231 => { :nameP => "Siren's ", :nameS => " of the Siren", 
              :SmatA => 2.5,  :SmdfA => 2.5, :SatkA => -1.25,:SdefA => -1.25},
            232 => { :nameP => "Mermaid's ", :nameS => " of the Mermaid", 
              :SmatA => 3,    :SmdfA => 3, :SatkA => -1.5, :SdefA => -1.5},
            233 => { :nameP => "Koi's ", :nameS => " of the Koi", 
              :SmatA => 3.5,  :SmdfA => 3.5, :SatkA => -1.75,:SdefA => -1.75},
            234 => { :nameP => "Branded ", :nameS => " of the Brand", 
              :SmatA => 4,    :SmdfA => 4, :SatkA => -2,   :SdefA => -2},
            
            #ATK/INT+ DEF/MDF-
            235 => { :nameP => "Lion Mane ", :nameS => " of the Lion", 
              :SmatA => 2,    :SmatA => 2, :SmdfA => -1,   :SdefA => -1},
            236 => { :nameP => "Bat Wing ", :nameS => " of the Bat", 
              :SmatA => 2.5,  :SmatA => 2.5, :SmdfA => -1.25,:SdefA => -1.25},
            237 => { :nameP => "Harpy's ", :nameS => " of the Harpy", 
              :SmatA => 3,    :SmatA => 3, :SmdfA => -1.5, :SdefA => -1.5},
            238 => { :nameP => "Excellent ", :nameS => " of Excelence", 
              :SmatA => 3.5,  :SmatA => 3.5, :SmdfA => -1.75,:SdefA => -1.75},
            239 => { :nameP => "Matriarch ", :nameS => " of the Matriarch", 
              :SmatA => 4,    :SmatA => 4, :SmdfA => -2,   :SdefA => -2},
            
            #ATK/INT+ AGI/LUK-
            240 => { :nameP => "Panda Fur ", :nameS => " of the Panda", 
              :SmatA => 2,    :SatkA => 2, :SagiA => -1,   :SlukA => -1},
            241 => { :nameP => "Fisher's ", :nameS => " of the Fisher", 
              :SmatA => 2.5,  :SatkA => 2.5, :SagiA => -1.25,:SlukA => -1.25},
            242 => { :nameP => "Dame's ", :nameS => " of the Dame", 
              :SmatA => 3,    :SatkA => 3,:SagiA => -1.5, :SlukA => -1.5},
            243 => { :nameP => "Grand ", :nameS => " of the Grandoise", 
              :SmatA => 3.5,  :SatkA => 3.5, :SagiA => -1.75,:SlukA => -1.75},
            244 => { :nameP => "Tyrone's ", :nameS => " of Tyrone", 
              :SmatA => 4,    :SatkA => 4, :SagiA => -2,   :SlukA => -2},
            
            #HP/MP+ ATK/INT-
            245 => { :nameP => "Willow ", :nameS => " of the Willow", 
              :ShpA => 4,     :SmpA => 4, :SatkA => -1,   :SmatA => -1},
            246 => { :nameP => "Acorn ", :nameS => " of the Acorn", 
              :ShpA => 5,     :SmpA => 5, :SatkA => -1.25,:SmatA => -1.25},
            247 => { :nameP => "Cactus ", :nameS => " of the Cactus", 
              :ShpA => 6,     :SmpA => 6, :SatkA => -1.5, :SmatA => -1.5},
            248 => { :nameP => "Superb ", :nameS => " of the Superb", 
              :ShpA => 7,     :SmpA => 7, :SatkA => -1.75,:SmatA => -1.75},
            249 => { :nameP => "Bursting ", :nameS => " of Bursting", 
              :ShpA => 8,     :SmpA => 8, :SatkA => -2,   :SmatA => -2},
            
            #HP/DEF+ ATK/INT-
            250 => { :nameP => "Pinecone ", :nameS => " of the Pinecone", 
              :ShpA => 4,     :SdefA => 2, :SatkA => -1,   :SmatA => -1},
            251 => { :nameP => "Armadillo's ", :nameS => " of the Armadillo", 
              :ShpA => 5,     :SdefA => 2.5, :SatkA => -1.25,:SmatA => -1.25},
            252 => { :nameP => "Totemic ", :nameS => " of Totems", 
              :ShpA => 6,     :SdefA => 3, :SatkA => -1.5, :SmatA => -1.5},
            253 => { :nameP => "Shrew's ", :nameS => " of the Shrew", 
              :ShpA => 7,     :SdefA => 3.5, :SatkA => -1.75,:SmatA => -1.75},
            254 => { :nameP => "Nonsense ", :nameS => " of Nonsense", 
              :ShpA => 8,     :SdefA => 4, :SatkA => -2,   :SmatA => -2},
            
            #MP/MDF+ ATK/INT-
            255 => { :nameP => "Caned ", :nameS => " of the Caned", 
              :SmpA => 4,     :SmdfA => 2, :SatkA => -1,   :SmatA => -1},
            256 => { :nameP => "Wyvern's ", :nameS => " of the Wyvern", 
              :SmpA => 5,     :SmdfA => 2.5, :SatkA => -1.25,:SmatA => -1.25},
            257 => { :nameP => "Hemmed ", :nameS => " of Hems", 
              :SmpA => 6,     :SmdfA => 3, :SatkA => -1.5, :SmatA => -1.5},
            258 => { :nameP => "Sugar Cane ", :nameS => " of Sugar Cane", 
              :SmpA => 7,     :SmdfA => 3.5, :SatkA => -1.75,:SmatA => -1.75},
            259 => { :nameP => "Majestic ", :nameS => " of Majesty", 
              :SmpA => 8,     :SmdfA => 4, :SatkA => -2,   :SmatA => -2},
            
            #ATK/INT/AGI+ DEF/MDF/LUK-
            260 => { :nameP => "Cougar Hide ", :nameS => " of the Cougar", 
                                  :SmatA => 2,    :SatkA => 2,    :SagiA => 2,
                                  :SdefA => -1,   :SlukA => -1,   :SmdfA => -1},
            261 => { :nameP => "Elven ", :nameS => " of the Elves", 
                                  :SmatA => 2.5,  :SatkA => 2.5,  :SagiA => 2.5,
                                  :SdefA => -1.25,:SlukA => -1.25,:SmdfA => -1.25},
            262 => { :nameP => "Drow ", :nameS => " of the Drow's", 
                                  :SmatA => 3,    :SatkA => 3,    :SagiA => 3,
                                  :SdefA => -1.5, :SlukA => -1.5, :SmdfA => -1.5},
            263 => { :nameP => "Beastly ", :nameS => " of the Beasts", 
                                  :SmatA => 3.5,  :SatkA => 3.5,  :SagiA => 3.5,
                                  :SdefA => -1.75,:SlukA => -1.75,:SmdfA => -1.75},
            264 => { :nameP => "Shade's ", :nameS => " of the Shade", 
                                  :SmatA => 4,    :SatkA => 4,    :SagiA => 4,
                                  :SdefA => -2,   :SlukA => -2 ,  :SmdfA => -2},
            
            #DEF/MDF/LUK+ ATK/INT/AGI-
            265 => { :nameP => "Halfling ", :nameS => " of the Halflings", 
                                  :SmatA => -1,   :SatkA => -1,   :SagiA => -1,
                                  :SdefA => 2,    :SlukA => 2,    :SmdfA => 2},
            266 => { :nameP => "Dwarven ", :nameS => " of the Dwarves", 
                                  :SmatA => -1.25,:SatkA => -1.25,:SagiA => -1.25,
                                  :SdefA => 2.5,  :SlukA => 2.5,  :SmdfA => 2.5},
            267 => { :nameP => "Wanderer's ", :nameS => " of the Wanderer", 
                                  :SmatA => -1.5, :SatkA => -1.5, :SagiA => -1.5,
                                  :SdefA => 3,    :SlukA => 3,    :SmdfA => 3},
            268 => { :nameP => "Traveler's ", :nameS => " of the Traveler", 
                                  :SmatA => -1.75,:SatkA => -1.75,:SagiA => -1.75,
                                  :SdefA => 3.5,  :SlukA => 3.5,  :SmdfA => 3.5},
            269 => { :nameP => "Staunch ", :nameS => " of the Staunch", 
                                  :SmatA => -2,   :SatkA => -2,   :SagiA => -2,
                                  :SdefA => 4,    :SlukA => 4,    :SmdfA => 4},
            
            #ATK/DEF/INT/MDF/AGI/LUK+
            270 => { :nameP => "Noble ", :nameS => " of the Noble", 
                                  :SatkA => 0.25, :SdefA => 0.25, :SmatA => 0.25,
                                  :SmdfA => 0.25, :SagiA => 0.25, :SlukA => 0.25},
            271 => { :nameP => "Lord's ", :nameS => " of the Lord", 
                                  :SatkA => 0.5,  :SdefA => 0.5,  :SmatA => 0.5,
                                  :SmdfA => 0.5,  :SagiA => 0.5,  :SlukA => 0.5},
            272 => { :nameP => "Princely ", :nameS => " of Princes", 
                                  :SatkA => 0.75, :SdefA => 0.75, :SmatA => 0.75,
                                  :SmdfA => 0.75, :SagiA => 0.75, :SlukA => 0.75},
            273 => { :nameP => "Queen's ", :nameS => " of the Queen", 
                                  :SatkA => 1,    :SdefA => 1,    :SmatA => 1,
                                  :SmdfA => 1,    :SagiA => 1,    :SlukA => 1},
            274 => { :nameP => "Kingly ", :nameS => " of the King", 
                                  :SatkA => 1.25, :SdefA => 1.25, :SmatA => 1.25,
                                  :SmdfA => 1.25, :SagiA => 1.25, :SlukA => 1.25},
            
            #ATK/DEF/INT/MDF/AGI/LUK/HP/MP+
            275 => { :nameP => "Wyrm's ", :nameS => " of the Wyrm", 
                                  :SatkA => 0.25, :SdefA => 0.25, :SmatA => 0.25,
                                  :SmdfA => 0.25, :SagiA => 0.25, :SlukA => 0.25,
                                  :ShpA => 0.5,   :SmpA => 0.5},
            276 => { :nameP => "Hatchling ", :nameS => " of the Hatchling", 
                                  :SatkA => 0.5,  :SdefA => 0.5,  :SmatA => 0.5,
                                  :SmdfA => 0.5,  :SagiA => 0.5,  :SlukA => 0.5,
                                  :ShpA => 1,     :SmpA => 1},
            277 => { :nameP => "Chromatic ", :nameS => " of the Chromatic", 
                                  :SatkA => 0.75, :SdefA => 0.75, :SmatA => 0.75,
                                  :SmdfA => 0.75, :SagiA => 0.75, :SlukA => 0.75,
                                  :ShpA => 1.5,   :SmpA => 1.5},
            278 => { :nameP => "Dragon ", :nameS => " of the Dragon", 
                                  :SatkA => 1,    :SdefA => 1,    :SmatA => 1,
                                  :SmdfA => 1,    :SagiA => 1,    :SlukA => 1,
                                  :ShpA => 2,     :SmpA => 2},
            279 => { :nameP => "Prismatic ", :nameS => " of the Prismatic", 
                                  :SatkA => 1.25, :SdefA => 1.25, :SmatA => 1.25,
                                  :SmdfA => 1.25, :SagiA => 1.25, :SlukA => 1.25,
                                  :ShpA => 2.5,   :SmpA => 2.5},
            
            #STATE APPLIES
              #Poison
            280 => { :nameP => "Poisoned ", :nameS => " of Poison", 
                      :SatkP  => 3, :SmatP => 3,
                     :features => [[32,2,0.10]]},
            281 => { :nameP => "Venom ", :nameS => " of Venom", 
                      :SatkP  => 4, :SmatP => 4,
                     :features => [[32,2,0.25]]},
            282 => { :nameP => "Toxic ", :nameS => " of Toxins", 
                      :SatkP  => 5, :SmatP => 5,
                     :features => [[32,2,0.5]]},
                     
              #Blind
            283 => { :nameP => "Gouging ", :nameS => " of Gouging", 
                      :SatkP  => 3, :SmatP => 3,
                     :features => [[32,3,0.10]]},
            284 => { :nameP => "Blind ", :nameS => " of Blindness", 
                      :SatkP  => 4, :SmatP => 4,
                     :features => [[32,3,0.25]]},
            285 => { :nameP => "Sightless ", :nameS => " of the Sightless", 
                      :SatkP  => 5, :SmatP => 5,
                     :features => [[32,3,0.5]]},
            
              #Silence
            286 => { :nameP => "Quiet ", :nameS => " of Quietness", 
                      :SatkP  => 3, :SmatP => 3,
                     :features => [[32,4,0.10]]},
            287 => { :nameP => "Silent ", :nameS => " of Silence", 
                      :SatkP  => 4, :SmatP => 4,
                     :features => [[32,4,0.25]]},
            288 => { :nameP => "Mute ", :nameS => " of the Mute", 
                      :SatkP  => 5, :SmatP => 5,
                     :features => [[32,4,0.5]]},
                  
              #Confusion
            289 => { :nameP => "Confused ", :nameS => " of Confusion", 
                      :SatkP  => 3, :SmatP => 3,
                     :features => [[32,5,0.10]]},
            290 => { :nameP => "Disoriented ", :nameS => " of Disorientation", 
                      :SatkP  => 4, :SmatP => 4,
                     :features => [[32,5,0.25]]},
            291 => { :nameP => "Baffled ", :nameS => " of Baffling", 
                      :SatkP  => 5, :SmatP => 5,
                     :features => [[32,5,0.5]]},
                     
              #Sleep
            292 => { :nameP => "Sleepy ", :nameS => " of Sleep", 
                      :SatkP  => 3, :SmatP => 3,
                     :features => [[32,6,0.10]]},
            293 => { :nameP => "Tired ", :nameS => " of the Tired", 
                      :SatkP  => 4, :SmatP => 4,
                     :features => [[32,6,0.25]]},
            294 => { :nameP => "Resting ", :nameS => " of the Resting", 
                      :SatkP  => 5, :SmatP => 5,
                     :features => [[32,6,0.5]]},
                     
              #Paralysis
            295 => { :nameP => "Paralyzing ", :nameS => " of Paralysis", 
                      :SatkP  => 3, :SmatP => 3,
                     :features => [[32,7,0.10]]},
            296 => { :nameP => "Disabling ", :nameS => " of Disabling", 
                      :SatkP  => 4, :SmatP => 4,
                     :features => [[32,7,0.25]]},
            297 => { :nameP => "Halting ", :nameS => " of Halting", 
                      :SatkP  => 5, :SmatP => 5,
                     :features => [[32,7,0.5]]},
            
              #Stun
            298 => { :nameP => "Stunning ", :nameS => " of Stunning", 
                      :SatkP  => 3, :SmatP => 3,
                     :features => [[32,8,0.10]]},
            299 => { :nameP => "Stopping ", :nameS => " of Stopping", 
                      :SatkP  => 4, :SmatP => 4,
                     :features => [[32,8,0.25]]},
            300 => { :nameP => "Overwhelming ", :nameS => " of Overwhelming", 
                      :SatkP  => 5, :SmatP => 5,
                     :features => [[32,8,0.5]]},
                     
              #Death
            301 => { :nameP => "Deadly ", :nameS => " of Death", 
                      :SatkP  => 3, :SmatP => 3,
                     :features => [[32,1,0.05]]},
            302 => { :nameP => "Doom Touched ", :nameS => " of Doom", 
                      :SatkP  => 4, :SmatP => 4,
                     :features => [[32,1,0.10]]},
            303 => { :nameP => "Reaper's ", :nameS => " of the Reaper", 
                      :SatkP  => 5, :SmatP => 5,
                     :features => [[32,1,0.15]]},
            
            #STATE RESISTS
              #Poison
            304 => { :nameP => "Antidotal ", :nameS => " of Antidotes", 
                      :SdefP => 3, :SmdfP => 3, :features => [[13,2,0.5]]},
            305 => { :nameP => "Antivenom ", :nameS => " of Antivenom", 
                      :SdefP => 5, :SmdfP => 5, :features => [[14,2,0]] },
                     
              #Blind
            306 => { :nameP => "Vision ", :nameS => " of Visions", 
                      :SdefP => 3, :SmdfP => 3, :features => [[13,3,0.5]]},
            307 => { :nameP => "Sight ", :nameS => " of Sight", 
                      :SdefP => 5, :SmdfP => 5, :features => [[14,3,0]] },
            
              #Silence
            308 => { :nameP => "Loud ", :nameS => " of the Loud", 
                      :SdefP => 3, :SmdfP => 3, :features => [[13,4,0.5]]},
            309 => { :nameP => "Ruckus ", :nameS => " of Ruckus", 
                      :SdefP => 5, :SmdfP => 5, :features => [[14,4,0]] },
                  
              #Confusion
            310 => { :nameP => "Clarity ", :nameS => " of Clarity", 
                      :SdefP => 3, :SmdfP => 3, :features => [[13,5,0.5]]},
            311 => { :nameP => "Lucidity ", :nameS => " of the Lucid", 
                      :SdefP => 5, :SmdfP => 5, :features => [[14,5,0]] },
                     
              #Sleep
            312 => { :nameP => "Awakening ", :nameS => " of Awakening", 
                      :SdefP => 3, :SmdfP => 3, :features => [[13,6,0.5]]},
            313 => { :nameP => "Insomnia ", :nameS => " of Insomnia", 
                      :SdefP => 5, :SmdfP => 5, :features => [[14,6,0]] },
                     
              #Paralysis
            314 => { :nameP => "Antiparalysis ", :nameS => " of Antiparalysis", 
                      :SdefP => 3, :SmdfP => 3, :features => [[13,7,0.5]]},
            315 => { :nameP => "Limber ", :nameS => " of the Limber", 
                      :SdefP => 5, :SmdfP => 5, :features => [[14,7,0]] },
            
              #Stun
            316 => { :nameP => "Bold ", :nameS => " of the Bold", 
                      :SdefP => 3, :SmdfP => 3, :features => [[13,8,0.5]]},
            317 => { :nameP => "Stunless ", :nameS => " of the Stunless", 
                      :SdefP => 5, :SmdfP => 5, :features => [[14,8,0]] },
                     
              #Death
            318 => { :nameP => "Inner Fire ", :nameS => " of Inner Fire", 
                      :SdefP => 3, :SmdfP => 3, :features => [[13,1,0.5]]},
            319 => { :nameP => "Life ", :nameS => " of Life", 
                      :SdefP => 5, :SmdfP => 5, :features => [[13,1,1]] },
            
            #ELEMENT APPLIES
              #Fire
            320 => { :nameP => "Fiery ", :nameS => " of Fire", 
                      :SmatP => 3, :SatkP => 3, :features => [[31,3,0]]},
            321 => { :nameP => "Flaming ", :nameS => " of Flames", 
                      :SmatP => 5, :SatkP => 3, :features => [[31,3,0]]},
            322 => { :nameP => "Hellfire ", :nameS => " of Hellfire", 
                      :SmatP => 7, :SatkP => 7, :features => [[31,3,0]]},
                     
              #Ice
            323 => { :nameP => "Icy ", :nameS => " of Icicles", 
                      :SmatP => 3, :SatkP => 3, :features => [[31,4,0]]},
            324 => { :nameP => "Frost ", :nameS => " of Frost", 
                      :SmatP => 5, :SatkP => 5, :features => [[31,4,0]]},
            325 => { :nameP => "Blizzard ", :nameS => " of Blizzards", 
                      :SmatP => 7, :SatkP => 7, :features => [[31,4,0]]},
                     
              #Thunder
            326 => { :nameP => "Jolt ", :nameS => " of Jolts", 
                      :SmatP => 3, :SatkP => 3, :features => [[31,5,0]]},
            327 => { :nameP => "Shocking ", :nameS => " of Shocks", 
                      :SmatP => 5, :SatkP => 5, :features => [[31,5,0]]},
            328 => { :nameP => "Thunderous ", :nameS => " of Thunder", 
                      :SmatP => 7, :SatkP => 7, :features => [[31,5,0]]},
                    
              #Water
            329 => { :nameP => "Moist ", :nameS => " of Moisture", 
                      :SmatP => 3, :SatkP => 3, :features => [[31,6,0]]},
            330 => { :nameP => "Monsoon ", :nameS => " of Monsoons", 
                      :SmatP => 5, :SatkP => 5, :features => [[31,6,0]]},
            331 => { :nameP => "Hurricane ", :nameS => " of Hurricanes", 
                      :SmatP => 7, :SatkP => 7, :features => [[31,6,0]]},
                     
              #Earth
            332 => { :nameP => "Rocky ", :nameS => " of Rocks", 
                      :SmatP => 3, :SatkP => 3, :features => [[31,7,0]]},
            333 => { :nameP => "Craggy ", :nameS => " of Crags",
                      :SmatP => 5, :SatkP => 5, :features => [[31,7,0]]},
            334 => { :nameP => "Quakes ", :nameS => " of Earthquakes", 
                      :SmatP => 7, :SatkP => 7, :features => [[31,7,0]]},
                     
              #Wind
            335 => { :nameP => "Gusting ", :nameS => " of Gusts", 
                      :SmatP => 3, :SatkP => 3, :features => [[31,8,0]]},
            336 => { :nameP => "Windy ", :nameS => " of Winds", 
                      :SmatP => 5, :SatkP => 5, :features => [[31,8,0]]},
            337 => { :nameP => "Tornado ", :nameS => " of Tornadoes", 
                      :SmatP => 7, :SatkP => 7, :features => [[31,8,0]]},
                     
              #Holy
            338 => { :nameP => "Shining ", :nameS => " of Light", 
                      :SmatP => 3, :SatkP => 3, :features => [[31,9,0]]},
            339 => { :nameP => "Holy ", :nameS => " of the Holy", 
                      :SmatP => 5, :SatkP => 5, :features => [[31,9,0]]},
            340 => { :nameP => "Angel's ", :nameS => " of Angels", 
                      :SmatP => 7, :SatkP => 7, :features => [[31,9,0]]},
                     
              #Dark
            341 => { :nameP => "Dark ", :nameS => " of Darkness", 
                      :SmatP => 3, :SatkP => 3, :features => [[31,10,0]]},
            342 => { :nameP => "Devil's ", :nameS => " of the Devil", 
                      :SmatP => 5, :SatkP => 5, :features => [[31,10,0]]},
            343 => { :nameP => "Void ", :nameS => " of the Void", 
                      :SmatP => 7, :SatkP => 7, :features => [[31,10,0]]},
            
            #ELEMENT RESISTS
              #Physical
            344 => { :nameP => "Resistant ", :nameS => " of Resistance", 
                      :SdefP => 3, :SmdfP => 3, :features => [[11,1,0.80]]},
            345 => { :nameP => "Protected ", :nameS => " of Protection", 
                      :SdefP => 5, :SmdfP => 5, :features => [[11,1,0.65]]},
            346 => { :nameP => "Safeguard ", :nameS => " of Safeguards", 
                      :SdefP => 7, :SmdfP => 7, :features => [[11,1,0.5]]},
                     
              #Fire
            347 => { :nameP => "Fireproof ", :nameS => " of Fireproofing", 
              :SdefP => 3, :SmdfP => 3, :features => [[11,3,0.66],[11,6,1.33]]},
            348 => { :nameP => "Heat Shield ", :nameS => " of Flame Resist", 
              :SdefP => 5, :SmdfP => 5, :features => [[11,3,0.33],[11,6,1.66]]},
            349 => { :nameP => "Smoldering ", :nameS => " of Smolders", 
              :SdefP => 7, :SmdfP => 7, :features => [[11,3,0],[11,6,2]]},
                     
              #Ice
            350 => { :nameP => "Warm ", :nameS => " of Warming", 
              :SdefP => 3, :SmdfP => 3, :features => [[11,4,0.66],[11,3,1.33]]},
            351 => { :nameP => "Frost Shield ", :nameS => " of Frost Resist", 
              :SdefP => 5, :SmdfP => 5, :features => [[11,4,0.33],[11,3,1.66]]},
            352 => { :nameP => "Chilling ", :nameS => " of Chills", 
              :SdefP => 7, :SmdfP => 7, :features => [[11,4,0],[11,3,2]]},
                    
              #Thunder
            353 => { :nameP => "Rubber ", :nameS => " of Rubber", 
              :SdefP => 3, :SmdfP => 3, :features => [[11,5,0.66],[11,7,1.33]]},
            354 => { :nameP => "Thunder Shield ", :nameS => " of Thunder Resist", 
              :SdefP => 5, :SmdfP => 5, :features => [[11,5,0.33],[11,7,1.66]]},
            355 => { :nameP => "Electric ", :nameS => " of Electricity", 
              :SdefP => 7, :SmdfP => 7, :features => [[11,5,0],[11,7,2]]},
                     
              #Water
            356 => { :nameP => "Waterproof ", :nameS => " of Waterproofing", 
              :SdefP => 3, :SmdfP => 3, :features => [[11,6,0.66],[11,5,1.33]]},
            357 => { :nameP => "Water Shield ", :nameS => " of Water Resist", 
              :SdefP => 5, :SmdfP => 5, :features => [[11,6,0.33],[11,5,1.66]]},
            358 => { :nameP => "Bubble ", :nameS => " of Bubbles", 
              :SdefP => 7, :SmdfP => 7, :features => [[11,6,0],[11,5,2]]},
                     
              #Earth
            359 => { :nameP => "Earthen ", :nameS => " of Earth", 
              :SdefP => 3, :SmdfP => 3, :features => [[11,7,0.66],[11,8,1.33]]},
            360 => { :nameP => "Rock Shield ", :nameS => " of Earth Resist", 
              :SdefP => 5, :SmdfP => 5, :features => [[11,7,0.33],[11,8,1.66]]},
            361 => { :nameP => "Barkskin ", :nameS => " of Barkskin", 
              :SdefP => 7, :SmdfP => 7, :features => [[11,7,0],[11,8,2]]},
                    
              #Wind
            362 => { :nameP => "Airproof ", :nameS => " of Airproofing", 
              :SdefP => 3, :SmdfP => 3, :features => [[11,8,0.66],[11,4,1.33]]},
            363 => { :nameP => "Wind Shield ", :nameS => " of Wind Resist", 
              :SdefP => 5, :SmdfP => 5, :features => [[11,8,0.33],[11,4,1.66]]},
            364 => { :nameP => "Stormy ", :nameS => " of Storms", 
              :SdefP => 7, :SmdfP => 7, :features => [[11,8,0],[11,4,2]]},
                     
              #Holy
            365 => { :nameP => "Aura ", :nameS => " of Auras", 
              :SdefP => 3, :SmdfP => 3, :features => [[11,9,0.66],[11,10,1.33]]},
            366 => { :nameP => "Holy Shield ", :nameS => " of Holy Resist", 
              :SdefP => 5, :SmdfP => 5, :features => [[11,9,0.33],[11,10,1.66]]},
            367 => { :nameP => "Light ", :nameS => " of Holy Light", 
              :SdefP => 7, :SmdfP => 7, :features => [[11,9,0],[11,10,2]]},
                     
              #Dark
            368 => { :nameP => "Cursed ", :nameS => " of Curses", 
              :SdefP => 3, :SmdfP => 3, :features => [[11,10,0.66],[11,9,1.33]]},
            369 => { :nameP => "Dark Shield ", :nameS => " of Dark Resist", 
              :SdefP => 5, :SmdfP => 5, :features => [[11,10,0.33],[11,9,1.66]]},
            370 => { :nameP => "Evil ", :nameS => " of the Evil", 
              :SdefP => 7, :SmdfP => 7, :features => [[11,10,0],[11,9,2]]},
            
            #EXTRA PARAMETERS
              #Hit Rate
            371 => { :nameP => "Bullseye ", :nameS => " of Bullseye's", 
                                  :SatkP => 2, :SdefP => 2, :SmatP => 2,
                                  :SmdfP => 2, :SagiP => 2, :SlukP => 2,
                                  :ShpP => 2,  :SmpP => 2,
                                  :features => [[22,0,5]] },
            372 => { :nameP => "Eagle Eye", :nameS => " of the Eagle", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[22,0,10]] },
            373 => { :nameP => "Accurate ", :nameS => " of Accuracy", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[22,0,15]] },
                                  
              #Evasion Rate
            374 => { :nameP => "Slippery ", :nameS => " of Slipperyness", 
                                  :SatkP => 2, :SdefP => 2, :SmatP => 2,
                                  :SmdfP => 2, :SagiP => 2, :SlukP => 2,
                                  :ShpP => 2,  :SmpP => 2,
                                  :features => [[22,1,4]] },
            375 => { :nameP => "Evading ", :nameS => " of Evasion", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[22,1,7]] },
            376 => { :nameP => "Shadow ", :nameS => " of Shadow's", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[22,1,10]] },
                                  
              #Critical Rate
            377 => { :nameP => "Critical ", :nameS => " of Criticals", 
                                  :SatkP => 2, :SdefP => 2, :SmatP => 2,
                                  :SmdfP => 2, :SagiP => 2, :SlukP => 2,
                                  :ShpP => 2,  :SmpP => 2,
                                  :features => [[22,2,5]] },
            378 => { :nameP => "Precise ", :nameS => " of Precision", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[22,2,10]] },
            379 => { :nameP => "Skillful ", :nameS => " of Skill", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[22,2,15]] },
                                
              #Critical Evasion Rate
            380 => { :nameP => "Unmoveable ", :nameS => " of Unmoving", 
                                  :SatkP => 2, :SdefP => 2, :SmatP => 2,
                                  :SmdfP => 2, :SagiP => 2, :SlukP => 2,
                                  :ShpP => 2,  :SmpP => 2,
                                  :features => [[22,3,5]] },
            381 => { :nameP => "Stiff ", :nameS => " of Stiffness", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[22,3,10]] },
            382 => { :nameP => "Stout ", :nameS => " of Stoutness", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[22,3,15]] },
                                  
              #Magic Evasion Rate
            383 => { :nameP => "Phased ", :nameS => " of Phasing", 
                                  :SatkP => 2, :SdefP => 2, :SmatP => 2,
                                  :SmdfP => 2, :SagiP => 2, :SlukP => 2,
                                  :ShpP => 2,  :SmpP => 2,
                                  :features => [[22,4,4]] },
            384 => { :nameP => "Phantom ", :nameS => " of Phantoms", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[22,4,7]] },
            385 => { :nameP => "Ethereal ", :nameS => " of the Ethereal", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[22,4,10]] },
                                  
              #Magic Reflection Rate
            386 => { :nameP => "Reflecting ", :nameS => " of Reflection", 
                                  :SatkP => 2, :SdefP => 2, :SmatP => 2,
                                  :SmdfP => 2, :SagiP => 2, :SlukP => 2,
                                  :ShpP => 2,  :SmpP => 2,
                                  :features => [[22,5,25]] },
            387 => { :nameP => "Mirrored ", :nameS => " of Mirrors", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[22,5,50]] },
            388 => { :nameP => "Echoed ", :nameS => " of Echos", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[22,5,100]] },
                                  
              #Counter Attack Rate
            389 => { :nameP => "Counter ", :nameS => " of Counters", 
                                  :SatkP => 2, :SdefP => 2, :SmatP => 2,
                                  :SmdfP => 2, :SagiP => 2, :SlukP => 2,
                                  :ShpP => 2,  :SmpP => 2,
                                  :features => [[22,6,25]] },
            390 => { :nameP => "Reversing ", :nameS => " of Reversal", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[22,6,50]] },
            391 => { :nameP => "Ricocheting ", :nameS => " of Ricochet", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[22,6,75]] },
                                  
              #Hp Regen Rate
            392 => { :nameP => "Regen ", :nameS => " of Regeneration", 
                                  :SatkP => 2, :SdefP => 2, :SmatP => 2,
                                  :SmdfP => 2, :SagiP => 2, :SlukP => 2,
                                  :ShpP => 2,  :SmpP => 2,
                                  :features => [[22,7,1]] },
            393 => { :nameP => "Replenishing ", :nameS => " of Replenishment", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[22,7,3]] },
            394 => { :nameP => "Restoring ", :nameS => " of Restoration", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[22,7,5]] },
                                  
              #Mp Regen Rate
            395 => { :nameP => "Fufilling ", :nameS => " of Fufillment", 
                                  :SatkP => 2, :SdefP => 2, :SmatP => 2,
                                  :SmdfP => 2, :SagiP => 2, :SlukP => 2,
                                  :ShpP => 2,  :SmpP => 2,
                                  :features => [[22,8,1]] },
            396 => { :nameP => "Refreshing ", :nameS => " of Refreshment", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[22,8,3]] },
            397 => { :nameP => "Renewal ", :nameS => " of Renewing", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[22,8,5]] },
                                  
              #Tp Regen Rate
            398 => { :nameP => "Charging ", :nameS => " of Ability Charge", 
                                  :SatkP => 2, :SdefP => 2, :SmatP => 2,
                                  :SmdfP => 2, :SagiP => 2, :SlukP => 2,
                                  :ShpP => 2,  :SmpP => 2,
                                  :features => [[22,9,1]] },
            399 => { :nameP => "Default ", :nameS => " of Defaulting", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[22,9,3]] },
            400 => { :nameP => "Breather's ", :nameS => " of Breathing", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[22,9,5]] },
            
            #SPECIAL PARAMETERS
              #Target Rate
            401 => { :nameP => "Taunting ", :nameS => " of Taunting", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[23,0,200]] },
            402 => { :nameP => "Cloaking ", :nameS => " of Cloaking", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[23,0,10]] },
                                  
              #Guard Effect Rate
            403 => { :nameP => "Guarding ", :nameS => " of the Guarded", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[23,1,125]] },
            404 => { :nameP => "Secured ", :nameS => " of Securing", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[23,1,150]] },
                                  
              #Recovery Effect Rate
            405 => { :nameP => "Mending ", :nameS => " of Mending", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[23,2,125]] },
            406 => { :nameP => "Soothed ", :nameS => " of Soothing", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[23,2,150]] },
                                  
              #Pharmacology Rate
            407 => { :nameP => "Alchemist's ", :nameS => " of Alchemy", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[23,3,125]] },
            408 => { :nameP => "Pharmacology ", :nameS => " of Pharmacology", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[23,3,150]] },
                                  
              #MP Cost Rate
            409 => { :nameP => "Efficient ", :nameS => " of Efficiency", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[23,4,85]] },
            410 => { :nameP => "Energetic ", :nameS => " of the Energetic", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[23,4,70]] },
                                  
              #Tp Charge Rate
            411 => { :nameP => "Quick Charge ", :nameS => " of Quick Charge", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[23,5,115]] },
            412 => { :nameP => "Fast Charge ", :nameS => " of Fast Charge", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[23,5,130]] },
                                  
              #Physical Damage Rate
            413 => { :nameP => "Melee ", :nameS => " of Melee Power", 
                      :features => [[23,6,95]] },
            414 => { :nameP => "Clash ", :nameS => " of Clashing", 
                      :features => [[23,6,90]] },
            415 => { :nameP => "Behemoth's ", :nameS => " of the Behemoth", 
                      :features => [[23,6,85]] },
                                  
              #Magical Damage Rate
            416 => { :nameP => "Occult ", :nameS => " of the Occult", 
                      :features => [[23,7,95]] },
            417 => { :nameP => "Wisp Dust ", :nameS => " of the Wisp", 
                      :features => [[23,7,90]] },
            418 => { :nameP => "Faetouched ", :nameS => " of the Fae", 
                      :features => [[23,7,85]] },
                                  
              #Experience Rate
            419 => { :nameP => "Trainer's ", :nameS => " of Training", 
                                  :SatkP => 2, :SdefP => 2, :SmatP => 2,
                                  :SmdfP => 2, :SagiP => 2, :SlukP => 2,
                                  :ShpP => 2,  :SmpP => 2,
                                  :features => [[23,9,105]] },
            420 => { :nameP => "Experienced ", :nameS => " of Experience", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[23,9,110]] },
            421 => { :nameP => "Studied ", :nameS => " of Studying", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[23,9,120]] },
            
            #MISCELANEOUS
              #Attack Speed
            422 => { :nameP => "Quick ", :nameS => " of the Quick", 
                                  :SatkP => 2, :SdefP => 2, :SmatP => 2,
                                  :SmdfP => 2, :SagiP => 2, :SlukP => 2,
                                  :ShpP => 2,  :SmpP => 2,
                                  :features => [[33,0,75]] },
            423 => { :nameP => "Greased ", :nameS => " of Grease", 
                                  :SatkP => 4, :SdefP => 4, :SmatP => 4,
                                  :SmdfP => 4, :SagiP => 4, :SlukP => 4,
                                  :ShpP => 4,  :SmpP => 4,
                                  :features => [[33,0,150]] },
                           
              #Attack Times
            424 => { :nameP => "Rapid ", :nameS => " of Rapidness", 
                                  :SatkP => 6, :SdefP => 6, :SmatP => 6,
                                  :SmdfP => 6, :SagiP => 6, :SlukP => 6,
                                  :ShpP => 6,  :SmpP => 6,
                                  :features => [[34,0,1]] },
                
              #Encounter Half
            425 => { :nameP => "Hiding ", :nameS => " of Hiding", 
                                  :SatkP => 3, :SdefP => 3, :SmatP => 3,
                                  :SmdfP => 3, :SagiP => 3, :SlukP => 3,
                                  :ShpP => 3,  :SmpP => 3,
                                  :features => [[63,0,0]] },
              #Encounter None
            426 => { :nameP => "Sneaky ", :nameS => " of Sneaking", 
                                  :SatkP => 3, :SdefP => 3, :SmatP => 3,
                                  :SmdfP => 3, :SagiP => 3, :SlukP => 3,
                                  :ShpP => 3,  :SmpP => 3,
                                  :features => [[63,1,0]] },
              #Cancel Surprise
            427 => { :nameP => "Perceptive ", :nameS => " of Perception", 
                                  :SatkP => 3, :SdefP => 3, :SmatP => 3,
                                  :SmdfP => 3, :SagiP => 3, :SlukP => 3,
                                  :ShpP => 3,  :SmpP => 3,
                                  :features => [[63,2,0]] },
              #Raise Preemptive
            428 => { :nameP => "Preemptive ", :nameS => " of the Preemptive", 
                                  :SatkP => 3, :SdefP => 3, :SmatP => 3,
                                  :SmdfP => 3, :SagiP => 3, :SlukP => 3,
                                  :ShpP => 3,  :SmpP => 3,
                                  :features => [[63,3,0]] },
              #Double Gold
            429 => { :nameP => "Treasured ", :nameS => " of Treasures", 
                                  :SatkP => 3, :SdefP => 3, :SmatP => 3,
                                  :SmdfP => 3, :SagiP => 3, :SlukP => 3,
                                  :ShpP => 3,  :SmpP => 3,
                                  :features => [[63,4,0]] },
                                  
              #Price
            430 => { :nameP => "Wealthy ", :nameS => " of the Wealthy", 
                                  :SatkP => 3, :SdefP => 3, :SmatP => 3,
                                  :SmdfP => 3, :SagiP => 3, :SlukP => 3,
                                  :ShpP => 3,  :SmpP => 3,
                                  :SpriceP => 25 },
            431 => { :nameP => "Golden ", :nameS => " of Gold", 
                                  :SatkP => 3, :SdefP => 3, :SmatP => 3,
                                  :SmdfP => 3, :SagiP => 3, :SlukP => 3,
                                  :ShpP => 3,  :SmpP => 3,
                                  :SpriceP => 50 },
            432 => { :nameP => "Valuable ", :nameS => " of Value", 
                                  :SatkP => 3, :SdefP => 3, :SmatP => 3,
                                  :SmdfP => 3, :SagiP => 3, :SlukP => 3,
                                  :ShpP => 3,  :SmpP => 3,
                                  :SpriceP => 100 },
            
            }
           
#If true, then weapons and armors dropped by enemies will be randomized
RANDOM_ENEMY_DROPS = true
#Pool Rarity (Instead of a first come first serve, each affix is given a chance)
POOL_RARITY = false
#If true, weapons and armors bought from shops will be randomized
WA_SHOP_RANDOM = false
#True if you are using Sleek Item Popup, and want those to popup!
USE_ITEM_POPUP = false
#Stack random weapons and armor, when false all equips are unique
STACK_SAME_EQUIP = false
USE_RARITY = true
PREFIX_RARITY = [0]*16 + [1]*8 + [2]*4 + [3]*2 + [4]
SUFFIX_RARITY = [5]*8 + [6]*4 + [7]*2 + [8]
UNINCLUDED_AFFIXES = [0,1,2,3,4,5,6,7,8]
 
class Window_ItemList
  def col_max; 1; end
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, enable?(item),item_width)
      draw_item_number(rect, item)
    end
  end
end

class Game_Interpreter
  def add_weapon(id, am)
    item = $game_party.add_weapon(id,am)
    popup(1,item.id,am) if USE_ITEM_POPUP
    item
  end
  def add_armor(id, am)
    item = $game_party.add_armor(id, am)
    popup(2,item.id,am) if USE_ITEM_POPUP
    item
  end
  def add_item(id, am)
    item = $game_party.add_item(id, am)
    popup(0,item.id,am) if USE_ITEM_POPUP
    item
  end
  def edit_affixes(item, subnote = nil)
    $game_party.edit_affixes(item, subnote)
  end
end
 
class Game_Party
  alias rig_initialize initialize
  def initialize
    rig_initialize
    @saved_weapons = $data_weapons
    @saved_armors = $data_armors
  end
  attr_accessor :saved_weapons
  attr_accessor :saved_armors
  def add_weapon(id, amount)
    item = Marshal.load(Marshal.dump($data_weapons[id]))
    edit_item(item)
    edit_affixes(item)
    if STACK_SAME_EQUIP
      $data_weapons.each do |base_item|
        next if base_item.nil?
        if ( item.params == base_item.params &&
            item.price == base_item.price &&
            item.name == base_item.name &&
            item.color == base_item.color)
          $game_party.gain_item(base_item, amount)
          return base_item
        end
      end
    end
    item.note = $data_weapons[item.id].note
    item.id = $data_weapons.size
    $data_weapons.push(item)
    $game_party.gain_item(item, amount)
    return item
  end
  def add_armor(id, amount)
    item = Marshal.load(Marshal.dump($data_armors[id]))
    edit_item(item)
    edit_affixes(item)
    if STACK_SAME_EQUIP
      $data_armors.each do |base_item|
        next if base_item.nil?
        if ( item.params == base_item.params &&
            item.price == base_item.price &&
            item.name == base_item.name &&
            item.color == base_item.color)
          $game_party.gain_item(base_item, amount)
          return base_item
        end
      end
    end
    item.note = $data_armors[item.id].note
    item.id = $data_armors.size
    $data_armors.push(item)
    $game_party.gain_item(item, amount)
    return item
  end
  def add_item(id, amount)
    item = Marshal.load(Marshal.dump($data_items[id]))
    edit_item(item)
    edit_affixes(item)
    $data_items.each do |base_item|
      next if base_item.nil?
      if (item.price == base_item.price &&
          item.name == base_item.name )
        $game_party.gain_item(base_item, amount)
        return base_item
      end
    end
    item.note = $data_items[item.id].note
    item.id = $data_items.size
    $data_items.push(item)
    $game_party.gain_item(item, amount)
    return item
  end
  def edit_affixes(item, subnote = nil)
    note = item.note.clone
    note = subnote.clone if subnote
    affix_pool = []
    while note.include?("<SUF")
      id = note =~ /<SUFFIX(\d+) (\d+)>/
      if !POOL_RARITY
        if !AFFIXES[$~[1].to_i].nil?
          break if add_affix(item, $~[1].to_i, false) if rand(100) < $2.to_i
          note[id] = "N"
        else
          msgbox("Affix #" + $1 + " doesn't exist. \nItem creation failed.")
          return
        end
      else
        if !AFFIXES[$~[1].to_i].nil?
          $2.to_i.times do
            affix_pool.push($1)
          end
          note[id] = "N"
        else
          msgbox("Affix #" + $1 + " doesn't exist. \nItem creation failed.")
          return
        end
      end
    end
    if !affix_pool.empty?
      add_affix(item, affix_pool[rand(affix_pool.size)], false) if POOL_RARITY
    end
    affix_pool = []
    while note.include?("<PRE")
      id = note =~ /<PREFIX(\d+) (\d+)>/
      if !POOL_RARITY
        if !AFFIXES[$~[1].to_i].nil?
          break if add_affix(item, $~[1].to_i, true) if rand(100) < $2.to_i
          note[id] = "N"
        else
          msgbox("Affix #" + $1 + " doesn't exist. \nItem creation failed.")
          return
        end
      else
        if !AFFIXES[$~[1].to_i].nil?
          $2.to_i.times do
            affix_pool.push($1)
          end
          note[id] = "N"
        else
          msgbox("Affix #" + $1 + " doesn't exist. \nItem creation failed.")
          return
        end
      end
    end
    if note.include?("<ALLPREFIX>")
      affix_added = false
      while !affix_added
        affix_id = AFFIXES.keys[rand(AFFIXES.keys[-1])]
        if !affix_id.nil? and !UNINCLUDED_AFFIXES.include?(affix_id)
          add_affix(item, affix_id, true)
          affix_added = true
        end
      end
    end
    if note.include?("<ALLSUFFIX>")
      affix_added = false
      while !affix_added
        affix_id = AFFIXES.keys[rand(AFFIXES.keys[-1])]
        if !affix_id.nil? and !UNINCLUDED_AFFIXES.include?(affix_id)
          add_affix(item, affix_id, false)
          affix_added = true
        end
      end
    end
    if !affix_pool.empty?
      add_affix(item, affix_pool[rand(affix_pool.size)], true) if POOL_RARITY
    end
    if USE_RARITY
      if !PREFIX_RARITY.empty?
        add_affix(item, PREFIX_RARITY[rand(PREFIX_RARITY.size)], true)
      end
      if !SUFFIX_RARITY.empty?
        add_affix(item, SUFFIX_RARITY[rand(SUFFIX_RARITY.size)], false)
      end
    end
  end
  def add_affix(item, id, prefix)
    affix = AFFIXES[id.to_i]
    if prefix 
      if affix[:nameP].nil? && !affix[:name].nil?
        item.name = affix[:name] + item.name
      elsif !affix[:nameP].nil?
        item.name = affix[:nameP] + item.name
      end
    elsif 
      if affix[:nameS].nil? && !affix[:name].nil?
        item.name = item.name + affix[:name] 
      elsif !affix[:nameS].nil?
        item.name = item.name + affix[:nameS]
      end
    end
    if !affix[:rarity].nil?
      if item.rarity.nil? || item.rarity > affix[:rarity]
        item.set_color(affix[:color]) if !affix[:color].nil?
        item.rarity = affix[:rarity]
      end
    else
      item.set_color(affix[:color]) if !affix[:color].nil?
    end
   
    if !affix[:desc].nil?
      item.description = affix[:desc]
    end
   
    if !item.is_a?(RPG::Armor) && !affix[:animation].nil?
      item.animation_id = affix[:animation]
    end
   
    item.icon_index = affix[:icon] if !affix[:icon].nil?
   
    if !item.is_a?(RPG::Item)
      item.params[0] += rand(affix[:hp]) if !affix[:hp].nil?
      item.params[1] += rand(affix[:mp]) if !affix[:mp].nil?
      item.params[2] += rand(affix[:atk]) if !affix[:atk].nil?
      item.params[3] += rand(affix[:def]) if !affix[:def].nil?
      item.params[4] += rand(affix[:mat]) if !affix[:mat].nil?
      item.params[5] += rand(affix[:mdf]) if !affix[:mdf].nil?
      item.params[6] += rand(affix[:agi]) if !affix[:agi].nil?
      item.params[7] += rand(affix[:luk]) if !affix[:luk].nil?
    end
    item.price += rand(affix[:price]) if !affix[:price].nil?
   
    if !item.is_a?(RPG::Item)
      item.params[0] += affix[:Shp] if !affix[:Shp].nil?
      item.params[1] += affix[:Smp] if !affix[:Smp].nil?
      item.params[2] += affix[:Satk] if !affix[:Satk].nil?
      item.params[3] += affix[:Sdef] if !affix[:Sdef].nil?
      item.params[4] += affix[:Smat] if !affix[:Smat].nil?
      item.params[5] += affix[:Smdf] if !affix[:Smdf].nil?
      item.params[6] += affix[:Sagi] if !affix[:Sagi].nil?
      item.params[7] += affix[:Sluk] if !affix[:Sluk].nil?
    end
    item.price += affix[:Sprice] if !affix[:Sprice].nil?
   
    if !item.is_a?(RPG::Item)
      item.params[0] += item.params[0] * (rand(affix[:hpP])) / 100 if !affix[:hpP].nil?
      item.params[1] += item.params[1] * (rand(affix[:mpP])) / 100 if !affix[:mpP].nil?
      item.params[2] += item.params[2] * (rand(affix[:atkP])) / 100 if !affix[:atkP].nil?
      item.params[3] += item.params[3] * (rand(affix[:defP])) / 100 if !affix[:defP].nil?
      item.params[4] += item.params[4] * (rand(affix[:matP])) / 100 if !affix[:matP].nil?
      item.params[5] += item.params[5] * (rand(affix[:mdfP])) / 100 if !affix[:mdfP].nil?
      item.params[6] += item.params[6] * (rand(affix[:agiP])) / 100 if !affix[:agiP].nil?
      item.params[7] += item.params[7] * (rand(affix[:lukP])) / 100 if !affix[:lukP].nil?
    end
    item.price += item.price * (rand(affix[:priceP])) / 100 if !affix[:priceP].nil?
   
    if !item.is_a?(RPG::Item)
      item.params[0] += item.params[0] * affix[:ShpP] / 100 if !affix[:ShpP].nil?
      item.params[1] += item.params[1] * affix[:SmpP] / 100 if !affix[:SmpP].nil?
      item.params[2] += item.params[2] * affix[:SatkP] / 100 if !affix[:SatkP].nil?
      item.params[3] += item.params[3] * affix[:SdefP] / 100 if !affix[:SdefP].nil?
      item.params[4] += item.params[4] * affix[:SmatP] / 100 if !affix[:SmatP].nil?
      item.params[5] += item.params[5] * affix[:SmdfP] / 100 if !affix[:SmdfP].nil?
      item.params[6] += item.params[6] * affix[:SagiP] / 100 if !affix[:SagiP].nil?
      item.params[7] += item.params[7] * affix[:SlukP] / 100 if !affix[:SlukP].nil?
    end
    item.price += item.price * affix[:SpriceP] / 100 if !affix[:SpriceP].nil?
    
    if !item.is_a?(RPG::Item)
      item.params[0] += rand(item.avg_params * affix[:hpA]) if !affix[:hpA].nil?
      item.params[1] += rand(item.avg_params * affix[:mpA]) if !affix[:mpA].nil?
      item.params[2] += rand(item.avg_params * affix[:atkA]) if !affix[:atkA].nil?
      item.params[3] += rand(item.avg_params * affix[:defA]) if !affix[:defA].nil?
      item.params[4] += rand(item.avg_params * affix[:matA]) if !affix[:matA].nil?
      item.params[5] += rand(item.avg_params * affix[:mdfA]) if !affix[:mdfA].nil?
      item.params[6] += rand(item.avg_params * affix[:agiA]) if !affix[:agiA].nil?
      item.params[7] += rand(item.avg_params * affix[:lukA]) if !affix[:lukA].nil?
    end
    
    if !item.is_a?(RPG::Item)
      item.params[0] += item.avg_params * affix[:ShpA] if !affix[:ShpA].nil?
      item.params[1] += item.avg_params * affix[:SmpA] if !affix[:SmpA].nil?
      item.params[2] += item.avg_params * affix[:SatkA] if !affix[:SatkA].nil?
      item.params[3] += item.avg_params * affix[:SdefA] if !affix[:SdefA].nil?
      item.params[4] += item.avg_params * affix[:SmatA] if !affix[:SmatA].nil?
      item.params[5] += item.avg_params * affix[:SmdfA] if !affix[:SmdfA].nil?
      item.params[6] += item.avg_params * affix[:SagiA] if !affix[:SagiA].nil?
      item.params[7] += item.avg_params * affix[:SlukA] if !affix[:SlukA].nil?
    end
   
    if !affix[:features].nil? && !item.is_a?(RPG::Item)
      for feature in affix[:features]
        new_feature = RPG::BaseItem::Feature.new(feature[0], feature[1], feature[2])
        item.features.push(new_feature)
      end
    end
   
    return true
  end
  def edit_item(item)
    if !item.is_a?(RPG::Item)
      item.note =~ /<HP (\d+)>/
      item.params[0] += rand($~[1].to_i) if $~
      item.note =~ /<MP (\d+)>/
      item.params[1] += rand($~[1].to_i) if $~
      item.note =~ /<ATK (\d+)>/
      item.params[2] += rand($~[1].to_i) if $~
      item.note =~ /<DEF (\d+)>/
      item.params[3] += rand($~[1].to_i) if $~
      item.note =~ /<MAT (\d+)>/
      item.params[4] += rand($~[1].to_i) if $~
      item.note =~ /<MDF (\d+)>/
      item.params[5] += rand($~[1].to_i) if $~
      item.note =~ /<AGI (\d+)>/
      item.params[6] += rand($~[1].to_i) if $~
      item.note =~ /<LUK (\d+)>/
      item.params[7] += rand($~[1].to_i) if $~
      item.note =~ /<PRICE (\d+)>/
    end
    item.price += rand($~[1].to_i) if $~
   
    if !item.is_a?(RPG::Item)
      item.note =~ /<HP% (\d+)>/
      item.params[0] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<MP% (\d+)>/
      item.params[1] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<ATK% (\d+)>/
      item.params[2] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<DEF% (\d+)>/
      item.params[3] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<MAT% (\d+)>/
      item.params[4] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<MDF% (\d+)>/
      item.params[5] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<AGI% (\d+)>/
      item.params[6] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<LUK% (\d+)>/
      item.params[7] += item.params[2] * (rand($~[1].to_i)) / 100 if $~
      item.note =~ /<PRICE% (\d+)>/
    end
    item.price += item.price * (rand($~[1].to_i)) / 100 if $~
  end
end
 
module BattleManager
  def self.gain_drop_items
    $game_troop.make_drop_items.each do |item|
      if RANDOM_ENEMY_DROPS
        if item.is_a?(RPG::Weapon)
          item = $game_party.add_weapon(item.id, 1)
        elsif item.is_a?(RPG::Armor)
          item = $game_party.add_armor(item.id, 1)
        else
          $game_party.gain_item(item, 1)
        end
      else
        $game_party.gain_item(item, 1)
      end
      $game_message.add(sprintf(Vocab::ObtainItem, item.name))
    end
    wait_for_message
  end
end
 
class Scene_Load
  alias rig_on_load_success on_load_success
  def on_load_success
    rig_on_load_success
    $data_weapons = $game_party.saved_weapons
    $data_armors = $game_party.saved_armors
  end
end
 
class Window_Base
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(item.color, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
    change_color(normal_color)
  end
end
 
class RPG::BaseItem
  attr_accessor  :rarity
  def color
    return Color.new(255,255,255) unless @color
    @color
  end
  def set_color(color)
    @color = color
  end
  def avg_params
    return 0 unless @params
    value = 0
    @params.each do |val|
      value += val
    end
    value / 8
  end
end
 
class Scene_Shop
  alias wa_do_buy do_buy
  def do_buy(number)
    if WA_SHOP_RANDOM
      number.times do |i|
        $game_party.lose_gold(buying_price)
        $game_party.add_weapon(@item.id, 1) if @item.is_a?(RPG::Weapon)
        $game_party.add_armor(@item.id, 1) if @item.is_a?(RPG::Armor)
        $game_party.gain_item(@item, 1) if @item.is_a?(RPG::Item)
      end
    else
      wa_do_buy(number)
    end
  end
end