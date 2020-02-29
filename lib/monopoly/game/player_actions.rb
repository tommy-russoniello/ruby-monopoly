module Monopoly
  class Game < Gosu::Window
    module PlayerActions
      def back_to_current_tile
        self.focused_tile = current_tile
        toggle_card_menu if drawing_card_menu?
        set_visible_tile_menu_buttons
      end

      def build_house(tile = focused_tile)
        if !tile.is_a?(StreetTile) || tile.owner != current_player
          add_message('Invalid tile to build house on.')
        end

        if !tile.group.monopolized?
          add_message(
            "#{current_player.name} must have a monopoly on the #{tile.group.singular_name} " \
            "color group before building a house on #{tile.name}."
          )
          return
        elsif current_player.money < tile.group.house_cost
          add_message(
            "#{current_player.name} does not have enough money to build a house on #{tile.name}."
          )
          return
        elsif tile.house_count >= max_house_count
          add_message("#{tile.name} cannot have anymore houses built on it.")
          return
        elsif tile.mortgaged?
          add_message(
            "Houses cannot be built on #{tile.name} as it is currently mortgaged."
          )
          return
        end

        related_tiles_with_less_houses = tile.group.tiles.select do |related_tile|
          related_tile.house_count < tile.house_count
        end

        unless related_tiles_with_less_houses.empty?
          if related_tiles_with_less_houses.size == 1
            add_message("Must build a house on #{related_tiles_with_less_houses.first.name} first.")
          else
            last_tile = related_tiles_with_less_houses.pop
            add_message(
              "Must build a house on #{related_tiles_with_less_houses.map(&:name).join(', ')} " \
              "and #{last_tile.name} first."
            )
          end

          return
        end

        house_cost = tile.group.house_cost
        current_player.money -= house_cost
        tile.house_count += 1

        set_visible_tile_menu_buttons
        set_visible_player_menu_buttons
        set_visible_group_menu_buttons if drawing_group_menu?

        add_message(
          "#{current_player.name} built a house on #{tile.name} for " \
          "#{format_money(house_cost)}."
        )
      end

      def buy
        unless current_player.money >= current_tile.purchase_price
          add_message(
            "#{current_player.name} does not have enough money to purchase this property."
          )
          return
        end

        current_player.money -= current_tile.purchase_price
        current_tile.owner = current_player
        current_player.properties += [current_tile]
        current_player.properties.sort_by! { |tile| tile_indexes[tile] }

        add_message(
          "#{current_player.name} bought #{current_tile.name} for " \
          "#{format_money(current_tile.purchase_price)}."
        )

        set_visible_tile_menu_buttons
        set_visible_player_menu_buttons
        update_visible_buttons(:end_turn)
      end

      def draw_card
        self.current_card = cards[current_tile.card_type].shift
        current_card.player = current_player
        card_menu_buttons[:continue].text = current_card.continue_button_text
        toggle_card_menu
        update_visible_buttons
      end

      def end_turn
        increment_current_player
        if current_player.number <= previous_player_number
          self.turn += 1
          add_message("Turn #{turn}...")
        end

        self.previous_player_number = current_player.number

        if current_player.in_jail?
          current_player.jail_turns -= 1
          new_visible_buttons = %i[end_turn]
          if current_player.in_jail?
            add_message(
              "#{current_player.name} has #{current_player.jail_turns} turn" \
              "#{'s' if current_player.jail_turns > 1} left in jail."
            )
            new_visible_buttons << :use_get_out_of_jail_free_card if
              current_player.cards.any? { |card| card.is_a?(GetOutOfJailFreeCard) }
          else
            add_message("#{current_player.name} is out of jail.")
          end

          set_visible_tile_menu_buttons
          set_visible_player_menu_buttons
          update_visible_buttons(*new_visible_buttons)
        else
          update_visible_buttons(:roll_dice_for_move)
        end
      end

      def exit_game
        close!
      end

      def forfeit
        toggle_deed_menu if drawing_deed_menu?
        toggle_group_menu if drawing_group_menu?
        toggle_options_menu if drawing_options_menu?
        return_new_card if current_card
        eliminate_player(current_player)
        end_turn
      end

      def go_to_jail
        send_player_to_jail(current_player)
        self.current_tile = self.focused_tile = tiles[:jail]
        new_visible_buttons = %i[end_turn]
        new_visible_buttons << :use_get_out_of_jail_free_card if
          current_player.cards.any? { |card| card.is_a?(GetOutOfJailFreeCard) }
        set_visible_tile_menu_buttons
        set_visible_player_menu_buttons
        update_visible_buttons(*new_visible_buttons)
      end

      def mortgage(tile = focused_tile)
        if !tile.is_a?(PropertyTile) || tile.owner != current_player
          add_message('Invalid tile to mortgage.')
        end

        if tile.is_a?(StreetTile)
          if tile.is_a?(StreetTile) && tile.house_count.positive?
            add_message("The houses on #{tile.name} must be sold before it can be mortgaged.")
            return
          end
        end

        tile.mortgaged = true
        current_player.money += tile.mortgage_cost
        add_message(
          "#{current_player.name} mortgaged #{tile.name} for #{format_money(tile.mortgage_cost)}."
        )

        set_visible_tile_menu_buttons
        set_visible_player_menu_buttons
        set_visible_group_menu_buttons if drawing_group_menu?
      end

      def pay_rent
        charge_money(
          amount: current_tile.rent,
          on_bankrupt: :end_turn,
          on_success: [:update_visible_buttons, :end_turn],
          recipient: current_tile.owner
        )
        self.temporary_rent_multiplier = nil

        set_visible_player_menu_buttons
      end

      def pay_tax
        charge_money(
          amount: current_tile.tax_amount,
          on_bankrupt: :end_turn,
          on_success: [:update_visible_buttons, :end_turn],
          player: current_player
        )

        set_visible_player_menu_buttons
      end

      def roll_dice
        self.die_a = roll_die
        self.die_b = roll_die
        add_message("#{current_player.name} has rolled #{die_a + die_b} (#{die_a}, #{die_b}).")
      end

      def save_game
        # TODO
      end

      def sell_house(tile = focused_tile)
        if !tile.is_a?(StreetTile) || tile.owner != current_player
          add_message('Invalid tile to sell house from.')
        end

        if tile.house_count < 1
          add_message("#{tile.name} has no houses on it to sell.")
          return
        end

        related_tiles_with_more_houses = tile.group.tiles.select do |related_tile|
          related_tile.house_count > tile.house_count
        end

        unless related_tiles_with_more_houses.empty?
          if related_tiles_with_more_houses.size == 1
            add_message(
              "Must sell a house from #{related_tiles_with_more_houses.first.name} first."
            )
          else
            last_tile = related_tiles_with_more_houses.pop
            add_message(
              "Must sell a house from #{related_tiles_with_more_houses.map(&:name).join(', ')} " \
              "and #{last_tile.name} first."
            )
          end

          return
        end

        house_sell_price = (tile.group.house_cost * building_sell_percentage).to_i
        current_player.money += house_sell_price
        tile.house_count -= 1

        set_visible_tile_menu_buttons
        set_visible_player_menu_buttons
        set_visible_group_menu_buttons if drawing_group_menu?

        add_message(
          "#{current_player.name} sold a house from #{tile.name} for " \
          "#{format_money(house_sell_price)}."
        )
      end

      def toggle_card_menu
        set_visible_card_menu_buttons unless drawing_card_menu?

        self.drawing_card_menu = !drawing_card_menu
      end

      def toggle_deed_menu
        if drawing_deed_menu?
          self.deed_rent_line_index = 1
        else
          set_visible_deed_menu_buttons
        end

        self.drawing_deed_menu = !drawing_deed_menu
      end

      def toggle_dialogue_box(actions: nil, button_text: nil)
        if drawing_dialogue_box?
          toggle_options_menu if drawing_options_menu?
        else
          dialogue_box_buttons[:action].actions = actions
          dialogue_box_buttons[:action].actions =
            [[:toggle_dialogue_box]] + dialogue_box_buttons[:action].actions
          dialogue_box_buttons[:action].text = button_text
        end

        self.drawing_dialogue_box = !drawing_dialogue_box
      end

      def toggle_group_menu(tiles = nil)
        if drawing_group_menu?
          self.group_menu_tiles.items = []
        else
          self.group_menu_tiles.items = (tiles || focused_tile.group.tiles)
          set_visible_group_menu_buttons
        end

        self.drawing_group_menu = !drawing_group_menu
      end

      def toggle_options_menu
        options_button = buttons[:options]
        if drawing_options_menu?
          options_button.color = nil
          options_button.hover_color = nil

          options_button.perform_image_animation(:spin, length: ticks_for_seconds(0.25),
            times: 0.25)
        else
          bottom_of_options_menu_button_y = options_button.y + options_button.height
          bottom_of_last_option_button_y =
            options_menu_buttons.values.last.y + options_menu_buttons.values.last.height

          self.options_menu_bar_paramaters = {
            color: colors[:options_menu_background],
            height: bottom_of_last_option_button_y - bottom_of_options_menu_button_y,
            width:
              options_button.x - options_menu_buttons.values.first.x + options_button.width + 1,
            x: options_menu_buttons.values.first.x,
            y: options_menu_buttons.values.first.y - 1,
            z: ZOrder::POP_UP_MENU_UI
          }
          options_button.color = colors[:options_menu_background]
          options_button.hover_color = colors[:options_menu_background]

          options_button.perform_image_animation(:spin, counterclockwise: true,
            length: ticks_for_seconds(0.25), times: 0.25)
        end

        self.drawing_options_menu = !drawing_options_menu
      end

      def unmortgage(tile = focused_tile)
        if !tile.is_a?(PropertyTile) || tile.owner != current_player
          add_message('Invalid tile to unmortgage.')
        end

        unless current_player.money >= tile.unmortgage_cost
          add_message(
            "#{current_player.name} does not have enough money to unmortgage this property."
          )
          return
        end

        current_player.money -= tile.unmortgage_cost
        tile.mortgaged = false
        add_message(
          "#{current_player.name} payed #{format_money(tile.unmortgage_cost)} to " \
          "unmortgage #{tile.name}."
        )

        set_visible_group_menu_buttons if drawing_group_menu?
        set_visible_tile_menu_buttons
        set_visible_player_menu_buttons
      end

      def use_get_out_of_jail_free_card
        card = current_player.cards.find { |card| card.is_a?(GetOutOfJailFreeCard) }
        return unless card

        card.perform_action
        card.player = nil
        current_player.cards -= [card]
        cards[card.type] << card

        set_visible_player_menu_buttons

        update_visible_buttons(:end_turn)
      end

      def use_new_card
        if current_card.keepable?
          current_player.cards << current_card
          self.current_card = nil
          toggle_card_menu
          set_visible_player_menu_buttons
          update_visible_buttons(:end_turn)
        else
          current_card.triggered = true
          current_card.perform_action
        end
      end
    end
  end
end
