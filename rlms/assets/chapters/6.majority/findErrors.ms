check = function
	nodeA = sim.nodeAtXY(4, 55)
	if not nodeA then return "Expected node A not found."
	nodeB = sim.nodeAtXY(4, 34)
	if not nodeB then return "Expected node B not found."
	nodeC = sim.nodeAtXY(4, 13)
	if not nodeC then return "Expected node C not found."
	nodeG = sim.nodeAtXY(76, 34)
	if not nodeG then return "expected node G not found."

	for a in [0,1]
		for b in [0,1]
			for c in [0,1]
				nodeA.setOn a
				nodeB.setOn b
				nodeC.setOn c
				sim.simulate
				if nodeA.on != a or nodeB.on != b or nodeC.on != c then
					return "Inputs should not directly affect each other."
				end if
				yesVotes = a + b + c
				if yesVotes >= 2 and not nodeG.on then
					return "G should be on when " + yesVotes + " inputs are on."
				else if yesVotes == 0 and nodeG.on then
					return "G should be off when no inputs are on."
				else if yesVotes == 1 and nodeG.on then
					return "G should be off when only one input is on."
				end if
			end for
		end for
	end for
	
	return ""
end function
