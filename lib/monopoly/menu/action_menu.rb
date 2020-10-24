module Monopoly
  class ActionMenu < Menu
    ROUNDED_CORNER_RADIUS = 35

    attr_accessor :die_images
    attr_accessor :initial_x
    attr_accessor :message
    attr_accessor :message_color
    attr_accessor :minimap_coordinates
    attr_accessor :players
    attr_accessor :x_offset

    def initialize(*)
      super

      inner_border_width = 10
      outer_border_width = 20
      transluscent_white = Gosu::Color::WHITE.dup
      transluscent_white.alpha = 175

      minimap_center_x = Coordinates::ACTION_MENU_LEFT_X + outer_border_width +
        (Coordinates::THUMBNAIL_HEIGHT * 5.5)
      minimap_center_y = Coordinates::ACTION_MENU_TOP_Y + outer_border_width +
        (Coordinates::THUMBNAIL_HEIGHT * 5.5)

      self.rectangles = {
        background: {
          color: game.colors[:pop_up_menu_background],
          height: Coordinates::ACTION_MENU_HEIGHT - (Coordinates::THUMBNAIL_HEIGHT * 2) -
            inner_border_width - outer_border_width,
          width: Coordinates::ACTION_MENU_WIDTH - (Coordinates::THUMBNAIL_HEIGHT * 2) -
            inner_border_width - outer_border_width,
          x: Coordinates::ACTION_MENU_LEFT_X + Coordinates::THUMBNAIL_HEIGHT + 20,
          y: Coordinates::ACTION_MENU_TOP_Y + Coordinates::THUMBNAIL_HEIGHT + 20,
          z: ZOrder::MENU_UI
        },
        bottom_border: {
          color: game.colors[:pop_up_menu_border],
          height: 10,
          width: Coordinates::ACTION_MENU_WIDTH,
          x: Coordinates::ACTION_MENU_LEFT_X,
          y: Coordinates::ACTION_MENU_BOTTOM_Y - inner_border_width,
          z: ZOrder::MENU_BACKGROUND
        },
        dice_background: {
          color: game.colors[:pop_up_menu_border],
          height: game.class::DEFAULT_TILE_BUTTON_HEIGHT + (game.class::TILE_BUTTON_GAP * 2),
          width: (game.class::DEFAULT_TILE_BUTTON_HEIGHT * 2) + (game.class::TILE_BUTTON_GAP * 4),
          x: minimap_center_x - (game.class::TILE_BUTTON_GAP * 2) -
            game.class::DEFAULT_TILE_BUTTON_HEIGHT,
          y: minimap_center_y,
          z: ZOrder::MENU_UI
        },
        left_border: {
          color: game.colors[:pop_up_menu_border],
          height: Coordinates::ACTION_MENU_HEIGHT,
          width: outer_border_width,
          x: Coordinates::ACTION_MENU_LEFT_X,
          y: Coordinates::ACTION_MENU_TOP_Y + ROUNDED_CORNER_RADIUS,
          z: ZOrder::MENU_BACKGROUND
        },
        right_border: {
          color: game.colors[:pop_up_menu_border],
          height: Coordinates::ACTION_MENU_HEIGHT,
          width: inner_border_width,
          x: Coordinates::ACTION_MENU_RIGHT_X - inner_border_width,
          y: Coordinates::ACTION_MENU_TOP_Y,
          z: ZOrder::MENU_BACKGROUND
        },
        top_border: {
          color: game.colors[:pop_up_menu_border],
          height: ROUNDED_CORNER_RADIUS,
          width: Coordinates::ACTION_MENU_WIDTH - ROUNDED_CORNER_RADIUS,
          x: Coordinates::ACTION_MENU_LEFT_X + ROUNDED_CORNER_RADIUS,
          y: Coordinates::ACTION_MENU_TOP_Y,
          z: ZOrder::MENU_BACKGROUND
        }
      }

      self.images = {
        die_a: {
          params: {
            draw_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
            draw_width: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
            x: minimap_center_x - game.class::TILE_BUTTON_GAP -
              game.class::DEFAULT_TILE_BUTTON_HEIGHT,
            y: minimap_center_y + game.class::TILE_BUTTON_GAP,
            z: ZOrder::MENU_UI
          }
        },
        die_b: {
          params: {
            draw_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
            draw_width: game.class::DEFAULT_TILE_BUTTON_HEIGHT,
            x: minimap_center_x + game.class::TILE_BUTTON_GAP,
            y: minimap_center_y + game.class::TILE_BUTTON_GAP,
            z: ZOrder::MENU_UI
          }
        },
        rounded_corner_circle: {
          image: Image.new(
            Gosu::Circle.new(
              color: game.colors[:pop_up_menu_border],
              radius: ROUNDED_CORNER_RADIUS
            )
          ),
          params: {
            from_center: true,
            x: Coordinates::ACTION_MENU_LEFT_X + ROUNDED_CORNER_RADIUS,
            y: Coordinates::ACTION_MENU_TOP_Y + ROUNDED_CORNER_RADIUS,
            z: ZOrder::MENU_BACKGROUND
          }
        }
      }

      self.die_images = {
        1 => Image.new(game.images[:die_1]),
        2 => Image.new(game.images[:die_2]),
        3 => Image.new(game.images[:die_3]),
        4 => Image.new(game.images[:die_4]),
        5 => Image.new(game.images[:die_5]),
        6 => Image.new(game.images[:die_6])
      }

      self.texts = {
        message: {
          font: game.fonts[:default][:type],
          params: {
            rel_x: 1,
            rel_y: 1,
            x: Coordinates::ACTION_MENU_RIGHT_X - 10,
            y: Coordinates::ACTION_MENU_TOP_Y - 10,
            z: ZOrder::MENU_UI
          }
        }
      }

      self.buttons = {
        consecutive_charge: CircularButton.new(
          actions: nil,
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button_hover],
          hover_image: Image.new(game.images[:dollar_sign]),
          image: Image.new(game.images[:dollar_sign]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.75,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          x: minimap_center_x,
          y: minimap_center_y - game.class::TILE_BUTTON_GAP -
            (game.class::DEFAULT_TILE_BUTTON_HEIGHT  * 0.7),
          z: ZOrder::MENU_UI
        ),
        draw_card: Button.new(
          actions: :draw_card,
          font: game.fonts[:default][:type],
          game: game,
          text: 'Draw Card',
          x: Coordinates::CENTER_X - (Button::DEFAULT_WIDTH / 2),
          y: Coordinates::CENTER_Y + (Coordinates::TILE_HEIGHT / 2) + game.class::TILE_BUTTON_GAP,
          z: ZOrder::MENU_UI
        ),
        end_turn: CircularButton.new(
          actions: :end_turn,
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button_hover],
          hover_image: Image.new(game.images[:checkbox_checked]),
          image: Image.new(game.images[:checkbox_checked]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          x: minimap_center_x,
          y: minimap_center_y - game.class::TILE_BUTTON_GAP -
            (game.class::DEFAULT_TILE_BUTTON_HEIGHT  * 0.7),
          z: ZOrder::MENU_UI
        ),
        go_to_jail: Button.new(
          actions: :go_to_jail,
          font: game.fonts[:default][:type],
          game: game,
          text: 'Go To Jail',
          x: Coordinates::CENTER_X - (Button::DEFAULT_WIDTH / 2),
          y: Coordinates::CENTER_Y + (Coordinates::TILE_HEIGHT / 2) + game.class::TILE_BUTTON_GAP,
          z: ZOrder::MENU_UI
        ),
        no_action: CircularButton.new(
          actions: nil,
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button],
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          x: minimap_center_x,
          y: minimap_center_y - game.class::TILE_BUTTON_GAP -
            (game.class::DEFAULT_TILE_BUTTON_HEIGHT  * 0.7),
          z: ZOrder::MENU_UI
        ),
        pay_rent: CircularButton.new(
          actions: :pay_rent,
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button_hover],
          hover_image: Image.new(game.images[:dollar_sign]),
          image: Image.new(game.images[:dollar_sign]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.75,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          x: minimap_center_x,
          y: minimap_center_y - game.class::TILE_BUTTON_GAP -
            (game.class::DEFAULT_TILE_BUTTON_HEIGHT  * 0.7),
          z: ZOrder::MENU_UI
        ),
        pay_tax: CircularButton.new(
          actions: :pay_tax,
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button_hover],
          hover_image: Image.new(game.images[:dollar_sign]),
          image: Image.new(game.images[:dollar_sign]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.75,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          x: minimap_center_x,
          y: minimap_center_y - game.class::TILE_BUTTON_GAP -
            (game.class::DEFAULT_TILE_BUTTON_HEIGHT  * 0.7),
          z: ZOrder::MENU_UI
        ),
        roll_dice_for_move: CircularButton.new(
          actions: [[:roll_dice], [:move], [:land]],
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button_hover],
          hover_image: Image.new(game.images[:dice]),
          image: Image.new(game.images[:dice]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          x: minimap_center_x,
          y: minimap_center_y - game.class::TILE_BUTTON_GAP -
            (game.class::DEFAULT_TILE_BUTTON_HEIGHT  * 0.7),
          z: ZOrder::MENU_UI
        ),
        roll_dice_for_rent: CircularButton.new(
          actions: [[:roll_dice], [:land]],
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:tile_button_hover],
          hover_image: Image.new(game.images[:dice]),
          image: Image.new(game.images[:dice]),
          image_height: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          radius: game.class::DEFAULT_TILE_BUTTON_HEIGHT * 0.7,
          x: minimap_center_x,
          y: minimap_center_y - game.class::TILE_BUTTON_GAP -
            (game.class::DEFAULT_TILE_BUTTON_HEIGHT  * 0.7),
          z: ZOrder::MENU_UI
        ),
        show_card: Button.new(
          actions: :toggle_card_menu,
          font: game.fonts[:default][:type],
          game: game,
          text: 'Show Card',
          x: Coordinates::CENTER_X - (Button::DEFAULT_WIDTH / 2),
          y: Coordinates::CENTER_Y + (Coordinates::TILE_HEIGHT / 2) + game.class::TILE_BUTTON_GAP,
          z: ZOrder::MENU_UI
        )
      }
      if game.standard_board?
        minimap_image = Image.new(generate_minimap_image)

        buttons[:minimap] = Button.new(
          actions: proc { game.map_menu.open },
          color: nil,
          deadzones: [rectangles[:background].slice(:height, :width, :x, :y)],
          game: game,
          height: minimap_image.height,
          highlight_hover_color: game.colors[:button_hover_highlight_light],
          hover_color: nil,
          hover_image: minimap_image,
          image: minimap_image,
          width: minimap_image.width,
          x: Coordinates::ACTION_MENU_LEFT_X + outer_border_width,
          y: Coordinates::ACTION_MENU_TOP_Y + outer_border_width,
          z: ZOrder::MENU_BACKGROUND
        )

        rectangles[:minimap_current_tile_highlight] = {
          color: transluscent_white,
          height: Coordinates::THUMBNAIL_HEIGHT,
          width: Coordinates::THUMBNAIL_HEIGHT,
          z: ZOrder::MENU_UI
        }

        images[:minimap_current_tile_dot_circle] = {
          image: Image.new(
            Gosu::Circle.new(
              color: Gosu::Color::BLACK,
              radius: 10
            )
          ),
          params: {
            from_center: true,
            z: ZOrder::MENU_UI
          }
        }
      else
        rectangles[:background].merge!(
          height: Coordinates::ACTION_MENU_HEIGHT - inner_border_width - outer_border_width,
          width: Coordinates::ACTION_MENU_WIDTH - inner_border_width - outer_border_width,
          x: Coordinates::ACTION_MENU_LEFT_X + 20,
          y: Coordinates::ACTION_MENU_TOP_Y + 20
        )
      end

      open
    end

    def draw
      return unless drawing?

      images[:die_a][:image] = die_images[game.die_a]
      images[:die_b][:image] = die_images[game.die_b]

      super
    end

    def open
      update

      super
    end

    def set_message(color:, message:)
      texts[:message][:params][:color] = color
      texts[:message][:text] = message
    end

    def update
      self.visible_buttons = []

      if buttons[:minimap]
        rectangles[:minimap_current_tile_highlight].merge!(
          x: buttons[:minimap].x + minimap_coordinates[game.current_tile][:x],
          y: buttons[:minimap].y + minimap_coordinates[game.current_tile][:y]
        )
        images[:minimap_current_tile_dot_circle][:params].merge!(
          x: buttons[:minimap].x + minimap_coordinates[game.current_tile][:x] +
            (Coordinates::THUMBNAIL_HEIGHT / 2),
          y: buttons[:minimap].y + minimap_coordinates[game.current_tile][:y] +
            (Coordinates::THUMBNAIL_HEIGHT / 2)
        )

        visible_buttons << buttons[:minimap]
      end

      visible_buttons << buttons[:show_card] if game.current_card && !game.drawing_card_menu?
      visible_buttons << buttons[game.next_action] if game.next_action
      visible_buttons << buttons[:no_action] if
        [nil, :draw_card, :go_to_jail].include?(game.next_action)

      super
    end

    private

    def generate_minimap_image
      self.minimap_coordinates = {}
      Gosu.render(Coordinates::THUMBNAIL_HEIGHT * 11, Coordinates::THUMBNAIL_HEIGHT * 11) do
        x = Coordinates::THUMBNAIL_HEIGHT * 10
        y = Coordinates::THUMBNAIL_HEIGHT * 10

        x_offsets = [-Coordinates::THUMBNAIL_HEIGHT, 0, Coordinates::THUMBNAIL_HEIGHT, 0]
        y_offsets = [0, -Coordinates::THUMBNAIL_HEIGHT, 0, Coordinates::THUMBNAIL_HEIGHT]

        tiles_to_draw = game.tile_indexes.keys
        tiles_to_draw.each_slice(10).with_index do |sub_tiles_to_draw, index|
          sub_tiles_to_draw.each do |tile|
            minimap_coordinates[tile] = { x: x, y: y }
            tile.thumbnail.draw(x: x, y: y, z: 0)
            x += x_offsets[index]
            y += y_offsets[index]
          end
        end
      end
    end
  end
end
