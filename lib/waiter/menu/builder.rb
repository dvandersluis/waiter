module Waiter
  class Menu
    # Builds a menu structure from the DSL
    class Builder
      def initialize(menu)
        @menu = menu
      end

      def method_missing(name, *args, &block)
        @menu.add name, *args
        if block_given?
          @menu.submenus[name] = Menu.new(@menu.options.merge(:controller => (args.first.andand[:controller] || name)))
          yield Builder.new(@menu.submenus[name])
        end
      end
    end
  end
end