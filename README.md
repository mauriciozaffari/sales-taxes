# Sales Taxes

A plain Ruby solution to [Subscribe's receipt exercise](https://gist.github.com/safplatform/792314da6b54346594432f30d5868f36). Application code has no external dependencies and does not use Rails. Gems are used only for testing and quality checks.

## Run

Install Ruby **4.0.7**. With [mise](https://mise.jdx.dev/), run `mise install` to install the pinned version.

From the project directory:

```sh
bundle install
bin/receipts examples/1.txt
```

To enter your own basket, run `bin/receipts` without arguments. Type one item per line, then press Enter on a blank line to print the receipt. Ctrl-D also finishes input:

```text
1 book at 12.49
1 music CD at 14.99
1 chocolate bar at 0.85
```

To print all three supplied baskets:

```sh
bin/receipts --examples
```

You can also supply several files (`bin/receipts examples/1.txt examples/2.txt`) or redirect a single basket from stdin (`bin/receipts < examples/1.txt`). Each file is a separate basket; receipts appear in argument order, separated by one blank line and ending with a newline. Piped input is read as one basket without prompts. An empty input produces a receipt with zero totals.

The executable can run without Bundler or installed QA gems: `ruby bin/receipts examples/1.txt`. The gemspec supplies optional packaging; building or installing the application as a gem is not required.

Input must be valid UTF-8 text. Input lines have the form `quantity product name at price`, with a positive integer quantity and a non-negative unit price containing exactly two decimal places. Blank lines are skipped; surrounding whitespace and CRLF line endings are accepted. Invalid input and file errors go to stderr with exit status 1. The application validates all baskets before printing, so an invalid later basket does not leave partial output.

## Design

The objects follow the path from input to output:

- `Parser` turns text into immutable `Item` objects.
- `Item` exposes `exempt?` and `imported?` based on its product name.
- `TaxCalculator` computes line tax using those predicates; one stateless calculator is reused across a basket.
- `Line` pairs an immutable item with its calculated tax and computes its total.
- `Basket` holds immutable priced lines and sums tax and totals.
- `Receipt` formats a basket as a string.
- `CLI` selects input and writes receipts or errors. `bin/receipts` only invokes it.

Calculation is separate from formatting and I/O. Composition lets each responsibility be tested independently without an inheritance hierarchy. A dedicated `Line` class makes the priced snapshot explicit, without a generated data structure.

`Basket.new(items, calculator: policy)` accepts any calculator exposing `tax_cents(item)`. The default implements the exercise's rules. To compare policies, build two baskets from the same items with different calculators and compare their totals. Each line retains its calculated tax, so an existing basket remains a snapshot.

### Exact money and rounding

Prices and final amounts are integer cents. Raw tax is a `Rational` so fractional cents remain exact until the required rounding step. Binary floating-point cannot represent every decimal exactly; integer and rational arithmetic avoids relying on approximate values at rounding boundaries. This is a correctness choice, not a claim that floats necessarily fail the supplied examples.

For each unit, each applicable tax is rounded **up to a multiple of five cents**. An amount already on a five-cent boundary stays unchanged. Rounded unit taxes are added, then multiplied by quantity.

For an imported chocolate box costing $11.25:

```text
Import tax per box: $11.25 × 5% = $0.5625 → $0.60
Three boxes:       3 × ($11.25 + $0.60) = $35.55
```

Rounding after multiplying the price by three would instead produce $35.45, which disagrees with the supplied output.

In cents, rounding is `Rational(price_cents * rate, 500).ceil * 5`: dividing by 500 combines the percentage denominator (100) and five-cent rounding increment (5).

### Assumptions

- Basic tax is 10%; imported goods additionally pay 5%, even when exempt from basic tax.
- Each rate is rounded separately. The examples also match rounding a combined rate, so they do not resolve this ambiguity. The wording describes rounding “for a tax rate of n%”; a dedicated test fixes this interpretation. At $10.03, an imported non-exempt item pays $1.05 + $0.55 = $1.60 rather than $1.55 under combined-rate rounding.
- Product categories are not supplied. The classifier recognizes the example vocabulary: whole words `book`/`books`, `chocolate`/`chocolates`, and `pill`/`pills`, ignoring case. Other names are taxable. This is not a general food or medical-product classifier.
- I considered a product-category registry, but free-text input would still need classification. For this exercise, a registry adds structure without resolving that assumption, so I kept a keyword matcher.
- `imported` is a case-insensitive whole word anywhere in the product name. Names are printed as supplied, apart from surrounding whitespace.
- Prices are unit prices. Each input line remains a separate receipt line; identical names are not merged.
- Zero-priced items are accepted; negative prices and zero quantities are rejected.

### Thread safety

Items, priced lines, and baskets are immutable. Calculation, parsing, and formatting keep no per-call shared mutable state. Concurrent tests exercise shared parser and formatter instances, while the default tax calculator is stateless. An injected calculator must provide its own thread-safety guarantees if shared across threads. This supports concurrent receipt calculation; it does not guarantee serialized writes to a shared output stream. A CLI instance and its I/O streams belong to one invocation.

## Tests and quality checks

```sh
bundle exec rspec
bin/ci
```

`bin/ci` stops on failure and runs RSpec, RuboCop (including performance and RSpec checks), Reek, Flay, and Bundler Audit. The same command runs in GitHub Actions. Bundler Audit updates its advisory database, which requires network access.

Tests include all three supplied receipts byte for byte, rounding boundaries, multiple quantities, imported exemptions, malformed input, whitespace, immutable snapshots, large amounts, CLI success/error paths, and concurrent calculations.

SimpleCov enforces **100% line and branch coverage of `lib/`**, including files that were never loaded. No branches are ignored. `.simplecov` enables `track_tests`; open `coverage/index.html` to inspect which examples executed a line. This helps identify incidental coverage, but executing a line is not proof that a test asserts its behavior. Focused assertions are still necessary. The tiny executable shim is exercised separately through command-line smoke tests.

The individual QA gems keep tooling separate from the application. For Rails projects, I package the QA toolchain in [rails-quality-assurance](https://github.com/develoz-com/rails-quality-assurance); this project uses the tools directly.
