# frozen_string_literal: true

require "pathname"
require "json"

class AoC; end

class AoC::Day15
  class Map
    attr_reader :data, :min, :max, :height, :ranges

    def initialize
      @min = Float::INFINITY
      @max = -Float::INFINITY
      @height = 0
      @data = {}
      @ranges = {}
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

    def ranges_overlap?(a, b)
      a.include?(b.begin) || b.include?(a.begin) || a.end + 1 == b.begin || b.end + 1 == a.begin
    end

    def merge_ranges(a, b)
      [a.begin, b.begin].min..[a.end, b.end].max
    end

    def merge_overlapping_ranges(overlapping_ranges)
      overlapping_ranges.sort_by(&:begin).inject([]) do |ranges, range|
        if !ranges.empty? && ranges_overlap?(ranges.last, range)
          ranges[0...-1].push(merge_ranges(ranges.last, range))
        else
          ranges.push(range)
        end
      end
    end

    def record_ranges(x, y, distance, limit: 20)
      limit_begin = limit.begin
      limit_end = limit.end

      xa = x - distance
      xb = x + distance

      # roll limit check into ranging...
      (-distance).upto(+distance).each do |dy|
        current_y = y + dy

        next if current_y < limit_begin || current_y > limit_end

        dy_abs = dy.abs

        b = (xa + dy_abs)
        e = (xb - dy_abs)

        @ranges[current_y] ||= []
        @ranges[current_y].push(b..e)
      end
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

      bar = 0
      input.each_line do |line|
        bar += 1
        # return if bar >= 3
        STDOUT.write "."

        sensor_x, sensor_y, beacon_x, beacon_y = line.match(/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/).captures.map(&:to_i)

        distance = (sensor_x - beacon_x).abs + (sensor_y - beacon_y).abs

        if debug
          map.set(sensor_x, sensor_y, "S")
          map.set(beacon_x, beacon_y, "B")
          # map.set_around(sensor_x, sensor_y, distance, only_y: line_to_count)
          map.set_around(sensor_x, sensor_y, distance)
        end

        # map.record_ranges(sensor_x, sensor_y, distance, limit: 0..max_xy)
        map.record_ranges(sensor_x, sensor_y, distance, limit: -Float::INFINITY..Float::INFINITY)
      end

      if debug
        puts
        puts "min: #{map.min}, max: #{map.max}"
        map.print
        puts
      end

      tuning_freq = 0
      map.ranges.keys.sort.each do |key|
        next if key < 0 || key > max_xy

        r = map.ranges[key]
        x = map.merge_overlapping_ranges(r)

        if x.length == 2
          tuning_freq = (x.first.end + 1) * 4_000_000 + key
          puts "#{key.to_s.rjust(3)}: #{x.inspect}" if debug
        end
      end

      [
        map.merge_overlapping_ranges(map.ranges[line_to_count]).sum { |range| range.end - range.begin },
        tuning_freq,
      ]
    end
  end
end

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec"
  gem "ruby-prof"
end

require "rspec/autorun" if Pathname.new($0).basename.to_s != "rspec"

RSpec.describe AoC::Day15 do
  context "with test input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input_test.txt"), line_to_count: 10, max_xy: 20) }

    it { expect(subject).to eq([26, 56000011]) }
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt"), line_to_count: 2_000_000, max_xy: 4_000_000) }

    it { expect(subject).to eq([4724228, 13622251246513]) }
  end
end
