# frozen_string_literal: true

RSpec.describe SalesTaxes::Item do
  def build_item(**attributes)
    described_class.new(quantity: 1, name: 'book', unit_price_cents: 1249, **attributes)
  end

  it 'stores the quantity and unit price without conversion' do
    item = build_item(quantity: 2)
    expect([item.quantity, item.unit_price_cents]).to eq([2, 1249])
  end

  it 'copies and freezes the name and freezes itself', :aggregate_failures do
    name = +'book'
    item = build_item(name:)
    name.replace('perfume')
    expect(item.name).to eq('book')
    expect([item, item.name]).to all(be_frozen)
  end

  it 'accepts zero price' do
    expect(build_item(unit_price_cents: 0).unit_price_cents).to eq(0)
  end

  [0, -1, 1.5, '1'].each do |quantity|
    it "rejects quantity #{quantity.inspect}" do
      expect { build_item(quantity:) }.to raise_error(ArgumentError, /Quantity/)
    end
  end

  [nil, '', '  '].each do |name|
    it "rejects name #{name.inspect}" do
      expect { build_item(name:) }.to raise_error(ArgumentError, /Name/)
    end
  end

  [-1, 1.2, '100'].each do |unit_price_cents|
    it "rejects price #{unit_price_cents.inspect}" do
      expect { build_item(unit_price_cents:) }.to raise_error(ArgumentError, /Unit price/)
    end
  end

  ['book', 'books', 'chocolate bar', 'imported boxes of chocolates', 'packet of headache pills', 'PILL'].each do |name|
    it "exempts #{name}" do
      expect(build_item(name:)).to be_exempt
    end
  end

  ['music CD', 'perfume', 'bookends', 'pillbox', 'unknown food'].each do |name|
    it "does not exempt #{name}" do
      expect(build_item(name:)).not_to be_exempt
    end
  end

  it 'recognizes imported as a whole word anywhere, regardless of case' do
    expect(build_item(name: 'box of IMPORTED chocolates')).to be_imported
  end

  it 'does not mistake a substring for the imported flag' do
    expect(build_item(name: 'unimported perfume')).not_to be_imported
  end
end
