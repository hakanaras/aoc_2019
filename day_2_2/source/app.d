import std.stdio, std.algorithm, std.array, std.conv, std.range;

void main() {
	const uint[] input = stdin.readln.splitter(",").map!(to!uint).array;

	foreach (ii; cartesianProduct(iota(1, 99), iota(1, 99))) {
		uint[] states = input.dup;
		states[1] = ii[0];
		states[2] = ii[1];

		bool complete;

		for (size_t i = 0; !complete && i < states.length; i += 4) {
			// dfmt off
			[
				1 : (uint i) => states[states[i + 3]] = states[states[i + 1]] + states[states[i + 2]],
				2 : (uint i) => states[states[i + 3]] = states[states[i + 1]] * states[states[i + 2]],
				99 : (uint i) { complete = true; return 0u; }
			][states[i]](i);
			// dfmt on
		}

		if (states[0] != 19_690_720)
			continue;

		writeln(ii[0] * 100 + ii[1]);
	}
}
