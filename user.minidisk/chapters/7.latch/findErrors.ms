check = function
	nodeSet = sim.nodeAtXY(8, 45)
	if not nodeSet then return "Expected node SET not found."
	nodeRst = sim.nodeAtXY(8, 26)
	if not nodeRst then return "Expected node RST not found."
	nodeOut = sim.nodeAtXY(73, 37)
	if not nodeOut then return "expected node OUT not found."

	nodeSet.setOn false; nodeRst.setOn false; nodeOut.setOn false
	sim.simulate

	nodeSet.setOn true; nodeSet.held = true
	sim.simulate; nodeSet.setOn false; nodeSet.held = false; sim.simulate
	if not nodeOut.on then return "OUT did not stay on after pressing SET."
	if nodeRst.on then return "Pressing SET should not light up RST."

	nodeRst.setOn true; nodeRst.held = true
	sim.simulate; nodeRst.setOn false; nodeRst.held = false; sim.simulate
	if nodeOut.on then return "OUT did not turn off after pressing RST."
	if nodeSet.on then return "Pressing RST should not light up SET."

	return ""
end function
