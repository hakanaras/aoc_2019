import std;

alias Card = long;

struct Deck {
	private {
		Array!Card cards;
		Array!Card table;
	}

	this(Stuff)(Stuff stuff) {
		cards.insert(stuff);
		table.length = cards.length;
	}

	auto opSlice() const {
		return cards[];
	}

	void dealIntoNewStack() {
		foreach (i; 0 .. cards.length / 2) {
			swap(cards[i], cards[$ - i - 1]);
		}
	}

	void cut(int n) {
		if (n >= 0) {
			cards.insertBack(cards[0 .. n]);
			cards.linearRemove(cards[0 .. n]);
		} else {
			auto backCards = cards[$ + n .. $].array;
			cards.insertBefore(cards[0 .. $], backCards);
			cards.linearRemove(cards[$ + n .. $]);
		}
	}

	void dealWithIncrement(int n) {
		foreach (i; 0 .. cards.length) {
			table[(i * n) % table.length] = cards[i];
		}
		cards.clear();
		cards.insert(table[]);
	}

	invariant(cards.length == table.length);

	@disable this();
}

void part1() {
	Deck deck = Deck(10_007.iota);
	foreach (line; File("input.txt").byLine.map!(l => l.to!string.strip)) {
		if (line.startsWith("deal with increment ")) {
			const n = line["deal with increment ".length .. $].to!int;
			deck.dealWithIncrement(n);
		} else if (line.startsWith("deal into new stack")) {
			deck.dealIntoNewStack();
		} else if (line.startsWith("cut ")) {
			const n = line["cut ".length .. $].to!int;
			deck.cut(n);
		}
	}
	foreach (i, card; deck[].enumerate) {
		if (card == 2019) {
			writeln(i);
			break;
		}
	}
}

struct Line {
	enum Type {
		Increment,
		New,
		Cut
	}

	Type type;
	Card n;
}

Line[] parseLines(string filename) {
	auto textLines = File(filename).byLine.map!(l => l.to!string.strip).array;

	Line[] lines;

	foreach (textLine; textLines) {
		if (line.startsWith("deal with increment ")) {
			lines ~= Line(Line.Type.Increment, line["deal with increment ".length .. $].to!int);
		} else if (line.startsWith("deal into new stack")) {
			lines ~= Line(Line.Type.New);
		} else if (line.startsWith("cut ")) {
			lines ~= Line(Line.Type.Cut, line["cut ".length .. $].to!int);
		}
	}

	return lines;
}

void part2() {
	enum Card cardCount = 119_315_717_514_047;
	enum Card shuffleCount = 101_741_582_076_661;

	Card index = 2020;

	Line[] lines = parseLines("input.txt");

	foreach (_; 0 .. shuffleCount) {
		foreach_reverse (line; lines) {
			if (line.type == Line.Type.New) {
				index = cardCount - 1 - index;
			} else if (line.type == Line.Type.Increment) {
				const wrapAroundAt = 1 + cardCount / n;
			} else if (line.type == Line.Type.Cut) {

			}
		}
	}

	writeln(currentPosition);
}

void main() {
	part2();
}
