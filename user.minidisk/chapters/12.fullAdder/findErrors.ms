
check = function
	nodeA = sim.nodeAtXY(4, 49)
	if not nodeA then return "Expected node A not found."
	nodeB = sim.nodeAtXY(4, 33)
	if not nodeB then return "expected node B not found."
	nodeC = sim.nodeAtXY(4, 17)
	if not nodeC then return "expected node C not found."
	node1 = sim.nodeAtXY(75, 42)
	if not node1 then return "expected node 1 not found."
	node2 = sim.nodeAtXY(75, 26)
	if not node2 then return "expected node 2 not found."

	setInputs = function(a, b, c)
		nodeA.setOn a
		nodeB.setOn b
		nodeC.setOn c		
		sim.simulate
	end function

	offOn = ["off", "on"]
	node1.setOn false; node2.setOn false
	for c in [0,1]
		for b in [0,1]
			for a in [0,1]
				setInputs a, b, c
				sum = a + b + c
				expected1 = sum % 2
				expected2 = floor(sum / 2)
				if node1.on != expected1 then
					return "Output 1 is " + offOn[node1.on] +
					 ", when it should be " + offOn[expected1] + "."
				end if
				if node2.on != expected2 then
					return "Output 2 is " + offOn[node2.on] +
					 ", when it should be " + offOn[expected2] + "."
				end if
			end for
		end for
	end for

	return ""
end function
