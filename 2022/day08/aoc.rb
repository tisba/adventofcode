# frozen_string_literal: true

require "pathname"

class AoC; end

class AoC::Day08
  class Tree < Struct.new(:height, :x, :y, :visible)
    include Comparable

    def <=>(other)
      self.height <=> other.height
    end
  end

  class << self
    def call(input:)
      map = input.each_line.each_with_index.map do |line, y|
        line.chomp.chars.each_with_index.map { |height, x| Tree.new(height.to_i, x, y) }
      end

      (map + map.transpose).each do |line|
        mark_visibility(line)
        mark_visibility(line.reverse)
      end

      [
        map.flatten.count(&:visible),
        map.flatten.map { |tree| scenic_score_for(map, tree) }.max,
      ]
    end

    def mark_visibility(line)
      line.reduce(-1) do |height, tree|
        tree.visible ||= tree.height > height

        [tree.height, height].max
      end
    end

    def scenic_score_for(map, tree)
      [
        (tree.y - 1).downto(0).map { |y| [ tree.x, y ] },                  # to up
        (tree.y + 1).upto(map.count-1).map { |y| [ tree.x, y ] },          # to down
        (tree.x - 1).downto(0).map { |x| [ x, tree.y ] },                  # to left
        (tree.x + 1).upto(map[tree.y].count-1).map { |x| [ x, tree.y ] },  # to right
      ].map do |coords|
        coords.reduce(0) do |score, (x, y)|
          if map[y][x] >= tree
            break score + 1
          else
            next score + 1
          end
        end
      end.reduce(&:*)
    end
  end
end

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec"
end

require "rspec/autorun" if Pathname.new($0).basename.to_s != "rspec"

RSpec.describe AoC::Day08 do
  context "with test input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input_test.txt")) }

    it { expect(subject).to eq([21, 8]) }
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt")) }

    it { expect(subject).to eq([1705, 371200]) }
  end
end
