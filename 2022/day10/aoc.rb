# frozen_string_literal: true

require "pathname"

class AoC; end

class AoC::Day10
  class << self
    def call(input:)
      x = 1
      c = 0
      probe = []
      input.each_line do |line|
        command, arg = line.split

        if command == "noop"
          c += 1
          probe << [c, x] if (c-20) % 40 == 0
        end

        if command == "addx"
          c += 1
          probe << [c, x] if (c-20) % 40 == 0
          c += 1
          probe << [c, x] if (c-20) % 40 == 0

          x += arg.to_i
        end
      end

      [ probe.sum { |(c, x)| c * x }, nil ]
    end
  end
end

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec"
end

require "rspec/autorun"

RSpec.describe AoC::Day10 do
  context "with test input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input_test.txt")) }

    it { expect(subject).to eq([13140, nil]) }
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt")) }

    it { expect(subject).to eq([nil, nil]) }
  end
end
