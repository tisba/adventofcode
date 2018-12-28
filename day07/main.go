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

// Example:
//   Step C must be finished before step A can begin.
var instructionRegexp = regexp.MustCompile("Step (.) must be finished before step (.) can begin.")

var buildCost map[rune]int

func main() {
	stepDurationOffset := 60
	workerCount := 5
	input := "input.txt"

	// it takes 60 + {1,2,3} secs for step A, B, C, ...
	buildCost = make(map[rune]int)
	for index := 0; index < 26; index++ {
		buildCost[rune('A'+index)] = stepDurationOffset + 1 + index
	}

	lines, err := loadFromFile(input)
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

	answer := getOrder(instructions, parents)
	fmt.Printf("Step sequence for 1 worker: %v\n", answer)

	instructions = make(map[rune][]rune)
	parents = make(map[rune]int)

	for _, line := range lines {
		m := instructionRegexp.FindStringSubmatch(line)
		key := rune(m[1][0])
		value := rune(m[2][0])

		instructions[key] = append(instructions[key], value)
		parents[value] = parents[value] + 1
	}

	duration := getDurationWithWorkers(workerCount, instructions, parents)
	fmt.Printf("Duration for %v workers: %v\n", workerCount, duration)
}

type workerPool []workerType

func (p workerPool) idle() bool {
	for _, worker := range p {
		if worker.busy() {
			return false
		}
	}

	return true
}

func (p workerPool) String() string {
	out := ""
	for _, worker := range p {
		out += "\t" + worker.String()
	}

	return out
}

type workerType struct {
	ID        int
	Step      rune
	Remaining int
}

func (w workerType) busy() bool {
	return (w.Remaining > 0 || w.Step > 0)
}

func (w workerType) String() string {
	if w.Step == 0 {
		return "."
	}

	return string(w.Step)
}

func getDurationWithWorkers(nWorkers int, instructions map[rune][]rune, parents map[rune]int) int {
	debug := false

	// identify already finished steps (starting points)
	available := make([]rune, 0)
	for k := range instructions {
		if parents[k] == 0 {
			available = append(available, k)
		}
	}

	// build worker pool
	workers := workerPool{}
	for index := 0; index < nWorkers; index++ {
		workers = append(workers, workerType{ID: index + 1})
	}

	duration := 0

	answer := ""
	for len(available) > 0 || !workers.idle() {
		for workerIdx, worker := range workers {
			// worker just got done
			if worker.Step > 0 && worker.Remaining == 0 {
				answer += string(worker.Step)

				// what's next to do
				for _, v := range instructions[worker.Step] {
					parents[v] = parents[v] - 1
					if parents[v] == 0 {
						available = append(available, v)
						delete(parents, v)
					}
				}

				worker.Step = 0
				workers[workerIdx] = worker
			}
		}

		for workerIdx, worker := range workers {
			if worker.busy() || len(available) == 0 {
				continue
			}

			temp := make([]rune, len(available))
			copy(temp, available)
			sort.Sort(runes(temp))

			step := temp[0]
			worker.Step = step
			worker.Remaining = buildCost[step]
			workers[workerIdx] = worker

			for i := 0; i < len(available); i++ {
				if available[i] == step {
					available = append(available[:i], available[i+1:]...)
				}
			}
		}

		for workerIdx, worker := range workers {
			if worker.busy() {
				worker.Remaining--
				workers[workerIdx] = worker
			}
		}

		if debug {
			fmt.Printf("%v \t %v \t %v\n", duration, workers, answer)
		}

		duration++
	}

	return duration - 1
}

func getOrder(instructions map[rune][]rune, parents map[rune]int) string {
	// identify already finished steps (starting points)
	done := make([]rune, 0)
	for k := range instructions {
		if parents[k] == 0 {
			done = append(done, k)
		}
	}

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
