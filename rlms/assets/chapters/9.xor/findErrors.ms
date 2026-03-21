check = function
	nodeF = sim.nodeAtXY(4, 38)
	if not nodeF then return "Expected node F not found."
	nodeC = sim.nodeAtXY(4, 24)
	if not nodeC then return "expected node C not found."
	nodeX = sim.nodeAtXY(73, 31)
	if not nodeX then return "expected node X not found."

	nodeX.setOn false; nodeF.setOn false; nodeC.setOn false	
	sim.simulate
	if nodeX.on then return "X lights up when F and C are both off."

	nodeC.setOn false; nodeF.setOn true; sim.simulate
	if nodeC.on then return "F and C should not be directly connected."
	if not nodeX.on then return "X did not light up when F is on but C is off."

	nodeF.setOn true; nodeC.setOn true; sim.simulate
	if nodeX.on then return "X lights up when F and C are both on."

	nodeF.setOn false; nodeC.setOn true; sim.simulate
	if nodeF.on then return "F and C should not be directly connected."
	if not nodeX.on then return "X did not light up when F is off but C is on."
	
	return ""
end function
