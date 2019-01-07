$imported = {} if $imported.nil?
$imported["EST - SIMPLE NOTETAGS"] = true
=begin

EST - SIMPLE NOTETAGS
v. 1.6

Author : Estriole
also credit:
Victor - for event comment as note code.

Version History
v. 1.0 - 2013-01-07 - finish the script
v. 1.1 - 2013-01-08 - fix the regexp to recognize text without ""
                    - add long_note_args method. 
v. 1.2 - 2013-01-08 - improve the regex so now can grab any notetags format
                      now can grab yanfly format, mr buble format, victor, etc
                      (i hope so). rewrite the introduction and how to use
                      to simplify things.
v. 1.3 - 2013-01-09 - change the method to module so we can include it in any
                      class as long as it have @note. to add it just add in the class:
                      
                        include ESTRIOLE::NOTETAGS_SYSTEM
                      
                      i already include the module in these following class:
                      RPG::BaseItem 
                      RPG::Map 
                      RPG::Tileset
                      RPG::Class::Learning 
                      since i think it's all the rpg class that have @note.
                      also add method in game map to make it able to access the @map
v. 1.4 - 2013-02-04 - fix some regexp to recognize more than 1 strings in one notetags
v. 1.5 - 2013-05-26 - fix some regexp to recognize '-' example: -1321, -asdr, ase-3
                      fix some regexp to recognize '.' example: 10.33, acd.331, 33.21a
                      also compatibility update for dynamic note script(if any).
                      also feature to grab event note (comment) (from victor code)
v. 1.6 - 2013-06-07 - fix regexp to use multi line mode.
                    - fix some regexp so can put array in note example: [1,2] it will saved as "1,2"
                      later you could do some eval to make it array again. ex:
                      note:
                      <test: [1,3],[11,9]>
                      then we grab it using note_args method
                      a = note_args("test")
                      now to transform all element in a to array. you could use collect.
                      a.collect!{|x| eval("[#{x}]")}
                    - fix some regexp so can put hash in note example: {1=>30,2=>2} it will saved as "1=>30,2=>2"
                      now to transform all element in a to hash the same method as array above just use different eval
                      a.collect!{|x| eval("{#{x}}")}

Introduction
this script basically works as notetags grabbers
Make your notetagging job for any database object easier (for scripter).
you can easily grab any notetags value using simple method. then use that
either in event script call / inside class

How to Use
now we can easily grab the notetags from any RPG database object such as:
RPG::Actor, RPG::Enemy, RPG::Class,
RPG::Item, RPG::Weapon, RPG::Armor, RPG::Skill, RPG::State
RPG::Map, RPG::Tileset, RPG::Class:Learning

basically every child class of RPG::BaseItem

this script give you two type of notetags grabber.
================================================================================

1) rpg_instance_object.note_args("notetags name")
example:
  -> Actor
     $game_actors[id].actor.note_args("notetags name")
     $game_party.members[slot_id].actor.note_args("notetags name")
  -> Enemy
     $game_troops.members[slot_id].enemy.note_args("notetags name")
  -> Class
     $data_classes[id].note_args("notetags name")
  -> Item, Weapon, Armor, Skill, State
     $data_items[id].note_args("notetags name")
     $data_weapons[id].note_args("notetags name")
     $data_armors[id].note_args("notetags name")
     $data_skills[id].note_args("notetags name")
     $data_states[id].note_args("notetags name")
  -> Map
     $game_map.map.note_args("notetags name")
  -> Tileset
     i don't know how to access it yet. if anyone know pm me :D
  -> Class::Learning
     i don't know how to access it yet. if anyone know pm me :D
  
this will grab notetags of this type:
<name: a b c d e f g h i ...>
or
<name: a, b, c, d, e, f, g, h, i,...>
or
combination of both (have coma or only spaces)

... means you can have as many as you want

it then will return array
[a,b,c,d,e,f,g,h,i,...]

every array member is in STRING format. so if you want to use it as integer
you need to use .to_i after grabbing array[index]
for true and false. it also become text. so you need to change it to boolean
yourself.

and if you want to have block text in your notetags you could put it inside ""
example:
<testnote: "King Maker" 10 true 322>
return array ["King Maker","10","true","322"]

and if all of your note value is integer and you're too lazy to use .to_i
you could change .note_args to .note_args_all_int
it will convert all array member to integer. (use collect method)
================================================================================

2) rpg_instance_object.long_note_args("notetags name")
example: just see number 1) above and change the method to 
.long_note_args("notetags name") instead.

this will grab notetags of this type:
<name>
key1: a b c d e f g h i ...
key2: a, b, c, d, e, f, g, h, i,...
key3: a b, c, d e f g h i ...
</name>

