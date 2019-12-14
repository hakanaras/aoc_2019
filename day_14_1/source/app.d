import std;

alias Chemical = string;
alias Qty = int;

struct ChemicalQty {
	Chemical chemical;
	Qty qty;
}

struct Reaction {
	ChemicalQty[] inputs;
	ChemicalQty output;
}

void main() {
	Reaction[Chemical] reactions;

	ChemicalQty toChemicalQty(char[] input) {
		ChemicalQty cq;
		input.strip.formattedRead!"%s %s"(cq.qty, cq.chemical);
		return cq;
	}

	void processLine(char[] line) {
		auto arrow = line.split("=>");
		Reaction reaction;
		reaction.output = toChemicalQty(arrow[1]);
		foreach (input; arrow[0].split(","))
			reaction.inputs ~= toChemicalQty(input);
		reactions[reaction.output.chemical] = reaction;
	}

	File("input.txt").byLine.each!processLine;

	Qty[Chemical] producedQty;
	Qty[Chemical] consumedQty;

	void addQty(ref Qty[Chemical] map, Chemical chemical, Qty qty) {
		map.update(chemical, () => qty, (Qty current) => current + qty);
	}

	Qty requiredOreQty(ChemicalQty cq)
	in(cq.qty > 0) {
		if (cq.chemical == "ORE")
			return cq.qty;

		const reaction = reactions[cq.chemical];
		const count = (1 + (cq.qty - 1) / reaction.output.qty);

		addQty(producedQty, cq.chemical, count * reaction.output.qty);
		addQty(consumedQty, cq.chemical, cq.qty);
		return reaction.inputs
			.map!(i => ChemicalQty(i.chemical, i.qty * count))
			.map!requiredOreQty
			.sum;
	}

	auto qty = requiredOreQty(ChemicalQty("FUEL", 1));
	auto que = Array!Chemical(producedQty.byKey);

	for (size_t i = 0; i < que.length; i++) {
		const chemical = que[i];
		const reaction = reactions[chemical];
		const surplus = producedQty[chemical] - consumedQty[chemical];
		if (surplus < reaction.output.qty)
			continue;
		const surplusReactions = surplus / reaction.output.qty;
		foreach (input; reaction.inputs) {
			if (input.chemical == "ORE") {
				qty -= surplusReactions * input.qty;
				continue;
			}
			if (!que[i + 1 .. $].canFind(input.chemical))
				que.insertBack(input.chemical);
			consumedQty[input.chemical] -= surplusReactions * input.qty;
		}
		producedQty[chemical] -= surplusReactions * reaction.output.qty;
	}
	writeln(qty);
}
