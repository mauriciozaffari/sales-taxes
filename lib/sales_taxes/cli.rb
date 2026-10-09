# frozen_string_literal: true

module SalesTaxes
  # Owns input selection and reports user-facing errors with a nonzero status.
  class CLI
    EXAMPLES = Dir[File.expand_path('../../examples/*.txt', __dir__)].map(&:freeze).freeze

    def initialize(input: $stdin, output: $stdout, error: $stderr)
      @receipt = Receipt.new
      @input = input
      @output = output
      @error = error
    end

    def run(arguments)
      receipts = sources(arguments).map { |source| render(source) }
      write_receipts(receipts)
    rescue ArgumentError, SystemCallError => error
      report_error(error)
    end

    def self.read_files(paths)
      paths.map { |path| File.read(path) }
    end

    private

    def report_error(exception)
      @error.puts(exception.message)
      1
    end

    def write_receipts(receipts)
      @output.write(receipts.join("\n"))
      0
    end

    def render(source)
      @receipt.render(Basket.new(Parser.new.parse(source)))
    end

    def sources(arguments)
      case arguments
      in []
        [read_input]
      in ['--examples']
        CLI.read_files(EXAMPLES)
      else
        CLI.read_files(arguments)
      end
    end

    def read_input
      return @input.read unless @input.tty?

      @error.puts('Enter items (e.g. 1 book at 12.49). Finish with a blank line or Ctrl-D.')
      @input.each_line.take_while { |line| !line.strip.empty? }.join
    end
  end
end
