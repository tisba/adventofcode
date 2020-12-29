package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
	"regexp"
	"strconv"
)

var claimRegexp = regexp.MustCompile("#(\\d+) @ (\\d+),(\\d+): (\\d+)x(\\d+)")

type Claim struct {
	ID      int
	OffsetX int
	OffsetY int
	Width   int
	Height  int
}

func BuildClaim(input string) Claim {
	m := claimRegexp.FindStringSubmatch(input)
	id, _ := strconv.Atoi(m[1])
	offsetX, _ := strconv.Atoi(m[2])
	offsetY, _ := strconv.Atoi(m[3])
	width, _ := strconv.Atoi(m[4])
	height, _ := strconv.Atoi(m[5])
	c := Claim{
		ID:      id,
		OffsetX: offsetX,
		OffsetY: offsetY,
		Width:   width,
		Height:  height,
	}

	return c
}

func (c *Claim) OverlapsWith(claimMap Map) bool {
	for x := c.OffsetX; x < c.OffsetX+c.Width; x++ {
		for y := c.OffsetY; y < c.OffsetY+c.Height; y++ {
			if claimMap[x][y] > 1 {
				return true
			}
		}
	}

	return false
}

type Map map[int]map[int]int

func BuildClaimMap(claims []Claim) Map {
	claimMap := make(Map)

	for _, claim := range claims {
		for x := claim.OffsetX; x < claim.OffsetX+claim.Width; x++ {
			if claimMap[x] == nil {
				claimMap[x] = make(map[int]int)
			}
			for y := claim.OffsetY; y < claim.OffsetY+claim.Height; y++ {
				claimMap[x][y]++
			}
		}
	}

	return claimMap
}

func (m *Map) CountSquaresWithMultipleUsage() (count int) {
	for _, x := range *m {
		for _, usageCounter := range x {
			if usageCounter > 1 {
				count++
			}
		}
	}

	return count
}

func main() {
	input, err := loadFromFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}

	claims := buildClaims(input)

	claimMap := BuildClaimMap(claims)

	fmt.Printf("Count of squares used more then once: %d\n", claimMap.CountSquaresWithMultipleUsage())

	for _, claim := range claims {
		if !claim.OverlapsWith(claimMap) {
			fmt.Printf("Non-overlapping claim id: %d\n", claim.ID)
			break
		}
	}
}

func buildClaims(claims []string) []Claim {
	out := make([]Claim, 0, len(claims))
	for _, claim := range claims {
		c := BuildClaim(claim)

		out = append(out, c)
	}

	return out
}

func loadFromFile(fileName string) ([]string, error) {
	file, err := os.Open(fileName)
	if err != nil {
		return []string{}, err
	}
	defer file.Close()

	changes, err := readInput(file)
	if err != nil {
		return []string{}, err
	}

	return changes, nil
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
