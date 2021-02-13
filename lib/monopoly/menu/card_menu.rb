module Monopoly
  class CardMenu < Menu
    CARD_HEIGHT = 368
    CARD_WIDTH = 630

    def initialize(*)
      super

      self.buttons = {
        back: CircularButton.new(
          actions: proc { game.back_to_current_tile },
          color: game.colors[:tile_button],
          game: game,
          hover_color: game.colors[:neutral_blue],
          hover_image: Image.new(game.images[:back]),
          image: Image.new(game.images[:back]),
          image_height: 42,
          radius: 30,
          x: Coordinates::CENTER_X + (CARD_WIDTH / 2) - 30,
          y: Coordinates::CENTER_Y + (CARD_HEIGHT / 2) + 35,
          z: ZOrder::MAIN_UI
        ),
        continue: Button.new(
          actions: proc { game.use_new_card },
          font: game.fonts[:default][:type],
          game: game,
          text: 'Continue',
          width: 300,
          x: Coordinates::CENTER_X - 150,
          y: Coordinates::CENTER_Y + (CARD_HEIGHT / 2) + 10
        )
      }
    end

    def close
      game.action_menu.update

      super
    end

    def open
      update
      game.action_menu.update

      super
    end

    def update
      self.visible_buttons = []

      if game.current_card
        visible_buttons << buttons[:back]
        visible_buttons << buttons[:continue] unless game.current_card.triggered

        self.images = {
          current_card: {
            image: game.current_card.image,
            params: {
              draw_height: CARD_HEIGHT,
              draw_width: CARD_WIDTH,
              from_center: true,
              x: Coordinates::CENTER_X,
              y: Coordinates::CENTER_Y,
              z: ZOrder::MENU_UI
            }
          }
        }
      end

      super
    end
  end
end
