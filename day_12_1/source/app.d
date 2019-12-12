import std;

alias Unit = int;
alias Vec3 = int[3];
alias HashValue = Unit[8];
alias Set = RedBlackTree!(HashValue, (a, b) => cmp(a[], b[]) < 0);
struct CompState {
	bool done;
	Set hashes;
	uint repeat;
}

Vec3 parse_vec3(char[] input) pure {
	Vec3 v;
	input.formattedRead!"<x=%s, y=%s, z=%s>"(v[0], v[1], v[2]);
	return v;
}

HashValue hash(Moon[] moons, size_t i) {
	return [
		moons[0].position[i], moons[1].position[i], moons[2].position[i],
		moons[3].position[i], moons[0].velocity[i], moons[1].velocity[i],
		moons[2].velocity[i], moons[3].velocity[i]
	];
}

void main() {
	Moon[] moons = File("input.txt", "r").byLine.map!(l => Moon(l.parse_vec3)).array;

	CompState[Vec3.length] comps = [
		CompState(false, new Set), CompState(false, new Set),
		CompState(false, new Set)
	];
	size_t t = 0;
	while (!comps[].all!"a.done" || t < 1000) {
		foreach (i; 0 .. Vec3.length) {
			if (!comps[i].done && !comps[i].hashes.insert(moons.hash(i))) {
				comps[i].done = true;
				comps[i].repeat = t;
			}
		}
		foreach (i1; 0 .. moons.length) {
			foreach (i2; i1 + 1 .. moons.length) {
				Moon.gravitate(moons[i1], moons[i2]);
			}
			moons[i1].apply_velocity();
		}
		++t;
		if (t == 1000) {
			writeln("Total Energy after 1000 time steps: ", moons.fold!"a + b.total_energy"(0));
		}
	}
	comps[].map!"a.repeat"
		.each!writeln;
}

struct Moon {
	Vec3 position;
	Vec3 velocity;

	Unit total_energy() const {
		return position.fold!"a.abs + b.abs" * velocity.fold!"a.abs + b.abs";
	}

	void apply_velocity() {
		foreach (i; 0 .. Vec3.length)
			position[i] += velocity[i];
	}

	static void gravitate(ref Moon a, ref Moon b) {
		foreach (i; 0 .. Vec3.length) {
			const sign = sgn(b.position[i] - a.position[i]);
			a.velocity[i] += sign;
			b.velocity[i] -= sign;
		}
	}
}
