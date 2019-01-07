=begin
================================================================================
EST - SUIKODEN RUNE
v3.1

Licenses:
Free to use in all project (except the one containing pornography)
as long as i credited (ESTRIOLE).
================================================================================
Compatibility:
put this script below these script if you're using them:
1) yanfly equip engine
2) Tsukihime Effect Manager
3) yanfly battle command list
in fact this script might compatible with lots of script as long as this put below
it. (let's hope so)

--------------------------------------------------------------------------------
Introduction
this make suikoden like equip rune scene mechanism.

--------------------------------------------------------------------------------
Feature
1) suikoden like equip rune mechanism
2) we can create runes that exclusive to certain actor
3) we can set starting runes for actor/class/subclass
4) we can set sealed rune slot for actor/class/subclass
5) by combining 3) and 4) we got fixed rune in certain slot
6) can make certain rune only able to equip in certain slot (ex: blue gate only at head slot)
7) extendable slots (for one who want to use it other than suikoden rune system)
   we can make equipping 'medal', 'artefact', etc whatever you want.
8) custom rune slot for actor/class/subclass
7) skill menu CAN be replaced with rune skill menu. it's scene skill but instead of
   choosing stype. it choose rune.
8) advanced auto rune slot unseal
--------------------------------------------------------------------------------
version history
v.1.0 - 2013.02.02 - finish the script
v.1.1 - 2013.02.03 - compatibility patches. added more feature.
v.1.2 - 2013.02.04 - add battle rune usage mechanism.
v.1.3 - 2013.02.05 - added method to recognize slot name for starting,
                     sealing, set rune, etc. (old method that use index still works too).
                     made custom rune slot each character now possible because of that.
v.1.4 - 2013.02.06 - > fix minor bugs rune window in battle.
                     > fix major bug when having more slots than visible line number. 
                     > add manual configuration for in battle rune slot window.
                     the configuration determine how many lines is the window height.
                     why creating that? yes! compatibility for custom battle engine.
                     > add manual configuration for the rune_skill list window in scene rune
                     the configuration determine which window the rune skill window will overlap.
                     the rune skill window will inherit overlapped position and size.
                     then when rune skill window shown the overlapped window will be hidden. vice versa.
                     why creating that? yes! compatibility for other equip engine script.
v.1.5 - 2013.02.06 - >forget modifying the on_actor_ok and on_actor_cancel. fixed
                     >missing @rune_slot_window.deactivate in method on_slot_ok. fixed
                     >fix other canceling issues
v.1.6 - 2013.02.07 - >can use notetags to 'write' the rune skill list window in equip rune scene.
                     useful if you don't want to add the skills via runes (just unlock the skill type).
                     the notetags will determine what the skill to drawn at the rune skill list window.
                     if no notetags it will use default method which 'read' the rune trait box for added skills.
                     >add switch to show the rune command in battle (example you don't want
                     the rune to show at first. and after certain event then the rune command shows.
                     >notetags to seal the rune (greyed). can be used in actor, class, weapon, armor,
                     and states. <rune_seal> :D.
v.1.7 - 2013.02.08 - >fix some errors when still having no subclass (if using yanfly class script)
v.1.8 - 2013.02.12 - >add method to check objects rune or not. for making compatibility patch
                     >added falcao mana stones enchantment compatibility patch
                     >IF you want rune still listed at the falcao mana stones just change the
                     configuration in module ESTRIOLE. LIST_RUNE_IN_FALCAO_MANA_STONE = true
v.1.9 - 2013.02.13 - >inspiration struct me and make me found a way to make 
                     compatibility for scene that not supposed to list rune in 
                     their list. (example falcao mana stones)
                     >removed the configuration created in v.1.8
                     >add configuration for what scene that not include runes
                     in Game_Actor equips method. so we have both compatibility with 
                     1)script that use equips method to do some effect or linked skill
                     2)script that use equips method to list equipment but not supposed to include runes. :D.
                     if you want RUNE to excluded from equip in that scene...
                     then add the scene name in module ESTRIOLE::SCENE_NOT_INCLUDE_RUNE
                     just search this: SCENE_NOT_INCLUDE_RUNE
v.2.0 - 2013.05.16 - >requested by zombiebear. added compatibility patch to
                     Nasty Extra Stat script. now you can make runes which when
                     attached to actor. could give you extra stats.
                     (you need still to modify the window for showing extra stats
                     changes in scene_equip though since this script only reuse what the 
                     scene_equip use. that's for compatibility with another equip
                     script...)
v.2.1 - 2013.05.23 - >thanks to detailed bug report from darkro... fix the bug
                     where the skill window not refreshing when accessing it using rune.
v.2.2 - 2013.05.26 - >updated the regexp just to make it the same as notetags grabber
                     because i often copy paste method from this script for the notetag.
                     no effect in this script. since this script don't use '-' and '.'
v.2.3 - 2013.06.11 - >updated the regexp to latest format used in EST - SIMPLE NOTETAGS GRABBER
                   - >Add scene rune skill. it's basically skill scene but selecting
                     rune instead of skill type. there's configuration to make it replace scene_skill.
                     (it will replace the skill menu. so no need to set up any menu script)
                     also the rune item will use the skill type that you ADD at the rune...
                     to determine what skills that can be selected...
                     it will use the first skill type you add at the trait box of the rune (armor)
v.2.4 - 2013.06.12 - >last update made some type to the manual rune skill notetags. fixed it
                   - >update the sealed rune slots feature. now equip and state can seal the rune slot.
                   - >now we can add new runeslots in game see how to use section
                   - >now we can remove runeslots in game see how to use section
                   - >script call to switch from skill menu mode or rune skill menu mode
                     in game see how to use section
v.2.5 - 2013.06.21 - >minor silly bugfix which caused this script can't work without yanfly equip engine.
v.2.6 - 2013.07.02 - >add Scene_RuneShop. it's the same with Scene_Rune except it have cost to attach / remove
                      i decide to separate the scene in case someone want the no cost equip rune feature.
                     >fix skill mode not able to togle
v.2.7 - 2013.07.27 - > add patch and configuration to AUTOMATICALLY add the menu command to
                      menu if using YANFLY MENU ENGINE script. you can choose which command to add
                      (3 possible menu - rune skill, rune attach, rune shop)
                      automatically disable hijack scene_skill feature if the rune_skill is added in menu
v.2.8 - 2013.11.12 - > fix regexp multiline mode. so it won't go over the next regexp
                     > rework the seal slot method to EVENT seal slot.
                     > add EVENT unseal slot method
                     both EVENT seal and unseal will override ANY seal/unseal.
                     this is your last modification to rune_slots.
                     > add auto unseal rune slot notetags. now when certain requirement met
                     it will automatically unseal the slot. UNLESS SEALED BY EVENT!!!!
                     how to use it? Search WHAT'S NEW IN V.2.8
v.2.9 - 2013.11.15 - > ADD(not replace) new notetags format for custom_rune and sealed rune slot. 
                     old notetags have problem recognizing > as runeslot name. so if 
                     you put: ">Fire" it won't be recognized. old notetags STILL can be USED!!!
                     i make it that way so if people already using old format and
                     have like 108 character... they won't have to change anything.
                     new notetags format:
                     <custom_rune>
                     "a:","b:","c:",
                     ">Fire:", "Etc"
                     </custom_rune>
                     <sealed_rune_slot>
                     ">Fire:", 0
                     </sealed_rune_slot>
                     if new notetags format exist. this script will IGNORE old format notetags!!!
                     
                     > rework the code a little bit so auto unseal runeslot notetags
                     could support slot index without putting it to ""
                     before:
                     <auto_unseal_rune_slot>
                      "0" => "p.gold > 1000",
                      1 => "p.gold > 100000"
                     </auto_unseal_rune_slot>
                     will only have auto unseal first slot (0). now both works!
v.3.0 - 2013.11.17 - > choose the actor when selecting rune skill/rune attach/rune shop from menu
                     ONLY IF using yanfly menu script!!!                     
v.3.1 - 2013.11.26 - > compatibility patch to Formar ATB/Stamina script.
                     make sure to put my script BELOW Formar ATB/Stamina script
                       
--------------------------------------------------------------------------------
How to use:
1) create the 'rune' and set the actor who can equip them
================================================================================
-> rune is basically armor. set it with any armor type you want (remember armor type NOT equipment type)
(if you're confused... armor type located ABOVE the equipment type in the database armor)
but it's better to use new one instead of using General Armor, Magic Armor that comes
with the default database. then make sure give your actors ability to equip that armor type

example: we create armor type "Rune" and armor type "Only Ted Rune"
then we set armor 1 named Fire Rune with that armor type "Rune"
then we set armor 2 named Water Rune with that armor type "Rune"
then we set armor 3 named Soul Eater Rune with that armor type "Only Ted Rune"
then we set actor 1 named Eric to able to equip armor type "Rune" (trait box)
then we set actor 2 named Ted to able to equip armor type "Rune" and armor type "Only Ted Rune"
thus eric able to equip fire and water rune. but cannot equip soul eater rune.
while ted able to equip fire, water, and soul eater rune.
so we can make runes exclusive to certain actors
  
-> second step is give that armor notetags
<equip type: Rune>

this to set the armor etype (not atype like above setting). and make it recognizeable
as 'rune'.
basically armor type(step above) is set to allow which actor can equip the rune
and equipment type is set to make the armor recognizeable as rune in the first place.

================================================================================

2) in trait box. give parameter increase, skills, and skill types to 'runes'
================================================================================
-> just use database armor trait box. you could add stat increase/skill/whatever supported
-> for skill added. it will be shown in the rune scene.
   if using yanfly equip engine support for 4 skill MAX. if using default support 5 skill MAX
   since i do some lookup at the trait box and make the first added skill
   i found as lv 1, second as lv 2, etc. so basically just put the skill add in right 
   order. lower level skill is at the higher position in the trait box.
