# frozen_string_literal: true

SimpleCov.start do
  add_filter '/spec/'
end

if ENV['CI'] == 'true' && ENV['COVERAGE'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
