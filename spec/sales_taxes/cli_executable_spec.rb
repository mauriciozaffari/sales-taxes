# frozen_string_literal: true

require 'open3'
require 'rbconfig'

RSpec.describe SalesTaxes::CLI do
  def execute(*, input: '')
    Open3.capture3(RbConfig.ruby, '--disable-gems', 'bin/receipts', *, stdin_data: input)
  end

  it 'runs the application without loading any gems' do
    output, error, status = execute('examples/1.txt')
    expect([output, error, status.exitstatus]).to eq([File.read('spec/fixtures/1.txt'), '', 0])
  end

  it 'reads input through an actual pipe' do
    output, error, status = execute(input: File.read('examples/3.txt'))
    expect([output, error, status.exitstatus]).to eq([File.read('spec/fixtures/3.txt'), '', 0])
  end

  it 'rejects invalid bytes without a backtrace or partial receipt' do
    output, error, status = execute(input: "1 b\xFF at 1.00\n".b)
    expect([output, error, status.exitstatus]).to eq(['', "Input must contain valid UTF-8 text\n", 1])
  end

  it 'returns a nonzero status for missing input files', :aggregate_failures do
    output, error, status = execute('missing.txt')
    expect(status.exitstatus).to eq(1)
    expect(output).to be_empty
    expect(error).to include('missing.txt')
  end
end
