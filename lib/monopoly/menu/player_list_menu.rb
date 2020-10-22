module Monopoly
  class PlayerListMenu < Menu
    attr_accessor :initial_x
    attr_accessor :players
    attr_accessor :x_offset

    def initialize(*)
      super

      button_gap = game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.075
      token_y = Coordinates::PLAYER_LIST_MENU_TOP_Y + (Coordinates::PLAYER_LIST_MENU_HEIGHT / 3)
      self.buttons = {
        close: Button.new(
          actions: proc { close },
          color: nil,
          game: game,
          height: 40,
          hover_color: nil,
          hover_image: Image.new(game.images[:x_hover]),
          image: Image.new(game.images[:x]),
          image_height: 40,
          width: 40,
          x: Coordinates::PLAYER_LIST_MENU_LEFT_X + Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH + 5,
          y: Coordinates::PLAYER_LIST_MENU_TOP_Y + Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH + 5,
          z: ZOrder::POP_UP_MENU_UI
        ),
        left: CircularButton.new(
          actions: [
            proc do
              players.shift_back
              update if drawing?
            end
          ],
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button],
          hover_image: Image.new(game.images[:arrow_left_hover]),
          image: Image.new(game.images[:arrow_left]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.3,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.2,
          x: Coordinates::PLAYER_LIST_MENU_LEFT_X + Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH +
            button_gap + (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.2),
          y: (Coordinates::PLAYER_LIST_MENU_BOTTOM_Y + Coordinates::PLAYER_LIST_MENU_TOP_Y) / 2,
          z: ZOrder::POP_UP_MENU_UI
        ),
        right: CircularButton.new(
          actions: [
            proc do
              players.shift_forward
              update if drawing?
            end
          ],
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button],
          hover_image: Image.new(game.images[:arrow_right_hover]),
          image: Image.new(game.images[:arrow_right]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.3,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.2,
          x: Coordinates::PLAYER_LIST_MENU_RIGHT_X - Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH -
            button_gap - (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.2),
          y: (Coordinates::PLAYER_LIST_MENU_BOTTOM_Y + Coordinates::PLAYER_LIST_MENU_TOP_Y) / 2,
          z: ZOrder::POP_UP_MENU_UI
        ),
        players: (0...8).map do |number|
          {
            message: CircularButton.new(
              actions: nil,
              color: game.colors[:tile_button],
              game: game,
              hover_color: game.colors[:neutral_blue],
              hover_image: Image.new(game.images[:message]),
              image: Image.new(game.images[:message]),
              image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.26,
              radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
              x: 0,
              y: token_y + (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.8) + (button_gap * 2),
              z: ZOrder::POP_UP_MENU_UI
            ),
            name: Button.new(
              actions: nil,
              color: nil,
              font: game.fonts[:default][:type],
              font_color: game.colors[:clickable_text],
              game: game,
              height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.5,
              hover_color: nil,
              width: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 2,
              x: 0,
              y: token_y + game.class::DEFAULT_TILE_BUTTON_HEIGHT + button_gap,
              z: ZOrder::POP_UP_MENU_UI
            ),
            token: CircularButton.new(
              actions: proc do
                game.inspected_player = current_player
                game.toggle_player_inspector
              end,
              border_color: game.colors[:pop_up_menu_border],
              border_hover_color: game.colors[:pop_up_menu_border],
              border_width: game.class::DEFAULT_TILE_BUTTON_BORDER_WIDTH,
              color: game.colors[:pop_up_menu_background_light],
              game: game,
              hover_color: game.colors[:pop_up_menu_background_light_hover],
              radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
              x: 0,
              y: token_y,
              z: ZOrder::POP_UP_MENU_UI
            ),
            trade: CircularButton.new(
              actions: nil,
              color: game.colors[:tile_button],
              game: game,
              hover_color: game.colors[:neutral_yellow],
              hover_image: Image.new(game.images[:handshake]),
              image: Image.new(game.images[:handshake]),
              image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
              radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.35,
              x: 0,
              y: token_y + (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.8) + (button_gap * 2),
              z: ZOrder::POP_UP_MENU_UI
            )
          }
        end
      }

      self.players = ScrollingList.new(items: [], view_size: 8)

      self.rectangles = {
        border: {
          color: game.colors[:pop_up_menu_border],
          height: Coordinates::PLAYER_LIST_MENU_HEIGHT,
          width: Coordinates::PLAYER_LIST_MENU_WIDTH,
          x: Coordinates::PLAYER_LIST_MENU_LEFT_X,
          y: Coordinates::PLAYER_LIST_MENU_TOP_Y,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        },
        background: {
          color: game.colors[:pop_up_menu_background],
          height: Coordinates::PLAYER_LIST_MENU_HEIGHT -
            (Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH * 2),
          width: Coordinates::PLAYER_LIST_MENU_WIDTH -
            (Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH * 2),
          x: Coordinates::PLAYER_LIST_MENU_LEFT_X + Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH,
          y: Coordinates::PLAYER_LIST_MENU_TOP_Y + Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        }
      }

      self.initial_x = Coordinates::PLAYER_LIST_MENU_LEFT_X +
        Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH + button_gap +
        (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 1.475)
      self.x_offset = (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 2) +
        (game.class::DEFAULT_TILE_BUTTON_BORDER_WIDTH * 2) + button_gap
    end

    def close
      players.items = []
      super
    end

    def open(players_to_show = nil)
      game.close_pop_up_menus
      players.items = players_to_show || (game.players + game.eliminated_players).sort_by(&:number)
      update

      super()
    end

    def update
      self.visible_buttons = []

      visible_buttons << buttons[:close]
      visible_buttons << buttons[:left] if players.previous?
      visible_buttons << buttons[:right] if players.next?

      initial_offset = initial_x + x_offset * ((players.view_size - players.items.size) / 2.0)

      players.items.each.with_index do |player, index|
        player_buttons = buttons[:players][index]
        player_buttons[:token].hover_image = player.token_image.clone
        player_buttons[:token].image = player.token_image.clone
        player_buttons[:token].maximize_images_in_square(game.class::TOKEN_HEIGHT * 2)
        player_buttons[:token].actions = proc do
          game.inspected_player = player
          game.toggle_player_inspector
        end

        x = initial_offset + (x_offset * index)
        player_buttons[:token].update_coordinates(x: x)
        player_buttons[:token].highlight_color = player_buttons[:token].highlight_hover_color =
          player.eliminated? ? game.colors[:blur] : nil
        visible_buttons << player_buttons[:token]

        player_buttons[:name].text = player.name
        player_buttons[:name].update_coordinates(x: x - game.class::DEFAULT_TILE_BUTTON_HEIGHT)
        visible_buttons << player_buttons[:name]

        unless player == game.current_player || player.eliminated?
          player_buttons[:message].update_coordinates(
            x: x - (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.4)
          )
          visible_buttons << player_buttons[:message]

          player_buttons[:trade].update_coordinates(
            x: x + (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.4)
          )
          visible_buttons << player_buttons[:trade]
        end
      end

      super
    end
  end
end
