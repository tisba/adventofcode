# frozen_string_literal: true

require "pathname"
require "json"

class AoC; end

class AoC::Puzzle
  class << self
    def call(input:)
      input.each_line.reduce(0) do |sum, line|
        numbers = line.strip.each_char.select { |c| c.match?(/\d/) }
        sum += (numbers.first + numbers[-1]).to_i
      end
    end
  end
end

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec"
end

require "rspec/autorun" unless Pathname.new($0).basename.to_s == "rspec"

module AoC::SpecHelper
  def input = Pathname.new(__dir__).join("input.txt")
  def input_test = Pathname.new(__dir__).join("input_test.txt")
end

RSpec.configure do |c|
  c.filter_run focus: true
  c.include AoC::SpecHelper
end

RSpec.describe AoC::Puzzle do
  context "with test input", :focus do
    subject { described_class.call(input: input_test) }

    it { expect(subject).to eq(142) }
  end

  context "with input" do
    subject { described_class.call(input: input) }

    it { expect(subject).to eq(54951) }
  end
end
