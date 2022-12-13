package main

import (
	"log"
	"sort"
	"strconv"

	"github.com/tisba/adventofcode/utils"
)

func main() {
	lines, err := utils.LoadFromFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}

	current := 0
	totals := make([]int, 0)
	for _, line := range lines {
		if line == "" {
			totals = append(totals, current)
			current = 0
			continue
		}

		calories, err := strconv.Atoi(line)
		if err != nil {
			log.Fatal(err)
		}

		current += calories
	}

	sort.Ints(totals)
	sum := 0
	for _, c := range totals[len(totals)-3:] {
		sum += c
	}

	log.Printf("Max: %v\n", totals[len(totals)-1])
	log.Printf("Sum Top 3: %v\n", sum)
}
