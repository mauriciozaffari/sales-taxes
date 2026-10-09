# frozen_string_literal: true

RSpec.describe SalesTaxes do
  def render_example(number, parser: SalesTaxes::Parser.new, receipt: SalesTaxes::Receipt.new)
    receipt.render(SalesTaxes::Basket.new(parser.parse(File.read("examples/#{number}.txt"))))
  end

  (1..3).each do |number|
    it "matches supplied output #{number} byte for byte" do
      expect(render_example(number)).to eq(File.read("spec/fixtures/#{number}.txt"))
    end
  end

  def concurrent_results(parser, receipt)
    Array.new(8) do
      Thread.new { Array.new(10) { (1..3).map { |number| render_example(number, parser:, receipt:) } } }
    end.map(&:value)
  end

  it 'processes baskets concurrently using shared stateless collaborators' do
    parser = SalesTaxes::Parser.new
    receipt = SalesTaxes::Receipt.new
    expected = (1..3).map { |number| File.read("spec/fixtures/#{number}.txt") }
    expect(concurrent_results(parser, receipt)).to all(eq(Array.new(10, expected)))
  end
end
