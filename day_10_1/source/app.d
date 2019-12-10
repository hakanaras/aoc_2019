import std;

alias Asteroid = int[2];
alias Slope = int[2];

void main() {
	Asteroid[] asteroids = asteroids(File("input.txt", "r").byLine.map!(to!string).array);

	uint max_count;
	auto slopes = new RedBlackTree!Slope;
	foreach (source; asteroids) {
		foreach (target; asteroids) {
			if (target == source)
				continue;
			slopes.insert(slope(source, target));
		}
		max_count = max(slopes.length, max_count);
		slopes.clear();
	}
	writeln(max_count);
}

Slope slope(Asteroid source, Asteroid target) pure {
	Slope result = [target[0] - source[0], target[1] - source[1]];
	if (result[0] == 0)
		return [0, result[1].sgn];
	if (result[1] == 0)
		return [result[0].sgn, 0];
	if (result[0] == result[1])
		return [result[0].sgn, result[1].sgn];
	const gcd = result.greatest_common_divisor;
	result[0] /= gcd;
	result[1] /= gcd;
	return result;
}

int greatest_common_divisor(int[2] numbers) pure {
	numbers[0] = numbers[0].abs;
	numbers[1] = numbers[1].abs;
	while (numbers[1] != 0) {
		if (numbers[0] > numbers[1]) {
			numbers[0] = numbers[0] - numbers[1];
		} else {
			numbers[1] = numbers[1] - numbers[0];
		}
	}
	return numbers[0];
}

Asteroid[] asteroids(string[] input) pure {
	Asteroid[] result;
	foreach (row; 0 .. input.length) {
		foreach (col; 0 .. input[row].length) {
			if (input[row][col] == '#')
				result ~= [row, col];
		}
	}
	return result;
}
