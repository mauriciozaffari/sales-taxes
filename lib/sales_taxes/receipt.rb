# frozen_string_literal: true

module SalesTaxes
  # Renders a receipt without writing to shared output streams.
  class Receipt
    def render(basket)
      rows = basket.lines.map { |line| render_line(line) }
      rows << "Sales Taxes: #{money(basket.tax_cents)}"
      rows << "Total: #{money(basket.total_cents)}"
      "#{rows.join("\n")}\n"
    end

    private

    def render_line(line)
      item = line.item
      format('%<quantity>d %<name>s: %<price>s',
             quantity: item.quantity, name: item.name, price: money(line.total_cents))
    end

    def money(cents)
      whole, fraction = cents.divmod(100)
      format('%<whole>d.%<fraction>02d', whole:, fraction:)
    end
  end
end
