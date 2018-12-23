#==============================================================================
#    Composite Graphics / Visual Equipment
#    Version: 1.0.1
#    Author: modern algebra (rmrk.net)
#    Date: January 13, 2013
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#
#    This script allows you to "compose" face and character graphics out of 
#   multiple graphics. This permits you to make it so that equipment worn by
#   a character can change the appearance of that actor's sprite and/or face.
#
#    Unlike my VX version, this script has a lot of new and improved features,
#   including, but not limited to: support for faces and not just character 
#   sprites; a more flexible configuration scheme; the ability to set one 
#   equipment to draw different graphics onto different actors (useful, for 
#   instance, if you want an equipment to show a different graphic on males 
#   than it would on females).
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#
#    Paste this script into its own slot in the Script Editor (F11), above Main 
#   but below Materials.
#
#    I hope that this script is fairly straightforward to set up. The 
#   configuration may look daunting at first, and I have obviously gone a bit
#   overboard on the volume of instructions I gave, but I trust that once you 
#   take a look you will find it to be quite easy and that really, all the 
#   codes are basically identical. I will start by going over how to setup 
#   actors, then move on to equipment, and then move on to events.
#``````````````````````````````````````````````````````````````````````````````
#  Actors:
#
#    The first thing to mention about actors is that the default character 
#   sprite is retained, so if the face or character sprite you setup there is
#   sufficient, you do not have to spend much time configuring actors. 
#
#    There are three codes you can use in an Actor's note box. Of these, \cc 
#   and \cf are identical as to how they are configured - the only difference
#   is that \cc is setting up a character sprite while \cf is setting up a 
#   face. For that reason, I will go over these codes together. The general
#   format for these codes are as follows (note that where there are numbers,
#   such as 0 or 255, then that simply means that is the default value of that
#   parameter - that is what you replace when you are setting it). It may seem
#   a little daunting at first, but note that only the filename is a required
#   parameter - the rest are just additional features.
#
#    \cc["filename", i0, h0, o255, z0, r0]
#    \cf["filename", i0, h0, o255, z0, r0]
#
#      "filename" : this should be the name of the character or face file you
#        want to load. You MUST put the quotation marks around it. Ie. if you
#        wanted to load a character graphic from Actor1, you would put "Actor1"
#      i0         : this is the index of the character or face you want in the
#        characterset or faceset. The indices correspond to a particular 
#        graphic in the characterset or faceset, in the following manner:
#                  0    1    2    3
#                  4    5    6    7
#        So if you want the third face in a faceset, you would put i2. Note
#        that you can exclude the i and just put 2.
#       h0        : this allows you to change the hue of a character or face
#         graphic you select. It can be anything between 0 and 360. Ie. h65 
#         would change the hue by 65 degrees.
#       o255      : this allows you to change the transparency of the character
#         or face graphic selected. 255 is fully opaque, while 0 is fully 
#         transparent. Ie. o128 would add the face graphic but make it half
#         see-through.
#       z0        : this determines the order in which each of the graphics in
#         a composite set are drawn. Those with lower z values are drawn before
#         ones with higher z values. So, if you want to make sure that the hair
#         is drawn over the skin, you need to set it so that the z value is 
#         higher. This can also be negative. Example: if you have four graphics
#         on an actor, one with z-2, one with z2, one with z0, and one with z4,
#         then the z-2 will be drawn first, then the z0, then the z2, and then 
#         the z4.
#       r0        : The R-code is a way of setting up graphics that are 
#         replaced if one with a greater r-code is applied. It is useful for
#         instance, if you want your actor to normally have a full head of hair,
#         but want the hair to be removed if an actor is wearing a helmet. In
#         that case, all you need to do is make sure they have the same r-code.
#         Graphics with r-code of 0 all show up and are not replaced.
#
#   There are a lot of options here, but I note that you only need to fill in
#  the filename and the rest of the parameters will default to the value above.
#  In other words, if you want the hue to be 0, opacity to be 255, and R-code
#  to to be 0, then you could exclude them all together and just specify the 
#  filename, index, and z value. Additionally, I should note that the default
#  graphic of an actor you set through the normal way has only the filename and
#  index set - the rest of the values are all default.
#
#    EXAMPLES:
#      \cc["Actor1", 2]
#        This will set it so that the third character graphic in the "Actor1"
#       character set is drawn onto the character. Since no other values are 
#       set, they default to h0, o255, z0, r0.
#      \cf["BackHair1", 3, z-1, h105, r1]
#        This will set it so that the fourth face graphic in the "BackHair1" 
#       faceset will have its hue changed by 105 degrees and then drawn onto 
#       the actor's face graphic. Since it's z is -1, it will be drawn below 
#       anything with a higher z value, including the default face. It's r-code 
#       is 1, so if the actor equips anything else that has an r-code of 1, 
#       this graphic will not show up at all. Since the opacity is not set, it 
#       defaults to 255.
#
#    There is only one further setting you can configure in the Actor notebox, 
#   and it will probably make a little more sense once we look at equipment, 
#   but it is the following:
#
#      \ct[x, y, ..., z]
#
#    where x, y, and z are just a series of integers. What this feature does is
#   set this actor's composite types, which will let you make equipments that 
#   draw different graphics depending on which actor is equipping the item. As
#   I mentioned, this will become clearer once we look at equipment. Note that
#   type 0 is automatically applied to all actors, and will be drawn on all
#   actors.
#
#    EXAMPLES:
#      \ct[2, 5]
#        This actor has composite sets 2 and 5, so any equipment graphics of
#       those types will be drawn on this actor.
#``````````````````````````````````````````````````````````````````````````````
#  Weapons & Armor:
#  
#    The codes for equipment are, in almost every respect, the same as that for
#   actors. The only difference is that you have the option to set "type" for
#   each graphic, in which case that graphic will only be drawn on an actor
#   equipping this weapon or armor if that actor has the correct type. To set 
#   this, you use this code:
#
#      \cc0["filename", i0, h0, o255, z0, r0]
#      \cf0["filename", i0, h0, o255, z0, r0]
#
#    As you can see, the stuff inside the square brackets is exactly the same 
#   as for actors. The difference lies in the number you place which lies 
#   directly before the square brackets. It is optional - if you do not place
#   a number there at all (or if you put 0 there) then it will apply to every
#   actor who equips the weapon or armor. However, if you put any integer above
#   0, then it will only apply to actors who have that ID listed in their \ct[] 
#   code.
#
#  EXAMPLE:
#    \cf["Helmet1", 2, z1, r1]
#      Any actor who equips this item will have the 3rd graphic in the 
#     "Helmet1" faceset drawn oon their face. If that actor has as one of its 
#     base graphics something with an r-code of 1, then that will be erased and
#     only the Helmet will show up.
#    \cc4["Actor1", 5]
#      The 6th character in the "Actor1" characterset will be drawn onto an 
#     an actor when he or she equips this item, but only if 4 is in that 
#     actor's \ct[] code.
#``````````````````````````````````````````````````````````````````````````````
#  Events:
#
#    You can also set up events to use composite characters, though not faces. 
#   To do so, you need to create a comment at the very top of a new page (must 
#   be the first line in the page), and in that comment you can use the exact 
#   same character codes as you can for actors:
#
#      \cc["filename", i0, h0, o255, z0, r0]
#
#    It is the exact same as with Actors. Additionally, you can use the 
#   following codes:
#      \cc[a1]  - This allows you to set an event to the composite character of
#        the actor with the specified ID. All you do is replace the 1 with the 
#        ID of the actor you want, so \cc[a5], for example, would make it so 
#        this event looked exactly like Actor 5, including equipment.
#      \cc[p1]  - This is similar, except the index you give corresponds 
#        instead to the actor in that position in the party. It starts at one, 
#        so \cc[p1] would show the party leader, \cc[p2] the second member in 
#        the party, etc.
#      \cc[w1]  - This will show the graphic you set for the weapon with that 
#        ID. So, for instance, \cc[w8] would apply the composite graphic of the 
#        weapon with ID 8 to the event.
#      \cc[ar1] - This will show the graphic you set for the armor with that 
#        ID. So, for instance, \cc[ar3] would apply the composite graphic of the
#        armor with ID 3 to the event.
#
#    Given that you can apply weapon and armor character graphics to an event,
#   you can also use the \ct[] codes from Actor here if you are using that 
#   feature.
#``````````````````````````````````````````````````````````````````````````````
#  Messages:
#
#    This script introduces two new codes which can be used in messages to show
#   actor faces, since otherwise you would be unable to show composite faces in
#   messages. The codes are:
#
#      \af[x] - this will show the face of the actor with ID x
#      \pf[x] - this will show the face of the party member in xth place. It 
#              starts at 1, so \pf[1] would show the face of the party leader,
#              \pf[2] would show the second member's face, etc.
#``````````````````````````````````````````````````````````````````````````````
#  Adding & Removing Composite Graphics:
#
#    Firstly, I will note that the regular event command of Change Actor 
#   Graphic does work, but it will only change the basic sprite - it will not 
#   remove any of the composite graphics you set up through the notebox.
#
#    To add or remove composite graphics from events, you use the following
#   code in a comment (NOT a script call!), wherever you want it to happen in
#   the sequence of events:
#
#     \add_e1_cc["filename", i0, h0, o255, z0, r0]
#     \remove_e1_cc["filename", i0, h0, o255, z0, r0]
#
#    As you can see, the arguments ("filename", etc.) are all identical to 
#   those with which you should now be familiar. The biggest difference is that
#   you need to put remove_e1 or add_e1 before that stuff. Note, the 1 after e
#   is the ID of the event. So, it can be any integer and the graphic will be
#   added to or removed from the event with that ID. If you don't provide any
#   ID, then it will go to the event from which it is called.
#
#    It is important to note that when you use a remove code, you do not need 
#   to specify every aspect of the code - what the script will do is simply get
#   rid of every graphic that shares the parameters you do set in. So all you
#   need to do is be specific enough with the arguments that you don't 
#   accidentally delete more than you want to delete.
#      
#    The codes for actors are similar:
#
#     \add_a1_cc["filename", i0, h0, o255, z0, r0]
#     \remove_a1_cc["filename", i0, h0, o255, z0, r0]
#     \add_a1_cf["filename", i0, h0, o255, z0, r0]
#     \remove_a1_cf["filename", i0, h0, o255, z0, r0]
#
#   Again, replace the 1 after the a with the ID of the actor whose composite
#   graphic you want to change.
#
#    Finally, you can also use the commands:
#
#     \add_p1_cc["filename", i0, h0, o255, z0, r0]
#     \remove_p1_cc["filename", i0, h0, o255, z0, r0]
#     \add_p1_cf["filename", i0, h0, o255, z0, r0]
#     \remove_p1_cf["filename", i0, h0, o255, z0, r0]
#
#    That will change the composite graphic selected for the party member in
#   that order. So, p1 would be the leader of the party, p2 the second actor 
#   in the party, etc...
#==============================================================================

