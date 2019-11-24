module Gosu
  # Adapted from https://gist.github.com/jlnr/661266
  class Circle
    attr_reader :columns
    attr_reader :rows

    def initialize(color: Color::WHITE, radius:)
      @columns = @rows = radius * 2

      clear = 0.chr
      solid = color.alpha.chr
      lower_half = (0...radius).map do |y|
        x = Math.sqrt(radius ** 2 - y ** 2).round
        right_half = "#{solid * x}#{clear * (radius - x)}"
        right_half.reverse + right_half
      end.join

      alpha_channel = lower_half.reverse + lower_half

      # Expand alpha bytes into RGBA color values.
      color_string = color.red.chr + color.green.chr + color.blue.chr
      @blob = alpha_channel.gsub(/./) { |alpha| color_string + alpha }
    end

    def to_blob
      @blob
    end
  end
end
