$simport.r 'iei/emission', '0.1.0', 'IEI Emission'

# [IEI]Cir.Kit.Tri
module IEI
  module Emission
    class BaseComponent
      def initialize(subject)
        @subject = subject
        init
      end

      def init
      end

      def signal_xy(x,y)
        _map.ctk_signal_stack.select{|sig|sig.pos?(x,y)}
      end

      def connector_xy(x,y)
        _map.ctk_connectors(x,y)
      end

      def ctk_accept?
        connector? || reactor?
      end

      def ctk_emit_pass?
        connector?
      end

      def emitter?
        false
      end

      def connector?
        false
      end

      def reactor?
        false
      end

      def signal?
        false
      end

      def _map
        $game.system._map
      end

      def dispose
        false
      end

      def update
      end
    end

    class Emitter < BaseComponent
      def init
        super
        @em_direc = [2,4,6,8]
      end

      attr_accessor :em_direc

      def emit
        @em_direc.each do |d|
          _map.ctk_signal_stack << Signal.new(@subject.x,@subject.y,d)
        end
      end

      def emitter?
        true
      end
    end

    class Connector < BaseComponent
      def connector?
        true
      end

      def x
        @subject.x
      end

      def y
        @subject.y
      end

      def pos?(x, y)
        @subject.pos?(x, y)
      end
    end

    class Reactor < BaseComponent
      def reactor?
        true
      end

      def update
        super
        @subject.ctk_react! if(!signal_xy(@subject.x, @subject.y).empty?)
      end
    end

    class Signal < BaseComponent
      def initialize(x, y, d, life = 5)
        @x, @y, @d = x, y, d
        @last = [x,y,d]
        @life = life
        @dead = false
      end

      def pos?(x,y)
        @x == x && @y == y
      end

      def signal?
        true
      end

      def find_connectors(x,y)
        [2,4,6,8].inject([]) { |r,d|
          r << [connector_xy(_map.round_x_with_direction(x,d), _map.round_y_with_direction(y,d)),d]
          r
        }
      end

      def update
        super
        return if(broken?)
        @last = [@x,@y,@d]
        find_connectors(@x,@y).each do |c_a|
          d = c_a[1]
          c_a[0].each { |c|
            _map.ctk_signal_stack << Signal.new(c.x,c.y,d,@life-1)
            puts "Sending signal to #{c.x}, #{c.y} d #{d}, life #{@life-1}"
          }
        end
        @dead = true
        #@x = _map.round_x_with_direction(@x,@d)
        #@y = _map.round_y_with_direction(@y,@d)
        #puts "#{self} moving at #{@x}, #{@y}, in #{@d}"
        #@life -= 1
      end

      def broken?
        @dead || @life <= 0
      end
    end
  end
end

class Game::Map
  CKT_CYCLE_VARIABLE = 12

  def ctk_signal_stack
    @ctk_signal_stack ||= []
  end

  attr_writer :ctk_signal_stack

  alias pre_ckt_update update

  def update(*args,&block)
    if(ckt_update?)
      ctk_signal_stack.select do |signal|
        signal.broken? ? signal.dispose : !!signal.update
      end
    end
    pre_ckt_update(*args,&block)
  end

  def ckt_update?
    (Graphics.frame_count % $game.variables[CKT_CYCLE_VARIABLE]) == 0
  end

  def ctk_connectors(x,y)
    events_xy(x,y).select{|e|e.ckt && e.ckt.ctk_emit_pass?}
  end
end

class Game::Character
  def ctk_react!
    nil
  end

  attr_reader :ckt

  def setup_ckt(cktclass)
    @ckt = cktclass.new(self)
  end

  alias pre_ckt_update update

  def update(*args,&block)
    pre_ckt_update(*args,&block)
    update_ckt if(@ckt) if(_map.ckt_update?)
  end

  def update_ckt
    @ckt.update
  end
end

class Game::Event
  def ctk_react!
    self.start
    puts "Event #{@event_id} reacted!"
  end
end
