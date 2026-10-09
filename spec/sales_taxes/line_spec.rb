# frozen_string_literal: true

RSpec.describe SalesTaxes::Line do
  let(:item) { SalesTaxes::Item.new(quantity: 3, name: 'imported chocolates', unit_price_cents: 1125) }
  let(:line) { described_class.new(item) }

  it 'retains the original item' do
    expect(line.item).to equal(item)
  end

  it 'stores the calculated tax for the whole line' do
    expect(line.tax_cents).to eq(180)
  end

  it 'adds tax to the price of all units' do
    expect(line.total_cents).to eq(3555)
  end

  it 'is immutable' do
    expect(line).to be_frozen
  end
end
