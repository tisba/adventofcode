package main

import (
	"fmt"
	"testing"
)

func Test(t *testing.T) {
	var tests = []struct {
		players, highestMarble int
		out                    int
	}{
		{10, 1618, 8317},
		{13, 7999, 146373},
		{17, 1104, 2764},
		{21, 6111, 54718},
		{30, 5807, 37305},
	}

	for _, tt := range tests {
		t.Run(fmt.Sprintf("%v players %v marbles", tt.players, tt.highestMarble), func(t *testing.T) {
			score := highestScore(tt.players, tt.highestMarble, false)
			if score != tt.out {
				t.Errorf("got %d want %d", score, tt.out)
			}
		})
	}
}

func Benchmark(b *testing.B) {
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		highestScore(438, 71626, false)
	}
}
