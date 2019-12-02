import std.stdio, std.algorithm, std.array, std.conv;

void main() {
	uint[] states = stdin.readln.splitter(",").map!(to!uint).array;

	states[1] = 12;
	states[2] = 2;

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

	states[0].writeln;
}
