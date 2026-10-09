# frozen_string_literal: true

RSpec.describe SalesTaxes::TaxCalculator do
  subject(:calculator) { described_class.new }

  def item(price, name: 'perfume', quantity: 1)
    SalesTaxes::Item.new(quantity:, name:, unit_price_cents: price)
  end

  { 0 => 0, 1 => 5, 49 => 5, 50 => 5, 51 => 10, 500 => 50, 501 => 55, 1499 => 150 }.each do |price, tax|
    it "rounds the basic tax on #{price} cents to #{tax} cents" do
      expect(calculator.tax_cents(item(price))).to eq(tax)
    end
  end

  it 'charges no basic tax on exempt products' do
    expect(calculator.tax_cents(item(1249, name: 'book'))).to eq(0)
  end

  it 'charges import duty even on exempt goods' do
    expect(calculator.tax_cents(item(1125, name: 'imported chocolates'))).to eq(60)
  end

  it 'leaves exact five-cent multiples unchanged' do
    expect(calculator.tax_cents(item(1000, name: 'imported chocolates'))).to eq(50)
  end

  it 'rounds each applicable rate separately, not the combined rate' do
    expect(calculator.tax_cents(item(1003, name: 'imported perfume'))).to eq(160)
  end

  it 'rounds per unit before multiplying by quantity' do
    expect(calculator.tax_cents(item(1125, name: 'imported chocolates', quantity: 3))).to eq(180)
  end

  it 'multiplies both rounded taxes for multiple fully taxed units' do
    expect(calculator.tax_cents(item(1003, name: 'imported perfume', quantity: 3))).to eq(480)
  end

  it 'supports large prices and quantities without precision loss' do
    expect(calculator.tax_cents(item(1_000_000_001, quantity: 1_000_000))).to eq(100_000_005_000_000)
  end
end
