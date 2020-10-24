module Monopoly
  class TileMenu < Menu
    attr_accessor :coordinates

    def initialize(*)
      super

      house_button_options = {
        actions: nil,
        color: nil,
        game: game,
        height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
        hover_color: nil,
        hover_image: Image.new(game.images[:house]),
        image: Image.new(game.images[:house]),
        image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
        image_width: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.1,
        width: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.1,
        x: Coordinates::FIRST_HOUSE_BUTTON_X,
        z: ZOrder::MAIN_UI
      }
      build_house_button_options = {
        actions: :build_house,
        hover_image: Image.new(game.images[:build_house_hover]),
        image: Image.new(game.images[:build_house])
      }
      sell_house_button_options = {
        actions: :sell_house,
        hover_image: Image.new(game.images[:sell_house_hover]),
        image: Image.new(game.images[:sell_house])
      }

      house_button_offset = house_button_options[:image_height] + game.class::TILE_BUTTON_GAP
      house_buttons = []
      build_house_buttons = []
      sell_house_buttons = []
      (0..game.max_house_count).map do |offset_multiplier|
        house_button_options[:y] =
          Coordinates::FIRST_HOUSE_BUTTON_Y + (house_button_offset * offset_multiplier)
        house_buttons << Button.new(house_button_options)
        build_house_buttons << Button.new(house_button_options.merge(build_house_button_options))
        sell_house_buttons << Button.new(house_button_options.merge(sell_house_button_options))
      end

      mortgage_lock_button_options = {
        color: nil,
        game: game,
        height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
        hover_color: nil,
        image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
        image_width: 70,
        width: 70,
        x: Coordinates::MORTGAGE_LOCK_X,
        y: Coordinates::MORTGAGE_LOCK_Y,
        z: ZOrder::MAIN_UI
      }
      back_button_radius = 30

      self.buttons = {
        back: CircularButton.new(
          actions: :back_to_current_tile,
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:neutral_blue],
          hover_image: Image.new(game.images[:back]),
          image: Image.new(game.images[:back]),
          image_height: back_button_radius * 1.4,
          radius: back_button_radius,
          x: 0,
          y: 0,
          z: ZOrder::MAIN_UI
        ),
        build_house: build_house_buttons,
        build_house_arrow: Button.new(
          actions: :build_house,
          color: nil,
          game: game,
          height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
          hover_color: nil,
          hover_image: Image.new(game.images[:arrow_up_hover]),
          image: Image.new(game.images[:arrow_up]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
          width: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
          x: Coordinates::FIRST_HOUSE_BUTTON_X,
          y: Coordinates::FIRST_HOUSE_BUTTON_Y,
          z: ZOrder::MAIN_UI
        ),
        buy: CircularButton.new(
          actions: :buy,
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:positive_green],
          hover_image: Image.new(game.images[:dollar_sign]),
          image: Image.new(game.images[:dollar_sign]),
          image_height: game.class::TOKEN_HEIGHT,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::BUY_BUTTON_X,
          y: Coordinates::BUY_BUTTON_Y,
          z: ZOrder::MAIN_UI
        ),
        house: house_buttons,
        house_with_number: Button.new(
          actions: nil,
          color: nil,
          font: game.fonts[:large][:type],
          font_color: game.colors[:house_count],
          game: game,
          height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
          hover_color: nil,
          hover_image: Image.new(game.images[:house]),
          image: Image.new(game.images[:house]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
          text_relative_position_y: 0.4,
          width: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
          x: Coordinates::FIRST_HOUSE_BUTTON_X,
          y: Coordinates::FIRST_HOUSE_BUTTON_Y + (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35),
          z: ZOrder::MAIN_UI
        ),
        mortgage: Button.new(
          mortgage_lock_button_options.merge(
            actions: :mortgage,
            hover_image: Image.new(game.images[:mortgage_hover]),
            image: Image.new(game.images[:mortgage])
          )
        ),
        mortgage_lock: Button.new(
          mortgage_lock_button_options.merge(
            actions: nil,
            hover_image: Image.new(game.images[:mortgage_lock]),
            image: Image.new(game.images[:mortgage_lock])
          )
        ),
        owner: CircularButton.new(
          actions: proc do
            return unless game.focused_tile.owner

            game.inspected_player = game.focused_tile.owner
            game.toggle_player_inspector
          end,
          game: game,
          hover_color: game.colors[:tile_button_hover],
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::TILE_OWNER_TOKEN_X,
          y: Coordinates::TILE_OWNER_TOKEN_Y,
          z: ZOrder::MAIN_UI
        ),
        sell_house: sell_house_buttons,
        sell_house_arrow: Button.new(
          actions: :sell_house,
          color: nil,
          game: game,
          height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
          hover_color: nil,
          hover_image: Image.new(game.images[:arrow_down_hover]),
          image: Image.new(game.images[:arrow_down]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
          width: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
          x: Coordinates::FIRST_HOUSE_BUTTON_X,
          y: Coordinates::FIRST_HOUSE_BUTTON_Y + (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.45),
          z: ZOrder::MAIN_UI
        ),
        show_deed: CircularButton.new(
          actions: :toggle_deed_menu,
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button_hover],
          hover_image: Image.new(game.images[:blank_deed]),
          image: Image.new(game.images[:blank_deed]),
          image_height: 70,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::BUY_BUTTON_X,
          y: Coordinates::BUY_BUTTON_Y + game.class::DEFAULT_TILE_BUTTON_HEIGHT +
            game.class::TILE_BUTTON_GAP,
          z: ZOrder::MAIN_UI
        ),
        show_group: CircularButton.new(
          actions: proc { game.group_menu.open },
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:positive_green],
          image_height: game.class::TOKEN_HEIGHT,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::BUY_BUTTON_X,
          y: Coordinates::BUY_BUTTON_Y +
            ((game.class::DEFAULT_TILE_BUTTON_HEIGHT + game.class::TILE_BUTTON_GAP) * 2),
          z: ZOrder::MAIN_UI
        ),
        show_players: CircularButton.new(
          actions: proc do
            game.player_list_menu.open(
              game.players.select { |player| player.tile == game.focused_tile }
            )
          end,
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button_hover],
          hover_image: Image.new(game.images[:people]),
          image: Image.new(game.images[:people]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: 0,
          y: 0,
          z: ZOrder::MAIN_UI
        ),
        unmortgage: Button.new(
          mortgage_lock_button_options.merge(
            actions: :unmortgage,
            hover_image: Image.new(game.images[:unmortgage_hover]),
            image: Image.new(game.images[:unmortgage])
          )
        )
      }

      self.coordinates = {
        back: {
          corner: {
            x: Coordinates::BACK_TO_CURRENT_TILE_BUTTON_X +
              (Coordinates::TILE_HEIGHT - Coordinates::TILE_WIDTH) / 2,
            y: Coordinates::BUY_BUTTON_Y -
              ((game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2) - back_button_radius)
          },
          middle: {
            x: Coordinates::BACK_TO_CURRENT_TILE_BUTTON_X,
            y: Coordinates::BACK_TO_CURRENT_TILE_BUTTON_Y
          }
        },
        show_players: {
          corner: {
            x: Coordinates::BUY_BUTTON_X - (Coordinates::TILE_HEIGHT - Coordinates::TILE_WIDTH) / 2,
            y: Coordinates::BUY_BUTTON_Y
          },
          middle: {
            non_property: {
              x: Coordinates::BUY_BUTTON_X,
              y: Coordinates::BUY_BUTTON_Y,
            },
            property: {
              x: Coordinates::BUY_BUTTON_X,
              y: Coordinates::BUY_BUTTON_Y +
                ((game.class::DEFAULT_TILE_BUTTON_HEIGHT + game.class:: TILE_BUTTON_GAP) * 3),
            }
          }
        }
      }

      open
    end

    def draw
      return if game.map_menu.drawing? || game.drawing_card_menu? || game.drawing_pop_up_menu?

      game.focused_tile.tile_image.draw(
        draw_height: Coordinates::TILE_HEIGHT,
        draw_width: game.tile_width(game.focused_tile),
        from_center: true,
        x: Coordinates::CENTER_X,
        y: Coordinates::CENTER_Y,
        z: ZOrder::MAIN_UI
      )

      super
    end

    def open
      update

      super
    end

    def update
      self.visible_buttons = []

      tile_type = game.focused_tile.corner? ? :corner : :middle
      if game.focused_tile != game.current_tile
        x, y = coordinates[:back][tile_type].values_at(:x, :y)
        buttons[:back].update_coordinates(x: x, y: y) unless buttons[:back].x == x &&
          buttons[:back].y == y
        visible_buttons << buttons[:back]
      end

      if game.players.count { |player| player.tile == game.focused_tile }.positive?
        data = coordinates[:show_players][tile_type]
        data = data[game.focused_tile.is_a?(PropertyTile) ? :property : :non_property] if
          tile_type == :middle
        x, y = data.values_at(:x, :y)
        buttons[:show_players].update_coordinates(x: x, y: y) unless
          buttons[:show_players].x == x && buttons[:show_players].y == y
        visible_buttons << buttons[:show_players]
      end

      return unless game.focused_tile.is_a?(PropertyTile)

      visible_buttons << buttons[:show_deed]

      buttons[:show_group].hover_image = game.focused_tile.group.image.clone
      buttons[:show_group].image = game.focused_tile.group.image.clone

      buttons[:show_group].maximize_images_in_square(game.class::TOKEN_HEIGHT)
      visible_buttons << buttons[:show_group]

      if game.focused_tile.owner
        buttons[:owner].hover_image = game.focused_tile.owner.token_image.clone
        buttons[:owner].image = game.focused_tile.owner.token_image.clone
        buttons[:owner].color, buttons[:owner].hover_color =
          if game.focused_tile.group.monopolized?
            game.colors.values_at(:monopoly_button_background, :monopoly_button_background_hover)
          else
            game.colors.values_at(:tile_button, :tile_button_hover)
          end

        buttons[:owner].maximize_images_in_square(game.class::TOKEN_HEIGHT)

        visible_buttons << buttons[:owner]

        if game.focused_tile.owner == game.current_player
          mortgage_button = game.focused_tile.mortgaged? ? :unmortgage : :mortgage
          visible_buttons << buttons[mortgage_button]
        elsif game.focused_tile.mortgaged?
          visible_buttons << buttons[:mortgage_lock]
        end
      elsif focusing_on_landed_tile?
        visible_buttons << buttons[:buy]
      end

      if game.focused_tile.is_a?(StreetTile)
        buttons[:show_group].image_background_color =
          buttons[:show_group].image_background_hover_color = game.focused_tile.group.color
        color = game.focused_tile.group.color
        buttons[:show_group].hover_color = Gosu::Color.new(100, color.red, color.green, color.blue)

        if game.focused_tile.owner == game.current_player
          if game.focused_tile.group.monopolized?
            if game.max_house_count <= game.class::DEFAULT_MAX_HOUSE_COUNT
              visible_buttons.concat(buttons[:sell_house][0...game.focused_tile.house_count])

              visible_buttons << buttons[:build_house][game.focused_tile.house_count] if
                game.focused_tile.house_count < game.max_house_count
            else
              visible_buttons << buttons[:build_house_arrow]
              buttons[:house_with_number].text = game.focused_tile.house_count
              visible_buttons << buttons[:house_with_number]
              visible_buttons << buttons[:sell_house_arrow]
            end
          end
        else
          visible_buttons.concat(buttons[:house][0...game.focused_tile.house_count])
        end
      else
        buttons[:show_group].hover_color = game.colors[:tile_button_hover]
        buttons[:show_group].image_background_color =
          buttons[:show_group].image_background_hover_color = nil
      end

      super
    end

    private

    def focusing_on_landed_tile?
      game.focused_tile == game.current_tile && game.current_player_cache.nil? &&
        game.current_player_landed
    end
  end
end
