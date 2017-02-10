require 'waiter/menu/section'

module Waiter
  class Menu
    class Column < Section
      def column?
        true
      end

      def section?
        false
      end
    end
  end
end
