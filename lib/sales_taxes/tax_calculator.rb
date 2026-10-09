# frozen_string_literal: true

module SalesTaxes
  # Applies each rate to a unit price before multiplying by quantity.
  class TaxCalculator
    def tax_cents(item)
      unit_tax(item) * item.quantity
    end

    def self.rates(item)
      rates = []
      rates << 10 unless item.exempt?
      rates << 5 if item.imported?
      rates
    end

    private

    def unit_tax(item)
      self.class.rates(item).sum { |rate| rounded_tax(item.unit_price_cents, rate) }
    end

    def rounded_tax(price_cents, rate)
      Rational(price_cents * rate, 500).ceil * 5
    end
  end
end
