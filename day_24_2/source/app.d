import std;

void main() {
	auto rooms = Rooms!char("input.txt");

	foreach (_; 0 .. 200)
		rooms.tickMinute();

	writeln(rooms[].count!(cell => cell == '#'));
}

struct Rooms(C = char, C space = '.', C bug = '#', int size = 5) {
	static assert(size % 2 == 1 && size > 1);
	enum center = size / 2;
	enum minutesPerLevel = size / 2;

	alias Cells = Array!(C[][]);

	@disable this();

	this(string filename) {
		currentCells.insert(File(filename).byLine.map!(l => l.dup[0 .. size]).array);
		nextCells.insert(emptyCellLevel());
	}

	void tickMinute() {
		if ((++minute - 1) % minutesPerLevel == 0) {
			growStates();
		}
		foreach (p; positions) {
			const currentCell = current(p[0], p[1], p[2]);
			const bugNeighbourCount = neighbours(p[0], p[1], p[2]).count!(n => n == bug);
			if (currentCell == bug && bugNeighbourCount != 1)
				next(p[0], p[1], p[2]) = space;
			else if (currentCell == space && (bugNeighbourCount == 1 || bugNeighbourCount == 2))
				next(p[0], p[1], p[2]) = bug;
			else
				next(p[0], p[1], p[2]) = currentCell;
		}
		swap(currentCells, nextCells);
	}

	auto opSlice() const {
		return positions.map!(p => current(p[0], p[1], p[2]));
	}

private:

	Cells currentCells, nextCells;
	int lowestLevel, highestLevel;
	size_t minute;

	invariant(currentCells.length == nextCells.length);
	invariant(currentCells.length == highestLevel - lowestLevel + 1);

	static bool validIndex(int row, int column) pure {
		return row >= 0 && row < size && column >= 0 && column < size
			&& (row != center || column != center);
	}

	C current(int level, int row, int column) const
	in(validIndex(row, column))
	out(r; r == space || r == bug) {
		if (level < lowestLevel || level > highestLevel)
			return space;
		return currentCells[level - lowestLevel][row][column];
	}

	ref C next(int level, int row, int column)
	in(validIndex(row, column))
	in(level >= lowestLevel && level <= highestLevel) {
		return nextCells[level - lowestLevel][row][column];
	}

	static C[][] emptyCellLevel() {
		auto result = new C[][](size, size);
		foreach (line; result)
			foreach (ref x; line)
				x = space;
		return result;
	}

	void growStates() {
		lowestLevel--;
		highestLevel++;
		currentCells.insertBefore(currentCells[0 .. $], emptyCellLevel());
		currentCells.insertBack(emptyCellLevel());
		nextCells.insertBefore(nextCells[0 .. $], emptyCellLevel());
		nextCells.insertBack(emptyCellLevel());
	}

	auto positions() const {
		return cartesianProduct(iota(lowestLevel, highestLevel + 1), size.iota, size.iota).filter!(
				p => validIndex(p[1], p[2]));
	}

	auto neighbours(int level, int row, int column) const {
		C[] result = [];
		if (row == 0) {
			result ~= current(level - 1, center - 1, center);
		}
		if (row == size - 1) {
			result ~= current(level - 1, center + 1, center);
		}
		if (column == 0) {
			result ~= current(level - 1, center, center - 1);
		}
		if (column == size - 1) {
			result ~= current(level - 1, center, center + 1);
		}
		if (row == center - 1 && column == center) {
			result ~= size.iota.map!(i => current(level + 1, 0, i)).array;
		}
		if (row == center + 1 && column == center) {
			result ~= size.iota.map!(i => current(level + 1, size - 1, i)).array;
		}
		if (column == center - 1 && row == center) {
			result ~= size.iota.map!(i => current(level + 1, i, 0)).array;
		}
		if (column == center + 1 && row == center) {
			result ~= size.iota.map!(i => current(level + 1, i, size - 1)).array;
		}

		static immutable neighbourOffsets = [[-1, 0], [1, 0], [0, -1], [0, 1]];
		result ~= neighbourOffsets.map!(o => [row + o[0], column + o[1]])
			.filter!(ij => validIndex(ij[0], ij[1]))
			.map!(ij => current(level, ij[0], ij[1]))
			.array;

		return result;
	}

}
