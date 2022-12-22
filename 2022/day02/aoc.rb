# frozen_string_literal: true

require "pathname"

class AoC; end

class AoC::Day02
  DEFEATS = {
    rock: :scissors,
    scissors: :paper,
    paper: :rock,
  }

  class << self
    def call(input:)
      to_shape = {
        a: :rock,
        x: :rock,
        b: :paper,
        y: :paper,
        c: :scissors,
        z: :scissors,
      }

      points = {
        rock: 1,
        paper: 2,
        scissors: 3,
      }

      total_a = 0
      total_b = 0
      input.each_line do |line|
        other, mine_or_outcome = line.split.map(&:downcase).map(&:to_sym)

        total_a += play(to_shape[mine_or_outcome], to_shape[other]) + points[to_shape[mine_or_outcome]]

        my_shape = shape_for_outcome(mine_or_outcome, other: to_shape[other])
        total_b += play(my_shape, to_shape[other]) + points[my_shape]
      end

      [total_a, total_b]
    end

    def shape_for_outcome(outcome, other:)
      case outcome
      when :x then DEFEATS[other]
      when :y then other
      when :z then DEFEATS.invert[other]
      end
    end

    def play(mine, other)
      case other
      when mine then 3
      when DEFEATS[mine] then 6
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

RSpec.describe AoC::Day02 do
  context "with test input" do
    subject { AoC::Day02.call(input: Pathname.new(__dir__).join("input_test.txt")) }

    it { expect(subject).to eq([15, 12]) }
  end

  context "with input" do
    subject { AoC::Day02.call(input: Pathname.new(__dir__).join("input.txt")) }

    it { expect(subject).to eq([15422, 15442]) }
  end
end
