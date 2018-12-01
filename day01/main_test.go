package main

import (
	"log"
	"os"
	"testing"
)

func BenchmarkFirstRepeat(b *testing.B) {
	changes := loadChanges("input.txt")

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		findFirstTwiceFrequency(changes)
	}
}

func TestApplyChanges(t *testing.T) {
	changes := loadChanges("input.txt")

	freq := applyChanges(changes)
	if freq != 477 {
		t.Errorf("Frequency is not correct, got %d want %d", freq, 477)
	}
}

func TestFirstRepeat(t *testing.T) {
	changes := loadChanges("input.txt")

	freq, _ := findFirstTwiceFrequency(changes)
	if freq != 390 {
		t.Errorf("Frequency is not correct, got %d want %d", freq, 390)
	}
}

func loadChanges(fileName string) []int {
	file, err := os.Open(fileName)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	changes, err := readInput(file)
	if err != nil {
		log.Fatal(err)
	}

	return changes
}
