RSpec::Matchers.define :have_menu_items_named do |*expected|
  match do |actual|
    actual.items.names & expected == expected
  end

  description do
    if expected.one?
      "contain a menu item named #{expected.first.to_s}"
    else
      "contain menu items named #{expected.map(&:to_s).join(', ')}"
    end
  end

  failure_message do
    msg = if expected.one?
            "expected menu to contain a menu item named #{expected}"
          else
            "expected menu to contain a menu items named #{expected}"
          end

    msg << "\nDiff:"

    differ = RSpec::Support::Differ.new(
        :object_preparer => lambda { |object| RSpec::Matchers::Composable.surface_descriptions_in(object) },
        :color => RSpec::Matchers.configuration.color?
    )

    msg << differ.diff(actual.items.names.join("\n"), expected.join("\n"))
  end
end

RSpec::Matchers.alias_matcher :have_a_menu_item_named, :have_menu_items_named