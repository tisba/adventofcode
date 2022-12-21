# frozen_string_literal: true

require "pathname"

class AoC; end

class AoC::Day09
  class << self
    def call(input:)
      motions = input.each_line.map do |line|
        direction, length = line.split(" ")

        vector = case direction
               when "U"  then [ 0, -1]
               when "R"  then [ 1,  0]
               when "D"  then [ 0,  1]
               when "L"  then [-1,  0]
               end

        [ vector, length.to_i ]
      end

      tail_visited = Set.new

      head = [0, 0]
      tail = [0, 0]

      tail_visited.add(tail)

      motions.each do |vector, length|
        length.times do
          head = move(head, vector)
          tail = update_tail(tail, head)

          tail_visited.add(tail)
        end
      end

      [tail_visited.count, nil]
    end

    def update_tail(tail, head)
      return tail if tail == head

      tx, ty = tail
      hx, hy = head

      if tx == hx && (ty - hy).abs > 1
        if ty > hy
          return move(tail, [0, -1]) # up
        else
          return move(tail, [0, 1]) # down
        end
      end

      if ty == hy && (tx - hx).abs > 1
        if tx > hx
          return move(tail, [-1, 0]) # left
        else
          return move(tail, [1, 0]) # right
        end
      end

      if ty != hy && tx != hx
        x = [hx - tx, hy - ty]
        return tail if x[0].abs < 2 && x[1].abs < 2

        x[0] -= x[0] <=> 0 if x[0].abs >= 2
        x[1] -= x[1] <=> 0 if x[1].abs >= 2

        return move(tail, x)
      end

      tail
    end

    def move(coord, vector)
      [
        coord[0] + vector[0],
        coord[1] + vector[1],
      ]
    end
  end
end

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec"
end

require "rspec/autorun"

RSpec.describe AoC::Day09 do
  context "with test input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input_test.txt")) }

    it { expect(subject).to eq([13, nil]) }
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt")) }

    it { expect(subject).to eq([6384, nil]) }
  end
end
