press = function(node)
	node.setOn true
	node.held = true
	sim.simulate
	node.setOn false
	node.held = false
	sim.simulate
end function

check = function
	nodeA = sim.nodeAtXY(4, 58)
	if not nodeA then return "Expected node A not found."
	nodeB = sim.nodeAtXY(4, 42)
	if not nodeB then return "Expected node B not found."
	nodeC = sim.nodeAtXY(4, 26)
	if not nodeC then return "Expected node C not found."
	nodeRst = sim.nodeAtXY(8, 7)
	if not nodeRst then return "Expected node RST not found."
	nodeA1 = sim.nodeAtXY(74, 58)
	if not nodeA1 then return "expected node A' not found."
	nodeB1 = sim.nodeAtXY(74, 42)
	if not nodeB1 then return "expected node B' not found."
	nodeC1 = sim.nodeAtXY(74, 26)
	if not nodeC1 then return "expected node C' not found."

	inpNodes = [nodeA, nodeB, nodeC]
	outNodes = [nodeA1, nodeB1, nodeC1]
	nodes = inpNodes + [nodeRst] + outNodes
	names = "ABC"
	
	for i in [0,1,2]
		for n in nodes; n.setOn false; end for
		press nodeRst
		for n in nodes
			if n.on then return "Some nodes did not reset properly."
		end for
		press inpNodes[i]
		if not outNodes[i].on then
			return names[i]+"' did not light up when "+names[i]+" pressed."
		end if
		for j in [0,1,2]
			if j == i then continue
			if outNodes[j].on then
				return names[j]+"' lit up when " + names[i] + " pressed."
			end if
		end for
		press inpNodes[(i+1)%3]
		for j in [0,1,2]
			if j == i then continue
			if outNodes[j].on then
				return names[j]+"' lit up when " + names[(i+1)%3] + " was pressed AFTER " + names[i] + "."
			end if
		end for
		press inpNodes[(i+2)%3]
		for j in [0,1,2]
			if j == i then continue
			if outNodes[j].on then
				return names[j]+"' lit up when " + names[(i+2)%3] + " was pressed AFTER " + names[i] + "."
			end if
		end for
		press nodeRst
		for n in nodes
			if n.on then return "Some nodes did not reset properly."
		end for
	end for

	return ""
end function
