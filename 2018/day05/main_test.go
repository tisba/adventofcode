package main

import "testing"

func TestPoly(t *testing.T) {
	lines, err := loadFromFile("input.txt")
	if err != nil {
		t.Fatal(err)
	}

	input := lines[0]

	count := len(poly(input))

	if count != 10978 {
		t.Errorf("polymere length incorrect, got %d want %d", count, 10978)
	}
}

func BenchmarkPoly(b *testing.B) {
	lines, err := loadFromFile("input.txt")
	if err != nil {
		b.Fatal(err)
	}

	input := lines[0]

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		poly(input)
	}
}

func BenchmarkPolyStep(b *testing.B) {
	lines, err := loadFromFile("input.txt")
	if err != nil {
		b.Fatal(err)
	}

	input := lines[0]

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		polyStep(input)
	}
}
