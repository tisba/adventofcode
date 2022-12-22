# frozen_string_literal: true

require "pathname"

class AoC; end

class AoC::Day10
  class << self
    def call(input:)
      x = 1
      c = 1
      probes = []
      crt_rows = []
      current_row = []

      cycle = -> () do
        probes << c * x if (c-20) % 40 == 0

        if current_row.length == 40
          crt_rows << current_row
          current_row = []
        end

        col = (c - 1) % 40
        lit = ((x-1)..(x+1)).include?(col)
        current_row << (lit ? "#" : ".")

        c += 1
      end

      input.each_line do |line|
        command, arg = line.split

        if command == "noop"
          cycle.call
        end

        if command == "addx"
          cycle.call
          cycle.call

          x += arg.to_i
        end
      end

      cycle.call

      [
        probes.sum,
        crt_rows.map { |row| row.join("") }
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

RSpec.describe AoC::Day10 do
  context "with test input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input_test.txt")) }

    let(:screen_rows) do
      %w(
      ##..##..##..##..##..##..##..##..##..##..
      ###...###...###...###...###...###...###.
      ####....####....####....####....####....
      #####.....#####.....#####.....#####.....
      ######......######......######......####
      #######.......#######.......#######.....
      )
    end

    it { expect(subject).to eq([13140, screen_rows]) }
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt")) }

    let(:screen_rows) do
      %w(
      ####.#....###..#....####..##..####.#....
      #....#....#..#.#.......#.#..#....#.#....
      ###..#....#..#.#......#..#......#..#....
      #....#....###..#.....#...#.##..#...#....
      #....#....#....#....#....#..#.#....#....
      ####.####.#....####.####..###.####.####.
      )
    end

    it { expect(subject).to eq([14780, screen_rows]) }
  end
end
