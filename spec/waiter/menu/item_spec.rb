require 'spec_helper'
require 'waiter/menu/item'
require 'waiter/menu'

RSpec.describe Waiter::Menu::Item do
  let(:parent) { double(Waiter::Menu, name: :parent, options: {}, top?: false) }
  subject { described_class.new(parent, :item1, 'path') }

  before { allow_any_instance_of(described_class).to receive(:collect_controllers) }

  it { is_expected.to_not be_section }

  its(:name) { is_expected.to eq :item1 }
  its(:path) { is_expected.to eq 'path' }
  its(:options) { is_expected.to be_empty }
  its(:submenu) { is_expected.to be_nil }

  it_behaves_like 'a menu item', [:item1, 'path']

  context 'collecting controllers' do
    before { allow_any_instance_of(described_class).to receive(:collect_controllers).and_call_original }

    it 'should add its controller to the parent' do
      described_class.new(parent, :item1, controller: :foo)
      expect(parent.options[:controllers]).to contain_exactly('foo')
    end

    it 'should strip slashes from the controller name' do
      described_class.new(parent, :item1, controller: '/foo')
      expect(parent.options[:controllers]).to contain_exactly('foo')
    end

    it 'should retain controllers given in options' do
      parent.options[:controllers] = ['bar']
      described_class.new(parent, :item1, controller: :foo)
      expect(parent.options[:controllers]).to contain_exactly('foo', 'bar')
    end

    it 'should not duplicate controllers' do
      parent.options[:controllers] = ['foo']
      described_class.new(parent, :item1, controller: :foo)
      expect(parent.options[:controllers]).to contain_exactly('foo')
    end
  end

  describe '#selected?' do
    let(:parent) { double(Waiter::Menu, context: context, options: {}).as_null_object }
    let(:context) { double('Context', params: { controller: @controller }) }

    subject do
      item = described_class.new(parent, :item1)
      allow(item).to receive(:controllers).and_return(@controllers)
      item
    end

    it 'should return true if the controller matches' do
      @controller = 'foo'
      @controllers = %w(foo)
      expect(subject).to be_selected
    end

    it "should return false if the controller doesn't match" do
      @controller = 'foo'
      @controllers = %w(bar baz quux)
      expect(subject).to_not be_selected
    end

    it 'should return true if the controller matches a wildcard' do
      @controller = 'foo/bar/baz'
      @controllers = %w(foo/*)
      expect(subject).to be_selected
    end

    it 'should return true if a simple controller matches a wildcard' do
      @controller = 'foo'
      @controllers = %w(foo/*)
      expect(subject).to be_selected
    end

    it "should return false if the wildcard doesn't match" do
      @controller = 'foo'
      @controllers = %w(foo/bar/*)
      expect(subject).to_not be_selected
    end

    it 'should return false if the controller only matches part of a wildcard' do
      @controller = 'foo/baz'
      @controllers = %w(foo/bar/*)
      expect(subject).to_not be_selected
    end

    it "should return false if the controller doesn't match a wildcard from the start" do
      @controller = 'foo/bar'
      @controllers = %w(bar/*)
      expect(subject).to_not be_selected
    end

    context 'when a selected item is specified' do
      subject { described_class.new(parent, :item1, nil, selected: :foo) }

      it 'should return true if the item has the same name as the selection' do
        allow(subject).to receive(:name).and_return(:foo)
        expect(subject).to be_selected
      end

      it 'should return false if the item does not have the same name as the selection' do
        expect(subject).to_not be_selected
      end
    end
  end

  describe "#path" do
    let(:menu) { Waiter::Menu.new(:test, nil) }

    it 'should be nil if not specified for a top level item' do
      item = described_class.new(menu, :item1, nil)
      menu.add(item)

      expect(item.path).to be_nil
    end

    it 'should not be nil for a submenu item' do
      item = described_class.new(menu, :item1, nil) do
        subitem1
      end
      menu.add(item)

      expect(item.submenu[:subitem1].path).to eq(controller: '/subitem1', action: :index)
    end

    it 'should add an index if missing' do
      item = described_class.new(menu, :item1, nil) do
        subitem1 controller: :foo
      end
      menu.add(item)

      expect(item.submenu[:subitem1].path).to eq(controller: '/foo', action: :index)
    end

    it 'should add a controller if missing' do
      item = described_class.new(menu, :item1, nil) do
        subitem1 action: :foo
      end
      menu.add(item)

      expect(item.submenu[:subitem1].path).to eq(controller: '/subitem1', action: :foo)
    end

    it 'should not add anything if given a string' do
      item = described_class.new(menu, :item1, nil) do
        subitem1 '/foo/bar/baz'
      end
      menu.add(item)

      expect(item.submenu[:subitem1].path).to eq '/foo/bar/baz'
    end

    it 'should not add anything if given controller & action' do
      item = described_class.new(menu, :item1, nil) do
        subitem1 controller: :foo, action: :bar, id: 123
      end
      menu.add(item)

      expect(item.submenu[:subitem1].path).to eq(controller: '/foo', action: :bar, id: 123)
    end
  end
end
