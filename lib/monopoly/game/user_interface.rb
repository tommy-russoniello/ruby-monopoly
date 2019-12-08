module Monopoly
  class Game < Gosu::Window
    module UserInterface
      DEFAULT_FONT_SIZE = 30
      DEFAULT_TILE_BUTTON_HEIGHT = 100
      DIALOGUE_BOX_BUTTON_GAP = 20
      MINIMUM_FONT_SIZE = 15
      TILE_BUTTON_GAP = 15
      TOKEN_HEIGHT = 70

      def add_message(message)
        puts(message)
        self.messages = [message] + messages
      end

      def display_tile(tile)
        self.focused_tile = tile
        set_visible_tile_menu_buttons
        toggle_card_menu if drawing_card_menu?
        toggle_deed_menu if drawing_deed_menu?
        toggle_group_menu if drawing_group_menu?
      end


      def draw
        self.draw_mouse_x = mouse_x
        self.draw_mouse_y = mouse_y

        # Background
        Gosu.draw_rect(
          color: colors[:main_background],
          height: Coordinates::BOTTOM_Y - Coordinates::TOP_Y,
          width: Coordinates::RIGHT_X - Coordinates::LEFT_X,
          x: Coordinates::LEFT_X,
          y: Coordinates::TOP_Y,
          z: ZOrder::MAIN_BACKGROUND
        )

        draw_card_menu
        draw_tile_menu

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
          "#{current_player.name}: #{format_money(current_player.money)}",
          color: colors[:default_text],
          x: Coordinates::LEFT_X,
          y: Coordinates::TOP_Y,
          z: ZOrder::MAIN_UI
        )

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

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_deed_menu? ||
          drawing_group_menu? || drawing_dialogue_box?

        # Primary buttons
        visible_buttons.each { |button| button.draw(*coordinates) }

        # Property buttons
        current_player.properties.each { |property| property.button.draw(*coordinates) }

        draw_deed_menu
        draw_group_menu
        draw_options_menu
        draw_dialogue_box
      end

      def draw_card_menu
        return unless drawing_card_menu?

        current_card.image.draw(
          draw_height: 245,
          draw_width: 420,
          from_center: true,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y,
          z: ZOrder::MENU_UI
        )

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_dialogue_box?
        visible_card_menu_buttons.each { |button| button.draw(*coordinates) }
      end

      def draw_deed_menu
        return unless drawing_deed_menu?

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_dialogue_box?

        Gosu.draw_rect(
          color: colors[:pop_up_menu_border],
          height: Coordinates::DEED_MENU_HEIGHT,
          width: Coordinates::DEED_MENU_WIDTH,
          x: Coordinates::DEED_MENU_LEFT_X,
          y: Coordinates::DEED_MENU_TOP_Y,
          z: ZOrder::MENU_BACKGROUND
        )
        Gosu.draw_rect(
          color: colors[:pop_up_menu_background],
          height: Coordinates::DEED_MENU_HEIGHT - (Coordinates::DEED_MENU_BORDER_WIDTH * 2),
          width: Coordinates::DEED_MENU_WIDTH - (Coordinates::DEED_MENU_BORDER_WIDTH * 2),
          x: Coordinates::DEED_MENU_LEFT_X + Coordinates::DEED_MENU_BORDER_WIDTH,
          y: Coordinates::DEED_MENU_TOP_Y + Coordinates::DEED_MENU_BORDER_WIDTH,
          z: ZOrder::MENU_BACKGROUND
        )

        draw_deed_base

        if focused_tile.is_a?(StreetTile)
          draw_street_tile_deed
        elsif focused_tile.is_a?(RailroadTile)
          draw_railroad_tile_deed
        else
          draw_utility_tile_deed
        end

        visible_deed_menu_buttons.each { |button| button.draw(*coordinates) }
      end

      def draw_dialogue_box
        return unless drawing_dialogue_box?

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
          height: Coordinates::DIALOGUE_BOX_HEIGHT,
          width: Coordinates::DIALOGUE_BOX_WIDTH,
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

      def draw_group_menu
        return unless drawing_group_menu?

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_dialogue_box?

        Gosu.draw_rect(
          color: colors[:pop_up_menu_border],
          height: Coordinates::GROUP_MENU_HEIGHT,
          width: Coordinates::GROUP_MENU_WIDTH,
          x: Coordinates::GROUP_MENU_LEFT_X,
          y: Coordinates::GROUP_MENU_TOP_Y,
          z: ZOrder::MENU_BACKGROUND
        )
        Gosu.draw_rect(
          color: colors[:pop_up_menu_background],
          height: Coordinates::GROUP_MENU_HEIGHT - (Coordinates::GROUP_MENU_BORDER_WIDTH * 2),
          width: Coordinates::GROUP_MENU_WIDTH - (Coordinates::GROUP_MENU_BORDER_WIDTH * 2),
          x: Coordinates::GROUP_MENU_LEFT_X + Coordinates::GROUP_MENU_BORDER_WIDTH,
          y: Coordinates::GROUP_MENU_TOP_Y + Coordinates::GROUP_MENU_BORDER_WIDTH,
          z: ZOrder::MENU_BACKGROUND
        )

        visible_group_menu_buttons.each do |button|

          button.draw(*coordinates)
        end
      end

      def draw_options_menu
        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_dialogue_box?
        buttons[:options].draw(*coordinates)
        return unless drawing_options_menu?


        Gosu.draw_rect(**options_menu_bar_paramaters)
        options_menu_buttons.each_value do |button|
          button.draw(*coordinates)
        end
      end

      def draw_tile_menu
        return if drawing_card_menu? || drawing_deed_menu? || drawing_group_menu?

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_dialogue_box?

        if focused_tile.is_a?(PropertyTile)
          focused_tile.tile_image.draw(
            draw_height: 658,
            draw_width: 400,
            from_center: true,
            x: Coordinates::CENTER_X,
            y: Coordinates::CENTER_Y,
            z: ZOrder::MAIN_UI
          )
        else
          width = focused_tile.corner? ? 658 : 400

          focused_tile.tile_image.draw(
            draw_height: 658,
            draw_width: width,
            from_center: true,
            x: Coordinates::CENTER_X,
            y: Coordinates::CENTER_Y,
            z: ZOrder::MAIN_UI
          )
        end

        visible_tile_menu_buttons.each { |button| button.draw(*coordinates) }
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

      def set_visible_card_menu_buttons
        self.visible_card_menu_buttons = []
        if current_card
          visible_card_menu_buttons << card_menu_buttons[:back]
          visible_card_menu_buttons << card_menu_buttons[:continue] if !current_card.triggered
        end
      end

      def set_visible_deed_menu_buttons
        self.visible_deed_menu_buttons = []
        visible_deed_menu_buttons << deed_menu_buttons[:close]

        max_width = Coordinates::DEED_WIDTH * 0.75
        line_count = deed_name_text.size

        # Find the best way to split the name across up to the 3 lines
        font_size = (MINIMUM_FONT_SIZE..fonts[:deed][:type].height).to_a.reverse.bsearch do |size|
          font = Gosu::Font.new(size, name: fonts[:deed][:type].name)
          temp_deed_name_text = Array.new(line_count)
          line_index = 0
          success = true
          words = focused_tile.name.split
          words.each.with_index do |word, index|
            new_line =
              if temp_deed_name_text[line_index]
                "#{temp_deed_name_text[line_index]} #{word.upcase}".strip
              else
                word.upcase
              end

            # The line can fit the new word
            if font.text_width(new_line) < max_width
              temp_deed_name_text[line_index] = new_line

            # The word alone can't fit on the line
            elsif temp_deed_name_text[line_index].nil?
              trailing_text = line_index >= line_count - 1 ? '...' : '-'
              truncated_text = font.truncate_text(text: new_line, width: max_width)
              temp_deed_name_text[line_index] = truncated_text + trailing_text
              words.insert(index + 1, new_line[truncated_text.length..-1])

              if line_index >= line_count - 1
                success = false
                break
              end

            # The line cannot fit the new word, but we're not out of lines yet
            elsif line_index < line_count - 1
              line_index += 1
              redo

            # The last line cannot fit the new word
            else
              temp_deed_name_text[line_count - 1] = "#{temp_deed_name_text[line_count - 1]}..."
              success = false
              break
            end
          end

          # The last iteration with either of these conditions will be the optimal
          # solution, so we record the value each time to avoid having to reprocess
          # the lines once we've found the optimal font size
          self.deed_name_text = temp_deed_name_text if success || size == MINIMUM_FONT_SIZE
          success
        end

        fonts[:deed_name][:type] =
          Gosu::Font.new(font_size || MINIMUM_FONT_SIZE, name: fonts[:deed][:type].name)
      end

      def set_visible_group_menu_buttons
        self.visible_group_menu_buttons = []

        visible_group_menu_buttons << group_menu_buttons[:close]
        visible_group_menu_buttons << group_menu_buttons[:left] if group_menu_tiles.previous?
        visible_group_menu_buttons << group_menu_buttons[:right] if group_menu_tiles.next?

        index_offset = group_menu_tiles.all_items.size <= 2 ? 1 : 0
        group_menu_tiles.items.each.with_index do |tile, index|
          buttons = group_menu_buttons[:tiles][index + index_offset]
          buttons[:tile].hover_image = buttons[:tile].image = tile.tile_image
          buttons[:tile].actions = [[:display_tile, tile]]
          visible_group_menu_buttons << buttons[:tile]

          if tile.owner
            buttons[:owner].hover_image = buttons[:owner].image = tile.owner.token_image
            buttons[:owner].maximize_image_in_square(TOKEN_HEIGHT)
            visible_group_menu_buttons << buttons[:owner]

            if tile.group.monopolized? && tile.is_a?(StreetTile)
              if tile.owner == current_player
                buttons[:house_small].text = tile.house_count
                visible_group_menu_buttons << buttons[:house_small]

                buttons[:build_house].actions = [[:build_house, tile]]
                visible_group_menu_buttons << buttons[:build_house]

                buttons[:sell_house].actions = [[:sell_house, tile]]
                visible_group_menu_buttons << buttons[:sell_house]
              else
                buttons[:house_big].text = tile.house_count
                visible_group_menu_buttons << buttons[:house_big]
              end
            end

            if tile.owner == current_player
              if tile.mortgaged?
                buttons[:unmortgage].actions = [[:unmortgage, tile]]
                visible_group_menu_buttons << buttons[:unmortgage]
              else
                buttons[:mortgage].actions = [[:mortgage, tile]]
                visible_group_menu_buttons << buttons[:mortgage]
              end
            else
              visible_group_menu_buttons << buttons[:mortgage_lock] if tile.mortgaged?
            end
          end
        end

        shift_group_menu_buttons
      end

      def set_visible_tile_menu_buttons
        self.visible_tile_menu_buttons = []

        visible_tile_menu_buttons << tile_menu_buttons[:back] if focused_tile != current_tile
        visible_tile_menu_buttons << tile_menu_buttons[:show_card] if current_card

        return unless focused_tile.is_a?(PropertyTile)

        visible_tile_menu_buttons << tile_menu_buttons[:show_deed]

        tile_menu_buttons[:show_group].hover_image = tile_menu_buttons[:show_group].image =
          focused_tile.group.image

        tile_menu_buttons[:show_group].maximize_image_in_square(TOKEN_HEIGHT)
        visible_tile_menu_buttons << tile_menu_buttons[:show_group]

        if focused_tile.owner
          tile_menu_buttons[:owner].hover_image = focused_tile.owner.token_image
          tile_menu_buttons[:owner].image = focused_tile.owner.token_image
          color =
            if focused_tile.group.monopolized?
              colors[:token_monopoly_background]
            else
              colors[:tile_button]
            end

          tile_menu_buttons[:owner].color = tile_menu_buttons[:owner].hover_color = color

          tile_menu_buttons[:owner].maximize_image_in_square(TOKEN_HEIGHT)

          visible_tile_menu_buttons << tile_menu_buttons[:owner]

          if focused_tile.owner == current_player
            mortgage_button = focused_tile.mortgaged? ? :unmortgage : :mortgage
            visible_tile_menu_buttons << tile_menu_buttons[mortgage_button]
          else
            visible_tile_menu_buttons << tile_menu_buttons[:mortgage_lock] if focused_tile.mortgaged?
          end
        elsif focused_tile == current_tile && current_player_cache.nil?
          visible_tile_menu_buttons << tile_menu_buttons[:buy]
        end

        if focused_tile.is_a?(StreetTile)
          tile_menu_buttons[:show_group].image_background_color =
            tile_menu_buttons[:show_group].image_background_hover_color =
              focused_tile.group.color
          color = focused_tile.group.color
          tile_menu_buttons[:show_group].hover_color =
            Gosu::Color.new(100, color.red, color.green, color.blue)

          if focused_tile.owner == current_player
            if focused_tile.group.monopolized?
              visible_tile_menu_buttons.concat(
                tile_menu_buttons[:sell_house][0...focused_tile.house_count]
              )

              visible_tile_menu_buttons << tile_menu_buttons[:build_house][focused_tile.house_count] if
                focused_tile.house_count < MAX_HOUSE_COUNT
            end
          else
            visible_tile_menu_buttons.concat(tile_menu_buttons[:house][0...focused_tile.house_count])
          end
        else
          tile_menu_buttons[:show_group].hover_color = colors[:tile_button_hover]
          tile_menu_buttons[:show_group].image_background_color =
            tile_menu_buttons[:show_group].image_background_hover_color = nil
        end
      end

      def update_visible_buttons(*button_names)
        self.visible_buttons = button_names.map { |button_name| buttons[button_name] }
      end

      private

      def draw_deed_base
        Gosu.draw_rect(
          color: colors[:deed],
          from_center: true,
          height: Coordinates::DEED_HEIGHT,
          width: Coordinates::DEED_WIDTH,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y,
          z: ZOrder::MENU_BACKGROUND
        )

        Gosu.draw_rect(
          color: colors[:deed_accent],
          from_center: true,
          height: Coordinates::DEED_HEIGHT * 0.92,
          width: Coordinates::DEED_WIDTH * 0.92,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y,
          z: ZOrder::MENU_BACKGROUND
        )
        Gosu.draw_rect(
          color: colors[:deed],
          from_center: true,
          height: Coordinates::DEED_HEIGHT * 0.9,
          width: Coordinates::DEED_WIDTH * 0.9,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y,
          z: ZOrder::MENU_BACKGROUND
        )
      end

      def draw_railroad_tile_deed
      end

      def draw_street_tile_deed
        Gosu.draw_rect(
          color: colors[:deed_accent],
          from_center: true,
          height: Coordinates::DEED_HEIGHT * 0.25,
          width: Coordinates::DEED_WIDTH * 0.82,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.3),
          z: ZOrder::MENU_BACKGROUND
        )
        Gosu.draw_rect(
          color: focused_tile.group.color,
          from_center: true,
          height: Coordinates::DEED_HEIGHT * 0.23,
          width: Coordinates::DEED_WIDTH * 0.8,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.3),
          z: ZOrder::MENU_BACKGROUND
        )
        font = fonts[:deed][:type]
        font.draw_text(
          'TITLE DEED',
          color: colors[:deed_accent],
          rel_x: 0.5,
          rel_y: 0.5,
          scale_x: 0.5,
          scale_y: 0.5,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.38),
          z: ZOrder::MENU_BACKGROUND
        )

        initial_offset =
          ((deed_name_text.size - deed_name_text.compact.size) / 2.0) * fonts[:deed][:offset]
        deed_name_text.each.with_index do |text, index|
          fonts[:deed_name][:type].draw_text(
            text,
            color: colors[:deed_accent],
            rel_x: 0.5,
            rel_y: 0.5,
            x: Coordinates::CENTER_X,
            y: Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.38) + initial_offset +
              (fonts[:deed][:offset] * (index + 1)),
            z: ZOrder::MENU_BACKGROUND
          )
        end

        left_x = Coordinates::CENTER_X - (Coordinates::DEED_WIDTH * 0.4)
        right_x = Coordinates::CENTER_X + (Coordinates::DEED_WIDTH * 0.4)
        y = Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.125)
        y_offset = fonts[:deed][:offset]

        font.draw_text(
          'Rent',
          color: colors[:deed_accent],
          rel_y: 0.5,
          x: left_x,
          y: y,
          z: ZOrder::MENU_BACKGROUND
        )
        font.draw_text(
          "#{format_money(focused_tile.rent_with_houses(0))}",
          color: colors[:deed_accent],
          rel_x: 1,
          rel_y: 0.5,
          x: right_x,
          y: y,
          z: ZOrder::MENU_BACKGROUND
        )

        font.draw_text(
          'Rent with color group',
          color: colors[:deed_accent],
          rel_y: 0.5,
          x: left_x,
          y: y + y_offset,
          z: ZOrder::MENU_BACKGROUND
        )
        font.draw_text(
          "#{format_money(focused_tile.base_rent_with_color_group)}",
          color: colors[:deed_accent],
          rel_x: 1,
          rel_y: 0.5,
          x: right_x,
          y: y + y_offset,
          z: ZOrder::MENU_BACKGROUND
        )

        if MAX_HOUSE_COUNT < 8
          (1..MAX_HOUSE_COUNT).each do |house_count|
            font.draw_text(
              "Rent with #{house_count} house#{'s' if house_count > 1}",
              color: colors[:deed_accent],
              rel_y: 0.5,
              x: left_x,
              y: y + (y_offset * (house_count + 1)),
              z: ZOrder::MENU_BACKGROUND
            )
            font.draw_text(
              "#{format_money(focused_tile.rent_with_houses(house_count))}",
              color: colors[:deed_accent],
              rel_x: 1,
              rel_y: 0.5,
              x: right_x,
              y: y + (y_offset * (house_count + 1)),
              z: ZOrder::MENU_BACKGROUND
            )
          end
        end

        Gosu.draw_rect(
          color: colors[:deed_accent],
          from_center: true,
          height: Coordinates::DEED_HEIGHT * 0.005,
          width: Coordinates::DEED_WIDTH * 0.78,
          x: Coordinates::CENTER_X,
          y: y + (y_offset * 9),
          z: ZOrder::MENU_BACKGROUND
        )

        font.draw_text(
          'Houses cost',
          color: colors[:deed_accent],
          rel_y: 0.5,
          x: left_x,
          y: y + (y_offset * 10),
          z: ZOrder::MENU_BACKGROUND
        )
        font.draw_text(
          "#{format_money(focused_tile.group.house_cost)} each",
          color: colors[:deed_accent],
          rel_x: 1,
          rel_y: 0.5,
          x: right_x,
          y: y + (y_offset * 10),
          z: ZOrder::MENU_BACKGROUND
        )

        font.draw_text(
          'Houses sell for',
          color: colors[:deed_accent],
          rel_y: 0.5,
          x: left_x,
          y: y + (y_offset * 11),
          z: ZOrder::MENU_BACKGROUND
        )
        font.draw_text(
          "#{format_money(focused_tile.group.house_cost * BUILDING_SELL_PERCENTAGE)} each",
          color: colors[:deed_accent],
          rel_x: 1,
          rel_y: 0.5,
          x: right_x,
          y: y + (y_offset * 11),
          z: ZOrder::MENU_BACKGROUND
        )
      end

      def draw_utility_tile_deed
      end

      def shift_group_menu_buttons
        if [1, 3].include?(group_menu_tiles.all_items.size)
          return if group_menu_alt_button_positions

          self.group_menu_alt_button_positions = true
          group_menu_buttons[:tiles].map(&:values).flatten.each do |button|
            button.update_coordinates(x: button.x + Coordinates::GROUP_MENU_FIRST_TILE_ALT_X_OFFSET)
          end
        elsif group_menu_alt_button_positions
          self.group_menu_alt_button_positions = false
          group_menu_buttons[:tiles].map(&:values).flatten.each do |button|
            button.update_coordinates(x: button.x - Coordinates::GROUP_MENU_FIRST_TILE_ALT_X_OFFSET)
          end
        end
      end
    end
  end
end
