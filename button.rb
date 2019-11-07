class Button
  DEFAULT_COLOR = Gosu::Color::WHITE.freeze
  DEFAULT_HOVER_COLOR = Gosu::Color.new(255, 219, 219, 219).freeze
  DEFAULT_HEIGHT = 50
  DEFAULT_WIDTH = 275
  MINIMUM_FONT_SIZE = 20

  attr_accessor :actions
  attr_accessor :center_x
  attr_accessor :center_y
  attr_accessor :color
  attr_accessor :font
  attr_accessor :font_color
  attr_accessor :height
  attr_accessor :hover_color
  attr_reader :text
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
    self.actions = window.format_actions(actions)

    self.center_x = x + (width / 2.0)
    self.center_y = y + (height / 2.0)
    self.color = color
    self.font = font
    self.font_color = font_color
    self.height = height
    self.hover_color = hover_color
    self.width = width
    self.window = window
    self.x = x
    self.y = y
    self.z = z

    self.text = text
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
    window.execute_actions(actions)
  end

  def text=(value)
    @text = value
    return text unless font

    # Find maximum font size (between set maximum and minimum)
    # usable while still fitting text on button
    font_size = (MINIMUM_FONT_SIZE..UserInterface::DEFAULT_FONT_SIZE).to_a.reverse.bsearch do |size|
      Gosu::Font.new(size).text_width(text) < width - 5
    end

    self.font = Gosu::Font.new(font_size || MINIMUM_FONT_SIZE)

    # If text doesn't fit on button even at minimum font size, truncate
    # text with ellipses beyond what can fit at minimum font size
    unless font_size
      length =
        (1..text.length).to_a.reverse.bsearch do |length|
          font.text_width(text[0...length]) < width - 20
        end

      length ||= 0
      @text = text[0...length] + '...'
    end

    text
  end

  def within?(_x, _y)
    _x >= x && _x < (x + width) && _y >= y && _y < (y + height)
  end
end
