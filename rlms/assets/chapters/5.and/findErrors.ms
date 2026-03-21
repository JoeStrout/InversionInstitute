check = function
	nodeA = sim.nodeAtXY(4, 44)
	if not nodeA then return "Expected node A not found."
	nodeB = sim.nodeAtXY(4, 23)
	if not nodeB then return "Expected node B not found."
	nodeG = sim.nodeAtXY(76, 34)
	if not nodeG then return "expected node G not found."

	nodeA.setOn false; nodeB.setOn false
	sim.simulate
	if nodeG.on then return "G should be off when A and B are off."

	nodeA.setOn true; nodeB.setOn false
	sim.simulate
	if nodeG.on then return "G should be off when B is off."

	nodeA.setOn false; nodeB.setOn true
	sim.simulate
	if nodeG.on then return "G should be off when A is off."

	nodeA.setOn true; nodeB.setOn true
	sim.simulate
	if not nodeG.on then return "G should be on when A and B are on."
	
	return ""
end function
