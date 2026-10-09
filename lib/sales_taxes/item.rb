# frozen_string_literal: true

module SalesTaxes
  # An immutable purchase line. Prices are expressed in cents per unit.
  class Item
    EXEMPT_TERMS = %w[book books chocolate chocolates pill pills].freeze
    EXEMPT_PATTERN = /\b(?:#{Regexp.union(EXEMPT_TERMS).source})\b/i

    attr_reader :quantity, :name, :unit_price_cents

    def initialize(quantity:, name:, unit_price_cents:)
      raise ArgumentError, 'Quantity must be a positive integer' unless quantity.is_a?(Integer) && quantity.positive?
      raise ArgumentError, 'Name must be a non-empty string' unless name.is_a?(String) && !name.strip.empty?
      unless unit_price_cents.is_a?(Integer) && unit_price_cents >= 0
        raise ArgumentError, 'Unit price must be a non-negative integer in cents'
      end

      @quantity = quantity
      @name = name.dup.freeze
      @unit_price_cents = unit_price_cents
      freeze
    end

    def exempt?
      name.match?(EXEMPT_PATTERN)
    end

    def imported?
      name.match?(/\bimported\b/i)
    end
  end
end
