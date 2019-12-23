import std;

void main() {
	const maze = new Maze("input.txt");

	struct QueEntry {
		const(Maze.Node) predecessor;
		const(Maze.Node) node;
		int depth;
	}

	DList!QueEntry bfsQue;
	bfsQue.insertBack(QueEntry(null, maze.start, 0));

	while (!bfsQue.empty) {
		auto current = bfsQue.front;
		bfsQue.removeFront();

		if (current.node is maze.end) {
			writeln("Distance: ", current.depth);
			return;
		}

		bfsQue.insertBack(current.node.neighbours[].filter!(n => n !is current.predecessor)
				.map!(n => QueEntry(current.node, n, current.depth + 1)));
	}
	assert(0, "No path found!");
}

class Maze {
	import ascii = std.ascii;

	Node start;
	Node end;
	Node[Tuple!(int, int)] nodes;

	private void setNode(Node node, int row, int column) {
		nodes[tuple(row, column)] = node;
		auto above = tuple(row - 1, column) in nodes;
		auto left = tuple(row, column - 1) in nodes;
		if (above !is null)
			node.connect(*above);
		if (left !is null)
			node.connect(*left);

	}

	private void resolvePortals() {
		Node[string] pending;
		foreach (ii, node; nodes) {
			auto asPortal = cast(Portal) node;
			if (asPortal is null)
				continue;
			assert(asPortal.neighbours.length <= 1);
			if (asPortal.neighbours.length == 0)
				continue;
			auto neighbour = asPortal.neighbours.front;
			neighbour.disconnect(asPortal);
			if (asPortal.name == "AA") {
				start = neighbour;
			} else if (asPortal.name == "ZZ") {
				end = neighbour;
			} else if (asPortal.name in pending) {
				pending[asPortal.name].connect(neighbour);
				pending.remove(asPortal.name);
			} else {
				pending[asPortal.name] = neighbour;
			}
		}
		assert(pending.empty);
	}

	this(string filename) {
		char[][] lines = File(filename).byLine.map!"a.dup".array;

		alias cell = (i, j) {
			if (i < 0 || i >= lines.length)
				return ' ';
			auto line = lines[i];
			if (j < 0 || j >= line.length)
				return ' ';
			return line[j];
		};

		foreach (i; 0 .. lines.length) {
			foreach (j; 0 .. lines[i].length) {
				dchar above = cell(i - 1, j);
				dchar left = cell(i, j - 1);
				dchar c = cell(i, j);

				if (ascii.isWhite(c))
					continue;

				else if (c == '.')
					setNode(new Passage, i, j);

				else if (ascii.isAlpha(c)) {
					if (ascii.isAlpha(above)) {
						auto portal = new Portal([c, above]);
						setNode(portal, i, j);
						setNode(portal, i - 1, j);
					} else if (ascii.isAlpha(left)) {
						auto portal = new Portal([c, left]);
						setNode(portal, i, j);
						setNode(portal, i, j - 1);
					} else {
						continue;
					}
				}
			}
		}

		resolvePortals();
	}

	abstract class Node {
		Array!Node neighbours;

		void connect(Node other) {
			neighbours.insert(other);
			other.neighbours.insert(this);
		}

		void disconnect(Node other) {
			neighbours.linearRemove(neighbours[].find(other).takeExactly(1));
			other.neighbours.linearRemove(other.neighbours[].find(this).takeExactly(1));
		}
	}

	class Passage : Node {

	}

	class Portal : Node {
		this(dchar[] characters) {
			this.name = characters. /*sort().*/ to!string;
		}

		string name;
	}
}
