module app;

import std;
import ascii = std.ascii;

void main() {
	auto nodes = loadInputNodes("input.txt");
	auto shortest = shortestPaths(nodes);

	struct Instance {
		Node[] nodes;
		Cell[][] cells;

		int distance(Node a, Node b) {
			return cells[a.index][b.index].distance;
		}

		int distanceByDoors(Node a, Node b) {
			return cells[a.index][b.index].distance_by_doors;
		}
	}

	solve(Instance(shortest.nodes, shortest.cells));

}

int solve(Arg)(Arg arg) {
	Node[] required = arg.nodes.filter!(n => n.type == Node.Type.Key).array;

	int upperBound = int.max;

	struct Step {
		Node node;
		int lowerBound;
		Array!Node moves;
	}

	Array!Step path;

	bool hasFoundNewKeys(size_t fromIndex) {
		outer: foreach (f; fromIndex + 1 .. path.length) {
			if (path[f].node.type != Node.Type.Key)
				continue;
			foreach_reverse (b; 0 .. fromIndex) {
				if (path[b].node is path[f].node)
					continue outer;
			}
			return true;
		}
		return false;
	}

	auto sortedPotentialMoves() {
		auto neighbours = path.back.node.neighbours[].filter!(n => n.type != Node.Type.Spawn);

		auto noImpassableDoors = neighbours.filter!(n => n.type != Node.Type.Door
				|| path[].map!(p => p.node.name.isNull ? ' ' : p.node.name.get).canFind(n.name.get));

		auto nonRepeats = noImpassableDoors.save.filter!(n => !path[].map!"a.node".canFind(n));

		bool validRepeat(Node node) {
			if (node.type != Node.Type.Door)
				return false;
			foreach_reverse (i; 0 .. path.length) {
				if (path[i].node !is node)
					continue;
				return hasFoundNewKeys(i);
			}
			assert(0);
		}

		auto repeats = noImpassableDoors.filter!(n => path[].map!"a.node".canFind(n))
			.filter!validRepeat;

		return nonRepeats.chain(repeats);
	}

	Node[] getMissingKeys() {
		return required.filter!(n => !path[].map!"a.node".canFind(n)).array;
	}

	int calculateLowerBound() {
		int result = 0;
		foreach (i; 1 .. path.length) {
			result += arg.distance(path[i - 1].node, path[i].node);
		}
		Node[] missingKeys = getMissingKeys();
		if (missingKeys.length < 2)
			return result;
		int largestMinimumDistance = int.min;
		foreach (i1; 0 .. missingKeys.length) {
			foreach (i2; i1 + 1 .. missingKeys.length) {
				largestMinimumDistance = max(largestMinimumDistance,
						arg.distanceByDoors(missingKeys[i1], missingKeys[i2]));
			}
		}
		return result + largestMinimumDistance;
	}

	bool takeNextStep() {
		while (path.back.moves.empty) {
			path.removeBack();
			if (path.empty) {
				return false;
			}
		}
		auto move = path.back.moves.back;
		path.back.moves.removeBack();
		path.insertBack(Step(move));
		path.back.lowerBound = calculateLowerBound();
		if (path.back.lowerBound > upperBound)
			return true;
		path.back.moves.insert(sortedPotentialMoves());
		return true;
	}

	auto spawn = arg.nodes.find!(n => n.type == Node.Type.Spawn).front;

	path.insert(Step(spawn));
	path.back.moves.insert(sortedPotentialMoves());

	while (true) {
		if (!takeNextStep())
			break;
		if (getMissingKeys().length == 0 && upperBound > path.back.lowerBound) {
			upperBound = path.back.lowerBound;
			path[].map!q{ a.node.name.isNull ? '-' : a.node.name.get }.writeln();
			writeln(upperBound);
		}
	}

	return upperBound;
}

class Node {
	alias Name = Nullable!char;

	this(char c) {
		if (ascii.isAlpha(c)) {
			if (ascii.isLower(c)) {
				type = Type.Key;
				name = Name(c);
			} else {
				type = Type.Door;
				name = Name(ascii.toLower(c));
			}
		} else if (c == '@') {
			type = Type.Spawn;
		} else if (c == '.') {
			type = Type.Passage;
		} else if (c == '#') {
			type = Type.Wall;
		} else {
			assert(0);
		}
	}

