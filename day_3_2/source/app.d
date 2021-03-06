import std.stdio, std.algorithm, std.range, std.conv, std.array, std.typecons, std.math;

struct Point {
	int x, y;

	Point opBinary(string op : "+")(Point other) const {
		return Point(x + other.x, y + other.y);
	}

	uint manhattanDistance(Point other) const {
		return abs(x - other.x) + abs(y - other.y);
	}
}

struct Intersection {
	Point point;
	uint delay;
}

struct Line {
	Point begin, end;
	uint delay;

	uint delayTo(Point point) const {
		const delayBegin = delay - (abs(begin.x - end.x) + abs(begin.y - end.y));
		return delayBegin + (abs(begin.x - point.x) + abs(begin.y - point.y));
	}

	void normalize() {
		if (begin.x > end.x) {
			swap(begin.x, end.x);
		}
		if (begin.y > end.y) {
			swap(begin.y, end.y);
		}
	}

	Nullable!Intersection intersect(Line other) const {
		Line l1 = this, l2 = other;
		l1.normalize;
		l2.normalize;

		const none = typeof(return).init;

		if (l1.begin.x > l2.end.x)
			return none;
		if (l1.begin.y > l2.end.y)
			return none;
		if (l1.end.x < l2.begin.x)
			return none;
		if (l1.end.y < l2.begin.y)
			return none;

		const point = Point(max(l1.begin.x, l2.begin.x), max(l1.begin.y, l2.begin.y));

		return typeof(return)(Intersection(point, this.delayTo(point) + other.delayTo(point)));
	}
}

Line advance(Line previous, char[] step) pure {
	const direction = step[0];
	const distance = step[1 .. $].to!int;
	assert(distance > 0);
	// dfmt off
	return Line(
		previous.end,
		previous.end + [
			'U': Point(0, distance),
			'D': Point(0, -distance),
			'R': Point(distance, 0),
			'L': Point(-distance, 0)
		][direction],
		previous.delay + distance
	);
	// dfmt on
}

void main() {
	Line[][] lines = stdin.byLine.map!((stdinLine) {
		return stdinLine.splitter(",").cumulativeFold!advance(Line()).array;
	}).array;

	cartesianProduct(lines[0], lines[1]).map!"a[0].intersect(a[1])"
		.filter!"!a.isNull"
		.map!"a.delay"
		.drop(1).minElement.writeln;
}
