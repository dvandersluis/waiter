require 'spec_helper'
require 'waiter/menu/item_list'

RSpec.describe Waiter::Menu::ItemList do
  let(:item1) { double('Item', name: :foo) }
  let(:item2) { double('Item', name: :bar) }
  let(:item3) { double('Item', name: :baz) }

  subject { described_class.new [item1, item2, item3] }

  describe '#include?' do
    it { is_expected.to include item1 }
    it { is_expected.to include item2 }
    it { is_expected.to include item3 }

    it { is_expected.to include :foo }
    it { is_expected.to include :bar }
    it { is_expected.to include :baz }

    it { is_expected.to_not include :foobarbaz }
  end

  describe '#[]' do
    its([0]) { is_expected.to eq item1 }
    its([1]) { is_expected.to eq item2 }
    its([2]) { is_expected.to eq item3 }

    its([:foo]) { is_expected.to eq item1 }
    its([:bar]) { is_expected.to eq item2 }
    its([:baz]) { is_expected.to eq item3 }

    its([:foobarbaz]) { is_expected.to be nil }
  end

  describe '#names' do
    its(:names) { is_expected.to contain_exactly(:foo, :bar, :baz) }
  end
end
