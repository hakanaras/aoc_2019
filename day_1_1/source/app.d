import std.stdio, std.conv, std.algorithm;

void main() {
	stdin.byLine.map!(x => x.to!int / 3 - 2).sum.writeln;
}
