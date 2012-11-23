module Waiter
  class Menu
    attr_accessor :options, :submenus

    class << self
      def serve(options = {})
        yield Builder.new(obj = self.new(options))
        obj
      end
    end

    def initialize(options = {})
      @menu_items = []
      @submenus = {}
      @options = options
    end

    def add(name, args = {})
      @menu_items << [name, args]
    end

    def items
      @menu_items
    end
  end
end