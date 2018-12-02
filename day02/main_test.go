package main

import (
	"testing"
)

func TestDifference(t *testing.T) {
	match, res := difference("fghij", "fguij")

	if !match {
		t.Errorf("match is not correct, got %t want %t", match, true)
	}

	if res != "fgij" {
		t.Errorf("difference is not correct, got %s want %s", res, "fgij")
	}
}

func BenchmarkDifference(b *testing.B) {
	for i := 0; i < b.N; i++ {
		difference("abcde", "axcye")
	}
}

func TestChecksum(t *testing.T) {
	ids := []string{"abcdef", "bababc", "abbcde", "abcccd", "aabcdd", "abcdee", "ababab"}

	if sum := checksum(ids); sum != 12 {
		t.Errorf("checksum is not correct, got %d want %d", sum, 12)
	}
}

func BenchmarkChecksum(b *testing.B) {
	ids := []string{"abcdef", "bababc", "abbcde", "abcccd", "aabcdd", "abcdee", "ababab"}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		checksum(ids)
	}
}
