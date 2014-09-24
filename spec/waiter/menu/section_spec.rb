require 'spec_helper'
require 'waiter/menu/section'
require 'waiter/menu'

RSpec.describe Waiter::Menu::Section do
  let(:parent) { double(Waiter::Menu, name: :parent, context: nil, options: {}) }
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

  describe '#items' do
    subject do
      described_class.new(parent, @options) do
        foo
        bar
        baz
        quux
      end
    end

    before { allow_any_instance_of(Waiter::Menu::Item).to receive(:translate) { |_, key| key.to_sym } }

    it 'should sort by item title' do
      @options = { sort: :item_title }
      expect(subject.items(true).names).to match [:bar, :baz, :foo, :quux]
    end

    it 'should reverse' do
      @options = { reverse: true }
      expect(subject.items(true).names).to match [:quux, :baz, :bar, :foo]
    end

    it 'should sort and reverse at the same time' do
      @options = { sort: :item_title, reverse: true }
      expect(subject.items(true).names).to match [:quux, :foo, :baz, :bar]
    end
  end
end
