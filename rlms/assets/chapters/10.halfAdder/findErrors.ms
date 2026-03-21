check = function
	nodeA = sim.nodeAtXY(4, 42)
	if not nodeA then return "Expected node A not found."
	nodeB = sim.nodeAtXY(4, 26)
	if not nodeB then return "expected node B not found."
	node1 = sim.nodeAtXY(75, 42)
	if not node1 then return "expected node 1 not found."
	node2 = sim.nodeAtXY(75, 26)
	if not node2 then return "expected node 2 not found."

	node1.setOn false; node2.setOn false; nodeA.setOn false; nodeB.setOn false	
	sim.simulate
	if node1.on then return "1 lights up when A and B are both off."
	if node2.on then return "2 lights up when A and B are both off."

	nodeA.setOn true; nodeB.setOn false; sim.simulate
	if nodeB.on or not nodeA.on then return "A and B should not affect each other."
	if not node1.on then return "1 fails to light when only A is on."
	if node2.on then return "2 lights up when only A is on."

	nodeA.setOn false; nodeB.setOn true; sim.simulate
	if nodeA.on or not nodeB.on then return "A and B should not affect each other."
	if not node1.on then return "1 fails to light when only B is on."
	if node2.on then return "2 lights up when only B is on."

	nodeA.setOn true; nodeB.setOn true; sim.simulate
	if node1.on then return "1 lights up when both A and B are on."
	if not node2.on then return "2 fails to light when both A and B are on."
	
	return ""
end function