	static void connect(Node n1, Node n2) {
		if (n1.type == Type.Wall || n2.type == Type.Wall)
			return;
		n1.neighbours ~= n2;
		n2.neighbours ~= n1;
	}

	enum Type {
		Key,
		Door,
		Passage,
		Wall,
		Spawn
	}

	Type type;
	size_t index;
	Name name;
	Array!Node neighbours;

	invariant(name.isNull || ascii.isLower(name.get));
	invariant((type == Type.Key || type == Type.Door) == !name.isNull);

	bool freelyPassable() {
		return type == Type.Key || type == Type.Passage || type == Type.Spawn;
	}

	override string toString() const {
		return type.to!string ~ (name.isNull ? "" : ": " ~ name.get);
	}
}

auto loadInputNodes(string filename) {
	Node[] inputNodes = File(filename).byLine
		.map!"a.dup"
		.array
		.parseNodes
		.join
		.filter!"a.neighbours.length > 0"
		.array;

	foreach (i; 0 .. inputNodes.length)
		inputNodes[i].index = i;

	return inputNodes;
}

Node[][] parseNodes(char[][] input) {
	Node[][] nodes = [];
	foreach (r; 0 .. input.length) {
		nodes ~= cast(Node[])[];
		foreach (c; 0 .. input[r].length) {
			if (ascii.isWhite(input[r][c]))
				continue;
			nodes[r] ~= new Node(input[r][c]);
			if (r > 0)
				Node.connect(nodes[r][c], nodes[r - 1][c]);
			if (c > 0)
				Node.connect(nodes[r][c], nodes[r][c - 1]);
		}
	}
	return nodes;
}

enum infinity = 100_000;

struct Cell {
	int distance = infinity;
	int distance_by_doors = infinity;
}

// Applies Floyd-Warshall to find the shortest paths between all input nodes
auto shortestPaths(Node[] nodes) {
	static struct Result {
		Node[] nodes;
		Cell[][] cells;
	}

	Cell[][] cells = new Cell[][](nodes.length, nodes.length);

	foreach (node; nodes) {
		foreach (neighbour; node.neighbours) {
			cells[node.index][neighbour.index] = Cell(1, 1);
		}
		cells[node.index][node.index] = Cell(0, 0);
	}

	foreach (k; 0 .. nodes.length) {
		foreach (i; 0 .. nodes.length) {
			foreach (j; 0 .. nodes.length) {
				if (nodes[k].freelyPassable
						&& cells[i][j].distance > cells[i][k].distance + cells[k][j].distance)
					cells[i][j].distance = cells[i][k].distance + cells[k][j].distance;
				if (
					cells[i][j].distance_by_doors > cells[i][k].distance_by_doors
						+ cells[k][j].distance_by_doors)
					cells[i][j].distance_by_doors = cells[i][k].distance_by_doors
						+ cells[k][j].distance_by_doors;
			}
		}
	}

	with (Node.Type) {
		Node[] relevant = nodes.filter!(n => [Spawn, Key, Door].canFind(n.type)).array;
		Cell[][] relevantCells = new Cell[][](relevant.length, relevant.length);
		foreach (i1; 0 .. relevant.length) {
			auto n1 = relevant[i1];
			foreach (i2; i1 + 1 .. relevant.length) {
				auto n2 = relevant[i2];
				relevantCells[i1][i2] = cells[n1.index][n2.index];
				relevantCells[i2][i1] = cells[n2.index][n1.index];
			}
			n1.index = i1;
			n1.neighbours.clear();
		}
		foreach (i1; 0 .. relevant.length) {
			auto n1 = relevant[i1];
			foreach (i2; i1 + 1 .. relevant.length) {
				auto n2 = relevant[i2];
				const distance = relevantCells[i1][i2].distance;
				if (distance == 0 || distance == infinity)
					continue;
				n1.neighbours.insertBack(n2);
				n2.neighbours.insertBack(n1);
			}
		}
		return Result(relevant, relevantCells);
	}
}