-> ADD trait to give actor the CORRECT SKILL TYPE in the 'rune'
   i made the script read the trait box to make it used for scene_battle rune command.
   so if the rune didn't give any skill type then the rune's skill is unusable in battle
   (shown but will be greyed out and cannot be used)
   unless you add the trait using another equipment/class/actor trait box. but
   that defeat the purpose of using rune in battle.
   the skill type added search function also will return the first skill type added.
   so if you added 2 skill type added in that rune. in battle when you choose that rune. it will
   open skill window with the upper skill type in the trait box. 
   'rune' added skill type command also won't be shown in actor command in battle.
   it will only accessible via rune command. in case you want your actor able
   to access skill via other means other than runes... it's better that you didn't give
   the actor SAME skill type as what the rune gives (via class, equipment, etc)
   since it will delete the skill type command.
   ex: Earth rune give skill type "Earth Magic".
       Eric equip Earth Sword which give "Earth Magic".
       then Eric can use the earth magic but only accessible using rune command.
       usual "Earth Magic" command will not shown.
   ex2:Earth rune give skill type "Earth Magic"
       Eric Equip Earth Sword which give "Earth Sword Magic" (different stype)
       then Eric can use "Earth Magic" from rune command
       while the usual "Earth Sword Magic" command is shown and Eric able to access it
   
================================================================================
         
3) Add the runes to inventory :D. either by event command change armor or giving 
   it as monster drop.

================================================================================   
   
4) call the scene:
SceneManager.call(Scene_Rune)
i didn't add menu feature yet since in suikoden you CANNOT access this scene from menu.
you need to visit runemaster :D. but you could easily add it if you're using yanfly menu script.

SceneManager.call(Scene_RuneShop)
call this scene if you want it as rune shop (require cost to attach/remove)
you can search HOW TO DEFINE ATTACH / REMOVE COST to learn how to set the notetags

# NOW there's a configuration to auto add those scenes (and rune skill) to menu
if using yanfly menu engine. CHEERS!!!

================================================================================

5) profit $$$

================================================================================
   
6) extra features:

================================================================================

                      ACTOR/CLASS/SUBCLASS NOTETAGS

================================================================================

->ADD STARTING RUNE to character. there's two method. one is using slot index. 
other using slot name.
first method: add notetags in actor/class/subclass

<start_rune_x: y>
x => rune slot (start at 0. first one is 0, second one is 1, etc)
y => rune id (if the rune id armor is not a 'rune' then it won't equip the rune)

ex: <start_rune_0: 55>
will add rune 55 (if rune) in slot 0 (first slot)

second method: add notetags in actor/class/subclass
<start_rune_"x": y>
x => rune slot name. CASE SENSITIVE!!!!. it's put inside "".
y => rune id (if the rune id armor is not a 'rune' then it won't equip the rune)

ex: <start_rune_"Lh:": 55>
will add rune 55 (if rune) in slot named "Lh:" if slot named that exist

================================================================================

-> to give certain actor custom rune slot
old notetags... still working but will ignore > as rune slot name
<custom_rune: "a:","b:","c:","d:",">ex:">
will make actor tagged with that to have runeslot:
a:
b:
c:
d:
you can add more string to increase rune slot number.

NEW NOTETAGS FORMAT from v2.9. now will recognize > as rune slot name
if the new notetags format exist... old format will be ignored.
<custom_rune>
"a:","b:","c:","d:",">ex:"
</custom_rune>
will make actor tagged with that to have runeslot:
a:
b:
c:
d:
>ex:

================================================================================

               ACTOR/CLASS/SUBCLASS/WEAPON/ARMOR/STATE NOTETAGS

================================================================================

->to seal rune slot (cannot be modified):
add notetags in actor/class/subclass
<sealed_rune_slot: x, y, z>
x y z is the id of rune slot (starting at 0)
x y z can also be rune slot name but need to put inside "". and CASE SENSITIVE!!!!

ex: <sealed_rune_slot: 0, "H :", 2>
will make rune slot 0 (the first one), slot named "H :", slot 2(third one)
cannot be modified. useful make fixed rune.
to make it fixed rune just set the starting rune for that character then seal it

NEW NOTETAGS FORMAT from v2.9. now will recognize > as rune slot name
if the new notetags format exist... old format will be ignored.
<sealed_rune_slot>
x, y, z
</sealed_rune_slot>
ex:
<sealed_rune_slot>
0, "H :", "2"
</sealed_rune_slot>
will make rune slot 0 (the first one), slot named "H :", third slot(index 2)
cannot be modified. useful make fixed rune.

--------------------------------------------------------------------------------

-> UNSEAL the runeslot if the condition met from notetags in actor/class/subclass/equipment/state
<auto_unseal_rune_slot>
"SLOTNAME" => "REQUIREMENT",
"SLOTNAME" => "REQUIREMENT",
"SLOTNAME" => "REQUIREMENT",
"SLOTNAME" => "REQUIREMENT",
"SLOTNAME" => "REQUIREMENT",
</auto_unseal_rune_slot>

SLOTNAME = name of the slot (or index of the slot). NEED TO PUT INSIDE ""
REQUIREMENT = the requirement when the slot unsealed automatically.
you can use any method inside Game_Actor class such as:
level, atk, agi
and i also add some shortcut variables to make the requirement shorter:
------------><-----------------------
      s = $game_switches
      v = $game_variables
      p = $game_party
      a = $game_actors
      gs = $game_system
      pt = $game_system.playtime
      bc = $game_system.battle_count
      sc = $game_system.save_count
------------><-----------------------
ex:
<auto_unseal_rune_slot>
"Head" => "level > 10 && sc > 10",
"Lips" => "agi > 400 || bc > 10",
"0" => "p.gold > 1000",
1 => "p.gold > 100000"
</auto_unseal_rune_slot>
will automatically unseal the:
"Head" slot if actor level > 10 AND save count > 10
"Lips" slot if actor agi > 400 OR battle count > 10
first slot if party gold > 1000
second slot if party gold > 100000
#notice that you could use slot index and slot index in quotes. it's new feature
from v2.9

================================================================================

now you can seal the actor from using runes in battle (command greyed). just give notetags to database object.
<rune_seal>

if given to actor then the actor won't able to use rune command. (people without magic capability?)
if given to class then every actor with that class cannot use rune. (class that cannot use rune?)
if given to equip then if actor equip that weapon/armor then cannot use rune (cursed weapon, armor, etc?)
if given to state then every actor that have that state cannot use rune.

using states... you can create mother earth skill which prevent all allies and
all enemies to use rune for 3 turns.
  
================================================================================

                       RUNE(ARMOR) NOTETAGS

================================================================================

->to specify certain rune only able to equipped in certain slot.
i provide two way:
a> set the forbidden slot for that rune. give notetags to the armor:

<forbidden_rune_slots: x, y, z>
x y z is the id of the rune slot the rune NOT allowed to shown on the list. slot start at 0
x y z can also be rune slot name but need to put inside "". and CASE SENSITIVE!!!!

ex: <forbidden_rune_slots: 0, "Rh:">

will make that rune(armor) not shown in runeslot 0 (first) and runeslot named "Rh:"
but will appear in all other slot available

b> the other way is to set what slot that rune is ALLOWED to appear (reverse of no 1)

<only_rune_slots: x, y, z>
x y z is the id of the rune slot that the rune IS allowed to shown on the list. slot start at 0
x y z can also be rune slot name but need to put inside "". and CASE SENSITIVE!!!!

ex: <only_rune_slots: 0, "Lh:">

will make that rune(armor) only shown in runeslot 0 (first) and runeslot named "Lh:"
but will NOT appear in all other slot available

================================================================================

If you're adding the skill via other way than runes (in class maybe. for setting level the skill can be used). 
and use runes only to unlock the skill type. but you still want to show some rune skill in windows.
you could add these notetags to the rune(Armor).

<rune_skills: a, b, c, d >
a b c d = id of the skills.
ex: 
<rune_skills: 33, 42, 21 >
will shown on window rune skill list like this:
Lv1: skill 33
Lv2: skill 42
Lv3: skill 21

if you're adding this notetags it will use this notetags value to determine what
to show in the rune skill list window. if not given notetags, it will use previous method.
'read' the rune trait box and search for added skills feature.

================================================================================
HOW TO DEFINE ATTACH / REMOVE COST

add cost to attaching or removing rune. give notetags to armor item:
<rune_attach_cost: x>
<rune_remove_cost: x>
change x to price you want
if item not given notetags it will use the default cost defined in ESTRIOLE module

================================================================================

7) in game modification (for event, etc)

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

->to give rune to certain slot for actor
script call:

actor_set_rune(actor_id,rune_slot,rune_id,swap_inventory = false)

actor_id => id of the actor in database
rune_slot => slot position (first one is 0, second is 1, etc)
             or slot name inside "". CASE SENSITIVE!!!
rune_id => rune id (armor id in database). i also made check to return if it's not a 'rune'
swap_inventory => true : will equip the inventory rune instead of giving free runes. if didn't have it then do nothing
                  false: will give free rune and set it to the slot
                  default is set to false
ex: actor_set_rune(1,0,56)
will give rune 56 for free(if rune). then attach it to runeslot 0 (first slot) 
for actor 1.
ex: actor_set_rune(1,"Rh:",56,true)
will searh rune 56 in inventory. if exist.. attach it to runeslot named "Rh:"
for actor 1

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

->to seal(cannot change) certain slot for actor
script call:

actor_seal_rune(actor_id,rune_slot)
actor_id => id of the actor in database
rune_slot => slot position (first one is 0, second is 1, etc)
             or slot name inside "". CASE SENSITIVE!!!

ex: actor_seal_rune(1,2)
will seal actor 1's rune slot 2 (third slot).
ex: actor_seal_rune(1,"H :")
will seal actor 1's rune slot named "H :".

->to unseal(can change) certain slot for actor
script call:

actor_unseal_rune(actor_id,rune_slot)
actor_id => id of the actor in database
rune_slot => slot position (first one is 0, second is 1, etc)
             or slot name inside "". CASE SENSITIVE!!!

ex: actor_unseal_rune(1,2)
will unseal actor 1's rune slot 2 (third slot).
ex: actor_unseal_rune(1,"H :")
will unseal actor 1's rune slot named "H :".

UNSEAL will have more priority over SEAL...

THESE SEAL AND UNSEAL METHOD WILL OVERRIDE ANY ACTOR / CLASS / EQUIP / STATE
this is your final modification to your rune slot seal / unseal.

-> if you want to reset it using actor/class/equip/state seal/unseal.
use these script call:

actor_reset_seal(actor_id, rune_slot)
actor_id => change to actor id you want to reset the seal
rune_slot => name of the slot that want to use default seal method
             if this not spefified then reset all slots


>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

->to add new rune slot
script call:

add_rune_slot(actor_id,rune_slot_name,pos,allow_duplicate, rune_id)
actor_id => id of the actor in database *required
rune_slot_name => the new rune slot name *required
pos => position of the slots (1 is the first slot, 2 is 2nd slot, etc, 0 means put as the last slot)
       *optional. if not set it will use 0 (last slot)
allow_duplicate => if true will add the slot even there's already slot with same name
                   if false will not add the slot when there's already slot with same name
                   *optional. if not set it will use true (allow duplicated slot name)
rune_id => if you want the new slot auto set with rune. add the rune id here
           *optional. if not set it will use nil (none)

  
example:
add_rune_slot(3,"Tail",0,false,67)
will add actor 3 slot named "Tail". not allowing duplicate. will set armor 67 as rune on that slot
(if it's a rune)

->to remove rune slot
script call:

rem_rune_slot(actor_id,slot_name,put_item_to_bag)
actor_id => id of the actor in database *required
slot_name => name of the slot to removed *required *case sensitive
put_item_to_bag => true -> put equipped rune to bag
                   false -> delete the equipped rune
                   *optional. if not set it will use true (put item to bag)

                   
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

->to change skill mode
                   
$game_system.rune_skill_mode = true/false

true -> will use Scene_MenuRune when choosing skill from menu
false -> will use Scene_Skill when choosing skill from menu

================================================================================                  

WHAT'S NEW IN V.2.8

================================================================================

now we have more advanced rune slot seal and unseal method. here's the order
the seal implemented: (the lower number overriden by higher number)

1) SEAL the runeslot from notetags in actor/class/subclass/equipment/state
<sealed_rune_slot: x, y, z>
ex:
<sealed_rune_slot: 0, "Lips", "Head">
it will seal the first slot, slot named "Lips", and slot named "Head"

2) UNSEAL the runeslot if the condition met from notetags in actor/class/subclass/equipment/state
<auto_unseal_rune_slot>
"SLOTNAME" => "REQUIREMENT",
"SLOTNAME" => "REQUIREMENT",
"SLOTNAME" => "REQUIREMENT",
"SLOTNAME" => "REQUIREMENT",
"SLOTNAME" => "REQUIREMENT",
</auto_unseal_rune_slot>

