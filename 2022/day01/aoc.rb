# frozen_string_literal: true

require "pathname"

current = 0

top = Pathname.new(__dir__).join("input.txt").each_line.each_with_object([]) do |line, top|
  if line.chomp.empty?
    top << current
    current = 0
    next
  end

  current += line.to_i
end.sort.reverse

puts "Max: #{top[0]}"
puts "Sum top 3: #{top[0..2].sum}"
