module Monopoly
  class Game < Gosu::Window
    module UserInterface
      DEFAULT_FONT_SIZE = 30
      DIALOGUE_BOX_BUTTON_GAP = 20

      def add_message(message)
        puts(message)
        self.messages = [message] + messages
      end

      def display_property(property)
        if draw_inspector?
          if current_tile == property
            exit_inspector
          else
            current_tile.button.color = property_button_color_cache
            current_tile.button.hover_color = property_button_hover_color_cache
            self.property_button_color_cache = property.button.color
            self.property_button_hover_color_cache = property.button.hover_color
            property.button.color = colors[:property_button_selected]
            property.button.hover_color = colors[:property_button_selected_hover]
            self.current_tile = property

            new_visible_buttons = %i[exit_inspector]
            new_visible_buttons += %i[build_house sell_house] if current_tile.is_a?(StreetTile)
            new_visible_buttons += current_tile.mortgaged? ? %i[unmortgage] : %i[mortgage]
            update_visible_buttons(*new_visible_buttons)
          end
        else
          self.draw_inspector = true
          cache_current_tile
          self.current_tile = property
          cache_visible_buttons

          new_visible_buttons = %i[exit_inspector]
          new_visible_buttons += %i[build_house sell_house] if current_tile.is_a?(StreetTile)
          new_visible_buttons += current_tile.mortgaged? ? %i[unmortgage] : %i[mortgage]
          update_visible_buttons(*new_visible_buttons)

          self.property_button_color_cache = property.button.color
          self.property_button_hover_color_cache = property.button.hover_color
          property.button.color = colors[:property_button_selected]
          property.button.hover_color = colors[:property_button_selected_hover]
        end
      end

      def draw
        # Background
        Gosu.draw_rect(
          color: colors[:main_background],
          height: Coordinates::BOTTOM_Y - Coordinates::TOP_Y,
          width: Coordinates::RIGHT_X - Coordinates::LEFT_X,
          x: Coordinates::LEFT_X,
          y: Coordinates::TOP_Y,
          z: ZOrder::MAIN_BACKGROUND
        )

        # Images
        if current_card && !draw_inspector?
          current_card.image.draw(
            draw_height: 245,
            draw_width: 420,
            from_center: true,
            x: Coordinates::CENTER_X,
            y: Coordinates::CENTER_Y,
            z: ZOrder::MENU_UI
          )
        elsif current_tile.is_a?(PropertyTile)
          details = [
            "Position: #{tile_indexes[current_tile] + 1} / #{tile_count}"
          ]

          current_tile.tile_image.draw(
            draw_height: 474,
            draw_width: 288,
            from_center: true,
            x: Coordinates::CENTER_X - 150,
            y: Coordinates::CENTER_Y,
            z: ZOrder::MENU_UI
          )

          current_tile.deed_image.draw(
            draw_height: 474,
            draw_width: 288,
            from_center: true,
            x: Coordinates::CENTER_X + 150,
            y: Coordinates::CENTER_Y,
            z: ZOrder::MENU_UI
          )

          owner_message =
            if current_tile.owner
              temp_message = "Owned By #{current_tile.owner.name}"
              temp_message << " (#{current_tile.group.amount_owned(current_tile.owner)})" if
                current_tile.group

              temp_message
            else
              'Unowned'
            end

          details += [owner_message, current_tile.mortgaged? ? 'Mortgaged' : 'Not Mortgaged']
          details += ["#{current_tile.house_count} Houses"] if current_tile.is_a?(StreetTile)
        else
          details = [
            "Position: #{tile_indexes[current_tile] + 1} / #{tile_count}"
          ]

          width = current_tile.corner? ? 474 : 288

          current_tile.tile_image.draw(
            draw_height: 474,
            draw_width: width,
            from_center: true,
            x: Coordinates::CENTER_X,
            y: Coordinates::CENTER_Y,
            z: ZOrder::MENU_UI
          )
        end

        # Player list
        y_differential = 0
        players.each do |player|
          fonts[:default][:type].draw_text(
            "#{player.name}: #{player.tile.name}",
            color: colors[:default_text],
            rel_x: 0.5,
            rel_y: 0,
            x: Coordinates::CENTER_X,
            y: Coordinates::TOP_Y + y_differential,
            z: ZOrder::MAIN_UI
          )
          y_differential += fonts[:default][:offset]
        end

        # Current player details
        fonts[:title][:type].draw_text(
          "#{current_player.name}: $#{format_number(current_player.money)}",
          color: colors[:default_text],
          x: Coordinates::LEFT_X,
          y: Coordinates::TOP_Y,
          z: ZOrder::MAIN_UI
        )

        coordinates_for_buttons = draw_dialogue_box? ? [] : [mouse_x, mouse_y]

        # Options Menu
        buttons[:options].draw(mouse_x, mouse_y)
        if draw_options_menu?
          Gosu.draw_rect(**options_menu_bar_paramaters)
          options_menu_buttons.each_value { |button| button.draw(*coordinates_for_buttons) }
        end

        # Mouse coordinates
        fonts[:default][:type].draw_text(
          "#{mouse_x.round(3)}, #{mouse_y.round(3)}",
          color: colors[:default_text],
          rel_x: 1,
          rel_y: 0,
          x: Coordinates::RIGHT_X * 0.85,
          y: Coordinates::TOP_Y,
          z: ZOrder::MAIN_UI
        )

        # Messages
        y_differential = 0
        self.messages = messages[0..4]
        messages.each do |message|
          fonts[:default][:type].draw_text(
            message,
            color: colors[:default_text],
            rel_x: 0,
            rel_y: 1,
            x: Coordinates::LEFT_X,
            y: Coordinates::BOTTOM_Y - y_differential,
            z: ZOrder::MAIN_UI
          )

          y_differential += fonts[:default][:offset]
        end

        # Primary buttons
        visible_buttons.each { |button| button.draw(*coordinates_for_buttons) }

        # Property buttons
        current_player.properties.each { |property| property.button.draw(*coordinates_for_buttons) }

        # Inspector
        if draw_inspector?
          Gosu.draw_rect(
            color: colors[:inspector_background],
            height: Coordinates::INSPECTOR_BOTTOM_Y - Coordinates::INSPECTOR_TOP_Y,
            width: Coordinates::INSPECTOR_RIGHT_X - Coordinates::INSPECTOR_LEFT_X,
            x: Coordinates::INSPECTOR_LEFT_X,
            y: Coordinates::INSPECTOR_TOP_Y,
            z: ZOrder::MENU_BACKGROUND
          )
          current_details_text_color = colors[:inspector_text]
        end

        # Current tile details
        y_differential = 250
        details&.each do |detail|
          fonts[:default][:type].draw_text(
            detail,
            color: current_details_text_color || colors[:default_text],
            rel_x: 0.5,
            rel_y: 0,
            x: Coordinates::CENTER_X,
            y: Coordinates::CENTER_Y + y_differential,
            z: ZOrder::MENU_UI
          )
          y_differential += fonts[:default][:offset]
        end

        # Dialogue box
        if draw_dialogue_box?
          # Background blur
          Gosu.draw_rect(
            color: colors[:blur],
            height: Coordinates::BOTTOM_Y - Coordinates::TOP_Y,
            width: Coordinates::RIGHT_X - Coordinates::LEFT_X,
            x: Coordinates::LEFT_X,
            y: Coordinates::TOP_Y,
            z: ZOrder::BLUR
          )

          Gosu.draw_rect(
            color: colors[:dialogue_box_background],
            height: Coordinates::DIALOGUE_BOX_BOTTOM_Y - Coordinates::DIALOGUE_BOX_TOP_Y,
            width: Coordinates::DIALOGUE_BOX_RIGHT_X - Coordinates::DIALOGUE_BOX_LEFT_X,
            x: Coordinates::DIALOGUE_BOX_LEFT_X,
            y: Coordinates::DIALOGUE_BOX_TOP_Y,
            z: ZOrder::DIALOGUE_BACKGROUND
          )

          fonts[:dialogue][:type].draw_text(
            'Are You Sure?',
            color: colors[:dialogue_box_text],
            rel_x: 0.5,
            rel_y: 0,
            x: Coordinates::CENTER_X,
            y: Coordinates::DIALOGUE_BOX_TOP_Y + (Coordinates::DIALOGUE_BOX_HEIGHT / 3),
            z: ZOrder::DIALOGUE_UI
          )

          dialogue_box_buttons.values.each { |button| button.draw(mouse_x, mouse_y) }
        end
      end

      def exit_inspector
        current_tile.button.color = property_button_color_cache
        current_tile.button.hover_color = property_button_hover_color_cache
        self.property_button_color_cache = nil
        self.property_button_hover_color_cache = nil
        self.draw_inspector = false
        pop_current_tile_cache
        pop_visible_buttons_cache
      end

      def set_options_menu_button_coordinates
        options_menu_buttons.values.each.with_index do |options_menu_button, index|
          options_menu_button.update_coordinates(
            x: buttons[:options].x - Button::DEFAULT_WIDTH + 10,
            y: buttons[:options].y + (index * (Button::DEFAULT_HEIGHT + 1)) +
              buttons[:options].height + 1,
            z: ZOrder::MENU_UI
          )
        end
      end

      def update_visible_buttons(*button_names)
        self.visible_buttons = button_names.map { |button_name| buttons[button_name] }
      end
    end
  end
end
