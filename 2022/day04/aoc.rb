# frozen_string_literal: true

require "pathname"

class AoC; end

class AoC::Day04
  class << self
    def call(input:)
      count_cover = 0
      count_overlap = 0

      input.each_line do |line|
        a, b = line.split(",")

        range_a = Range.new(*a.split("-").map(&:to_i))
        range_b = Range.new(*b.split("-").map(&:to_i))

        count_cover += 1 if range_a.cover?(range_b) || range_b.cover?(range_a)
        count_overlap += 1 if overlaps?(range_a, range_b)
      end

      [count_cover, count_overlap]
    end

    def overlaps?(a, b)
      a.begin == b.begin || b.cover?(a.begin) || a.cover?(b.begin)
    end
  end
end

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec"
end

require "rspec/autorun"

RSpec.describe AoC::Day04 do
  context "with test input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input_test.txt")) }

    it { expect(subject).to eq([2, 4]) }
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt")) }

    it { expect(subject).to eq([453, 919]) }
  end
end
