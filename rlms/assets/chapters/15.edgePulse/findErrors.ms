check = function
	inNode = sim.nodeAtXY(12, 32)
	if not inNode then return "Expected input node IN not found."
	out1 = sim.nodeAtXY(68, 32)
	if not out1 then return "Expected top output node not found."
	out1.name = "Top output"
	
	inNode.setOn false
	sim.simulate
	
	if out1.on then return out1.name + " is on when it should be off."

	inNode.setOn true
	for i in range(9)
		sim.simulate 1
		if out1.on then break
	end for
	if not out1.on then return out1.name + " failed to come on when IN went from low to high."
	sim.simulate 3
	if out1.on then return out1.name + " stayed on too long."
	
	inNode.setOn false
	for i in range(9)
		sim.simulate 1
		if out1.on then return out1.name + " came on when IN went from high to low."
	end for	
	
	return ""
end function
