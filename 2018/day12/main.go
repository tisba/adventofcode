package main

import (
	"fmt"
	"log"
	"math"
	"regexp"

	"github.com/tisba/adventofcode-2018/utils"
)

type State struct {
	Pods map[int]bool
}

func (s State) String() string {
	min := math.MaxInt16
	max := math.MinInt16
	for p, state := range s.Pods {
		if p < min && state {
			min = p
		}
		if p > max && state {
			max = p
		}
	}

	idxOut := ""
	out := ""
	for index := min; index <= max; index++ {
		if index == 0 {
			idxOut += "0"
		} else {
			idxOut += " "
		}
		pod := s.Pods[index]
		if pod {
			out += "#"
		} else {
			out += "."
		}
	}

	return idxOut + "\n" + out
}

func (s State) Arround(pos int, size int) [5]bool {
	start := pos - size
	end := pos + size

	foo := [5]bool{}
	c := 0
	for index := start; index <= end; index++ {
		foo[c] = s.Pods[index]
		c++
		// foo = append(foo, s.Pods[index])
	}

	return foo
}

func (s *State) Apply(patterns []Pattern) State {
	min := math.MaxInt16
	max := math.MinInt16

	for p, state := range s.Pods {
		if p < min && state {
			min = p
		}
		if p > max && state {
			max = p
		}
	}

	type ChangeRes struct {
		pos   int
		state bool
	}

	results := make(chan ChangeRes, 100)
	for pos := min - 2; pos <= max+2; pos++ {
		go func(p int) {
			input := s.Arround(pos, 2)
			newState := ShouldChange(input, patterns)

			results <- ChangeRes{pos: p, state: newState}
		}(pos)
	}

	x := []ChangeRes{}
	for pos := min - 2; pos <= max+2; pos++ {
		select {
		case r, ok := <-results:
			if !ok {
				break
			}
			x = append(x, r)
		}
	}

	// apply changes
	for _, r := range x {
		s.Pods[r.pos] = r.state
	}

	return *s
}

func ShouldChange(input [5]bool, patterns []Pattern) bool {
	changeTo := false
	found := false
	for _, pattern := range patterns {
		if pattern.Pattern == input {
			changeTo = true
			found = true
			break
		}
	}

	if !found && input[2] {
		changeTo = false
	}

	return changeTo
}

type Pattern struct {
	Pattern [5]bool
}

func main() {
	input, err := utils.LoadFromFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}

	initialStateExp := regexp.MustCompile("initial state: ([\\.#]+)")
	patternExp := regexp.MustCompile("([\\.#]{5}) => ([\\.#])") // ...## => #

	stateInput := initialStateExp.FindStringSubmatch(input[0])[1]

	state := State{Pods: make(map[int]bool)}
	for pos, s := range stateInput {
		state.Pods[pos] = s == '#'
	}

	patterns := []Pattern{}
	for _, line := range input[2:] {
		res := patternExp.FindStringSubmatch(line)

		if res[2] == "." {
			continue
		}

		p := Pattern{}
		for i, s := range res[1] {
			p.Pattern[i] = s == '#'
			// p.Pattern = append(p.Pattern, s == '#')
		}

		patterns = append(patterns, p)
	}

	fmt.Printf("Iteration %d\n", 0)
	fmt.Println(state)

	iterations := 50000000000
	// iterations := 20

	for index := 1; index <= iterations; index++ {
		state = state.Apply(patterns)

		if iterations < 100 {
			fmt.Printf("Iteration %d\n", index)
			fmt.Println(state)
		}
		if index%1000000 == 0 {
			fmt.Print(".")
		}
	}

	fmt.Print("\n")
	fmt.Printf("Final state: %v\n\n", state)

	sum := 0
	for id, pod := range state.Pods {
		if pod {
			sum += id
		}
	}

	fmt.Printf("Sum of all living pod positions is %d\n", sum)
}
