require 'waiter/menu/item'

module Waiter
  class Menu
    class Section < Item
      def initialize(parent, options = {}, &block)
        super(parent, nil, nil, options, &block)
      end

      def section?
        true
      end

    private

      def complete_path_for(*)
        nil
      end
    end
  end
end