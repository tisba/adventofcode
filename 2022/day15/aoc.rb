# frozen_string_literal: true

require "pathname"
require "json"

class AoC; end

class AoC::Day15
  class Map
    attr_reader :data, :min, :max, :height

    def initialize
      @min = Float::INFINITY
      @max = -Float::INFINITY
      @height = 0
      @data = {}
    end

    def set(x, y, what, if_empty: false)
      @min = x if x < min
      @max = x if x > max
      @height = y if y > height

      @data[y] ||= {}

      return if if_empty && @data[y][x]

      @data[y][x] = what
    end

    def get(x, y)
      return nil if @data[y].nil?

      @data[y][x]
    end

    def set_around(x, y, distance, only_y: nil)
      unless only_y
        (-distance).upto(distance).each do |dy|
          next if y+dy == only_y

          (-distance + dy).upto(distance - dy).each do |dx|
            next if (dx.abs + dy.abs) > distance

            set(x+dx, y+dy, "#", if_empty: true)
          end
        end

        return
      end

      dy = only_y-y
      (-distance + dy.abs).upto(distance - dy.abs).each do |dx|
        set(x+dx, y+dy, "#", if_empty: true)
      end
    end

    def print
      puts "    " + (@min..@max).map { |x| r = x % 5; r == 0 ? "X" : " " }.join("")
      0.upto(height) do |y|
        row = @data[y]

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
    def call(input:, line_to_count:, max_xy:, debug: false)
      map = Map.new
      puts if debug
      input.each_line do |line|
        STDOUT.write "." if debug

        sensor_x, sensor_y, beacon_x, beacon_y = line.match(/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/).captures.map(&:to_i)

        map.set(sensor_x, sensor_y, "S")
        map.set(beacon_x, beacon_y, "B")

        distance = (sensor_x - beacon_x).abs + (sensor_y - beacon_y).abs

        map.set_around(sensor_x, sensor_y, distance, only_y: line_to_count)
      end

      if debug
        puts
        map.print
        puts
      end

      [
        (map.min).upto(map.max).count { |x| map.get(x, line_to_count) == "#" },
        nil,
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

RSpec.describe AoC::Day15 do
  context "with test input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input_test.txt"), line_to_count: 10, max_xy: 20) }

    it { expect(subject).to eq([26, nil]) }
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt"), line_to_count: 2_000_000, max_xy: 4_000_000) }

    it { expect(subject).to eq([4724228, nil]) }
  end
end
