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
      # noop if we already have an edge in the other direction
      # TODO: Why does this not work?
      # return unless graph.dig(target, source).nil?

      nodes << source
      nodes << target

      graph[source] ||= {}
      graph[source][target] = weight

      graph[target] ||= {}
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
    def dijkstra(source, target: nil)
      distance = {}
      previous = {}
      queue = Set.new

      nodes.each do |node|
        distance[node] = Float::INFINITY
        queue.add(node)
      end

      distance[source] = 0

      seen = []

      until queue.empty? do
        current = queue.min_by { |n| distance[n] }

        if target
          return previous if current == target
        end

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
  end




  class << self
    def call(input:, debug: false, only_part_one: false)
      map = Map.new
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

      movement = build_graph(map, -> (from, to) { to && (from >= to || from == to - 1) })

      start_node = Graph::Node.new(start)
      dest_node = Graph::Node.new(dest)
      dijkstra = movement.dijkstra(start_node, target: dest_node)

      # part 1: from start to dest in shortest path
      shortest_path_part_one = movement.to_path(dijkstra, start_node, dest_node)

      movement = build_graph(map, -> (from, to) { to && (to >= from || from == to + 1) })

      dest_node = Graph::Node.new(dest)
      dijkstra = movement.dijkstra(dest_node)

      lengths = []
      map.each_with_index do |row, y|
        row.each_with_index do |current, x|
          next if current > 0

          start_node = Graph::Node.new([x, y])

          shortest_path = movement.to_path(dijkstra, dest_node, start_node)

          unless shortest_path.empty?
            lengths << shortest_path.length
          end
        end
      end

      [
        shortest_path_part_one.count - 1,
        lengths.min - 1,
      ]
    end

    def build_graph(map, can_go)
      movement = Graph.new

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

      movement
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

    it { expect(subject).to eq([449, 443]) }
  end
end
