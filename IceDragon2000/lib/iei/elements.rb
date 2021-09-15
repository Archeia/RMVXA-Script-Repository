$simport.r 'iei/elements', '1.0.0', 'IEI Elements'

module IEI
  # >_> Nothing here to see. <_< Come on get going...
  class Element < RPG::BaseItem
    WEAK_RATE        =  1.50 #2.0 # >: 2x was a little too much
    NORMAL_RATE      =  1.00 #1.0 # :p Now why would you change this
    RESITANT_RATE    =  0.75 #0.5 # (: Gotta balance this out too
    INEFFECTIVE_RATE =  0.00 #0.0 # O: Absolutely useless
    REGEN_RATE       = -0.50 #0.5 # =] Congrats on screwing up and doing a regen effect

    def self.[](id, weak=[], resistant=[], ineffective=[], regen=[])
      f = RPG::BaseItem::Feature
      ele = new
      ele.initialize_add
      ele.id          = id
      ele.icon.index  = Game::Icon.element(ele.id)
      ele.name        = Vocab.element(ele.id)
      ele.description = ''
      ele.features  = []
      ele.features += weak.collect { |i| MakeFeature.element_r(i, WEAK_RATE) }
      ele.features += resistant.collect { |i| MakeFeature.element_r(i, RESITANT_RATE) }
      ele.features += ineffective.collect { |i| MakeFeature.element_r(i, INEFFECTIVE_RATE) }
      ele.features += regen.collect { |i| MakeFeature.element_r(i, REGEN_RATE) }
      ele # . x . You get teh newly created element
    end
  end
  module Elements
    @elements = []

    Element = IEI::Element

    def self.elements
      @elements
    end

    def self.element(n)
      elements[n]
    end

    def self.seed_database
      #
    end

    def self.create_database
      IEI.debug { |io| io.puts "Creating Element Database" }
      @elements = []
      seed_database
      @elements
    end

    module Mixin
      module Battler
        attr_accessor :element_id

        def init_element
          @element_id = 0
        end

        def element  # . x . Yes you retrieve the actual Element object
          $data_elements[element_id]
        end

        def elements # >_> Yes not element, ELEMENTS, >=> Dont ask
          [element]
        end

        def feature_objects # And then we add em all together
          super + elements # Other + Elements :3
        end
      end
    end
  end
end

DataManager.add_callback(:load_user_database) do
  $data_elements = IEI::Elements.create_database
end
