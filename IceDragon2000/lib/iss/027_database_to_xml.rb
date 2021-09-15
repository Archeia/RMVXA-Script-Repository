#encoding:UTF-8
# ISS027 - Database to Xml
#==============================================================================#
# ** ISS - Database To Xml
#==============================================================================#
# ** Date Created  : 09/04/2011
# ** Date Modified : 09/05/2011
# ** Created By    : IceDragon
# ** For Game      : S.A.R.A
# ** ID            : 027
# ** Version       : 1.0
# ** Optional      : ISS000 - Core(2.1 or above)
#==============================================================================#
($imported ||= {})["ISS-DatabaseToXml"] = true
#==============================================================================#
# ** ISS::DatabaseToXml
#==============================================================================#
module ISS
  install_script(27, :system) if $simport.valid?('iss/core', '>= 1.9')
  module DatabaseToXml
    DATABASE_LOCATION = 'Data/Database'
    FileUtils.mkdir_p(DATABASE_LOCATION)

    def self.dump_database
      dump_data_object('ITEM',   'Items',      File.join(DATABASE_LOCATION, 'Items'))
      dump_data_object('SKILL',  'Skills',     File.join(DATABASE_LOCATION, 'Skills'))
      dump_data_object('ARMOR',  'Armors',     File.join(DATABASE_LOCATION, 'Armors'))
      dump_data_object('WEAPON', 'Weapons',    File.join(DATABASE_LOCATION, 'Weapons'))
      dump_data_object('STATE',  'States',     File.join(DATABASE_LOCATION, 'States'))
      dump_data_object('CLASS',  'Classes',    File.join(DATABASE_LOCATION, 'Classes'))
      dump_data_object('ACTOR',  'Actors',     File.join(DATABASE_LOCATION, 'Actors'))
      dump_data_object('ENEMY',  'Enemies',    File.join(DATABASE_LOCATION, 'Enemies'))
      dump_data_object('ANIM',   'Animations', File.join(DATABASE_LOCATION, 'Animations'))
    end

    def self.dump_data_object(prename, filename, outputfolder)
      Dir.mkdir(outputfolder ) if !FileTest.directory?( outputfolder)
      (i = load_data("Data/#{filename}.rvdata")).each { |o|
         next if o.nil?()
         File.open("#{outputfolder}/#{prename}#{"%03d"%o.id}.xml", "w+") { |f|
           f.puts(o.create_xml)
         }
      }
    end

    def self.indent_string(string, indent_amt)
      indent = "" ; indent_amt.times { indent += " " }
      lines = string.split(/[\r\n]/i)
      result = ""
      for i in 0...lines.size
        result += indent + lines[i]
        result += "\n" unless i == lines.size-1
      end
      return result
    end

    def self.parameter_table_to_string(table, kind, label, spf)
      result = ""
      for y in 1...table.ysize
        ans = %Q(#{sprintf(spf, table[kind, y])})
        result += %Q(<#{label} level="#{y}" value=#{ans}/>) + (y==table.ysize-1 ? "" : "\n")
      end
      return result
    end

    def self.actions_array_to_string(array)
      return array.inject("\n") { |r, a|
        r +
%Q(<action>
#{indent_string(a.create_xml, 2)}
</action>

) #+ (array.index(a)==array.size-1 ? "" : "\n")
      }
    end

    def self.array_to_string(array, spf)
      return array.inject("") { |r, i| r + %Q(sprintf(spf, i)) + (array.index(i)==array.size-1 ? "" : ",") }
    end

    def self.array_to_xmlstring(array, dataname, spf)
      return array.inject("") { |r, i| r + %Q(\n<#{dataname}=#{sprintf(spf, i)}/>) }
    end

    def self.learnings_array_to_string(array)
      return array.inject("") { |r, i| r + %Q(#{i.create_xml}) + (array.index(i)==array.size-1 ? "" : "\n") }
    end

    def self.rank_table_to_string(table, spf)
      result = ""
      for x in 1...table.xsize
        ans = %Q(#{sprintf(spf, table[x])})
        result += %Q(<#{x}=#{ans}/>) + (x==table.xsize-1 ? "" : "\n")
      end
      return result
    end

    def self.sting_each_line(string)
      string.split(/[\r\n]+/).each { |line| yield line }
    end

    def self.string_to_bool(string)
      case string
      when true                  ; return true
      when false                 ; return false
      when /(TRUE|YES|Y|T|ON)/i  ; return true
      when /(FALSE|NO|N|F|OFF)/i ; return false
      else                       ; return false
      end
    end

    def self.number_string_to_array(string)
      result = []
      case string
      when /("\d+"(?:\s*,\s*"\d+")*)/i
        $1.split(/\d+/).each { |i| result << i }
      when /(\d+(?:\s*,\s*\d+)*)/i
        $1.split(/\d+/).each { |i| result << i }
      end
      return result
    end

    def self.gen_xml_value(ele_name, value, spf)
      return "<#{ele_name}=#{sprintf(spf, value)} />"
      #return "<#{ele_name}>#{sprintf(spf, value)}</#{ele_name}>"
    end

  end
end

DBXML = ISS::DatabaseToXml

class RPG::Animation

  def create_xml()
    return %Q(
#{DBXML.gen_xml_value("id"             , @id             , "%s")}
#{DBXML.gen_xml_value("name"           , @name           , '"%s"')}
#{DBXML.gen_xml_value("animation1_name", @animation1_name, '"%s"')}
#{DBXML.gen_xml_value("animation1_hue" , @animation1_hue , "%s")}
#{DBXML.gen_xml_value("animation2_name", @animation2_name, '"%s"')}
#{DBXML.gen_xml_value("animation2_hue" , @animation2_hue , "%s")}
#{DBXML.gen_xml_value("position"       , @position       , "%s")}
#{DBXML.gen_xml_value("frame_max"      , @frame_max      , "%s")}

<frames>
#{DBXML.indent_string((@frames.inject("") { |r, s| r + s.create_xml(@frames.index(s)) }), 2)}
</frames>

<timings>
#{DBXML.indent_string((@timings.inject("") { |r, s| r + s.create_xml }), 2)}
</timings>
    )
  end

  class Frame

    def create_xml(frame_id)
      return %Q(
<frame id=#{frame_id}>
  <cell_max=#{@cell_max}/>

  <cells>
  #{DBXML.indent_string(cells_to_xml(), 4)}

  </cells>
</frame>
      )
    end

    def cells_to_xml()
      result = ""
      for i in 0...@cell_max
        next if @cell_data[i, 0] == -1
        #tx = %Q(
#<cell id=#{i}>
#  <pattern=#{@cell_data[i, 0]}/>
#  <x=#{@cell_data[i, 1]}/>
#  <y=#{@cell_data[i, 2]}/>
#  <zoom=#{@cell_data[i, 3]}/>
#  <angle=#{@cell_data[i, 4]}/>
#  <flip=#{@cell_data[i, 5]}/>
#  <opacity=#{@cell_data[i, 6]}/>
#  <blend=#{@cell_data[i, 7]}/>
#</cell>

#)
        tx = %Q(<cell id=#{i} pattern=#{@cell_data[i, 0]} x=#{@cell_data[i, 1]} y=#{@cell_data[i, 2]} zoom=#{@cell_data[i, 3]} angle=#{@cell_data[i, 4]} flip=#{@cell_data[i, 5]} opacity=#{@cell_data[i, 6]} blend=#{@cell_data[i, 7]}/>)
        result += tx
      end
      return result
    end

  end

  class Timing

    def create_xml()
      return %Q(
<timing frame=#{@frame}>
  <se name="#{@se.name}" volume=#{@se.volume} pitch=#{@se.pitch}/>
  <flash_scope=#{@flash_scope}/>
  <flash_color red=#{@flash_color.red.to_i} green=#{@flash_color.green.to_i} blue=#{@flash_color.blue.to_i} alpha=#{@flash_color.alpha.to_i}/>
  <flash duration=#{@flash_duration}/>
</timing>
      )
    end

  end

end

class RPG::BaseItem

  def create_xml()
    return %Q(
#{DBXML.gen_xml_value("id"             , @id             , "%s")}
#{DBXML.gen_xml_value("name"           , @name           , '"%s"')}
#{DBXML.gen_xml_value("icon_index"     , @icon_index     , "%s")}
#{DBXML.gen_xml_value("description"    , @description    , '"%s"')}

<note>
#{DBXML.indent_string(@note, 2)}
</note>
)
  end

  def set_from_string(instring)
    @__reading_note_lines = false
    DBXML.sting_each_line { |line|
      string_to_property(line)
    }
  end

  def string_to_property(line)
    case line
    when /<id=(\d+)\/>/i
      @id = $1.to_i
    when /<name="(.*)"\/>/i
      @name = $1
    when /<icon_index=(\d+)\/>/i
      @icon_index = $1.to_i
    when /<description="(.*)"\/>/i
      @description = $1
    when /<note>/i
      @__reading_note_lines = true
    when /<\/note>/i
      @__reading_note_lines = false
    else
      if @__reading_note_lines
        self.note += line + "\n"
      end
    end
  end

end

class RPG::UsableItem

  def create_xml()
    return super + %Q(
#{DBXML.gen_xml_value("scope"            , @scope            , "%s")}
#{DBXML.gen_xml_value("occasion"         , @occasion         , "%s")}
#{DBXML.gen_xml_value("speed"            , @speed            , "%s")}
#{DBXML.gen_xml_value("animation_id"     , @animation_id     , "%s")}

#{DBXML.gen_xml_value("common_event_id"  , @common_event_id  , "%s")}

#{DBXML.gen_xml_value("base_damage"      , @base_damage      , "%s")}
#{DBXML.gen_xml_value("variance"         , @variance         , "%s")}
#{DBXML.gen_xml_value("atk_f"            , @atk_f            , "%s")}
#{DBXML.gen_xml_value("spi_f"            , @spi_f            , "%s")}

<physical_attack="#{@physical_attack.to_s}"/>
<damage_to_mp="#{@damage_to_mp.to_s}"/>
<absorb_damage="#{@absorb_damage.to_s}"/>
<ignore_defense="#{@ignore_defense.to_s}"/>

<element_set>
#{DBXML.indent_string(DBXML.array_to_xmlstring(@element_set, "element", "%s"), 2)}
</element_set>

<plus_state_set>
#{DBXML.indent_string(DBXML.array_to_xmlstring(@plus_state_set, "plus_state", "%s"), 2)}
</plus_state_set>

<minus_state_set>
#{DBXML.indent_string(DBXML.array_to_xmlstring(@minus_state_set, "minus_state", "%s"), 2)}
</minus_state_set>
)
  end

  def set_from_string(string)
    @__reading_element_set     = false
    @__reading_plus_state_set  = false
    @__reading_minus_state_set = false
    super(string)
  end

  def string_to_property(line)
    super(line)
    case line
    when /<scope=(\d+)\/>/i
      @scope = $1.to_i
    when /<occasion=(\d+)\/>/i
      @occasion = $1.to_i
    when /<speed=(\d+)\/>/i
      @speed = $1.to_i
    when /<animation_id=(\d+)\/>/i
      @animation_id = $1.to_i
    when /<common_event_id=(\d+)\/>/i
      @common_event_id = $1.to_i
    when /<base_damage=(\d+)\/>/i
      @base_damage = $1.to_i
    when /<variance=(\d+)\/>/i
      @variance = $1.to_i
    when /<atk_f=(\d+)\/>/i
      @atk_f = $1.to_i
    when /<spi_f=(\d+)\/>/i
      @spi_f = $1.to_i
    when /<physical_attack="(\w+)"\/>/i
      @physical_attack = DBXML.string_to_bool($1)
    when /<damage_to_mp="(\w+)"\/>/i
      @damage_to_mp = DBXML.string_to_bool($1)
    when /<absorb_damage="(\w+)"\/>/i
      @absorb_damage = DBXML.string_to_bool($1)
    when /<ignore_defense="(\w+)"\/>/i
      @ignore_defense = DBXML.string_to_bool($1)
    when /<element_set>/i
      @__reading_element_set = true
    when /<\/element_set>/i
      @__reading_element_set = false
    when /<plus_state_set>/i
      @__reading_plus_state_set = true
    when /<\/plus_state_set>/i
      @__reading_plus_state_set = false
    when /<minus_state_set>/i
      @__reading_minus_state_set = true
    when /<\/minus_state_set>/i
      @__reading_minus_state_set = false
    else
      if @__reading_element_set
        @element_set += DBXML.number_string_to_array(line)
      end
      if @__reading_plus_state_set
        @plus_state_set += DBXML.number_string_to_array(line)
      end
      if @__reading_minus_state_set
        @minus_state_set += DBXML.number_string_to_array(line)
      end
    end
  end

end

class RPG::Item

  def create_xml()
    return super + %Q(
<price=#{@price}/>

<consumable="#{@consumable.to_s}"/>

<hp_recovery_rate=#{@hp_recovery_rate}/>
<hp_recovery=#{@hp_recovery}/>

<mp_recovery_rate=#{@mp_recovery_rate}/>
<mp_recovery=#{@mp_recovery}/>

<parameter_type=#{@parameter_type}/>
<parameter_points=#{@parameter_points}/>
    )
  end

  def string_to_property(line)
    super(line)
    case line
    when /<price=(\d+)\/>/i
      @price = $1.to_i
    when /<consumable="(\w+)"\/>/i
      @consumable = DBXML.string_to_bool($1)
    when /<hp_recovery_rate=(\d+)\/>/i
      @hp_recovery_rate = $1.to_i
    when /<hp_recovery=(\d+)\/>/i
      @hp_recovery = $1.to_i
    when /<mp_recovery_rate=(\d+)\/>/i
      @mp_recovery_rate = $1.to_i
    when /<mp_recovery=(\d+)\/>/i
      @mp_recovery = $1.to_i
    when /<parameter_type=(\d+)\/>/i
      @parameter_type = $1.to_i
    when /<parameter_points=(\d+)\/>/i
      @parameter_points = $1.to_i
    end
  end

end

class RPG::Skill

  def create_xml()
    return super + %Q(
#{DBXML.gen_xml_value("mp_cost"           , @mp_cost          , "%s")}

#{DBXML.gen_xml_value("hit"               , @hit              , "%s")}

<message1="#{@message1}"/>
<message2="#{@message2}"/>
    )
  end

  def string_to_property(line)
    super(line)
    case line
    when /<mp_cost="(\d+)"\/>/i
      @mp_cost = $1.to_i
    when /<hit="(\d+)"\/>/i
      @hit = $1.to_i
    when /<message1="(.*)"\/>/i
      @message1 = $1
    when /<message2="(.*)"\/>/i
      @message2 = $1
    end
  end

end

class RPG::Armor

  def create_xml()
    return super + %Q(
#{DBXML.gen_xml_value("kind"              , @kind             , "%s")}
#{DBXML.gen_xml_value("price"             , @price            , "%s")}

#{DBXML.gen_xml_value("eva"               , @eva              , "%s")}

#{DBXML.gen_xml_value("atk"               , @atk              , "%s")}
#{DBXML.gen_xml_value("def"               , @def              , "%s")}
#{DBXML.gen_xml_value("spi"               , @spi              , "%s")}
#{DBXML.gen_xml_value("agi"               , @agi              , "%s")}

<prevent_critical="#{@prevent_critical.to_s}"/>
<half_mp_cost="#{@half_mp_cost.to_s}"/>
<double_exp_gain="#{@double_exp_gain.to_s}"/>
<auto_hp_recover="#{@auto_hp_recover.to_s}"/>

<element_set>
#{DBXML.indent_string(DBXML.array_to_xmlstring(@element_set, "element", "%s"), 2)}
</element_set>

<state_set>
#{DBXML.indent_string(DBXML.array_to_xmlstring(@state_set, "state", "%s"), 2)}
</state_set>
    )
  end

  def set_from_string(string)
    @__reading_element_set     = false
    @__reading_state_set = false
    super(string)
  end

  def string_to_property(line)
    super(line)
    case line
    when /<kind=(\d+)\/>/i
      @kind = $1.to_i
    when /<price=(\d+)\/>/i
      @price = $1.to_i
    when /<eva=(\d+)\/>/i
      @eva = $1.to_i
    when /<atk=(\d+)\/>/i
      @atk = $1.to_i
    when /<def=(\d+)\/>/i
      @def = $1.to_i
    when /<spi=(\d+)\/>/i
      @spi = $1.to_i
    when /<agi=(\d+)\/>/i
      @agi = $1.to_i
    when /<prevent_critical="(\w+)"\/>/i
      @prevent_critical = DBXML.string_to_bool($1)
    when /<half_mp_cost="(\w+)"\/>/i
      @half_mp_cost = DBXML.string_to_bool($1)
    when /<double_exp_gain="(\w+)"\/>/i
      @double_exp_gain = DBXML.string_to_bool($1)
    when /<auto_hp_recover="(\w+)"\/>/i
      @auto_hp_recover = DBXML.string_to_bool($1)
    when /<element_set>/i
      @__reading_element_set = true
    when /<\/element_set>/i
      @__reading_element_set = false
    when /<state_set>/i
      @__reading_element_set = true
    when /<\/state_set>/i
      @__reading_element_set = false
    else
      if @__reading_element_set
        @element_set += DBXML.number_string_to_array(line)
      end
      if @__reading_state_set
        @state_set += DBXML.number_string_to_array(line)
      end
    end
  end

end

class RPG::Weapon

  def create_xml()
    return super + %Q(
#{DBXML.gen_xml_value("animation_id"      , @animation_id     , "%s")}
#{DBXML.gen_xml_value("price"             , @price            , "%s")}

#{DBXML.gen_xml_value("hit"               , @hit              , "%s")}

#{DBXML.gen_xml_value("atk"               , @atk              , "%s")}
#{DBXML.gen_xml_value("def"               , @def              , "%s")}
#{DBXML.gen_xml_value("spi"               , @spi              , "%s")}
#{DBXML.gen_xml_value("agi"               , @agi              , "%s")}

<two_handed=#{@two_handed.to_s}/>
<fast_attack=#{@fast_attack.to_s}/>
<dual_attack=#{@dual_attack.to_s}/>
<critical_bonus=#{@critical_bonus.to_s}/>

<element_set>
#{DBXML.indent_string(DBXML.array_to_xmlstring(@element_set, "element", "%s"), 2)}
</element_set>

<state_set>
#{DBXML.indent_string(DBXML.array_to_xmlstring(@state_set, "state", "%s"), 2)}
</state_set>
    )
  end

  def set_from_string(string)
    @__reading_element_set = false
    @__reading_state_set = false
    super(string)
  end

  def string_to_property(line)
    super(line)
    case line
    when /<animation_id=(\d+)\/>/i
      @animation_id = $1.to_i
    when /<price=(\d+)\/>/i
      @price = $1.to_i
    when /<hit=(\d+)\/>/i
      @hit = $1.to_i
    when /<atk=(\d+)\/>/i
      @atk = $1.to_i
    when /<def=(\d+)\/>/i
      @def = $1.to_i
    when /<spi=(\d+)\/>/i
      @spi = $1.to_i
    when /<agi=(\d+)\/>/i
      @agi = $1.to_i
    when /<two_handed="(\w+)"\/>/i
      @two_handed = DBXML.string_to_bool($1)
    when /<fast_attack="(\w+)"\/>/i
      @fast_attack = DBXML.string_to_bool($1)
    when /<dual_attack="(\w+)"\/>/i
      @dual_attack = DBXML.string_to_bool($1)
    when /<critical_bonus="(\w+)"\/>/i
      @critical_bonus = DBXML.string_to_bool($1)
    when /<element_set>/i
      @__reading_element_set = true
    when /<\/element_set>/i
      @__reading_element_set = false
    when /<state_set>/i
      @__reading_element_set = true
    when /<\/state_set>/i
      @__reading_element_set = false
    else
      if @__reading_element_set
        @element_set += DBXML.number_string_to_array(line)
      end
      if @__reading_state_set
        @state_set += DBXML.number_string_to_array(line)
      end
    end
  end
end

class RPG::State

  def create_xml()
    return %Q(
#{DBXML.gen_xml_value("id"               , @id               , "%s")}
#{DBXML.gen_xml_value("name"             , @name             , '"%s"')}
#{DBXML.gen_xml_value("icon_index"       , @icon_index       , "%s")}

#{DBXML.gen_xml_value("restriction"      , @restriction      , "%s")}
#{DBXML.gen_xml_value("priority"         , @priority         , "%s")}

#{DBXML.gen_xml_value("atk_rate"         , @atk_rate         , "%s")}
#{DBXML.gen_xml_value("def_rate"         , @def_rate         , "%s")}
#{DBXML.gen_xml_value("spi_rate"         , @spi_rate         , "%s")}
#{DBXML.gen_xml_value("agi_rate"         , @agi_rate         , "%s")}

#{DBXML.gen_xml_value("nonresistance"    , @nonresistance    , '"%s"')}
#{DBXML.gen_xml_value("offset_by_opposite", @offset_by_opposite, '"%s"')}
#{DBXML.gen_xml_value("slip_damage"      , @slip_damage      , '"%s"')}
#{DBXML.gen_xml_value("reduce_hit_ratio" , @reduce_hit_ratio , '"%s"')}

#{DBXML.gen_xml_value("battle_only"      , @battle_only      , '"%s"')}
#{DBXML.gen_xml_value("release_by_damage", @release_by_damage, '"%s"')}

#{DBXML.gen_xml_value("hold_turn"        , @hold_turn        , "%s")}
#{DBXML.gen_xml_value("auto_release_prob", @auto_release_prob, "%s")}

#{DBXML.gen_xml_value("message1"         , @message1         , '"%s"')}
#{DBXML.gen_xml_value("message2"         , @message2         , '"%s"')}
#{DBXML.gen_xml_value("message3"         , @message3         , '"%s"')}
#{DBXML.gen_xml_value("message4"         , @message4         , '"%s"')}

<element_set>
#{DBXML.indent_string(DBXML.array_to_xmlstring(@element_set, "element", "%s"), 2)}
</element_set>

<state_set>
#{DBXML.indent_string(DBXML.array_to_xmlstring(@state_set, "state", "%s"), 2)}
</state_set>

<note>
#{DBXML.indent_string(@note, 2)}
</note>
    )
  end

  def set_from_string(instring)
    @__reading_note_lines = false
    @__reading_element_set = false
    @__reading_state_set   = false
    DBXML.sting_each_line { |line|
      string_to_property(line)
    }
  end

  def string_to_property(line)
    case line
    when /<id=(\d+)\/>/i
      @id = $1.to_i
    when /<name="(.*)"\/>/i
      @name = $1
    when /<icon_index=(\d+)\/>/i
      @icon_index = $1.to_i
    when /<restriction=(\d+)\/>/i
      @restriction = $1.to_i
    when /<priority=(\d+)\/>/i
      @priority = $1.to_i
    when /<atk_rate=(\d+)\/>/i
      @atk_rate = $1.to_i
    when /<def_rate=(\d+)\/>/i
      @def_rate = $1.to_i
    when /<spi_rate=(\d+)\/>/i
      @spi_rate = $1.to_i
    when /<agi_rate=(\d+)\/>/i
      @agi_rate = $1.to_i
    when /<nonresistance="(\w+)"\/>/i
      @nonresistance = DBXML.string_to_bool($1)
    when /<offset_by_opposite="(\w+)"\/>/i
      @offset_by_opposite = DBXML.string_to_bool($1)
    when /<slip_damage="(\w+)"\/>/i
      @slip_damage = DBXML.string_to_bool($1)
    when /<reduce_hit_ratio="(\w+)"\/>/i
      @reduce_hit_ratio = DBXML.string_to_bool($1)
    when /<battle_only="(\w+)"\/>/i
      @battle_only = DBXML.string_to_bool($1)
    when /<release_by_damage="(\w+)"\/>/i
      @release_by_damage = DBXML.string_to_bool($1)
    when /<hold_turn="(\d+)"\/>/i
      @hold_turn = $1.to_i
    when /<auto_release_prob="(\d+)"\/>/i
      @auto_release_prob = $1.to_i
    when /<message1="(.*)"\/>/i
      @message1 = $1
    when /<message2="(.*)"\/>/i
      @message2 = $1
    when /<message3="(.*)"\/>/i
      @message3 = $1
    when /<message4="(.*)"\/>/i
      @message4 = $1
    when /<note>/i
      @__reading_note_lines = true
    when /<\/note>/i
      @__reading_note_lines = false
    when /<element_set>/i
      @__reading_element_set = true
    when /<\/element_set>/i
      @__reading_element_set = false
    when /<state_set>/i
      @__reading_element_set = true
    when /<\/state_set>/i
      @__reading_element_set = false
    else
      if @__reading_note_lines
        self.note += line + "\n"
      end
      if @__reading_element_set
        @element_set += DBXML.number_string_to_array(line)
      end
      if @__reading_state_set
        @state_set += DBXML.number_string_to_array(line)
      end
    end
  end

end

class RPG::Class

  def create_xml()
    return %Q(
#{DBXML.gen_xml_value("id"               , @id               , "%s")}
#{DBXML.gen_xml_value("name"             , @name             , '"%s"')}
#{DBXML.gen_xml_value("position"         , @position         , "%s")}

<weapon_set>
#{DBXML.indent_string(DBXML.array_to_xmlstring(@weapon_set, "weapon", "%s"), 2)}
</weapon_set>

<armor_set>
#{DBXML.indent_string(DBXML.array_to_xmlstring(@armor_set, "armor", "%s"), 2)}
</armor_set>

<element_ranks>
#{DBXML.indent_string(DBXML.rank_table_to_string(@element_ranks, "%s"), 2)}
</element_ranks>

<state_ranks>
#{DBXML.indent_string(DBXML.rank_table_to_string(@state_ranks, "%s"), 2)}
</state_ranks>

<learnings>
#{DBXML.indent_string(DBXML.learnings_array_to_string(@learnings), 2)}
</learnings>

#{DBXML.gen_xml_value("skill_name_valid" , @skill_name_valid , '"%s"')}
#{DBXML.gen_xml_value("skill_name"       , @skill_name       , '"%s"')}
    )
  end

  class Learning

    def create_xml()
      return %Q(<learning level=#{@level} skill_id=#{@skill_id}/>)
    end

  end

  def set_from_string(instring)
    @__reading_note_lines    = false
    @__reading_weapon_set    = false
    @__reading_armor_set     = false
    @__reading_element_ranks = false
    @__reading_state_ranks   = false
    @__reading_learnings     = false
    @__lastlearning = nil
    DBXML.sting_each_line { |line|
      string_to_property(line)
    }
  end

  def string_to_property(line)
    case line
    when /<id="(\d+)"\/>/i
      @id = $1.to_i
    when /<name="(.*)"\/>/i
      @name = $1
    when /<position="(\d+)"\/>/i
      @position = $1.to_i
    when /<weapon_set>/i
      @__reading_weapon_set = true
    when /<\/weapon_set>/i
      @__reading_weapon_set = false
    when /<armor_set>/i
      @__reading_armor_set  = true
    when /<\/armor_set>/i
      @__reading_armor_set  = false
    when /<element_ranks>/i
      @__reading_element_ranks = true
    when /<\/element_ranks>/i
      @__reading_element_ranks = false
    when /<state_ranks>/i
      @__reading_state_ranks = true
    when /<\/state_ranks>/i
      @__reading_state_ranks = false
    when /<learnings>/i
      @__reading_learnings  = true
    when /<\/learnings>/i
      @__reading_learnings  = false
    else
      if @__reading_weapon_set
        @weapon_set += line[/<weapon="(\d+)"\/>/i, 1] || []
      end
      if @__reading_armor_set
        @armor_set += line.match[/<armor="(\d+)"\/>/i, 1] || []
      end
      if @__reading_element_ranks
        case line
        when /<(\d+)="(\d+)"\/>/i
          @element_ranks[$1.to_i] = $2.to_i
        end
      end
      if @__reading_state_ranks
        case line
        when /<(\d+)="(\d+)"\/>/i
          @state_ranks[$1.to_i] = $2.to_i
        end
      end
      if @__reading_learnings
        case line
        when /<learning>/i
          @__lastlearning = Learning.new()
        when /<\/learning>/i
          @learnings << @__lastlearning unless @__lastlearning.nil?()
          @__lastlearning = nil
        when /<level=(\d+)\/>/i
          @__lastlearning.level = $1.to_i
        when /<skill_id=(\d+)\/>/i
          @__lastlearning.skill_id = $1.to_i
        end
      end
    end
  end

end

class RPG::Actor

  def create_xml
    return %Q(
#{DBXML.gen_xml_value("id"               , @id               , "%s")}
#{DBXML.gen_xml_value("name"             , @name             , '"%s"')}
#{DBXML.gen_xml_value("class_id"         , @class_id         , "%s")}
#{DBXML.gen_xml_value("initial_level"    , @initial_level    , "%s")}

#{DBXML.gen_xml_value("exp_basis"        , @exp_basis        , "%s")}
#{DBXML.gen_xml_value("exp_inflation"    , @exp_inflation    , "%s")}

#{DBXML.gen_xml_value("character_name"   , @character_name   , '"%s"')}
#{DBXML.gen_xml_value("character_index"  , @character_index  , "%s")}
#{DBXML.gen_xml_value("face_name"        , @face_name        , '"%s"')}
#{DBXML.gen_xml_value("face_index"       , @face_index       , "%s")}

#{DBXML.gen_xml_value("weapon_id"        , @weapon_id        , "%s")}
#{DBXML.gen_xml_value("armor1_id"        , @armor1_id        , "%s")}
#{DBXML.gen_xml_value("armor2_id"        , @armor2_id        , "%s")}
#{DBXML.gen_xml_value("armor3_id"        , @armor3_id        , "%s")}
#{DBXML.gen_xml_value("armor4_id"        , @armor4_id        , "%s")}

#{DBXML.gen_xml_value("two_swords_style" , @two_swords_style , '"%s"')}
#{DBXML.gen_xml_value("fix_equipment"    , @fix_equipment    , '"%s"')}
#{DBXML.gen_xml_value("auto_battle"      , @auto_battle      , '"%s"')}
#{DBXML.gen_xml_value("super_guard"      , @super_guard      , '"%s"')}
#{DBXML.gen_xml_value("pharmacology"     , @pharmacology     , '"%s"')}
#{DBXML.gen_xml_value("critical_bonus"   , @critical_bonus   , '"%s"')}

<parameters>
#{DBXML.indent_string(parameters_to_string(), 2)}
</parameters>
    )
  end

  def parameters_to_string
    result = ""
    for i in 0...6
      result += %Q(
<kind id=#{i}>
#{DBXML.indent_string(DBXML.parameter_table_to_string(@parameters, i, "parameter", "%s"), 2)}
</kind>
)
    end
    return result
  end

  def set_from_string(instring)
    @__reading_note_lines    = false
    @__reading_weapon_set    = false
    @__reading_armor_set     = false
    @__reading_element_ranks = false
    @__reading_state_ranks   = false
    @__reading_learnings     = false
    @__lastlearning = nil
    DBXML.sting_each_line { |line|
      string_to_property(line)
    }
  end

  def string_to_property(line)
    case line
    when ""
    end
  end

end

class RPG::Enemy

  def create_xml
    return %Q(
#{DBXML.gen_xml_value("id"               , @id               , "%s")}
#{DBXML.gen_xml_value("name"             , @name             , '"%s"')}
#{DBXML.gen_xml_value("battler_name"     , @battler_name     , '"%s"')}
#{DBXML.gen_xml_value("battler_hue"      , @battler_hue      , "%s")}

#{DBXML.gen_xml_value("maxhp"            , @maxhp            , "%s")}
#{DBXML.gen_xml_value("maxmp"            , @maxmp            , "%s")}
#{DBXML.gen_xml_value("atk"              , @atk              , "%s")}
#{DBXML.gen_xml_value("def"              , @def              , "%s")}
#{DBXML.gen_xml_value("spi"              , @spi              , "%s")}
#{DBXML.gen_xml_value("agi"              , @agi              , "%s")}
#{DBXML.gen_xml_value("hit"              , @hit              , "%s")}
#{DBXML.gen_xml_value("eva"              , @eva              , "%s")}
#{DBXML.gen_xml_value("exp"              , @exp              , "%s")}
#{DBXML.gen_xml_value("gold"             , @gold             , "%s")}

#{DBXML.gen_xml_value("levitate"         , @levitate         , '"%s"')}
#{DBXML.gen_xml_value("has_critical"     , @has_critical     , '"%s"')}

<element_ranks>
#{DBXML.indent_string(DBXML.rank_table_to_string(@element_ranks, "%s"), 2)}
</element_ranks>

<state_ranks>
#{DBXML.indent_string(DBXML.rank_table_to_string(@state_ranks, "%s"), 2)}
</state_ranks>

<drop_item id=1>
#{DBXML.indent_string(@drop_item1.create_xml(), 2)}
</drop_item>

<drop_item id=2>
#{DBXML.indent_string(@drop_item2.create_xml(), 2)}
</drop_item>

<actions>
#{DBXML.indent_string(DBXML.actions_array_to_string(@actions), 2)}

</actions>

<note>
#{DBXML.indent_string(@note, 2)}
</note>

    )
  end

  def set_from_string(instring)
    @__reading_note_lines    = false
    @__reading_weapon_set    = false
    @__reading_armor_set     = false
    @__reading_element_ranks = false
    @__reading_state_ranks   = false
    @__reading_learnings     = false
    @__lastlearning = nil
    DBXML.sting_each_line { |line|
      string_to_property(line)
    }
  end

  def string_to_property(line)
    case line
    when ""
    end
  end

  class DropItem

    def create_xml
      return %Q(#{DBXML.gen_xml_value("kind"             , @kind             , "%s")}
#{DBXML.gen_xml_value("item_id"          , @item_id          , "%s")}
#{DBXML.gen_xml_value("weapon_id"        , @weapon_id        , "%s")}
#{DBXML.gen_xml_value("armor_id"         , @armor_id         , "%s")}
#{DBXML.gen_xml_value("denominator"      , @denominator      , "%s")}
)
    end

  end

  class Action

    def create_xml
      return %Q(#{DBXML.gen_xml_value("kind"             , @kind             , "%s")}
#{DBXML.gen_xml_value("basic"            , @basic            , "%s")}
#{DBXML.gen_xml_value("skill_id"         , @skill_id         , "%s")}
#{DBXML.gen_xml_value("condition_type"   , @condition_type   , "%s")}
#{DBXML.gen_xml_value("condition_param1" , @condition_param1 , "%s")}
#{DBXML.gen_xml_value("condition_param2" , @condition_param2 , "%s")}
#{DBXML.gen_xml_value("rating"           , @rating           , "%s")}
)
    end

  end

end

#DBXML.dump_database()
#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#
