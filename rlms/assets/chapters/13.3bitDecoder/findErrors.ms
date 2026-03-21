check = function
	in1 = sim.nodeAtXY(3, 49)
	if not in1 then return "Expected input node 1 not found."
	in2 = sim.nodeAtXY(3, 37)
	if not in2 then return "Expected input node 2 not found."
	in4 = sim.nodeAtXY(3, 25)
	if not in4 then return "Expected input node 4 not found."

	outs = []
	for i in range(0,7)
		outs.push sim.nodeAtXY(12 + i*6, 3)
	end for
	for i in outs.indexes
		if not outs[i] then return "Expected output node " + i + " not found."
	end for

	for testVal in range(0, 7)
		in1.setOn testVal % 2
		in2.setOn floor(testVal/2) % 2
		in4.setOn floor(testVal/4)
		sim.simulate
		for i in outs.indexes
			if i == testVal and not outs[i].on then
				return "Output " + i + " should be on with these inputs."
			else if i != testVal and outs[i].on then
				return "Output " + i + " should be off with these inputs."
			end if
		end for
	end for
	
	return ""
end function
