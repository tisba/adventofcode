package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
)

func main() {
	ids, err := loadFromFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}

	checksum := checksum(ids)

	fmt.Printf("Checksum: %d\n", checksum)
	log.Printf("Common chars: %s\n", correctCommonChars(ids))
}

func checksum(ids []string) int {
	twoTimes := 0
	threeTimes := 0
	for _, id := range ids {
		chars := make(map[byte]int, 26)

		for i := 0; i < len(id); i++ {
			chars[id[i]]++
		}

		c2 := false
		c3 := false

		for _, count := range chars {
			if count == 2 {
				c2 = true
			}
			if count == 3 {
				c3 = true
			}
		}

		if c2 {
			twoTimes++
		}
		if c3 {
			threeTimes++
		}
	}

	return twoTimes * threeTimes
}

func correctCommonChars(ids []string) string {
	for i := 0; i < len(ids)/2; i++ {
		for j, b := range ids {
			if i == j {
				continue
			}

			if match, diff := difference(ids[i], b); match {
				return diff
			}
		}
	}

	return ""
}

func difference(a, b string) (bool, string) {
	if len(a) != len(b) {
		return false, ""
	}
	out := make([]byte, len(a)-1)

	pos := 0

	for i := 0; i < len(a); i++ {
		if a[i] != b[i] {
			continue
		}

		out[pos] = a[i]
		pos++

		if (i - pos) >= 2 {
			return false, ""
		}
	}

	if len(a)-pos >= 2 {
		return false, ""
	}

	return true, string(out)
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
