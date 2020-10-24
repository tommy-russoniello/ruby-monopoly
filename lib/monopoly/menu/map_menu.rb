module Monopoly
  class MapMenu < Menu
    BUTTON_GAP = Monopoly::Game::DEFAULT_TILE_BUTTON_HEIGHT * 0.05
    BUTTON_HEIGHT = Monopoly::Game::DEFAULT_TILE_BUTTON_HEIGHT * 0.4
    TILES_MAX_WIDTH = Coordinates::RIGHT_X - Coordinates::LEFT_X -
      (Monopoly::Game::DEFAULT_TILE_BUTTON_HEIGHT * 1.8)

    attr_accessor :current_tile
    attr_accessor :current_tile_button
    attr_accessor :first_tile_index
    attr_accessor :last_tile_index
    attr_accessor :max_token_buttons_per_tile
    attr_accessor :player_plus_x_offset_corner
    attr_accessor :player_plus_x_offset_jail
    attr_accessor :player_plus_x_offset_normal
    attr_accessor :show_player_tokens
    attr_accessor :tiles

    def initialize(*)
      super

      tile_center_y =
        game.standard_board? ? Coordinates::CENTER_Y + 50 : Coordinates::MAP_MENU_TILE_CENTER_Y
      transluscent_white = Gosu::Color::WHITE.dup
      transluscent_white.alpha = 220
      toggle_player_tokens_height = game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2
      toggle_player_tokens_params = {
        color: nil,
        font: game.fonts[:default][:type],
        font_color: game.colors[:clickable_text],
        font_hover_color: game.colors[:clickable_text_hover],
        game: game,
        height: toggle_player_tokens_height,
        hover_color: nil,
        image_height: toggle_player_tokens_height * 0.6,
        image_position_x: 0.9,
        text: 'Show player tokens',
        text_position_x: 0,
        text_relative_position_x: 0,
        text_relative_width: 0.8,
        width: toggle_player_tokens_height * 4.5,
        x: Coordinates::RIGHT_X - (toggle_player_tokens_height * 4.5) - 5,
        y: Coordinates::BOTTOM_Y - toggle_player_tokens_height - 5,
        z: ZOrder::MAIN_UI
      }
      mortgage_lock_button_options = {
        color: nil,
        game: game,
        height: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
        hover_color: nil,
        image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
        image_width: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
        width: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
        x: Coordinates::CENTER_X - (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.175),
        y: tile_center_y + (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
        z: ZOrder::MAIN_UI
      }
      self.buttons = {
        back: Button.new(
          actions: proc do
            self.current_tile = nil
            update
          end,
          color: nil,
          game: game,
          height: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          hover_color: nil,
          hover_image: Image.new(game.images[:back]),
          image: Image.new(game.images[:back_alt]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
          width: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X + (Coordinates::MAP_MENU_TILE_WIDTH / 2) - BUTTON_GAP -
            (game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2),
          y: tile_center_y + (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          z: ZOrder::MAIN_UI
        ),
        build_house: Button.new(
          actions: proc { game.build_house(current_tile) },
          color: nil,
          game: game,
          height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.175,
          hover_color: nil,
          hover_image: Image.new(game.images[:arrow_up_hover]),
          image: Image.new(game.images[:arrow_up]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.175,
          width: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X - (game.class::DEFAULT_TILE_BUTTON_HEIGHT / 4),
          y: tile_center_y - (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 2.025),
          z: ZOrder::MAIN_UI
        ),
        close: Button.new(
          actions: proc { close },
          color: nil,
          game: game,
          height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.4,
          hover_color: nil,
          hover_image: Image.new(game.images[:x_hover]),
          image: Image.new(game.images[:x]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.4,
          width: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.4,
          x: Coordinates::LEFT_X + 5,
          y: Coordinates::TOP_Y + 5,
          z: ZOrder::MAIN_UI
        ),
        house: Button.new(
          actions: nil,
          color: nil,
          font: game.fonts[:large][:type],
          font_color: game.colors[:house_count],
          game: game,
          height: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          hover_color: nil,
          hover_image: Image.new(game.images[:house]),
          image: Image.new(game.images[:house]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          text_relative_position_y: 0.4,
          width: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X - (game.class::DEFAULT_TILE_BUTTON_HEIGHT / 4),
          y: tile_center_y - (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.85),
          z: ZOrder::MAIN_UI
        ),
        money: Button.new(
          actions: nil,
          color: nil,
          font: game.fonts[:title][:type],
          font_color: game.colors[:clickable_text],
          game: game,
          height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
          hover_color: nil,
          text_position_x: 0.05,
          text_relative_position_x: 0,
          text_relative_width: 0.95,
          width: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 3,
          x: Coordinates::LEFT_X + game.class::DEFAULT_TILE_BUTTON_HEIGHT +
            (game.class::DEFAULT_TILE_BUTTON_BORDER_WIDTH * 2),
          y: Coordinates::BOTTOM_Y - game.class::DEFAULT_TILE_BUTTON_HEIGHT -
            game.class::DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          z: ZOrder::MAIN_UI
        ),
        mortgage: Button.new(
          mortgage_lock_button_options.merge(
            actions: proc { game.mortgage(current_tile) },
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
        open_in_tile_menu: Button.new(
          actions: proc do
            game.focused_tile = current_tile
            game.tile_menu.update
            close
          end,
          color: nil,
          game: game,
          height: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          hover_color: nil,
          hover_image: Image.new(game.images[:expand_hover]),
          image: Image.new(game.images[:expand]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
          width: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X + (Coordinates::MAP_MENU_TILE_WIDTH / 2) - BUTTON_GAP -
            (game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2),
          y: tile_center_y + (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.75) - BUTTON_GAP,
          z: ZOrder::MAIN_UI
        ),
        owner: CircularButton.new(
          actions: proc do
            return unless current_tile.owner

            game.inspected_player = current_tile.owner
            game.toggle_player_inspector
          end,
          game: game,
          hover_color: game.colors[:tile_button_hover],
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X - (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          y: tile_center_y - (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          z: ZOrder::MAIN_UI
        ),
        player_token: CircularButton.new(
          actions: proc do
            game.inspected_player = game.current_player
            game.toggle_player_inspector
          end,
          border_color: game.colors[:pop_up_menu_border],
          border_hover_color: game.colors[:pop_up_menu_border],
          border_width: game.class::DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          color: game.colors[:pop_up_menu_background_light],
          game: game,
          hover_color: game.colors[:pop_up_menu_background_light_hover],
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::LEFT_X + (game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2) +
            game.class::DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          y: Coordinates::BOTTOM_Y - (game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2) -
            game.class::DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          z: ZOrder::MAIN_UI
        ),
        player_tokens_hide: Button.new(
          toggle_player_tokens_params.merge(
            actions: proc do
              show_player_tokens[game.current_player] = false
              update
            end,
            hover_image: Image.new(game.images[:checkbox_checked_hover]),
            image: Image.new(game.images[:checkbox_checked])
          )
        ),
        player_tokens_show: Button.new(
          toggle_player_tokens_params.merge(
            actions: proc do
              show_player_tokens[game.current_player] = true
              update
            end,
            hover_image: Image.new(game.images[:checkbox_unchecked_hover]),
            image: Image.new(game.images[:checkbox_unchecked])
          )
        ),
        sell_house: Button.new(
          actions: proc { game.sell_house(current_tile) },
          color: nil,
          game: game,
          height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.175,
          hover_color: nil,
          hover_image: Image.new(game.images[:arrow_down_hover]),
          image: Image.new(game.images[:arrow_down]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.175,
          width: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X - (game.class::DEFAULT_TILE_BUTTON_HEIGHT / 4),
          y: tile_center_y - (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.3),
          z: ZOrder::MAIN_UI
        ),
        show_deed: CircularButton.new(
          actions: proc { game.deed_menu.open },
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button_hover],
          hover_image: Image.new(game.images[:blank_deed]),
          image: Image.new(game.images[:blank_deed]),
          image_height: 70,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X + (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          y: tile_center_y + (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          z: ZOrder::MAIN_UI
        ),
        show_group: CircularButton.new(
          actions: proc { game.group_menu.open(current_tile.group.tiles) },
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:positive_green],
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X + (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          y: tile_center_y - (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          z: ZOrder::MAIN_UI
        ),
        show_players: CircularButton.new(
          actions: proc do
            game.player_list_menu.open(game.players.select { |player| player.tile == current_tile })
          end,
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button_hover],
          hover_image: Image.new(game.images[:people]),
          image: Image.new(game.images[:people]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X - (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          y: tile_center_y + (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.25),
          z: ZOrder::MAIN_UI
        ),
        tile_icon: CircularButton.new(
          actions: nil,
          border_color: game.colors[:pop_up_menu_border],
          border_hover_color: game.colors[:pop_up_menu_border],
          border_width: game.class::DEFAULT_TILE_BUTTON_BORDER_WIDTH,
          color: game.colors[:pop_up_menu_background_light],
          game: game,
          hover_color: game.colors[:pop_up_menu_background_light],
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
          x: Coordinates::CENTER_X,
          y: tile_center_y,
          z: ZOrder::MAIN_UI
        ),
        tile_name: Button.new(
          actions: nil,
          color: nil,
          font: game.fonts[:big_title][:type],
          font_color: game.colors[:clickable_text],
          game: game,
          height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
          hover_color: nil,
          width: Coordinates::MAP_MENU_TILE_WIDTH - (BUTTON_GAP * 2),
          x: Coordinates::CENTER_X - (Coordinates::MAP_MENU_TILE_WIDTH / 2) + BUTTON_GAP,
          y: tile_center_y - (Coordinates::MAP_MENU_TILE_HEIGHT / 2),
          z: ZOrder::MAIN_UI
        ),
        tokens: game.players.map do |player|
          button = CircularButton.new(
            actions: nil,
            color: transluscent_white,
            game: game,
            hover_color: transluscent_white,
            hover_image: player.token_image.clone,
            image: player.token_image.clone,
            radius: BUTTON_HEIGHT / 2,
            z: ZOrder::MAIN_UI
          )
          button.maximize_images_in_square(BUTTON_HEIGHT * 0.7)
          [player, button]
        end.to_h,
        unmortgage: Button.new(
          mortgage_lock_button_options.merge(
            actions: proc { game.unmortgage(current_tile) },
            hover_image: Image.new(game.images[:unmortgage_hover]),
            image: Image.new(game.images[:unmortgage])
          )
        )
      }

      tile_height = (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.4).round
      tile_width = (tile_height / (Coordinates::TILE_HEIGHT / Coordinates::TILE_WIDTH.to_f)).to_i
      owner_button_radius = (tile_width * 0.325).round
      edge_length = (tile_width * 9) + (tile_height * 2)

      inner_rectangle_length = edge_length - (tile_height * 2) + 2
      inner_rectangle_width = owner_button_radius + 2
      self.max_token_buttons_per_tile = {
        jail: 4,
        jail_visiting: 5,
        normal: 4
      }
      self.player_plus_x_offset_corner = tile_height * (5 / 6.0)
      self.player_plus_x_offset_jail = tile_height / 2
      self.player_plus_x_offset_normal = tile_width * 0.74
      self.show_player_tokens = game.players.map { |player| [player, true] }.to_h

      self.rectangles = {
        background: {
          color: game.colors[:pop_up_menu_background],
          height: Coordinates::BOTTOM_Y - Coordinates::TOP_Y,
          width: Coordinates::RIGHT_X - Coordinates::LEFT_X,
          x: Coordinates::LEFT_X,
          y: Coordinates::TOP_Y,
          z: ZOrder::MAIN_BACKGROUND
        }
      }

      # Inner map border
      if game.standard_board?
        rectangles.merge!(
          inner_border_top: {
            color: game.colors[:pop_up_menu_border],
            height: inner_rectangle_width,
            width: inner_rectangle_length,
            x: Coordinates::CENTER_X - (edge_length / 2) + tile_height - 1,
            y: Coordinates::CENTER_Y - (edge_length / 2) + tile_height - 1,
            z: ZOrder::MAIN_BACKGROUND
          },
          inner_border_left: {
            color: game.colors[:pop_up_menu_border],
            height: inner_rectangle_length,
            width: inner_rectangle_width,
            x: Coordinates::CENTER_X - (edge_length / 2) + tile_height - 1,
            y: Coordinates::CENTER_Y - (edge_length / 2) + tile_height - 1,
            z: ZOrder::MAIN_BACKGROUND
          },
          inner_border_right: {
            color: game.colors[:pop_up_menu_border],
            height: inner_rectangle_length,
            width: inner_rectangle_width,
            x: Coordinates::CENTER_X + (edge_length / 2) - tile_height -
              owner_button_radius - 1,
            y: Coordinates::CENTER_Y - (edge_length / 2) + tile_height - 1,
            z: ZOrder::MAIN_BACKGROUND
          },
          inner_border_bottom: {
            color: game.colors[:pop_up_menu_border],
            height: inner_rectangle_width,
            width: inner_rectangle_length,
            x: Coordinates::CENTER_X - (edge_length / 2) + tile_height - 1,
            y: Coordinates::CENTER_Y + (edge_length / 2) - tile_height - owner_button_radius - 1,
            z: ZOrder::MAIN_BACKGROUND
          }
        )
      end

      tile_button_params = {
        color: nil,
        game: game,
        height: tile_height,
        highlight_hover_color: game.colors[:default_button_hover_highlight],
        hover_color: nil,
        image_height: tile_height,
        z: ZOrder::MAIN_UI
      }

      house_height = tile_height * 0.12
      houses_button_params = {
        actions: nil,
        color: nil,
        font: game.fonts[:default][:type],
        font_color: game.colors[:house_count],
        game: game,
        height: house_height,
        hover_color: nil,
        image_height: house_height,
        width: tile_width,
        z: ZOrder::MAIN_UI
      }

      # TODO: Update this check once hotels are implemented
      if game.max_house_count >= game.class::DEFAULT_MAX_HOUSE_COUNT
        houses_button_params.merge!(
          font: game.fonts[:small][:type],
          font_color: game.colors[:house_count],
          height: house_height * 1.5,
          hover_image: Image.new(game.images[:house]),
          image: Image.new(game.images[:house]),
          image_height: house_height * 1.5,
          text_relative_position_y: 0.4,
          text_relative_width: 0.85,
          width: house_height * 1.5
        )
      end

      owner_button_params = {
        actions: nil,
        color: Gosu::Color::WHITE,
        game: game,
        hover_color: nil,
        radius: owner_button_radius,
        z: ZOrder::MAIN_UI
      }

      transluscent_warning = game.colors[:warning].dup
      transluscent_warning.alpha = 50
      mortgage_lock_button_params = {
        actions: nil,
        color: transluscent_warning,
        game: game,
        hover_color: transluscent_warning,
        hover_image: Image.new(game.images[:mortgage_lock]),
        image: Image.new(game.images[:mortgage_lock]),
        image_height: BUTTON_HEIGHT * 0.43,
        radius: BUTTON_HEIGHT * 0.3,
        z: ZOrder::MAIN_UI
      }

      player_plus_button_params = {
        actions: nil,
        color: transluscent_white,
        font: game.fonts[:default][:type],
        font_color: game.colors[:default_text],
        game: game,
        hover_color: transluscent_white,
        radius: BUTTON_HEIGHT / 2,
        z: ZOrder::MAIN_UI
      }

      if game.standard_board?
        buttons[:rotate_clockwise] = CircularButton.new(
          actions: [
            proc do
              return unless drawing?

              self.first_tile_index = (first_tile_index - 10) % 40
              update(refresh: true)
            end
          ],
          color: nil,
          game: game,
          hover_color: nil,
          hover_image: Image.new(game.images[:rotate_clockwise_hover]),
          image: Image.new(game.images[:rotate_clockwise]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.75,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X + ((edge_length + game.class::DEFAULT_TILE_BUTTON_HEIGHT) / 2) +
            (BUTTON_GAP * 3),
          y: Coordinates::CENTER_Y,
          z: ZOrder::MAIN_UI
        )
        buttons[:rotate_counterclockwise] = CircularButton.new(
          actions: [
            proc do
              return unless drawing?

              self.first_tile_index = (first_tile_index + 10) % 40
              update(refresh: true)
            end
          ],
          color: nil,
          game: game,
          hover_color: nil,
          hover_image: Image.new(game.images[:rotate_counterclockwise_hover]),
          image: Image.new(game.images[:rotate_counterclockwise]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.75,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
          x: Coordinates::CENTER_X - ((edge_length + game.class::DEFAULT_TILE_BUTTON_HEIGHT) / 2) -
            (BUTTON_GAP * 3),
          y: Coordinates::CENTER_Y,
          z: ZOrder::MAIN_UI
        )

        offsets = {
          houses: {
            0 => {
              x: tile_width / 2,
              y:
                # TODO: Update this check once hotels are implemented
                if game.max_house_count < game.class::DEFAULT_MAX_HOUSE_COUNT
                  (tile_height * 0.05) + (houses_button_params[:height] / 2)
                else
                  (tile_height * 0.02) + (houses_button_params[:height] / 2)
                end
            }
          },
          mortgage_lock: {
            0 => {
              x: tile_width - BUTTON_GAP - mortgage_lock_button_params[:radius],
              y: tile_height - BUTTON_GAP - mortgage_lock_button_params[:radius]
            }
          },
          owner: {
            0 => {
              data: { image_position_y: 0.275 },
              x: tile_width / 2,
              y: 0
            },
            90 => {
              data: { image_position_x: 0.725 }
            },
            180 => {
              data: { image_position_y: 0.725 }
            },
            270 => {
              data: { image_position_x: 0.275 }
            }
          }
        }

        offsets.each do |button_name, data|
          x = data[0][:x]
          y = data[0][:y]
          data.deep_merge!(
            90 => { x: tile_height - y, y: x },
            180 => { x: tile_width - x, y: tile_height - y },
            270 => { x: y, y: tile_width - x }
          )
        end

        top = Coordinates::CENTER_Y - (edge_length / 2)
        bottom = Coordinates::CENTER_Y + (edge_length / 2)
        left = Coordinates::CENTER_X - (edge_length / 2)
        right = Coordinates::CENTER_X + (edge_length / 2)

        angle = 270
        x = right - tile_height
        y = bottom - tile_height
        tile_button_image_width = 0
        update_buttom_params = proc do
          case angle
          when 0
            x -= tile_button_image_width
          when 90
            y -= tile_button_image_width
          when 180
            x += tile_button_image_width
          when 270
            y += tile_button_image_width
          end
        end

        buttons[:tiles] = game.tile_indexes.sort_by { |_, index| index }.map do |tile, index|
          tile_button_image_width = tile.corner? ? tile_height : tile_width
          tile_button_height = tile_height
          tile_button_width = tile_button_image_width

          if angle % 180 == 0
            houses_height = houses_button_params[:height]
            houses_width = houses_button_params[:width]
          else
            houses_height = houses_button_params[:width]
            houses_width = houses_button_params[:height]
            tile_button_height, tile_button_width = tile_button_width, tile_button_height
          end

          update_buttom_params.call if angle < 180
          angle = (angle + 90) % 360 if index % 10 == 0

          action = proc do
            if current_tile == tiles[index]
              self.current_tile = nil
              update
            else
              game.display_tile(tiles[index])
            end
          end

          hash = {
            houses: Button.new(
              houses_button_params.merge(
                actions: action,
                height: houses_height,
                image_angle: angle,
                text_angle: angle,
                width: houses_width,
                x: x + offsets[:houses][angle][:x] - (houses_width / 2),
                y: y + offsets[:houses][angle][:y] - (houses_height / 2)
              )
            ),
            mortgage_lock: CircularButton.new(
              mortgage_lock_button_params.merge(
                actions: action,
                image_angle: angle,
                x: x + offsets[:mortgage_lock][angle][:x],
                y: y + offsets[:mortgage_lock][angle][:y]
              )
            ),
            owner: CircularButton.new(
              owner_button_params
                .merge(offsets[:owner][angle][:data])
                .merge(
                  actions: action,
                  image_angle: angle,
                  x: x + offsets[:owner][angle][:x],
                  y: y + offsets[:owner][angle][:y]
                )
            ),
            player_plus: CircularButton.new(
              player_plus_button_params.merge(actions: action)
            ),
            player_plus_visiting_jail: CircularButton.new(
              player_plus_button_params.merge(actions: action)
            ),
            tile: Button.new(
              tile_button_params.merge(
                actions: action,
                height: tile_button_height,
                hover_image: tile.tile_image.clone,
                image: tile.tile_image.clone,
                image_angle: angle,
                image_width: tile_button_image_width,
                width: tile_button_width,
                x: x,
                y: y
              )
            )
          }

          update_buttom_params.call if angle >= 180

          hash
        end
      else
        buttons[:left] = CircularButton.new(
          actions: [
            proc do
              return unless drawing?

              self.last_tile_index = nil
              self.first_tile_index = (game.tile_indexes[tiles.first] - 1) % game.tile_count
              update(refresh: true)
            end
          ],
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button],
          hover_image: Image.new(game.images[:arrow_left_hover]),
          image: Image.new(game.images[:arrow_left]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.4,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.3,
          x: Coordinates::LEFT_X + game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.3 + 5,
          y: Coordinates::MAP_MENU_CENTER_Y - (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35),
          z: ZOrder::MAIN_UI
        )
        buttons[:page_left] = CircularButton.new(
          actions: [
            proc do
              return unless drawing?

              self.last_tile_index = nil
              self.first_tile_index = (game.tile_indexes[tiles.first] - 10) % game.tile_count
              update(refresh: true)
            end
          ],
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button],
          hover_image: Image.new(game.images[:double_arrow_left_hover]),
          image: Image.new(game.images[:double_arrow_left]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.4,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.3,
          x: Coordinates::LEFT_X + game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.3 + 5,
          y: Coordinates::MAP_MENU_CENTER_Y + (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35),
          z: ZOrder::MAIN_UI
        )
        buttons[:page_right] = CircularButton.new(
          actions: [
            proc do
              return unless drawing?

              self.first_tile_index = nil
              self.last_tile_index = (game.tile_indexes[tiles.last] + 10) % game.tile_count
              update(refresh: true)
            end
          ],
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button],
          hover_image: Image.new(game.images[:double_arrow_right_hover]),
          image: Image.new(game.images[:double_arrow_right]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.4,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.3,
          x: Coordinates::RIGHT_X - game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.3 - 5,
          y: Coordinates::MAP_MENU_CENTER_Y + (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35),
          z: ZOrder::MAIN_UI
        )
        buttons[:right] = CircularButton.new(
          actions: [
            proc do
              return unless drawing?

              self.first_tile_index = nil
              self.last_tile_index = (game.tile_indexes[tiles.last] + 1) % game.tile_count
              update(refresh: true)
            end
          ],
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button],
          hover_image: Image.new(game.images[:arrow_right_hover]),
          image: Image.new(game.images[:arrow_right]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.4,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.3,
          x: Coordinates::RIGHT_X - game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.3 - 5,
          y: Coordinates::MAP_MENU_CENTER_Y - (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35),
          z: ZOrder::MAIN_UI
        )

        # Make enough buttons to handle the maximum amount that can fit on the screen
        buttons[:tiles] = (TILES_MAX_WIDTH / tile_width).floor.times.map do |number|
          action = proc do
            if current_tile == tiles[number]
              self.current_tile = nil
              update
            else
              game.display_tile(tiles[number])
            end
          end

          {
            houses: Button.new(
              houses_button_params.merge(
                actions: action,
                y:
                  # TODO: Update this check once hotels are implemented
                  if game.max_house_count < game.class::DEFAULT_MAX_HOUSE_COUNT
                    Coordinates::MAP_MENU_CENTER_Y - (tile_height * 0.45)
                  else
                    Coordinates::MAP_MENU_CENTER_Y - (tile_height * 0.48)
                  end
              )
            ),
            mortgage_lock: CircularButton.new(
              mortgage_lock_button_params.merge(
                actions: action,
                y: Coordinates::MAP_MENU_CENTER_Y + (tile_height / 2) -
                  BUTTON_GAP - mortgage_lock_button_params[:radius]
              )
            ),
            owner: CircularButton.new(
              owner_button_params.merge(
                actions: action,
                image_position_y: 0.275,
                y: Coordinates::MAP_MENU_CENTER_Y - (tile_height / 2)
              )
            ),
            player_plus: CircularButton.new(
              player_plus_button_params.merge(
                actions: action,
                y: Coordinates::MAP_MENU_CENTER_Y + (BUTTON_HEIGHT) + BUTTON_GAP
              )
            ),
            player_plus_visiting_jail: CircularButton.new(
              player_plus_button_params.merge(
                actions: action,
                y: Coordinates::MAP_MENU_CENTER_Y
              )
            ),
            tile: Button.new(
              tile_button_params.merge(
                actions: action,
                y: Coordinates::MAP_MENU_CENTER_Y - (tile_height / 2),
              )
            )
          }
        end
      end
    end

    def close
      self.current_tile = nil
      self.current_tile_button = nil
      self.first_tile_index = nil
      self.last_tile_index = nil
      self.tiles = nil

      game.action_menu.update
      game.set_visible_card_menu_buttons
      game.set_visible_compass_menu_buttons
      game.set_visible_player_menu_buttons
      game.tile_menu.update

      super
    end

    def draw
      return unless drawing?

      super

      draw_current_tile_button_border if current_tile_button
    end

    def open
      game.close_pop_up_menus
      self.first_tile_index = game.standard_board? ? 0 : game.tile_indexes[game.focused_tile]

      update(refresh: true)
      super
    end

    def update(refresh: false)
      self.visible_buttons = []
      self.current_tile_button = nil

      visible_buttons << buttons[:close]

      buttons[:player_token].hover_image = game.current_player.token_image.clone
      buttons[:player_token].image = game.current_player.token_image.clone
      buttons[:player_token].maximize_images_in_square(game.class::TOKEN_HEIGHT)
      visible_buttons << buttons[:player_token]

      buttons[:money].text = game.format_money(game.current_player.money)
      visible_buttons << buttons[:money]

      visible_buttons <<
        if show_player_tokens[game.current_player]
          buttons[:player_tokens_hide]
        else
          buttons[:player_tokens_show]
        end

      if game.standard_board?
        visible_buttons << buttons[:rotate_clockwise]
        visible_buttons << buttons[:rotate_counterclockwise]

        self.tiles = []
        (
          (first_tile_index...game.tile_count).to_a + (0...first_tile_index).to_a
        ).each.with_index do |tile_index, index|
          tile = game.tiles[tile_index]
          tiles << tile
          tile_buttons = buttons[:tiles][index]
          self.current_tile_button = tile_buttons[:tile] if tile == current_tile

          if refresh
            tile_buttons[:tile].image = tile.tile_image.clone
            tile_buttons[:tile].hover_image = tile.tile_image.clone
          end

          if tile.is_a?(PropertyTile) && tile.owner
            tile_buttons[:owner].image = tile.owner.token_image.clone
            tile_buttons[:owner].hover_image = tile.owner.token_image.clone
            tile_buttons[:owner].maximize_images_in_square(BUTTON_HEIGHT * 0.625)
            visible_buttons << tile_buttons[:owner]
            visible_buttons << tile_buttons[:tile]

            visible_buttons << tile_buttons[:mortgage_lock] if tile.mortgaged?

            if tile.group.monopolized?
              tile_buttons[:owner].color = tile_buttons[:owner].hover_color =
                game.colors[:positive_green]

              if tile.is_a?(StreetTile) && tile.house_count.positive?
                # TODO: Update this check once hotels are implemented
                if game.max_house_count < game.class::DEFAULT_MAX_HOUSE_COUNT
                  image = game.images[:"houses_#{tile.house_count}"]
                  tile_buttons[:houses].image = Image.new(image)
                  tile_buttons[:houses].hover_image = Image.new(image)
                else
                  tile_buttons[:houses].text = tile.house_count
                end

                visible_buttons << tile_buttons[:houses]
              end
            else
              tile_buttons[:owner].color = tile_buttons[:owner].hover_color = Gosu::Color::WHITE
            end
          else
            visible_buttons << tile_buttons[:tile]
          end

          set_token_buttons(tile_buttons: tile_buttons, tile: tile) if
            show_player_tokens[game.current_player]
        end
      else
        ratio = Coordinates::TILE_HEIGHT / (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.4)

        total_width = 0
        tile_index = first_tile_index || last_tile_index
        next_tile_width = game.tile_width(game.tiles[tile_index]) / ratio
        tiles_to_draw = []
        while total_width + next_tile_width < TILES_MAX_WIDTH
          tile = game.tiles[tile_index]
          total_width += next_tile_width

          increment =
            if first_tile_index
              tiles_to_draw << tile
              1
            else
              tiles_to_draw.unshift(tile)
              -1
            end

          tile_index = (tile_index + increment) % game.tile_count
          next_tile_width = game.tile_width(game.tiles[tile_index]) / ratio
        end

        initial_x = Coordinates::CENTER_X - (total_width / 2)
        offset = 0
        tiles_to_draw.each.with_index do |tile, index|
          tile_buttons = buttons[:tiles][index]
          self.current_tile_button = tile_buttons[:tile] if tile == current_tile
          x = initial_x + offset
          tile_width = game.tile_width(tile) / ratio
          if refresh
            tile_buttons[:tile].image = tile.tile_image.clone
            tile_buttons[:tile].hover_image = tile.tile_image.clone
            tile_buttons[:tile].width = tile_buttons[:tile].image_width = tile_width
            tile_buttons[:tile].hover_image_width = tile_width
            tile_buttons[:tile].update_coordinates(x: x)
          end

          if tile.is_a?(PropertyTile) && tile.owner
            tile_buttons[:owner].image = tile.owner.token_image.clone
            tile_buttons[:owner].hover_image = tile.owner.token_image.clone
            tile_buttons[:owner].maximize_images_in_square(BUTTON_HEIGHT * 0.625)
            center_of_tile_x = tile_buttons[:tile].x + (tile_width / 2)
            tile_buttons[:owner].update_coordinates(x: center_of_tile_x)
            visible_buttons << tile_buttons[:owner]
            visible_buttons << tile_buttons[:tile]

            if tile.mortgaged?
              tile_buttons[:mortgage_lock].update_coordinates(
                x: tile_buttons[:tile].x + tile_buttons[:tile].width - BUTTON_GAP -
                  tile_buttons[:mortgage_lock].radius
              )
              visible_buttons << tile_buttons[:mortgage_lock]
            end

            if tile.group.monopolized?
              tile_buttons[:owner].color = tile_buttons[:owner].hover_color =
                game.colors[:positive_green]

              if tile.is_a?(StreetTile) && tile.house_count.positive?
                # TODO: Update this check once hotels are implemented
                if game.max_house_count < game.class::DEFAULT_MAX_HOUSE_COUNT
                  image = game.images[:"houses_#{tile.house_count}"]
                  tile_buttons[:houses].image = Image.new(image)
                  tile_buttons[:houses].hover_image = Image.new(image)
                else
                  tile_buttons[:houses].text = tile.house_count
                end

                tile_buttons[:houses].update_coordinates(
                  x: center_of_tile_x - (tile_buttons[:houses].width / 2)
                )
                visible_buttons << tile_buttons[:houses]
              end
            else
              tile_buttons[:owner].color = tile_buttons[:owner].hover_color = Gosu::Color::WHITE
            end
          else
            visible_buttons << tile_buttons[:tile]
          end

          set_token_buttons(tile_buttons: tile_buttons, tile: tile) if
            show_player_tokens[game.current_player]

          offset += tile_width
        end

        if tiles_to_draw.size < game.tile_count
          visible_buttons << buttons[:left]
          visible_buttons << buttons[:page_left]
          visible_buttons << buttons[:page_right]
          visible_buttons << buttons[:right]
        end

        self.tiles = tiles_to_draw
      end

      if current_tile
        visible_buttons << buttons[:back]
        visible_buttons << buttons[:open_in_tile_menu]

        buttons[:tile_name].text = current_tile.name
        visible_buttons << buttons[:tile_name]

        if current_tile.icon
          buttons[:tile_icon].hover_image = current_tile.icon.clone
          buttons[:tile_icon].image = current_tile.icon.clone
        else
          buttons[:tile_icon].hover_image = current_tile.tile_image.clone
          buttons[:tile_icon].image = current_tile.tile_image.clone
        end

        buttons[:tile_icon].maximize_images_in_square(game.class::TOKEN_HEIGHT * 2)

        buttons[:tile_icon].border_color =
          buttons[:tile_icon].border_hover_color =
            if current_tile.is_a?(StreetTile)
              current_tile.group.color
            else
              game.colors[:pop_up_menu_border]
            end

        visible_buttons << buttons[:tile_icon]

        visible_buttons << buttons[:show_players] if
          game.players.count { |player| player.tile == current_tile }.positive?

        if current_tile.is_a?(PropertyTile)
          tiles.each.with_index do |tile, index|
            buttons[:tiles][index][:tile].highlight_color =
              if current_tile.group.tiles.include?(tile)
                if current_tile.group.is_a?(ColorGroup)
                  color = current_tile.group.color
                  Gosu::Color.new(100, color.red, color.green, color.blue)
                else
                  game.colors[:tile_button_hover]
                end
              else
                nil
              end
          end

          buttons[:show_group].hover_image = current_tile.group.image.clone
          buttons[:show_group].image = current_tile.group.image.clone
          buttons[:show_group].maximize_images_in_square(game.class::TOKEN_HEIGHT)
          visible_buttons << buttons[:show_group]

          visible_buttons << buttons[:show_deed]

          if current_tile.owner
            buttons[:owner].hover_image = current_tile.owner.token_image.clone
            buttons[:owner].image = current_tile.owner.token_image.clone
            buttons[:owner].color, buttons[:owner].hover_color =
              if current_tile.group.monopolized?
                game.colors.values_at(
                  :monopoly_button_background,
                  :monopoly_button_background_hover
                )
              else
                game.colors.values_at(:tile_button, :tile_button_hover)
              end

            buttons[:owner].maximize_images_in_square(game.class::TOKEN_HEIGHT)
            visible_buttons << buttons[:owner]

            if current_tile.owner == game.current_player
              mortgage_button = current_tile.mortgaged? ? :unmortgage : :mortgage
              visible_buttons << buttons[mortgage_button]
            elsif current_tile.mortgaged?
              visible_buttons << buttons[:mortgage_lock]
            end
          end

          if current_tile.is_a?(StreetTile)
            color = current_tile.group.color
            buttons[:show_group].image_background_color = color
            buttons[:show_group].image_background_hover_color = color
            buttons[:show_group].hover_color =
              Gosu::Color.new(100, color.red, color.green, color.blue)

            if current_tile.group.monopolized?
              buttons[:house].text = current_tile.house_count
              visible_buttons << buttons[:house]

              if current_tile.owner == game.current_player
                visible_buttons << buttons[:build_house]
                visible_buttons << buttons[:sell_house]
              end
            end
          else
            buttons[:show_group].hover_color = game.colors[:tile_button_hover]
            buttons[:show_group].image_background_color = nil
            buttons[:show_group].image_background_hover_color = nil
          end
        else
          buttons[:tiles].each { |tile_buttons| tile_buttons[:tile].highlight_color = nil }
        end
      else
        buttons[:tiles].each { |tile_buttons| tile_buttons[:tile].highlight_color = nil }
      end

      super()
    end

    private

    def draw_current_tile_button_border
      color = game.colors[:neutral_yellow]
      width = 5

      Gosu.draw_rect(
        color: color,
        height: width,
        width: current_tile_button.width,
        x: current_tile_button.x,
        y: current_tile_button.y,
        z: ZOrder::MAIN_UI
      )
      Gosu.draw_rect(
        color: color,
        height: width,
        width: current_tile_button.width,
        x: current_tile_button.x,
        y: current_tile_button.y + current_tile_button.height - width,
        z: ZOrder::MAIN_UI
      )
      Gosu.draw_rect(
        color: color,
        height: current_tile_button.height,
        width: width,
        x: current_tile_button.x,
        y: current_tile_button.y,
        z: ZOrder::MAIN_UI
      )
      Gosu.draw_rect(
        color: color,
        height: current_tile_button.height,
        width: width,
        x: current_tile_button.x + current_tile_button.width - width,
        y: current_tile_button.y,
        z: ZOrder::MAIN_UI
      )
    end

    def set_token_buttons(tile_buttons:, tile:)
      players_to_show = game.players.select { |player| player.tile == tile }
      players_to_show.each do |player|
        buttons[:tokens][player].actions = tile_buttons[:tile].actions
      end

      if tile.is_a?(JailTile) && tile.corner?
        players_in_jail, players_just_visiting =
          players_to_show.partition { |player| player.in_jail? }

        set_token_buttons_helper(
          jail: true,
          maximum_players: max_token_buttons_per_tile[:jail],
          player_plus_button: tile_buttons[:player_plus],
          players_to_show: players_in_jail,
          tile_button: tile_buttons[:tile]
        )
        set_token_buttons_helper(
          jail: true,
          maximum_players: max_token_buttons_per_tile[:jail_visiting],
          player_plus_button: tile_buttons[:player_plus_visiting_jail],
          players_to_show: players_just_visiting,
          tile_button: tile_buttons[:tile],
          visiting: true
        )
      else
        set_token_buttons_helper(
          maximum_players: max_token_buttons_per_tile[:normal],
          player_plus_button: tile_buttons[:player_plus],
          players_to_show: players_to_show,
          tile_button: tile_buttons[:tile]
        )
      end
    end

    def set_token_buttons_helper(
      jail: false,
      maximum_players:,
      player_plus_button:,
      players_to_show:,
      tile_button:,
      visiting: false
    )
      total_players = players_to_show.size
      buttons_to_align = []
      if players_to_show.size > maximum_players
        not_shown_players = players_to_show.size - (maximum_players - 1)
        players_to_show = players_to_show.first(maximum_players - 1)
        player_plus_button.text = "+#{not_shown_players}"
        buttons_to_align += [player_plus_button]
      end

      buttons_to_align =
        buttons[:tokens].values_at(*players_to_show) + buttons_to_align
      buttons_to_align.each.with_index do |button, index|
        button.update_coordinates(
          token_coordinates(
            jail: jail,
            count: total_players,
            number: index + 1,
            tile_button: tile_button,
            visiting: visiting
          )
        )

        visible_buttons << button
      end
    end

    def token_coordinates(count:, jail: false, number:, tile_button:, visiting: false)
      if visiting
        offset = BUTTON_HEIGHT + (BUTTON_GAP * 1.5)
        x, y =
          case number
          when 1
            [-offset, offset]
          when 2
            [offset, -offset]
          when 3
            [0, offset]
          when 4
            [offset, 0]
          end

        x = y = offset if count == 1 || number == 5
        x += tile_button.height / 2
        y += tile_button.height / 2

        case tile_button.image_angle
        when 90
          x = tile_button.width - x
        when 180
          x = tile_button.width - x
          y = tile_button.height - y
        when 270
          y = tile_button.height - y
        end
      else
        offset = (BUTTON_HEIGHT + BUTTON_GAP / 2) / 2
        x = tile_button.width / 2
        if number.even?
          x += offset
        elsif count != number
          x -= offset
        end

        y = tile_button.height / 2
        y += number > 2 ? offset : -offset if count > 2

        if jail
          case tile_button.image_angle
          when 0
            x -= offset
            y -= offset
          when 90
            x += offset
            y -= offset
          when 180
            x += offset
            y += offset
          when 270
            x -= offset
            y += offset
          end
        end
      end

      { x: tile_button.x + x, y: tile_button.y + y }
    end
  end
end
