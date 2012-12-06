require_relative "gui"

module Hoops
  class GameOver < Gui
    TEXT_COLOR = Color.rgba(255, 255, 255, 180)

    def initialize
      super

      on_input(:escape) { game_state_manager.pop_until_game_state Menu }

      button_options = { width: 180, justify: :center, font_height: 22 }

      vertical align_h: :center, padding_top: 190 do
        label "Game Over!", font_height: 100, color: TEXT_COLOR

        vertical align_h: :center, padding_top: 10, spacing: 8 do
          button "Again", button_options.merge(tip: "Play game again with same song/players/difficulty", shortcut: :g) do
            pop_game_state
            previous_game_state.restart
          end

          button "Change game", button_options.merge(tip: "Go back to change song/players/difficulty", shortcut: :c) do
            game_state_manager.pop_until_game_state Difficulty
          end

          button "Menu", button_options.merge(tip: "Go back to main menu", shortcut: :m) do
            game_state_manager.pop_until_game_state Menu
          end

          button "Exit", button_options.merge(tip: "Quit to desktop", shortcut: :x) do
            exit
          end
        end
      end
    end

    def draw
      super
      previous_game_state.draw
    end
  end
end