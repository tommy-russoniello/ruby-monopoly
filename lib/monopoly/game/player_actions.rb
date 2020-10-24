module Monopoly
  class Game < Gosu::Window
    module PlayerActions
      def back_to_current_tile
        self.focused_tile = current_tile
        toggle_card_menu if drawing_card_menu?
        tile_menu.update
      end

      def build_house(tile = focused_tile)
        return display_error('Invalid tile to build house on.') if !tile.is_a?(StreetTile) ||
          tile.owner != current_player

        if !tile.group.monopolized?
          display_error(
            "You must have a monopoly on the #{tile.group.singular_name} " \
            "color group before building a house on #{tile.name}."
          )
          return
        elsif current_player.money < tile.group.house_cost
          return display_error("You don't have enough money to build a house on #{tile.name}.")
        elsif tile.house_count >= max_house_count
          return display_error("You can't build anymore houses on #{tile.name}.")
        elsif tile.mortgaged?
          display_error("You can't build houses on #{tile.name} because it is currently mortgaged.")
          return
        end

        related_tiles_with_less_houses = tile.group.tiles.select do |related_tile|
          related_tile.house_count < tile.house_count
        end

        unless related_tiles_with_less_houses.empty?
          if related_tiles_with_less_houses.size == 1
            display_error(
              "You must build a house on #{related_tiles_with_less_houses.first.name} first."
            )
          else
            last_tile = related_tiles_with_less_houses.pop
            display_error(
              'You must build a house on ' \
              "#{related_tiles_with_less_houses.map(&:name).join(', ')} and " \
              "#{last_tile.name} first."
            )
          end

          return
        end

        house_cost = tile.group.house_cost
        current_player.subtract_money(house_cost, :buildings)
        tile.house_count += 1

        set_visible_group_menu_buttons if drawing_group_menu?
        if map_menu.drawing?
          map_menu.update
        else
          tile_menu.update
          set_visible_player_menu_buttons
        end

        log_event(
          "#{current_player.name} built a house on #{tile.name} for " \
          "#{format_money(house_cost)}."
        )
      end

      def buy
        return display_error('You don\'t have enough money to purchase this property.') unless
          current_player.money >= current_tile.purchase_price

        current_player.subtract_money(current_tile.purchase_price, :properties)
        current_tile.owner = current_player
        current_player.properties += [current_tile]
        current_player.properties.sort_by! { |tile| tile_indexes[tile] }

        log_event(
          "#{current_player.name} bought #{current_tile.name} for " \
          "#{format_money(current_tile.purchase_price)}."
        )

        tile_menu.update
        set_visible_player_menu_buttons
        set_next_action(:end_turn)
      end

      def close_error_dialogue
        self.error_ticks = nil
      end

      def draw_card
        self.current_card = cards[current_tile.card_type].shift
        current_card.player = current_player
        card_menu_buttons[:continue].text = current_card.continue_button_text
        toggle_card_menu
        set_next_action(nil)
      end

      def end_turn
        increment_current_player
        if current_player.number <= previous_player_number
          self.turn += 1
          log_event("Turn #{turn} began.")
        end

        self.previous_player_number = current_player.number

        if current_player.in_jail?
          current_player.stats[:turns_in_jail] += 1
          current_player.jail_turns -= 1
          log_event("#{current_player.name} got out of jail.") unless current_player.in_jail?

          tile_menu.update
          set_visible_player_menu_buttons
          set_next_action(:end_turn)
        else
          set_next_action(:roll_dice_for_move)
        end
      end

      def exit_game
        close!
      end

      def forfeit
        close_pop_up_menus
        map_menu.close if map_menu.drawing?
        options_menu.close if options_menu.drawing?
        return_new_card if current_card
        eliminate_player(current_player)
        end_turn
      end

      def go_to_jail
        send_player_to_jail(current_player)
        self.current_tile = self.focused_tile = tiles[:jail]
        set_visible_compass_menu_buttons
        tile_menu.update
        set_visible_player_menu_buttons
        set_next_action(:end_turn)
      end

      def mortgage(tile = focused_tile)
        return display_error('Invalid tile to mortgage.') if !tile.is_a?(PropertyTile) ||
          tile.owner != current_player || tile.mortgaged?

        if tile.is_a?(StreetTile)
          if tile.is_a?(StreetTile) && tile.house_count.positive?
            display_error("You must sell the houses on #{tile.name} before it can be mortgaged.")
            return
          end
        end

        tile.mortgaged = true
        current_player.add_money(tile.mortgage_cost, :mortgages)
        log_event(
          "#{current_player.name} mortgaged #{tile.name} for #{format_money(tile.mortgage_cost)}."
        )

        set_visible_group_menu_buttons if drawing_group_menu?
        if map_menu.drawing?
          map_menu.update
        else
          tile_menu.update
          set_visible_player_menu_buttons
        end
      end

      def pay_rent
        charge_money(
          amount: current_tile.rent,
          on_bankrupt: :end_turn,
          on_success: [:set_next_action, :end_turn],
          reason: :rent,
          recipient: current_tile.owner
        )
        self.temporary_rent_multiplier = nil

        set_visible_player_menu_buttons
      end

      def pay_tax
        charge_money(
          amount: current_tile.tax_amount,
          on_bankrupt: :end_turn,
          on_success: [:set_next_action, :end_turn],
          player: current_player,
          reason: :game
        )

        set_visible_player_menu_buttons
      end

      def roll_dice
        self.die_a = roll_die
        self.die_b = roll_die
        log_event("#{current_player.name} rolled #{die_a + die_b} (#{die_a}, #{die_b}).")
      end

      def save_game
        # TODO
      end

      def sell_house(tile = focused_tile)
        return display_error('Invalid tile to sell house from.') if !tile.is_a?(StreetTile) ||
          tile.owner != current_player

        return display_error("#{tile.name} has no houses on it to sell.") if tile.house_count < 1

        related_tiles_with_more_houses = tile.group.tiles.select do |related_tile|
          related_tile.house_count > tile.house_count
        end

        unless related_tiles_with_more_houses.empty?
          if related_tiles_with_more_houses.size == 1
            display_error(
              "You must sell a house from #{related_tiles_with_more_houses.first.name} first."
            )
          else
            last_tile = related_tiles_with_more_houses.pop
            display_error(
              'You must sell a house from ' \
              "#{related_tiles_with_more_houses.map(&:name).join(', ')} " \
              "and #{last_tile.name} first."
            )
          end

          return
        end

        house_sell_price = (tile.group.house_cost * building_sell_percentage).to_i
        current_player.add_money(house_sell_price, :buildings)
        tile.house_count -= 1

        set_visible_group_menu_buttons if drawing_group_menu?
        if map_menu.drawing?
          map_menu.update
        else
          tile_menu.update
          set_visible_player_menu_buttons
        end

        log_event(
          "#{current_player.name} sold a house from #{tile.name} for " \
          "#{format_money(house_sell_price)}."
        )
      end

      def toggle_card_menu
        set_visible_card_menu_buttons unless drawing_card_menu?

        self.drawing_card_menu = !drawing_card_menu

        action_menu.update
      end

      def toggle_deed_menu
        if drawing_deed_menu?
          self.deed_rent_line_index = 1
        else
          close_pop_up_menus
          set_visible_deed_menu_buttons
        end

        self.drawing_deed_menu = !drawing_deed_menu
      end

      def toggle_event_history_menu
        if drawing_event_history_menu?
          self.event_history_view = nil
        else
          self.event_history_view = ScrollingList.new(items: event_history, view_size: 10)
          set_visible_event_history_menu_buttons
        end

        self.drawing_event_history_menu = !drawing_event_history_menu
      end

      def toggle_group_menu(tiles = nil)
        if drawing_group_menu?
          self.group_menu_tiles.items = []
        else
          close_pop_up_menus
          self.group_menu_tiles.items = (tiles || focused_tile.group.tiles)
          set_visible_group_menu_buttons
        end

        self.drawing_group_menu = !drawing_group_menu
      end

      def toggle_player_inspector
        if drawing_player_inspector?
          self.inspected_player = nil
          self.player_inspector_show_stats = false
        else
          close_pop_up_menus
          set_visible_player_inspector_buttons(refresh: true)
        end

        self.drawing_player_inspector = !drawing_player_inspector
      end

      def unmortgage(tile = focused_tile)
        return display_error('Invalid tile to unmortgage.') if !tile.is_a?(PropertyTile) ||
          tile.owner != current_player || !tile.mortgaged?

        return display_error('You don\'t have enough money to unmortgage this property.') unless
          current_player.money >= tile.unmortgage_cost

        current_player.subtract_money(tile.unmortgage_cost, :mortgages)
        tile.mortgaged = false
        log_event(
          "#{current_player.name} payed #{format_money(tile.unmortgage_cost)} to " \
          "unmortgage #{tile.name}."
        )

        set_visible_group_menu_buttons if drawing_group_menu?
        if map_menu.drawing?
          map_menu.update
        else
          tile_menu.update
          set_visible_player_menu_buttons
        end
      end

      def use_get_out_of_jail_free_card
        return unless current_player.in_jail?

        card = current_player.cards.find { |card| card.is_a?(GetOutOfJailFreeCard) }
        return unless card

        card.perform_action
        card.player = nil
        current_player.cards -= [card]
        cards[card.type] << card

        set_visible_player_menu_buttons
      end

      def use_new_card
        if current_card.keepable?
          current_player.cards << current_card
          self.current_card = nil
          toggle_card_menu
          tile_menu.update
          set_visible_player_menu_buttons
          set_next_action(:end_turn)
        else
          current_card.triggered = true
          set_visible_card_menu_buttons
          current_card.perform_action
        end
      end
    end
  end
end
