module Waiter
  class Menu
    class ItemList < Array
      def initialize(ary = [], sort_options = {})
        super(ary)
        sort(sort_options)
      end

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

      def sort(options = {})
        sort_by!(&options[:sort].to_sym) if options.fetch(:sort, false)
        reverse! if options.fetch(:reverse, false)
      end
    end
  end
end