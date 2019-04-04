package main

import (
	"fmt"
	"image"
	"image/color"
	"image/png"
	"log"
	"math"
	"os"
	"regexp"
	"strconv"

	"github.com/otiai10/gosseract"
	"github.com/tisba/adventofcode-2018/utils"
)

type Field []*Point

func (f *Field) At(n int) {
	for _, point := range *f {
		point.X = n * point.Vx
		point.Y = n * point.Vy
	}
}

func (f *Field) Tick() {
	for _, point := range *f {
		point.X += point.Vx
		point.Y += point.Vy
	}
}

func (f Field) MinMax() (int, int, int, int) {
	xMin, xMax := math.MaxInt64, math.MinInt64
	yMin, yMax := math.MaxInt64, math.MinInt64

	for _, point := range f {
		if point.X > xMax {
			xMax = point.X
		}

		if point.X < xMin {
			xMin = point.X
		}

		if point.Y > yMax {
			yMax = point.Y
		}

		if point.Y < yMin {
			yMin = point.Y
		}
	}

	return xMin, xMax, yMin, yMax
}

func (f Field) Print() {
	xMin, xMax, yMin, yMax := f.MinMax()

	for y := yMin; y <= yMax; y++ {
		for x := xMin; x <= xMax; x++ {
			match := false
			for _, point := range f {
				if point.X == x && point.Y == y {
					fmt.Print("#")
					match = true
				}
			}

			if !match {
				fmt.Print(".")
			}
		}
		fmt.Print("\n")
	}
}

type Point struct {
	X  int
	Y  int
	Vx int
	Vy int
}

func main() {
	input, err := utils.LoadFromFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}

	exp := regexp.MustCompile("position=<\\s*(-?\\d+),\\s*(-?\\d+)> velocity=<\\s*(-?\\d+),\\s*(-?\\d+)>")

	field := Field{}

	for _, line := range input {
		res := exp.FindStringSubmatch(line)

		x, _ := strconv.Atoi(res[1])
		y, _ := strconv.Atoi(res[2])
		vx, _ := strconv.Atoi(res[3])
		vy, _ := strconv.Atoi(res[4])

		field = append(field, &Point{
			X:  x,
			Y:  y,
			Vx: vx,
			Vy: vy,
		})
	}

	areaMin := float64(math.MaxInt64)
	iteration := 0
	for index := 1; index <= 10375; index++ {
		field.Tick()
		xMin, xMax, yMin, yMax := field.MinMax()

		area := (math.Abs(float64(xMax)) - math.Abs(float64(xMin))) * (math.Abs(float64(yMax)) - math.Abs(float64(yMin)))

		if area < areaMin {
			areaMin = area
			iteration = index
		}

		log.Printf("%d: %d - %f\n", index, iteration, areaMin)
	}

	Foo(field, iteration)
	log.Println(OCR(fmt.Sprintf("tmp/image-%03d.png", iteration)))
}

func Foo(field Field, n int) {
	xMin, xMax, yMin, yMax := field.MinMax()

	width := xMax - xMin + 4
	height := yMax - yMin + 4

	upLeft := image.Point{0, 0}
	lowRight := image.Point{width, height}

	img := image.NewGray(image.Rectangle{upLeft, lowRight})

	for x := 0; x <= width; x++ {
		for y := 0; y <= height; y++ {
			img.Set(x, y, color.White)
		}
	}

	for _, point := range field {
		img.Set(point.X-xMin+2, point.Y-yMin+2, color.Black)
	}

	f, err := os.Create(fmt.Sprintf("tmp/image-%03d.png", n))
	if err != nil {
		log.Fatal(err)
	}
	png.Encode(f, img)
	f.Close()
}

func OCR(file string) string {
	client := gosseract.NewClient()
	defer client.Close()
	client.SetImage(file)
	text, err := client.Text()
	if err != nil {
		log.Fatal(err)
	}

	return text
}
