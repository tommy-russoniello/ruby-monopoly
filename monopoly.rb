require 'gosu'
require 'byebug'
require 'active_support'
require 'active_support/core_ext/numeric/conversions'
require 'securerandom'

require_relative 'gosu/image'

require_relative 'button'
require_relative 'player'
require_relative 'tile'
require_relative 'tile_group'

module ZOrder
  MAIN_BACKGROUND, MAIN_UI, MENU_BACKGROUND, MENU_UI = *0..3
end

module Coordinates
  CENTER_X = 960
  CENTER_Y = 540
  TOP_Y = 0
  BOTTOM_Y = 1080
  RIGHT_X = 1920
  LEFT_X = 0
  INSPECTOR_LEFT_X = 480
  INSPECTOR_TOP_Y = 275
  INSPECTOR_RIGHT_X = 1440
  INSPECTOR_BOTTOM_Y = 965
end

class Monopoly < Gosu::Window
  def initialize
    @redraw = true

    super(1920, 1080, fullscreen: ARGV.include?('-f'))

    self.caption = 'Monopoly'

    @go_money_amount = 200
    @building_sell_percentage = 0.5

    @fonts = {
      default: { type: Gosu::Font.new(30), offset: 35 },
      title: { type: Gosu::Font.new(50), offset: 55 }
    }

    @colors = {
      default_button: Gosu::Color::WHITE,
      default_button_hover: Gosu::Color.new(255, 219, 219, 219),
      property_button_selected: Gosu::Color.new(255, 127, 158, 209),
      property_button_selected_hover: Gosu::Color.new(255, 105, 130, 170),
      default_text: Gosu::Color::YELLOW,
      inspector_text: Gosu::Color::BLACK,
      inspector_background: Gosu::Color.new(255, 192, 206, 193)
    }

    @color_groups = {
      brown: ColorGroup.new(
        color: Gosu::Color.new(255, 149, 84, 54),
        house_cost: 50,
        name: 'brown'
      ),
      light_blue: ColorGroup.new(
        color: Gosu::Color.new(255, 0, 114, 187),
        house_cost: 200,
        name: 'light blue'
      )
    }

    @railroads_group = TileGroup.new(name: 'Railroads')

    @tile_count = 0
    @tiles = {}
    @tile_indexes = {}
    [
      GoTile.new(
        name: 'Go',
        tile_image: Gosu::Image.new("images/tiles/go.jpg")
      ),
      StreetTile.new(
        group: @color_groups[:brown],
        deed_image: Gosu::Image.new("images/deeds/mediterranean_avenue.jpg"),
        name: 'Mediterranean Avenue',
        purchase_price: 60,
        rent_scale: [2, 10, 30, 90, 160, 250],
        tile_image: Gosu::Image.new("images/tiles/mediterranean_avenue.png")
      ),
      StreetTile.new(
        group: @color_groups[:brown],
        deed_image: Gosu::Image.new("images/deeds/baltic_avenue.jpg"),
        name: 'Baltic Avenue',
        purchase_price: 60,
        rent_scale: [4, 20, 60, 180, 320, 450],
        tile_image: Gosu::Image.new("images/tiles/baltic_avenue.png")
      ),
      RailroadTile.new(
        deed_image: Gosu::Image.new("images/deeds/reading_railroad.jpg"),
        group: @railroads_group,
        name: 'Reading Railroad',
        purchase_price: 200,
        rent_scale: [25, 50, 100, 200],
        tile_image: Gosu::Image.new("images/tiles/reading_railroad.png")
      ),
      RailroadTile.new(
        deed_image: Gosu::Image.new("images/deeds/pennsylvania_railroad.jpg"),
        group: @railroads_group,
        name: 'Pennsylvania Railroad',
        purchase_price: 200,
        rent_scale: [25, 50, 100, 200],
        tile_image: Gosu::Image.new("images/tiles/pennsylvania_railroad.png")
      ),
      FreeParkingTile.new(
        name: 'Free Parking',
        tile_image: Gosu::Image.new("images/tiles/free_parking.jpg")
      ),
      StreetTile.new(
        group: @color_groups[:light_blue],
        deed_image: Gosu::Image.new("images/deeds/park_place.jpg"),
        name: 'Park Place',
        purchase_price: 350,
        rent_scale: [35, 175, 500, 1100, 1300, 1500],
        tile_image: Gosu::Image.new("images/tiles/park_place.png")
      ),
      StreetTile.new(
        group: @color_groups[:light_blue],
        deed_image: Gosu::Image.new("images/deeds/boardwalk.jpg"),
        name: 'Boardwalk',
        purchase_price: 400,
        rent_scale: [50, 200, 600, 1400, 1700, 2000],
        tile_image: Gosu::Image.new("images/tiles/boardwalk.png")
      )
    ].each.with_index do |tile, index|
      @tile_count += 1
      @tiles[index] = tile
      @tiles[tile.name.downcase.tr(' ', '_').to_sym] = tile
      @tile_indexes[tile] = index

      if tile.is_a?(PropertyTile)
        tile.button = Button.new(
          window: self,
          width: Button::DEFAULT_WIDTH + (Button::DEFAULT_WIDTH / 3.to_f),
          font: @fonts[:default][:type],
          text: tile.name,
          actions: [:display_property, tile]
        )
      end
    end

    @players = [
      Player.new(name: 'Tom', money: 200, tile: @tiles[:go], window: self),
      Player.new(name: 'Jerry', money: 200, tile: @tiles[:go], window: self)
    ]
    @current_player_index = 0
    @current_player = @players.first

    @buttons = {
      buy: Button.new(
        window: self,
        x: Coordinates::RIGHT_X - Button::DEFAULT_WIDTH,
        y: Coordinates::BOTTOM_Y - (Button::DEFAULT_HEIGHT * 2 + 1),
        font: @fonts[:default][:type],
        text: 'Buy',
        actions: :buy
      ),
      end_turn: Button.new(
        window: self,
        x: Coordinates::RIGHT_X - Button::DEFAULT_WIDTH,
        y: Coordinates::BOTTOM_Y - Button::DEFAULT_HEIGHT,
        font: @fonts[:default][:type],
        text: 'End Turn',
        actions: :end_turn
      ),
      continue: Button.new(
        window: self,
        x: Coordinates::RIGHT_X - Button::DEFAULT_WIDTH,
        y: Coordinates::BOTTOM_Y - Button::DEFAULT_HEIGHT,
        font: @fonts[:default][:type],
        text: 'Continue',
        actions: :end_turn
      ),
      roll_dice: Button.new(
        window: self,
        x: Coordinates::RIGHT_X - Button::DEFAULT_WIDTH,
        y: Coordinates::BOTTOM_Y - Button::DEFAULT_HEIGHT,
        font: @fonts[:default][:type],
        text: 'Roll Dice',
        actions: :roll_dice
      ),
      pay_rent: Button.new(
        window: self,
        x: Coordinates::RIGHT_X - Button::DEFAULT_WIDTH,
        y: Coordinates::BOTTOM_Y - Button::DEFAULT_HEIGHT,
        font: @fonts[:default][:type],
        text: 'Pay Rent',
        actions: :pay_rent
      ),
      exit_inspector: Button.new(
        window: self,
        x: Coordinates::RIGHT_X - Button::DEFAULT_WIDTH,
        y: Coordinates::BOTTOM_Y - Button::DEFAULT_HEIGHT,
        font: @fonts[:default][:type],
        text: 'Back',
        actions: :exit_inspector
      ),
      mortgage: Button.new(
        window: self,
        x: Coordinates::INSPECTOR_RIGHT_X - (Button::DEFAULT_WIDTH + 3),
        y: Coordinates::INSPECTOR_BOTTOM_Y - (Button::DEFAULT_HEIGHT + 3),
        z: ZOrder::MENU_UI,
        font: @fonts[:default][:type],
        text: 'Mortgage',
        actions: :mortgage
      ),
      unmortgage: Button.new(
        window: self,
        x: Coordinates::INSPECTOR_RIGHT_X - (Button::DEFAULT_WIDTH + 3),
        y: Coordinates::INSPECTOR_BOTTOM_Y - (Button::DEFAULT_HEIGHT + 3),
        z: ZOrder::MENU_UI,
        font: @fonts[:default][:type],
        text: 'Unmortgage',
        actions: :unmortgage
      ),
      build_house: Button.new(
        window: self,
        x: Coordinates::INSPECTOR_RIGHT_X - (Button::DEFAULT_WIDTH + 3),
        y: Coordinates::INSPECTOR_BOTTOM_Y - (Button::DEFAULT_HEIGHT * 3 + 5),
        z: ZOrder::MENU_UI,
        font: @fonts[:default][:type],
        text: 'Build House',
        actions: :build_house
      ),
      sell_house: Button.new(
        window: self,
        x: Coordinates::INSPECTOR_RIGHT_X - (Button::DEFAULT_WIDTH + 3),
        y: Coordinates::INSPECTOR_BOTTOM_Y - (Button::DEFAULT_HEIGHT * 2 + 4),
        z: ZOrder::MENU_UI,
        font: @fonts[:default][:type],
        text: 'Sell House',
        actions: :sell_house
      )
    }

    @visible_buttons = [@buttons[:roll_dice]]

    @current_tile = @tiles[0]

    @messages = []

    @turn = 1
  end

  def buy
    unless @current_player.money >= @current_tile.purchase_price
      add_message("#{@current_player.name} does not have enough money to purchase this property.")
      return
    end

    @current_player.money -= @current_tile.purchase_price
    @current_tile.owner = @current_player
    @current_player.properties += [@current_tile]

    @current_player.update_property_button_coordinates(
      Coordinates::LEFT_X,
      Coordinates::TOP_Y + @fonts[:title][:offset],
      Button::DEFAULT_HEIGHT + 1
    )

    add_message(
      "#{@current_player.name} bought #{@current_tile.name} for " \
      "$#{format_number(@current_tile.purchase_price)}."
    )

    update_visible_buttons(:end_turn)
  end

  def update_visible_buttons(*button_names)
    @visible_buttons = button_names.map { |button_name| @buttons[button_name] }
  end

  def cache_visible_buttons
    @visible_button_cache = @visible_buttons
  end

  def pop_visible_buttons_cache
    @visible_buttons = @visible_button_cache
    @visible_button_cache = nil
  end

  def end_turn
    @turn += 1
    @messages = []
    increment_current_player
    update_visible_buttons(:roll_dice)
  end

  def add_message(message)
    @messages = [message] + @messages
  end

  def draw
    tile_details = [
      "Position: #{@tile_indexes[@current_tile] + 1} / #{@tile_count}"
    ]

    # Current tile images
    if @current_tile.is_a?(PropertyTile)
      @current_tile.tile_image.draw(
        Coordinates::CENTER_X - 150,
        Coordinates::CENTER_Y,
        ZOrder::MENU_UI,
        1,
        1,
        from_center: true,
        draw_height: 474,
        draw_width: 288
      )

      @current_tile.deed_image.draw(
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
        if @current_tile.owner
          temp_message = "Owned By #{@current_tile.owner.name}"
          temp_message << " (#{@current_tile.group.amount_owned(@current_tile.owner)})" if
            @current_tile.group

          temp_message
        else
          'Unowned'
        end

      tile_details += [owner_message, @current_tile.mortgaged? ? 'Mortgaged' : 'Not Mortgaged']
      tile_details += ["#{@current_tile.house_count} Houses"] if @current_tile.is_a?(StreetTile)
    else
      @current_tile.tile_image.draw(
        Coordinates::CENTER_X,
        Coordinates::CENTER_Y,
        ZOrder::MENU_UI,
        1,
        1,
        from_center: true,
        draw_height: 474,
        draw_width: 474
      )
    end

    # Player list
    y_differential = 0
    @players.each do |player|
      @fonts[:default][:type].draw_text_rel(
        "#{player.name}: #{player.tile.name}",
        Coordinates::CENTER_X,
        Coordinates::TOP_Y + y_differential,
        ZOrder::MAIN_UI,
        0.5,
        0,
        1,
        1,
        @colors[:default_text]
      )
      y_differential += @fonts[:default][:offset]
    end

    # Current player details
    @fonts[:title][:type].draw_text(
      "#{@current_player.name}: $#{format_number(@current_player.money)}",
      Coordinates::LEFT_X,
      Coordinates::TOP_Y,
      ZOrder::MAIN_UI,
      1,
      1,
      @colors[:default_text]
    )

    # Mouse coordinates
    @fonts[:default][:type].draw_text_rel(
      "#{mouse_x.round(3)}, #{mouse_y.round(3)}",
      Coordinates::RIGHT_X,
      Coordinates::TOP_Y,
      ZOrder::MAIN_UI,
      1,
      0,
      1,
      1,
      @colors[:default_text]
    )

    # Messages
    y_differential = 0
    @messages = @messages[0..4]
    @messages.each do |message|
      @fonts[:default][:type].draw_text_rel(
        message,
        Coordinates::LEFT_X,
        Coordinates::BOTTOM_Y - y_differential,
        ZOrder::MAIN_UI,
        0,
        1,
        1,
        1,
        @colors[:default_text]
      )

      y_differential += @fonts[:default][:offset]
    end

    # Primary buttons
    @visible_buttons.each { |button| button.draw(mouse_x, mouse_y) }

    # Property buttons
    @current_player.properties.each { |property| property.button.draw(mouse_x, mouse_y) }

    # Inspector
    if @draw_inspector
      Gosu.draw_rect(
        Coordinates::INSPECTOR_LEFT_X,
        Coordinates::INSPECTOR_TOP_Y,
        Coordinates::INSPECTOR_RIGHT_X - Coordinates::INSPECTOR_LEFT_X,
        Coordinates::INSPECTOR_BOTTOM_Y - Coordinates::INSPECTOR_TOP_Y,
        @colors[:inspector_background],
        ZOrder::MENU_BACKGROUND
      )
      current_tile_details_text_color = @colors[:inspector_text]
    end

    # Current tile details
    y_differential = 250
    tile_details.each do |detail|
      @fonts[:default][:type].draw_text_rel(
        detail,
        Coordinates::CENTER_X,
        Coordinates::CENTER_Y + y_differential,
        ZOrder::MENU_UI,
        0.5,
        0,
        1,
        1,
        current_tile_details_text_color || @colors[:default_text]
      )
      y_differential += @fonts[:default][:offset]
    end
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    case id
    when Gosu::MS_LEFT
      handle_click(mouse_x, mouse_y)
    when Gosu::KB_ESCAPE
      close

    # FOR DEVELOPMENT: Print out current state of the instance to STDOUT
    when Gosu::KB_P
      print_state if ctrl_cmd_down?

    # FOR DEVELOPMENT: Automatically move exactly 1 tile forward
    when Gosu::KB_N
      if ctrl_cmd_down?
        exit_inspector if @draw_inspector
        move(1)
        land
      end

    # FOR DEVELOPMENT: Give current player $100
    when Gosu::KB_4
      @current_player.money += 100 if ctrl_cmd_down?
    else
      super
    end
  end

  def handle_click(x, y)
    property_buttons = @current_player.properties.map { |property| property.button }
    (@visible_buttons + property_buttons).each do |button|
      if button.within?(x, y)
        button.perform_actions
        break
      end
    end
  end

  def land
    case @current_tile
    when CardTile
    when FreeParkingTile
      add_message('whoopdie doo, free parking')
      update_visible_buttons(:end_turn)
    when GoTile
      update_visible_buttons(:end_turn)
    when GoToJailTile
    when JailTile
    when PropertyTile, RailroadTile
      if @current_tile.owner
        if @current_tile.owner == @current_player
          update_visible_buttons(:end_turn)
        elsif @current_tile.mortgaged?
          add_message(
            "No rent is due to #{@current_tile.owner.name} as " \
            "#{@current_tile.name} is currently mortgaged."
          )
          update_visible_buttons(:end_turn)
        else
          @buttons[:pay_rent].text = "Pay Rent ($#{format_number(@current_tile.rent)})"
          update_visible_buttons(:pay_rent)
        end
      else
        update_visible_buttons(:buy, :end_turn)
      end
    when TaxTile
    when UtilityTile
    else
      pp 'WARNING: INVALID TILE TYPE'
    end
  end

  def move(spaces)
    new_index = @tile_indexes[@current_tile] + spaces
    times_passed_go = new_index / @tile_count
    @current_tile = @tiles[new_index % @tile_count]
    @current_player.tile = @current_tile
    times_passed_go
  end

  def increment_current_player
    @current_player_index = (@current_player_index + 1) % @players.size
    @current_player = @players[@current_player_index]
    @current_tile = @current_player.tile
  end

  def roll_die
    SecureRandom.rand(6) + 1
  end

  def roll_dice
    @die_a = roll_die
    @die_b = roll_die
    add_message("#{@current_player.name} has rolled #{@die_a + @die_b} (#{@die_a}, #{@die_b})")
    times_passed_go = move(@die_a + @die_b)
    if times_passed_go > 0
      go_money_collected = @go_money_amount * times_passed_go
      extra_string = " #{times_passed_go} times" if times_passed_go > 1
      add_message(
        "#{@current_player.name} has gained $#{format_number(go_money_collected)} for " \
        "passing Go#{extra_string}."
      )
      @current_player.money += go_money_collected
    end

    land
  end

  def pay_rent
    rent = @current_tile.rent
    if @current_player.money < rent
      if @current_player.has_assets_for?(rent)
        add_message(
          "#{@current_player.name} cannot afford to pay this rent in cash but can afford it " \
          "by liquidating assets (selling houses and/or mortgaging properties)."
        )
      else
        add_message(
          "#{@current_player.name} does not have the cash or assets to pay this rent."
        )
        total_asset_liquidation_amount = @current_player.total_asset_liquidation_amount
        @current_tile.owner.money += total_asset_liquidation_amount
        @current_player.money = 0
        add_message(
          "#{@current_player.name} liquidated his remaining assets and payed " \
          "$#{format_number(total_asset_liquidation_amount)} to #{@current_tile.owner.name}."
        )
        eliminate_player
      end
    else
      @current_tile.owner.money += rent
      @current_player.money -= @current_tile.rent
      add_message(
        "#{@current_player.name} payed $#{format_number(rent)} in rent to " \
        "#{@current_tile.owner.name}."
      )
      update_visible_buttons(:end_turn)
    end
  end

  def eliminate_player
    add_message(
      "#{@current_player.name} is eliminated! All of #{@current_player.name}'s properties " \
      "have been reclaimed by the bank."
    )
    @current_player.properties.each do |property|
      property.owner = nil
      property.house_count = 0 if property.is_a?(StreetTile)
      property.mortgaged = false
    end

    @current_player.properties = []
    @players.delete(@current_player)
    @current_player_index =
      @current_player_index == 0 ? @players.size - 1 : @current_player_index - 1
    increment_current_player
    update_visible_buttons(:continue)
  end

  def display_property(property)
    if @draw_inspector
      if @current_tile == property
        exit_inspector
      else
        @current_tile.button.color = @property_button_color_cache
        @current_tile.button.hover_color = @property_button_hover_color_cache
        @property_button_color_cache = property.button.color
        @property_button_hover_color_cache = property.button.hover_color
        property.button.color = @colors[:property_button_selected]
        property.button.hover_color = @colors[:property_button_selected_hover]
        @current_tile = property

        new_visible_buttons = %i[exit_inspector]
        new_visible_buttons += %i[build_house sell_house] if @current_tile.is_a?(StreetTile)
        new_visible_buttons += @current_tile.mortgaged? ? %i[unmortgage] : %i[mortgage]
        update_visible_buttons(*new_visible_buttons)
      end
    else
      @draw_inspector = true
      @current_tile_cache = @current_tile
      @current_tile = property
      cache_visible_buttons

      new_visible_buttons = %i[exit_inspector]
      new_visible_buttons += %i[build_house sell_house] if @current_tile.is_a?(StreetTile)
      new_visible_buttons += @current_tile.mortgaged? ? %i[unmortgage] : %i[mortgage]
      update_visible_buttons(*new_visible_buttons)

      @property_button_color_cache = property.button.color
      @property_button_hover_color_cache = property.button.hover_color
      property.button.color = @colors[:property_button_selected]
      property.button.hover_color = @colors[:property_button_selected_hover]
    end
  end

  def exit_inspector
    @current_tile.button.color = @property_button_color_cache
    @current_tile.button.hover_color = @property_button_hover_color_cache
    @property_button_color_cache = nil
    @property_button_hover_color_cache = nil
    @draw_inspector = false
    @current_tile = @current_tile_cache
    @current_tile_cache = nil
    pop_visible_buttons_cache
  end

  def mortgage
    new_visible_buttons = %i[exit_inspector unmortgage]
    if @current_tile.is_a?(StreetTile)
      if @current_tile.is_a?(StreetTile) && @current_tile.house_count.positive?
        add_message("The houses on #{@current_tile.name} must be sold before it can be mortgaged.")
        return
      end

      new_visible_buttons += %i[build_house sell_house]
    end

    @current_tile.mortgaged = true
    @current_player.money += @current_tile.mortgage_cost
    add_message(
      "#{@current_player.name} mortgaged #{@current_tile.name} for " \
      "$#{format_number(@current_tile.mortgage_cost)}."
    )

    update_visible_buttons(*new_visible_buttons)
  end

  def unmortgage
    unless @current_player.money >= @current_tile.unmortgage_cost
      add_message("#{@current_player.name} does not have enough money to unmortgage this property.")
      return
    end

    @current_player.money -= @current_tile.unmortgage_cost
    @current_tile.mortgaged = false
    add_message(
      "#{@current_player.name} payed $#{format_number(@current_tile.unmortgage_cost)} to " \
      "unmortgage #{@current_tile.name}."
    )
    new_visible_buttons = %i[exit_inspector mortgage]
    new_visible_buttons += %i[build_house sell_house] if @current_tile.is_a?(StreetTile)
    update_visible_buttons(*new_visible_buttons)
  end

  def build_house
    if !@current_tile.group.monopolized?
      add_message(
        "#{@current_player.name} must have a monopoly on the #{@current_tile.group.name} " \
        "color group before building a house on #{@current_tile.name}."
      )
      return
    elsif @current_player.money < @current_tile.group.house_cost
      add_message(
        "#{@current_player.name} does not have enough money to build a house on " \
        "#{@current_tile.name}."
      )
      return
    elsif @current_tile.house_count > 4
      add_message("#{@current_tile.name} cannot have anymore houses built on it.")
      return
    elsif @current_tile.mortgaged?
      add_message("Houses cannot be built on #{@current_tile.name} as it is currently mortgaged.")
      return
    end

    related_tiles_with_less_houses = @current_tile.group.tiles.select do |tile|
      tile.house_count < @current_tile.house_count
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

    house_cost = @current_tile.group.house_cost
    @current_player.money -= house_cost
    @current_tile.house_count += 1

    add_message(
      "#{@current_player.name} built a house on #{@current_tile.name} for " \
      "$#{format_number(house_cost)}."
    )
  end

  def sell_house
    if @current_tile.house_count < 1
      add_message("#{@current_tile.name} has no houses on it to sell.")
      return
    end

    related_tiles_with_more_houses = @current_tile.group.tiles.select do |tile|
      tile.house_count > @current_tile.house_count
    end

    unless related_tiles_with_more_houses.empty?
      if related_tiles_with_more_houses.size == 1
        add_message("Must sell a house from #{related_tiles_with_more_houses.first.name} first.")
      else
        last_tile = related_tiles_with_more_houses.pop
        add_message(
          "Must sell a house from #{related_tiles_with_more_houses.map(&:name).join(', ')} " \
          "and #{last_tile.name} first."
        )
      end

      return
    end

    house_sell_price = (@current_tile.group.house_cost * @building_sell_percentage).to_i
    @current_player.money += house_sell_price
    @current_tile.house_count -= 1

    add_message(
      "#{@current_player.name} sold a house from #{@current_tile.name} for " \
      "$#{format_number(house_sell_price)}."
    )
  end

  def format_number(number)
    number.to_s(:delimited)
  end

  def ctrl_cmd_down?
    # If on Mac OS
    if RUBY_PLATFORM =~ /darwin/
      button_down?(Gosu::KB_RIGHT_META) || button_down?(Gosu::KB_LEFT_META)
    else
      button_down?(Gosu::KB_RIGHT_CONTROL) || button_down?(Gosu::KB_LEFT_CONTROL)
    end
  end

  def print_state
    puts('--------------------------')
    puts('PRINTING STATE')
    puts

    instance_variables.each do |instance_variable_name|
      puts("#{instance_variable_name.to_s[1..-1].tr('_', ' ').upcase}:")
      pp(instance_variable_get(instance_variable_name))
      puts
    end

    puts
    puts('--------------------------')
    puts
  end

  def inspect
    to_s
  end
end

monopoly = Monopoly.new.show
