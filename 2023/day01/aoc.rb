# frozen_string_literal: true

require "pathname"
require "json"

class AoC; end

class AoC::Puzzle
  class << self
    def call(input:, with_words: false)
      words = Hash[(1..9).map { |i| [i, i] }]

      if with_words
        words = words.merge(Hash[%w(one two three four five six seven eight nine).each_with_index.map { |n, i| [n, i+1] }])
      end

      words = words.transform_keys(&:to_s).transform_values(&:to_s)

      scan_for = /#{words.keys.join("|")}/

      input.each_line.inject(0) do |sum, line|
        line.strip!

        next if line.empty?

        numbers = line.size.times.map do |i|
          line[i..].match(scan_for)&.match(0)
        end.compact

        first, last = numbers[0], numbers[-1]

        sum + (words[first] + words[last]).to_i
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
  c.run_all_when_everything_filtered = true
  c.include AoC::SpecHelper
end

RSpec.describe AoC::Puzzle do
  context "with test input" do
    context "for part 1" do
      subject { described_class.call(input: input_test, with_words: false) }

      it { expect(subject).to eq(142) }
    end

    context "for part 2" do
      subject { described_class.call(input: Pathname.new(__dir__).join("input_test2.txt"), with_words: true) }

      it { expect(subject).to eq(281) }
    end
  end

  context "with input" do
    context "for part 1" do
      subject { described_class.call(input: input) }

      it { expect(subject).to eq(54951) }
    end

    context "for part 2" do
      subject { described_class.call(input: input, with_words: true) }

      it { expect(subject).to eq(55218) }
    end
  end
end
