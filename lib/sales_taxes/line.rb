# frozen_string_literal: true

module SalesTaxes
  # An immutable item paired with its calculated line tax.
  class Line
    attr_reader :item, :tax_cents

    def initialize(item, calculator: TaxCalculator.new)
      @item = item
      @tax_cents = calculator.tax_cents(item)
      freeze
    end

    def total_cents
      (item.unit_price_cents * item.quantity) + tax_cents
    end
  end
end
