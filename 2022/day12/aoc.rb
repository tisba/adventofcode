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

    attr_reader :graph

    def initialize
      @graph = {} # the graph // {node => { edge1 => weight, edge2 => weight}, node2 => ...
    end

    def add_edge(source, target, weight: 1)
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
    def dijkstra(source, targets: nil)
      distance = {}
      previous = {}
      queue = Set.new
      targets = [targets].flatten if targets

      graph.keys.each do |node|
        distance[node] = Float::INFINITY
        queue.add(node)
      end

      distance[source] = 0

      until queue.empty? do
        current = queue.min_by { |n| distance[n] }

        if targets
          return previous if targets.include?(current)
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

    def distance(prev, start, target)
      return 0 unless prev[target]

      steps = 0
      current = target

      while current
        steps += 1
        current = prev[current]
      end

      steps - 1
    end
  end




  class << self
    def call(input:, debug: false)
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
      dijkstra = movement.dijkstra(start_node, targets: dest_node)

      # part 1: from start to dest in shortest path
      shortest_path_part_one = movement.distance(dijkstra, start_node, dest_node)

      # part 2:
      movement = build_graph(map, -> (from, to) { to && (to >= from || from == to + 1) })

      start_node_candidates = map.each_with_index.flat_map do |row, y|
        row.each_with_index.flat_map do |current, x|
          next if current > 0

          Graph::Node.new([x, y])
        end
      end.compact

      dijkstra = movement.dijkstra(dest_node, targets: start_node_candidates)

      distances = start_node_candidates.map do |start_node|
        movement.distance(dijkstra, start_node, start_node)
      end

      [
        shortest_path_part_one,
        distances.compact.reject(&:zero?).min,
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
    subject { described_class.call(input: Pathname.new(__dir__).join("input.txt")) }

    it { expect(subject).to eq([449, 443]) }
  end
end
