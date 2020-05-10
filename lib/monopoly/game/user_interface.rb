module Monopoly
  class Game < Gosu::Window
    module UserInterface
      COMPASS_BORDER_WIDTH = 10
      COMPASS_RANGE = 4
      DEFAULT_FONT_SIZE = 30
      DEFAULT_TILE_BUTTON_BORDER_WIDTH = 5
      DEFAULT_TILE_BUTTON_HEIGHT = 100
      DIALOGUE_BOX_BUTTON_GAP = 20
      HEADER_HEIGHT = 50
      MAX_DEED_ICON_HEIGHT = Coordinates::DEED_HEIGHT * 0.27
      MAX_DEED_ICON_WIDTH = Coordinates::DEED_HEIGHT * 0.5
      MAX_DEED_NAME_LINES = 3
      MINIMUM_ERROR_DIALOGUE_SECONDS = 2
      MINIMUM_FONT_SIZE = 15
      PLAYER_MENU_BUTTON_HEIGHT = 50
      PLAYER_MENU_RIGHT_BORDER_WIDTH = 5
      PLAYER_MENU_ROUNDED_CORNER_RADIUS = 35
      TILE_BUTTON_GAP = 15
      TOKEN_HEIGHT = 70

      def display_error(message)
        wrapped_text_data = Gosu::Font.wrap_text(
          max_lines: 4,
          max_size: fonts[:default][:type].height,
          min_size: MINIMUM_FONT_SIZE,
          name: fonts[:default][:type].name,
          text: message,
          width: (Coordinates::ERROR_DIALOGUE_WIDTH - (Coordinates::ERROR_DIALOGUE_BORDER_WIDTH * 2)) * 0.95
        )

        error_dialogue_data[:font] = wrapped_text_data[:font]
        compacted_lines = wrapped_text_data[:lines].compact
        initial_offset = fonts[:error_dialogue][:offset] *
          ((wrapped_text_data[:lines].size - compacted_lines.size) / 2.0)
        error_dialogue_data[:lines] = compacted_lines.map.with_index do |line, index|
          {
            text: line,
            y: initial_offset + Coordinates::ERROR_DIALOGUE_TOP_Y +
              Coordinates::ERROR_DIALOGUE_BORDER_WIDTH + (fonts[:error_dialogue][:offset] * index)
          }
        end

        # Make the error dialogue stay up for more time the longer the error message
        self.error_ticks = ticks_for_seconds(
          MINIMUM_ERROR_DIALOGUE_SECONDS + (0.03 * compacted_lines.sum(&:length))
        ).round
      end

      def display_tile(tile)
        self.focused_tile = tile
        set_visible_tile_menu_buttons
        toggle_card_menu if drawing_card_menu?
        close_pop_up_menus
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

        draw_player_menu
        draw_card_menu
        draw_tile_menu

        # Mouse coordinates
        fonts[:default][:type].draw_text(
          "#{mouse_x.round(3)}, #{mouse_y.round(3)}",
          color: colors[:default_text],
          rel_x: 1,
          rel_y: 0,
          x: Coordinates::RIGHT_X * 0.85,
          y: Coordinates::TOP_Y,
          z: ZOrder::POP_UP_MENU_UI
        )

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_pop_up_menu? ||
          drawing_dialogue_box?

        # Primary buttons
        visible_buttons.each { |button| button.draw(*coordinates) }

        # Pop up background blur
        if drawing_pop_up_menu? && !drawing_dialogue_box?
          Gosu.draw_rect(
            color: colors[:blur],
            height: Coordinates::BOTTOM_Y - Coordinates::TOP_Y,
            width: Coordinates::RIGHT_X - Coordinates::LEFT_X,
            x: Coordinates::LEFT_X,
            y: Coordinates::TOP_Y,
            z: ZOrder::POP_UP_BLUR
          )
        end

        # Header background
        Gosu.draw_rect(
          color: colors[:pop_up_menu_background_light],
          height: HEADER_HEIGHT,
          width: Coordinates::RIGHT_X - Coordinates::LEFT_X,
          x: Coordinates::LEFT_X,
          y: Coordinates::TOP_Y,
          z: ZOrder::MENU_BACKGROUND
        )

        draw_compass_menu
        draw_deed_menu
        draw_event_history_menu
        draw_game_menu
        draw_group_menu
        draw_player_inspector
        draw_player_list_menu

        draw_options_menu
        draw_dialogue_box
        draw_error_dialogue
      end

      def draw_card_menu
        return unless drawing_card_menu?

        current_card.image.draw(
          draw_height: Coordinates::CARD_HEIGHT,
          draw_width: Coordinates::CARD_WIDTH,
          from_center: true,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y,
          z: ZOrder::MENU_UI
        )

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_dialogue_box?
        visible_card_menu_buttons.each { |button| button.draw(*coordinates) }
      end

      def draw_compass_menu
        return unless drawing_compass_menu?

        compass_menu_data[:outer_circle].draw(
          compass_menu_data[:left_circle_params]
        )
        compass_menu_data[:outer_circle].draw(
          compass_menu_data[:right_circle_params]
        )
        compass_menu_data[:inner_circle].draw(
          compass_menu_data[:left_circle_params]
        )
        compass_menu_data[:inner_circle].draw(
          compass_menu_data[:right_circle_params]
        )
        Gosu.draw_rect(compass_menu_data[:tile_background])

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_pop_up_menu? ||
          drawing_dialogue_box?
        visible_compass_menu_buttons.each { |button| button.draw(*coordinates) }

        Gosu.draw_rect(compass_menu_data[:bottom_border])
        Gosu.draw_triangle(compass_menu_data[:point])
        Gosu.draw_rect(compass_menu_data[:top_border])
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
          z: ZOrder::POP_UP_MENU_BACKGROUND
        )
        Gosu.draw_rect(
          color: colors[:pop_up_menu_background],
          height: Coordinates::DEED_MENU_HEIGHT - (Coordinates::DEED_MENU_BORDER_WIDTH * 2),
          width: Coordinates::DEED_MENU_WIDTH - (Coordinates::DEED_MENU_BORDER_WIDTH * 2),
          x: Coordinates::DEED_MENU_LEFT_X + Coordinates::DEED_MENU_BORDER_WIDTH,
          y: Coordinates::DEED_MENU_TOP_Y + Coordinates::DEED_MENU_BORDER_WIDTH,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        )

        if focused_tile.deed_image
          focused_tile.deed_image.draw(
            draw_height: Coordinates::DEED_HEIGHT,
            draw_width: Coordinates::DEED_WIDTH,
            from_center: true,
            x: Coordinates::CENTER_X,
            y: Coordinates::CENTER_Y,
            z: ZOrder::POP_UP_MENU_UI
          )
        else
          draw_deed_base

          if focused_tile.is_a?(StreetTile)
            draw_street_tile_deed
          elsif focused_tile.is_a?(RailroadTile)
            draw_railroad_tile_deed
          else
            draw_utility_tile_deed
          end
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
          z: ZOrder::DIALOGUE_BLUR
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

      def draw_error_dialogue
        return unless drawing_error_dialogue?

        error_dialogue_data[:rectangles].each { |data| Gosu.draw_rect(data) }
        error_dialogue_data[:exclamation_point][:image].draw(
          error_dialogue_data[:exclamation_point][:params]
        )

        error_dialogue_data[:lines].each do |line|
          error_dialogue_data[:font].draw_text(
            line[:text],
            y: line[:y],
            **error_dialogue_data[:text]
          )
        end

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_dialogue_box?
        error_dialogue_buttons[:close].draw(*coordinates)

        self.error_ticks -= 1
        close_error_dialogue unless error_ticks.positive?
      end

      def draw_event_history_menu
        return unless drawing_event_history_menu?

        Gosu.draw_rect(
          color: colors[:pop_up_menu_border],
          height: Coordinates::EVENT_HISTORY_MENU_HEIGHT,
          width: Coordinates::EVENT_HISTORY_MENU_WIDTH,
          x: Coordinates::EVENT_HISTORY_MENU_LEFT_X,
          y: Coordinates::EVENT_HISTORY_MENU_TOP_Y,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        )
        Gosu.draw_rect(
          color: colors[:pop_up_menu_background],
          height: Coordinates::EVENT_HISTORY_MENU_HEIGHT -
            (Coordinates::EVENT_HISTORY_MENU_BORDER_WIDTH * 2),
          width: Coordinates::EVENT_HISTORY_MENU_WIDTH -
            (Coordinates::EVENT_HISTORY_MENU_BORDER_WIDTH * 2),
          x: Coordinates::EVENT_HISTORY_MENU_LEFT_X + Coordinates::EVENT_HISTORY_MENU_BORDER_WIDTH,
          y: Coordinates::EVENT_HISTORY_MENU_TOP_Y + Coordinates::EVENT_HISTORY_MENU_BORDER_WIDTH,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        )

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_dialogue_box?
        visible_event_history_menu_buttons.each { |button| button.draw(*coordinates) }
      end

      def draw_game_menu
        return unless drawing_game_menu?

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_pop_up_menu? ||
          drawing_dialogue_box?
        game_menu_buttons.values.each { |button| button.draw(*coordinates) }
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
          z: ZOrder::POP_UP_MENU_BACKGROUND
        )
        Gosu.draw_rect(
          color: colors[:pop_up_menu_background],
          height: Coordinates::GROUP_MENU_HEIGHT - (Coordinates::GROUP_MENU_BORDER_WIDTH * 2),
          width: Coordinates::GROUP_MENU_WIDTH - (Coordinates::GROUP_MENU_BORDER_WIDTH * 2),
          x: Coordinates::GROUP_MENU_LEFT_X + Coordinates::GROUP_MENU_BORDER_WIDTH,
          y: Coordinates::GROUP_MENU_TOP_Y + Coordinates::GROUP_MENU_BORDER_WIDTH,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        )

        visible_group_menu_buttons.each { |button| button.draw(*coordinates) }
      end

      def draw_options_menu
        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_dialogue_box?
        buttons[:options].draw(*coordinates)
        return unless drawing_options_menu?


        Gosu.draw_rect(**options_menu_bar_paramaters)
        options_menu_buttons.each_value { |button| button.draw(*coordinates) }
      end

      def draw_player_inspector
        return unless drawing_player_inspector?

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_dialogue_box?

        player_inspector_data[:rectangles].each do |data|
          Gosu.draw_rect(data.except(:stats)) unless !data[:stats] && player_inspector_show_stats
        end

        visible_player_inspector_buttons.each { |button| button.draw(*coordinates) }
      end

      def draw_player_list_menu
        return unless drawing_player_list_menu?

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_dialogue_box?

        Gosu.draw_rect(
          color: colors[:pop_up_menu_border],
          height: Coordinates::PLAYER_LIST_MENU_HEIGHT,
          width: Coordinates::PLAYER_LIST_MENU_WIDTH,
          x: Coordinates::PLAYER_LIST_MENU_LEFT_X,
          y: Coordinates::PLAYER_LIST_MENU_TOP_Y,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        )
        Gosu.draw_rect(
          color: colors[:pop_up_menu_background],
          height: Coordinates::PLAYER_LIST_MENU_HEIGHT - (Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH * 2),
          width: Coordinates::PLAYER_LIST_MENU_WIDTH - (Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH * 2),
          x: Coordinates::PLAYER_LIST_MENU_LEFT_X + Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH,
          y: Coordinates::PLAYER_LIST_MENU_TOP_Y + Coordinates::PLAYER_LIST_MENU_BORDER_WIDTH,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        )

        visible_player_list_menu_buttons.each { |button| button.draw(*coordinates) }
      end

      def draw_player_menu
        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_pop_up_menu? ||
          drawing_dialogue_box?

        Gosu.draw_rect(player_menu_data[:right_border_params])
        Gosu.draw_rect(player_menu_data[:background_params])
        player_menu_data[:rounded_corner_circle].draw(
          player_menu_data[:rounded_corner_circle_params]
        )
        Gosu.draw_rect(player_menu_data[:top_border_params])
        (0...player_menu_data[:jail_bar_count])
          .each { |number| Gosu.draw_rect(player_menu_data[:jail_bars][number]) }

        visible_player_menu_buttons.each { |button| button.draw(*coordinates) }
      end

      def draw_tile_menu
        return if drawing_card_menu? || drawing_pop_up_menu?

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_dialogue_box?

        if focused_tile.is_a?(PropertyTile)
          focused_tile.tile_image.draw(
            draw_height: Coordinates::TILE_HEIGHT,
            draw_width: Coordinates::TILE_WIDTH,
            from_center: true,
            x: Coordinates::CENTER_X,
            y: Coordinates::CENTER_Y,
            z: ZOrder::MAIN_UI
          )
        else
          width = focused_tile.corner? ? Coordinates::TILE_HEIGHT : Coordinates::TILE_WIDTH

          focused_tile.tile_image.draw(
            draw_height: Coordinates::TILE_HEIGHT,
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
            z: ZOrder::POP_UP_MENU_UI
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

      def set_visible_compass_menu_buttons
        self.visible_compass_menu_buttons = []

        ratio = Coordinates::TILE_HEIGHT / DEFAULT_TILE_BUTTON_HEIGHT.to_f
        normal_width = Coordinates::TILE_WIDTH / ratio
        corner_width = Coordinates::TILE_HEIGHT / ratio
        button = compass_menu_buttons[0]
        button.image = current_tile.tile_image.clone
        button.hover_image = current_tile.tile_image.clone
        width = current_tile.corner? ? corner_width : normal_width
        button.width = button.image_width = button.hover_image_width = width
        button.update_coordinates(x: Coordinates::CENTER_X - (width / 2))
        visible_compass_menu_buttons << button

        current_tile_index = tile_indexes[current_tile]
        right_offset = left_offset = width / 2
        (1..COMPASS_RANGE).each do |index|
          break unless tile_count >= index * 2

          tile = tiles[(current_tile_index + index) % tile_count]
          button = compass_menu_buttons[index]
          button.image = tile.tile_image.clone
          button.hover_image = tile.tile_image.clone
          width = tile.corner? ? corner_width : normal_width
          button.width = button.image_width = button.hover_image_width = width
          button.update_coordinates(x: Coordinates::CENTER_X + right_offset)
          right_offset += width
          visible_compass_menu_buttons << button

          break unless tile_count >= index * 2 + 1

          tile = tiles[(current_tile_index - index) % tile_count]
          button = compass_menu_buttons[-index]
          button.image = tile.tile_image.clone
          button.hover_image = tile.tile_image.clone
          width = tile.corner? ? corner_width : normal_width
          button.width = button.image_width = button.hover_image_width = width
          left_offset += width
          button.update_coordinates(x: Coordinates::CENTER_X - left_offset)
          visible_compass_menu_buttons << button
        end

        left_edge = Coordinates::CENTER_X - left_offset
        compass_menu_data[:bottom_border][:x] = compass_menu_data[:top_border][:x] =
          compass_menu_data[:tile_background][:x] = left_edge
        compass_menu_data[:bottom_border][:width] = compass_menu_data[:top_border][:width] =
          compass_menu_data[:tile_background][:width] = left_offset + right_offset

        compass_menu_data[:left_circle_params][:x] = left_edge
        compass_menu_data[:right_circle_params][:x] = Coordinates::CENTER_X + right_offset
      end

      def set_visible_deed_menu_buttons
        self.visible_deed_menu_buttons = []
        self.deed_data = {}
        visible_deed_menu_buttons << deed_menu_buttons[:close]

        set_deed_base_data
        wrapped_text_data = Gosu::Font.wrap_text(
          max_lines: MAX_DEED_NAME_LINES,
          max_size: fonts[:deed][:type].height,
          min_size: MINIMUM_FONT_SIZE,
          name: fonts[:deed][:type].name,
          text: focused_tile.name.upcase,
          width: Coordinates::DEED_WIDTH * 0.75
        )
        fonts[:deed_name][:type] = wrapped_text_data[:font]
        deed_data[:name] = wrapped_text_data[:lines]

        if focused_tile.is_a?(StreetTile)
          set_street_tile_deed_data
        elsif focused_tile.is_a?(RailroadTile)
          set_railroad_tile_deed_data
        else
          set_utility_tile_deed_data
        end
      end

      def set_visible_event_history_menu_buttons
        self.visible_event_history_menu_buttons = []

        visible_event_history_menu_buttons << event_history_menu_buttons[:close]
        if event_history_view.previous?
          self.visible_event_history_menu_buttons +=
            event_history_menu_buttons.values_at(:page_up, :skip_to_top, :up)
        end

        if event_history_view.next?
          self.visible_event_history_menu_buttons +=
            event_history_menu_buttons.values_at(:down, :page_down, :skip_to_bottom)
        end

        event_history_view.items.each.with_index do |event, index|
          button = event_history_menu_buttons[:events][index]
          if event[:font]
            line_count = event[:text].count("\n") + 1
            button.instance_variable_set(:@text, event[:text])
            button.instance_variable_set(:@font, event[:font])
          else
            wrap_text_data = Gosu::Font.wrap_text(
              max_lines: 3,
              max_size: fonts[:default][:type].height,
              min_size: MINIMUM_FONT_SIZE,
              name: fonts[:default][:type].name,
              text: event[:text],
              width: button.width
            )

            compacted_lines = wrap_text_data[:lines].compact
            line_count = compacted_lines.size
            wrapped_text = compacted_lines.join("\n")
            button.instance_variable_set(:@text, wrapped_text)
            button.instance_variable_set(:@font, wrap_text_data[:font])
            event[:font] = wrap_text_data[:font]
            event[:text] = wrapped_text
          end

          button.instance_variable_set(:@text_position_y, 0.5 - (line_count - 1) * 0.175)
          button.update_coordinates

          visible_event_history_menu_buttons << button
        end
      end

      def set_visible_group_menu_buttons
        self.visible_group_menu_buttons = []

        visible_group_menu_buttons << group_menu_buttons[:close]
        visible_group_menu_buttons << group_menu_buttons[:left] if group_menu_tiles.previous?
        visible_group_menu_buttons << group_menu_buttons[:right] if group_menu_tiles.next?

        index_offset = group_menu_tiles.all_items.size <= 2 ? 1 : 0
        group_menu_tiles.items.each.with_index do |tile, index|
          buttons = group_menu_buttons[:tiles][index + index_offset]
          buttons[:tile].hover_image = tile.tile_image.clone
          buttons[:tile].image = tile.tile_image.clone
          buttons[:tile].actions = [[:display_tile, tile]]
          visible_group_menu_buttons << buttons[:tile]

          if tile.owner
            buttons[:owner].hover_image = tile.owner.token_image.clone
            buttons[:owner].image = tile.owner.token_image.clone
            buttons[:owner].maximize_images_in_square(TOKEN_HEIGHT)
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

      def set_visible_player_inspector_buttons(refresh: false)
        self.visible_player_inspector_buttons = []
        visible_player_inspector_buttons << player_inspector_buttons[:close]

        if player_inspector_show_stats
          player_inspector_buttons[:stats].each do |data|
            visible_player_inspector_buttons << data[:name]
            data[:value].text = data[:function].call(inspected_player)
            visible_player_inspector_buttons << data[:value]
          end

          visible_player_inspector_buttons << player_inspector_buttons[:stats_back]
          player_inspector_buttons[:stats_player_name].text = inspected_player.name
          visible_player_inspector_buttons << player_inspector_buttons[:stats_player_name]

          return
        end

        player_inspector_buttons[:player_token].hover_image = inspected_player.token_image.clone
        player_inspector_buttons[:player_token].image = inspected_player.token_image.clone
        player_inspector_buttons[:player_token].maximize_images_in_square(TOKEN_HEIGHT * 2)
        player_inspector_buttons[:player_token].highlight_color =
          player_inspector_buttons[:player_token].highlight_hover_color =
            inspected_player.eliminated? ? colors[:blur] : nil
        visible_player_inspector_buttons << player_inspector_buttons[:player_token]

        player_inspector_buttons[:player_name].text = inspected_player.name
        visible_player_inspector_buttons << player_inspector_buttons[:player_name]

        player_inspector_buttons[:currently_on].text = inspected_player.tile.name
        visible_player_inspector_buttons << player_inspector_buttons[:currently_on]

        player_inspector_buttons[:money].text =
          format_money(inspected_player.money, dollar_sign: false)
        visible_player_inspector_buttons << player_inspector_buttons[:money]

        if inspected_player.in_jail?
          player_inspector_buttons[:jail_turns].text = inspected_player.jail_turns.to_s
          visible_player_inspector_buttons << player_inspector_buttons[:jail_turns]
        end

        visible_player_inspector_buttons <<
          if inspected_player.cards.any? { |card| card.is_a?(GetOutOfJailFreeCard) }
            player_inspector_buttons[:get_out_of_jail_free]
          else
            player_inspector_buttons[:no_get_out_of_jail_free]
          end

        visible_player_inspector_buttons <<
          if inspected_player.properties.any? { |property| property.mortgaged? }
            player_inspector_buttons[:mortgaged_properties]
          else
            player_inspector_buttons[:no_mortgaged_properties]
          end

        visible_player_inspector_buttons << player_inspector_buttons[:all_properties]

        if refresh
          [
            player_inspector_color_groups,
            player_inspector_railroad_groups,
            player_inspector_utility_groups
          ].each { |group_set| group_set.items = group_set.all_items }
        end

        %i[railroad utility].each do |type|
          groups = send(:"player_inspector_#{type}_groups")
          visible_player_inspector_buttons << player_inspector_buttons[:"#{type}_group_left"] if
            groups.previous?
          visible_player_inspector_buttons << player_inspector_buttons[:"#{type}_group_right"] if
            groups.next?

          button = player_inspector_buttons[:"#{type}_group"]
          group = groups.items.first
          amount_owned = group.amount_owned(inspected_player)
          if amount_owned.positive? && group.monopolized?
            button.color = colors[:monopoly_button_background]
            button.hover_color = colors[:monopoly_button_background_hover]
          else
            button.color = colors[:tile_button]
            button.hover_color = colors[:tile_button_hover]
          end

          button.text = "#{group.amount_owned(inspected_player)}/#{group.tiles.count}"
          button.image = group.image.clone
          button.hover_image = group.image.clone

          visible_player_inspector_buttons << button
        end

        visible_player_inspector_buttons << player_inspector_buttons[:color_groups_left] if
          player_inspector_color_groups.previous?
        visible_player_inspector_buttons << player_inspector_buttons[:color_groups_right] if
          player_inspector_color_groups.next?

        player_inspector_color_groups.items.each.with_index do |color_group, index|
          buttons = player_inspector_buttons[:color_groups][index]
          buttons[:color].color = buttons[:color].hover_color = color_group.color

          amount_owned = color_group.amount_owned(inspected_player)
          if amount_owned.positive? && color_group.monopolized?
            buttons[:count].color = colors[:monopoly_button_background]
            buttons[:count].hover_color = colors[:monopoly_button_background_hover]
          else
            buttons[:count].color = colors[:tile_button]
            buttons[:count].hover_color = colors[:tile_button_hover]
          end

          buttons[:count].text =
            "#{color_group.amount_owned(inspected_player)}/#{color_group.tiles.count}"

          self.visible_player_inspector_buttons += buttons.values
        end

        visible_player_inspector_buttons << player_inspector_buttons[:show_stats]
        unless inspected_player == current_player || inspected_player.eliminated?
          visible_player_inspector_buttons << player_inspector_buttons[:message]
          visible_player_inspector_buttons << player_inspector_buttons[:trade]
        end
      end

      def set_visible_player_list_menu_buttons
        self.visible_player_list_menu_buttons = []

        visible_player_list_menu_buttons << player_list_menu_buttons[:close]
        visible_player_list_menu_buttons << player_list_menu_buttons[:left] if
          player_list_menu_players.previous?
        visible_player_list_menu_buttons << player_list_menu_buttons[:right] if
          player_list_menu_players.next?

        initial_offset = player_list_menu_data[:initial_x] + player_list_menu_data[:offset] *
          ((player_list_menu_players.view_size - player_list_menu_players.items.size) / 2.0)

        player_list_menu_players.items.each.with_index do |player, index|
          buttons = player_list_menu_buttons[:players][index]
          buttons[:token].hover_image = player.token_image.clone
          buttons[:token].image = player.token_image.clone
          buttons[:token].maximize_images_in_square(TOKEN_HEIGHT * 2)
          buttons[:token].actions = proc do
            self.inspected_player = player
            toggle_player_inspector
          end

          x = initial_offset + (player_list_menu_data[:offset] * index)
          buttons[:token].update_coordinates(x: x)
          buttons[:token].highlight_color = buttons[:token].highlight_hover_color =
            player.eliminated? ? colors[:blur] : nil
          visible_player_list_menu_buttons << buttons[:token]

          buttons[:name].text = player.name
          buttons[:name].update_coordinates(x: x - DEFAULT_TILE_BUTTON_HEIGHT)
          visible_player_list_menu_buttons << buttons[:name]

          unless player == current_player || player.eliminated?
            buttons[:message].update_coordinates(x: x - (DEFAULT_TILE_BUTTON_HEIGHT * 0.4))
            visible_player_list_menu_buttons << buttons[:message]

            buttons[:trade].update_coordinates(x: x + (DEFAULT_TILE_BUTTON_HEIGHT * 0.4))
            visible_player_list_menu_buttons << buttons[:trade]
          end
        end
      end

      def set_visible_player_menu_buttons(refresh: false)
        self.visible_player_menu_buttons = []

        player_menu_buttons[:player_token].hover_image = current_player.token_image.clone
        player_menu_buttons[:player_token].image = current_player.token_image.clone
        player_menu_buttons[:player_token].maximize_images_in_square(TOKEN_HEIGHT)
        visible_player_menu_buttons << player_menu_buttons[:player_token]

        player_menu_buttons[:player_name].text = current_player.name
        visible_player_menu_buttons << player_menu_buttons[:player_name]

        player_menu_data[:jail_bar_count] = 0
        if current_player.in_jail?
          visible_player_menu_buttons << player_menu_buttons[:jail_turns]
          if jail_time <= DEFAULT_JAIL_TIME
            player_menu_data[:jail_bar_count] = current_player.jail_turns
          else
            player_menu_buttons[:jail_turns].text = current_player.jail_turns.to_s
          end
        end

        player_menu_buttons[:money].text = format_money(current_player.money)
        visible_player_menu_buttons << player_menu_buttons[:money]

        visible_player_menu_buttons <<
          if current_player.cards.any? { |card| card.is_a?(GetOutOfJailFreeCard) }
            player_menu_buttons[:get_out_of_jail_free]
          else
            player_menu_buttons[:no_get_out_of_jail_free]
          end

        visible_player_menu_buttons <<
          if current_player.properties.any? { |property| property.mortgaged? }
            player_menu_buttons[:mortgaged_properties]
          else
            player_menu_buttons[:no_mortgaged_properties]
          end

        visible_player_menu_buttons << player_menu_buttons[:all_properties]

        if refresh
          [player_menu_color_groups, player_menu_railroad_groups, player_menu_utility_groups]
            .each { |group_set| group_set.items = group_set.all_items }

          self.next_players.items =
            players[current_player_index + 1..-1] + players[0...current_player_index]
        end

        %i[railroad utility].each do |type|
          groups = send(:"player_menu_#{type}_groups")
          visible_player_menu_buttons << player_menu_buttons[:"#{type}_group_left"] if
            groups.previous?
          visible_player_menu_buttons << player_menu_buttons[:"#{type}_group_right"] if
            groups.next?

          button = player_menu_buttons[:"#{type}_group"]
          group = groups.items.first
          amount_owned = group.amount_owned(current_player)
          if amount_owned.positive? && group.monopolized?
            button.color = colors[:monopoly_button_background]
            button.hover_color = colors[:monopoly_button_background_hover]
          else
            button.color = colors[:tile_button]
            button.hover_color = colors[:tile_button_hover]
          end

          button.text = "#{group.amount_owned(current_player)}/#{group.tiles.count}"
          button.image = group.image.clone
          button.hover_image = group.image.clone

          visible_player_menu_buttons << button
        end

        visible_player_menu_buttons << player_menu_buttons[:color_groups_left] if
          player_menu_color_groups.previous?
        visible_player_menu_buttons << player_menu_buttons[:color_groups_right] if
          player_menu_color_groups.next?

        player_menu_color_groups.items.each.with_index do |color_group, index|
          buttons = player_menu_buttons[:color_groups][index]
          buttons[:color].color = buttons[:color].hover_color = color_group.color

          amount_owned = color_group.amount_owned(current_player)
          if amount_owned.positive? && color_group.monopolized?
            buttons[:count].color = colors[:monopoly_button_background]
            buttons[:count].hover_color = colors[:monopoly_button_background_hover]
          else
            buttons[:count].color = colors[:tile_button]
            buttons[:count].hover_color = colors[:tile_button_hover]
          end

          buttons[:count].text =
            "#{color_group.amount_owned(current_player)}/#{color_group.tiles.count}"

          self.visible_player_menu_buttons += buttons.values
        end

        visible_player_menu_buttons << player_menu_buttons[:next_players_down] if
          next_players.previous?
        visible_player_menu_buttons << player_menu_buttons[:next_players_up] if
          next_players.next?

        next_players.items.each.with_index do |player, index|
          button = player_menu_buttons[:next_players][index]

          button.hover_image = player.token_image.clone
          button.image = player.token_image.clone
          button.maximize_images_in_square(TOKEN_HEIGHT)

          visible_player_menu_buttons << button
        end
      end

      def set_visible_tile_menu_buttons
        self.visible_tile_menu_buttons = []

        tile_type = focused_tile.corner? ? :corner : :middle
        if focused_tile != current_tile
          x, y = tile_menu_data[:back][tile_type].values_at(:x, :y)
          tile_menu_buttons[:back].update_coordinates(x: x, y: y) unless
            tile_menu_buttons[:back].x == x && tile_menu_buttons[:back].y == y
          visible_tile_menu_buttons << tile_menu_buttons[:back]
        end

        visible_tile_menu_buttons << tile_menu_buttons[:show_card] if current_card

        if players.count { |player| player.tile == focused_tile }.positive?
          data = tile_menu_data[:show_players][tile_type]
          data = data[focused_tile.is_a?(PropertyTile) ? :property : :non_property] if
            tile_type == :middle
          x, y = data.values_at(:x, :y)
          tile_menu_buttons[:show_players].update_coordinates(x: x, y: y) unless
            tile_menu_buttons[:show_players].x == x && tile_menu_buttons[:show_players].y == y
          visible_tile_menu_buttons << tile_menu_buttons[:show_players]
        end

        return unless focused_tile.is_a?(PropertyTile)

        visible_tile_menu_buttons << tile_menu_buttons[:show_deed]

        tile_menu_buttons[:show_group].hover_image = focused_tile.group.image.clone
        tile_menu_buttons[:show_group].image = focused_tile.group.image.clone

        tile_menu_buttons[:show_group].maximize_images_in_square(TOKEN_HEIGHT)
        visible_tile_menu_buttons << tile_menu_buttons[:show_group]

        if focused_tile.owner
          tile_menu_buttons[:owner].hover_image = focused_tile.owner.token_image.clone
          tile_menu_buttons[:owner].image = focused_tile.owner.token_image.clone
          tile_menu_buttons[:owner].color, tile_menu_buttons[:owner].hover_color =
            if focused_tile.group.monopolized?
              colors.values_at(:monopoly_button_background, :monopoly_button_background_hover)
            else
              colors.values_at(:tile_button, :tile_button_hover)
            end

          tile_menu_buttons[:owner].maximize_images_in_square(TOKEN_HEIGHT)

          visible_tile_menu_buttons << tile_menu_buttons[:owner]

          if focused_tile.owner == current_player
            mortgage_button = focused_tile.mortgaged? ? :unmortgage : :mortgage
            visible_tile_menu_buttons << tile_menu_buttons[mortgage_button]
          elsif focused_tile.mortgaged?
            visible_tile_menu_buttons << tile_menu_buttons[:mortgage_lock]
          end
        elsif focused_tile == current_tile && current_player_cache.nil? && current_player_landed
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
              if max_house_count <= DEFAULT_MAX_HOUSE_COUNT
                visible_tile_menu_buttons.concat(
                  tile_menu_buttons[:sell_house][0...focused_tile.house_count]
                )

                visible_tile_menu_buttons << tile_menu_buttons[:build_house][focused_tile.house_count] if
                  focused_tile.house_count < max_house_count
              else
                visible_tile_menu_buttons << tile_menu_buttons[:build_house_arrow]
                tile_menu_buttons[:house_with_number].text = focused_tile.house_count
                visible_tile_menu_buttons << tile_menu_buttons[:house_with_number]
                visible_tile_menu_buttons << tile_menu_buttons[:sell_house_arrow]
              end
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
        Gosu.draw_rect(deed_data[:outer_border_params])
        Gosu.draw_rect(deed_data[:inner_border_params])
        Gosu.draw_rect(deed_data[:main_base_params])
      end

      def draw_railroad_tile_deed
        (focused_tile.icon || focused_tile.group.image).draw(deed_data[:image_params])

        font = fonts[:deed][:type]
        deed_data[:name_lines_params].each do |params|
          fonts[:deed_name][:type].draw_text(*params)
        end

        if deed_data[:rent_params]
          font.draw_text(*deed_data[:rent_params][:left])
          font.draw_text(*deed_data[:rent_params][:right])
        end

        deed_data[:rent_with_railroads_params]&.each do |data|
          font.draw_text(*data[:left])
          font.draw_text(*data[:right])
        end

        Gosu.draw_rect(deed_data[:divider_params])

        font.draw_text(*deed_data[:mortgage_value_params][:left])
        font.draw_text(*deed_data[:mortgage_value_params][:right])

        font.draw_text(*deed_data[:unmortgage_cost_params][:left])
        font.draw_text(*deed_data[:unmortgage_cost_params][:right])
      end

      def draw_street_tile_deed
        Gosu.draw_rect(deed_data[:color_box_border_params])
        Gosu.draw_rect(deed_data[:color_box_params])
        font = fonts[:deed][:type]
        font.draw_text(*deed_data[:title_deed_text_params])

        deed_data[:name_lines_params].each do |params|
          fonts[:deed_name][:type].draw_text(*params)
        end

        font.draw_text(*deed_data[:rent_line_params][:left])
        font.draw_text(*deed_data[:rent_line_params][:right])

        font.draw_text(*deed_data[:rent_with_color_group_line_params][:left])
        font.draw_text(*deed_data[:rent_with_color_group_line_params][:right])

        deed_data[:rent_with_houses_lines_params]&.each do |data|
          font.draw_text(*data[:left])
          font.draw_text(*data[:right])
        end

        Gosu.draw_rect(deed_data[:divider_params])

        font.draw_text(*deed_data[:house_cost_params][:left])
        font.draw_text(*deed_data[:house_cost_params][:right])

        font.draw_text(*deed_data[:house_sell_price_params][:left])
        font.draw_text(*deed_data[:house_sell_price_params][:right])

        font.draw_text(*deed_data[:mortgage_value_params][:left])
        font.draw_text(*deed_data[:mortgage_value_params][:right])

        font.draw_text(*deed_data[:unmortgage_cost_params][:left])
        font.draw_text(*deed_data[:unmortgage_cost_params][:right])
      end

      def draw_utility_tile_deed
        (focused_tile.icon || focused_tile.group.image).draw(deed_data[:image_params])
        deed_data[:name_lines_params].each do |params|
          fonts[:deed_name][:type].draw_text(*params)
        end

        deed_data[:rent_lines_params].each do |params|
          deed_data[:rent_font].draw_text(*params)
        end

        if deed_data[:rent_line_params]
          deed_data[:rent_font].draw_text(*deed_data[:rent_line_params][:left])
          deed_data[:rent_font].draw_text(*deed_data[:rent_line_params][:right])
        end

        Gosu.draw_rect(deed_data[:divider_params])

        font = fonts[:deed][:type]
        font.draw_text(*deed_data[:mortgage_value_params][:left])
        font.draw_text(*deed_data[:mortgage_value_params][:right])

        font.draw_text(*deed_data[:unmortgage_cost_params][:left])
        font.draw_text(*deed_data[:unmortgage_cost_params][:right])
      end

      def set_deed_base_data
        deed_data[:outer_border_params] = {
          color: colors[:deed],
          from_center: true,
          height: Coordinates::DEED_HEIGHT,
          width: Coordinates::DEED_WIDTH,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        }
        deed_data[:inner_border_params] = {
          color: colors[:deed_accent],
          from_center: true,
          height: Coordinates::DEED_HEIGHT * 0.92,
          width: Coordinates::DEED_WIDTH * 0.92,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        }
        deed_data[:main_base_params] = {
          color: colors[:deed],
          from_center: true,
          height: Coordinates::DEED_HEIGHT * 0.9,
          width: Coordinates::DEED_WIDTH * 0.9,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        }
      end

      def set_railroad_tile_deed_data
        image = (focused_tile.icon || focused_tile.group.image).clone
        if (image.height / MAX_DEED_ICON_HEIGHT) > (image.width / MAX_DEED_ICON_WIDTH)
          height = MAX_DEED_ICON_HEIGHT
        else
          width = MAX_DEED_ICON_WIDTH
        end

        deed_data[:image_params] = {
          draw_height: height,
          draw_width: width,
          from_center: true,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.28),
          z: ZOrder::POP_UP_MENU_UI
        }

        initial_offset =
          ((deed_data[:name].size - deed_data[:name].compact.size) / 2.0) * fonts[:deed][:offset]
        deed_data[:name_lines_params] = deed_data[:name].map.with_index do |text, index|
          [
            text,
            color: colors[:deed_accent],
            rel_x: 0.5,
            rel_y: 0.5,
            x: Coordinates::CENTER_X,
            y: Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.17) + initial_offset +
              (fonts[:deed][:offset] * (index + 1)),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ]
        end

        left_x = Coordinates::CENTER_X - (Coordinates::DEED_WIDTH * 0.4)
        right_x = Coordinates::CENTER_X + (Coordinates::DEED_WIDTH * 0.4)
        y = Coordinates::CENTER_Y + Coordinates::DEED_HEIGHT * 0.025
        y_offset = fonts[:deed][:offset]

        owner = focused_tile.owner

        if focused_tile.group.tiles.size < 7
          text_color =
            if owner && focused_tile.group.amount_owned(owner) == 1
              colors[:deed_highlight]
            else
              colors[:deed_accent]
            end

          deed_data[:rent_params] = {
            left: [
              'Rent',
              color: text_color,
              rel_y: 0.5,
              x: left_x,
              y: y,
              z: ZOrder::POP_UP_MENU_BACKGROUND
            ],
            right: [
              format_money(focused_tile.rent_with_railroads(1)),
              color: text_color,
              rel_x: 1,
              rel_y: 0.5,
              x: right_x,
              y: y,
              z: ZOrder::POP_UP_MENU_BACKGROUND
            ]
          }

          deed_data[:rent_with_railroads_params] =
            (2..focused_tile.group.tiles.size).map do |railroad_count|
              text_color =
                if owner && focused_tile.group.amount_owned(owner) == railroad_count
                  colors[:deed_highlight]
                else
                  colors[:deed_accent]
                end

              {
                left: [
                  "Rent with #{railroad_count} #{focused_tile.group.plural_name}",
                  color: text_color,
                  rel_y: 0.5,
                  x: left_x,
                  y: y + (y_offset * (railroad_count - 1)),
                  z: ZOrder::POP_UP_MENU_BACKGROUND
                ],
                right: [
                  format_money(focused_tile.rent_with_railroads(railroad_count)),
                  color: text_color,
                  rel_x: 1,
                  rel_y: 0.5,
                  x: right_x,
                  y: y + (y_offset * (railroad_count - 1)),
                  z: ZOrder::POP_UP_MENU_BACKGROUND
                ]
              }
            end
        else
          railroad_count = deed_rent_line_index

          visible_deed_menu_buttons << deed_menu_buttons[:up] if railroad_count > 1
          visible_deed_menu_buttons << deed_menu_buttons[:down] if
            railroad_count < focused_tile.group.tiles.size

          text_color =
            if owner && focused_tile.group.amount_owned(owner) == railroad_count
              colors[:deed_highlight]
            else
              colors[:deed_accent]
            end

          group_name =
            focused_tile.group.send("#{railroad_count == 1 ? 'singular' : 'plural'}_name")

          deed_data[:rent_with_railroads_params] = [
            {
              left: [
                "Rent with #{railroad_count} #{group_name}",
                color: text_color,
                rel_y: 0.5,
                x: left_x,
                y: y + y_offset,
                z: ZOrder::POP_UP_MENU_BACKGROUND
              ],
              right: [
                format_money(focused_tile.rent_with_railroads(railroad_count)),
                color: text_color,
                rel_x: 1,
                rel_y: 0.5,
                x: right_x,
                y: y + y_offset,
                z: ZOrder::POP_UP_MENU_BACKGROUND
              ]
            }
          ]
        end

        deed_data[:divider_params] = {
          color: colors[:deed_accent],
          from_center: true,
          height: Coordinates::DEED_HEIGHT * 0.005,
          width: Coordinates::DEED_WIDTH * 0.78,
          x: Coordinates::CENTER_X,
          y: y + (y_offset * 6),
          z: ZOrder::POP_UP_MENU_BACKGROUND
        }

        deed_data[:mortgage_value_params] = {
          left: [
            'Mortgage value',
            color: colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 7),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ],
          right: [
            format_money(focused_tile.mortgage_cost),
            color: colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 7),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ]
        }

        deed_data[:unmortgage_cost_params] = {
          left: [
            'Unmortgage cost',
            color: colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 8),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ],
          right: [
            format_money(focused_tile.unmortgage_cost),
            color: colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 8),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ]
        }
      end

      def set_street_tile_deed_data
        deed_data[:color_box_border_params] = {
          color: colors[:deed_accent],
          from_center: true,
          height: Coordinates::DEED_HEIGHT * 0.25,
          width: Coordinates::DEED_WIDTH * 0.82,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.3),
          z: ZOrder::POP_UP_MENU_BACKGROUND
        }
        deed_data[:color_box_params] = {
          color: focused_tile.group.color,
          from_center: true,
          height: Coordinates::DEED_HEIGHT * 0.23,
          width: Coordinates::DEED_WIDTH * 0.8,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.3),
          z: ZOrder::POP_UP_MENU_BACKGROUND
        }
        deed_data[:title_deed_text_params] = [
          'TITLE DEED',
          color: colors[:deed_accent],
          rel_x: 0.5,
          rel_y: 0.5,
          scale_x: 0.5,
          scale_y: 0.5,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.38),
          z: ZOrder::POP_UP_MENU_BACKGROUND
        ]

        initial_offset =
          ((deed_data[:name].size - deed_data[:name].compact.size) / 2.0) * fonts[:deed][:offset]
        deed_data[:name_lines_params] = deed_data[:name].map.with_index do |text, index|
          [
            text,
            color: colors[:deed_accent],
            rel_x: 0.5,
            rel_y: 0.5,
            x: Coordinates::CENTER_X,
            y: Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.38) + initial_offset +
              (fonts[:deed][:offset] * (index + 1)),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ]
        end

        left_x = Coordinates::CENTER_X - (Coordinates::DEED_WIDTH * 0.4)
        right_x = Coordinates::CENTER_X + (Coordinates::DEED_WIDTH * 0.4)
        y = Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.125)
        y_offset = fonts[:deed][:offset]

        text_color =
          if focused_tile.owner && !focused_tile.group.monopolized?
            colors[:deed_highlight]
          else
            colors[:deed_accent]
          end

        deed_data[:rent_line_params] = {
          left: [
            'Rent',
            color: text_color,
            rel_y: 0.5,
            x: left_x,
            y: y,
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ],
          right: [
            format_money(focused_tile.rent_with_houses(0)),
            color: text_color,
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y,
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ]
        }

        text_color =
          if focused_tile.group.monopolized? && focused_tile.house_count.zero?
            colors[:deed_highlight]
          else
            colors[:deed_accent]
          end

        deed_data[:rent_with_color_group_line_params] = {
          left: [
            'Rent with color group',
            color: text_color,
            rel_y: 0.5,
            x: left_x,
            y: y + y_offset,
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ],
          right: [
            format_money(focused_tile.base_rent_with_color_group),
            color: text_color,
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + y_offset,
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ]
        }

        deed_data[:rent_with_houses_lines_params] =
          if max_house_count <= DEFAULT_MAX_HOUSE_COUNT
            (1..max_house_count).map do |house_count|
              text_color =
                if house_count == focused_tile.house_count
                  colors[:deed_highlight]
                else
                  colors[:deed_accent]
                end

              {
                left: [
                  "Rent with #{house_count} house#{'s' if house_count > 1}",
                  color: text_color,
                  rel_y: 0.5,
                  x: left_x,
                  y: y + (y_offset * (house_count + 1)),
                  z: ZOrder::POP_UP_MENU_BACKGROUND
                ],
                right: [
                  format_money(focused_tile.rent_with_houses(house_count)),
                  color: text_color,
                  rel_x: 1,
                  rel_y: 0.5,
                  x: right_x,
                  y: y + (y_offset * (house_count + 1)),
                  z: ZOrder::POP_UP_MENU_BACKGROUND
                ]
              }
            end
          else
            house_count = deed_rent_line_index

            visible_deed_menu_buttons << deed_menu_buttons[:up] if house_count > 1
            visible_deed_menu_buttons << deed_menu_buttons[:down] if house_count < max_house_count

            text_color =
              if house_count == focused_tile.house_count
                colors[:deed_highlight]
              else
                colors[:deed_accent]
              end

            [
              {
                left: [
                  "Rent with #{house_count} house#{'s' if house_count > 1}",
                  color: text_color,
                  rel_y: 0.5,
                  x: left_x,
                  y: y + (y_offset * 4),
                  z: ZOrder::POP_UP_MENU_BACKGROUND
                ],
                right: [
                  format_money(focused_tile.rent_with_houses(house_count)),
                  color: text_color,
                  rel_x: 1,
                  rel_y: 0.5,
                  x: right_x,
                  y: y + (y_offset * 4),
                  z: ZOrder::POP_UP_MENU_BACKGROUND
                ]
              }
            ]
          end

        deed_data[:divider_params] = {
          color: colors[:deed_accent],
          from_center: true,
          height: Coordinates::DEED_HEIGHT * 0.005,
          width: Coordinates::DEED_WIDTH * 0.78,
          x: Coordinates::CENTER_X,
          y: y + (y_offset * 7),
          z: ZOrder::POP_UP_MENU_BACKGROUND
        }

        deed_data[:house_cost_params] = {
          left: [
            'Houses cost',
            color: colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 8),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ],
          right: [
            "#{format_money(focused_tile.group.house_cost)} each",
            color: colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 8),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ]
        }

        deed_data[:house_sell_price_params] = {
          left: [
            'Houses sell for',
            color: colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 9),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ],
          right: [
            "#{format_money(focused_tile.group.house_cost * building_sell_percentage)} each",
            color: colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 9),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ]
        }

        deed_data[:mortgage_value_params] = {
          left: [
            'Mortgage value',
            color: colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 10),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ],
          right: [
            format_money(focused_tile.mortgage_cost),
            color: colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 10),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ]
        }

        deed_data[:unmortgage_cost_params] = {
          left: [
            'Unmortgage cost',
            color: colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 11),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ],
          right: [
            format_money(focused_tile.unmortgage_cost),
            color: colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 11),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ]
        }
      end

      def set_utility_tile_deed_data
        image = (focused_tile.icon || focused_tile.group.image).clone
        if (image.height / MAX_DEED_ICON_HEIGHT) > (image.width / MAX_DEED_ICON_WIDTH)
          height = MAX_DEED_ICON_HEIGHT
        else
          width = MAX_DEED_ICON_WIDTH
        end

        deed_data[:image_params] = {
          draw_height: height,
          draw_width: width,
          from_center: true,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.27),
          z: ZOrder::POP_UP_MENU_UI
        }

        initial_offset =
          ((deed_data[:name].size - deed_data[:name].compact.size) / 2.0) * fonts[:deed][:offset]
        deed_data[:name_lines_params] = deed_data[:name].map.with_index do |text, index|
          [
            text,
            color: colors[:deed_accent],
            rel_x: 0.5,
            rel_y: 0.5,
            x: Coordinates::CENTER_X,
            y: Coordinates::CENTER_Y - (Coordinates::DEED_HEIGHT * 0.15) + initial_offset +
              (fonts[:deed][:offset] * (index + 1)),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ]
        end

        left_x = Coordinates::CENTER_X - (Coordinates::DEED_WIDTH * 0.4)
        right_x = Coordinates::CENTER_X + (Coordinates::DEED_WIDTH * 0.4)
        y = Coordinates::CENTER_Y + Coordinates::DEED_HEIGHT * 0.025
        y_offset = fonts[:deed][:offset]

        owner = focused_tile.owner
        max_paragraph_lines = 3
        if focused_tile.group.tiles.size == 2
          font = fonts[:deed][:type]
          text_color =
            if owner && focused_tile.group.amount_owned(owner) == 1
              colors[:deed_highlight]
            else
              colors[:deed_accent]
            end

          wrapped_text_data = Gosu::Font.wrap_text(
            max_lines: max_paragraph_lines,
            max_size: font.height,
            min_size: MINIMUM_FONT_SIZE,
            name: font.name,
            text: "If one #{focused_tile.group.singular_name} is owned, rent is " \
              "#{focused_tile.rent_multiplier_scale.first} times amount shown on dice.",
            width: Coordinates::DEED_WIDTH * 0.75
          )
          deed_data[:rent_font] = wrapped_text_data[:font]
          first_paragraph_offset = wrapped_text_data[:lines].count
          deed_data[:rent_lines_params] = wrapped_text_data[:lines].map.with_index do |text, index|
            [
              text,
              color: text_color,
              rel_x: 0.5,
              rel_y: 0.5,
              x: Coordinates::CENTER_X,
              y: Coordinates::CENTER_Y + (fonts[:deed][:offset] * (index + 0.75)),
              z: ZOrder::POP_UP_MENU_BACKGROUND
            ]
          end

          text_color =
            if owner && focused_tile.group.amount_owned(owner) == 2
              colors[:deed_highlight]
            else
              colors[:deed_accent]
            end

          wrapped_text_data = Gosu::Font.wrap_text(
            max_lines: max_paragraph_lines,
            max_size: font.height,
            min_size: MINIMUM_FONT_SIZE,
            name: font.name,
            text: "If both #{focused_tile.group.plural_name} are owned, rent is " \
              "#{focused_tile.rent_multiplier_scale.last} times amount shown on dice.",
            width: Coordinates::DEED_WIDTH * 0.75
          )
          deed_data[:rent_font] = [wrapped_text_data[:font], deed_data[:rent_font]].min_by(&:height)
          deed_data[:rent_lines_params] += wrapped_text_data[:lines].map.with_index do |text, index|
            [
              text,
              color: text_color,
              rel_x: 0.5,
              rel_y: 0.5,
              x: Coordinates::CENTER_X,
              y: Coordinates::CENTER_Y +
                (fonts[:deed][:offset] * (index + 1 + first_paragraph_offset)),
              z: ZOrder::POP_UP_MENU_BACKGROUND
            ]
          end
        else
          utility_count = deed_rent_line_index

          visible_deed_menu_buttons << deed_menu_buttons[:up] if utility_count > 1
          visible_deed_menu_buttons << deed_menu_buttons[:down] if
            utility_count < focused_tile.group.tiles.size

          text_color =
            if owner && focused_tile.group.amount_owned(owner) == utility_count
              colors[:deed_highlight]
            else
              colors[:deed_accent]
            end

          group_name =
            focused_tile.group.send("#{utility_count == 1 ? 'singular' : 'plural'}_name")
          y = Coordinates::CENTER_Y + Coordinates::DEED_HEIGHT * 0.025
          y_offset = fonts[:deed][:offset]

          deed_data[:rent_line_params] = {
            left: [
              "Multiplier with #{utility_count} #{group_name}",
              color: text_color,
              rel_y: 0.5,
              x: left_x,
              y: y + y_offset,
              z: ZOrder::POP_UP_MENU_BACKGROUND
            ],
            right: [
              format_number(focused_tile.rent_multiplier_scale[utility_count - 1]),
              color: text_color,
              rel_x: 1,
              rel_y: 0.5,
              x: right_x,
              y: y + y_offset,
              z: ZOrder::POP_UP_MENU_BACKGROUND
            ]
          }
          deed_data[:rent_font] = fonts[:deed][:type]

          wrapped_text_data = Gosu::Font.wrap_text(
            max_lines: max_paragraph_lines,
            max_size: fonts[:deed][:type].height,
            min_size: MINIMUM_FONT_SIZE,
            name: fonts[:deed][:type].name,
            text: "Rent is the amount shown on dice times the multiplier.",
            width: Coordinates::DEED_WIDTH * 0.75
          )
          deed_data[:rent_font] = [wrapped_text_data[:font], deed_data[:rent_font]].min_by(&:height)
          deed_data[:rent_lines_params] = wrapped_text_data[:lines].map.with_index do |text, index|
            [
              text,
              color: text_color,
              rel_x: 0.5,
              rel_y: 0.5,
              x: Coordinates::CENTER_X,
              y: y + (y_offset * (3.5 + index)),
              z: ZOrder::POP_UP_MENU_BACKGROUND
            ]
          end
        end

        deed_data[:divider_params] = {
          color: colors[:deed_accent],
          from_center: true,
          height: Coordinates::DEED_HEIGHT * 0.005,
          width: Coordinates::DEED_WIDTH * 0.78,
          x: Coordinates::CENTER_X,
          y: y + (y_offset * 6.25),
          z: ZOrder::POP_UP_MENU_BACKGROUND
        }

        deed_data[:mortgage_value_params] = {
          left: [
            'Mortgage value',
            color: colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 7),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ],
          right: [
            format_money(focused_tile.mortgage_cost),
            color: colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 7),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ]
        }

        deed_data[:unmortgage_cost_params] = {
          left: [
            'Unmortgage cost',
            color: colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 8),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ],
          right: [
            format_money(focused_tile.unmortgage_cost),
            color: colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 8),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          ]
        }
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