SLOTNAME = name of the slot (or index of the slot). NEED TO PUT INSIDE ""
REQUIREMENT = the requirement when the slot unsealed automatically.
you can use any method inside Game_Actor class such as:
level, atk, agi
and i also add some shortcut variables to make the requirement shorter:
------------><-----------------------
      s = $game_switches
      v = $game_variables
      p = $game_party
      a = $game_actors
      gs = $game_system
      pt = $game_system.playtime
      bc = $game_system.battle_count
      sc = $game_system.save_count
------------><-----------------------
ex:
<auto_unseal_rune_slot>
"Head" => "level > 10 && sc > 10",
"Lips" => "agi > 400 || bc > 10",
"0" => "p.gold > 1000",
1 => "p.gold > 100000"
</auto_unseal_rune_slot>
will automatically unseal the:
"Head" slot if actor level > 10 AND save count > 10
"Lips" slot if actor agi > 400 OR battle count > 10
first slot if party gold > 1000
second slot if party gold > 100000
#notice that you could use slot index and slot index in quotes.

3) SEAL the runeslot from event using script call:
->to seal(cannot change) certain slot for actor
script call:

actor_seal_rune(actor_id,rune_slot)
actor_id => id of the actor in database
rune_slot => slot position (first one is 0, second is 1, etc)
             or slot name inside "". CASE SENSITIVE!!!

ex: actor_seal_rune(1,2)
will seal actor 1's rune slot 2 (third slot).
ex: actor_seal_rune(1,"H :")
will seal actor 1's rune slot named "H :".

4) UNSEAL the runeslot from event using script call:
->to unseal(can change) certain slot for actor
script call:

actor_unseal_rune(actor_id,rune_slot)
actor_id => id of the actor in database
rune_slot => slot position (first one is 0, second is 1, etc)
             or slot name inside "". CASE SENSITIVE!!!

ex: actor_unseal_rune(1,2)
will unseal actor 1's rune slot 2 (third slot).
ex: actor_unseal_rune(1,"H :")
will unseal actor 1's rune slot named "H :".

SO BASICALLY 4> override 3> override 2> override 1>

and 3> and 4> is the final modification to the runeslot. since we might want
to create event where we want the certain slot SEALED no matter what.

Note: if you want to reset event seal.
use these script call:

actor_reset_seal(actor_id, rune_slot)
actor_id => change to actor id you want to reset the seal
rune_slot => name of the slot that want to use default seal method
             if this not spefified then reset all slots
               
================================================================================

Author Note

================================================================================

None

================================================================================
=end

$imported = {} if $imported.nil?
$imported["EST - SUIKODEN RUNE"] = true

