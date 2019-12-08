import std;

void main() {
	const width = 25, height = 6;
	auto layers = File("input.txt", "r").readln.chunks(width * height).array;

	auto message = (width * height).iota.map!((i) {
		dchar digit = '2';
		foreach (ref layer; layers) {
			if (digit == '2')
				digit = layer.front;
			layer.popFront();
		}
		return digit;
	});

	message.chunks(width).joiner("\n").writeln;
}
