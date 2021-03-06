import std, core.thread;

alias Value = BigInt;

void perform(const Value[] program, ref Array!Value io) {
	Array!Value states;
	states.insertBack(program[]);
	Value relativeBase = 0;

	ref Value state(Value index) {
		size_t stIndex = cast(size_t) index.toLong;
		if (stIndex >= states.length)
			states.length = stIndex + 1;
		return states[stIndex];
	}

	bool complete;
	for (Value i = 0; !complete && i < states.length;) {
		const instruction = state(i) % 100;
		alias mode = (p) => state(i) % (100 * pow(10, p)) / (100 * pow(10, p - 1));
		ref Value param(size_t p) {
			final switch (mode(p)) {
			case 0:
				return state(state(i + p));
			case 1:
				return state(i + p);
			case 2:
				return state(relativeBase + state(i + p));
			}
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
				while (io.empty)
					Fiber.yield();
				param(1) = io.back;
				io.removeBack();
				i += 2;
			},
			4: () { // Output
				write(param(1).toInt.to!char);
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
			9: () { // Adjust relative base
				relativeBase += param(1);
				i += 2;
			},
			99: () { complete = true; }
		][instruction]();
	}
}

void main() {
	Array!Value io;
	const Value[] program = File("input.txt", "r").readln.splitter(",").map!(to!Value).array;

	auto fiber = new Fiber(() => program.perform(io));
	fiber.call();
	while (fiber.state != Fiber.State.TERM) {
		string input = readln();
		ubyte[] bytes = (cast(ubyte[]) input).reverse();

		io.insert(bytes.map!(b => b.to!Value));

		fiber.call();
	}
}
