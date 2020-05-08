module Monopoly
  class ScrollingList
    def initialize(items:, view_size:)
      @view_size = view_size
      self.items = items
    end

    def all_items
      @pre_items + @current_items + @post_items
    end

    def full_shift_back
      return false if @pre_items.empty?

      self.items = all_items
      true
    end

    def full_shift_forward
      return false if @post_items.empty?

      items = all_items
      @current_items = items.pop(@view_size)
      @pre_items = items
      @post_items = []
      true
    end

    def items
      @current_items
    end

    def next?
      !@post_items.empty?
    end

    def previous?
      !@pre_items.empty?
    end

    def items=(items)
      items = items.clone
      @pre_items = []
      @current_items = items.shift(@view_size)
      @post_items = items
    end

    def shift_back(times = 1)
      shifted = false
      times.times do
        break unless recede

        shifted = true
      end

      shifted
    end

    def shift_forward(times = 1)
      shifted = false
      times.times do
        break unless advance

        shifted = true
      end

      shifted
    end

    protected

    def advance
      return false if @post_items.empty?

      @pre_items << @current_items.shift unless @current_items.empty?
      @current_items << @post_items.shift

      true
    end

    def recede
      return false if @pre_items.empty?

      @post_items.prepend(@current_items.pop) unless @current_items.empty?
      @current_items.prepend(@pre_items.pop)

      true
    end
  end
end
