check = function
	nodeA = sim.nodeAtXY(3, 32)
	if not nodeA then return "Expected node A not found."
	nodeB = sim.nodeAtXY(64, 32)
	if not nodeB then return "expected node B not found."

	nodeA.setOn true; sim.simulate
	if not nodeB.on then return "A-on did not cause B-on."

	nodeB.setOn false; sim.simulate
	if not nodeB.on then return "Touching B changes its state."

	nodeA.setOn false; sim.simulate
	if nodeB.on then return "A-off did not cause B-off."

	nodeB.setOn true; sim.simulate
	if nodeB.on then return "Touching B changes its state."
	return ""
end function
