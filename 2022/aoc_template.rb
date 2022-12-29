# frozen_string_literal: true

require "pathname"
require "json"

class AoC; end

class AoC::DayXX
  class << self
    def call(input:)
    end
  end
end

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec"
end

require "rspec/autorun" if Pathname.new($0).basename.to_s != "rspec"

RSpec.describe AoC::DayXX do
  context "with test input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input_test.txt")) }

    it { expect(subject).to eq([nil, nil]) }
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt")) }

    it { expect(subject).to eq([nil, nil]) }
  end
end
