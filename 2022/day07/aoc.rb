# frozen_string_literal: true

require "pathname"

class AoC; end

class AoC::Day07
  class << self
    def call(input:)
      cwd = Pathname.new("/")
      directories = Hash.new(0)

      input.each_line do |line|
        if line.start_with?("$") && line.start_with?("$ cd")
          cwd = cwd.join(line.delete_prefix("$ cd").strip)
          next
        end

        next if line.start_with?("dir ")

        directories[cwd] += line.split(" ").first.to_i
      end

      directories.each do |name, size|
        until (path = Pathname.new(name)).root?
          name = path.join("..")

          directories[name] += size
        end
      end

      need_to_remove = (70_000_000 - 30_000_000 - directories[Pathname.new("/")]).abs

      [
        directories.values.select { |s| s < 100_000 }.sum,
        directories.values.sort.find { |s| s >= need_to_remove },
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

RSpec.describe AoC::Day07 do
  context "with test input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input_test.txt")) }

    it { expect(subject).to eq([95437, 24933642]) }
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt")) }

    it { expect(subject).to eq([1989474, 1111607]) }
  end
end
