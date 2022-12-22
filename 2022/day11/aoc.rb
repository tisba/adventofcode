# frozen_string_literal: true

require "pathname"

class AoC; end

class AoC::Day11
  class Monkey < Struct.new(:id, :items, :operation, :divisibility_test, :action, :inspections)
    def initialize(id)
      super

      self.action ||= {}
      self.inspections = 0
    end

    def turn(worry_reduction, lcm)
      while worry = self.items.shift do
        self.inspections += 1

        worry = operation.call(worry)
        worry /= 3 if worry_reduction

        div = worry % divisibility_test == 0

        self.action[div].items.push(worry % lcm)
      end
    end
  end

  class << self
    def call(input:, rounds:, worry_reduction:)
      monkey = nil
      lcm_operands = []
      monkeys = input.each_line.each_with_object([]) do |line, monkeys|
        case line
        when /Monkey (\d+)/
          monkeys << monkey if monkey
          monkey = Monkey.new($1.to_i)
        when /Starting items: (.+)/
          monkey.items = $1.split(", ").map(&:to_i)
        when /Operation: new = old (.?) (.+)/
          lcm_operands << $2.to_i
          monkey.operation = Kernel.eval("-> (old) { old #{$1} #{$2} }")
        when /Test: divisible by (\d+)/
          lcm_operands << $1.to_i
          monkey.divisibility_test = $1.to_i
        when /If (true|false): throw to monkey (\d+)/
          monkey.action[$1 == "true"] = $2.to_i
        end
      end

      monkeys << monkey

      # build monkey index
      monkeys.each do |monkey|
        monkey.action[true] = monkeys.find { |m| m.id == monkey.action[true] }
        monkey.action[false] = monkeys.find { |m| m.id == monkey.action[false] }
      end

      lcm = lcm_operands.filter(&:positive?).reduce(:lcm)

      rounds.times do |i|
        monkeys.each { |m| m.turn(worry_reduction, lcm) }
      end

      monkeys.map(&:inspections).max(2).reduce(:*)
    end
  end
end

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec"
end

require "rspec/autorun"

RSpec.describe AoC::Day11 do
  context "with test input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input_test.txt"), rounds: rounds, worry_reduction: worry_reduction) }

    context "for part one" do
      let(:rounds) { 20 }
      let(:worry_reduction) { true }

      it { expect(subject).to eq(10605) }
    end

    context "for part two" do
      let(:rounds) { 10_000 }
      let(:worry_reduction) { false }

      it { expect(subject).to eq(2713310158) }
    end
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt"), rounds: rounds, worry_reduction: worry_reduction) }

    context "for part one" do
      let(:rounds) { 20 }
      let(:worry_reduction) { true }

      it { expect(subject).to eq(58794) }
    end

    context "for part two" do
      let(:rounds) { 10_000 }
      let(:worry_reduction) { false }

      it { expect(subject).to eq(20151213744) }
    end
  end
end
