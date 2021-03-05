module Monopoly
  class Game < Gosu::Window
    module UserInterface
      COMPASS_BORDER_WIDTH = 10
      COMPASS_RANGE = 4
      DEFAULT_FONT_SIZE = 30
      DEFAULT_TILE_BUTTON_BORDER_WIDTH = 5
      DEFAULT_TILE_BUTTON_HEIGHT = 100
      HEADER_HEIGHT = 50
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
          width: (Coordinates::ERROR_DIALOGUE_WIDTH -
            (Coordinates::ERROR_DIALOGUE_BORDER_WIDTH * 2)) * 0.95
        )

        error_dialogue_data[:font] = wrapped_text_data[:font]
        compacted_lines = wrapped_text_data[:lines].compact
        initial_offset = fonts[:default][:offset] *
          ((wrapped_text_data[:lines].size - compacted_lines.size) / 2.0)
        error_dialogue_data[:lines] = compacted_lines.map.with_index do |line, index|
          {
            text: line,
            y: initial_offset + Coordinates::ERROR_DIALOGUE_TOP_Y +
              Coordinates::ERROR_DIALOGUE_BORDER_WIDTH + (fonts[:default][:offset] * index)
          }
        end

        # Make the error dialogue stay up for more time the longer the error message
        self.error_ticks = ticks_for_seconds(
          MINIMUM_ERROR_DIALOGUE_SECONDS + (0.03 * compacted_lines.sum(&:length))
        ).round
      end

      def display_tile(tile)
        if map_menu.drawing?
          map_menu.current_tile = tile
          map_menu.update
        else
          self.focused_tile = tile
          tile_menu.update
          card_menu.close if card_menu.drawing?
        end

        close_pop_up_menus
      end


      def draw
        self.draw_mouse_x = mouse_x
        self.draw_mouse_y = mouse_y

        unless map_menu.drawing?
          # Background
          Gosu.draw_rect(
            color: colors[:main_background],
            height: Coordinates::BOTTOM_Y - Coordinates::TOP_Y,
            width: Coordinates::RIGHT_X - Coordinates::LEFT_X,
            x: Coordinates::LEFT_X,
            y: Coordinates::TOP_Y,
            z: ZOrder::MAIN_BACKGROUND
          )

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
          draw_game_menu
          draw_player_menu
          card_menu.draw
          tile_menu.draw
          action_menu.draw
        end

        # Pop up background blur
        if drawing_pop_up_menu? && !dialogue_box_menu.drawing?
          Gosu.draw_rect(
            color: colors[:blur],
            height: Coordinates::BOTTOM_Y - Coordinates::TOP_Y,
            width: Coordinates::RIGHT_X - Coordinates::LEFT_X,
            x: Coordinates::LEFT_X,
            y: Coordinates::TOP_Y,
            z: ZOrder::POP_UP_BLUR
          )
        end

        deed_menu.draw
        draw_event_history_menu
        group_menu.draw
        map_menu.draw
        draw_player_inspector
        player_list_menu.draw

        draw_clock
        options_menu.draw
        dialogue_box_menu.draw
        draw_error_dialogue

        # Mouse coordinates
        fonts[:default][:type].draw_text(
          "#{mouse_x.round(3)}, #{mouse_y.round(3)}",
          color: colors[:default_text],
          rel_x: 1,
          rel_y: 0,
          x: Coordinates::RIGHT_X * 0.8,
          y: Coordinates::TOP_Y,
          z: ZOrder::POP_UP_MENU_UI
        )
      end

      def draw_clock
        clock_data[:font].draw_text("Turn #{turn} | #{time_elapsed}", **clock_data[:text_params])
      end

      def draw_compass_menu
        return unless drawing_compass_menu?

        compass_menu_data[:outer_circle].draw(
          **compass_menu_data[:left_circle_params]
        )
        compass_menu_data[:outer_circle].draw(
          **compass_menu_data[:right_circle_params]
        )
        compass_menu_data[:inner_circle].draw(
          **compass_menu_data[:left_circle_params]
        )
        compass_menu_data[:inner_circle].draw(
          **compass_menu_data[:right_circle_params]
        )
        Gosu.draw_rect(**compass_menu_data[:tile_background])

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_pop_up_menu? ||
          dialogue_box_menu.drawing?
        visible_compass_menu_buttons.each { |button| button.draw(*coordinates) }

        Gosu.draw_rect(**compass_menu_data[:bottom_border])
        Gosu.draw_triangle(**compass_menu_data[:point])
        Gosu.draw_rect(**compass_menu_data[:top_border])
      end

      def draw_error_dialogue
        return unless drawing_error_dialogue?

        error_dialogue_data[:rectangles].each { |data| Gosu.draw_rect(**data) }
        error_dialogue_data[:exclamation_point][:image].draw(
          **error_dialogue_data[:exclamation_point][:params]
        )

        error_dialogue_data[:lines].each do |line|
          error_dialogue_data[:font].draw_text(
            line[:text],
            y: line[:y],
            **error_dialogue_data[:text]
          )
        end

        coordinates = [draw_mouse_x, draw_mouse_y] unless dialogue_box_menu.drawing?
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

        coordinates = [draw_mouse_x, draw_mouse_y] unless dialogue_box_menu.drawing?
        visible_event_history_menu_buttons.each { |button| button.draw(*coordinates) }
      end

      def draw_game_menu
        return unless drawing_game_menu?

        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_pop_up_menu? ||
          dialogue_box_menu.drawing?
        game_menu_buttons.values.each { |button| button.draw(*coordinates) }
      end

      def draw_player_inspector
        return unless drawing_player_inspector?

        coordinates = [draw_mouse_x, draw_mouse_y] unless dialogue_box_menu.drawing?

        player_inspector_data[:rectangles].each do |data|
          Gosu.draw_rect(**data.except(:stats)) unless !data[:stats] && player_inspector_show_stats
        end

        visible_player_inspector_buttons.each { |button| button.draw(*coordinates) }
      end

      def draw_player_menu
        coordinates = [draw_mouse_x, draw_mouse_y] unless drawing_pop_up_menu? ||
          dialogue_box_menu.drawing?

        Gosu.draw_rect(**player_menu_data[:right_border_params])
        Gosu.draw_rect(**player_menu_data[:background_params])
        player_menu_data[:rounded_corner_circle].draw(
          **player_menu_data[:rounded_corner_circle_params]
        )
        Gosu.draw_rect(**player_menu_data[:top_border_params])
        (0...player_menu_data[:jail_bar_count])
          .each { |number| Gosu.draw_rect(**player_menu_data[:jail_bars][number]) }

        visible_player_menu_buttons.each { |button| button.draw(*coordinates) }
      end

      def set_visible_compass_menu_buttons
        self.visible_compass_menu_buttons = []

        ratio = Coordinates::TILE_HEIGHT / DEFAULT_TILE_BUTTON_HEIGHT.to_f
        button = compass_menu_buttons[0]
        button.image = current_tile.tile_image.clone
        button.hover_image = current_tile.tile_image.clone
        width = tile_width(current_tile) / ratio
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
          width = tile_width(tile) / ratio
          button.width = button.image_width = button.hover_image_width = width
          button.update_coordinates(x: Coordinates::CENTER_X + right_offset)
          right_offset += width
          visible_compass_menu_buttons << button

          break unless tile_count >= index * 2 + 1

          tile = tiles[(current_tile_index - index) % tile_count]
          button = compass_menu_buttons[-index]
          button.image = tile.tile_image.clone
          button.hover_image = tile.tile_image.clone
          width = tile_width(tile) / ratio
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

      def set_visible_player_inspector_buttons(refresh: false)
        self.visible_player_inspector_buttons = []
        visible_player_inspector_buttons << player_inspector_buttons[:close]

        if player_inspector_show_stats
          update_current_player_time_played

          player_inspector_buttons[:stats][0...-1].each do |data|
            visible_player_inspector_buttons << data[:name]
            data[:value].text = data[:function].call(inspected_player)
            visible_player_inspector_buttons << data[:value]
          end

          if inspected_player.eliminated?
            data = player_inspector_buttons[:stats].last
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

      def tile_width(tile)
        tile.corner? ? Coordinates::TILE_HEIGHT : Coordinates::TILE_WIDTH
      end
    end
  end
end
