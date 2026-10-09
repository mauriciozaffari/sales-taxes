# frozen_string_literal: true

module SalesTaxes
  # A priced snapshot, independent of subsequent changes to its input collection.
  class Basket
    attr_reader :lines

    def initialize(items, calculator: TaxCalculator.new)
      @lines = items.map { |item| Line.new(item, calculator:) }.freeze
      freeze
    end

    def tax_cents
      lines.sum(&:tax_cents)
    end

    def total_cents
      lines.sum(&:total_cents)
    end
  end
end