note: key3 is the combination with coma and just spaces.

it then will return 2 level array
[[key1,a,b,c,d,e,f,g,h,i,...],[key2,a,b,c,d,e,...],[key3,a,b,c,d,e,f,g,...]]

every level two array member is in STRING format. 
so if you want to use it as integer you need to use .to_i after grabbing it
for true and false. it also become text. so you need to change it to boolean
yourself.

and if you want to have block text in your notetags you could put it inside ""
example:
<testnote>
can have spaces: "Dragon Slayer" "yes", true, 123
w: 10 13, 33
</testnote>

will return array
[["can have spaces","Dragon Slayer","yes","true","123"],["w","10","13","33"]]

================================================================================
FOR GRABBING EVENT COMMENT:
game_event_object.note_args("notetags name")
game_event_object.long_note_args("notetags name")
it will grab note from that event object ACTIVE page comment
ex:
$game_map.events[1].note_args("event_size")
and in current map event 001 active page has comment:
<event_size: 10, 4, 33, "yeah baby">
it will return array
["10","4","33","yeah baby"]

================================================================================  
Author Note
This script is the way i tested myself on how much i've grown in notetagging and
regex in this past 6 month. i would like to see my limit.
and also learn to code efficiently (making as few line as possible)

Next patch maybe adding long_note_args_eval method.
for grabbing something like victor enemy action condition / some yanfly notetags...
which use eval method.

i don't know but i think this script will more suited named EST - NOTETAGS GRABBER
LOL...

=end
module ESTRIOLE

  NO_NOTETAGS_RETURN = nil
  # change above to whatever you want the function return when no note found
  # nil or [] is recommended
  
  module NOTETAGS_SYSTEM
   def note_args_all_int(str)
    return NO_NOTETAGS_RETURN if !note[/<#{str}:(.*)>/i]
    a = note[/<#{str}:(.*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    a.collect!{|x| x.to_i}
    return noteargs = a
   end

   def note_args(str)
    return NO_NOTETAGS_RETURN if !note[/<#{str}:(.*)>/im]
    a = note[/<#{str}:(.*)>/im].scan(/:(.*)/m).flatten[0].scan(/(?:"(.*?)"|\{(.*?)\}|\[(.*?)\]| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/m).flatten.compact
    return noteargs = a
   end

   def long_note_args(str)
    return NO_NOTETAGS_RETURN if !note[/<#{str}?>(?:[^<]|<[^\/])*<\/#{str}?>/i]
    a = note[/<#{str}?>(?:[^<]|<[^\/])*<\/#{str}?>/i].scan(/(?:!<#{str}?>|(.*)\r)/).flatten
    a.delete_at(0)
    noteargs = b = []
    a.each do |mem|
    b = mem.scan(/(?:(.*) :|(.*):|"(.*?)"| ([-\w.\w]+)|([-\w.\w]+),|,([-\w.\w]+))/).flatten.compact
    noteargs.push(b)
    end
    return noteargs
   end 

   def eval_long_note_args(str)
    return NO_NOTETAGS_RETURN if !note[/<#{str}?>(?:[^<]|<[^\/])*<\/#{str}?>/i]
    a = note[/<#{str}?>(?:[^<]|<[^\/])*<\/#{str}?>/i].scan(/(?:!<#{str}?>|(.*)\r)/)
    a.delete_at(0)    
    return noteargs = a.join("\r\n")     
   end
   
   def have_note?(str)
    return "<type x>" if note[/<#{str}:(.*)>/i]  
    return "<type> x </type>" if note[/<#{str}?>(?:[^<]|<[^\/])*<\/#{str}?>/i]
    return "<type>" if note[/<#{str}>/i]  
    return nil
   end
  end
end

class Game_Map
  attr_reader :map
end #new method to access @map

class RPG::BaseItem
  include ESTRIOLE::NOTETAGS_SYSTEM 
end

class RPG::Map
  include ESTRIOLE::NOTETAGS_SYSTEM
end

class RPG::Tileset
  include ESTRIOLE::NOTETAGS_SYSTEM
end

class RPG::Class::Learning
  include ESTRIOLE::NOTETAGS_SYSTEM
end
class Game_Event < Game_Character
  include ESTRIOLE::NOTETAGS_SYSTEM
#grabbed from victor basic module  
  def note
    return "" if !@page || !@page.list || @page.list.size <= 0
    comment_list = []
    @page.list.each do |item|
      next unless item && (item.code == 108 || item.code == 408)
      comment_list.push(item.parameters[0])
    end
    comment_list.join("\r\n")
  end  
end