import std.stdio, std.algorithm, std.range, std.conv;

void main() {
	iota(197_487, 673_251).map!(to!string)
		.filter!(x => x.group.canFind!"a[1] == 2")
		.filter!(x => x.findAdjacent!"a > b".empty)
		.count
		.writeln;
}
