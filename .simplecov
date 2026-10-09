# frozen_string_literal: true

SimpleCov.configure do
  enable_coverage :line
  enable_coverage :branch
  minimum_coverage line: 100, branch: 100
  track_tests
  cover 'lib/**/*.rb'
end
