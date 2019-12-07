import std.stdio, std.algorithm, std.array, std.conv, std.math, std.string,
	std.container, std.range, core.thread;

void perform(const int[] program, ref Array!int io) {
	int[] states = program.dup;

	bool complete;
	for (size_t i = 0; !complete && i < states.length;) {
		const instruction = states[i] % 100;
		alias mode = (p) => states[i] % (100 * pow(10, p)) / (100 * pow(10, p - 1));
		ref int param(int p) {
			return mode(p) ? states[i + p] : states[states[i + p]];
		}

		[
			1: () { // Addition
				param(3) = param(1) + param(2);
				i += 4;
			},
			2: () { // Multiplication
				param(3) = param(1) * param(2);
				i += 4;
			},
			3: () { // Input
				Fiber.yield();
				param(1) = io.back;
				io.removeBack();
				i += 2;
			},
			4: () { // Output
				io.insertBack(param(1));
				Fiber.yield();
				i += 2;
			},
			5: () { // Jump-if-true
				if (param(1))
					i = param(2);
				else
					i += 3;
			},
			6: () { // Jump-if-false
				if (!param(1))
					i = param(2);
				else
					i += 3;
			},
			7: () { // Less than
				param(3) = param(1) < param(2) ? 1 : 0;
				i += 4;
			},
			8: () { // Equals
				param(3) = param(1) == param(2) ? 1 : 0;
				i += 4;
			},
			99: () { complete = true; }
		][instruction]();
	}
}

void main() {
	const int[] program = File("input.txt", "r").readln.splitter(",").map!(to!int).array;

	int maxSignal = int.min;

	foreach (permutation; iota(5, 10).permutations) {
		Array!int io;
		Fiber[5] fibers;
		io.insertBack(permutation);

		foreach (ref fiber; fibers) { // Initialize fibers
			fiber = new Fiber(() => program.perform(io));
			fiber.call(); // Pauses for phase setting input
			fiber.call(); // Pauses for signal input
		}

		io.insertBack(0);

		size_t i = 0;
		while (fibers[].canFind!(f => f.state != Fiber.State.TERM)) {
			fibers[i++ % 5].call();
		}

		assert(io.length == 1);
		maxSignal = max(maxSignal, io.back);
	}

	maxSignal.writeln();
}
