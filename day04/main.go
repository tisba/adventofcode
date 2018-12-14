package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
	"regexp"
	"sort"
	"strconv"
	"time"
)

var guardShiftRegexp = regexp.MustCompile("\\[([^\\]]+)\\] (?:(falls asleep)|(wakes up)|(Guard #(\\d+) begins shift))")

type entry struct {
	Time    time.Time
	GuardID int
	Name    string
}

type guard struct {
	ID         int
	TotalSleep int
	Minutes    []int
}

func (g guard) MostSleepyMinute() (minute int, count int) {
	count = -1
	minute = -1
	for m, minCount := range g.Minutes {
		if m == 0 || minCount > count {
			count = minCount
			minute = m
		}
	}

	return minute, count
}

type guardList map[int]guard

func (guards guardList) findMostSleeptMinute() (guardID int, minute int) {
	maxCount := -1
	minute = -1
	guardID = -1
	for id, g := range guards {
		m, count := g.MostSleepyMinute()
		if count > maxCount {
			maxCount = count
			minute = m
			guardID = id
		}
	}

	return guardID, minute
}

func (guards guardList) mostSleepyGuard() (g guard) {
	min := 0
	for _, gx := range guards {
		if gx.TotalSleep > min {
			g = gx
			min = g.TotalSleep
		}
	}

	return g
}

func load(inputFile string) []entry {
	lines, err := loadFromFile(inputFile)
	if err != nil {
		log.Fatal(err)
	}

	entries := make([]entry, 0, len(lines))

	for _, line := range lines {
		m := guardShiftRegexp.FindStringSubmatch(line)

		fallsAsleep, wakesUp, beginsShift, guardID := m[2], m[3], m[4], m[5]

		t, err := time.Parse("2006-01-02 15:04", m[1])
		if err != nil {
			log.Fatal(err)
		}

		id := 0
		if guardID != "" {
			id, err = strconv.Atoi(guardID)
			if err != nil {
				log.Fatal(err)
			}
		}

		var eventName string
		if fallsAsleep != "" {
			eventName = "sleep"
		}
		if wakesUp != "" {
			eventName = "wakeup"
		}
		if beginsShift != "" {
			eventName = "begin_shift"
		}

		e := entry{
			Time:    t,
			GuardID: id,
			Name:    eventName,
		}

		entries = append(entries, e)
	}

	sort.Slice(entries, func(a, b int) bool { return entries[a].Time.UnixNano() < entries[b].Time.UnixNano() })

	currentGuard := entries[0].GuardID
	for index := 1; index < len(entries); index++ {
		if entries[index].GuardID == 0 {
			entries[index].GuardID = currentGuard
		} else {
			currentGuard = entries[index].GuardID
		}
	}

	return entries
}

func main() {
	entries := load("input.txt")

	guards := analyseSleep(entries)

	sleepyGuard := guards.mostSleepyGuard()

	maxMinute, _ := sleepyGuard.MostSleepyMinute()
	fmt.Printf("Most sleeping guard: %d and the most in minute %d -- %d\n", sleepyGuard.ID, maxMinute, sleepyGuard.ID*maxMinute)

	maxGuard, maxMinute := guards.findMostSleeptMinute()
	fmt.Printf("Most sleept minute %d by guard %d -- %d\n", maxMinute, maxGuard, maxMinute*maxGuard)
}

func analyseSleep(entries []entry) guardList {
	var lastEvent entry

	guards := make(guardList)

	for _, e := range entries {
		// make sure guard is present and set up
		_, found := guards[e.GuardID]
		if !found {
			guards[e.GuardID] = guard{
				ID:         e.GuardID,
				TotalSleep: 0,
				Minutes:    make([]int, 60),
			}
		}
		g := guards[e.GuardID]

		if lastEvent.GuardID == 0 {
			lastEvent = e
		}

		// same guard, was sleeping, did wake up
		if e.GuardID == lastEvent.GuardID && (e.Name == "begin_shift" || e.Name == "wakeup") && lastEvent.Name == "sleep" {
			diff := e.Time.Sub(lastEvent.Time)

			for index := 0; index < int(diff.Minutes()); index++ {
				g.Minutes[lastEvent.Time.Minute()+index]++
			}
			g.TotalSleep += int(diff.Minutes())
		}

		guards[e.GuardID] = g
		lastEvent = e
	}

	return guards
}

func loadFromFile(fileName string) ([]string, error) {
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
