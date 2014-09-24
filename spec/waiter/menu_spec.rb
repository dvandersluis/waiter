require 'spec_helper'
require 'waiter/menu'

RSpec.describe Waiter::Menu do
  describe '.serve' do
    context 'basic DSL' do
      context 'when explicitly specifying block params' do
        subject do
          Waiter::Menu.serve(:test) do |menu|
            menu.first
            menu.second
            menu.third do |submenu|
              submenu.item1
              submenu.item2
            end
          end
        end

        it { is_expected.to have_exactly(3).items }
        it { is_expected.to have_menu_items_named(:first, :second, :third) }
        it { is_expected.to have_menu_items_named(:second, :third) }
        it { is_expected.to_not have_a_menu_item_named(:item1) }

        its([:first]) { is_expected.to_not have_a_submenu }
        its([:second]) { is_expected.to_not have_a_submenu }
        its([:third]) { is_expected.to have_a_submenu.containing(2).items }
      end

      context 'when omitting block params' do
        subject do
          Waiter::Menu.serve(:test) do
            first
            second
            third do
              item1
              item2
            end
          end
        end

        it { is_expected.to have_exactly(3).items }
        it { is_expected.to have_menu_items_named(:first, :second, :third) }
        it { is_expected.to have_menu_items_named(:second, :third) }
        it { is_expected.to_not have_a_menu_item_named(:item1) }

        its([:first]) { is_expected.to_not have_a_submenu }
        its([:second]) { is_expected.to_not have_a_submenu }
        its([:third]) { is_expected.to have_a_submenu.containing(2).items }
      end
    end

    context 'sections' do
      subject do
        Waiter::Menu.serve(:test) do
          section do
            first
            second
          end

          section do
            third
            fourth
          end

          fifth
        end
      end

      it { is_expected.to have_exactly(2).sections }
      it { is_expected.to have_a_menu_item_named(:fifth) }
      it { is_expected.to_not have_a_menu_item_named(:fourth) }

      its('sections.first') { is_expected.to have_exactly(2).items }
      its('sections.first') { is_expected.to have_menu_items_named(:first, :second) }
    end

    context 'using methods provided in context object' do
      let(:context) { double('Context Object', foo: 1, bar: 2) }

      subject do
        Waiter::Menu.serve(:test, context) do
          first if foo == 1
          second if foo == 2

          third do
            fourth if bar == 2
          end
        end
      end

      it { is_expected.to have_exactly(2).items }
      it { is_expected.to have_menu_items_named(:first, :third) }
      it { is_expected.to_not have_a_menu_item_named(:second) }

      its([:third]) { is_expected.to have_a_submenu.containing(1).item }
      its([:third]) { is_expected.to have_a_menu_item_named(:fourth) }
    end

    context 'options' do
      subject do
        Waiter::Menu.serve(:test, nil, foo: 1) do
          first bar: 2
          second(bar: 3) do
            third
          end

          section(foo: 2) do
            fourth
            fifth foo: 3
          end
        end
      end

      before { allow_any_instance_of(Waiter::Menu::Section).to receive(:collect_controllers) }
      before { allow_any_instance_of(Waiter::Menu::Item).to receive(:collect_controllers) }

      its([:first]) { is_expected.to have_options(foo: 1, bar: 2) }
      its([:second]) { is_expected.to have_options(foo: 1, bar: 3) }
      its('sections.first') { is_expected.to have_options(foo: 2) }

      it 'should pass options to submenus' do
        expect(subject[:second][:third]).to have_options(foo: 1, bar: 3)
      end

      it 'should pass options to sections' do
        expect(subject.sections.first[:fourth]).to have_options(foo: 2)
      end

      it 'should allow passed on options to be overriden' do
        expect(subject.sections.first[:fifth]).to have_options(foo: 3)
      end
    end
  end

  describe '.new' do
    let(:context) { double('Context') }

    subject { described_class.new(:test, context) }

    its(:context) { is_expected.to eq context }
    its(:items) { is_expected.to be_empty }
    its(:items) { is_expected.to be_a Waiter::Menu::ItemList }
    its(:options) { is_expected.to be_empty }
  end

  describe '#draw' do
    let(:drawer) { double(Waiter::Menu::Drawer).as_null_object }

    subject do
      Waiter::Menu.serve(:test) do |menu|
        menu.first
        menu.second
        menu.third do |submenu|
          submenu.item1
          submenu.item2
        end
      end
    end

    before do
      allow(Waiter::Menu::Drawer).to receive(:new).and_return(drawer)
    end

    it 'should create a new drawer' do
      expect(Waiter::Menu::Drawer).to receive(:new).with(subject, nil)
      subject.draw
    end

    it 'should draw the menu' do
      expect(drawer).to receive(:draw)
      subject.draw
    end
  end

  describe '#add' do
    subject do
      m = described_class.new(:test, nil)
      m.add(:foo, { controller: :path }, { do_something: true })
      m[:foo]
    end

    before { allow_any_instance_of(Waiter::Menu::Item).to receive(:collect_controllers) }

    it { is_expected.to be_a Waiter::Menu::Item }
    it { is_expected.to have_options(do_something: true) }
    its(:path) { is_expected.to eq(controller: '/path', action: :index) }
  end

  describe '#add_section' do
    subject do
      m = described_class.new(:test, nil)
      m.add_section({ do_something: true }) do
        item1
      end
      m.sections.last
    end

    before { allow_any_instance_of(Waiter::Menu::Section).to receive(:collect_controllers) }
    before { allow_any_instance_of(Waiter::Menu::Item).to receive(:collect_controllers) }

    it { is_expected.to be_a Waiter::Menu::Section }
    it { is_expected.to have_options(do_something: true) }

    it 'should not add a blank section' do
      m = described_class.new(:test, nil)
      m.add_section
      expect(m.sections.count).to eq 0
    end

    it 'should not add blank nested sections' do
      m = described_class.new(:test, nil)
      m.add_section do
        section {}
      end
      expect(m.sections.count).to eq 0
    end
  end

  describe '#sections' do
    context 'when sections are defined' do
      subject do
        m = described_class.new(:test, nil)
        3.times { m.add_section { item1 } }
        2.times { |i| m.add("item#{i}".to_sym, :path) }
        m.sections
      end

      it { is_expected.to all(be_a(Waiter::Menu::Section)) }
      its(:size) { is_expected.to eq 3 }
    end

    context 'when sections are not defined' do
      subject do
        m = described_class.new(:test, nil)
        2.times { |i| m.add("item#{i}".to_sym, :path) }
        m.sections
      end

      it { is_expected.to be_empty }
    end
  end

  describe '#[]' do
    subject { described_class.new(:test, nil) }

    context 'when the menu has no items' do
      its([:item1]) { is_expected.to be_nil }
    end

    context 'when the menu has items' do
      before { 2.times { |i| subject.add("item#{i}".to_sym, :path) } }

      its([:item1]) { is_expected.to be_a Waiter::Menu::Item }
    end
  end

  describe '#items' do
    before { allow_any_instance_of(Waiter::Menu::Item).to receive(:translate) { |_, key| key.to_sym } }

    subject do
      described_class.serve(:test, nil, @options) do
        foo
        bar
        baz
        quux
      end
    end

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

  describe '#top?' do
    it 'should be true for a new menu' do
      expect(described_class.new(:test, nil)).to be_top
    end

    it 'should be false for a submenu' do
      item = Waiter::Menu::Item.new(double('Parent', options: {}).as_null_object, :item1) do
        item2
      end

      expect(item.submenu).to_not be_top
    end
  end
end