import std.stdio, std.file, std.algorithm, std.array, std.container, std.conv;

class Body {
	this(string name) {
		this.name = name;
	}

	string name;
	Body[] children;
}

Body load() {
	auto roots = new RedBlackTree!string;
	Body[string] bodies;

	File("input.txt", "r").byLine
		.map!(to!string)
		.each!((string line) {
			string[] parts = line.split(")");
			auto orbiter = bodies.require(parts[1], new Body(parts[1]));
			roots.removeKey(parts[1]);
			Body create() {
				roots.insert(parts[0]);
				Body root = new Body(parts[0]);
				root.children ~= orbiter;
				return root;
			}

			Body update(Body body) {
				body.children ~= orbiter;
				return 
				body;
			}

			bodies.update(parts[0], &create, &update);
		});

	assert(roots.length == 1);
	return bodies[roots.front];
}

uint countOrbits(Body root, uint level = 1) pure {
	return level * root.children.length + root.children.map!(x => countOrbits(x, level + 1)).sum;
}

void main() {
	countOrbits(load()).writeln;
}
