package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
	"strconv"
)

func main() {
	changes, err := loadChangesFromFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}

	frequency := applyChanges(changes)
	fmt.Printf("Frequency after changes: %d\n", frequency)

	frequency, numChanges := findFirstTwiceFrequency(changes)
	fmt.Printf("Frequency seen twice: %d (after %d changes)\n", frequency, numChanges)
}

func applyChanges(changes []int) (frequency int) {
	for _, change := range changes {
		frequency += change
	}

	return
}

func findFirstTwiceFrequency(changes []int) (frequency int, numChanges int) {
	seen := make(map[int]bool)
	freq := 0
	for {
		for _, change := range changes {
			freq += change

			if seen[freq] {
				return freq, len(seen) + 1
			}

			seen[freq] = true
		}
	}
}

func readInput(r io.Reader) ([]int, error) {
	out := []int{}

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		change, err := strconv.Atoi(scanner.Text())
		if err != nil {
			return out, err
		}

		out = append(out, change)
	}

	if err := scanner.Err(); err != nil {
		return out, err
	}

	return out, nil
}

func loadChangesFromFile(fileName string) ([]int, error) {
	file, err := os.Open(fileName)
	if err != nil {
		return []int{}, err
	}
	defer file.Close()

	changes, err := readInput(file)
	if err != nil {
		return []int{}, err
	}

	return changes, nil
}
