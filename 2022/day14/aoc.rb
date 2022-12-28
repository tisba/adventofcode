# frozen_string_literal: true

require "pathname"
require "json"

class AoC; end

class AoC::Day14
  class Cave
    attr_reader :data, :min, :max, :height
    attr_accessor :bottomless

    def initialize(bottomless: true)
      @data = []
      @bottomless = bottomless
      @min, @max, @height = Float::INFINITY, -Float::INFINITY, 0
    end

    def set(x, y, what)
      @min = x if x < min
      @max = x if x > max
      @height = y if what == "#" && y > height

      @data[y] ||= []
      @data[y][x] = what
    end

    def get(x, y)
      return "#" if !bottomless && y == @height + 2
      return nil if @data[y].nil?

      @data[y][x]
    end

    def add_path((x1, y1), (x2, y2), what="#")
      if x1 == x2
        x = x1
        [y1, y2].max.downto([y1, y2].min).each do |y|
          set(x, y, what)
        end
      else
        y = y1
        [x1, x2].max.downto([x1, x2].min).each do |x|
          set(x, y, what)
        end
      end
    end

    def tick(x, y)
      return false if bottomless && (y >= height || x >= @max)
      return false if !bottomless && get(x, y) == "o"

      y += 1 while get(x, y).nil?

      ld, d, rd = get(x-1, y), get(x, y), get(x+1, y)

      if [ld, d, rd].none?(&:nil?)
        set(x, y-1, "o")

        true
      elsif ld.nil?
        tick(x-1, y)
      elsif rd.nil?
        tick(x+1, y)
      end
    end

    def remove_sand!
      @data.each_with_index do |row, y|
        row&.each_with_index do |what, x|
          @data[y][x] = nil if @data[y][x] == "o"
        end
      end
    end

    def print
      @data.each_with_index do |row, y|
        prefix = y.to_s.rjust(3) + " "

        if row.nil?
          puts prefix + "." * (@max-@min+1)
        else
          puts prefix + @min.upto(@max).map { |x| row[x] || "." }.join("")
        end
      end

      nil
    end
  end

  class << self
    def call(input:)
      cave = Cave.new

      input.each_line.map do |line|
        path = line.split(" -> ").map { |point| point.split(",").map(&:to_i) }

        path.reduce(path.shift) { |prev, current| cave.add_path(prev, current); current }
      end

      units_of_sand = 0
      units_of_sand += 1 while cave.tick(500, 0)

      cave.remove_sand!
      cave.bottomless = false

      units_of_sand_p2 = 0
      units_of_sand_p2 += 1 while cave.tick(500, 0)

      [units_of_sand, units_of_sand_p2]
    end
  end
end

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec"
end

require "rspec/autorun" if Pathname.new($0).basename.to_s != "rspec"

RSpec.describe AoC::Day14 do
  context "with test input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input_test.txt")) }

    it { expect(subject).to eq([24, 93]) }
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt")) }

    it { expect(subject).to eq([1061, 25055]) }
  end
end
