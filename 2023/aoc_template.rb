# frozen_string_literal: true

require "pathname"
require "json"

class AoC; end

class AoC::Puzzle
  class << self
    def call(input:)
      # implementation starts here…
    end
  end
end

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec"
end

require "rspec/autorun" unless Pathname.new($0).basename.to_s == "rspec"

module AoC::SpecHelper
  def input = Pathname.new(__dir__).join("input.txt")
  def input_test = Pathname.new(__dir__).join("input_test.txt")
end

RSpec.configure do |c|
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true
  c.include AoC::SpecHelper
end

RSpec.describe AoC::Puzzle do
  context "with test input" do
    subject { described_class.call(input: input_test) }

    it { expect(subject).to eq([nil, nil]) }
  end

  context "with input" do
    subject { described_class.call(input: input) }

    it { expect(subject).to eq([nil, nil]) }
  end
end
