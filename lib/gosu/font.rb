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

    def truncate_text(text:, trailing_text: nil, width:)
      length = (1..text.length).to_a.reverse.bsearch do |length|
        text_width(text[0...length]) < width
      end

      length ||= 0
      text[0...length] + (trailing_text || '')
    end
  end
end
