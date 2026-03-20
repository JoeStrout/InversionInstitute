// Miscellaneous small helper functions that don't fit anywhere else.

env = {}  // ToDo: make this actually work in the host!
env.importPaths = [".", "/usr/game", "/usr/lib", "/sys/lib"]

import "importUtil"

// Get the maximum of two values
globals.max = function(a,b)
	if a > b then return a else return b
end function

// Get the minimum of two values
globals.min = function(a,b)
	if a < b then return a else return b
end function

// Get back the result of a die roll with a certain number of sides
rollDie = function(sides = 6)
	return ceil(rnd * sides)
end function

list._refIndexOf = function(item)
	i = 0; selfLen = self.len
	while i < selfLen
		if refEquals(self[i], @item) then return i
		i += 1
	end while
	return null
end function

mapName = function(m)
	if not @m isa map then return null
	if m.hasIndex("_name") then return m._name
	for kv in intrinsics
		// Among intrinsics, all our "class" names start with a capital letter.
		// (And many of them are actually functions that *return* the class,
		// so in this case we'll invoke kv.value without @.)
		name = @kv.key
		if name isa string and name and 
		  "A" <= name[0] <= "Z" and refEquals(kv.value, m) then return name
	end for
	for kv in globals
		// Among globals, check all regardless of name.  But don't invoke
		// the value; it must be a direct map reference.
		if refEquals(@kv.value, m) then return @kv.key
	end for
	return null
end function

// Pretty print (used for debugging)
globals.pprintToList = function(outList, obj, prefix="", indent=0, suffix="", alreadySeen=null)
	s = str(@obj)
	if @obj == null then s = "null"
	if @obj isa funcRef then s = "function" + s[8:]
	if s.len + prefix.len + indent < 65 then
		outList.push " "*indent + prefix + s + suffix
		return
	end if
	if indent > 32 then
		outList.push " "*indent + prefix + "..." + suffix
		return
	end if
	if alreadySeen == null then alreadySeen = []
	if @obj isa list then
		outList.push " "*indent + prefix + "["
		if alreadySeen._refIndexOf(@obj) != null then
			outList[-1] += "...]"
		else
			alreadySeen.push @obj
			for i in obj.indexes
				pprintToList outList, obj[i], "", indent + 4, "," * (i < obj.len-1), alreadySeen
			end for
			outList.push " "*indent + "]" + suffix
		end if
	else if @obj isa map then
		outList.push " "*indent + prefix + "{"
		if alreadySeen._refIndexOf(@obj) != null then
			outList[-1] += "...}"
		else
			alreadySeen.push @obj
			entries = []; for kv in obj; entries.push kv; end for
			for i in entries.indexes
				kv = entries[i]
				value = null
				if @kv.value isa map then value = mapName(@kv.value)
				if value == null then value = @kv.value
				pprintToList outList, @value, @kv.key + ": ", indent+4, "," * (i < entries.len-1), alreadySeen
			end for
			outList.push " "*indent + "}" + suffix
		end if
	else
		outList.push " "*indent + prefix + s + suffix
	end if
end function

globals.pprint = function(obj)
	lines = []
	pprintToList lines, obj
	for line in lines; print line; end for
end function

runUnitTests = function()
	ensureImport "qa"
	qa.assert max(2,5) == 5
	qa.assert max(5,2) == 5
	qa.assert min(2,5) == 2
	qa.assert min(5,2) == 2
end function

if locals == globals then runUnitTests

	