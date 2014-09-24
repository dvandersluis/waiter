require 'active_support/core_ext/module/delegation'

module Waiter
  class Menu
    # Outputs a Menu into HTML
    class Drawer
      attr_reader :menu, :context

      delegate :render, :link_to, :content_tag, :params, :to => :context

      def initialize(menu, context)
        # context is a Controller binding, which allows the ActionView helpers to work in the correct context
        @context = context
        @menu = menu
      end

      def draw
        render partial: 'waiter/menu_bar', locals: { menu: menu }
      end

      protected
      def menu_selected?(name, controller, action = nil, controllers = [])
        controllers = [] unless controllers

        if @menu.options[:selected]
          name.to_s == @menu.options[:selected].to_s
        else
          return true if controllers.map(&:to_s).include?(params[:controller])

          selected = params[:controller] == controller.to_s

          if action.is_a? Array
            selected &&= action.map(&:to_s).include?(params[:action])
          elsif action
            selected &&= params[:action] == action.to_s
          end

          selected
        end
      end
    end
  end
end