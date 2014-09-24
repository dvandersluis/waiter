RSpec.shared_examples 'a menu item' do |instance_options|
  let(:parent) { double(Waiter::Menu, context: nil, name: :parent, options: {}) }

  before { allow_any_instance_of(Waiter::Menu::Item).to receive(:collect_controllers) }

  context 'when given a block' do
    subject do
      described_class.new(parent, *instance_options) do
        first
      end
    end

    its(:submenu) { is_expected.to have_exactly(1).item }
    its(:submenu) { is_expected.to have_a_menu_item_named(:first) }

    context 'with options' do
      before { allow(parent).to receive(:options).and_return(foo: :bar) }

      subject do
        described_class.new(parent, *instance_options) do
          first foo: :baz
          second
          third quux: true
        end
      end

      its([:first]) { is_expected.to have_options(foo: :baz) }
      its([:second]) { is_expected.to have_options(foo: :bar) }
      its([:third]) { is_expected.to have_options(foo: :bar, quux: true) }
    end
  end

  describe '#items' do
    context 'when a block is not given' do
      its(:items) { is_expected.to be_empty }
    end

    context 'when a block is given' do
      subject do
        described_class.new(parent, *instance_options) do
          first
          second
        end
      end

      its('items.size') { is_expected.to eq(2) }
    end
  end

  describe '#[]' do
    context 'when a block is not given' do
      its([:third]) { is_expected.to be_nil }
    end

    context 'when a block is given' do
      subject do
        described_class.new(parent, *instance_options) do
          first
          second
        end
      end

      its([:second]) { is_expected.to be_a(Waiter::Menu::Item) }
      its([:third]) { is_expected.to be_nil }
    end
  end
end