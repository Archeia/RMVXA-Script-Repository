#
# EDOS/src/REI/component.rb
#
module REI
  module Component
  end
end

require_relative 'component/abilities'    # Allows various abilities
require_relative 'component/actions'      # Allows the entity to make actions
require_relative 'component/body'         # Allows a few fine-tuned components
require_relative 'component/character'    # Allows the entity to be displayed
require_relative 'component/damage'       # Allows the damaging of the entity
require_relative 'component/effect'       # Allows for direct effect application
require_relative 'component/equipment'    # Allows the equipping of items
require_relative 'component/event_server' # Allows the entity to use polled events (FIFO)
require_relative 'component/health'       # HP
require_relative 'component/inventory'    # Allows the storage of items (not usage)
require_relative 'component/item_use'     # Allows usage of item (only usage, no storage)
require_relative 'component/level'        # Growth
require_relative 'component/mana'         # MP
require_relative 'component/motion'       # Motion, involves being able to move
require_relative 'component/name'         # Name
require_relative 'component/position'     # Allows the character to be placed in the world
require_relative 'component/position_ease'# Smoothed movement
require_relative 'component/size'         # Size
require_relative 'component/skill_list'   # Allows the storage of magic (not usage)
require_relative 'component/skill_use'    # Allows usage of magic (only usage, no storage)
require_relative 'component/squad'        # Squad
require_relative 'component/states'       # The entity can be affect by states (such as paralysis and sleep)
require_relative 'component/time_event'   # Allows the entity to use timed events
require_relative 'component/wt'           # WT