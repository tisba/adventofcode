package utils

import (
	"bufio"
	"io"
	"os"
)

func LoadFromFile(fileName string) ([]string, error) {
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
