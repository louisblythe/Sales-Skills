# frozen_string_literal: true

require 'bigdecimal'
require 'csv'
require 'date'

REVIEW = File.expand_path('../examples/weekly-pipeline-review', __dir__)
REQUIRED = %w[deal owner stage amount currency close_date forecast_category next_step].freeze
CATEGORIES = { 'commit' => 'Open commit', 'upside' => 'Open upside', '' => 'Open unclassified' }.freeze

def review(csv)
  rows = CSV.parse(csv, headers: true)
  missing = REQUIRED - rows.headers
  raise ArgumentError, "Missing columns: #{missing.join(', ')}" unless missing.empty?
  raise ArgumentError, 'No deal rows' if rows.empty?

  totals = Hash.new { |currencies, currency| currencies[currency] = Hash.new(0) }
  warnings = []
  rows.each_with_index do |row, index|
    blank = (REQUIRED - ['forecast_category']).find { |field| row[field].to_s.strip.empty? }
    raise ArgumentError, "Row #{index + 2}: missing #{blank}" if blank
    amount = row['amount']
    raise ArgumentError, "Row #{index + 2}: invalid amount" unless amount.match?(/\A\d+(?:\.\d{1,2})?\z/)
    Date.iso8601(row['close_date'])
    category = row['forecast_category'].to_s.strip.downcase
    warnings << "#{row['deal']}: missing forecast category" if category.empty?
    label = CATEGORIES.fetch(category) { raise ArgumentError, "Unknown forecast category: #{category}" }
    money = totals[row['currency'].strip]
    money[label] += BigDecimal(amount)
    money['Open pipeline'] += BigDecimal(amount)
  end
  [totals, warnings]
end

def check_totals(actual, expected)
  labels = CATEGORIES.values + ['Open pipeline']
  unless expected.keys.sort == labels.sort && labels.all? { |label| actual[label] == expected[label] }
    raise ArgumentError, 'Worked totals do not reconcile to the sample CSV'
  end
end

def expect_error(message)
  yield
  abort "Expected failure: #{message}"
rescue ArgumentError => e
  raise unless e.message.include?(message)
end

sample = File.read(File.join(REVIEW, 'sample.csv'))
totals, warnings = review(sample)
output = File.read(File.join(REVIEW, 'README.md'))
report = output.split("## Sales Reporting\n", 2).fetch(1)
expected = report.scan(/^\| (Open [^|]+?) \| (\d+(?:\.\d+)?) \|$/).to_h.transform_values { |amount| BigDecimal(amount) }
raise 'Expected an AUD-only sample' unless totals.keys == ['AUD']
check_totals(totals.fetch('AUD'), expected)
raise 'Expected a missing forecast category warning' unless warnings == ['Banksia Retail: missing forecast category']

expect_error('Missing columns: owner') { review(sample.sub('deal,owner,', 'deal,')) }
expect_error('missing owner') { review(sample.sub('Harbour Health,Mia,', 'Harbour Health,,')) }
expect_error('invalid amount') { review(sample.sub(',40000,', ',oops,')) }
expect_error('do not reconcile') { check_totals(totals.fetch('AUD'), expected.merge('Open pipeline' => 1)) }
puts 'Validated the pipeline example totals and missing-field checks.'
