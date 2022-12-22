# frozen_string_literal: true

require "pathname"

class AoC; end

class AoC::Day09
  class << self
    def call(input:, segment_count:)
      motions = input.each_line.map do |line|
        direction, length = line.split(" ")

        vector = case direction
               when "U" then [ 0, -1]
               when "R" then [ 1,  0]
               when "D" then [ 0,  1]
               when "L" then [-1,  0]
               end

        [ vector, length.to_i ]
      end

      tail_visited = Set.new

      head = [0, 4]
      segments = [[0, 4]] * segment_count

      tail_visited.add(segments.last)

      motions.each do |vector, length|
        length.times do
          head = move(head, vector)
          segments = segments.each_with_object([head]) do |segment, acc|
            acc << update_segment(segment, acc.last)
          end
          segments.shift

          tail_visited.add(segments.last)
        end
      end

      tail_visited.count
    end

    def update_segment(segment, prev_segment)
      dy = prev_segment[1] - segment[1]
      dx = prev_segment[0] - segment[0]

      # no movement, segment is adjacent to previous
      # segment ("head")
      if   (dx == 0 && dy.abs <= 1) \
        || (dy == 0 && dx.abs <= 1) \
        || (dx.abs < 2 && dy.abs < 2)
        segment

      else
        # move into the direction of the deltas
        move(segment, [ dx <=> 0, dy <=> 0 ])
      end
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

require "rspec/autorun" if Pathname.new($0).basename.to_s != "rspec"

RSpec.describe AoC::Day09 do
  context "with test input" do
    subject { described_class.call(input: input, segment_count: segment_count) }

    context "for part one" do
      let(:segment_count) { 1 }

      let(:input) do
        <<~EOS
        R 4
        U 4
        L 3
        D 1
        R 4
        D 1
        L 5
        R 2
        EOS
      end

      it { expect(subject).to eq(13) }
    end

    context "for part two" do
      let(:segment_count) { 9 }

      let(:input) do
        <<~EOS
        R 5
        U 8
        L 8
        D 3
        R 17
        D 10
        L 25
        U 20
        EOS
      end

      it { expect(subject).to eq(36) }
    end
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt"), segment_count: segment_count) }

    context "for part one" do
      let(:segment_count) { 1 }

      it { expect(subject).to eq(6384) }
    end

    context "for part two" do
      let(:segment_count) { 9 }

      it { expect(subject).to eq(2734) }
    end
  end
end
