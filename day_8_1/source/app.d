import std;

void main() {
	const width = 25, height = 6;
	alias Stats = Tuple!(uint, "zeroes", uint, "ones", uint, "twos");

	auto layers = File("input.txt", "r").readln.chunks(width * height);

	auto stats = layers.map!((layer) {
		return layer.fold!((stats, digit) {
			stats.zeroes += (digit == '0' ? 1 : 0);
			stats.ones += (digit == '1' ? 1 : 0);
			stats.twos += (digit == '2' ? 1 : 0);
			return stats;
		})(Stats());
	});

	auto minZeroesStat = stats.minElement!"a.zeroes";

	writeln(minZeroesStat.ones * minZeroesStat.twos);
}
