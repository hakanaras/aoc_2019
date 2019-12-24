import std;

alias Rating = long;

void main() {
	char[][] state = File("input.txt").byLine.map!"a.dup[0..5]".array;
	char[][] next = new char[][](5, 5);

	auto pastRatings = new RedBlackTree!Rating;

	while (true) {
		if (!pastRatings.insert(state.biodiversity)) {
			writeln("Repeating rating: ", state.biodiversity);
			return;
		}
		tick(state, next);
		swap(state, next);
	}
}

void tick(const(char[][]) before, char[][] after) {
	alias cell = (i, j) {
		if (i < 0 || i >= before.length)
			return '.';
		const line = before[i];
		if (j < 0 || j >= line.length)
			return '.';
		return line[j];
	};

	alias neighbours = (i, j) {
		static immutable neighbourOffsets = [[-1, 0], [1, 0], [0, -1], [0, 1]];
		return neighbourOffsets.map!(o => cell(i + o[0], j + o[1]));
	};

	foreach (i; 0 .. before.length) {
		foreach (j; 0 .. before[i].length) {
			const center = before[i][j];
			const bugNeighbourCount = neighbours(i, j).filter!(n => n == '#').count;
			if (center == '#' && bugNeighbourCount != 1)
				after[i][j] = '.';
			else if (center == '.' && (bugNeighbourCount == 1 || bugNeighbourCount == 2))
				after[i][j] = '#';
			else
				after[i][j] = center;
		}
	}
}

Rating biodiversity(char[][] state) {
	static immutable cellValue = 25.iota.map!"2.pow(a)".array;
	return state.joiner
		.enumerate
		.filter!"a[1] == '#'"
		.map!(en => cellValue[en[0]])
		.sum;
}
