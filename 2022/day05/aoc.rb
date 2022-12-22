# frozen_string_literal: true

require "pathname"

class AoC; end

class AoC::Day05
  class << self
    def call(input:)
      buffer = []
      instructions = false
      stacks_a = []
      stacks_b = []
      input.each_line do |line|
        if instructions
          next if line.chomp.empty?

          _match, n, source, target = line.match(/move (\d+) from (\d+) to (\d+)/).to_a.map(&:to_i)

          n.times do
            crate = stacks_a[source-1].shift
            stacks_a[target-1].unshift(crate)
          end

          crates = stacks_b[source-1].shift(n)
          stacks_b[target-1].unshift(*crates)

        elsif line.strip.start_with?("1")
          stack_count = line.split.compact.map(&:to_i).max

          stacks_a = Array.new(stack_count) { [] }
          stacks_b = Array.new(stack_count) { [] }

          buffer.each do |l|
            l.scan(/\s{3}|\[(\w)\] ?/).to_a.each_with_index do |(e), idx|
              next if e.nil?

              stacks_a[idx].push(e)
              stacks_b[idx].push(e)
            end
          end

          instructions = true
          next
        else
          buffer << line
        end
      end

      [ stacks_a, stacks_b ].map { |s| s.map(&:shift).join("") }
    end
  end
end

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec"
end

require "rspec/autorun" if Pathname.new($0).basename.to_s != "rspec"

RSpec.describe AoC::Day05 do
  context "with test input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input_test.txt")) }

    it { expect(subject).to eq(["CMZ", "MCD"]) }
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt")) }

    it { expect(subject).to eq(["WCZTHTMPS", "BLSGJSDTS"]) }
  end
end
