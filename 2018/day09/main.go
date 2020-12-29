package main

import (
	"container/ring"
	"fmt"
	"strconv"
)

type player struct {
	score int
}

type board struct {
	marbles *ring.Ring
}

func (b *board) set(value int) (score int) {
	if value%23 != 0 {
		// insert at CW-1
		b.marbles = b.marbles.Move(1)
		s := ring.New(1)
		s.Value = value
		b.marbles.Link(s)
	} else {
		// go to marble CCW-7
		b.marbles = b.marbles.Move(-8)

		// remove and add build score
		removed := b.marbles.Unlink(1)
		score = value + removed.Value.(int)
	}

	// new current is always CW-1
	b.marbles = b.marbles.Move(1)

	return
}

func (b board) String() (out string) {
	current := b.marbles.Value.(int)
	b.marbles.Do(func(m interface{}) {
		value := m.(int)
		if value == current {
			out += "" + fmt.Sprintf("%4s", "("+strconv.Itoa(value)+")") + " "
		} else {
			out += "" + fmt.Sprintf("%3s", strconv.Itoa(value)) + " "
		}
	})

	return out
}

func buildBoard() (b board) {
	b = board{
		marbles: ring.New(1),
	}
	b.marbles.Value = 0

	return
}

func highestScore(playersCount, highestMarble int, showBoard bool) int {
	b := buildBoard()

	players := make([]player, playersCount)

	if showBoard {
		fmt.Println(b)
	}

	for marbleIdx := 1; marbleIdx <= highestMarble; marbleIdx++ {
		currentPlayer := marbleIdx % playersCount

		players[currentPlayer].score += b.set(marbleIdx)

		if showBoard {
			fmt.Println(b)
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
	// -- Test Inputs
	playersCount := 9
	highestMarble := 25
	showBoard := true

	// playersCount = 17
	// highestMarble = 1104
	// showBoard = true

	// -- Puzzle A
	playersCount = 438
	highestMarble = 71626
	showBoard = false

	fmt.Printf("A: Highest player score is %v\n", highestScore(playersCount, highestMarble, showBoard))

	// -- Puzzle B
	playersCount = 438
	highestMarble = 71626 * 100
	showBoard = false

	fmt.Printf("B: Highest player score is %v\n", highestScore(playersCount, highestMarble, showBoard))
}
