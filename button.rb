class Button
  DEFAULT_COLOR = Gosu::Color::WHITE.freeze
  DEFAULT_HOVER_COLOR = Gosu::Color.new(255, 219, 219, 219).freeze
  DEFAULT_HEIGHT = 50
  DEFAULT_WIDTH = 250

  attr_accessor :actions
  attr_accessor :center_x
  attr_accessor :center_y
  attr_accessor :color
  attr_accessor :font
  attr_accessor :font_color
  attr_accessor :height
  attr_accessor :hover_color
  attr_accessor :text
  attr_accessor :width
  attr_accessor :window
  attr_accessor :x
  attr_accessor :y
  attr_accessor :z

  def initialize(
    x: 0,
    y: 0,
    z: ZOrder::MAIN_UI,
    height: DEFAULT_HEIGHT,
    width: DEFAULT_WIDTH,
    color: DEFAULT_COLOR,
    hover_color: DEFAULT_HOVER_COLOR,
    font: nil,
    text: nil,
    font_color: nil,
    window:,
    actions:
  )
    @actions =
      if actions.is_a?(Array) && actions.all? { |element| element.is_a?(Array) }
        actions
      else
        [actions]
      end

    @center_x = x + (width / 2.0)
    @center_y = y + (height / 2.0)
    @color = color
    @font = font
    @font_color = font_color
    @height = height
    @hover_color = hover_color
    @text = text
    @width = width
    @window = window
    @x = x
    @y = y
    @z = z
  end

  def draw(mouse_x = nil, mouse_y = nil)
    if mouse_x && mouse_y && within?(mouse_x, mouse_y)
      Gosu.draw_rect(x, y, width, height, hover_color, z)
    else
      Gosu.draw_rect(x, y, width, height, color, z)
    end

    font&.draw_text_rel(
      text,
      center_x,
      center_y,
      z,
      0.5,
      0.5,
      1.0,
      1.0,
      font_color || Gosu::Color::BLACK
    )
  end

  def update_coordinates(new_x = nil, new_y = nil)
    self.x = new_x if new_x
    self.y = new_y if new_y

    self.center_x = x + (width / 2.0)
    self.center_y = y + (height / 2.0)
  end

  def perform_actions
    puts "\"#{text}\" button clicked"

    actions.each do |action|
      if action.is_a?(Array)
        parameters = action.last
        action = action.first
        if action.is_a?(Proc)
          action.call(parameters)
        elsif action.is_a?(Symbol)
          window.send(action, parameters)
        else
          pp "\"#{text}\" button has an invalid action"
        end
      else
        if action.is_a?(Proc)
          action.call
        elsif action.is_a?(Symbol)
          window.send(action)
        else
          pp "\"#{text}\" button has an invalid action"
        end
      end
    end
  end

  def within?(_x, _y)
    _x >= x && _x < (x + width) && _y >= y && _y < (y + height)
  end
end
