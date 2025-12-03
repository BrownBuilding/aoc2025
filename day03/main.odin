package day03

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:testing"

Bank :: []u8

read_input :: proc(file_name: string, allocator:=context.allocator) -> []Bank {
	banks := make([dynamic]Bank, allocator)
	file_content := string(os.read_entire_file(file_name) or_else panic("could not read input file"))
	for line in strings.split_lines_iterator(&file_content) {
		line_bytes := transmute([]u8)line
		row := slice.to_dynamic(line_bytes, allocator)
		for &v in row {
			v -= '0' // convert character to number
		}
		append(&banks, row[:])
	}
	return banks[:]
}

@(test)
test_read_input :: proc(t: ^testing.T) {
	input: []Bank = read_input("testinput.txt")
	testing.expect_value(t, len(input), 4)
	testing.expect(t, slice.equal(input[0][:], []u8{9,8,7,6,5,4,3,2,1,1,1,1,1,1,1,}))
	testing.expect(t, slice.equal(input[1][:], []u8{8,1,1,1,1,1,1,1,1,1,1,1,1,1,9,}))
	testing.expect(t, slice.equal(input[2][:], []u8{2,3,4,2,3,4,2,3,4,2,3,4,2,7,8,}))
	testing.expect(t, slice.equal(input[3][:], []u8{8,1,8,1,8,1,9,1,1,1,1,2,1,1,1,}))
}

jolt :: proc(bank: Bank) -> int {
	i := slice.max_index(bank[:len(bank)-1]) or_else panic("bank is empty ????")
	j := (slice.max_index(bank[i+1:]) or_else panic("bank has less than two elements ????") )+ i + 1
	return int(bank[i]) * 10 + int(bank[j])
}

@(test)
test_jolt :: proc(t: ^testing.T) {
	testing.expect_value(t, jolt([]u8{9,8,7,6,5,4,3,2,1,1,1,1,1,1,1,}), 98)
	testing.expect_value(t, jolt([]u8{8,1,1,1,1,1,1,1,1,1,1,1,1,1,9,}), 89)
	testing.expect_value(t, jolt([]u8{2,3,4,2,3,4,2,3,4,2,3,4,2,7,8,}), 78)
	testing.expect_value(t, jolt([]u8{8,1,8,1,8,1,9,1,1,1,1,2,1,1,1,}), 92)
}

part1 :: proc(input: []Bank) -> (sum: int) {
	for b in input {
		sum += jolt(b)
	}
	return
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	input := read_input("testinput.txt")
	testing.expect_value(t, part1(input), 357)
}

jolt2 :: proc(bank: Bank, n:=12, value_up:=0) -> int {
	if n == 0 {
		return value_up
	}
	i := slice.max_index(bank[0:len(bank) - n + 1])
	value := value_up * 10 + int(bank[i])
	return jolt2(bank[i+1:], n - 1, value)
}

@(test)
test_jolt2 :: proc(t: ^testing.T) {
	testing.expect_value(t, jolt2({9,8,7,6,5,4,3,2,1,1,1,1,1,1,1,}), 987654321111)
	testing.expect_value(t, jolt2({8,1,1,1,1,1,1,1,1,1,1,1,1,1,9,}), 811111111119)
	testing.expect_value(t, jolt2({2,3,4,2,3,4,2,3,4,2,3,4,2,7,8,}), 434234234278)
	testing.expect_value(t, jolt2({8,1,8,1,8,1,9,1,1,1,1,2,1,1,1,}), 888911112111)
}

part2 :: proc(input: []Bank) -> (sum: int) {
	for b in input {
		sum += jolt2(b)
	}
	return
}

@(test)
test_part2 :: proc(t: ^testing.T) {
	input := read_input("testinput.txt")
	testing.expect_value(t, part2(input), 3121910778619)
}

main :: proc() {
	input := read_input("input.txt")
	fmt.println("The solution to part 1 is", part1(input))
	fmt.println("The solution to part 2 is", part2(input))
}
