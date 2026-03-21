check = function
	nodeF = sim.nodeAtXY(4, 38)
	if not nodeF then return "Expected node F not found."
	nodeC = sim.nodeAtXY(4, 24)
	if not nodeC then return "expected node C not found."
	nodeL = sim.nodeAtXY(68, 31)
	if not nodeL then return "expected node L not found."
	nodeL.setOn false
	nodeF.setOn false
	nodeC.setOn false	
	sim.simulate
	if nodeL.on then return "L lights up without F or C on."

	nodeC.setOn false; nodeF.setOn true; sim.simulate
	if nodeC.on then return "F and C should not be directly connected."
	if not nodeL.on then return "F-on did not cause L-on."

	nodeF.setOn true; nodeC.setOn true; sim.simulate
	if not nodeL.on then return "Both F and C on did not cause L-on."

	nodeF.setOn false; nodeC.setOn true; sim.simulate
	if nodeF.on then return "F and C should not be directly connected."
	if not nodeL.on then return "C-on did not cause L-on."
	
	return ""
end function
