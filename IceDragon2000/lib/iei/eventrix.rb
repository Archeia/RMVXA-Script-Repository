#-define HDR_TYP :type=>"module"
#-define HDR_GNM :name=>"IEI - Eventrix"
#-define HDR_GDC :dc=>"22/06/2012"
#-define HDR_GDM :dm=>"22/06/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"1.0"
#-inject gen_script_header HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
$simport.r 'iei/eventrix', '0.1.0', 'IEI Eventrix'

#-inject gen_module_header 'Eventrix'
module Eventrix
  # // EVTX
  @@eventrix_id = 1000
  @commands = MACL::Blaz.new

  def self.add_command *args,&block
    @commands.add_command *args,&block
    @command_hash = nil
  end

  def self.str2eventrix str
    return nil if !str or str.empty?
    @commands.match_command str do |sym,mtch,func,params|
      RPG::EventCommand.new sym, mtch.to_hash
    end
  end

  def self.match2evc_params match_data
    (1...10).map do |i| match_data[i] end
  end

  def self.mk_uniq_code
    ids = @commands.command_syms
    id = @@eventrix_id
    id += 1 while ids.include? id
    id
  end

  def self.define_commands!
    interpreter = ($imported['EDOS::Data'] ? Game::Interpreter : Game_Interpreter)
    @commands.enum_commands do |sym,regexp,func,params|
      interpreter.define_command sym, func if func
    end
  end

  def self.command_params sym
    @command_hash||=@commands.to_hash
    return nil unless @command_hash.has_key? sym
    @command_hash[sym][2]
  end
end

#EVTX = Eventrix
IEI::Core.on_data_load('iei/eventrix') { Eventrix.define_commands! }
#-inject gen_class_header 'RPG::Event'
class RPG::Event
  def eventrix!
    @page.map! &:eventrix!
  end
end

#-inject gen_class_header 'RPG::Event::Page'
class RPG::Event::Page
  def eventrix!
    new_list = []
    skip = 0
    @list.each do |c|
      next skip -= 1 if skip > 0
      com = c
      if COMMENT_CODES.include? c.code
        n = c.parameters.first.match /EVTX\s(.+)/i
        com = Eventrix.str2eventrix n[1] if n
      end
      params = Eventrix.command_params c.code
      if params
        case params[0]
        when :drop_next ; skip = 1
        when :drop_prev ; new_list.pop
        end
      end
      new_list << com
    end
    @list.replace new_list
    self
  end
end

class Game_Interpreter
  def self.define_command com_id, &func
    define_method "command_#{com_id}", &func
  end
end
#-inject gen_script_footer
