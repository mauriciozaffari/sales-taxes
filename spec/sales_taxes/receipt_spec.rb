# frozen_string_literal: true

RSpec.describe SalesTaxes::Receipt do
  subject(:receipt) { described_class.new }

  it 'renders an empty basket with zero totals and a trailing newline' do
    expect(receipt.render(SalesTaxes::Basket.new([]))).to eq("Sales Taxes: 0.00\nTotal: 0.00\n")
  end

  it 'preserves the product name and prints two decimal places for an exempt basket' do
    items = SalesTaxes::Parser.new.parse("1 BOOK at 12.00\n1 chocolate bar at 0.05")
    expect(receipt.render(SalesTaxes::Basket.new(items))).to eq(
      "1 BOOK: 12.00\n1 chocolate bar: 0.05\nSales Taxes: 0.00\nTotal: 12.05\n"
    )
  end
end
