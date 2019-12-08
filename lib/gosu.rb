require_relative 'gosu/animation'
require_relative 'gosu/animation/spin_animation'
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
  end
end
