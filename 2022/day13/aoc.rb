# frozen_string_literal: true

require "pathname"
require "json"

class AoC; end

class AoC::Day13
  class << self
    def call(input:, debug: false)
      ok_pairs = 0
      input.each_line("\n\n").each_with_index do |block, pair_index|
        first, second = block.split("\n").map { |b| JSON.parse(b) }

        puts "Index: #{pair_index}"
        puts "1st: #{first.inspect}"
        puts "2nd: #{second.inspect}"

        result = compare(first, second)

        if result
          puts "  OK!"
          ok_pairs += pair_index + 1
        else
          puts "  not ok"
        end

        puts
        puts
      end

      [ok_pairs, nil]
    end

    def compare(left, right)
      puts "Compare: #{left.inspect} - #{right.inspect}"
      right = [right] if left.is_a?(Array) && right.is_a?(Integer)
      left = [left] if left.is_a?(Integer) && right.is_a?(Array)

      if left.is_a?(Integer) && right.is_a?(Integer)
        if left < right
          true
        elsif left > right
          false
        else
          nil
        end
      elsif left.is_a?(Array) && right.is_a?(Array)
        while true do
          left_item = left.shift
          right_item = right.shift

          result = compare(left_item, right_item)

          return result unless result.nil?

          if left_item.nil? && right_item.nil?
            return nil
          elsif left_item.nil?
            return true
          elsif right_item.nil?
            return false
          end
        end
      else
        nil
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

    it { expect(subject).to eq([13, nil]) }
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt")) }

    it { expect(subject).to eq([5808, nil]) }
  end
end
