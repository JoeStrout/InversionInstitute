check = function
	inR = sim.nodeAtXY(4, 52)
	if not inR then return "Expected input node R not found."
	inY = sim.nodeAtXY(4, 34)
	if not inY then return "expected input node Y not found."
	inB = sim.nodeAtXY(4, 16)
	if not inB then return "expected input node B not found."

	outR = sim.nodeAtXY(75, 58)
	if not outR then return "expected output node R not found."
	outO = sim.nodeAtXY(75, 49)
	if not outO then return "expected output node O not found."
	outY = sim.nodeAtXY(75, 40)
	if not outY then return "expected output node Y not found."
	outG = sim.nodeAtXY(75, 31)
	if not outG then return "expected output node G not found."
	outB = sim.nodeAtXY(75, 22)
	if not outB then return "expected output node B not found."
	outV = sim.nodeAtXY(75, 13)
	if not outV then return "expected output node V not found."
	outK = sim.nodeAtXY(75, 4)
	if not outK then return "expected output node K not found."
	outputs = [outR, outO, outY, outG, outB, outV, outK]
	for i in range(0,6)
		name = "ROYGBVK"[i]
		outputs[i].name = name
	end for		

	// TESTS: first three are R, Y, and B input states; last one is
	// which output node should be on.
	tests = []
	tests.push [0, 0, 0, null]
	tests.push [1, 0, 0, outR]
	tests.push [0, 1, 0, outY]
	tests.push [0, 0, 1, outB]
	tests.push [1, 1, 0, outO]
	tests.push [0, 1, 1, outG]
	tests.push [1, 0, 1, outV]
	tests.push [1, 1, 1, outK]
	
	for test in tests
		inR.setOn test[0]
		inY.setOn test[1]
		inB.setOn test[2]
		sim.simulate
		for outp in outputs
			if outp.on and outp != test[3] then return "Output " +
			  outp.name + " should not be on in this case."
		end for
		if test[3] and not test[3].on then return "Output " +
			test[3].name + " should be on in this case."
	end for
	
	return ""
end function
