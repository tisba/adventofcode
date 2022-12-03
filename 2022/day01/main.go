package main

import (
	"log"
	"strconv"

	"github.com/tisba/adventofcode/utils"
)

func main() {
	lines, err := utils.LoadFromFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}

	max := 0
	current := 0
	for _, line := range lines {
		if line == "" {
			if current > max {
				max = current
			}

			current = 0
			continue
		}

		calories, err := strconv.Atoi(line)
		if err != nil {
			log.Fatal(err)
		}

		current += calories
	}

	log.Println(max)
}
