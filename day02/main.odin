package day02

import "core:os"
import "core:strings"
import "core:strconv"
import "core:testing"
import "core:fmt"

Range :: struct {
	begin: int,
	end: int,
}

read_input :: proc(file_path: string) -> (result: [dynamic]Range) {
	file_content: string = string(os.read_entire_file(file_path) or_else panic("could not read file"))
	file_content = strings.split_lines_iterator(&file_content) or_else panic("file does not have a line????")

	for range_str in strings.split_iterator(&file_content, ",") {
		range_str := range_str
		begin_str := strings.split_iterator(&range_str, "-") or_else panic("could not split range")
		end_str   := range_str
		append(&result, Range{
			begin = int(strconv.parse_uint(begin_str) or_else panic("could not convert beginning of range to int")),
			end   = int(strconv.parse_uint(end_str)   or_else panic("could not convert end of range to int")),
		})
	}
	return
}

@(test)
test_read_input :: proc(t: ^testing.T) {
	input := read_input("testinput.txt")
	testing.expect_value(t, input[ 0], Range{ begin = 11, end = 22});
	testing.expect_value(t, input[ 1], Range{ begin = 95, end = 115});
	testing.expect_value(t, input[ 2], Range{ begin = 998, end = 1012});
	testing.expect_value(t, input[ 3], Range{ begin = 1188511880, end = 1188511890});
	testing.expect_value(t, input[ 4], Range{ begin = 222220, end = 222224});
	testing.expect_value(t, input[ 5], Range{ begin = 1698522, end = 1698528});
	testing.expect_value(t, input[ 6], Range{ begin = 446443, end = 446449});
	testing.expect_value(t, input[ 7], Range{ begin = 38593856, end = 38593862});
	testing.expect_value(t, input[ 8], Range{ begin = 565653, end = 565659});
	testing.expect_value(t, input[ 9], Range{ begin = 824824821, end = 824824827});
	testing.expect_value(t, input[10], Range{ begin = 2121212118, end = 2121212124});
	free_all(context.allocator)
}

part1 :: proc(input: []Range) -> (sum: int) {
	is_invalid :: proc(number: int) -> bool {
		sb: strings.Builder
		defer strings.builder_destroy(&sb)
		number_str := fmt.sbprint(&sb, number)
		if len(number_str) % 2 == 1 {
			return false
		}
		for i in 0..<len(number_str)/2 {
			if i == 0 && number_str[i] == '0' { // ignoring leading zero
				return false;
			}
			if number_str[i] != number_str[len(number_str)/2 + i] {
				return false;
			}
		}
		return true
	}

	for r in input {
		range_sum := 0
		for n in r.begin..=r.end {
			if is_invalid(n) {
				range_sum += n
			}
		}
		sum += range_sum
	}

	return
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	input := read_input("testinput.txt")
	testing.expect_value(t, part1(input[:]), 1227775554)
	free_all(context.allocator)
}

has_n_equal_segments :: proc(number_str: []u8, num_segments: int) -> bool {
	assert(num_segments != 0)
	if len(number_str) % num_segments != 0 {
		// `number_str` can't even be devided into `num_segments` equal length segments
		return false
	}
	segment_length := len(number_str) / num_segments
	for i in 0..<segment_length {
		c: u8 = number_str[i]
		for segment_idx in 0..<num_segments {
			if number_str[i + segment_idx * segment_length] != c {
				return false
			}
		}
	}
	return true
}

@(test)
test_has_n_equal_segments :: proc(t: ^testing.T) {
	testing.expect_value(t, has_n_equal_segments([]u8{0, 1, 2, 0, 1, 2}, 2), true)
	testing.expect_value(t, has_n_equal_segments([]u8{0, 1, 2, 0, 1, 2}, 3), false)
	testing.expect_value(t, has_n_equal_segments([]u8{2, 2, 2, 2, 2, 2}, 1), true)
	testing.expect_value(t, has_n_equal_segments([]u8{2, 2, 2, 2, 2, 2}, 2), true)
	testing.expect_value(t, has_n_equal_segments([]u8{2, 2, 2, 2, 2, 2}, 3), true)
	testing.expect_value(t, has_n_equal_segments([]u8{2, 2, 2, 2, 2, 2}, 6), true)
	testing.expect_value(t, has_n_equal_segments([]u8{2, 2, 2, 2, 2, 2}, 7), false)
	testing.expect_value(t, has_n_equal_segments([]u8{0, 2, 0, 2, 0, 2}, 3), true)
	testing.expect_value(t, has_n_equal_segments([]u8{0, 2, 0, 2, 0, 2}, 6), false)
	testing.expect_value(t, has_n_equal_segments([]u8{0}, 1), true)
	testing.expect_value(t, has_n_equal_segments([]u8{0, 1}, 1), true)
	testing.expect_value(t, has_n_equal_segments([]u8{0, 3}, 2), false)
}

part2 :: proc(input: []Range) -> (sum: int) {
	for r in input {
		outer: for n in r.begin..=r.end {
			sb: strings.Builder
			defer strings.builder_destroy(&sb)
			number_str := fmt.sbprint(&sb, n)
			for i in 2..=len(number_str) {
				if has_n_equal_segments(
					number_str   = transmute([]u8)number_str,
					num_segments = i
				) {
					sum += n
					// 222222 could be divided mutliple ways and still be "invalid":
					// 222|222, 22|22|22, 2|2|2|2|2|2 .
					// but we only want to count it *once*, hence:
					continue outer 
				}
			}
		}
	}
	return
}

@(test)
test_part2 :: proc(t: ^testing.T) {
	input := read_input("testinput.txt")
	testing.expect_value(t, part2(input[:]), 4174379265)
	free_all(context.allocator)
}

main :: proc() {
	input := read_input("input.txt")
	fmt.println("The solution to part 1 is", part1(input[:]))
	fmt.println("The solution to part 2 is", part2(input[:]))
}
