# frozen_string_literal: true

RSpec.describe SalesTaxes::Parser do
  subject(:parser) { described_class.new }

  it 'parses quantity, product name and decimal price into integer cents' do
    item = parser.parse("2 imported book at 12.49\n").first
    expect([item.quantity, item.name, item.unit_price_cents]).to eq([2, 'imported book', 1249])
  end

  it 'allows surrounding whitespace and preserves internal name spacing' do
    item = parser.parse(" \t1  music  CD  at  0.85  \r\n").first
    expect([item.name, item.unit_price_cents]).to eq(['music  CD', 85])
  end

  it 'skips blank lines and accepts an empty input' do
    expect(parser.parse("\n \t\n")).to eq([])
  end

  it 'accepts free products and a final line without a newline' do
    expect(parser.parse('1 sample at 0.00').first.unit_price_cents).to eq(0)
  end

  it 'rejects invalid UTF-8 before processing lines' do
    expect { parser.parse("1 b\xFF at 1.00\n".b) }.to raise_error(ArgumentError, /valid UTF-8/)
  end

  ['0 book at 12.49', '-1 book at 12.49', '1 at 12.49', '1 book 12.49',
   '1 book at -1.00', '1 book at 1.2', '1 book at 1.001', '1 book at abc',
   '1 book at 1.00 trailing', '1.5 book at 1.00'].each do |line|
    it "rejects #{line.inspect} with line context" do
      expect { parser.parse("\n#{line}\n") }.to raise_error(ArgumentError, "Invalid input on line 2: #{line.inspect}")
    end
  end
end
