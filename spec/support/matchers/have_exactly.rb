RSpec::Matchers.define :have_exactly do |expected|
  match do |actual|
    if @sections
      actual.sections.size == expected
    else
      actual.items.size == expected
    end
  end

  description do
    "contain exactly #{expected} menu #{@sections ? 'sections' : 'items'}"
  end

  failure_message do
    msg = "expected that the menu would contain #{expected} #{@sections ? 'sections' : 'items'}; actually contains "
    msg << (@sections ? actual.sections.size : actual.items.size).to_s
    msg
  end

  chain(:item) { @sections = false }
  chain(:items) { @sections = false }
  chain(:section) { @sections = true }
  chain(:sections) { @sections = true }
end