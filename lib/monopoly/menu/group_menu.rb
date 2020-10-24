module Monopoly
  class GroupMenu < Menu
    TILE_BUTTON_HEIGHT =
      (Coordinates::GROUP_MENU_HEIGHT - (Coordinates::GROUP_MENU_BORDER_WIDTH * 2)) * 0.75
    TILE_BUTTON_WIDTH = TILE_BUTTON_HEIGHT * 0.6
    TILE_GAP = TILE_BUTTON_WIDTH * 0.04
    FIRST_TILE_X = Coordinates::CENTER_X - (TILE_GAP * 1.5) - (TILE_BUTTON_WIDTH * 2)
    FIRST_TILE_ALT_X_OFFSET = (TILE_GAP + TILE_BUTTON_WIDTH) * 0.5
    FIRST_TILE_Y = Coordinates::GROUP_MENU_TOP_Y + Coordinates::GROUP_MENU_BORDER_WIDTH + 50

    attr_accessor :alt_button_positions
    attr_accessor :tiles

    def initialize(*)
      super

      tile_button_options = {
        actions: nil,
        color: nil,
        game: game,
        height: TILE_BUTTON_HEIGHT,
        hover_color: game.colors[:blur],
        width: TILE_BUTTON_WIDTH,
        z: ZOrder::POP_UP_MENU_UI
      }
      sub_button_edge = tile_button_options[:width] -
        (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 3) - (game.class::TILE_BUTTON_GAP * 2)
      sub_button_edge /= 2
      sub_button_y = FIRST_TILE_Y + TILE_BUTTON_HEIGHT + game.class::TILE_BUTTON_GAP

      arrow_button_x_offset = Coordinates::GROUP_MENU_BORDER_WIDTH +
        (FIRST_TILE_X - Coordinates::GROUP_MENU_LEFT_X - Coordinates::GROUP_MENU_BORDER_WIDTH) / 2

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
          x: Coordinates::GROUP_MENU_LEFT_X + Coordinates::GROUP_MENU_BORDER_WIDTH + 5,
          y: Coordinates::GROUP_MENU_TOP_Y + Coordinates::GROUP_MENU_BORDER_WIDTH + 5,
          z: ZOrder::POP_UP_MENU_UI
        ),
        left: CircularButton.new(
          actions: [
            proc do
              tiles.shift_back
              update if drawing?
            end
          ],
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button],
          hover_image: Image.new(game.images[:arrow_left_hover]),
          image: Image.new(game.images[:arrow_left]),
          image_height: 40,
          radius: 30,
          x: Coordinates::GROUP_MENU_LEFT_X + arrow_button_x_offset,
          y: FIRST_TILE_Y + (TILE_BUTTON_HEIGHT / 2),
          z: ZOrder::POP_UP_MENU_UI
        ),
        right: CircularButton.new(
          actions: [
            proc do
              tiles.shift_forward
              update if drawing?
            end
          ],
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button],
          hover_image: Image.new(game.images[:arrow_right_hover]),
          image: Image.new(game.images[:arrow_right]),
          image_height: 40,
          radius: 30,
          x: Coordinates::GROUP_MENU_RIGHT_X - arrow_button_x_offset,
          y: FIRST_TILE_Y + (TILE_BUTTON_HEIGHT / 2),
          z: ZOrder::POP_UP_MENU_UI
        ),
        tiles: (0...4).map do |number|
          x = FIRST_TILE_X + (TILE_BUTTON_WIDTH + TILE_GAP) * number
          {
            build_house: Button.new(
              actions: nil,
              color: nil,
              game: game,
              height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.25,
              hover_color: nil,
              hover_image: Image.new(game.images[:arrow_up_hover]),
              image: Image.new(game.images[:arrow_up]),
              image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.25,
              width: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
              x: x + sub_button_edge,
              y: sub_button_y,
              z: tile_button_options[:z]
            ),
            house_big: Button.new(
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
              x: x + sub_button_edge,
              y: sub_button_y,
              z: tile_button_options[:z]
            ),
            house_small: Button.new(
              actions: nil,
              color: nil,
              font: game.fonts[:large][:type],
              font_color: game.colors[:house_count],
              game: game,
              height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.45,
              hover_color: nil,
              hover_image: Image.new(game.images[:house]),
              image: Image.new(game.images[:house]),
              image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.45,
              text_relative_position_y: 0.4,
              width: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.45,
              x: x + sub_button_edge + ((game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.55) / 2),
              y: sub_button_y + game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.25,
              z: tile_button_options[:z]
            ),
            owner: CircularButton.new(
              actions: proc do
                index = number
                index -= 1 if tiles.all_items.size <= 2
                game.inspected_player = tiles.items[index].owner
                game.toggle_player_inspector
              end,
              color: game.colors[:tile_button],
              game: game,
              hover_color: game.colors[:tile_button_hover],
              radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2,
              x: x + sub_button_edge + game.class::DEFAULT_TILE_BUTTON_HEIGHT +
                game.class::TILE_BUTTON_GAP + (game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2),
              y: sub_button_y + (game.class::DEFAULT_TILE_BUTTON_HEIGHT / 2),
              z: tile_button_options[:z]
            ),
            mortgage: Button.new(
              actions: nil,
              color: nil,
              game: game,
              height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
              hover_color: nil,
              hover_image: Image.new(game.images[:mortgage_hover]),
              image: Image.new(game.images[:mortgage]),
              image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
              image_width: 70,
              width: 70,
              x: x + sub_button_edge + (game.class::TILE_BUTTON_GAP * 2) +
                (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 2),
              y: sub_button_y,
              z: tile_button_options[:z]
            ),
            mortgage_lock: Button.new(
              actions: nil,
              color: nil,
              game: game,
              height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
              hover_color: nil,
              hover_image: Image.new(game.images[:mortgage_lock]),
              image: Image.new(game.images[:mortgage_lock]),
              image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
              image_width: 70,
              width: 70,
              x: x + sub_button_edge + (game.class::TILE_BUTTON_GAP * 2) +
                (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 2),
              y: sub_button_y,
              z: tile_button_options[:z]
            ),
            sell_house: Button.new(
              actions: nil,
              color: nil,
              game: game,
              height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.25,
              hover_color: nil,
              hover_image: Image.new(game.images[:arrow_down_hover]),
              image: Image.new(game.images[:arrow_down]),
              image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.25,
              width: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
              x: x + sub_button_edge,
              y: sub_button_y + game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.75,
              z: tile_button_options[:z]
            ),
            tile: Button.new(
              tile_button_options.merge(
                image_height: TILE_BUTTON_HEIGHT * 0.9,
                x: x,
                y: FIRST_TILE_Y
              )
            ),
            unmortgage: Button.new(
              actions: nil,
              color: nil,
              game: game,
              height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
              hover_color: nil,
              hover_image: Image.new(game.images[:unmortgage_hover]),
              image: Image.new(game.images[:unmortgage]),
              image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
              image_width: 70,
              width: 70,
              x: x + sub_button_edge + (game.class::TILE_BUTTON_GAP * 2) +
                (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 2),
              y: sub_button_y,
              z: tile_button_options[:z]
            ),
          }
        end
      }

      self.rectangles = {
        border: {
          color: game.colors[:pop_up_menu_border],
          height: Coordinates::GROUP_MENU_HEIGHT,
          width: Coordinates::GROUP_MENU_WIDTH,
          x: Coordinates::GROUP_MENU_LEFT_X,
          y: Coordinates::GROUP_MENU_TOP_Y,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        },
        background: {
          color: game.colors[:pop_up_menu_background],
          height: Coordinates::GROUP_MENU_HEIGHT - (Coordinates::GROUP_MENU_BORDER_WIDTH * 2),
          width: Coordinates::GROUP_MENU_WIDTH - (Coordinates::GROUP_MENU_BORDER_WIDTH * 2),
          x: Coordinates::GROUP_MENU_LEFT_X + Coordinates::GROUP_MENU_BORDER_WIDTH,
          y: Coordinates::GROUP_MENU_TOP_Y + Coordinates::GROUP_MENU_BORDER_WIDTH,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        }
      }

      self.tiles = ScrollingList.new(items: [], view_size: 4)
      self.alt_button_positions = false
    end

    def close
      tiles.items = []

      super
    end

    def open(tiles_to_show = game.focused_tile.group.tiles)
      game.close_pop_up_menus
      tiles.items = tiles_to_show
      update

      super()
    end

    def update
      self.visible_buttons = []

      visible_buttons << buttons[:close]
      visible_buttons << buttons[:left] if tiles.previous?
      visible_buttons << buttons[:right] if tiles.next?

      index_offset = tiles.all_items.size <= 2 ? 1 : 0
      tiles.items.each.with_index do |tile, index|
        tile_buttons = buttons[:tiles][index + index_offset]
        tile_buttons[:tile].hover_image = tile.tile_image.clone
        tile_buttons[:tile].image = tile.tile_image.clone
        tile_buttons[:tile].actions = [[:display_tile, tile]]
        visible_buttons << tile_buttons[:tile]

        if tile.owner
          tile_buttons[:owner].hover_image = tile.owner.token_image.clone
          tile_buttons[:owner].image = tile.owner.token_image.clone
          tile_buttons[:owner].maximize_images_in_square(game.class::TOKEN_HEIGHT)
          visible_buttons << tile_buttons[:owner]

          if tile.group.monopolized? && tile.is_a?(StreetTile)
            if tile.owner == game.current_player
              tile_buttons[:house_small].text = tile.house_count
              visible_buttons << tile_buttons[:house_small]

              tile_buttons[:build_house].actions = [[:build_house, tile]]
              visible_buttons << tile_buttons[:build_house]

              tile_buttons[:sell_house].actions = [[:sell_house, tile]]
              visible_buttons << tile_buttons[:sell_house]
            else
              tile_buttons[:house_big].text = tile.house_count
              visible_buttons << tile_buttons[:house_big]
            end
          end

          if tile.owner == game.current_player
            if tile.mortgaged?
              tile_buttons[:unmortgage].actions = [[:unmortgage, tile]]
              visible_buttons << tile_buttons[:unmortgage]
            else
              tile_buttons[:mortgage].actions = [[:mortgage, tile]]
              visible_buttons << tile_buttons[:mortgage]
            end
          else
            visible_buttons << tile_buttons[:mortgage_lock] if tile.mortgaged?
          end
        end
      end

      shift_buttons

      super
    end

    private

    def shift_buttons
      if [1, 3].include?(tiles.all_items.size)
        return if alt_button_positions

        self.alt_button_positions = true
        buttons[:tiles].map(&:values).flatten.each do |button|
          button.update_coordinates(x: button.x + FIRST_TILE_ALT_X_OFFSET)
        end
      elsif alt_button_positions
        self.alt_button_positions = false
        buttons[:tiles].map(&:values).flatten.each do |button|
          button.update_coordinates(x: button.x - FIRST_TILE_ALT_X_OFFSET)
        end
      end
    end
  end
end
