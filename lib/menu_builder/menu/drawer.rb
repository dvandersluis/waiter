module MenuBuilder
  class Menu
    # Outputs a Menu into HTML
    class Drawer
      # @context is a Controller binding, which allows the ActionView helpers to work in the correct context
      delegate :link_to, :content_tag, :params, :to => :@context

      def initialize(menu, context)
        @context = context
        @menu = menu
      end

      def draw
        content_tag :div, :id => "menu" do
          out = ActiveSupport::SafeBuffer.new

          @menu.items.each do |(name, menu)|
            menu[:controller] = name unless menu[:controller]

            # Allow an :if option which will only display the menu if true
            if !menu[:if] or menu[:if].call
              # If there is a :selected option, use that instead of trying to determine the selected menu item
              selected = menu_selected?(name, menu[:controller], menu[:action] || menu[:actions], menu.delete(:controllers))

              out << content_tag(:span, :class => selected ? "selected" : nil) do
                out2 = ActiveSupport::SafeBuffer.new
                out2 << link_to(I18n.t(@menu.options[:string_prefix].to_s + name.to_s), { :controller => menu.delete(:controller).to_s.absolutify, :action => (menu.delete(:action) || menu.delete(:actions).andand.first) }.merge(menu))
                out2 << draw_submenu(@menu.submenus[name]) if @menu.submenus[name]
                out2
              end
            end
          end

          out << '<br class="clear" />'.html_safe
          out
        end
      end

      def draw_submenu(submenu)
        content_tag :table, :class => "dropdown", :cellspacing => 0 do

          out = ActiveSupport::SafeBuffer.new

          submenu.items.each do |(name, menu)|
            out << content_tag(:tr) do
              content_tag :td do
                controller = menu.delete(:controller) || submenu.options[:controller]
                action =
                    menu.delete(:action) || begin
                      controller_class = "#{controller}_controller".classify.constantize
                      controller_class.action_methods.include?(name.to_s) ? name : nil
                    end rescue nil || :index

                link_to I18n.t(submenu.options[:string_prefix].to_s + name.to_s), { :controller => controller.to_s.absolutify, :action => action }.merge(menu)
              end
            end
          end

          out
        end
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

class String
  def absolutify
    self.gsub(%r{^(?!/)}, "/")
  end
end