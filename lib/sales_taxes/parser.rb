# frozen_string_literal: true

module SalesTaxes
  # Converts the challenge's line-oriented input into purchase items.
  class Parser
    LINE = /\A\s*(?<quantity>[1-9]\d*)\s+(?<name>\S(?:.*\S)?)\s+at\s+(?<whole>\d+)\.(?<fraction>\d{2})\s*\z/

    def parse(input)
      self.class.validate_encoding(input).each_line.with_index(1).filter_map do |line, number|
        parse_line(line, number) unless line.strip.empty?
      end
    end

    def self.validate_encoding(input)
      text = input.dup.force_encoding(Encoding::UTF_8)
      raise ArgumentError, 'Input must contain valid UTF-8 text' unless text.valid_encoding?

      text
    end

    private

    def parse_line(line, number)
      match = LINE.match(line)
      raise ArgumentError, "Invalid input on line #{number}: #{line.strip.inspect}" unless match

      quantity, name, whole, fraction = match.values_at(:quantity, :name, :whole, :fraction)
      Item.new(quantity: quantity.to_i, name:, unit_price_cents: (whole.to_i * 100) + fraction.to_i)
    end
  end
end
