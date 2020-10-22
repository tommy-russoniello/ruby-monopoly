module Monopoly
  class Menu
    attr_accessor :buttons
    attr_accessor :drawing
    attr_accessor :game
    attr_accessor :images
    attr_accessor :rectangles
    attr_accessor :texts
    attr_accessor :visible_buttons

    def initialize(game)
      self.game = game
      self.images = {}
      self.rectangles = {}
      self.texts = {}
      self.visible_buttons = []
    end

    def close
      self.drawing = false
      self.visible_buttons = []
    end

    def draw
      return unless drawing?

      rectangles.values.each { |params| Gosu.draw_rect(**params) }
      images.values.each { |data| data[:image]&.draw(**data[:params]) }
      texts.values.each do |data|
        data[:font].draw_text(data[:text], **data[:params]) if data[:text]
      end

      draw_buttons(visible_buttons)
    end

    def drawing?
      drawing
    end

    def open
      self.drawing = true
    end

    def update; end

    private

    def draw_buttons(buttons_to_draw)
      coordinates = [game.draw_mouse_x, game.draw_mouse_y] unless game.dialogue_box_menu.drawing?
      buttons_to_draw.each { |button| button.draw(*coordinates) }
    end
  end
end
