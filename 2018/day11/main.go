package main

import (
	"log"
	"math"
)

type Result struct {
	x     int
	y     int
	size  int
	power int
}

func foo() {
	results := make(chan Result, 100)

	work := func(size, serial int) {
		x, y, power := maxPower(size, serial)

		results <- Result{
			x:     x,
			y:     y,
			size:  size,
			power: power,
		}
	}

	for size := 1; size <= 300; size++ {
		go work(size, 8444)
	}

	found := Result{power: math.MinInt64}
	for a := 1; a <= 300; a++ {
		r := <-results

		if r.power > found.power {
			found = r
		}
	}

	log.Printf("Max Power -> Size: %dx%d at %d,%d with %d\n", found.size, found.size, found.x, found.y, found.power)
}

func main() {
	foo()

	if true {
		return
	}

	// log.Println(powerFor(3, 5, 8))
	// log.Println(powerFor(122, 79, 57))
	// log.Println(powerFor(217, 196, 39))
	// log.Println(powerFor(101, 153, 71))
	// log.Println(powerFor(33, 47, 18))

	serial := 8444
	size := 3
	x, y, power := maxPower(size, serial)
	log.Printf("Size: %dx%d at %d,%d with %d\n", size, size, x, y, power)

	serial = 8444
	foundPower, foundX, foundY, foundSize := -1, -1, -1, 0
	for size := 1; size <= 300; size++ {
		x, y, power := maxPower(size, serial)
		log.Printf("Size: %dx%d at %d,%d with %d\n", size, size, x, y, power)
		if power > foundPower {
			foundX = x
			foundY = y
			foundSize = size
			foundPower = power
		}
	}

	log.Printf("Max Power -> Size: %dx%d at %d,%d with %d\n", foundSize, foundSize, foundX, foundY, foundPower)
}

func maxPower(size, serial int) (pX, pY, power int) {
	pX = -1
	pY = -1
	power = math.MinInt64
	for y := 1; y <= 300-size-1; y++ {
		for x := 1; x <= 300-size-1; x++ {
			p := powerSumFor(x, y, size, serial)
			// log.Println(x, y, size, serial)
			if p > power {
				power = p
				pX = x
				pY = y
			}
		}
	}

	return
}

func powerSumFor(xStart, yStart, size, serial int) int {
	power := 0
	for y := yStart; y <= yStart+size-1; y++ {
		for x := xStart; x <= xStart+size-1; x++ {
			power += powerFor(x, y, serial)
		}
	}

	return power
}

func powerFor(x, y, serial int) int {
	rackID := x + 10

	power := rackID * y
	power = (power + serial)
	power = power * rackID
	power = (power / 100) % 10

	return power - 5
}
