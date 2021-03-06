require_relative "gui"

module Hoops
  class Difficulty < Gui
    PLAYER_NAMES = %w[Meow Star]

    DIFFICULTY_FILE = File.join(EXTRACT_PATH, 'lib', 'hoops', 'difficulty.yml')
    DIFFICULTY_SETTINGS = YAML.load(File.read(DIFFICULTY_FILE))

    def initialize
      super

      @button_options = { justify: :center, width: 120 }

      @difficulty = []

      vertical padding: 16, spacing: 15, align: :center, width: @container.width, height: @container.height do
        track_selector

        players

        buttons
      end

      on_input(:escape) { pop_game_state }
    end

    def players
      @players_selected = group do
        horizontal padding: 0, align_h: :center do
          label "Dancers: ", width: 100
          radio_button "#{PLAYER_NAMES[0]} only", [true, false], tip: "Play with just one dancer (on the left)"
          radio_button "Both", [true, true], tip: "Play with both dancers"
          radio_button "#{PLAYER_NAMES[1]} only", [false, true], tip: "Play with just one dancer (on the right)"
        end

        subscribe :changed do |control, players_playing|
          @difficulty_controls.each_pair do |player, control|
            control.each {|c| c.enabled = players_playing[player] }
          end

          2.times do |i|
            @player_image_frames[i].image = @player_images[[i, (players_playing[i] ? :enabled : :disabled)]]
          end
        end
      end

      vertical align_h: :center do
        horizontal padding: 0, align_h: :center do
          @difficulty_controls = Hash.new {|h, k| h[k] = [] }

          2.times do |number|
            player_image(number) if number == 0

            vertical align_h: :center do
              label "#{PLAYER_NAMES[number]}", font_height: 52, align_h: :center
              @difficulty << group do
                vertical spacing: 8, padding: 0 do
                  DIFFICULTY_SETTINGS.each_pair do |difficulty, settings|
                    @difficulty_controls[number] << radio_button(settings[:name], difficulty, @button_options)
                  end
                end
              end
              @difficulty.last.value = settings[:difficulty, number]
            end

            player_image(number) if number == 1
          end
        end
      end

      @players_selected.value = [settings[:playing, 0], settings[:playing, 1]]
    end

    def player_image(number)
      # Create two images, one normal and the other greyed out.
      @player_images ||= {}
      enabled_image = Image.load_tiles($window, File.join(Image.autoload_dirs[0], "player#{number + 1}_16x16.png"), 16, 16, true)[0]
      enabled_image.refresh_cache
      disabled_image = enabled_image.dup
      disabled_image.clear color: [0.25, 0.25, 0.25], dest_ignore: :transparent
      disabled_image.refresh_cache

      @player_images[[number, :enabled]] = enabled_image
      @player_images[[number, :disabled]] = disabled_image

      # Put the normal image into the frame, which can be replaced later.
      @player_image_frames ||= []
      @player_image_frames[number] = image_frame enabled_image, factor: 12, padding_top: 20, tip: PLAYER_NAMES[number]
    end

    def track_selector
      horizontal padding: 0 do
        label "Track:", width: 100

        vertical do
          horizontal padding: 0, spacing: 50 do
            @track_random = toggle_button "Randomize", value: settings[:playlist, :random] do |sender, value|
               @track_choice.enabled = (not value)
            end

            horizontal padding: 0 do
              label "Limit game length to: ", tip: "Games will last as long as the selected track, unless an upper limit has been set"
              @track_max_length = combo_box do
                (30..600).step(30) {|duration| item ("%2d:%02d" % duration.divmod(60)), duration }
                item "Unlimited", Float::INFINITY
              end
            end

            @track_max_length.value = settings[:playlist, :max_length]
          end

          # The tracklist is both the ones that come with the game and any added by the user.
          @tracks = Tracklist.new

          selected_track_index = rand(@tracks.size)
          @track_choice = combo_box enabled: (not settings[:playlist, :random]) do
            @tracks.each_with_index do |track, i|
              item "#{track.name} (#{track.duration_string})", i
              selected_track_index = i if track.file == settings[:playlist, :track]
            end
          end
          @track_choice.value = selected_track_index
        end
      end
    end

    def buttons
      vertical spacing: 0, padding: 0, width: @container.width do
        button("Dance!!!", @button_options.merge(align: :center, font_height: 70, width: 300, shortcut: :d)) do
          # Save difficulty settings
          2.times do |number|
            settings[:playing, number] = @players_selected.value[number]
            settings[:difficulty, number] = @difficulty[number].value if settings[:playing, number]
          end

          # Save track settings.
          track = @track_random.value ? @tracks.sample : @tracks[@track_choice.value]
          settings[:playlist, :random] = @track_random.value
          settings[:playlist, :track] = track.file unless @track_random.value
          settings[:playlist, :max_length] = @track_max_length.value

          settings_1 = settings[:playing, 0] ? DIFFICULTY_SETTINGS[@difficulty[0].value] : nil
          settings_2 = settings[:playing, 1] ? DIFFICULTY_SETTINGS[@difficulty[1].value] : nil
          push_game_state Play.new(settings_1, settings_2, track, settings[:playlist, :max_length])
        end

        button("Cancel", @button_options.merge(width: 70, align_v: :bottom, shortcut: :c)) { pop_game_state }
      end
    end
  end
end