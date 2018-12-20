package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"math"
	"os"
	"strconv"
	"strings"
)

type point struct {
	X        int
	Y        int
	Closest  int
	Infinite bool
}

func (p point) Distance(other point) int {
	return abs(p.X-other.X) + abs(p.Y-other.Y)
}

func main() {
	lines, err := loadFromFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}

	points := make([]point, 0, len(lines))

	maxX := 0
	maxY := 0
	for _, line := range lines {
		parts := strings.Split(line, ", ")

		x, err := strconv.Atoi(parts[0])
		if err != nil {
			log.Fatal(err)
		}
		y, err := strconv.Atoi(parts[1])
		if err != nil {
			log.Fatal(err)
		}

		points = append(points, point{X: x, Y: y})

		if x > maxX {
			maxX = x
		}
		if y > maxY {
			maxY = y
		}
	}

	for x := 0; x <= maxX; x++ {
		for y := 0; y <= maxY; y++ {
			minDist := math.MaxInt64
			dirty := false
			var closestPt point
			var closestIdx int
			for idx, p := range points {
				dist := p.Distance(point{X: x, Y: y})
				if dist < minDist {
					minDist = dist
					closestPt = p
					closestIdx = idx
					dirty = false
				} else if dist == minDist {
					dirty = true
				}
			}

			if !dirty {
				closestPt.Closest++

				if x == 0 || x == maxX || y == 0 || y == maxY {
					closestPt.Infinite = true
				}

				// fmt.Printf("%d:%d is closest to %d:%d (%d) -- %v\n", x, y, closestPt.X, closestPt.Y, minDist, closestPt)

				points[closestIdx] = closestPt
			}
		}
	}

	largestArea := 0
	for _, p := range points {
		if p.Infinite {
			continue
		}

		if p.Closest > largestArea {
			largestArea = p.Closest
		}
	}

	fmt.Printf("Largest, finite area is: %d\n", largestArea)

	regionSize := 0
	for x := 0; x <= maxX; x++ {
		for y := 0; y <= maxY; y++ {
			sum := 0
			for _, p := range points {
				dist := p.Distance(point{X: x, Y: y})
				sum += dist
			}

			if sum < 10000 {
				regionSize++
			}
		}
	}

	fmt.Printf("Size of safe region: %d\n", regionSize)
}

func loadFromFile(fileName string) ([]string, error) {
	file, err := os.Open(fileName)
	if err != nil {
		return []string{}, err
	}
	defer file.Close()

	lines, err := readInput(file)
	if err != nil {
		return []string{}, err
	}

	return lines, nil
}

func readInput(r io.Reader) ([]string, error) {
	out := []string{}

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		out = append(out, scanner.Text())
	}

	if err := scanner.Err(); err != nil {
		return out, err
	}

	return out, nil
}

func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}
