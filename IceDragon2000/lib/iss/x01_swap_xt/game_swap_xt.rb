# ISSX01 - SwapXT 0.9a
#==============================================================================#
# ** ISS - SwapXT (Remixed)
#==============================================================================#
# ** Date Created  : 05/12/2011
# ** Date Modified : 07/29/2011
# ** Original By   : Marco Di Antonio (bulletxt@gmail.com) (BulletXt)
# ** Rewritten By  : IceDragon
# ** ID            : R01
# ** Version       : 0.9a
#==============================================================================#
# ============================================================================ #
# // This is SwapXT script that must be put in your VX game script section. // #
# // It's Plug&Play.                                                        // #
# // Use SwapXT application to do swaps once you put this into your VX game.// #
# ============================================================================ #
# Currently, realtime swapping isn't supported sorry about that ,x,
$simport.r('issx/swap-xt', '0.9.0', 'Rewrite of BulletXt\'s SwapXT')
#==============================================================================#
# ISS::SwapXT
#==============================================================================#
module ISS
  module SwapXT
    EVENT_SWAPPING_SWITCH_ID = nil
    JIFZ_MODE = false

#==============================================================================#
# ** SwapXT::Game_SwapXT
#==============================================================================#
    class Game_SwapXT
    #--------------------------------------------------------------------------#
    # * Constants
    #--------------------------------------------------------------------------#
      RMVX_FEXTENSION      = '.rvdata'
      SWAPXT_FEXTENSION    = '.stx'
      SWAPXT_MAIN_PATH     = 'swapxt/'
      PROFILE_TILE_PATH    = 'tiles/'
      PROFILE_PASS_PATH    = 'passages/'
      DEF_TILE_PATH        = 'Graphics/System/'
      DEF_EXTRA_TILEFOLDER = 'extra_tiles/'
      DEF_PASSAGE_PATH     = 'Graphics/System/'
      DEF_EXTRA_PASSFOLDER = 'extra_tiles/'
      FILEEMPTY_STRING     = 'empty::*::'
      DEFAULT_TILES        = Array.new(9).map! { '' } # // I have no idea why I did this...
      DEFAULT_TILES[0]     = 'TileA1'
      DEFAULT_TILES[1]     = 'TileA2'
      DEFAULT_TILES[2]     = 'TileA3'
      DEFAULT_TILES[3]     = 'TileA4'
      DEFAULT_TILES[4]     = 'TileA5'
      DEFAULT_TILES[5]     = 'TileB'
      DEFAULT_TILES[6]     = 'TileC'
      DEFAULT_TILES[7]     = 'TileD'
      DEFAULT_TILES[8]     = 'TileE'

    #--------------------------------------------------------------------------#
    # * Public Instance Variables
    #--------------------------------------------------------------------------#
      attr_accessor :loaded_system
      attr_accessor :swap_tiles

    #--------------------------------------------------------------------------#
    # * method :initialize
    #--------------------------------------------------------------------------#
      def initialize
        setup(-1)
      end

    #--------------------------------------------------------------------------#
    # * new-method :setup
    #--------------------------------------------------------------------------#
      def setup(map_id)
        $logger.write app: 'Game_SwapXT', fn: 'setup'
        @swap_tiles        = Array.new(9).map! { FILEEMPTY_STRING }
        @swap_passages     = FILEEMPTY_STRING # // System.rvdata name
        @swap_realtime     = false
        @swap_tile_profile = false
        @swap_pass_profile = false
        @map_id            = map_id
        @loaded_system     = nil
        load_tile_profile
        load_passage_profile
        load_system_data
      end

    #--------------------------------------------------------------------------#
    # * new-method :tile_bitmapname
    #--------------------------------------------------------------------------#
      def tile_bitmapname(t, defal = false)
        case t
        when 0, :a1
          return DEFAULT_TILES[0] if @swap_tiles[0] == FILEEMPTY_STRING or defal
          return sprintf('%s%s', DEF_EXTRA_TILEFOLDER, @swap_tiles[0])
        when 1, :a2
          return DEFAULT_TILES[1] if @swap_tiles[1] == FILEEMPTY_STRING or defal
          return sprintf('%s%s', DEF_EXTRA_TILEFOLDER, @swap_tiles[1])
        when 2, :a3
          return DEFAULT_TILES[2] if @swap_tiles[2] == FILEEMPTY_STRING or defal
          return sprintf('%s%s', DEF_EXTRA_TILEFOLDER, @swap_tiles[2])
        when 3, :a4
          return DEFAULT_TILES[3] if @swap_tiles[3] == FILEEMPTY_STRING or defal
          return sprintf('%s%s', DEF_EXTRA_TILEFOLDER, @swap_tiles[3])
        when 4, :a5
          return DEFAULT_TILES[4] if @swap_tiles[4] == FILEEMPTY_STRING or defal
          return sprintf('%s%s', DEF_EXTRA_TILEFOLDER, @swap_tiles[4])
        when 5, :b
          return DEFAULT_TILES[5] if @swap_tiles[5] == FILEEMPTY_STRING or defal
          return sprintf('%s%s', DEF_EXTRA_TILEFOLDER, @swap_tiles[5])
        when 6, :c
          return DEFAULT_TILES[6] if @swap_tiles[6] == FILEEMPTY_STRING or defal
          return sprintf('%s%s', DEF_EXTRA_TILEFOLDER, @swap_tiles[6])
        when 7, :d
          return DEFAULT_TILES[7] if @swap_tiles[7] == FILEEMPTY_STRING or defal
          return sprintf('%s%s', DEF_EXTRA_TILEFOLDER, @swap_tiles[7])
        when 8, :e
          return DEFAULT_TILES[8] if @swap_tiles[8] == FILEEMPTY_STRING or defal
          return sprintf('%s%s', DEF_EXTRA_TILEFOLDER, @swap_tiles[8])
        end
      end

    #--------------------------------------------------------------------------#
    # * new-method :load_tile_profile
    #--------------------------------------------------------------------------#
      def load_tile_profile
        if ::ISS::SwapXT::JIFZ_MODE
          swaps = JIFZ::SWAPS
          return unless swaps.has_key?(@map_id)
          @swap_tiles[0] = swaps[@map_id][:tileA1].nil? ? swaps[0][:tileA1] : swaps[@map_id][:tileA1]
          @swap_tiles[1] = swaps[@map_id][:tileA2].nil? ? swaps[0][:tileA2] : swaps[@map_id][:tileA2]
          @swap_tiles[2] = swaps[@map_id][:tileA3].nil? ? swaps[0][:tileA3] : swaps[@map_id][:tileA3]
          @swap_tiles[3] = swaps[@map_id][:tileA4].nil? ? swaps[0][:tileA4] : swaps[@map_id][:tileA4]
          @swap_tiles[4] = swaps[@map_id][:tileA5].nil? ? swaps[0][:tileA5] : swaps[@map_id][:tileA5]
          @swap_tiles[5] = swaps[@map_id][:tileB].nil?  ? swaps[0][:tileB] : swaps[@map_id][:tileB]
          @swap_tiles[6] = swaps[@map_id][:tileC].nil?  ? swaps[0][:tileC] : swaps[@map_id][:tileC]
          @swap_tiles[7] = swaps[@map_id][:tileD].nil?  ? swaps[0][:tileD] : swaps[@map_id][:tileD]
          @swap_tiles[8] = swaps[@map_id][:tileE].nil?  ? swaps[0][:tileE] : swaps[@map_id][:tileE]
          for i in 0...@swap_tiles.size
            @swap_tiles[i] = FILEEMPTY_STRING if @swap_tiles[i].nil?
          end
        else
          ext = SWAPXT_FEXTENSION
          pth = SWAPXT_MAIN_PATH
          tpth= PROFILE_TILE_PATH
          nm = sprintf('%s%s%s%s', pth, tpth, @map_id, ext)
          if FileTest.exist?(nm)
            @swap_tile_profile = true ; i = 0
            File.read(nm).split("\n").each do |t|
              @swap_tiles[i] = t ; i += 1
            end
          end
        end
      end

    #--------------------------------------------------------------------------#
    # * new-method :load_passage_profile
    #--------------------------------------------------------------------------#
      def load_passage_profile
        if ::ISS::SwapXT::JIFZ_MODE
          swaps = JIFZ::SWAPS
          return unless swaps.has_key?(@map_id)
          @swap_passages = swaps[@map_id][:passage].nil? ? swaps[0][:passage] : swaps[@map_id][:passage]
          @swap_passages = FILEEMPTY_STRING if @swap_passages.nil?
        else
          ext = SWAPXT_FEXTENSION
          pth = SWAPXT_MAIN_PATH
          ppth= PROFILE_PASS_PATH
          nm = sprintf('%s%s%s%s', pth, ppth, @map_id, ext)
          if FileTest.exist?(nm)
            $logger.write app: 'Game_SwapXT', at: 'passage_profile.exists'
            @swap_pass_profile = true
            @swap_passages = (File.read(nm).split("\n"))[0]
          end
        end
      end

    #--------------------------------------------------------------------------#
    # * new-method :load_system_data
    #--------------------------------------------------------------------------#
      def load_system_data
        return if @swap_passages == FILEEMPTY_STRING
        ext = RMVX_FEXTENSION
        pth = DEF_PASSAGE_PATH
        ppth= DEF_EXTRA_PASSFOLDER
        nm  = sprintf('%s%s%s%s', pth, ppth, @swap_passages, ext)
        if FileTest.exist?(nm)
          @loaded_system = load_data(nm)
        else
          m = ISS::SwapXT::ErrorHandler::ERROR_MESSAGES["SystemDataDoesntExist"]
          m = sprintf(m, @swap_passages + ext)
          ISS::SwapXT::ErrorHandler.throw_error(m)
          return
        end
      end
    end # // SwapXT::Game_SwapXT
