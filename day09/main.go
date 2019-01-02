package main

import (
	"fmt"
	"strconv"
)

type player struct {
	score int
}

type board struct {
	current int
	marbles []int
}

func (b *board) set(value int) (score int) {
	if value%23 != 0 {
		pos := -1
		if b.current == 0 && value == 1 {
			pos = 1
		} else {
			pos = b.current + 1
			if pos >= len(b.marbles) {
				pos = 0
			}
			pos++
		}

		// log.Printf("current is %v | Target pos for %v is %v\n", b.current, value, pos)

		b.marbles = append(b.marbles, 0)
		copy(b.marbles[pos+1:], b.marbles[pos:])
		b.marbles[pos] = value

		b.current = pos
	} else {
		i := b.current - 7

		if i < 0 {
			i = len(b.marbles) + i
		}

		score = value + b.marbles[i]

		b.marbles = append(b.marbles[:i], b.marbles[i+1:]...)

		b.current = i
	}

	return
}

func (b board) String() string {
	out := ""

	for i, m := range b.marbles {
		if i != b.current {
			out += "" + fmt.Sprintf("%3v", strconv.Itoa(m)) + " "
		} else {
			out += "" + fmt.Sprintf("%4v", "("+strconv.Itoa(m)+")") + " "
		}
	}

	return out
}

func highestScore(playersCount, highestMarble int, showBoard bool) int {
	b := board{
		current: 0,
		marbles: make([]int, 1, 100000),
		// marbles: []int{0},
	}

	players := make([]player, playersCount)

	if showBoard {
		fmt.Println(b)
	}

	currentPlayer := 0
	for marbleIdx := 1; marbleIdx <= highestMarble; marbleIdx++ {
		score := b.set(marbleIdx)

		players[currentPlayer].score += score

		if showBoard {
			fmt.Println(b)
		}

		currentPlayer++
		if currentPlayer >= len(players) {
			currentPlayer = 0
		}
	}

	highestScore := -1
	for _, p := range players {
		if p.score > highestScore {
			highestScore = p.score
		}
	}

	return highestScore
}

func main() {
	// -- Test Input
	// playersCount := 17
	// highestMarble := 1104
	// showBoard = true

	// -- Puzzle Input
	playersCount := 438
	highestMarble := 71626
	showBoard := false

	fmt.Printf("Highest player score is %v\n", highestScore(playersCount, highestMarble, showBoard))
}
