# frozen_string_literal: true

RSpec.describe SalesTaxes::CLI do
  let(:input) { StringIO.new('1 book at 12.49') }
  let(:output) { StringIO.new }
  let(:error) { StringIO.new }
  let(:cli) { described_class.new(input:, output:, error:) }

  it 'reads piped input when no filenames are supplied', :aggregate_failures do
    expect(cli.run([])).to eq(0)
    expect(output.string).to eq("1 book: 12.49\nSales Taxes: 0.00\nTotal: 12.49\n")
    expect(error.string).to be_empty
  end

  it 'renders an empty piped basket', :aggregate_failures do
    input.string = ''
    expect(cli.run([])).to eq(0)
    expect(output.string).to eq("Sales Taxes: 0.00\nTotal: 0.00\n")
  end

  it 'renders the supplied examples on request', :aggregate_failures do
    expected = (1..3).map { |number| File.read("spec/fixtures/#{number}.txt") }.join("\n")
    expect(cli.run(['--examples'])).to eq(0)
    expect(output.string).to eq(expected)
    expect(error.string).to be_empty
  end

  it 'prompts for interactive input and stops at a blank line', :aggregate_failures do
    allow(input).to receive(:tty?).and_return(true)
    input.string = "1 book at 12.49\n \t\ninvalid trailing input\n"
    expect(cli.run([])).to eq(0)
    expect(output.string).to eq("1 book: 12.49\nSales Taxes: 0.00\nTotal: 12.49\n")
    expect(error.string).to include('Finish with a blank line or Ctrl-D')
  end

  it 'also finishes interactive input at EOF', :aggregate_failures do
    allow(input).to receive(:tty?).and_return(true)
    expect(cli.run([])).to eq(0)
    expect(output.string).to include('1 book: 12.49')
  end

  it 'accepts an empty interactive basket', :aggregate_failures do
    allow(input).to receive(:tty?).and_return(true)
    input.string = "\n"
    expect(cli.run([])).to eq(0)
    expect(output.string).to eq("Sales Taxes: 0.00\nTotal: 0.00\n")
  end

  it 'reads multiple files in argument order, separated by a blank line', :aggregate_failures do
    expect(cli.run(%w[examples/2.txt examples/1.txt])).to eq(0)
    expect(output.string).to eq("#{File.read('spec/fixtures/2.txt')}\n#{File.read('spec/fixtures/1.txt')}")
  end

  it 'reports malformed input without writing a partial receipt', :aggregate_failures do
    input.string = 'bad input'
    expect(cli.run([])).to eq(1)
    expect(error.string).to include('Invalid input on line 1')
    expect(output.string).to be_empty
  end

  it 'reports missing files without a backtrace', :aggregate_failures do
    expect(cli.run(['examples/missing.txt'])).to eq(1)
    expect(error.string).to include('missing.txt')
    expect(output.string).to be_empty
  end

  it 'does not output earlier receipts if a later file is invalid', :aggregate_failures do
    Tempfile.create do |file|
      file.write('invalid').then { file.flush }
      expect(cli.run(['examples/1.txt', file.path])).to eq(1)
      expect(output.string).to be_empty
    end
  end
end
