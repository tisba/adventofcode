package main

import (
	"fmt"
	"log"
	"strconv"
	"strings"

	utils "github.com/tisba/adventofcode-2018/utils"
)

func main() {
	input, err := utils.LoadFromFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}

	data := []int{}
	for _, i := range strings.Split(input[0], " ") {
		n, err := strconv.Atoi(i)
		if err != nil {
			log.Fatal(err)
		}

		data = append(data, n)
	}

	fmt.Println(data)
	t := tree{}
	_, rootNode := t.processNode('A', data, 0)
	fmt.Printf("Sum is: %v\n", t.sum)
	fmt.Printf("Value of root: %v\n", t.valueOf(rootNode))
	// fmt.Printf("Tree: %v", t.nodes)
}

type treeNode struct {
	id       rune
	children []treeNode
	metaData []int
}

func (n treeNode) String() string {
	return fmt.Sprintf("%v: %v children, %v meta -> %v", string(n.id), len(n.children), len(n.metaData), n.metaData)
}

type tree struct {
	sum   int
	nodes []treeNode
}

func (t *tree) valueOf(n treeNode) (value int) {
	if len(n.children) == 0 {
		for _, v := range n.metaData {
			value += v
		}
	} else {
		for _, m := range n.metaData {
			if m > len(n.children) {
				continue
			}

			value += t.valueOf(n.children[m-1])
		}
	}

	return
}

func (t *tree) processNode(id rune, data []int, pos int) (int, treeNode) {
	node := treeNode{
		id: id,
	}

	childrenLen := data[pos+0]
	metaDataLen := data[pos+1]
	var metaData []int

	// fmt.Printf("ID: %v | pos %v | c: %v, m: %v\n", string(id), pos, childrenLen, metaDataLen)

	pos += 2

	var child treeNode
	for index := 0; index < childrenLen; index++ {
		pos, child = t.processNode(rune(id+rune(index+1)), data, pos)
		node.children = append(node.children, child)
	}

	if metaDataLen > 0 {
		metaData = data[pos : pos+metaDataLen]
		node.metaData = metaData
	}

	pos += metaDataLen

	for _, m := range metaData {
		t.sum += m
	}

	// fmt.Printf("%v  Children: %v, Metadata: %v -> %v\n", string(id), childrenLen, metaDataLen, metaData)
	fmt.Println(node)
	t.nodes = append(t.nodes, node)

	return pos, node
}
