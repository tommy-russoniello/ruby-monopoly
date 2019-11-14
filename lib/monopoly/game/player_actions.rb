module Monopoly
  class Game < Gosu::Window
    module PlayerActions
      def build_house
        if !current_tile.group.monopolized?
          add_message(
            "#{current_player.name} must have a monopoly on the #{current_tile.group.name} " \
            "color group before building a house on #{current_tile.name}."
          )
          return
        elsif current_player.money < current_tile.group.house_cost
          add_message(
            "#{current_player.name} does not have enough money to build a house on " \
            "#{current_tile.name}."
          )
          return
        elsif current_tile.house_count > 4
          add_message("#{current_tile.name} cannot have anymore houses built on it.")
          return
        elsif current_tile.mortgaged?
          add_message(
            "Houses cannot be built on #{current_tile.name} as it is currently mortgaged."
          )
          return
        end

        related_tiles_with_less_houses = current_tile.group.tiles.select do |tile|
          tile.house_count < current_tile.house_count
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

        house_cost = current_tile.group.house_cost
        current_player.money -= house_cost
        current_tile.house_count += 1

        add_message(
          "#{current_player.name} built a house on #{current_tile.name} for " \
          "$#{format_number(house_cost)}."
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

        current_player.update_property_button_coordinates(
          Coordinates::LEFT_X,
          Coordinates::TOP_Y + fonts[:title][:offset],
          Button::DEFAULT_HEIGHT + 1
        )

        add_message(
          "#{current_player.name} bought #{current_tile.name} for " \
          "$#{format_number(current_tile.purchase_price)}."
        )

        update_visible_buttons(:end_turn)
      end

      def draw_card
        self.current_card = cards[current_tile.card_type].shift
        current_card.player = current_player
        buttons[:card_continue].text = current_card.continue_button_text
        update_visible_buttons(:card_continue)
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

          update_visible_buttons(*new_visible_buttons)
        else
          update_visible_buttons(:roll_dice_for_move)
        end
      end

      def exit_game
        close!
      end

      def forfeit
        exit_inspector if draw_inspector?
        toggle_options_menu if draw_options_menu?
        eliminate_player(current_player)
        end_turn
      end

      def go_to_jail
        send_player_to_jail(current_player)
        self.current_tile = tiles[:jail]
        new_visible_buttons = %i[end_turn]
        new_visible_buttons << :use_get_out_of_jail_free_card if
          current_player.cards.any? { |card| card.is_a?(GetOutOfJailFreeCard) }
        update_visible_buttons(*new_visible_buttons)
      end

      def mortgage
        new_visible_buttons = %i[exit_inspector unmortgage]
        if current_tile.is_a?(StreetTile)
          if current_tile.is_a?(StreetTile) && current_tile.house_count.positive?
            add_message(
              "The houses on #{current_tile.name} must be sold before it can be mortgaged."
            )
            return
          end

          new_visible_buttons += %i[build_house sell_house]
        end

        current_tile.mortgaged = true
        current_player.money += current_tile.mortgage_cost
        add_message(
          "#{current_player.name} mortgaged #{current_tile.name} for " \
          "$#{format_number(current_tile.mortgage_cost)}."
        )

        update_visible_buttons(*new_visible_buttons)
      end

      def pay_rent
        charge_money(
          amount: current_tile.rent,
          on_bankrupt: :end_turn,
          on_success: [:update_visible_buttons, :end_turn],
          recipient: current_tile.owner
        )
        self.temporary_rent_multiplier = nil
      end

      def pay_tax
        charge_money(
          amount: current_tile.tax_amount,
          on_bankrupt: :end_turn,
          on_success: [:update_visible_buttons, :end_turn],
          player: current_player
        )
      end

      def roll_dice
        self.die_a = roll_die
        self.die_b = roll_die
        add_message("#{current_player.name} has rolled #{die_a + die_b} (#{die_a}, #{die_b}).")
      end

      def save_game
        # TODO
      end

      def sell_house
        if current_tile.house_count < 1
          add_message("#{current_tile.name} has no houses on it to sell.")
          return
        end

        related_tiles_with_more_houses = current_tile.group.tiles.select do |tile|
          tile.house_count > current_tile.house_count
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

        house_sell_price = (current_tile.group.house_cost * BUILDING_SELL_PERCENTAGE).to_i
        current_player.money += house_sell_price
        current_tile.house_count -= 1

        add_message(
          "#{current_player.name} sold a house from #{current_tile.name} for " \
          "$#{format_number(house_sell_price)}."
        )
      end

      def toggle_dialogue_box(actions: nil, button_text: nil)
        if draw_dialogue_box?
          toggle_options_menu if draw_options_menu?
        else
          dialogue_box_buttons[:action].actions = actions
          dialogue_box_buttons[:action].actions =
            [[:toggle_dialogue_box]] + dialogue_box_buttons[:action].actions
          dialogue_box_buttons[:action].text = button_text
        end

        self.draw_dialogue_box = !draw_dialogue_box
      end

      def toggle_options_menu
        if draw_options_menu?
          buttons[:options].color = nil
          buttons[:options].hover_color = nil
        else
          bottom_of_options_menu_button_y = buttons[:options].y + buttons[:options].height
          bottom_of_last_option_button_y =
            options_menu_buttons.values.last.y + options_menu_buttons.values.last.height

          self.options_menu_bar_paramaters = {
            color: colors[:inspector_background],
            height: bottom_of_last_option_button_y - bottom_of_options_menu_button_y,
            width: buttons[:options].x - options_menu_buttons.values.first.x +
              buttons[:options].width + 1,
            x: options_menu_buttons.values.first.x,
            y: options_menu_buttons.values.first.y - 1,
            z: ZOrder::MENU_BACKGROUND
          }
          buttons[:options].color = colors[:inspector_background]
          buttons[:options].hover_color = colors[:inspector_background]
        end

        self.draw_options_menu = !draw_options_menu
      end

      def unmortgage
        unless current_player.money >= current_tile.unmortgage_cost
          add_message(
            "#{current_player.name} does not have enough money to unmortgage this property."
          )
          return
        end

        current_player.money -= current_tile.unmortgage_cost
        current_tile.mortgaged = false
        add_message(
          "#{current_player.name} payed $#{format_number(current_tile.unmortgage_cost)} to " \
          "unmortgage #{current_tile.name}."
        )
        new_visible_buttons = %i[exit_inspector mortgage]
        new_visible_buttons += %i[build_house sell_house] if current_tile.is_a?(StreetTile)
        update_visible_buttons(*new_visible_buttons)
      end

      def use_get_out_of_jail_free_card
        card = current_player.cards.find { |card| card.is_a?(GetOutOfJailFreeCard) }
        return unless card

        card.perform_action
        card.player = nil
        current_player.cards -= [card]
        cards[card.type] << card

        update_visible_buttons(:end_turn)
      end

      def use_new_card
        if current_card.keepable?
          current_player.cards << current_card
          self.current_card = nil
          update_visible_buttons(:end_turn)
        else
          current_card.perform_action
        end
      end
    end
  end
end