module ESTRIOLE
################ START CONFIGURATION ###########################################
    
  RUNE_SLOT_ID = 101            #give this etype_id that don't conflict with yanfly equip engine setting you set
  RUNE_SKILL_LIST_POINTER = "►" #change this to "-" if you have custom font issues
  RUNE_SLOT_SPACE = 50          #size of the rune slot name. raise this if you use longer slot name
  RUNE_REMOVE_EQUIP_ICON = 185  #set this if you're NOT using yanfly equip engine
  RUNE_NOTHING_ICON = 185       #set this if you're NOT using yanfly equip engine
  
  #RUNE COST RELATED
  RUNE_DEFAULT_ATTACH_COST = 1000
  RUNE_DEFAULT_REMOVE_COST = 500
  
  # you could set the default rune slot below.
  RUNE_SLOT_NAME = ["H :","Lh:","Rh:"]
  # you can add more slot just by adding above array new string
  # if you want custom slot each actor just give notetags (see how to use)
    
  ### RUNE COMMAND IN MENU RELATED ###########################################  
  RUNE_REPLACE_SKILL_MENU = true
  # if you set above to true it will replace skill menu to rune skill menu
  # if set to false it will use default skill menu. and if you want to call
  # rune skill menu you must call it with: SceneManager.call(Scene_MenuRune)
  
  # ADD the "SCENE" that it's game_actor equips method not included runes in it BELOW.
  # Warning PUT THE SCENE NAME IN STRING!!!!. i make it string for better compatibility
  SCENE_NOT_INCLUDE_RUNE = [#do not touch this line
  "Scene_ManaStones",
  "Scene_Party",
  ]#do not touch this line
  # DON'T Forget the ,(coma) after each scene name.
  # the "SCENE" child class WILL still include runes.
  # ex: Scene_Equip < Scene_MenuBase
  # if you put "Scene_MenuBase" in array above. then Scene_Equip still have runes 
  # returned from game_actor equips method. to make it not using runes add "Scene_Equip".
  # it's better to NEVER ADD "Scene_Rune" in above array. add that at your own RISK!
  
  ### AUTO ADD IN YANFLY MENU ENGINE CONFIG ####################################
  #change the display name to what you want as menu name
    EST_RUNE_CUSTOM_COMMAND = {
  #                      ["Display Name", EnableSwitch, ShowSwitch,      Handler Method],
    :est_rune_skill   => [  "Rune Skill",     0,          0, :command_est_rune_skill],
    :est_rune_attach  => [  "Rune Attach",    0,          0, :command_est_rune_attach],
    :est_rune_shop    => [  "Rune Shop",      0,          0, :command_est_rune_shop],
  } # <- Do not delete.
  
  ### set to true if you want to auto add the menu if using yanfly menu engine
  ADD_EST_RUNE_SKILL = true 
  ADD_EST_RUNE_ATTACH = true
  ADD_EST_RUNE_SHOP = true
  
  ### the position of the menu (0 is the first)
  EST_RUNE_SKILL_POS = 3
  EST_RUNE_ATTACH_POS = 4
  EST_RUNE_SHOP_POS = 5
    
  ### RUNE COMMAND IN BATTLE RELATED ###########################################
  RUNE_BATTLE_SHOW_SWITCH = 0     #switch if on will show rune command. if off rune command is not shown.
                                  #if you don't want to use it change it to 0
  RUNE_BATTLE_DISABLED_SWITCH = 0 #switch if on all actor will not able to access rune in battle (greyed)
                                  #if you don't want to use it change it to 0
  RUNE_VOCAB = "Rune"             #this what shown in battle command
  RUNE_COMMAND_POSITION = 2       #default 2nd slot (below attack)
  RUNE_BATTLE_WINDOW = {
  :x => 0,                        # set x of the rune in battle window
  :y => 0,                        # set y of the rune in battle window
  :w => 250,                      # set width of the rune in battle window
  :slots => 3,                    # number of slots space for the window
  }
  
  ##############################################################################
  # DO NOT TOUCH BELOW IF YOU'RE USING EITHER YANFLY EQUIP ENGINE OR DEFAULT EQUIP ENGINE
  # change this hash below ONLY if you have compatibility with your equip scene script.
  #-----------------------------------------------------------------------------
  RUNE_SKILL_LIST_SETTING = {
  :overlap_window => "@slot_window",  
  #change above to window name(in "") you want the @rune_skill_window to overlap
  #the @rune_skill_window will positioned and sized just like the overlapped window
  #then the overlapped window will also hidden when @rune_skill_window shown
  }
  #above is SET for default equip system. don't change it if you're not using equip scene script.
  #if using yanfly equip engine above ALL above settings is ignored!!! and will use yanfly setting instead  
  
  ### do not edit below this unless you know what you're doing
  if $imported["YEA-AceMenuEngine"]  
  RUNE_REPLACE_SKILL_MENU = false if ADD_EST_RUNE_SKILL
  YEA::MENU::CUSTOM_COMMANDS.merge!(EST_RUNE_CUSTOM_COMMAND)
  YEA::MENU::COMMANDS.insert(EST_RUNE_SKILL_POS,:est_rune_skill) if ADD_EST_RUNE_SKILL
  YEA::MENU::COMMANDS.insert(EST_RUNE_ATTACH_POS,:est_rune_attach) if ADD_EST_RUNE_ATTACH
  YEA::MENU::COMMANDS.insert(EST_RUNE_SHOP_POS,:est_rune_shop) if ADD_EST_RUNE_SHOP
  end 
  ### do not edit this  
  
################# END CONFIGURATION ############################################
end

if $imported["YEA-AceEquipEngine"]
  module YEA
    module EQUIP
      RUNE_TYPES ={
      # TypeID => ["Type Name", Removable?, Optimize?],
        "#{ESTRIOLE::RUNE_SLOT_ID}".to_i => [ESTRIOLE::RUNE_VOCAB, true, false],
      } # Do not remove this.    
      TYPES.merge!(RUNE_TYPES)
    end
  end
end

if !$imported["YEA-AceEquipEngine"]
  module Icon  
    def self.remove_equip; return ESTRIOLE::RUNE_REMOVE_EQUIP_ICON; end
    def self.nothing_equip; return ESTRIOLE::RUNE_NOTHING_ICON; end
  end # Icon
end

module SceneManager
  def self.scene_any?(array_scene)
    array_scene.each {|scene_class|
      return true if @scene.class.to_s == scene_class.to_s
    }
    return false
  end
end

