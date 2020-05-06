require_relative 'gosu/circle'
require_relative 'gosu/font'
require_relative 'gosu/image'

module Gosu
  class << self
    alias _draw_rect draw_rect
    def draw_rect(color:, from_center: false, height:, mode: :default, width:, x:, y:, z: 0)
      if from_center
        x = x - (width / 2.0)
        y = y - (height / 2.0)
      end

      _draw_rect(x, y, width, height, color, z, mode)
    end

    alias _draw_triangle draw_triangle
    def draw_triangle(
      color: nil,
      color1: nil,
      color2: nil,
      color3: nil,
      mode: :default,
      x1:,
      x2:,
      x3:,
      y1:,
      y2:,
      y3:,
      z: 0
    )
      color1 = color2 = color3 = color if color
      _draw_triangle(x1, y1, color1, x2, y2, color2, x3, y3, color3, z, mode)
    end
  end
end
