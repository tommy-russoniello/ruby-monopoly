module Gosu
  class Font
    def self.wrap_text(
      max_lines: nil,
      max_size:,
      min_size:,
      name: nil,
      text:,
      trailing_text: '...',
      width:
    )
      text = text.strip
      return_lines = []
      font_size = (min_size..max_size).to_a.reverse.bsearch do |size|
        font = new(size, name: name)
        lines = Array.new(max_lines || 0)
        line_index = 0
        success = true
        words = text.split
        words.each.with_index do |word, index|
          new_line = lines[line_index] ? "#{lines[line_index]} #{word}" : word

          # The line can fit the new word
          if font.text_width(new_line) < width
            lines[line_index] = new_line

          # The word alone can't fit on the line
          elsif lines[line_index].nil?
            line_trailing_text = line_index >= max_lines - 1 ? trailing_text : '-'
            truncated_text = font.truncate_text(text: new_line, width: width)
            lines[line_index] = truncated_text + line_trailing_text
            words.insert(index + 1, new_line[truncated_text.length..-1])

            if max_lines && line_index >= max_lines - 1
              success = false
              break
            end

          # The line cannot fit the new word, but we're not out of lines yet
          elsif max_lines.nil? || line_index < max_lines - 1
            line_index += 1
            redo

          # The last line cannot fit the new word
          else
            lines[max_lines - 1] = "#{lines[max_lines - 1]}#{trailing_text}"
            success = false
            break
          end
        end

        # The last iteration with either of these conditions will be the optimal
        # solution, so we record the value each time to avoid having to reprocess
        # the lines once we've found the optimal font size
        return_lines = lines if success || size == min_size
        success
      end

      { font: new(font_size || min_size, name: name), lines: return_lines }
    end

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
