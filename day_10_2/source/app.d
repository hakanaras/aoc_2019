import std;

alias Location = int[2];
alias Slope = int[2];
alias Offsets = RedBlackTree!(Location, (a, b) => a[0].abs + a[1].abs < b[0].abs + b[1].abs);

void main() {
	Location[] asteroids = asteroids(File("input.txt", "r").byLine.map!(to!string).array);
	Location center = asteroids[270];
	Offsets[Slope] offsets;

	foreach (target; asteroids) {
		if (target == center)
			continue;
		offsets.update(slope(center, target), {
			return new Offsets(offset(center, target));
		}, (Offsets offsets) {
			offsets.insert(offset(center, target));
			return offsets;
		});
	}
	Offsets[] sorted = offsets.byKeyValue
		.array
		.sort!((a, b) => a.key.angle < b.key.angle)
		.map!"a.value"
		.array;
	uint count = 0;
	while (true) {
		foreach (o; sorted) {
			if (o.empty)
				continue;
			if (++count == 200) {
				[o.front[0] + center[0], o.front[1] + center[1]].writeln;
				return;
			}
			o.removeFront;
		}
	}
}

Location offset(Location source, Location target) pure {
	return [target[0] - source[0], target[1] - source[1]];
}

real angle(Slope a) pure {
	if (a[0] == 0)
		return a[1] < 0 ? 0 : PI;
	const result = atan2(cast(real) a[0], cast(real)-a[1]);
	return result < 0 ? result + 2 * PI : result;
}

Slope slope(Location source, Location target) pure {
	Slope result = [target[0] - source[0], target[1] - source[1]];
	if (result[0] == 0)
		return [0, result[1].sgn];
	if (result[1] == 0)
		return [result[0].sgn, 0];
	if (result[0] == result[1])
		return [result[0].sgn, result[1].sgn];
	const scale = gcd(result[0].abs, result[1].abs);
	result[0] /= scale;
	result[1] /= scale;
	return result;
}

Location[] asteroids(string[] input) pure {
	Location[] result;
	foreach (row; 0 .. input.length) {
		foreach (col; 0 .. input[row].length) {
			if (input[row][col] == '#')
				result ~= [col, row];
		}
	}
	return result;
}
