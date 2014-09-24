require "waiter/menu"
require "waiter/dsl"
require "waiter/menu/drawer"

module Waiter
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w{ waiter/menu.css }
      Rails.application.config.assets.paths << root.join("app", "assets", "stylesheets")
      Rails.application.config.assets.paths << root.join("app", "assets", "images")
    end
  end
end
