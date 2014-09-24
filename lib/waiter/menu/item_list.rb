module Waiter
  class Menu
    class ItemList < Array
      def include?(other)
        return map(&:name).include?(other) if other.is_a? Symbol
        super
      end

      def [](index)
        return detect{ |item| item.name == index } if index.is_a? Symbol
        super
      end

      def names
        map(&:name)
      end
    end
  end
end