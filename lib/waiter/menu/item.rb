require 'active_support/core_ext/object/try'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'

module Waiter
  class Menu
    class Item
      attr_reader :parent, :name, :path, :submenu
      attr_accessor :options
      delegate :context, to: :parent

      def initialize(parent, name, path = {}, options = {}, &block)
        @parent = parent
        @name = name
        @path = complete_path_for(path)
        @options = options

        collect_controllers

        @options.reverse_merge!(parent.options || {})

        if block_given?
          @submenu = Menu.new([@parent.name, name].compact, @parent.context, @options.dup)
          @submenu.parent = self
          @submenu.update(&block)
        end
      end

      def section?
        false
      end

      def column?
        false
      end

      def items
        @submenu.try(:items) || []
      end

      def empty?
        items.empty?
      end

      def [](name)
        return nil if items.empty?
        items[name]
      end

      def submenu?
        submenu.present?
      end

      def menu_title
        translate(:title)
      end

      def item_title
        translate(name)
      end

      def controller
        @controller ||= find_controller
      end

      def controllers
        options[:controllers]
      end

      def selected?
        return name == options[:selected] if options[:selected]

        current_controller = context.params[:controller]

        if wildcard_controllers.any?
          return true if wildcard_controllers.any? do |c|
            r = Regexp.new('\A' + c.sub(%r{/\*\Z}, '(/*)?').gsub('*', '.*'))
            r =~ current_controller
          end
        end

        controllers.include?(current_controller)
      end

      def inspect
        "#<#{self.class.name}:#{'0x%x' % (36971870 << 1)} name=#{name.inspect} options=#{options.inspect} parent=#{parent.inspect} submenu=#{submenu.inspect}>"
      end

    private

      def translate(key)
        scope = i18n_scope
        scope.pop if scope.last == key
        I18n.t(key, scope: scope, cascade: true)
      end

      def i18n_scope
        [:menu, parent.name, name].flatten.compact
      end

      def complete_path_for(path)
        return if path.nil? && parent.top?

        case path
          when String
            path

          when Hash, NilClass
            path ||= {}
            path[:action] ||= :index
            path[:controller] ||= name
            path[:controller] = path[:controller].to_s.gsub(%r{^(?!/)}, '/')
            path
        end
      end

      def find_controller
        case path
          when Hash
            path[:controller].to_s.gsub(%r{^/}, '')

          when String
            request = parent.context.request
            route = Rails.application.routes.recognize_path("#{request.protocol}#{request.host}#{path}")
            route ? route[:controller].to_s : nil
        end

      rescue ActionController::RoutingError
        nil
      end

      def collect_controllers
        target = parent.top? ? self : parent
        target.options[:controllers] ||= []
        target.options[:controllers] << controller unless controller.blank?
        target.options[:controllers].uniq!
      end

      def wildcard_controllers
        @wildcard_controllers ||= controllers.select{ |c| c['*'] }
      end
    end
  end
end
