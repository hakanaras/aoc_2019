import std.stdio, std.functional, std.conv, std.algorithm, std.range, std.typecons;

void main() {
	alias fuel = mass => mass / 3 - 2;

	stdin.byLine.map!(x => fuel(x.to!int).recurrence!((s, n) => fuel(s[n - 1]))
			.until!"a <= 0"
			.sum).sum.writeln;
}
