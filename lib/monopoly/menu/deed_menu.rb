module Monopoly
  class DeedMenu < Menu
    DEED_HEIGHT = (Coordinates::DEED_MENU_HEIGHT - (Coordinates::DEED_MENU_BORDER_WIDTH * 2)) * 0.9
    DEED_WIDTH = (Coordinates::DEED_MENU_WIDTH - (Coordinates::DEED_MENU_BORDER_WIDTH * 2)) * 0.6
    MAX_DEED_ICON_HEIGHT = DEED_HEIGHT * 0.27
    MAX_DEED_ICON_WIDTH = DEED_HEIGHT * 0.5
    MAX_DEED_NAME_LINES = 3

    attr_accessor :deed_data
    attr_accessor :deed_rent_line_index

    def initialize(*)
      super

      self.buttons = {
        close: Button.new(
          actions: proc { close },
          color: nil,
          game: game,
          height: 40,
          hover_color: nil,
          hover_image: Image.new(game.images[:x_hover]),
          image: Image.new(game.images[:x]),
          image_height: 40,
          width: 40,
          x: Coordinates::DEED_MENU_LEFT_X + Coordinates::DEED_MENU_BORDER_WIDTH + 5,
          y: Coordinates::DEED_MENU_TOP_Y + Coordinates::DEED_MENU_BORDER_WIDTH + 5,
          z: ZOrder::POP_UP_MENU_UI
        ),
        down: Button.new(
          actions: [
            proc do
              self.deed_rent_line_index += 1
              update if drawing?
            end
          ],
          color: nil,
          game: game,
          height: game.fonts[:deed][:offset],
          hover_color: nil,
          hover_image: Image.new(game.images[:arrow_down_hover]),
          image: Image.new(game.images[:arrow_down]),
          image_height: game.fonts[:deed][:offset],
          width: DEED_WIDTH * 0.75,
          x: Coordinates::CENTER_X - DEED_WIDTH * 0.4,
          y: Coordinates::CENTER_Y - (DEED_HEIGHT * 0.125) + (game.fonts[:deed][:offset] * 5),
          z: ZOrder::POP_UP_MENU_UI
        ),
        up: Button.new(
          actions: [
            proc do
              self.deed_rent_line_index -= 1
              update if drawing?
            end
          ],
          color: nil,
          game: game,
          height: game.fonts[:deed][:offset],
          hover_color: nil,
          hover_image: Image.new(game.images[:arrow_up_hover]),
          image: Image.new(game.images[:arrow_up]),
          image_height: game.fonts[:deed][:offset],
          width: DEED_WIDTH * 0.75,
          x: Coordinates::CENTER_X - DEED_WIDTH * 0.4,
          y: Coordinates::CENTER_Y - (DEED_HEIGHT * 0.125) + (game.fonts[:deed][:offset] * 2),
          z: ZOrder::POP_UP_MENU_UI
        )
      }

      self.rectangles = {
        border: {
          color: game.colors[:pop_up_menu_border],
          height: Coordinates::DEED_MENU_HEIGHT,
          width: Coordinates::DEED_MENU_WIDTH,
          x: Coordinates::DEED_MENU_LEFT_X,
          y: Coordinates::DEED_MENU_TOP_Y,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        },
        background: {
          color: game.colors[:pop_up_menu_background],
          height: Coordinates::DEED_MENU_HEIGHT - (Coordinates::DEED_MENU_BORDER_WIDTH * 2),
          width: Coordinates::DEED_MENU_WIDTH - (Coordinates::DEED_MENU_BORDER_WIDTH * 2),
          x: Coordinates::DEED_MENU_LEFT_X + Coordinates::DEED_MENU_BORDER_WIDTH,
          y: Coordinates::DEED_MENU_TOP_Y + Coordinates::DEED_MENU_BORDER_WIDTH,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        },
        deed_outer_border: {
          color: game.colors[:deed],
          from_center: true,
          height: DEED_HEIGHT,
          width: DEED_WIDTH,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        },
        deed_inner_border: {
          color: game.colors[:deed_accent],
          from_center: true,
          height: DEED_HEIGHT * 0.92,
          width: DEED_WIDTH * 0.92,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        },
        deed_background: {
          color: game.colors[:deed],
          from_center: true,
          height: DEED_HEIGHT * 0.9,
          width: DEED_WIDTH * 0.9,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y,
          z: ZOrder::POP_UP_MENU_BACKGROUND
        }
      }

      self.deed_data = {}
      self.deed_rent_line_index = 1
    end

    def close
      self.deed_rent_line_index = 1

      super
    end

    def draw
      return unless drawing?

      super

      tile = game.map_menu.current_tile || game.focused_tile
      if tile.deed_image
        tile.deed_image.draw(
          draw_height: DEED_HEIGHT,
          draw_width: DEED_WIDTH,
          from_center: true,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y,
          z: ZOrder::POP_UP_MENU_UI
        )
      else
        if tile.is_a?(StreetTile)
          draw_street_tile_deed
        elsif tile.is_a?(RailroadTile)
          draw_railroad_tile_deed(tile)
        else
          draw_utility_tile_deed(tile)
        end
      end
    end

    def open
      game.close_pop_up_menus
      update

      super
    end

    def update
      self.visible_buttons = []
      self.deed_data = {}
      visible_buttons << buttons[:close]

      tile = game.map_menu.current_tile || game.focused_tile
      wrapped_text_data = Gosu::Font.wrap_text(
        max_lines: MAX_DEED_NAME_LINES,
        max_size: game.fonts[:deed][:type].height,
        min_size: game.class::MINIMUM_FONT_SIZE,
        name: game.fonts[:deed][:type].name,
        text: tile.name.upcase,
        width: DEED_WIDTH * 0.75
      )
      game.fonts[:deed_name][:type] = wrapped_text_data[:font]
      deed_data[:name] = wrapped_text_data[:lines]

      if tile.is_a?(StreetTile)
        set_street_tile_deed_data(tile)
      elsif tile.is_a?(RailroadTile)
        set_railroad_tile_deed_data(tile)
      else
        set_utility_tile_deed_data(tile)
      end

      super
    end

    private

    def draw_railroad_tile_deed(tile)
      (tile.icon || tile.group.image).draw(**deed_data[:image_params])

      font = game.fonts[:deed][:type]
      deed_data[:name_lines_params].each do |params|
        game.fonts[:deed_name][:type].draw_text(params[:text], **params[:options])
      end

      if deed_data[:rent_params]
        font.draw_text(deed_data[:rent_params][:left][:text], **deed_data[:rent_params][:left][:options])
        font.draw_text(deed_data[:rent_params][:right][:text], **deed_data[:rent_params][:right][:options])
      end

      deed_data[:rent_with_railroads_params]&.each do |data|
        font.draw_text(data[:left][:text], **data[:left][:options])
        font.draw_text(data[:right][:text], **data[:right][:options])
      end

      Gosu.draw_rect(**deed_data[:divider_params])

      font.draw_text(deed_data[:mortgage_value_params][:left][:text], **deed_data[:mortgage_value_params][:left][:options])
      font.draw_text(deed_data[:mortgage_value_params][:right][:text], **deed_data[:mortgage_value_params][:right][:options])

      font.draw_text(deed_data[:unmortgage_cost_params][:left][:text], **deed_data[:unmortgage_cost_params][:left][:options])
      font.draw_text(deed_data[:unmortgage_cost_params][:right][:text], **deed_data[:unmortgage_cost_params][:right][:options])
    end

    def draw_street_tile_deed
      Gosu.draw_rect(**deed_data[:color_box_border_params])
      Gosu.draw_rect(**deed_data[:color_box_params])
      font = game.fonts[:deed][:type]
      font.draw_text(deed_data[:title_deed_text_params][:text], **deed_data[:title_deed_text_params][:options])

      deed_data[:name_lines_params].each do |params|
        game.fonts[:deed_name][:type].draw_text(params[:text], **params[:options])
      end

      font.draw_text(deed_data[:rent_line_params][:left][:text], **deed_data[:rent_line_params][:left][:options])
      font.draw_text(deed_data[:rent_line_params][:right][:text], **deed_data[:rent_line_params][:right][:options])

      font.draw_text(deed_data[:rent_with_color_group_line_params][:left][:text], **deed_data[:rent_with_color_group_line_params][:left][:options])
      font.draw_text(deed_data[:rent_with_color_group_line_params][:right][:text], **deed_data[:rent_with_color_group_line_params][:right][:options])

      deed_data[:rent_with_houses_lines_params]&.each do |data|
        font.draw_text(data[:left][:text], **data[:left][:options])
        font.draw_text(data[:right][:text], **data[:right][:options])
      end

      Gosu.draw_rect(**deed_data[:divider_params])

      font.draw_text(deed_data[:house_cost_params][:left][:text], **deed_data[:house_cost_params][:left][:options])
      font.draw_text(deed_data[:house_cost_params][:right][:text], **deed_data[:house_cost_params][:right][:options])

      font.draw_text(deed_data[:house_sell_price_params][:left][:text], **deed_data[:house_sell_price_params][:left][:options])
      font.draw_text(deed_data[:house_sell_price_params][:right][:text], **deed_data[:house_sell_price_params][:right][:options])

      font.draw_text(deed_data[:mortgage_value_params][:left][:text], **deed_data[:mortgage_value_params][:left][:options])
      font.draw_text(deed_data[:mortgage_value_params][:right][:text], **deed_data[:mortgage_value_params][:right][:options])

      font.draw_text(deed_data[:unmortgage_cost_params][:left][:text], **deed_data[:unmortgage_cost_params][:left][:options])
      font.draw_text(deed_data[:unmortgage_cost_params][:right][:text], **deed_data[:unmortgage_cost_params][:right][:options])
    end

    def draw_utility_tile_deed(tile)
      (tile.icon || tile.group.image).draw(deed_data[:image_params])
      deed_data[:name_lines_params].each do |params|
        game.fonts[:deed_name][:type].draw_text(params[:text], **params[:options])
      end

      deed_data[:rent_lines_params].each do |params|
        deed_data[:rent_font].draw_text(params[:text], **params[:options])
      end

      if deed_data[:rent_line_params]
        deed_data[:rent_font].draw_text(deed_data[:rent_line_params][:left][:text], **deed_data[:rent_line_params][:left][:options])
        deed_data[:rent_font].draw_text(deed_data[:rent_line_params][:right][:text], **deed_data[:rent_line_params][:right][:options])
      end

      Gosu.draw_rect(**deed_data[:divider_params])

      font = game.fonts[:deed][:type]
      font.draw_text(deed_data[:mortgage_value_params][:left][:text], **deed_data[:mortgage_value_params][:left][:options])
      font.draw_text(deed_data[:mortgage_value_params][:right][:text], **deed_data[:mortgage_value_params][:right][:options])

      font.draw_text(deed_data[:unmortgage_cost_params][:left][:text], **deed_data[:unmortgage_cost_params][:left][:options])
      font.draw_text(deed_data[:unmortgage_cost_params][:right][:text], **deed_data[:unmortgage_cost_params][:right][:options])
    end

    def set_railroad_tile_deed_data(tile)
      image = (tile.icon || tile.group.image).clone
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
        y: Coordinates::CENTER_Y - (DEED_HEIGHT * 0.28),
        z: ZOrder::POP_UP_MENU_UI
      }

      initial_offset =
        ((deed_data[:name].size - deed_data[:name].compact.size) / 2.0) * game.fonts[:deed][:offset]
      deed_data[:name_lines_params] = deed_data[:name].map.with_index do |text, index|
        {
          text: text,
          options: {
            color: game.colors[:deed_accent],
            rel_x: 0.5,
            rel_y: 0.5,
            x: Coordinates::CENTER_X,
            y: Coordinates::CENTER_Y - (DEED_HEIGHT * 0.17) + initial_offset +
              (game.fonts[:deed][:offset] * (index + 1)),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        }
      end

      left_x = Coordinates::CENTER_X - (DEED_WIDTH * 0.4)
      right_x = Coordinates::CENTER_X + (DEED_WIDTH * 0.4)
      y = Coordinates::CENTER_Y + DEED_HEIGHT * 0.025
      y_offset = game.fonts[:deed][:offset]

      owner = tile.owner

      if tile.group.tiles.size < 7
        text_color =
          if owner && tile.group.amount_owned(owner) == 1
            game.colors[:deed_highlight]
          else
            game.colors[:deed_accent]
          end

        deed_data[:rent_params] = {
          left: {
            text: 'Rent',
            options: {
              color: text_color,
              rel_y: 0.5,
              x: left_x,
              y: y,
              z: ZOrder::POP_UP_MENU_BACKGROUND
            }
          },
          right: {
            text: game.format_money(tile.rent_with_railroads(1)),
            options: {
              color: text_color,
              rel_x: 1,
              rel_y: 0.5,
              x: right_x,
              y: y,
              z: ZOrder::POP_UP_MENU_BACKGROUND
            }
          }
        }

        deed_data[:rent_with_railroads_params] =
          (2..tile.group.tiles.size).map do |railroad_count|
            text_color =
              if owner && tile.group.amount_owned(owner) == railroad_count
                game.colors[:deed_highlight]
              else
                game.colors[:deed_accent]
              end

            {
              left: {
                text: "Rent with #{railroad_count} #{tile.group.plural_name}",
                options: {
                  color: text_color,
                  rel_y: 0.5,
                  x: left_x,
                  y: y + (y_offset * (railroad_count - 1)),
                  z: ZOrder::POP_UP_MENU_BACKGROUND
                }
              },
              right: {
                text: game.format_money(tile.rent_with_railroads(railroad_count)),
                options: {
                  color: text_color,
                  rel_x: 1,
                  rel_y: 0.5,
                  x: right_x,
                  y: y + (y_offset * (railroad_count - 1)),
                  z: ZOrder::POP_UP_MENU_BACKGROUND
                }
              }
            }
          end
      else
        railroad_count = deed_rent_line_index

        visible_buttons << buttons[:up] if railroad_count > 1
        visible_buttons << buttons[:down] if railroad_count < tile.group.tiles.size

        text_color =
          if owner && tile.group.amount_owned(owner) == railroad_count
            game.colors[:deed_highlight]
          else
            game.colors[:deed_accent]
          end

        group_name = tile.group.send("#{railroad_count == 1 ? 'singular' : 'plural'}_name")

        deed_data[:rent_with_railroads_params] = [
          {
            left: {
              text: "Rent with #{railroad_count} #{group_name}",
              options: {
                color: text_color,
                rel_y: 0.5,
                x: left_x,
                y: y + y_offset,
                z: ZOrder::POP_UP_MENU_BACKGROUND
              }
            },
            right: {
              text: game.format_money(tile.rent_with_railroads(railroad_count)),
              options: {
                color: text_color,
                rel_x: 1,
                rel_y: 0.5,
                x: right_x,
                y: y + y_offset,
                z: ZOrder::POP_UP_MENU_BACKGROUND
              }
            }
          }
        ]
      end

      deed_data[:divider_params] = {
        color: game.colors[:deed_accent],
        from_center: true,
        height: DEED_HEIGHT * 0.005,
        width: DEED_WIDTH * 0.78,
        x: Coordinates::CENTER_X,
        y: y + (y_offset * 6),
        z: ZOrder::POP_UP_MENU_BACKGROUND
      }

      deed_data[:mortgage_value_params] = {
        left: {
          text: 'Mortgage value',
          options: {
            color: game.colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 7),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        },
        right: {
          text: game.format_money(tile.mortgage_cost),
          options: {
            color: game.colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 7),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        }
      }

      deed_data[:unmortgage_cost_params] = {
        left: {
          text: 'Unmortgage cost',
          options: {
            color: game.colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 8),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        },
        right: {
          text: game.format_money(tile.unmortgage_cost),
          options: {
            color: game.colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 8),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        }
      }
    end

    def set_street_tile_deed_data(tile)
      deed_data[:color_box_border_params] = {
        color: game.colors[:deed_accent],
        from_center: true,
        height: DEED_HEIGHT * 0.25,
        width: DEED_WIDTH * 0.82,
        x: Coordinates::CENTER_X,
        y: Coordinates::CENTER_Y - (DEED_HEIGHT * 0.3),
        z: ZOrder::POP_UP_MENU_BACKGROUND
      }
      deed_data[:color_box_params] = {
        color: tile.group.color,
        from_center: true,
        height: DEED_HEIGHT * 0.23,
        width: DEED_WIDTH * 0.8,
        x: Coordinates::CENTER_X,
        y: Coordinates::CENTER_Y - (DEED_HEIGHT * 0.3),
        z: ZOrder::POP_UP_MENU_BACKGROUND
      }
      deed_data[:title_deed_text_params] = {
        text: 'TITLE DEED',
        options: {
          color: game.colors[:deed_accent],
          rel_x: 0.5,
          rel_y: 0.5,
          scale_x: 0.5,
          scale_y: 0.5,
          x: Coordinates::CENTER_X,
          y: Coordinates::CENTER_Y - (DEED_HEIGHT * 0.38),
          z: ZOrder::POP_UP_MENU_BACKGROUND
        }
      }

      initial_offset =
        ((deed_data[:name].size - deed_data[:name].compact.size) / 2.0) * game.fonts[:deed][:offset]
      deed_data[:name_lines_params] = deed_data[:name].map.with_index do |text, index|
        {
          text: text,
          options: {
            color: game.colors[:deed_accent],
            rel_x: 0.5,
            rel_y: 0.5,
            x: Coordinates::CENTER_X,
            y: Coordinates::CENTER_Y - (DEED_HEIGHT * 0.38) + initial_offset +
              (game.fonts[:deed][:offset] * (index + 1)),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        }
      end

      left_x = Coordinates::CENTER_X - (DEED_WIDTH * 0.4)
      right_x = Coordinates::CENTER_X + (DEED_WIDTH * 0.4)
      y = Coordinates::CENTER_Y - (DEED_HEIGHT * 0.125)
      y_offset = game.fonts[:deed][:offset]

      text_color =
        if tile.owner && !tile.group.monopolized?
          game.colors[:deed_highlight]
        else
          game.colors[:deed_accent]
        end

      deed_data[:rent_line_params] = {
        left: {
          text: 'Rent',
          options: {
            color: text_color,
            rel_y: 0.5,
            x: left_x,
            y: y,
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        },
        right: {
          text: game.format_money(tile.rent_with_houses(0)),
          options: {
            color: text_color,
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y,
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        }
      }

      text_color =
        if tile.group.monopolized? && tile.house_count.zero?
          game.colors[:deed_highlight]
        else
          game.colors[:deed_accent]
        end

      deed_data[:rent_with_color_group_line_params] = {
        left: {
          text: 'Rent with color group',
          options: {
            color: text_color,
            rel_y: 0.5,
            x: left_x,
            y: y + y_offset,
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        },
        right: {
          text: game.format_money(tile.base_rent_with_color_group),
          options: {
            color: text_color,
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + y_offset,
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        }
      }

      deed_data[:rent_with_houses_lines_params] =
        if game.max_house_count <= game.class::DEFAULT_MAX_HOUSE_COUNT
          (1..game.max_house_count).map do |house_count|
            text_color =
              if house_count == tile.house_count
                game.colors[:deed_highlight]
              else
                game.colors[:deed_accent]
              end

            {
              left: {
                text: "Rent with #{house_count} house#{'s' if house_count > 1}",
                options: {
                  color: text_color,
                  rel_y: 0.5,
                  x: left_x,
                  y: y + (y_offset * (house_count + 1)),
                  z: ZOrder::POP_UP_MENU_BACKGROUND
                }
              },
              right: {
                text: game.format_money(tile.rent_with_houses(house_count)),
                options: {
                  color: text_color,
                  rel_x: 1,
                  rel_y: 0.5,
                  x: right_x,
                  y: y + (y_offset * (house_count + 1)),
                  z: ZOrder::POP_UP_MENU_BACKGROUND
                }
              }
            }
          end
        else
          house_count = deed_rent_line_index

          visible_buttons << buttons[:up] if house_count > 1
          visible_buttons << buttons[:down] if house_count < game.max_house_count

          text_color =
            if house_count == tile.house_count
              game.colors[:deed_highlight]
            else
              game.colors[:deed_accent]
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
                game.format_money(tile.rent_with_houses(house_count)),
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
        color: game.colors[:deed_accent],
        from_center: true,
        height: DEED_HEIGHT * 0.005,
        width: DEED_WIDTH * 0.78,
        x: Coordinates::CENTER_X,
        y: y + (y_offset * 7),
        z: ZOrder::POP_UP_MENU_BACKGROUND
      }

      deed_data[:house_cost_params] = {
        left: {
          text: 'Houses cost',
          options: {
            color: game.colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 8),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        },
        right: {
          text: "#{game.format_money(tile.group.house_cost)} each",
          options: {
            color: game.colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 8),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        }
      }

      deed_data[:house_sell_price_params] = {
        left: {
          text: 'Houses sell for',
          options: {
            color: game.colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 9),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        },
        right: {
          text: "#{game.format_money(tile.group.house_cost * game.building_sell_percentage)} each",
          options: {
            color: game.colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 9),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        }
      }

      deed_data[:mortgage_value_params] = {
        left: {
          text: 'Mortgage value',
          options: {
            color: game.colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 10),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        },
        right: {
          text: game.format_money(tile.mortgage_cost),
          options: {
            color: game.colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 10),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        }
      }

      deed_data[:unmortgage_cost_params] = {
        left: {
          text: 'Unmortgage cost',
          options: {
            color: game.colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 11),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        },
        right: {
          text: game.format_money(tile.unmortgage_cost),
          options: {
            color: game.colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 11),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        }
      }
    end

    def set_utility_tile_deed_data(tile)
      image = (tile.icon || tile.group.image).clone
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
        y: Coordinates::CENTER_Y - (DEED_HEIGHT * 0.27),
        z: ZOrder::POP_UP_MENU_UI
      }

      initial_offset =
        ((deed_data[:name].size - deed_data[:name].compact.size) / 2.0) * game.fonts[:deed][:offset]
      deed_data[:name_lines_params] = deed_data[:name].map.with_index do |text, index|
        {
          text: text,
          options: {
            color: game.colors[:deed_accent],
            rel_x: 0.5,
            rel_y: 0.5,
            x: Coordinates::CENTER_X,
            y: Coordinates::CENTER_Y - (DEED_HEIGHT * 0.15) + initial_offset +
              (game.fonts[:deed][:offset] * (index + 1)),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        }
      end

      left_x = Coordinates::CENTER_X - (DEED_WIDTH * 0.4)
      right_x = Coordinates::CENTER_X + (DEED_WIDTH * 0.4)
      y = Coordinates::CENTER_Y + DEED_HEIGHT * 0.025
      y_offset = game.fonts[:deed][:offset]

      owner = tile.owner
      max_paragraph_lines = 3
      if tile.group.tiles.size == 2
        font = game.fonts[:deed][:type]
        text_color =
          if owner && tile.group.amount_owned(owner) == 1
            game.colors[:deed_highlight]
          else
            game.colors[:deed_accent]
          end

        wrapped_text_data = Gosu::Font.wrap_text(
          max_lines: max_paragraph_lines,
          max_size: font.height,
          min_size: game.class::MINIMUM_FONT_SIZE,
          name: font.name,
          text: "If one #{tile.group.singular_name} is owned, rent is " \
            "#{tile.rent_multiplier_scale.first} times amount shown on dice.",
          width: DEED_WIDTH * 0.75
        )
        deed_data[:rent_font] = wrapped_text_data[:font]
        first_paragraph_offset = wrapped_text_data[:lines].count
        deed_data[:rent_lines_params] = wrapped_text_data[:lines].map.with_index do |text, index|
          {
            text: text,
            options: {
              color: text_color,
              rel_x: 0.5,
              rel_y: 0.5,
              x: Coordinates::CENTER_X,
              y: Coordinates::CENTER_Y + (game.fonts[:deed][:offset] * (index + 0.75)),
              z: ZOrder::POP_UP_MENU_BACKGROUND
            }
          }
        end

        text_color =
          if owner && tile.group.amount_owned(owner) == 2
            game.colors[:deed_highlight]
          else
            game.colors[:deed_accent]
          end

        wrapped_text_data = Gosu::Font.wrap_text(
          max_lines: max_paragraph_lines,
          max_size: font.height,
          min_size: game.class::MINIMUM_FONT_SIZE,
          name: font.name,
          text: "If both #{tile.group.plural_name} are owned, rent is " \
            "#{tile.rent_multiplier_scale.last} times amount shown on dice.",
          width: DEED_WIDTH * 0.75
        )
        deed_data[:rent_font] = [wrapped_text_data[:font], deed_data[:rent_font]].min_by(&:height)
        deed_data[:rent_lines_params] += wrapped_text_data[:lines].map.with_index do |text, index|
          {
            text: text,
            options: {
              color: text_color,
              rel_x: 0.5,
              rel_y: 0.5,
              x: Coordinates::CENTER_X,
              y: Coordinates::CENTER_Y +
                (game.fonts[:deed][:offset] * (index + 1 + first_paragraph_offset)),
              z: ZOrder::POP_UP_MENU_BACKGROUND
            }
          }
        end
      else
        utility_count = deed_rent_line_index

        visible_buttons << buttons[:up] if utility_count > 1
        visible_buttons << buttons[:down] if utility_count < tile.group.tiles.size

        text_color =
          if owner && tile.group.amount_owned(owner) == utility_count
            game.colors[:deed_highlight]
          else
            game.colors[:deed_accent]
          end

        group_name = tile.group.send("#{utility_count == 1 ? 'singular' : 'plural'}_name")
        y = Coordinates::CENTER_Y + DEED_HEIGHT * 0.025
        y_offset = game.fonts[:deed][:offset]

        deed_data[:rent_line_params] = {
          left: {
            text: "Multiplier with #{utility_count} #{group_name}",
            options: {
              color: text_color,
              rel_y: 0.5,
              x: left_x,
              y: y + y_offset,
              z: ZOrder::POP_UP_MENU_BACKGROUND
            }
          },
          right: {
            text: game.format_number(tile.rent_multiplier_scale[utility_count - 1]),
            options: {
              color: text_color,
              rel_x: 1,
              rel_y: 0.5,
              x: right_x,
              y: y + y_offset,
              z: ZOrder::POP_UP_MENU_BACKGROUND
            }
          }
        }
        deed_data[:rent_font] = game.fonts[:deed][:type]

        wrapped_text_data = Gosu::Font.wrap_text(
          max_lines: max_paragraph_lines,
          max_size: game.fonts[:deed][:type].height,
          min_size: game.class::MINIMUM_FONT_SIZE,
          name: game.fonts[:deed][:type].name,
          text: "Rent is the amount shown on dice times the multiplier.",
          width: DEED_WIDTH * 0.75
        )
        deed_data[:rent_font] = [wrapped_text_data[:font], deed_data[:rent_font]].min_by(&:height)
        deed_data[:rent_lines_params] = wrapped_text_data[:lines].map.with_index do |text, index|
          {
            text: text,
            options: {
              color: text_color,
              rel_x: 0.5,
              rel_y: 0.5,
              x: Coordinates::CENTER_X,
              y: y + (y_offset * (3.5 + index)),
              z: ZOrder::POP_UP_MENU_BACKGROUND
            }
          }
        end
      end

      deed_data[:divider_params] = {
        color: game.colors[:deed_accent],
        from_center: true,
        height: DEED_HEIGHT * 0.005,
        width: DEED_WIDTH * 0.78,
        x: Coordinates::CENTER_X,
        y: y + (y_offset * 6.25),
        z: ZOrder::POP_UP_MENU_BACKGROUND
      }

      deed_data[:mortgage_value_params] = {
        left: {
          text: 'Mortgage value',
          options: {
            color: game.colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 7),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        },
        right: {
          text: game.format_money(tile.mortgage_cost),
          options: {
            color: game.colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 7),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        }
      }

      deed_data[:unmortgage_cost_params] = {
        left: {
          text: 'Unmortgage cost',
          options: {
            color: game.colors[:deed_accent],
            rel_y: 0.5,
            x: left_x,
            y: y + (y_offset * 8),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        },
        right: {
          text: game.format_money(tile.unmortgage_cost),
          options: {
            color: game.colors[:deed_accent],
            rel_x: 1,
            rel_y: 0.5,
            x: right_x,
            y: y + (y_offset * 8),
            z: ZOrder::POP_UP_MENU_BACKGROUND
          }
        }
      }
    end
  end
end
