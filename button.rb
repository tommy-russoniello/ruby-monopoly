class Button
  attr_accessor :action
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

  def initialize(x:, y:, height:, width:, color: Gosu::Color::WHITE, hover_color: Gosu::Color.new(255, 219, 219, 219), font: nil, text: nil, font_color: nil, window:, action:)
    @action = action
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
  end

  def draw(mouse_x = nil, mouse_y = nil)
    if mouse_x && mouse_y && within?(mouse_x, mouse_y)
      Gosu.draw_rect(x, y, width, height, hover_color, ZOrder::UI)
    else
      Gosu.draw_rect(x, y, width, height, color, ZOrder::UI)
    end

    font&.draw_text_rel(text, center_x, center_y, ZOrder::UI, 0.5, 0.5, 1.0, 1.0, (font_color || Gosu::Color::BLACK))
  end

  def perform_action
    puts "\"#{text}\" button clicked"

    if action.is_a?(Proc)
      action.call
    elsif action.is_a?(Symbol)
      window.send(action)
    else
      pp "\"#{text}\" button has invalid action"
    end
  end

  def within?(_x, _y)
    _x >= x && _x < (x + width) && _y >= y && _y < (y + height)
  end
end
