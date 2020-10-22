module Monopoly
  class OptionsMenu < Menu
    def initialize(*)
      super

      self.buttons = {
        save: Button.new(
          actions: :save_game,
          color: game.colors[:options_menu_button],
          font: game.fonts[:default][:type],
          game: game,
          hover_color: game.colors[:options_menu_button_hover],
          text: 'Save'
        ),
        exit: Button.new(
          actions: proc { game.dialogue_box_menu.open(actions: :exit_game, button_text: 'Exit') },
          color: game.colors[:options_menu_button],
          font: game.fonts[:default][:type],
          game: game,
          hover_color: game.colors[:options_menu_button_hover],
          text: 'Exit'
        ),
        forfeit: Button.new(
          actions: proc { game.dialogue_box_menu.open(actions: :forfeit, button_text: 'Forfeit') },
          color: game.colors[:options_menu_button],
          font: game.fonts[:default][:type],
          game: game,
          hover_color: game.colors[:warning],
          text: 'Forfeit'
        )
      }

      toggle_button = Button.new(
        actions: proc do
          if drawing?
            close
          else
            open
          end
        end,
        color: nil,
        game: game,
        height: game.class::HEADER_HEIGHT,
        hover_color: nil,
        hover_image: Image.new(game.images[:options_gear_hover]),
        image_height: game.class::HEADER_HEIGHT * 0.9,
        image_width: game.class::HEADER_HEIGHT * 0.9,
        image: Image.new(game.images[:options_gear]),
        width: game.class::HEADER_HEIGHT,
        x: Coordinates::RIGHT_X - game.class::HEADER_HEIGHT,
        y: Coordinates::TOP_Y,
        z: ZOrder::POP_UP_MENU_UI
      )

      buttons.values.each.with_index do |button, index|
        button.update_coordinates(
          x: toggle_button.x - Button::DEFAULT_WIDTH + 10,
          y: toggle_button.y + (index * (Button::DEFAULT_HEIGHT + 1)) + toggle_button.height + 1,
          z: ZOrder::POP_UP_MENU_UI
        )
      end

      self.rectangles = {
        background: {
          color: game.colors[:pop_up_menu_border],
          height: (buttons.values.last.y + buttons.values.last.height) -
            (toggle_button.y + toggle_button.height),
          width:
            toggle_button.x - buttons.values.first.x + toggle_button.width + 1,
          x: buttons.values.first.x,
          y: buttons.values.first.y - 1,
          z: ZOrder::POP_UP_MENU_UI
        }
      }

      buttons[:toggle] = toggle_button
      update
    end

    def close
      buttons[:toggle].color = nil
      buttons[:toggle].hover_color = nil
      buttons[:toggle].perform_image_animation(
        :spin,
        length: game.ticks_for_seconds(0.25),
        times: 0.25
      )

      super
      update
    end

    def draw
      return super if drawing?

      draw_buttons([buttons[:toggle]])
    end

    def open
      buttons[:toggle].color = game.colors[:pop_up_menu_border]
      buttons[:toggle].hover_color = game.colors[:pop_up_menu_border]
      buttons[:toggle].perform_image_animation(
        :spin,
        counterclockwise: true,
        length: game.ticks_for_seconds(0.25),
        times: 0.25
      )

      super
      update
    end

    def update
      self.visible_buttons = drawing? ? buttons.values : [buttons[:toggle]]

      super
    end
  end
end
