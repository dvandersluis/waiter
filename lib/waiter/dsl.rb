require 'active_support/core_ext/array/extract_options'

module Waiter
  module DSL
    def section(options = {}, &block)
      add_section(options, &block)
    end

    def method_missing(name, *args, &block)
      return context.send(name, *args, &block) if context.respond_to?(name)

      path = args.shift
      options = args.extract_options!

      if path.is_a?(Hash) && !(path.key?(:controller) || path.key?(:action))
        options, path = path, nil
      end

      options[:controllers] ||= []
      add(name, path, options, &block)
      return nil
    end
  end
end