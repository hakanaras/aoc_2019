module dijkstra;

import std;

int dijkstra(int delegate(int) pStep) {
    Coord initialPosition = Coord(0, 0);
    Coord position = initialPosition;

    Chart chart;
    PredecessorMap predecessor;
    DList!Coord queue;

    Coord oxygenCoords;

    int step(Coord target) {
        const dir = position.direction(target);
        const response = pStep(dir);
        if (response == empty || response == oxygen) {
            position = target;
        }
        return response;
    }

    void onEmptyBlock(Coord coord) {
        foreach (neighbour; coord.neighbours) {
            if (chart.queryBlock(neighbour) == uncharted && !queue[].canFind(neighbour)) {
                queue.insertBack(neighbour);
                predecessor[neighbour] = coord;
            }
        }
    }

    void backtrack() {
        while (position != initialPosition)
            step(predecessor.get(position, initialPosition));
    }

    void approach(Coord coord) {
        if (coord == position)
            return;
        const previousCoord = predecessor.get(coord, initialPosition);
        approach(previousCoord);
        if (previousCoord != position)
            step(previousCoord);
    }

    chart[initialPosition] = empty;
    onEmptyBlock(initialPosition);

    while (!queue.empty) {
        const target = queue.front;
        queue.removeFront();
        backtrack();
        approach(target);
        const response = step(target);
        chart[target] = response;
        final switch (response) {
        case empty:
            onEmptyBlock(position);
            break;
        case wall:
            break;
        case oxygen:
            oxygenCoords = target;
            break;
        }
    }

    assert(oxygenCoords != Coord.init);

    writeln("Calculating depth...");

    int[Coord] depth;
    void computeDepth(Coord from, int currentDepth = 0) {
        if (from in depth)
            return;
        const block = chart.get(from, uncharted);
        assert(block != uncharted);
        if (block == wall)
            return;
        depth.require(from, currentDepth);
        foreach (neighbour; from.neighbours) {
            computeDepth(neighbour, currentDepth + 1);
        }
    }

    computeDepth(oxygenCoords);
    return (depth.byValue.maxElement);
}

private:

alias Coord = Tuple!(int, int);
alias Chart = int[Coord];
alias PredecessorMap = Coord[Coord];
alias DistanceMap = int[Coord];

enum int north = 1;
enum int south = 2;
enum int west = 3;
enum int east = 4;

enum int uncharted = -1;
enum int wall = 0;
enum int empty = 1;
enum int oxygen = 2;

int queryBlock(Chart chart, Coord coord) {
    return chart.get(coord, uncharted);
}

void setBlock(ref Chart chart, Coord coord, int block) {
    chart[coord] = block;
}

int direction(Coord from, Coord to) {
    const x = to[0] - from[0];
    const y = to[1] - from[1];
    if (x == -1)
        return west;
    else if (x == 1)
        return east;
    else if (y == -1)
        return south;
    else if (y == 1)
        return north;
    else
        throw new Error(format!"Invalid predecessor: %s -> %s!"(from, to));
}

Coord[4] neighbours(Coord center) {
    return [
        Coord(center[0] + 1, center[1]), Coord(center[0] - 1, center[1]),
        Coord(center[0], center[1] + 1), Coord(center[0], center[1] - 1)
    ];
}

void render(Chart chart) {
    const minX = chart.byKey.minElement!"a[0]"[0];
    const maxX = chart.byKey.maxElement!"a[0]"[0];
    const minY = chart.byKey.minElement!"a[1]"[1];
    const maxY = chart.byKey.maxElement!"a[1]"[1];
    writeln('-'.repeat(maxX - minX));
    foreach (y; minY .. maxY + 1) {
        string row = "";
        foreach (x; minX .. maxX + 1) {
            final switch (chart.get(Coord(x, y), uncharted)) {
            case uncharted:
                row ~= "?";
                break;
            case wall:
                row ~= "#";
                break;
            case empty:
                row ~= " ";
                break;
            case oxygen:
                row ~= "O";
                break;
            }
        }
        writeln(row);
    }
}
