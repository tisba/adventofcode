# frozen_string_literal: true

require "pathname"
require "json"

class AoC; end

class AoC::Day13
  class << self
    def call(input:, debug: false)
      packets = input.each_line.map do |line|
        next if line.strip.empty?

        JSON.parse(line)
      end.compact

      ok_pairs = packets.each_slice(2).to_a.each_with_index.reduce(0) do |acc, ((first, second), pair_index)|
        if compare(first, second) == -1
          acc += pair_index + 1
        else
          acc
        end
      end

      sorted = (packets + [[[2]], [[6]]]).sort { |a, b| compare(a, b) }

      decoder_key = sorted.each_with_index.reduce(1) do |acc, (packet, index)|
        if [[[2]], [[6]]].include?(packet)
          acc *= index + 1
        else
          acc
        end
      end

      [ok_pairs, decoder_key]
    end

    def compare(left, right)
      left = left.dup
      right = right.dup
      right = [right] if left.is_a?(Array) && right.is_a?(Integer)
      left = [left] if left.is_a?(Integer) && right.is_a?(Array)

      if left.is_a?(Integer) && right.is_a?(Integer)
        return left <=> right

      elsif left.is_a?(Array) && right.is_a?(Array)
        while true do
          ll = left.length
          rl = right.length
          left_item = left.shift
          right_item = right.shift

          result = compare(left_item, right_item)

          if result != 0
            return result
          elsif left_item.nil? || right_item.nil?
            return ll <=> rl
          end
        end

      else
        0
      end
    end
  end
end

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec"
end

require "rspec/autorun" if Pathname.new($0).basename.to_s != "rspec"

RSpec.describe AoC::Day13 do
  context "with test input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input_test.txt")) }

    it { expect(subject).to eq([13, 140]) }
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt")) }

    it { expect(subject).to eq([5808, 22713]) }
  end
end
