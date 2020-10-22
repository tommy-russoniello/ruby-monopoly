module Monopoly
  class DialogueBoxMenu < Menu
    BUTTON_GAP = 20

    def initialize(*)
      super

      button_width = (Coordinates::DIALOGUE_BOX_WIDTH - (BUTTON_GAP * 3)) / 2
      self.buttons = {
        cancel: Button.new(
          actions: proc { close },
          font: game.fonts[:default][:type],
          game: game,
          hover_color: game.colors[:dialogue_box_button_hover],
          text: 'Cancel',
          width: button_width,
          x: Coordinates::DIALOGUE_BOX_LEFT_X + BUTTON_GAP,
          y: Coordinates::DIALOGUE_BOX_BOTTOM_Y - Button::DEFAULT_HEIGHT - 10,
          z: ZOrder::DIALOGUE_UI
        ),
        action: Button.new(
          actions: proc { close },
          font: game.fonts[:default][:type],
          game: game,
          hover_color: game.colors[:dialogue_box_button_hover],
          text: 'Cancel',
          width: button_width,
          x: Coordinates::DIALOGUE_BOX_RIGHT_X - BUTTON_GAP - button_width,
          y: Coordinates::DIALOGUE_BOX_BOTTOM_Y - Button::DEFAULT_HEIGHT - 10,
          z: ZOrder::DIALOGUE_UI
        )
      }

      self.rectangles = {
        background: {
          color: game.colors[:dialogue_box_background],
          height: Coordinates::DIALOGUE_BOX_HEIGHT,
          width: Coordinates::DIALOGUE_BOX_WIDTH,
          x: Coordinates::DIALOGUE_BOX_LEFT_X,
          y: Coordinates::DIALOGUE_BOX_TOP_Y,
          z: ZOrder::DIALOGUE_BACKGROUND
        },
        blur: {
          color: game.colors[:blur],
          height: Coordinates::BOTTOM_Y - Coordinates::TOP_Y,
          width: Coordinates::RIGHT_X - Coordinates::LEFT_X,
          x: Coordinates::LEFT_X,
          y: Coordinates::TOP_Y,
          z: ZOrder::DIALOGUE_BLUR
        }
      }

      self.texts = {
        are_you_sure: {
          font: game.fonts[:extra_large][:type],
          params: {
            color: game.colors[:dialogue_box_text],
            rel_x: 0.5,
            rel_y: 0,
            x: Coordinates::CENTER_X,
            y: Coordinates::DIALOGUE_BOX_TOP_Y + (Coordinates::DIALOGUE_BOX_HEIGHT / 3),
            z: ZOrder::DIALOGUE_UI
          },
          text: 'Are You Sure?'
        }
      }
    end

    def close
      game.options_menu.close if game.options_menu.drawing?

      super
    end

    def open(actions:, button_text:)
      buttons[:action].actions = [[proc { close }], *actions]
      buttons[:action].text = button_text
      update

      super()
    end

    def update
      self.visible_buttons = buttons.values

      super
    end

    private

    def draw_buttons(buttons_to_draw)
      buttons_to_draw.each { |button| button.draw(game.draw_mouse_x, game.draw_mouse_y) }
    end
  end
end
