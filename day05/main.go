package main

import (
	"bufio"
	"io"
	"log"
	"math"
	"os"
)

func main() {
	lines, err := loadFromFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}

	input := lines[0]

	output := poly(input)
	log.Printf("Length output: %d\n", len(output))

	shortest := math.MaxInt64
	for unit := 65; unit < 90; unit++ {
		modInput := dropUnit(input, byte(unit))
		output := poly(modInput)

		if len(output) < shortest {
			shortest = len(output)
		}
	}

	log.Printf("Shortest: %d\n", shortest)
}

func dropUnit(input string, unit byte) string {
	output := make([]byte, 0, len(input))
	for index := 0; index < len(input); index++ {
		if input[index] != unit && input[index] != unit+32 {
			output = append(output, input[index])
		}
	}

	return string(output)
}

func poly(input string) string {
	x := input
	for {
		output := polyStep(x)
		if x == output {
			return output
		}

		x = output
	}
}

func polyStep(input string) string {
	output := make([]byte, 0, len(input))
	for index := 0; index < len(input); index++ {
		a := input[index]

		if index+1 >= len(input) {
			output = append(output, a)
			continue
		}

		b := input[index+1]

		// if delta is 32 (difference between lower and upper case chars)
		// skip current and goto next
		if a-b == 32 || b-a == 32 {
			index++
			continue
		}

		output = append(output, a)
	}

	return string(output)
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
