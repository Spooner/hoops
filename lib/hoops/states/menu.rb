module Hoops
  class Menu < Gui
    BACKGROUND_COLOR = Color.rgb(50, 50, 100)
    def initialize
      super

      add_inputs(
          p: :play,
          e: :close,
          escape: :close
      )

      Log.level = settings[:debug_mode] ? Logger::DEBUG : Logger::INFO

      vertical align_h: :center, spacing: 30, padding: 20 do
        heading = label "An indeterminate number of hoops!", font_size: 34, color: Color.rgb(50, 120, 255), justify: :center

        vertical align_h: :center, spacing: 12 do
          options = { width: heading.width - 15 - 300, font_size: 32, justify: :center }
          button("Play", options.merge(tip: 'Both players on the same keyboard')) { play }
          button("Options", options) { push_game_state OptionsPlaylist }
          button("About", options.merge(enabled: false))
          button("Exit", options) { close }
        end
      end

    @hoops = []
     (10..90).step(12) do |x|
       @hoops << SpinningHoop.new(x: x, y: 50, color: Color.rgb(rand(255), rand(255), rand(255)))
      end
    end


    def draw
      $window.pixel.draw(0, 0, ZOrder::BACKGROUND, $window.width, $window.height, BACKGROUND_COLOR)
      @hoops.each(&:draw)
      super
    end

    def update
      super
      @hoops.each(&:update)
    end

    def setup
      super
      log.info "Viewing main menu"
    end

    def play
      push_game_state Difficulty.new
    end

    def close
      log.info "Exited game"
      super
      exit
    end
  end
end
