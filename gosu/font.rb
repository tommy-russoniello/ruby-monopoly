module Gosu
  class Font
    alias _draw_text draw_text
    def draw_text(
      text,
      color: 0xff_ffffff,
      mode: :default,
      rel_x: 0,
      rel_y: 0,
      scale_x: 1,
      scale_y: 1,
      x:,
      y:,
      z:
    )
      draw_text_rel(text, x, y, z, rel_x, rel_y, scale_x, scale_y, color, mode)
    end
  end
end
