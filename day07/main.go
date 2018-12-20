package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
	"regexp"
	"sort"
)

// Step C must be finished before step A can begin.
var instructionRegexp = regexp.MustCompile("Step (.) must be finished before step (.) can begin.")

var buildCost map[rune]int

func main() {
	buildCost = make(map[rune]int)
	for index := 0; index < 26; index++ {
		buildCost[rune('A'+index)] = 60 + 1 + index
	}

	lines, err := loadFromFile("input_test.txt")
	if err != nil {
		log.Fatal(err)
	}

	instructions := make(map[rune][]rune)
	parents := make(map[rune]int)

	for _, line := range lines {
		m := instructionRegexp.FindStringSubmatch(line)
		key := rune(m[1][0])
		value := rune(m[2][0])

		instructions[key] = append(instructions[key], value)
		parents[value] = parents[value] + 1
	}

	done := make([]rune, 0)

	// identify already finished steps (starting points)
	for k := range instructions {
		if parents[k] == 0 {
			done = append(done, k)
		}
	}

	answer := getOrder(instructions, parents, done)

	fmt.Println(answer)
}

func getOrder(instructions map[rune][]rune, parents map[rune]int, done []rune) string {
	answer := ""
	for len(done) > 0 {
		// find next step that can be done
		// have to have no waiting parents
		// and if there are more then one,
		// pick the "lower" one.
		temp := make([]rune, len(done))
		copy(temp, done)
		sort.Sort(runes(temp))
		x := temp[0]
		for i := 0; i < len(done); i++ {
			if done[i] == x {
				done = append(done[:i], done[i+1:]...)
			}
		}

		// add next step to answer
		answer = answer + string(x)

		// go over instructions and decrement
		for _, v := range instructions[x] {
			parents[v] = parents[v] - 1
			if parents[v] == 0 {
				done = append(done, v)
				delete(parents, v)
			}
		}
	}

	return answer
}

type runes []rune

func (s runes) Len() int {
	return len(s)
}

func (s runes) Swap(i, j int) {
	s[i], s[j] = s[j], s[i]
}
func (s runes) Less(i, j int) bool {
	return s[i] < s[j]
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
