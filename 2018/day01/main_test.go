package main

import (
	"testing"
)

func TestFirstRepeat(t *testing.T) {
	changes, err := loadChangesFromFile("input.txt")
	if err != nil {
		t.Fatal(err)
	}

	freq, _ := findFirstTwiceFrequency(changes)
	if freq != 390 {
		t.Errorf("Frequency is not correct, got %d want %d", freq, 390)
	}
}

func BenchmarkFirstRepeat(b *testing.B) {
	changes, err := loadChangesFromFile("input.txt")
	if err != nil {
		b.Fatal(err)
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		findFirstTwiceFrequency(changes)
	}
}

func TestApplyChanges(t *testing.T) {
	changes, err := loadChangesFromFile("input.txt")
	if err != nil {
		t.Fatal(err)
	}

	freq := applyChanges(changes)
	if freq != 477 {
		t.Errorf("Frequency is not correct, got %d want %d", freq, 477)
	}
}

func BenchmarkApplyChanges(b *testing.B) {
	changes, err := loadChangesFromFile("input.txt")
	if err != nil {
		b.Fatal(err)
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		applyChanges(changes)
	}
}
