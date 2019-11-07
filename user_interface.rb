module UserInterface
  DEFAULT_FONT_SIZE = 30

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
    # Images
    if current_card && !draw_inspector?
      current_card.image.draw(
        Coordinates::CENTER_X,
        Coordinates::CENTER_Y,
        ZOrder::MENU_UI,
        1,
        1,
        from_center: true,
        draw_height: 245,
        draw_width: 420
      )
    elsif current_tile.is_a?(PropertyTile)
      details = [
        "Position: #{tile_indexes[current_tile] + 1} / #{tile_count}"
      ]

      current_tile.tile_image.draw(
        Coordinates::CENTER_X - 150,
        Coordinates::CENTER_Y,
        ZOrder::MENU_UI,
        1,
        1,
        from_center: true,
        draw_height: 474,
        draw_width: 288
      )

      current_tile.deed_image.draw(
        Coordinates::CENTER_X + 150,
        Coordinates::CENTER_Y,
        ZOrder::MENU_UI,
        1,
        1,
        from_center: true,
        draw_height: 474,
        draw_width: 288
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
        Coordinates::CENTER_X,
        Coordinates::CENTER_Y,
        ZOrder::MENU_UI,
        1,
        1,
        from_center: true,
        draw_height: 474,
        draw_width: width
      )
    end

    # Player list
    y_differential = 0
    players.each do |player|
      fonts[:default][:type].draw_text_rel(
        "#{player.name}: #{player.tile.name}",
        Coordinates::CENTER_X,
        Coordinates::TOP_Y + y_differential,
        ZOrder::MAIN_UI,
        0.5,
        0,
        1,
        1,
        colors[:default_text]
      )
      y_differential += fonts[:default][:offset]
    end

    # Current player details
    fonts[:title][:type].draw_text(
      "#{current_player.name}: $#{format_number(current_player.money)}",
      Coordinates::LEFT_X,
      Coordinates::TOP_Y,
      ZOrder::MAIN_UI,
      1,
      1,
      colors[:default_text]
    )

    # Mouse coordinates
    fonts[:default][:type].draw_text_rel(
      "#{mouse_x.round(3)}, #{mouse_y.round(3)}",
      Coordinates::RIGHT_X,
      Coordinates::TOP_Y,
      ZOrder::MAIN_UI,
      1,
      0,
      1,
      1,
      colors[:default_text]
    )

    # Messages
    y_differential = 0
    self.messages = messages[0..4]
    messages.each do |message|
      fonts[:default][:type].draw_text_rel(
        message,
        Coordinates::LEFT_X,
        Coordinates::BOTTOM_Y - y_differential,
        ZOrder::MAIN_UI,
        0,
        1,
        1,
        1,
        colors[:default_text]
      )

      y_differential += fonts[:default][:offset]
    end

    # Primary buttons
    visible_buttons.each { |button| button.draw(mouse_x, mouse_y) }

    # Property buttons
    current_player.properties.each { |property| property.button.draw(mouse_x, mouse_y) }

    # Inspector
    if draw_inspector?
      Gosu.draw_rect(
        Coordinates::INSPECTOR_LEFT_X,
        Coordinates::INSPECTOR_TOP_Y,
        Coordinates::INSPECTOR_RIGHT_X - Coordinates::INSPECTOR_LEFT_X,
        Coordinates::INSPECTOR_BOTTOM_Y - Coordinates::INSPECTOR_TOP_Y,
        colors[:inspector_background],
        ZOrder::MENU_BACKGROUND
      )
      current_details_text_color = colors[:inspector_text]
    end

    # Current tile details
    y_differential = 250
    details&.each do |detail|
      fonts[:default][:type].draw_text_rel(
        detail,
        Coordinates::CENTER_X,
        Coordinates::CENTER_Y + y_differential,
        ZOrder::MENU_UI,
        0.5,
        0,
        1,
        1,
        current_details_text_color || colors[:default_text]
      )
      y_differential += fonts[:default][:offset]
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

  def update_visible_buttons(*button_names)
    self.visible_buttons = button_names.map { |button_name| buttons[button_name] }
  end
end