#==============================================================================#
# ** SwapXT::ErrorHandler
#==============================================================================#
    class ErrorHandler
    #--------------------------------------------------------------------------#
    # * Constants
    #--------------------------------------------------------------------------#
      EXTENSIONS = ['.png']
      TILENAMES  = {
        0 => 'A1',
        1 => 'A2',
        2 => 'A3',
        3 => 'A4',
        4 => 'A5',
        5 => 'B',
        6 => 'C',
        7 => 'D',
        8 => 'E'
      } # // Do Not Remove
      SWAP_PREFILENAME      = 'swapped_'
      PASSAGE_WARN_FILENAME = 'passage_warning'

      ERROR_HEADER   = 'SwapXT Error Encountered:'
      ERROR_MESSAGES = {
      # // Swapped tiles exists message
        "SwappedTileExists" => %Q(#{ERROR_HEADER}
        You are not allowed to start your game with swapped tilesets.
        You must unload your tilesets with SwapXT application first.
        Open SwapXT, click at top Tools->Restore all Tilesets),
      # // Swapped passage exists message
        "SwappedPassageExists" => %Q(#{ERROR_HEADER}
        You are not allowed to start your game with swapped passage settings.
        You must unload your passage setting with SwapXT application first.
        Open SwapXT, go on PassageSetting tab and click on Restore to Default.),
        "SystemDataDoesntExist"=> %Q(#{ERROR_HEADER}
        Cannot load passage data
        %s does not exist. Please check to ensure the file is spelt correctly,
        or if the file exists.)
      }

    #--------------------------------------------------------------------------#
    # * class-method :tile_error?
    #--------------------------------------------------------------------------#
      def self.tile_error?
        spf = SWAP_PREFILENAME
        tln = TILENAMES
        pth = Game_SwapXT::DEF_TILE_PATH
        # ---------------------------------------------------------------------- #
        tln.keys.each do |i|
          EXTENSIONS.each do |ext|
            nm = sprintf('%s%s%s%s', pth, spf, tln[i], ext)
            return true if FileTest.exist?(nm)
          end # // EXTENSIONS
        end # // TILENAMES.keys
        # ---------------------------------------------------------------------- #
        return false # // No problems
      end

    #--------------------------------------------------------------------------#
    # * class-method :passage_error?
    #--------------------------------------------------------------------------#
      def self.passage_error?
        pwf = PASSAGE_WARN_FILENAME
        pth = Game_SwapXT::SWAPXT_MAIN_PATH
        ext = Game_SwapXT::SWAPXT_FEXTENSION
        # ---------------------------------------------------------------------- #
        nm  = sprintf('%s%s%s', pth, pwf, ext)
        # ---------------------------------------------------------------------- #
        return true if FileTest.exist?(nm)
        # ---------------------------------------------------------------------- #
        return false # // No problems
      end

    #--------------------------------------------------------------------------#
    # * class-method :throw_error
    #--------------------------------------------------------------------------#
      def self.throw_error(string)
        fail string
      end
    end # // ErrorHandler

    def self.startup_error_checking
      if ErrorHandler.tile_error?
        m = ErrorHandler::ERROR_MESSAGES["SwappedTileExists"]
        ErrorHandler.throw_error(m)
        return
      end
      if ErrorHandler.passage_error?
        m = ErrorHandler::ERROR_MESSAGES["SwappedPassageExists"]
        ErrorHandler.throw_error(m)
        return
      end
    end
  end
end # // ISS
