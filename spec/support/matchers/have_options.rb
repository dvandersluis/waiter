require 'active_support/core_ext/hash/except'

RSpec::Matchers.define :have_options do |expected|
  match do |actual|
    options == expected
  end

  failure_message do
    msg = "expected to contain options #{expected} but actually contained #{options}\nDiff:"

    differ = RSpec::Support::Differ.new(
        :object_preparer => lambda { |object| RSpec::Matchers::Composable.surface_descriptions_in(object) },
        :color => RSpec::Matchers.configuration.color?
    )

    msg << differ.diff(options, expected)
    msg
  end

  def options
    expected.key?(:controllers) ? actual.options : actual.options.except(:controllers)
  end
end