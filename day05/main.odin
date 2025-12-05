package day05

import "core:fmt"
import "core:strings"
import "core:os"
import "core:strconv"
import "core:testing"
import "core:slice"

Range :: struct {
	begin: int,
	end: int,
}

Input :: struct {
	ranges: []Range,
	ids: []int,
}

read_input :: proc(filename: string, allocator := context.allocator) -> (input: Input) {
	file_content_bytes := os.read_entire_file(filename) or_else panic("could not read input file")
	defer delete(file_content_bytes)
	file_content := string(file_content_bytes)
	ranges := make([dynamic]Range, allocator)
	ids    := make([dynamic]int, allocator)

	for line in strings.split_lines_iterator(&file_content) {
		if line == "" {
			break
		}
		line := line
		begin_str := strings.split_iterator(&line, "-") or_else panic("could not split range along '-'")
		end_str := line
		begin := int(strconv.parse_uint(begin_str) or_else panic("could not convert beginning of to integer"))
		end   := int(strconv.parse_uint(end_str)   or_else panic("coult not convert end of range to integer"))
		append(&ranges, Range{ begin=begin, end=end })
	}

	for line in strings.split_lines_iterator(&file_content) {
		append(&ids, strconv.parse_int(line) or_else panic("could not parse id"))
	}

	return Input{
		ranges=ranges[:],
		ids=ids[:],
	}
}

@(test)
test_read_input :: proc(t: ^testing.T) {
	input := read_input("testinput.txt")
	testing.expect_value(t, len(input.ranges), 4)
	testing.expect_value(t, input.ranges[0], Range{ begin = 3, end = 5 })
	testing.expect_value(t, input.ranges[1], Range{ begin = 10, end = 14 })
	testing.expect_value(t, input.ranges[2], Range{ begin = 16, end = 20 })
	testing.expect_value(t, input.ranges[3], Range{ begin = 12, end = 18 })
	testing.expect_value(t, len(input.ids), 6)
	testing.expect_value(t, input.ids[0], 1)
	testing.expect_value(t, input.ids[1], 5)
	testing.expect_value(t, input.ids[2], 8)
	testing.expect_value(t, input.ids[3], 11)
	testing.expect_value(t, input.ids[4], 17)
	testing.expect_value(t, input.ids[5], 32)
	free_all(context.allocator)
}

part1 :: proc(input: Input) -> (num_fresh_ids: int) {
	for_id: for id in input.ids {
		for r in input.ranges {
			if r.begin <= id && id <= r.end {
				num_fresh_ids += 1
				continue for_id
			}
		}
	}
	return
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	input := read_input("testinput.txt")
	testing.expect_value(t, part1(input), 3)
	free_all(context.allocator)
}

part2 :: proc(input: Input) -> (num_possible_fresh_ids: int) {
	are_overlapping :: proc(a, b: Range) -> bool {
		// a         B..........E   |   a B..........E
		// b B............E         |   b        B............E
		return (a.begin <= b.begin && b.begin <= a.end) || (b.begin <= a.begin && a.begin <= b.end)
	}

	find_overlapping :: proc(merged_ranges: []Range) -> (int, int, bool) {
		for r0, i_r0 in merged_ranges do for r1, i_r1 in merged_ranges {
			if i_r1 == i_r0 {
				continue
			}
			if are_overlapping(r0, r1) {
				return i_r0, i_r1, true
			}
		}
		return 0, 0, false
	}

	merged_ranges: [dynamic]Range = slice.to_dynamic(input.ranges)
	defer delete(merged_ranges)

	for i_r0, i_r1 in find_overlapping(merged_ranges[:]) {
		r0, r1 := merged_ranges[i_r0], merged_ranges[i_r1]
		r_new := Range{
			begin = min(r0.begin, r1.begin),
			end   = max(r0.end,   r1.end),
		}
		unordered_remove(&merged_ranges, i_r0)
		i_r1 := i_r1
		if i_r1 == len(merged_ranges) {
			i_r1 = i_r0
		}
		unordered_remove(&merged_ranges, i_r1)
		append(&merged_ranges, r_new)
	}

	sum := 0
	for r in merged_ranges {
		sum += r.end - r.begin + 1
	}
	return sum
}

@(test)
test_part2 :: proc(t: ^testing.T) {
	input := read_input("testinput.txt")
	testing.expect_value(t, part2(input), 14)
	free_all(context.allocator)
}

main :: proc() {
	input := read_input("input.txt")
	fmt.println("The solution to part 1 is", part1(input))
	fmt.println("The solution to part 2 is", part2(input))
}
