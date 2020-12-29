package main

import (
	"testing"
)

func TestMultpleUsage(t *testing.T) {
	c1 := BuildClaim("#1 @ 1,3: 4x4")
	c2 := BuildClaim("#2 @ 3,1: 4x4")
	c3 := BuildClaim("#3 @ 5,5: 2x2")

	c := BuildClaimMap([]Claim{c1, c2, c3})

	count := c.CountSquaresWithMultipleUsage()

	if count != 4 {
		t.Errorf("count of multiple use squares is not correct, got %d want %d", count, 4)
	}
}

func BenchmarkMultpleUsage(b *testing.B) {
	c1 := BuildClaim("#1 @ 1,3: 4x4")
	c2 := BuildClaim("#2 @ 3,1: 4x4")
	c3 := BuildClaim("#3 @ 5,5: 2x2")

	c := BuildClaimMap([]Claim{c1, c2, c3})

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		c.CountSquaresWithMultipleUsage()
	}
}

func TestOverlap(t *testing.T) {
	c1 := BuildClaim("#1 @ 1,3: 4x4")
	c2 := BuildClaim("#2 @ 3,1: 4x4")
	c3 := BuildClaim("#3 @ 5,5: 2x2")

	c := BuildClaimMap([]Claim{c1, c2, c3})

	if !c1.OverlapsWith(c) {
		t.Errorf("expected c1 to overlap")
	}

	if !c2.OverlapsWith(c) {
		t.Errorf("expected c1 to overlap")
	}

	if c3.OverlapsWith(c) {
		t.Errorf("expected c3 not to overlap")
	}
}

func BenchmarkOverlap(b *testing.B) {
	c1 := BuildClaim("#1 @ 1,3: 4x4")
	c2 := BuildClaim("#2 @ 3,1: 4x4")
	c3 := BuildClaim("#3 @ 5,5: 2x2")

	c := BuildClaimMap([]Claim{c1, c2, c3})

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		c1.OverlapsWith(c)
		c2.OverlapsWith(c)
		c3.OverlapsWith(c)
	}
}
