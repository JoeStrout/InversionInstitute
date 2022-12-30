check = function
	in1 = sim.nodeAtXY(3, 49)
	if not in1 then return "Expected input node 1 not found."
	in2 = sim.nodeAtXY(3, 37)
	if not in2 then return "Expected input node 2 not found."
	in4 = sim.nodeAtXY(3, 25)
	if not in4 then return "Expected input node 4 not found."

	outs = []
	outs.push sim.nodeAtXY(77, 25)
	outs.push sim.nodeAtXY(70, 30)
	outs.push sim.nodeAtXY(62, 25)
	outs.push sim.nodeAtXY(70, 18)
	outs.push sim.nodeAtXY(62, 11)
	outs.push sim.nodeAtXY(70, 4)
	outs.push sim.nodeAtXY(77, 11)
	for i in outs.indexes
		if not outs[i] then return "Expected output node " + i + " not found."
	end for

	// define what the digits look like, as a list of on/off values
	// corresponding to our 'outs' segments.
	digit = []
	digit.push [1, 1, 1, 0, 1, 1, 1]		// 0
	digit.push [1, 0, 0, 0, 0, 0, 1]		// 1
	digit.push [1, 1, 0, 1, 1, 1, 0]		// 2
	digit.push [1, 1, 0, 1, 0, 1, 1]		// 3
	digit.push [1, 0, 1, 1, 0, 0, 1]		// 4
	digit.push [0, 1, 1, 1, 0, 1, 1]		// 5
	digit.push [0, 1, 1, 1, 1, 1, 1]		// 6
	digit.push [1, 1, 0, 0, 0, 0, 1]		// 7
	
	for testVal in range(0, 7)
		in1.setOn testVal % 2
		in2.setOn floor(testVal/2) % 2
		in4.setOn floor(testVal/4)
		sim.simulate
		for seg in outs.indexes
			if outs[seg].on != digit[testVal][seg] then
				return "The display for these inputs should look like a " + testVal + "."
			end if
		end for
	end for
	
	return ""
end function
