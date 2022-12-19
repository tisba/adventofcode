# frozen_string_literal: true

require "pathname"

class AoC; end

class AoC::Day03
  class << self
    PRIOS = Hash[(("a".."z").to_a + ("A".."Z").to_a).zip((1..52).to_a)]

    def call(input:)
      sum_common = 0
      sum_batch = 0
      group = []

      input.each_line do |line|
        items = line.chomp.chars

        total = items.count
        a = items[0..(total/2)-1]
        b = items[(total/2)..total]

        group << items

        if group.length == 3
          sum_batch += PRIOS[group.reduce(&:&).first]
          group = []
        end

        sum_common += PRIOS[(a & b).first]
      end

      [sum_common, sum_batch]
    end
  end
end

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec"
end

require "rspec/autorun"

RSpec.describe AoC::Day03 do
  context "with test input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input_test.txt")) }

    it { expect(subject).to eq([157, 70]) }
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt")) }

    it { expect(subject).to eq([7826, 2577]) }
  end
end
