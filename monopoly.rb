require 'gosu'
require 'byebug'
require 'active_support/inflector'
require 'securerandom'

require_relative 'gosu/image'

require_relative 'button'
require_relative 'player'
require_relative 'tile'

# Tile image size: 144x237

module ZOrder
  BACKGROUND, UI = *0..1
end

module Coordinates
  CENTER_X = 600
  CENTER_Y = 342.5
  TOP_Y = 0
  BOTTOM_Y = 685
  RIGHT_X = 1200
  LEFT_X = 0
end

class Monopoly < Gosu::Window
  def initialize
    @redraw = true

    super(1200, 685)

    self.caption = 'Monopoly'

    @go_money_amount = 200

    @font = Gosu::Font.new(20)

    @tile_count = 0
    @tiles = {}
    @tile_indexes = {}
    [
      GoTile.new(
        name: 'Go',
        tile_image: Gosu::Image.new("images/tiles/go.jpg")
      ),
      PropertyTile.new(
        deed_image: Gosu::Image.new("images/deeds/baltic_avenue.jpg"),
        name: 'Baltic Avenue',
        purchase_price: 60,
        rent_scale: [4, 20, 60, 180, 320, 450],
        tile_image: Gosu::Image.new("images/tiles/baltic_avenue.png")
      ),
      FreeParkingTile.new(
        name: 'Free Parking',
        tile_image: Gosu::Image.new("images/tiles/free_parking.jpg")
      ),
      PropertyTile.new(
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
    end

    @players = [
      Player.new(name: 'Tom', money: 200, tile: @tiles[:go]),
      Player.new(name: 'Jerry', money: 200, tile: @tiles[:go])
    ]
    @current_player_index = 0
    @current_player = @players.first

    @buttons = {
      buy: Button.new(
        window: self,
        x: Coordinates::RIGHT_X - 150,
        y: Coordinates::BOTTOM_Y - 70,
        height: 35,
        width: 150,
        font: Gosu::Font.new(20),
        text: 'Buy',
        action: :buy
      ),
      end_turn: Button.new(
        window: self,
        x: Coordinates::RIGHT_X - 150,
        y: Coordinates::BOTTOM_Y - 35,
        height: 35,
        width: 150,
        font: Gosu::Font.new(20),
        text: 'End Turn',
        action: :end_turn
      ),
      continue: Button.new(
        window: self,
        x: Coordinates::RIGHT_X - 150,
        y: Coordinates::BOTTOM_Y - 35,
        height: 35,
        width: 150,
        font: Gosu::Font.new(20),
        text: 'Continue',
        action: :end_turn
      ),
      roll_dice: Button.new(
        window: self,
        x: Coordinates::RIGHT_X - 150,
        y: Coordinates::BOTTOM_Y - 35,
        height: 35,
        width: 150,
        font: Gosu::Font.new(20),
        text: 'Roll Dice',
        action: :roll_dice
      ),
      collect_go_money: Button.new(
        window: self,
        x: Coordinates::RIGHT_X - 150,
        y: Coordinates::BOTTOM_Y - 35,
        height: 35,
        width: 150,
        font: Gosu::Font.new(20),
        text: 'Collect Go Money',
        action: :collect_go_money
      ),
      pay_rent: Button.new(
        window: self,
        x: Coordinates::RIGHT_X - 150,
        y: Coordinates::BOTTOM_Y - 35,
        height: 35,
        width: 150,
        font: Gosu::Font.new(20),
        text: 'Pay Rent',
        action: :pay_rent
      )
    }

    @visible_buttons = [@buttons[:roll_dice]]

    @current_tile = @tiles[0]

    @turn = 1
  end

  def buy
    unless @current_player.money >= @current_tile.purchase_price
      @message = "#{@current_player.name} does not have enough money to purchase this property."
      return
    end

    @current_player.money -= @current_tile.purchase_price
    @current_tile.owner = @current_player
    @current_player.properties += [@current_tile]

    update_visible_buttons(:end_turn)
  end

  def update

  end

  def update_visible_buttons(*button_names)
    @visible_buttons = button_names.map { |button_name| @buttons[button_name] }
    # tick
  end

  def end_turn
    @turn += 1
    @message = nil
    increment_current_player
    update_visible_buttons(:roll_dice)
  end

  def draw
    tile_details = [
      "Position: #{@tile_indexes[@current_tile]} / #{@tiles.count}"
    ]

    # Current tile images
    if @current_tile.respond_to?(:deed_image)
      @current_tile.tile_image.draw_from_center(Coordinates::CENTER_X - 100, Coordinates::CENTER_Y, ZOrder::UI, 1, 1)

      if @current_tile.deed_image
        @current_tile.deed_image.draw_from_center(Coordinates::CENTER_X + 100, Coordinates::CENTER_Y, ZOrder::UI, 1, 1)
      else
        puts("WARNING: NO DEED IMAGE FOR TILE: \"#{@current_tile.name}\"")
      end

      tile_details += [
        @current_tile.owner&.name ? "Owned By #{@current_tile.owner.name}" : 'Unowned',
        "#{@current_tile.house_count} Houses",
        @current_tile.mortgaged? ? 'Mortgaged' : 'Not Mortgaged'
      ]
    else
      @current_tile.tile_image.draw_from_center(Coordinates::CENTER_X, Coordinates::CENTER_Y, ZOrder::UI, 1, 1)
    end

    # Current tile details
    y_differential = 150
    tile_details.each do |detail|
      @font.draw_text_rel(detail, Coordinates::CENTER_X, Coordinates::CENTER_Y + y_differential, ZOrder::UI, 0.5, 0, 1, 1, Gosu::Color::YELLOW)
      y_differential += 25
    end

    # Player list
    y_differential = 0
    @players.each do |player|
      @font.draw_text_rel("#{player.name}: #{player.tile.name}", Coordinates::CENTER_X, Coordinates::TOP_Y + y_differential, ZOrder::UI, 0.5, 0, 1, 1, Gosu::Color::YELLOW)
      y_differential += 25
    end

    # Current player details
    @font.draw_text("#{@current_player.name}: $#{@current_player.money}", Coordinates::LEFT_X, Coordinates::TOP_Y, ZOrder::UI, 2, 2, Gosu::Color::YELLOW)
    y_differential = 50
    @current_player.properties.each do |property|
      property_string = "#{property.name}"
      property_string += " (#{property.house_count})" if property.house_count.positive?
      @font.draw_text(property_string, Coordinates::LEFT_X, Coordinates::TOP_Y + y_differential, ZOrder::UI, 1, 1, Gosu::Color::YELLOW)
      y_differential += 25
    end

    # Dice roll
    if @die_a
      @font.draw_text_rel("Dice Roll: #{@die_a}, #{@die_b}", Coordinates::RIGHT_X, Coordinates::TOP_Y, ZOrder::UI, 1, 0, 1, 1, Gosu::Color::YELLOW)
    end

    # Message
    @font.draw_text_rel(@message, Coordinates::LEFT_X, Coordinates::BOTTOM_Y, ZOrder::UI, 0, 1, 1, 1, Gosu::Color::YELLOW)

    # Buttons
    @visible_buttons.each { |button| button.draw(mouse_x, mouse_y) }
  end

  def needs_cursor?
    true
  end

  # def needs_redraw?
  #   if @redraw
  #     @redraw = false
  #     true
  #   else
  #     false
  #   end
  # end

  def button_down(id)
    case id
    when Gosu::MS_LEFT
      handle_click(mouse_x, mouse_y)
    when Gosu::KB_ESCAPE
      close
    when Gosu::KB_P
      print_state if ctrl_cmd_down?
    else
      super
    end
  end

  def handle_click(x, y)
    @visible_buttons.each do |button|
      if button.within?(x, y)
        button.perform_action
        break
      end
    end
  end

  def land
    case @current_tile
    when CardTile
    when FreeParkingTile
      @message = 'whoopdie doo, free parking'
      update_visible_buttons(:end_turn)
    when GoTile
      update_visible_buttons(:end_turn)
    when GoToJailTile
    when JailTile
    when PropertyTile
      if @current_tile.owner
        if @current_tile.owner == @current_player
          update_visible_buttons(:end_turn)
        else
          update_visible_buttons(:pay_rent)
        end
      else
        update_visible_buttons(:buy, :end_turn)
      end
    when RailroadTile
    when TaxTile
    when UtilityTile
    else
      # byebug
      pp 'Invalid tile type'
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
    times_passed_go = move(@die_a + @die_b)
    if times_passed_go > 0
      go_money_collected = @go_money_amount * times_passed_go
      extra_string = " #{times_passed_go} times" if times_passed_go > 1
      @message = "#{@current_player.name} has gained $#{go_money_collected} for passing Go#{extra_string}."
      @current_player.money += @go_money_amount
    end

    land
  end

  def pay_rent
    if @current_player.money < @current_tile.rent
      @current_tile.owner.money += @current_player.money
      @current_player.money = 0

      # TODO: mortgage logic
      eliminate_player
    else
      @current_tile.owner.money += @current_tile.rent
      @current_player.money -= @current_tile.rent
      update_visible_buttons(:end_turn)
    end
  end

  # TODO: maybe make this just call `end_turn`?
  def eliminate_player
    @message = "#{@current_player.name} is eliminated!"
    @current_player.properties.each do |property|
      property.owner = nil
      property.house_count = 0
      # TODO: unmortgage once mortgage logic is written
    end

    @current_player.properties = []
    @players.delete(@current_player)
    @current_player_index = @current_player_index == 0 ? @players.size - 1 : @current_player_index - 1
    # @current_player = @players[@current_player_index]
    # @current_tile = @current_player.tile
    update_visible_buttons(:continue)
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
