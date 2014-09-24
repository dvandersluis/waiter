# Waiter

Waiter serves up menus for your application:
* Provides a quick DSL for building menus, without having to specify any HTML.
* Makes assumptions based on what's provided in the DSL so that the specification does not need to be unnecessarily verbose.

## Installation

Add this line to your application's Gemfile:

    gem 'waiter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install waiter

## Usage

### Building a menu

To create a new menu:

    Waiter::Menu.serve(:my_menu) do
      file
      edit
      view
      # ...
    end

The above defines a menu with three items. By default, each item name (ie. "file", "edit", etc.) corresponds both to the
I18n string to use (so `file` will call `I18n.t(:file, scope: [:menu, :my_menu])`) as well as to the controller to use
(`file` will correspond to `FileController`, and the menu item will link to `FileController#index` by default).

Of course, there will be situations where the path may need to be explicitly specified. In this case, you can use a path finder:

    Waiter::Menu::serve do
      menu.file documents_path
    end
 
Alternately, the `:controller` and `:action` options can be specified:

    Waiter::Menu.serve do
      menu.file :controller => :documents, :action => :index
    end
    
In both of the above examples, the File menu will correspond to `DocumentsController#index`, and will be shown as selected
for any action within that controller.

There may also be times where you need multiple controllers to light up the same menu item. This can be achieved by
passing an array to the `:controllers` option:

    Waiter::Menu.serve do
      file :controllers => ['files', 'print', ... ]
    end

This will create a menu that links to `DocumentsController#index`, which will be lit up the user hits any action within
the `FilesController`, `PrintController`, as well as the `DocumentsController`.


### Submenus

Menus can also have submenus (currently only one level of nesting is supported when drawing a menu, but infinite
levels are supported when building a menu). A submenu is defined with the same syntax as a root menu item, and is
passed as a block to the root menu item.

Submenus automatically assume the controller to use is the controller specified by its root menu item, so a
controller does not need to be specified unless it differs. As well, the menu item name is assumed to be used
for the controller for that item, so it does not need to be specified unless it differs from the name.
An id can also be specified if necessary (with the `:id` option).

    Waiter::Menu.serve do
      file do
        new                            # Corresponds to FileController#new
        print print_file_path          # Corresponds to PrintController#print
        list :action => :all           # Corresponds to ListController#all
      end
    end

If a path hash is given without an `action` key, the index action will be inferred.


### Menu Options

There are two options that you can use when building your menu. Options can be passed into build when defining
a menu or specified once the menu is defined by accessing the menu.options hash.

`selected`: Allows the selected menu item to be overridden, so a specified menu item can be lit up regardless of
what the current controller/action is. This can be useful if there is an action that falls under different menu
items depending on application context, or if there is a controller that may correspond to multiple menu items.
A good way to achieve this would be to add a before_filter to set an instance variable which is then passed into
the selected option.

    before_filter :set_current_menu

    def set_current_menu
      case params[:action]
        when 'foo' then @current_menu = "menu1"
        when 'bar' then @current_menu = "menu2"
      end
    end

    Waiter::Menu.serve(:selected => @current_menu) do |menu|
    end

Note that the value passed to `:selected` should match the name of the menu item.


### Drawing (outputting) a menu

To draw a created menu, use the `Waiter::Menu::Drawer` class. The class requires the current context to be
passed in so that `ActionController` methods can be used. In general (ie. if the menu is being drawn from a helper)
the context is self.

    menu = Waiter::Menu.serve do |menu|
      # ...
    end

    Waiter::Menu::Drawer.new(menu, context).draw

If a different `Drawer` is desired, `Waiter::Menu::Drawer` can be subclassed and the method `draw` overridden to provide an alternate format.

Alternately, `Waiter::Menu` responds to `draw` directly:

    menu.draw(context)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