class RPG::BaseItem
  def old_sealed_rune_slots
    return [] if !note[/<sealed_rune_slot:([^>]*)>/im]
    a = note[/<sealed_rune_slot:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    return noteargs = a        
  end

  def sealed_rune_slots
    return old_sealed_rune_slots if !note[/<sealed_rune_slots?>(?:[^<]|<[^\/])*<\/sealed_rune_slots?>/i]
    a = note[/<sealed_rune_slots?>(?:[^<]|<[^\/])*<\/sealed_rune_slots?>/i].scan(/(?:!<sealed_rune_slots?>|(.*)\r)/)
    a.delete_at(0)    
    a = a.join("\r\n")
    return noteargs = eval("[#{a}]") rescue []
  end
  def auto_unseal_rune_slot
    return {} if !note[/<auto_unseal_rune_slot?>(?:[^<]|<[^\/])*<\/auto_unseal_rune_slot?>/i]
    a = note[/<auto_unseal_rune_slot?>(?:[^<]|<[^\/])*<\/auto_unseal_rune_slot?>/i].scan(/(?:!<auto_unseal_rune_slot?>|(.*)\r)/)
    a.delete_at(0)    
    a = a.join("\r\n")
    return noteargs = eval("{#{a}}") rescue {}
  end
  def starting_rune(index)
    return [] if !note[/<start_rune_#{index}:([^>]*)>/im]
    a = note[/<start_rune_#{index}:(.*)>/im].scan(/:([^>]*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    a.collect!{|x| x.to_i}
    return noteargs = a        
  end
  def starting_rune_ex(slot_name)
    return [] if !note[/<start_rune_"#{slot_name}":([^>]*)>/im]
    a = note[/<start_rune_"#{slot_name}":([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    a.collect!{|x| x.to_i}
    return noteargs = a        
  end
  def custom_rune
    return old_custom_rune if !note[/<custom_rune?>(?:[^<]|<[^\/])*<\/custom_rune?>/i]
    a = note[/<custom_rune?>(?:[^<]|<[^\/])*<\/custom_rune?>/i].scan(/(?:!<custom_rune?>|(.*)\r)/)
    a.delete_at(0)    
    a = a.join("\r\n")
    return noteargs = eval("[#{a}]") rescue []    
  end
  def old_custom_rune
    return [] if !note[/<custom_rune:([^>]*)>/im]
    a = note[/<custom_rune:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    return noteargs = a        
  end
  def rune_seal?
    return false if !note[/<rune_seal>/im]
    return true if note[/<rune_seal>/im]
  end
  def rune?
    return false if !note[/<equip type:([^>]*)>/im]
    a = note[/<equip type:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    etype = a[0][/rune/im] ? ESTRIOLE::RUNE_SLOT_ID : a[0].to_i
    return true if etype == ESTRIOLE::RUNE_SLOT_ID && self.is_a?(RPG::Armor)
    return false
  end
end

class RPG::Armor < RPG::EquipItem
  def forbidden_rune_slots
    return [] if !note[/<forbidden_rune_slots:([^>]*)>/im]
    a = note[/<forbidden_rune_slots:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    return noteargs = a        
  end
  def only_rune_slots
    return [] if !note[/<only_rune_slots:([^>]*)>/im]
    a = note[/<only_rune_slots:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    return noteargs = a        
  end
  def manual_rune_skills
    return nil if !note[/<rune_skills:([^>]*)>/im]
    a = note[/<rune_skills:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    a.collect!{|x| x.to_i}
    return noteargs = a        
  end  
  def rune_attach_cost
    return ESTRIOLE::RUNE_DEFAULT_ATTACH_COST if !note[/<rune_attach_cost:([^>]*)>/im]
    a = note[/<rune_attach_cost:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    return noteargs = a[0].to_i    
  end
  def rune_remove_cost
    return ESTRIOLE::RUNE_DEFAULT_REMOVE_COST if !note[/<rune_remove_cost:([^>]*)>/im]
    a = note[/<rune_remove_cost:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    return noteargs = a[0].to_i        
  end
  
  if !$imported["YEA-AceEquipEngine"]
    def etype_id
      custom_etype = get_custom_etype
      return custom_etype if custom_etype
      return @etype_id
    end
    def get_custom_etype
    return nil if !@note[/<equip type:([^>]*)>/im]
    a = note[/<equip type:([^>]*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    etype = a[0][/rune/im] ? ESTRIOLE::RUNE_SLOT_ID : a[0].to_i
    return noteargs = etype
    end
  end
  
  
end

class Game_System
  attr_accessor :rune_skill_mode
  def rune_skill_mode
    @rune_skill_mode = ESTRIOLE::RUNE_REPLACE_SKILL_MENU if @rune_skill_mode.nil?
    @rune_skill_mode
  end
end
class Game_Actor < Game_Battler
  attr_accessor :runes
  attr_accessor :sealed_rune_slot
  alias est_rune_game_actor_init initialize
  def initialize(actor_id)
    est_rune_game_actor_init(actor_id)
    @runes = Array.new(rune_slots_name.size,nil)
    init_runes
  end
  def init_runes
    for i in 0..@runes.size-1
      @runes[i] = $data_armors[starting_rune(i)] if starting_rune(i) && $data_armors[starting_rune(i)].etype_id == ESTRIOLE::RUNE_SLOT_ID
    end
    @hp = mhp
    @mp = mmp
  end
  def rune_enabled?
    return false if check_rune_seal
    return false if $game_switches[ESTRIOLE::RUNE_BATTLE_DISABLED_SWITCH]
    return true
  end
  def check_rune_seal
    return true if actor.rune_seal?
    return true if $data_classes[@class_id].rune_seal?
    return true if $imported["YEA-ClassSystem"] &&
                   $data_classes[@subclass_id] &&
                   $data_classes[@subclass_id].rune_seal?
    equips.each do |equip|
      next if !equip
      return true if equip.rune_seal?
    end    
    states.each do |state|
      return true if state.rune_seal?
    end
    return false
  end
  def starting_rune(index)
    return actor.starting_rune_ex(rune_slots_name[index])[0] if actor.starting_rune_ex(rune_slots_name[index]) != []
    return actor.starting_rune(index)[0] if actor.starting_rune(index)
    return $data_classes[@class_id].starting_rune_ex(rune_slots_name[index])[0] if $data_classes[@class_id].starting_rune_ex(rune_slots_name[index])  != []
    return $data_classes[@class_id].starting_rune(index)[0] if $data_classes[@class_id].starting_rune(index)
    return $data_classes[@subclass_id].starting_rune_ex(rune_slots_name[index])[0] if $imported["YEA-ClassSystem"] &&
                                                                                      $data_classes[@subclass_id] &&
                                                                                      $data_classes[@subclass_id].starting_rune_ex(rune_slots_name[index]) != [] 
    return $data_classes[@subclass_id].starting_rune(index)[0] if $imported["YEA-ClassSystem"] && 
                                                                  $data_classes[@subclass_id] &&
                                                                  $data_classes[@subclass_id].starting_rune(index)
    return nil
  end
  def sealed_rune_slots
    @sealed_rune_slot = get_sealed_rune_slots
    auto_unseal_requirement
    @sealed_rune_slot += event_sealed_rune_slots
    @sealed_rune_slot -= event_unsealed_rune_slots    
    @sealed_rune_slot
  end
  def auto_unseal_requirement
    s = $game_switches
    v = $game_variables
    p = $game_party
    a = $game_actors
    gs = $game_system
    pt = $game_system.playtime
    bc = $game_system.battle_count
    sc = $game_system.save_count 
    actor.auto_unseal_rune_slot.each do |slot,req|
      @sealed_rune_slot -= [slot] if eval(req) rescue false
    end
    $data_classes[@class_id].auto_unseal_rune_slot.each do |slot,req|
      @sealed_rune_slot -= [slot] if eval(req) rescue false
    end
    if chk = subclass rescue false
      subclass.auto_unseal_rune_slot.each do |slot,req|
        @sealed_rune_slot -= [slot] if eval(req) rescue false
      end
    end
    equips.each do |equip|
      next if !equip
      equip.auto_unseal_rune_slot.each do |slot,req|
        @sealed_rune_slot -= [slot] if eval(req) rescue false
      end
    end    
    states.each do |state|
      state.auto_unseal_rune_slot.each do |slot,req|
        @sealed_rune_slot -= [slot] if eval(req) rescue false
      end
    end    
  end
  def event_sealed_rune_slots
    @event_sealed_rune_slots = [] if !@event_sealed_rune_slots
    return @event_sealed_rune_slots
  end
  def event_sealed_rune_slots=(val)
    return if @event_sealed_rune_slots == val
    @event_sealed_rune_slots = val
  end
  def event_unsealed_rune_slots
    @event_unsealed_rune_slots = [] if !@event_unsealed_rune_slots
    return @event_unsealed_rune_slots
  end
  def event_unsealed_rune_slots=(val)
    return if @event_unsealed_rune_slots == val
    @event_unsealed_rune_slots = val
  end
  
  def get_sealed_rune_slots
    sealed_slot = []
    sealed_slot = sealed_slot + actor.sealed_rune_slots if actor.sealed_rune_slots
    sealed_slot = sealed_slot + $data_classes[@class_id].sealed_rune_slots if $data_classes[@class_id].sealed_rune_slots
    sealed_slot = sealed_slot + $data_classes[@subclass_id].sealed_rune_slots if $imported["YEA-ClassSystem"] && 
                                                            $data_classes[@subclass_id] &&
                                                            $data_classes[@subclass_id].sealed_rune_slots
    equips.each do |equip|
      next if !equip
      sealed_slot = sealed_slot + equip.sealed_rune_slots if equip.sealed_rune_slots
    end    
    states.each do |state|
      sealed_slot = sealed_slot + state.sealed_rune_slots if state.sealed_rune_slots
    end
    return sealed_slot
  end
  def rune_slots
    @rune_slots = Array.new(rune_slots_name.size,ESTRIOLE::RUNE_SLOT_ID) if !@rune_slots
    @rune_slots
  end
  def rune_slots_name
    @rune_slots_name = get_rune_slots_name if !@rune_slots_name
    @rune_slots_name
  end
  def get_rune_slots_name
    return actor.custom_rune if actor.custom_rune != []
    return $data_classes[@class_id].custom_rune if $data_classes[@class_id].custom_rune != []
    return $data_classes[@subclass_id].custom_rune if $imported["YEA-ClassSystem"] && 
                                                      $data_classes[@subclass_id] &&
                                                      $data_classes[@subclass_id].custom_rune != []
    return ESTRIOLE::RUNE_SLOT_NAME.dup    
  end
  def change_rune(slot_id, item)
    return unless trade_item_with_party(item, runes[slot_id])
    return if item && rune_slots[slot_id] != item.etype_id
    @runes[slot_id] = item
    refresh
  end
  def set_rune(slot_id, item)
    trade_item_with_party(nil, runes[slot_id])
    return if item && rune_slots[slot_id] != item.etype_id
    @runes[slot_id] = item
    refresh    
  end
  def force_change_rune(slot_id, item)
    @runes[slot_id] = item
    refresh
  end
    
  alias est_suikoden_rune_equips equips
  def equips
    equip = est_suikoden_rune_equips
    runes = [] if @runes.nil?
    runes = @runes if !@runes.nil?
    return equips = equip + runes if !SceneManager.scene_any?(ESTRIOLE::SCENE_NOT_INCLUDE_RUNE)
    return equip
  end
  alias est_rune_game_actor_feature_objects feature_objects
  def feature_objects
    cond = SceneManager.scene_any?(ESTRIOLE::SCENE_NOT_INCLUDE_RUNE)
    return obj = est_rune_game_actor_feature_objects + @runes.compact if cond && @runes 
    est_rune_game_actor_feature_objects
  end    
  def runes_object
    @runes.compact
  end
  def runes
    @runes
  end
  #add rune slot ingame patch
  def add_rune_slot(rune_slot_name,pos=-1,allow_duplicate = true,rune)
    return if @rune_slots_name.include?(rune_slot_name) && !allow_duplicate
    rune_slots #to init the variable if still nil
    rune_slots_name #to init the variable if still nil
    @runes.insert(pos,rune)
    @rune_slots.insert(pos,ESTRIOLE::RUNE_SLOT_ID)
    @rune_slots_name.insert(pos,rune_slot_name)
  end
  def rem_rune_slot(slot,put_item_to_bag = true)
    rune_slots #to init the variable if still nil
    rune_slots_name #to init the variable if still nil
    slot = @rune_slots_name.index(slot) rescue nil
    return if !slot
    return if slot > @runes.size-1
    item = @runes[slot]
    @runes.delete_at(slot)
    @rune_slots.delete_at(slot)
    @rune_slots_name.delete_at(slot)
    $game_party.gain_item(item, 1) if item && put_item_to_bag
  end
  #tsukihime effect manager patch. runes can have effects too :D.
  # you can create rune who damage all enemy at start of battle
  # this useful to create fury rune. why? add the fury state after reviving
  if $imported["Effect_Manager"]
    alias est_suikoden_rune_effect_objects effect_objects
    def effect_objects
      prev_effects = est_suikoden_rune_effect_objects
      runes = [] if @runes.nil?
      runes = @runes.compact if !@runes.nil?
      return new_effects = prev_effects + runes    
    end
  end
end

class Window_RuneCommand < Window_EquipCommand
  def make_command_list
    add_command("Attach",   :attach)
    add_command("Remove", :remove)
    add_command("Leave",    :quit)
  end
end

class Window_RuneSlot < Window_EquipSlot
  def draw_item(index)
    return unless @actor
    rect = item_rect_for_text(index)
    change_color(system_color, enable?(index))
    draw_text(rect.x, rect.y, ESTRIOLE::RUNE_SLOT_SPACE, line_height, slot_name(index))
    item = @actor.runes[index]
    dx = rect.x + ESTRIOLE::RUNE_SLOT_SPACE
    dw = contents.width - dx - 24
    if item.nil?
      draw_nothing_equip(dx, rect.y, false, dw)
    else
      draw_item_name(item, dx, rect.y, enable?(index), dw)
    end
  end
  def draw_nothing_equip(dx, dy, enabled, dw)
    change_color(normal_color, enabled)
    draw_icon(Icon.nothing_equip, dx, dy, enabled)
    text = "Nothing"
    draw_text(dx + 24, dy, dw - 24, line_height, text)
  end  

  def slot_name(index)
    return @actor.rune_slots_name[index] if @actor
    return ""
  end

  def item_max
    @actor ? @actor.rune_slots.size : 0
  end

  def cost_window=(cost_window)
    return if @cost_window == cost_window
    @cost_window = cost_window
    refresh
  end
  
  def item
    @actor ? @actor.runes[@index] : nil
  end

  def enable?(index)
    return false if !@actor
    return false if @actor.sealed_rune_slots.include?(index)
    return false if @actor.sealed_rune_slots.include?(index.to_s)
    return false if @actor.sealed_rune_slots.include?(@actor.rune_slots_name[index])
    return true
  end
  
  alias est_suikoden_rune_refresh refresh
  def refresh
    create_contents
    est_suikoden_rune_refresh
  end
  alias est_suikoden_rune_update_help_cost update_help
  def update_help
    est_suikoden_rune_update_help_cost
    @cost_window.set_item_slot(item) if @cost_window
  end
end # Window_EquipSlot

class Window_RuneItem < Window_EquipItem
  def rune_skill_window=(rune_skill_window)
    @rune_skill_window = rune_skill_window
    call_update_help
  end
  def cost_window=(cost_window)
    return if @cost_window == cost_window
    @cost_window = cost_window
    refresh
  end
  def include?(item)
    return true if item == nil
    return false unless item.is_a?(RPG::EquipItem)
    return false if @slot_id < 0
    return false if item.etype_id != @actor.rune_slots[@slot_id]
    return false if item.forbidden_rune_slots.include?(@slot_id.to_s) 
    return false if item.forbidden_rune_slots.include?(@actor.rune_slots_name[@slot_id])
    return false if !item.only_rune_slots.include?(@slot_id.to_i.to_s) && 
                    !item.only_rune_slots.include?(@actor.rune_slots_name[@slot_id]) && 
                    item.only_rune_slots != []
    return @actor.equippable?(item)
  end
  def draw_remove_equip(rect)
    draw_icon(Icon.remove_equip, rect.x, rect.y)
    text = "- Remove -"
    rect.x += 24
    rect.width -= 24
    draw_text(rect, text)
  end
  def enable?(item)
      if item.nil? && !@actor.nil?
        etype_id = @actor.rune_slots[@slot_id]
        return YEA::EQUIP::TYPES[etype_id][1] if $imported["YEA-AceEquipEngine"]
      end
    return @actor.equippable?(item)
  end
  def update_help
    @help_window.set_item(item)
    @cost_window.set_item(item) if @cost_window
    if @actor && @status_window
      temp_actor = Marshal.load(Marshal.dump(@actor))
      temp_actor.force_change_rune(@slot_id, item)
      @status_window.set_temp_actor(temp_actor)
    end
    @rune_skill_window.item = item if @rune_skill_window
  end
end

class Window_RuneSkill < Window_Base
  def initialize(dx, dy, dw, dh)
    super(dx, dy, dw, dh)
    @item = nil
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # actor=
  #--------------------------------------------------------------------------
  def item=(item)
    return if @item == item
    @item = item
    refresh
  end
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return unless @item
    skills = get_skill(@item)
    i = 0
    skills.each do |skill|
      draw_text(0,i*line_height,48,line_height,"Lv #{i+1} #{ESTRIOLE::RUNE_SKILL_LIST_POINTER} ")
      draw_item_name(skill,48,i*line_height)
      i += 1
    end
  end
  def get_skill(item)
    skills = []
    if item.manual_rune_skills
      item.manual_rune_skills.each do |skill_id|
        skills.push($data_skills[skill_id])
      end
    else
    features = item.features
      features.each do |ft|
        skills.push($data_skills[ft.data_id]) if ft.code == 43
      end
    end
    return skills
  end
end

class Window_RuneGold < Window_Gold
  def initialize
    super#(0, 0, window_width, fitting_height(1))
    refresh
  end
  def contents_height
    height - standard_padding * 2 - 6
  end
  def window_width
    return 160
  end
  def draw_currency_value(value, unit, x, y, width)
    make_font_smaller
    cx = text_size(unit).width
    change_color(system_color)
    draw_text(x, y, width, line_height, "Fund", 3)
    change_color(normal_color)
    draw_text(x, y, width - cx - 2, line_height, value, 2)
    change_color(system_color)
    draw_text(x, y, width, line_height, unit, 2)
    reset_font_settings
  end
end
class Window_RuneCost < Window_Gold
  def initialize
    super
    refresh
  end
  def set_item(item)
    return if @item == item
    @item = item
    refresh
  end
  def set_item_slot(item)
    return if @item_slot == item
    @item_slot = item
    refresh
  end
  def mode=(mode)
    return if @mode == mode
    @mode = mode
    refresh
  end
  def contents_height
    height - standard_padding * 2 - 6
  end
  def window_width
    return 160
  end
  def draw_currency_value(value, unit, x, y, width)
    make_font_smaller
    cx = text_size(unit).width
    change_color(system_color)
    draw_text(x, y, width, line_height, "Cost", 3)
    change_color(normal_color)
    draw_text(x, y, width - cx - 2, line_height, value, 2)
    change_color(system_color)
    draw_text(x, y, width, line_height, unit, 2)
    reset_font_settings
  end
  def value
    case @mode
    when :attach
    remove_cost = @item_slot.rune_remove_cost rescue 0      
    attach_cost = @item.rune_attach_cost rescue 0
#    return total_cost = @item ? remove_cost + attach_cost : 0
    return total_cost = remove_cost + attach_cost
    when :remove
    remove_cost = @item_slot.rune_remove_cost rescue 0      
    else
    cost = 0
    end
  end
end

class Scene_Rune < Scene_Equip  
  alias est_suikoden_rune_start start
  def start
    $game_party.menu_actor = $game_party.members[0] if !$game_party.menu_actor
    est_suikoden_rune_start
  end  
  alias escape_scene_update update
  def update
    escape_scene_update
    return_scene if Input.trigger?(:B)
  end
  alias est_suikoden_rune_create_command_window create_command_window
  def create_command_window
    est_suikoden_rune_create_command_window
    wx = @command_window.x
    wy = @command_window.y
    ww = @command_window.width
    @command_window.dispose
    @command_window = Window_RuneCommand.new(wx, wy, ww)
    @command_window.viewport = @viewport
    @command_window.help_window = @help_window
    @command_window.set_handler(:attach,    method(:command_attach))
    @command_window.set_handler(:remove, method(:command_remove))
    @command_window.set_handler(:quit,   method(:return_scene))
    @command_window.set_handler(:pagedown, method(:next_actor))
    @command_window.set_handler(:pageup,   method(:prev_actor))    
  end  
  alias est_suikoden_rune_next_actor next_actor
  def next_actor
    est_suikoden_rune_next_actor
    @slot_window.select(0)
  end
  alias est_suikoden_rune_prev_actor prev_actor
  def prev_actor
    est_suikoden_rune_prev_actor
    @slot_window.select(0)
  end
  def command_attach
    @slot_window.set_handler(:ok,       method(:on_slot_ok_attach))
    @slot_window.activate
    @slot_window.select(0)
  end
  def command_remove
    @slot_window.set_handler(:ok,       method(:on_slot_ok_remove))
    @slot_window.activate
    @slot_window.select(0)
  end
  def overlap_rune_skill_window
    return @actor_window if @actor_window && $imported["YEA-AceEquipEngine"]
    return eval("#{ESTRIOLE::RUNE_SKILL_LIST_SETTING[:overlap_window]}")
    return nil
  end  
  def on_slot_ok_attach
    on_slot_ok
    overlap_rune_skill_window.hide if overlap_rune_skill_window
    @rune_skill_window.show
    @item_window.set_handler(:ok,     method(:on_item_ok))    
  end
  def on_slot_ok_remove
    Sound.play_equip
    @actor.change_rune(@slot_window.index, nil)
    @slot_window.activate
    @slot_window.refresh
    @item_window.unselect
    @item_window.refresh
    @actor_window.refresh if $imported["YEA-AceEquipEngine"]
    @slot_window.show
    @item_window.hide if $imported["YEA-AceEquipEngine"]
    @status_window.refresh
  end
  alias est_suikoden_rune_create_slot_window create_slot_window  
  def create_slot_window
    est_suikoden_rune_create_slot_window
    wx = @slot_window.x
    wy = @slot_window.y
    ww = @slot_window.width
    @slot_window.dispose
    @slot_window = Window_RuneSlot.new(wx, wy, ww)
    @slot_window.viewport = @viewport
    @slot_window.help_window = @help_window
    @slot_window.status_window = @status_window
    @slot_window.actor = @actor
    @slot_window.set_handler(:cancel,   method(:on_slot_cancel))
  end
  alias est_suikoden_rune_create_item_window create_item_window
  def create_item_window
    est_suikoden_rune_create_item_window
    wx = @item_window.x
    wy = @item_window.y
    ww = @item_window.width
    wh = @item_window.height
    @item_window.dispose
    @item_window = Window_RuneItem.new(wx, wy, ww, wh)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.status_window = @status_window
    @item_window.actor = @actor
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @slot_window.item_window = @item_window
    @item_window.hide if $imported["YEA-AceEquipEngine"]
    create_rune_skill_window
    @item_window.rune_skill_window = @rune_skill_window
  end
  def create_rune_skill_window
    if $imported["YEA-AceEquipEngine"]
    wx = @actor_window.x
    wy = @actor_window.y
    ww = @actor_window.width
    wh = @actor_window.height
    @rune_skill_window = Window_RuneSkill.new(wx, wy, ww, wh)
    else
    wx = eval("#{ESTRIOLE::RUNE_SKILL_LIST_SETTING[:overlap_window]}.x")
    wy = eval("#{ESTRIOLE::RUNE_SKILL_LIST_SETTING[:overlap_window]}.y")
    ww = eval("#{ESTRIOLE::RUNE_SKILL_LIST_SETTING[:overlap_window]}.width")
    wh = eval("#{ESTRIOLE::RUNE_SKILL_LIST_SETTING[:overlap_window]}.height")
    @rune_skill_window = Window_RuneSkill.new(wx, wy, ww, wh)
    end
    @rune_skill_window.viewport = @viewport
    @rune_skill_window.item = nil
  end
  alias est_suikoden_rune_on_item_ok on_item_ok
  def on_item_ok
    Sound.play_equip
    @actor.change_rune(@slot_window.index, @item_window.item)
    @slot_window.activate
    @slot_window.refresh
    @item_window.unselect
    @item_window.refresh
    @actor_window.refresh if @actor_window
    @item_window.hide if $imported["YEA-AceEquipEngine"]
    @rune_skill_window.hide
    @slot_window.show
    overlap_rune_skill_window.show if overlap_rune_skill_window
  end
  alias on_item_cancel_switch_window on_item_cancel
  def on_item_cancel
    on_item_cancel_switch_window
    @rune_skill_window.hide
    overlap_rune_skill_window.show if overlap_rune_skill_window
  end  
end

#scene rune but with cost....
class Scene_RuneShop < Scene_Rune  
  def start
    super
    create_gold_and_cost_window
  end    
  def create_gold_and_cost_window
    @gold_window = Window_RuneGold.new
    @cost_window = Window_RuneCost.new
    @item_window.cost_window = @cost_window
    @slot_window.cost_window = @cost_window
    if $imported["YEA-AceEquipEngine"] == true
    @gold_window.width = @command_window.width
    @gold_window.height = @command_window.height/2
    @gold_window.x = @command_window.x
    @gold_window.z = @help_window.z + 100
    @gold_window.y = @command_window.y
    @cost_window.width = @command_window.width
    @cost_window.height = @command_window.height/2
    @cost_window.x = @gold_window.x
    @cost_window.z = @help_window.z + 100
    @cost_window.y = @gold_window.y + @gold_window.height
    else
    @gold_window.width = @command_window.width/2
    @gold_window.x = @command_window.x
    @gold_window.z = @help_window.z + 100
    @gold_window.y = @command_window.y
    @cost_window.width = @command_window.width/2
    @cost_window.x = @gold_window.x + @gold_window.width
    @cost_window.z = @help_window.z + 100
    @cost_window.y = @command_window.y
    end
    @gold_window.hide
    @cost_window.hide
  end

  def command_attach
    @gold_window.show
    @cost_window.show
    @command_window.hide
    @cost_window.mode = :attach
    super
  end
  def command_remove
    @gold_window.show
    @cost_window.show
    @command_window.hide
    @cost_window.mode = :remove
    super
  end
  def on_slot_ok_remove
    return not_enough_money(@slot_window) if $game_party.gold < @cost_window.value
    Sound.play_equip
    $game_party.lose_gold(@cost_window.value)
    @gold_window.refresh
    @actor.change_rune(@slot_window.index, nil)
    @slot_window.activate
    @slot_window.refresh
    @item_window.unselect
    @item_window.refresh
    @actor_window.refresh if $imported["YEA-AceEquipEngine"]
    @slot_window.show
    @item_window.hide if $imported["YEA-AceEquipEngine"]
    @status_window.refresh
  end
  def on_slot_cancel
    @gold_window.hide
    @cost_window.hide
    @command_window.show
    super
  end
  def on_item_ok
    return not_enough_money(@item_window) if $game_party.gold < @cost_window.value
    $game_party.lose_gold(@cost_window.value)
    @gold_window.refresh
    super
    @cost_window.set_item(nil)
  end
  def not_enough_money(window)
    Sound.play_buzzer
    window.activate
  end
  def on_item_cancel
    @cost_window.set_item(nil)
    super
  end  
end

class Game_Interpreter
  def actor_set_rune(actor_id,rune_slot,rune_id,swap_inventory = false)
    actor = $game_actors[actor_id] rescue nil
    rune = rune_id ? $data_armors[rune_id] : nil
    rune_slot = get_rune_slot_id(actor,rune_slot) if rune_slot.is_a?(String)
    return if !actor
    return if !rune_slot
    return if rune.etype_id != ESTRIOLE::RUNE_SLOT_ID
    actor.change_rune(rune_slot,rune) if swap_inventory
    actor.set_rune(rune_slot,rune) if !swap_inventory
  end
  def add_rune_slot(actor_id,rune_slot_name,pos = 0,allow_duplicate = true, rune_id = nil)
    actor = $game_actors[actor_id]
    rune = rune_id ? $data_armors[rune_id] : nil
    rune = nil if rune && rune.etype_id != ESTRIOLE::RUNE_SLOT_ID
    pos = 0 if !pos
    actor.add_rune_slot(rune_slot_name,pos-1,allow_duplicate,rune)
  end
  def rem_rune_slot(actor_id,slot_name,put_item_to_bag = true)
    actor = $game_actors[actor_id]
    actor.rem_rune_slot(slot_name,put_item_to_bag)
  end
  def actor_seal_rune(actor_id,rune_slot)
    actor = $game_actors[actor_id]
    return if !actor
    return if !rune_slot
    actor.event_unsealed_rune_slots
    actor.event_unsealed_rune_slots -= [rune_slot]
    actor.event_unsealed_rune_slots.uniq!
    actor.event_sealed_rune_slots
    actor.event_sealed_rune_slots += [rune_slot]
    actor.event_sealed_rune_slots.uniq!
  end
  def actor_unseal_rune(actor_id,rune_slot)
    actor = $game_actors[actor_id]
    return if !actor
    return if !rune_slot
    actor.event_unsealed_rune_slots
    actor.event_unsealed_rune_slots += [rune_slot]
    actor.event_unsealed_rune_slots.uniq!
    actor.event_sealed_rune_slots
    actor.event_sealed_rune_slots -= [rune_slot]
    actor.event_sealed_rune_slots.uniq!
  end
  def actor_reset_seal(actor_id, rune_slot = nil)
    actor = $game_actors[actor_id]
    return if !actor    
    actor.event_unsealed_rune_slots
    actor.event_sealed_rune_slots
    
    actor.event_unsealed_rune_slots = nil if !rune_slot
    actor.event_sealed_rune_slots = nil if !rune_slot
    
    return unless rune_slot
    actor.event_unsealed_rune_slots -= [rune_slot]
    actor.event_sealed_rune_slots -= [rune_slot]    
  end
  
  def get_rune_slot_id(actor,string)
    return actor.rune_slots_name.index(string)
  end
end

#####################   BATTLE RUNE PART   #####################################

class Window_ActorCommand < Window_Command
  alias est_suikoden_rune_make_command_list make_command_list
  def make_command_list
    est_suikoden_rune_make_command_list
    add_rune_command
  end
  def add_rune_command
    return if !@actor
    if $game_switches[ESTRIOLE::RUNE_BATTLE_SHOW_SWITCH] || ESTRIOLE::RUNE_BATTLE_SHOW_SWITCH <= 0
    pos = ESTRIOLE::RUNE_COMMAND_POSITION - 1
    pos = ESTRIOLE::RUNE_COMMAND_POSITION if ESTRIOLE::RUNE_COMMAND_POSITION < 1
    @list.insert(pos,{:name=>ESTRIOLE::RUNE_VOCAB, :symbol=>:rune, :enabled=>@actor.rune_enabled?, :ext=>"rune"})
    end
    #removing the stype added by the rune
    runes_added_stype = []
    @actor.runes.each do |rune|
    runes_added_stype.push(check_stype(rune)) if check_stype(rune)  
    end
    @list = @list.select{|command|!runes_added_stype.include?(command[:ext])}
  end
  def check_stype(item)
    return nil if !item
    features = item.features
    features.each do |ft|
      return stype = ft.data_id if ft.code == 41
    end
    return nil
  end  
end

class Window_RuneSlot_Battle < Window_RuneSlot
  def initialize(dx, dy, dw)
    super(dx, dy, dw)
    @actor = nil
    self.height = fitting_height(ESTRIOLE::RUNE_BATTLE_WINDOW[:slots])
    refresh
  end  
  def actor
    @actor
  end
  def enable?(index)
  return false if !@actor
  return false if !check_stype(@actor.runes[index])
  return true
  end
  def check_stype(item)
    return nil if !item
    features = item.features
    features.each do |ft|
      return stype = ft.data_id if ft.code == 41
    end
    return nil
  end  
end # Window_EquipSlot

class Window_ActorCommand < Window_Command
  def current_symbol=(symbol)
    current_data[:symbol] = symbol
  end
end

class Scene_Battle < Scene_Base
  alias est_suikoden_rune_create_all_windows create_all_windows
  def create_all_windows
    est_suikoden_rune_create_all_windows
    create_rune_list_window
  end

  def create_rune_list_window
    wx = ESTRIOLE::RUNE_BATTLE_WINDOW[:x]
    wy = ESTRIOLE::RUNE_BATTLE_WINDOW[:y]
    ww = ESTRIOLE::RUNE_BATTLE_WINDOW[:w]
    @rune_slot_window = Window_RuneSlot_Battle.new(wx, wy, ww)
    @rune_slot_window.set_handler(:ok,   method(:on_slot_ok))
    @rune_slot_window.set_handler(:cancel,   method(:on_slot_cancel))
    @rune_slot_window.hide
  end
  
  def on_slot_ok
    item = @rune_slot_window.item
    stype = check_stype(item)
    @rune_slot_window.activate
    return Sound.play_buzzer if !stype
    @rune_slot_window.hide
    @skill_window.actor = @rune_slot_window.actor
    @skill_window.stype_id = stype
    @from_rune = true
    @rune_slot_window.deactivate
    @skill_window.refresh
    @skill_window.show.activate.select(0)
  end

  def check_stype(item)
    features = item.features
    features.each do |ft|
      return stype = ft.data_id if ft.code == 41
    end
    return nil
  end  
    
  def on_slot_cancel
    @rune_slot_window.hide.deactivate
    @actor_command_window.activate
    @from_rune = false
  end
  
  alias est_suikoden_rune_create_actor_command_window create_actor_command_window
  def create_actor_command_window
    est_suikoden_rune_create_actor_command_window
    @actor_command_window.set_handler(:rune,  method(:command_rune))
  end
  
  def command_rune
    @rune_slot_window.actor = BattleManager.actor
    @rune_slot_window.show.activate.select(0)
  end
  
  alias est_suikoden_rune_on_skill_ok on_skill_ok
  def on_skill_ok
    est_suikoden_rune_on_skill_ok
  end
  
  alias est_suikoden_rune_on_skill_cancel on_skill_cancel
  def on_skill_cancel
    est_suikoden_rune_on_skill_cancel
    if @from_rune
    @actor_command_window.deactivate
    @rune_slot_window.show.activate
    @from_rune = false  
    end
  end
  
  alias est_suikoden_rune_on_enemy_ok on_enemy_ok
  def on_enemy_ok
    est_suikoden_rune_on_enemy_ok
    @rune_slot_window.deactivate
    @from_rune = false  
  end
  
  alias est_suikoden_rune_on_enemy_cancel on_enemy_cancel
  def on_enemy_cancel
    @actor_command_window.current_symbol = :skill if @actor_command_window.current_symbol == :rune
    est_suikoden_rune_on_enemy_cancel
    @actor_command_window.current_symbol = :rune if @from_rune
  end
  
  alias est_suikoden_rune_on_actor_ok on_actor_ok
  def on_actor_ok
    est_suikoden_rune_on_actor_ok
    @rune_slot_window.deactivate
    @from_rune = false      
  end
  alias est_suikoden_rune_on_actor_cancel on_actor_cancel
  def on_actor_cancel
    @actor_command_window.current_symbol = :skill if @actor_command_window.current_symbol == :rune
    est_suikoden_rune_on_actor_cancel    
    @actor_command_window.current_symbol = :rune if @from_rune
  end  
end

# Rune Menu Patch
module SceneManager
  class << self; alias est_rune_menu_hijack_call call; end  
  def self.call(scene_class)
    scene_class = Scene_MenuRune if scene_class == Scene_Skill && $game_system.rune_skill_mode
    est_rune_menu_hijack_call(scene_class)
  end
end

class Scene_MenuRune < Scene_Skill
  alias est_suikoden_rune_create_command_window create_command_window
  def create_command_window
    est_suikoden_rune_create_command_window
    wx = @command_window.x
    wy = @command_window.y
    ww = 250
    @command_window.dispose
    @command_window = Window_MenuRune.new(wx, wy, ww)
    @command_window.viewport = @viewport
    @command_window.help_window = @help_window
    @command_window.actor = @actor
    @command_window.set_handler(:skill,    method(:command_skill))
    @command_window.set_handler(:cancel,   method(:return_scene))
    @command_window.set_handler(:pagedown, method(:next_actor))
    @command_window.set_handler(:pageup,   method(:prev_actor))
  end  
  alias est_suikoden_rune_create_status_window create_status_window
  def create_status_window
    est_suikoden_rune_create_status_window
    wx = @status_window.x
    wy = @status_window.y
    ww = @status_window.width
    ww = Graphics.width - @command_window.width
    @status_window.dispose
    @status_window = Window_MenuRuneStatus.new(wx, wy, ww)#(@command_window.width, y)#Window_MenuRune.new(wx, wy, ww)
    @status_window.viewport = @viewport
    @status_window.actor = @actor    
  end  
end

class Window_MenuRuneStatus < Window_SkillStatus
  def initialize(x, y, w)
    @width = w
    super(x, y)
    @actor = nil
  end
  def window_width
    return @width
  end    
  def refresh
    contents.clear
    return unless @actor
    draw_actor_face(@actor, 0, 0)
    draw_actor_simple_status(@actor, 108, 0)
  end
  def draw_actor_simple_status(actor, x, y)
    draw_actor_name(actor, x, y)
    draw_actor_level(actor, contents_width-55, y + line_height * 1)
    draw_actor_icons(actor, 0, y + line_height * 3)
    draw_actor_class(actor, x , y + line_height * 1,contents_width-108-60)
    draw_actor_hp(actor, x, y + line_height * 2, contents_width-108)
    draw_actor_mp(actor, x, y + line_height * 3, contents_width-108)
  end
  def draw_actor_hp(actor, x, y, width = 160)
    draw_gauge(x, y, width, actor.hp_rate, hp_gauge_color1, hp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::hp_a)
    draw_current_and_max_values(x, y, width, actor.hp, actor.mhp,
      hp_color(actor), normal_color)
  end
  def draw_actor_mp(actor, x, y, width = 160)
    if $imported[:ve_mp_level]
    draw_actor_mp_level(actor, x, y, width)
    else
    draw_gauge(x, y, width, actor.mp_rate, mp_gauge_color1, mp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::mp_a)
    draw_current_and_max_values(x, y, width, actor.mp, actor.mmp,
      mp_color(actor), normal_color)
    end
  end
  
end

class Window_MenuRune < Window_SkillCommand
  def initialize(x, y, w)
    @width = w
    super(x, y)
    @actor = nil
  end
  def window_width
    return @width
  end    
  def make_command_list
    return unless @actor
    @actor.runes.each do |rune|
      name = rune ? rune.name : "None"
      stype = rune ? get_stype(rune) : 0
      add_command(name, :skill, true, stype)
    end
  end
  def rune
    @actor && @actor.runes && index >= 0 ? @actor.runes[index] : nil
  end
  def update_help
    @help_window.set_item(rune)
  end  
  def draw_item(index)
    runeslotname = @actor.rune_slots_name[index]
    rect = item_rect_for_text(index)
    change_color(system_color, command_enabled?(index))
    draw_text(rect.x, rect.y, ESTRIOLE::RUNE_SLOT_SPACE, line_height, runeslotname,3)
    item = @actor.runes[index]
    dx = rect.x + ESTRIOLE::RUNE_SLOT_SPACE
    dw = contents.width - dx - 24
    if item.nil?
      draw_nothing_equip(dx, rect.y, false, dw)
    else
      draw_item_name(item, dx, rect.y, command_enabled?(index), dw)
    end
  end

  def draw_nothing_equip(dx, dy, enabled, dw)
    change_color(normal_color, enabled)
    draw_icon(Icon.nothing_equip, dx, dy, enabled)
    text = "Nothing"
    draw_text(dx + 24, dy, dw - 24, line_height, text)
  end  
  
  def get_stype(item)
    features = item.features
    features.each do |ft|
      return ft.data_id if ft.code == 41
    end
    return 0
  end
end

#compatibility patch for falcao mana stones. he didn't use imported but
#the method is not used in other script so i guess it doesn't matter.
class Scene_Rune < Scene_Equip
  def update_manacalling
  end
  def update_enchant_help
  end
end

#compatibility patch for Nasty extra stats. you have to modify the window to
#show the extra stats yourself though. this patch only to make equipped runes
#can grant xstats
if chk_nastyextrastats = Z26::STATS rescue false
  class Game_Actor < Game_Battler
    alias est_nasty_compt_change_rune change_rune
    def change_rune(slot_id, item)
      last_item = @runes[slot_id]
      est_nasty_compt_change_rune(slot_id, item)
      z26variate_equip(item)
      z26variate_equip(last_item, false)
    end
  end
end

# yanfly menu engine auto add patch
class Scene_Menu < Scene_MenuBase
  alias est_on_personal_ok on_personal_ok
  def on_personal_ok
    case @command_window.current_symbol
    when :est_rune_attach 
      SceneManager.call(Scene_Rune)
    when :est_rune_skill 
      SceneManager.call(Scene_MenuRune)
    when :est_rune_shop 
      SceneManager.call(Scene_RuneShop)
    else
      est_on_personal_ok
    end
  end      
  def command_est_rune_skill
    command_personal
  end
  def command_est_rune_attach
    command_personal
  end
  def command_est_rune_shop
    command_personal
  end
end

# formar ATB/Stamina compatibility patch. make sure my script BELOW formar ATB/Stamina
if chk_formar_atb = CBS::MAX_STAMINA rescue false
  class Scene_Battle < Scene_Base
    def inputting?
      return @actor_command_window.active || @skill_window.active ||
        @item_window.active || @actor_window.active || @enemy_window.active ||
        @rune_slot_window.active
    end  
  end
end