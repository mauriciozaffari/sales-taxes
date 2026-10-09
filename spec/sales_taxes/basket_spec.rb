# frozen_string_literal: true

RSpec.describe SalesTaxes::Basket do
  it 'totals the line prices and taxes' do
    items = SalesTaxes::Parser.new.parse("2 music CD at 14.99\n1 chocolate bar at 0.85")
    basket = described_class.new(items)
    expect([basket.tax_cents, basket.total_cents]).to eq([300, 3383])
  end

  it 'prices the same items under two independent policies', :aggregate_failures do
    items = SalesTaxes::Parser.new.parse('2 music CD at 14.99')
    alternative = instance_double(SalesTaxes::TaxCalculator, tax_cents: 600)
    current = described_class.new(items)
    proposed = described_class.new(items, calculator: alternative)
    expect([current.tax_cents, proposed.tax_cents, proposed.total_cents - current.total_cents]).to eq([300, 600, 300])
  end

  it 'has zero totals when empty' do
    basket = described_class.new([])
    expect([basket.tax_cents, basket.total_cents]).to eq([0, 0])
  end

  it 'is an immutable snapshot of the input array', :aggregate_failures do
    items = SalesTaxes::Parser.new.parse('1 book at 12.49')
    basket = described_class.new(items)
    items.clear
    expect(basket.lines.size).to eq(1)
    expect([basket, basket.lines, basket.lines.first]).to all(be_frozen)
  end
end
