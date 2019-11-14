require_relative 'gosu/font'
require_relative 'gosu/image'

module Gosu
  class << self
    alias _draw_rect draw_rect
    def draw_rect(color:, height:, mode: :default, width:, x:, y:, z: 0)
      _draw_rect(x, y, width, height, color, z, mode)
    end
  end
end
