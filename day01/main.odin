package day01

import "core:text/regex"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:os"
import "core:testing"
import "core:log"
import "core:math"

Rotation :: struct {
	direction: rune,
	magnitude: int,
}

read_input :: proc(path: string) -> (result: [dynamic]Rotation) {
	file_content_data := os.read_entire_file(path) or_else panic("could not read file")
	defer delete(file_content_data)

	reg := regex.create("(L|R)(\\d+)") or_else panic("regex failed")
	defer regex.destroy_regex(reg)
	file_content := string(file_content_data)

	for line in strings.split_lines_iterator(&file_content) {
		capture: regex.Capture = regex.match(reg, line) or_else panic("no match")
		defer regex.destroy_capture(capture)
		assert(len(capture.groups) == 3)
		assert(len(capture.groups[1]) > 0)
		rotation := Rotation{
			magnitude = strconv.parse_int(capture.groups[2]) or_else panic("failed to parse magnitude"),
			direction = rune(capture.groups[1][0])
		}
		append(&result, rotation)
	}

	return
}

@(test)
test_read_input :: proc(t: ^testing.T) {
	input := read_input("testinput.txt")
	testing.expect_value(t, input[0], Rotation{ direction = 'L', magnitude = 68 })
	testing.expect_value(t, input[1], Rotation{ direction = 'L', magnitude = 30 })
	testing.expect_value(t, input[2], Rotation{ direction = 'R', magnitude = 48 })
	testing.expect_value(t, input[3], Rotation{ direction = 'L', magnitude =  5 })
	testing.expect_value(t, input[4], Rotation{ direction = 'R', magnitude = 60 })
	testing.expect_value(t, input[5], Rotation{ direction = 'L', magnitude = 55 })
	testing.expect_value(t, input[6], Rotation{ direction = 'L', magnitude =  1 })
	testing.expect_value(t, input[7], Rotation{ direction = 'L', magnitude = 99 })
	testing.expect_value(t, input[8], Rotation{ direction = 'R', magnitude = 14 })
	testing.expect_value(t, input[9], Rotation{ direction = 'L', magnitude = 82 })
}

part1 :: proc(input: []Rotation) -> (number_of_zeros: int) {
	position := 50
	for r in input {
		change := (r.direction == 'R'? 1 : -1) * r.magnitude
		position = (position + change) %% 100
		if position == 0 {
			number_of_zeros += 1
		}
	}
	return
}

@(test) 
test_part1 :: proc(t: ^testing.T) {
	input := read_input("testinput.txt")
	testing.expect_value(t, part1(input[:]), 3)
	delete(input)
}

part2 :: proc(input: []Rotation) -> (number_of_zeros: int) {
	position := 50
	for r in input {
		change := (r.direction == 'R'? 1 : -1)
		// i am not that smart
		for _ in 0..<r.magnitude {
			position = (position + change) %% 100
			if position == 0 {
				number_of_zeros += 1
			}
		}
	}
	return
}

@(test) 
test_part2 :: proc(t: ^testing.T) {
	input := read_input("testinput.txt")
	testing.expect_value(t, part2(input[:]), 6)
	delete(input)
}

@(test) 
test_part2_part2 :: proc(t: ^testing.T) {
	input := [?]Rotation {
		{ direction = 'L', magnitude =  50 }
	}
	testing.expect_value(t, part2(input[:]), 1)
}

main :: proc() {
	input := read_input("input.txt")
	fmt.println("The solution to part 1 is", part1(input[:]))
	fmt.println("The solution to part 2 is", part2(input[:]))
}
