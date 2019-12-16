import std;

alias V = int;

void main() {
	V[] input = File("input.txt").readln.map!(x => (x - '0').to!V).array;
	V[] output = new V[](input.length);

	V[4] basePattern = [0, 1, 0, -1];

	const len = input.length;

	foreach (_; 0 .. 100) {
		foreach (i; 0 .. len) {
			auto pattern = basePattern[].map!(x => x.repeat(i + 1))
				.joiner.cycle.drop(1).takeExactly(len);
			output[i] = zip(pattern, input).fold!"a + b[0] * b[1]"(0).abs % 10;
		}
		swap(input, output);
	}
	writeln(input);
}
