RSpec::Matchers.define :have_a_submenu do
  match do |actual|
    result = !actual.submenu.nil?
    result &&= actual.submenu.items.size == @count unless @count.nil?
    result
  end

  description do
    desc = "have a submenu"
    desc << " with #{@count} items" unless @count.nil?
    desc
  end

  failure_message do
    msg = "expected menu item to have a submenu"

    unless @count.nil?
      msg << " with #{@count} items but it actually has #{actual.submenu.items.size}"
    end

    msg
  end

  failure_message_when_negated do
    msg = "expected menu item to not have a submenu"
  end

  chain :containing do |count|
    @count = count
  end

  chain(:item) {}
  chain(:items) {}
end