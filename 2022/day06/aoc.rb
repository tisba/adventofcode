# frozen_string_literal: true

require "pathname"

class AoC; end

class AoC::Day06
  class << self
    def call(input:, uniq_chars:)
      buffer = []

      input.each_char.each_with_index do |char, idx|
        buffer << char

        next unless buffer.length == uniq_chars

        if buffer.uniq.length == uniq_chars
          return idx + 1
        end

        buffer.shift
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

RSpec.describe AoC::Day06 do
  context "with test input" do
    subject { described_class }

    describe "part one" do
      {
        "mjqjpqmgbljsphdztnvjfqwrcgsmlb" => 7,
        "bvwbjplbgvbhsrlpgdmjqwftvncz" => 5,
        "nppdvjthqldpwncqszvftbrmjlhg" => 6,
        "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg" => 10,
        "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw" => 11,
      }.each do |input, output|
        it do
          expect(subject.call(input: input, uniq_chars: 4)).to eq(output)
        end
      end
    end

    describe "part two" do
      {
        "mjqjpqmgbljsphdztnvjfqwrcgsmlb" => 19,
        "bvwbjplbgvbhsrlpgdmjqwftvncz" => 23,
        "nppdvjthqldpwncqszvftbrmjlhg" => 23,
        "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg" => 29,
        "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw" => 26,
      }.each do |input, output|
        it do
          expect(subject.call(input: input, uniq_chars: 14)).to eq(output)
        end
      end
    end
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt").read, uniq_chars: uniq_chars) }

    describe "part one" do
      let(:uniq_chars) { 4 }

      it { expect(subject).to eq(1238) }
    end

    describe "part two" do
      let(:uniq_chars) { 14 }

      it { expect(subject).to eq(3037) }
    end
  end
end
