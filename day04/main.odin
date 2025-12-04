package day03

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:testing"

read_input :: proc(file_name: string, allocator := context.allocator) -> [][]u8 {
	file_content_bytes := os.read_entire_file(file_name) or_else panic("could not read input file")
	defer delete(file_content_bytes)
	file_content := string(file_content_bytes)
	paper_rolls := make([dynamic][]u8, allocator)
	for line in strings.split_lines_iterator(&file_content) {
		row := make([dynamic]u8, allocator)
		for c in line {
			assert(c == '@' || c == '.')
			append(&row, u8(c));
		}
		append(&paper_rolls, row[:])
	}
	return paper_rolls[:]
}

@(test)
test_read_input :: proc(t: ^testing.T) {
	input := read_input("testinput.txt")
	testing.expect(t, slice.equal(input[0], []u8{'.', '.', '@', '@', '.', '@', '@', '@', '@', '.', }))
	testing.expect(t, slice.equal(input[1], []u8{'@', '@', '@', '.', '@', '.', '@', '.', '@', '@', }))
	testing.expect(t, slice.equal(input[2], []u8{'@', '@', '@', '@', '@', '.', '@', '.', '@', '@', }))
	testing.expect(t, slice.equal(input[3], []u8{'@', '.', '@', '@', '@', '@', '.', '.', '@', '.', }))
	testing.expect(t, slice.equal(input[4], []u8{'@', '@', '.', '@', '@', '@', '@', '.', '@', '@', }))
	testing.expect(t, slice.equal(input[5], []u8{'.', '@', '@', '@', '@', '@', '@', '@', '.', '@', }))
	testing.expect(t, slice.equal(input[6], []u8{'.', '@', '.', '@', '.', '@', '.', '@', '@', '@', }))
	testing.expect(t, slice.equal(input[7], []u8{'@', '.', '@', '@', '@', '.', '@', '@', '@', '@', }))
	testing.expect(t, slice.equal(input[8], []u8{'.', '@', '@', '@', '@', '@', '@', '@', '@', '.', }))
	testing.expect(t, slice.equal(input[9], []u8{'@', '.', '@', '.', '@', '@', '@', '.', '@', '.', }))
	free_all(context.allocator)
}

count_adjecent :: proc(grid: [][]u8, x, y: int) -> (sum: int) {
	grid_get :: proc(grid: [][]u8, x, y: int) -> u8 {
		zero := []u8{}
		return slice.get((slice.get(grid, y) or_else zero), x) or_else '.'
	}
	sum += grid_get(grid, x - 1, y - 1) == '.'? 0 : 1
	sum += grid_get(grid, x    , y - 1) == '.'? 0 : 1
	sum += grid_get(grid, x + 1, y - 1) == '.'? 0 : 1
	sum += grid_get(grid, x - 1, y    ) == '.'? 0 : 1
//	sum += grid_get(grid, x    , y    ) == '.'? 0 : 1
	sum += grid_get(grid, x + 1, y    ) == '.'? 0 : 1
	sum += grid_get(grid, x - 1, y + 1) == '.'? 0 : 1
	sum += grid_get(grid, x    , y + 1) == '.'? 0 : 1
	sum += grid_get(grid, x + 1, y + 1) == '.'? 0 : 1
	return
}

@(test)
test_count_adjecent :: proc(t: ^testing.T) {
	input := read_input("testinput.txt")
	testing.expect_value(t, count_adjecent(input, 6, 2), 2)
	testing.expect_value(t, count_adjecent(input, 2, 0), 3)
	testing.expect_value(t, count_adjecent(input, 6, 3), 4)
	testing.expect_value(t, count_adjecent(input, 9, 9), 2)
	testing.expect_value(t, count_adjecent(input, 4, 4), 8)
	free_all(context.allocator)
}

part1 :: proc(input: [][]u8) -> (sum: int) {
	for row, y in input {
		for cell, x in row {
			if cell == '@' && count_adjecent(input, x, y) < 4 {
				sum += 1
			}
		}
	}
	return
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	input := read_input("testinput.txt")
	testing.expect_value(t, part1(input), 13)
	free_all(context.allocator)
}

part2 :: proc(input: [][]u8) -> (total_removed: int) {
	for {
		removed_this_turn := 0
		for row, y in input do for &cell, x in row {
			if cell == '@' && count_adjecent(input, x, y) < 4 {
				removed_this_turn += 1
				cell = 'x' // `x`'s still get counted by `count_adjecent`
			}
		}
		total_removed += removed_this_turn
		if removed_this_turn == 0 {
			break
		}
		for row in input do for &cell in row {
			if cell == 'x' {
				cell = '.'
			}
		}
	}
	return
}

@(test)
test_part2 :: proc(t: ^testing.T) {
	input := read_input("testinput.txt")
	testing.expect_value(t, part2(input), 43)
	free_all(context.allocator)
}

main :: proc() {
	input := read_input("input.txt")
	fmt.println("The solution to part 1 is", part1(input))
	fmt.println("The solution to part 2 is", part2(input))
}
