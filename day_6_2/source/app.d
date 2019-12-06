import std.stdio, std.file, std.algorithm, std.array, std.container, std.conv, std.typecons;

class Body {
	this(string name) {
		this.name = name;
	}

	void attachOrbiter(Body orbiter) {
		orbiter.parent = this;
		children ~= orbiter;
	}

	Body parent;
	string name;
	Body[] children;
}

Body[string] load() {
	Body[string] result;

	File("input.txt", "r").byLine
		.map!(to!string)
		.each!((string line) {
			string[] parts = line.split(")");
			auto orbiter = result.require(parts[1], new Body(parts[1]));
			result.update(parts[0], () {
				Body root = new Body(parts[0]);
				root.attachOrbiter(orbiter);
				return root;
			}, (Body root) { root.attachOrbiter(orbiter); return root; });
		});

	return result;
}

alias Distance = Nullable!uint;

Distance distanceToDescendant(Body root, Body descendant) pure {
	if (root is descendant)
		return Distance(0);
	foreach (child; root.children) {
		Distance byChild = child.distanceToDescendant(descendant);
		if (!byChild.isNull) {
			return Distance(byChild + 1);
		}
	}
	return Distance.init;
}

Distance distance(Body from, Body to) pure {
	Distance result = from.distanceToDescendant(to);
	if (!result.isNull)
		return result;
	result = from.parent.distance(to);
	if (result.isNull)
		return result;
	else
		return Distance(result + 1);
}

void main() {
	auto bodies = load();

	distance(bodies["YOU"].parent, bodies["SAN"].parent).writeln;
}
