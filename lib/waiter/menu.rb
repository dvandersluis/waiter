require 'waiter/dsl'
require 'waiter/menu/item_list'
require 'waiter/menu/item'
require 'waiter/menu/section'
require 'waiter/menu/column'
require 'waiter/menu/drawer'
require 'active_support/core_ext/hash/slice'

module Waiter
  class Menu
    attr_accessor :name, :context, :options, :submenu, :parent

    include DSL

    def self.serve(name, context = nil, options = {}, &block)
      new(name, context, options).tap do |menu|
        menu.update(&block)
      end
    end

    def initialize(name, context, options = {})
      @name = name
      @context = context
      @items = ItemList.new
      @options = options
    end

    def update(&block)
      instance_eval(&block)
    end

    def draw(context = nil)
      Drawer.new(self, context).draw
    end

    def add(name, path = {}, options = {}, &block)
      items << Item.new(self, name, path, options, &block)
    end

    def add_section(options = {}, &block)
      section = Section.new(self, options, &block)
      items << section unless section.empty?
    end

    def add_column(options = {}, &block)
      column = Column.new(self, options, &block)
      items << column unless column.empty?
    end

    def sections
      items.select(&:section?) || []
    end

    def [](name)
      items[name]
    end

    def items(sorted = false)
      return @items unless sorted
      ItemList.new(@items, options.slice(:sort, :reverse))
    end

    def top?
      parent.nil?
    end

    def inspect
      "#<#{self.class.name}:#{'0x%x' % (36971870 << 1)} name=#{name.inspect} options=#{options.inspect}>"
    end
  end
end
