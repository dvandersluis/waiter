require 'spec_helper'
require 'waiter/menu/section'
require 'waiter/menu'

RSpec.describe Waiter::Menu::Section do
  let(:parent) { double(Waiter::Menu, name: :parent, options: {}) }
  subject { described_class.new(parent) }

  before do
    allow_any_instance_of(described_class).to receive(:collect_controllers)
  end

  it { is_expected.to be_section }

  its(:name) { is_expected.to be_nil }
  its(:path) { is_expected.to be_nil }
  its(:options) { is_expected.to be_empty }
  its(:submenu) { is_expected.to be_nil }

  it_behaves_like 'a menu item', []
end
