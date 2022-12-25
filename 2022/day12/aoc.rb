# frozen_string_literal: true

require "pathname"
require "set"
require "stringio"

class AoC; end

class Array
  def print
    self.each do |row|
      puts row.map { |s| s.to_s.rjust(2) }.join(" ")
    end
  end
end

class AoC::Day12
  Map = ::Array

  class Graph
    class Node < Struct.new(:coord)
      def inspect
        coord.join("-")
      end
    end

    attr_reader :graph, :nodes

    def initialize
      @graph = {} # the graph // {node => { edge1 => weight, edge2 => weight}, node2 => ...
      @nodes = Set.new
    end

    def add_edge(source, target, weight: 1)
      connect_graph(source, target, weight)
    end

    def to_dot
      out = StringIO.new

      x = Set.new
      @graph.each do |node, edges|
        edges.keys.each do |edge|
          x.add(%Q(  "#{node.coord}" -> "#{edge.coord}";))
        end
      end
      out.puts "digraph D {"
      out << x.join("\n")
      out.puts
      out.puts "}"

      out.string
    end

    # based of wikipedia's pseudocode: http://en.wikipedia.org/wiki/Dijkstra's_algorithm
    def dijkstra(source)
      distance = {}
      previous = {}
      queue = Set.new

      nodes.each do |node|
        distance[node] = Float::INFINITY
        queue.add(node)
      end

      distance[source] = 0

      until queue.empty? do
        current = queue.min_by { |n| distance[n] }
        queue.delete(current)

        graph[current].keys.each do |vertex|
          alt = distance[current] + graph[current][vertex]

          if alt < distance[vertex]
            distance[vertex] = alt
            previous[vertex] = current
          end
        end
      end

      previous
    end

    def shortest(from:, to:)
      from = Node.new(from) unless from === Node
      to = Node.new(to) unless to === Node

      to_path(dijkstra(from), from, to)
    end

    def to_path(prev, start, target)
      return [] unless prev[target]

      path = []
      current = target

      while current
        path << current
        current = prev[current]
      end

      path.reverse
    end


    private

    def connect_graph(source, target, weight)
      # return if graph.dig(target, source)

      nodes << source
      nodes << target

      graph[source] ||= {}
      graph[source][target] = weight

      graph[target] ||= {}
    end
  end




  class << self
    def call(input:, debug: false, only_part_one: false)
      map = Map.new
      movement = Graph.new
      start, dest = nil

      input.each_line.each_with_index do |line, y|
        if found_at_x = line.index("S")
          start ||= [found_at_x, y]
        end
        if found_at_x = line.index("E")
          dest ||= [found_at_x, y]
        end

        map << line.strip.gsub("S", "a").gsub("E", "z").chars.map { |c| c.ord - 97 }
      end

      if debug
        puts "Start: #{start.inspect}"
        puts "Destination: #{dest.inspect}"
        map.print
      end

      can_go = -> (from, to) { to && (from >= to || from == to - 1) }

      map.each_with_index do |row, y|
        row.each_with_index do |current, x|
          u = map.dig(y-1, x  ) if y >= 1
          d = map.dig(y+1, x  ) if y < map.length
          l = map.dig(y  , x-1) if x >= 1
          r = map.dig(y  , x+1) if x < row.length

          targets = []
          targets << [   x, y-1 ] if can_go.call(current, u)
          targets << [   x, y+1 ] if can_go.call(current, d)
          targets << [ x-1,   y ] if can_go.call(current, l)
          targets << [ x+1,   y ] if can_go.call(current, r)
          targets.each do |target|
            movement.add_edge(Graph::Node.new([x, y]), Graph::Node.new(target))
          end
        end
      end

      # part 1: from start to dest in shortest path
      shortest_path = movement.shortest(from: start, to: dest)

      unless only_part_one
        # part 2 hacking...
        lengths = []
        foo = []
        map.each_with_index do |row, y|
          row.each_with_index do |current, x|
            STDOUT.write "."
            next unless current == 0
            if foo.include?([x, y])
              STDOUT.write "S"
              next
            end

            path = movement.shortest(from: [x, y], to: dest)

            if path.count == 0
              puts "\nno path from #{[x, y]} to #{dest}"
              foo << [x, y]
            else
              lengths << path.count - 1
            end
          end
        end

        new_route_steps = lengths.min
      end

      [
        shortest_path.count - 1,
        new_route_steps,
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

RSpec.describe AoC::Day12 do
  context "with test input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input_test.txt")) }

    it { expect(subject).to eq([31, 29]) }
  end

  context "with input" do
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt"), only_part_one: true) }

    it { expect(subject).to eq([449, nil]) }
  end
end
