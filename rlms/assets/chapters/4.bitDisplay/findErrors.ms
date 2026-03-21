check = function
	nodeI = sim.nodeAtXY(4, 25)
	if not nodeI then return "Expected node I not found."
	nodeC = sim.nodeAtXY(67, 35)
	if not nodeC then return "Expected node C not found."
	node1 = sim.nodeAtXY(76, 35)
	if not node1 then return "expected node 1 not found."

	nodeI.setOn false
	sim.simulate
	if not nodeC.on or not node1.on then return "Display doesn't show 0 when I is off."

	nodeI.setOn true
	sim.simulate
	if nodeC.on or not node1.on then return "Display doesn't show 1 when I is on."
	
	return ""
end function