$imported = {} unless $imported
$imported[:MA_CompositeGraphics] = true

#==============================================================================
# *** RPG
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new module - MACGVE_Data_CompositeGraphic, mixed in with Actor & EquipItem
#    modified class - Actor
#==============================================================================

module RPG
  #============================================================================
  # *** MACGVE_Data_CompositeGraphic
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  This module holds a method to retrieve composite graphics. It is to be 
  # mixed in with the relevant data classes
  #============================================================================

  module MACGVE_Data_CompositeGraphic
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Composite Character and Composite Face methods - lazy instantiation
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    [:character, :face].each { |method|
      define_method(:"macgve_composite_#{method}") do |*args|
        id, = *args
        # Define @macgve_composite_ if undefined 
        if !instance_variable_defined?(:"@macgve_composite_#{method}")
          instance_variable_set(:"@macgve_composite_#{method}", {})
        end
        if !instance_variable_get(:"@macgve_composite_#{method}")[id]
          instance_variable_get(:"@macgve_composite_#{method}")[id] = []
          idtos = id == 0 ? "0?" : id.to_s
          note.scan(/\\C#{method.to_s[0,1] + idtos}\[(.+?)\]/im) { |str| 
            str[0].gsub!(/[\r\n]/, "")
            cg = MACGVE_Data_CompositeGraphic.interpret_composite_graphic_string(str[0])
            instance_variable_get(:"@macgve_composite_#{method}")[id] << cg
          }
        end
        instance_variable_get(:"@macgve_composite_#{method}")[id]
      end
    }
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Interpret Composite Graphic String
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def self.interpret_composite_graphic_string(string, cg = MA_Composite_Graphic.new("", 0, 0, 255, 0, 0))
      if cg.is_a?(Hash)
        string.sub!(/["'](.+)["']/) { cg[:filename] = $1;    "" } # Filename: ""
        string.sub!(/[Zz](-?\d+)/) { cg[:z] = $1.to_i;       "" } # Z:         0
        string.sub!(/[Hh](\d+)/)   { cg[:hue] = $1.to_i;     "" } # Hue:       0
        string.sub!(/[Oo](\d+)/)   { cg[:opacity] = $1.to_i; "" } # Opacity: 255
        string.sub!(/[Rr](\d+)/)   { cg[:rcode] = $1.to_i;   "" } # R-Code:    0
        string.sub!(/[Ii]?(\d+)/)  { cg[:index] = $1.to_i;   "" } # Index:     0
      elsif cg.is_a?(MA_Composite_Graphic)
        string.sub!(/["'](.+)["']/) { cg.filename = $1;     "" }  # Filename: ""
        string.sub!(/[Zz](-?\d+)/)  { cg.z = $1.to_i;       "" }  # Z:         0
        string.sub!(/[Hh](\d+)/)    { cg.hue = $1.to_i;     "" }  # Hue:       0
        string.sub!(/[Oo](\d+)/)    { cg.opacity = $1.to_i; "" }  # Opacity: 255
        string.sub!(/[Rr](\d+)/)    { cg.rcode = $1.to_i;   "" }  # R-Code:    0
        string.sub!(/[Ii]?(\d+)/)   { cg.index = $1.to_i;   "" }  # Index:     0
      end
      cg
    end
  end
  
  #============================================================================
  # ** Actor, EquipItem
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #  Summary of Changes:
  #    MACGVE_Data_CompositeGraphic included in both classes
  #    new method in Actor - macgve_composite_type
  #============================================================================
  
  class Actor
    include(MACGVE_Data_CompositeGraphic)
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Composite Type
    #````````````````````````````````````````````````````````````````````````
    #  This is a type set to an actor - mostly used to distinguish between
    # visual equipment assigned to particular genders
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def macgve_composite_types
      if !@macgve_composite_types
        @macgve_composite_types = [0]
        if note[/\\CT\[(.+)\]/i]
          match = $1
          match.scan(/\d+/).each { |id| @macgve_composite_types << id.to_i }
        end
        @macgve_composite_types.compact!
      end
      @macgve_composite_types
    end
  end
  
  EquipItem.send(:include, MACGVE_Data_CompositeGraphic)
end

#==============================================================================
# *** Cache
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new constant - MACGVE_PRESERVED_CHARACTERS
#    new methods - self.macgve_composite_graphic_name; self.make_unique_name;
#      self.macgve_create_composite_graphic; self.macgve_src_rect;
#      self.macgve_get_individual_graphic; self.macgve_get_key; 
#      self.macgve_get_path; self.macgve_tidy_cg_array
#    aliased method - clear; load_bitmap
#==============================================================================

module Cache
  class << self
    alias macgve_clearcach_2jh5 clear
    alias macgve_lodbmp_3nj6 load_bitmap
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Clear Cache
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.clear(*args, &block)
    @macgve_name_cache ||= { face: {}, character: {} }
    @macgve_name_cache.clear
    @macgve_unique_name_id ||= 0
    macgve_clearcach_2jh5(*args, &block)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Load Bitmap
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.load_bitmap(folder_name, filename, *args)
    path = folder_name + filename
    if @cache && @cache[path] && @cache[path].disposed? && filename[0, 8] == "$macgve_"
      retrieved_ary = macgve_cgary_from_name(filename)
      recache_cg_from_key(*retrieved_ary) if retrieved_ary
    end
    macgve_lodbmp_3nj6(folder_name, filename, *args) # Call original method
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Composite Graphic
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.macgve_composite_graphic_name(type, composite_graphics)
    cg_array = macgve_tidy_cg_array(composite_graphics)
    return "" if cg_array.empty?
    key = macgve_get_key(cg_array)
    path = macgve_get_path(type)
    @macgve_name_cache ||= { face: {}, character: {} }
     # If no graphic for this cached
    if !@macgve_name_cache[type].has_key?(key) || 
        !include?(path + @macgve_name_cache[type][key])
      name = macgve_make_unique_name(cg_array)
      # Create new graphic and cache it
      @cache[path + name] = macgve_create_composite_graphic(type, cg_array)
      @macgve_name_cache[type][key] = name
    end
    @macgve_name_cache[type][key]    # Return cached graphic
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Tidy Composite Graphic Array
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.macgve_tidy_cg_array(cg_array)
    cg_array = cg_array.select {|cg| cg.is_a?(MA_Composite_Graphic) && !cg.filename.empty? }
    # Delete subordinate R-Codes - preserve latest of each type
    rcodes = cg_array.collect { |cg| cg.rcode }
    cg_array.delete_if { |cg| rcodes.shift != 0 && rcodes.include?(cg.rcode) }
    cg_array.sort! {|a, b| a.z <=> b.z }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Key
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.macgve_get_key(cg_array)
    cg_array.collect {|cg| Array(cg)[0, 4] }.flatten
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Path
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.macgve_get_path(type)
    type == :character ? "Graphics/Characters/" : "Graphics/Faces/"
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Make Unique Name
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.macgve_make_unique_name(cg_array = [])
    @macgve_unique_name_id ||= 0
    @macgve_unique_name_id += 1
    #  Create a mostly garbage name to avoid accidental overwrite
    char_ary = Array(0..9).collect {|i| i.to_s } + Array("a".."z") + Array("A".."Z")
    rand_s = ""
    24.times do rand_s += char_ary.sample end
    result = "$macgve_#{rand_s}_#{@macgve_unique_name_id}"
    result.insert(0, '!') if cg_array.any? {|cg| cg.filename[/^!/] != nil }
    result
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Create Composite Graphic
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.macgve_create_composite_graphic(type, cg_array)
    bmp_array = cg_array.collect {|cg| macgve_get_individual_graphic(type, cg) }
    w = bmp_array.max_by { |bmp| bmp.width }.width
    h = bmp_array.max_by { |bmp| bmp.height }.height
    bitmap = Bitmap.new(w, h)
    bmp_array.each { |bmp| bitmap.blt((bitmap.width - bmp.width) / 2, 
      bitmap.height - bmp.height, bmp, bmp.rect) }
    bitmap # Return bitmap
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Collect Individual Graphics
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.macgve_get_individual_graphic(type, cg)
    bmp = send(type, cg.filename) # Get graphic from file
    src_rect = macgve_src_rect(type, bmp, cg)
    bitmap = Bitmap.new(src_rect.width, src_rect.height)
    bitmap.blt(0, 0, bmp, src_rect, cg.opacity)
    bitmap.hue_change(cg.hue) if cg.hue != 0
    bitmap
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get Source Rectangle
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.macgve_src_rect(type, bmp, cg)
    if type == :face || type == :character
      sign = cg.filename[/^[\!\$]./]
      if sign && sign.include?('$')
        w, h = bmp.width, bmp.height
      else
        w, h = bmp.width / 4, bmp.height / 2
      end
    else
      w, h = bmp.width, bmp.height # Full graphic if unrecognized type
    end
    Rect.new((cg.index % 4) * w, (cg.index / 4) * h, w, h)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get CG Array from Name
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.macgve_cgary_from_name(name)
    @macgve_name_cache.keys.each { |key|
      @macgve_name_cache[key].each_pair { |cg_key, cg_name|
        return [key, name, cg_key] if cg_name == name } }
    false
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Recache CG from Key
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.recache_cg_from_key(type, name, key)
    return [] if !key || key.empty?
    cg_array = []
    for i in 0...(key.size / 4)
      cg_array.push(MA_Composite_Graphic.new(*(key.slice!(0, 4) + [i, 0])))
    end
    @cache[macgve_get_path(type) + name] = macgve_create_composite_graphic(type, cg_array)
    @macgve_name_cache ||= { face: {}, character: {} }
    @macgve_name_cache[type][key] = name
  end
end

#==============================================================================
# *** DataManager
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - extract_save_contents; make_save_header; load_header
#==============================================================================

module DataManager
  class << self
    alias macgve_extractsave_2wm5 extract_save_contents
    alias macgve_savehedr_2df6 make_save_header
    alias macgve_ldheadr_6hk8 load_header
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Extract Save Contents
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.extract_save_contents(contents, *args, &block)
    macgve_extractsave_2wm5(contents, *args, &block) # Call Original Method
    # Initialize new data for actors if old save file
    for i in 1...$data_actors.size
      # If actor has been initialized in this save file but data not setup
      if $game_actors.macgve_actor_init?(i) && !$game_actors[i].composite_equip_types
        $game_actors[i].macgve_initialize_composite_graphics
        $game_actors[i].macgve_extend_equips_to_refresh
      end
    end
    $game_player.refresh
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Make Save Header
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.make_save_header(*args, &block)
    result = macgve_savehedr_2df6(*args, &block)
    result[:cache_cgs] = []
    #  Cycle through all values of the header (while :characters holds the
    # characters by default, this is intended to check for the possibility 
    # that another script adds it under a different key - :face, for instance
    result.values.flatten.each { |el|
      if el.is_a?(String)
        r = Cache.macgve_cgary_from_name(el)
        result[:cache_cgs].push(r) if r 
      end
    }
    result
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Load Header
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.load_header(*args, &block)
    result = macgve_ldheadr_6hk8(*args, &block) # Call Original Method
    if result && result[:cache_cgs]
      result[:cache_cgs].each { |type, name, cg_key|
        cg_array = Cache.recache_cg_from_key(type, name, cg_key)
      }
    end
    result
  end
end

#==============================================================================
# *** MACGVE_BaseItem_Refresh
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This module is intended to be mixed in with instances of Game_BaseItem that
# handle equipment, and it refreshes the player whenever equipment changes
#==============================================================================

module MACGVE_BaseItem_Refresh
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Object
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def object=(*args, &block)
    result = super(*args, &block)
    $game_player.refresh
    result
  end
end

#==============================================================================
# ** Composite_Graphic
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  This Struct holds data for composite graphics
#==============================================================================

class MA_Composite_Graphic < Struct.new(:filename, :index, :hue, :opacity, :z, :rcode)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Equality?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def eql?(other)
    # Don't check for z or rcode equality
    other.is_a?(MA_Composite_Graphic) && @filename == other.filename &&
      @index == other.index && @hue == other.hue && @opacity == other.opacity 
  end
  alias == eql?
end

#==============================================================================
# ** Game Actor
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new public instance variables - composite_equip_types; 
#      base_composite_characte; base_composite_face;
#    aliased methods - init_graphics; init_equips; character_name, 
#      character_index, face_name, face_index
#    new methods - macgve_composite_character; macgve_composite_face;
#      macgve_add_cg; macgve_remove_cg; 
#      macgve_initialize_composite_graphics
#==============================================================================

class Game_Actor
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :composite_equip_types
  attr_accessor :base_composite_character
  attr_accessor :base_composite_face
  [:character, :face].each { |method|
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Compose Character/Face
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    define_method(:"macgve_composite_#{method}") do |*args|
      # Add all composite graphics from actor, equipments and states
      basic = MA_Composite_Graphic.new(instance_variable_get(:"@#{method}_name"),
        instance_variable_get("@#{method}_index"), 0, 255, 0, 0)
      result = [basic] + instance_variable_get(:"@base_composite_#{method}")
      equips.compact.each { |equip| 
        composite_equip_types.each { |t| 
          result += equip.send(:"macgve_composite_#{method}", t) } }
      result
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Character/Face Name
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias_method(:"macgve_#{method}nm_2qa5", :"#{method}_name")
    define_method(:"#{method}_name") do |*args|
      if send(:"macgve_composite_#{method}").size > 1
        Cache.macgve_composite_graphic_name(method, send(:"macgve_composite_#{method}"))
      else
        send(:"macgve_#{method}nm_2qa5", *args)
      end
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * Character/Face Index
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias_method(:"macgve_#{method}ix_3fm9", :"#{method}_index")
    define_method(:"#{method}_index") do |*args|
      send(:"macgve_composite_#{method}").size > 1 ? 0 : 
        send(:"macgve_#{method}ix_3fm9", *args)
    end
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Initialize Graphics
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macgve_initlzgraph_3dk4 init_graphics
  def init_graphics(*args, &block)
    macgve_initialize_composite_graphics
    macgve_initlzgraph_3dk4(*args, &block)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Initialize Composite Graphics
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macgve_initialize_composite_graphics
    @composite_equip_types = actor.macgve_composite_types
    @base_composite_character = actor.macgve_composite_character
    @base_composite_face = actor.macgve_composite_face
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Initialize Equips
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macgve_initequpment_2gu7 init_equips
  def init_equips(*args, &block)
    macgve_initequpment_2gu7(*args, &block)
    macgve_extend_equips_to_refresh
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Extend Equips to Refresh
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macgve_extend_equips_to_refresh
    @equips.each { |eqp| eqp.send(:extend, MACGVE_BaseItem_Refresh) }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Add Composite Character/Face
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macgve_add_cg(type, arg = {})
    case arg
    when String then cg = RPG::MACGVE_Data_CompositeGraphic.interpret_composite_graphic_string(arg)
    when Hash
      cg = MA_Composite_Graphic.new("", 0, 0, 255, 0, 0)
      arg.each_pair(key, value) { cg.send(:"#{key}=", value) }
    when MA_Composite_Graphic then cg = arg
    else
      return
    end
    send(:"base_composite_#{type}") << cg
    $game_player.refresh
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Remove Composite Character/Face
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macgve_remove_cg(type, hash = {})
    hash = RPG::MACGVE_Data_CompositeGraphic.interpret_composite_graphic_string(hash, {}) if hash.is_a?(String) 
    send(:"base_composite_#{type}").delete_if { |cg|
      return_value = true
      # If any element is not equal to the CG, then return false
      hash.each_pair { |key, value| 
        unless cg.send(key) == value
          return_value = false
          break
        end
      }
      return_value
    }
    $game_player.refresh
  end
end

#==============================================================================
# ** Game Actors
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    new method - macgve_actor_init?
#==============================================================================

class Game_Actors
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Actor Initialized?
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macgve_actor_init?(id)
    @data[id] != nil
  end
end

#==============================================================================
# ** Game Event
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - clear_page_settings; setup_page_settings
#    overwritten (super)methods - character_name; character_index
#    new method - macgve_setup_composite_characters; 
#      interpret_composite_graphic_string
#==============================================================================

class Game_Event
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Public Instance Variables
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :composite_equip_types
  attr_accessor :base_composite_character
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Clear Page Settings
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macgve_clrpagesets_2rd8 clear_page_settings
  def clear_page_settings(*args, &block)
    @macgve_character_name = ""
    macgve_clrpagesets_2rd8(*args, &block) # Call Original Method
    @base_composite_characters = []
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Page Settings
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macgve_setppagestngs_4qm3 setup_page_settings
  def setup_page_settings(*args, &block)
    macgve_setppagestngs_4qm3(*args, &block) # Call Original Method
    macgve_setup_composite_characters
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Setup Composite Characters
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macgve_setup_composite_characters
    # Collect Comments
    comment = maccve_get_first_comment
    set_composite_equip_types(comment)
    set_base_composite_characters(comment)
    @macgve_character_name = Cache.macgve_composite_graphic_name(:character, macgve_composite_characters)
    # If no original graphic
    if @page.graphic.character_name.empty? && !@base_composite_characters.empty?
      @pattern, @original_pattern = 1, 1
      @tile_id = 0
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Get First Comment
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def maccve_get_first_comment
    comment = ""
    i = 0
    while !@list[i].nil? && (@list[i].code == 108 || @list[i].code == 408)
      comment += @list[i].parameters[0].dup
      i += 1
    end
    comment
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Composite Equip Types
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_composite_equip_types(comment = "")
    @composite_equip_types = [0]
    unless comment[/\\CT\[(.+?)\]/i].nil?
      match = $1
      match.scan(/\d+/).each { |id| @composite_equip_types << id.to_i }
    end
    @composite_equip_types
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Set Base Composite Characters
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_base_composite_characters(comment = "")
    @base_composite_characters = []
    comment.scan(/\\CC\[(.+?)\]/i) { |str|
      composite_equip_types.each { |id| 
        @base_composite_characters += interpret_composite_graphic_string(str[0], id)
      }
    }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Interpret Composite Graphic String
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def interpret_composite_graphic_string(string, id = 0)
    string.gsub!(/([APW]|AR)(\d+)/i) { 
      object =  case $1.upcase
      when 'A'  then $game_actors[$2.to_i]            # Actor
      when 'P'  then $game_party.members[$2.to_i - 1] # Party Member
      when 'W'  then $data_weapons[$2.to_i]           # Weapon
      when 'AR' then $data_armors[$2.to_i]            # Armor
      end
      return *object.macgve_composite_character(id) unless object.nil?
      ""
    }
    [RPG::MACGVE_Data_CompositeGraphic.interpret_composite_graphic_string(string)]
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Composite Characters
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macgve_composite_characters
    # Add all composite graphics from actor, equipments and states
    result = [MA_Composite_Graphic.new(@character_name, @character_index, 0, 255, 0, 0)]
    result += @base_composite_characters if @base_composite_characters
    result
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Add Composite Character
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macgve_add_cc(string)
    @base_composite_characters ||= []
    @base_composite_characters.push(*interpret_composite_graphic_string(string))
    @macgve_character_name = Cache.macgve_composite_graphic_name(:character, macgve_composite_characters)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Remove Composite Character
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macgve_remove_cc(string)
    return unless @base_composite_characters
    hash = RPG::MACGVE_Data_CompositeGraphic.interpret_composite_graphic_string(string, {})
    @base_composite_characters.delete_if { |cg|
      return_value = true
      # If any element is not equal to the CG, then return false
      hash.each_pair { |key, value| 
        unless cg.send(key) == value
          return_value = false
          break
        end
      }
      return_value
    }
    @macgve_character_name = Cache.macgve_composite_graphic_name(:character, macgve_composite_characters)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Character Name/Index
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macgve_crctrname_4dk8 character_name
  def character_name
    if !@base_composite_characters.empty? # If not just the base sprite
      if @macgve_character_name.empty? || !Cache.include?("Graphics/Characters/" + @macgve_character_name)
        @macgve_character_name = Cache.macgve_composite_graphic_name(:character, macgve_composite_characters)
      end
      @macgve_character_name
    else # If no composite characters, just return the default.
      macgve_crctrname_4dk8
    end
  end
  alias macgve_charindx_2vd3 character_index
  def character_index
    !@base_composite_characters.empty? ? 0 : macgve_charindx_2vd3
  end
end

#==============================================================================
# ** Game Interpreter
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - command_108
#    new method - macgve_interpret_cg_comment
#    new methods - add_actor_cc; add_actor_cf; remove_actor_cc; remove_actor_cf 
#==============================================================================

class Game_Interpreter
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Collect Comment
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macgve_commnd108comments_1xh4 command_108
  def command_108(*args, &block)
    macgve_commnd108comments_1xh4(*args, &block) # Call Original Method
    macgve_interpret_cg_comment(@comments.join)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Interpret Composite Graphic Comment
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macgve_interpret_cg_comment(comment)
    comment.scan(/\\(add|remove)_([eap])(-?\d*)_c([cf])\[(.+?)\]/i) { |oper, char, id, type, args|
      case char.upcase
      when 'A' then actor = $game_actors[id.empty? ? 1 : id.to_i]
      when 'P' then actor = $game_party.members[id.empty? ? 0 : id.to_i - 1]
      when 'E' then id.to_i < 0 ? actor = $game_player.actor : event = get_character(id.to_i)
      end
      type = type.upcase == 'C' ? :character : :face
      actor.send(:"macgve_#{oper.downcase}_cg", type, args) unless actor.nil?
      event.send(:"macgve_#{oper.downcase}_cc", args) unless event.nil?
    }
  end
end

#==============================================================================
# ** Window_Base
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased method - draw_face
#==============================================================================

class Window_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Face
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias masff_drawfac_1wk7 draw_face
  def draw_face(face_name, face_index, *args, &block)
    if face_index == 0 && face_name[/^$/]
      ma_draw_single_face(face_name, *args, &block) # Draw single face
    else
      # Call Original Method
      masff_drawfac_1wk7(face_name, face_index, *args, &block) 
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Single Face
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  unless method_defined?(:ma_draw_single_face)
    def ma_draw_single_face(face_name, x, y, enabled = true)
      bmp = Cache.face(face_name)
      contents.blt(x, y, bmp, bmp.rect, enabled ? 255 : translucent_alpha)
    end
  end
end

#==============================================================================
# ** Window_Message
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased (super)method - new_page; process_escape_character
#    new method - macgve_new_page
#==============================================================================

class Window_Message
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * New Page
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if instance_methods(false).include?(:new_page)
    alias macgve_newpage_5di4 new_page
    def new_page(text, pos, *args, &block)
      result = macgve_new_page(text, pos, *args, &block)
      macgve_newpage_5di4(result, pos, *args, *block) # Call Original Method
    end
  else
    def new_page(text, pos, *args, &block)
      result = macgve_new_page(text, pos, *args, &block)
      super(result, pos, *args, *block) # Call Original Method
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Check First Code for Face
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def macgve_new_page(text, pos, *args, &block)
    result = text.dup
    # Remove AF or PF code and process it
    if result[/\A\e[AP]F\[\d+\]/i] != nil
      result.sub!(/\A\e([AP]F)/i, "")
      process_escape_character($1, result, pos)
    end
    return result
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Process Escape Character
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias macgve_procesccha_2gk1 process_escape_character
  def process_escape_character(code, text, *args, &block)
    if code.upcase[/([AP])F/] != nil
      type = ($1 == 'A')
      param = obtain_escape_param(text)
      actor = type ? $game_actors[param] : $game_party.members[param - 1]
      if actor
        # Change face to that of the chosen actor
        $game_message.face_name = actor.face_name
        $game_message.face_index = actor.face_index
      end
    else
      macgve_procesccha_2gk1(code, text, *args, &block) # Call Original Method
    end
  end
end