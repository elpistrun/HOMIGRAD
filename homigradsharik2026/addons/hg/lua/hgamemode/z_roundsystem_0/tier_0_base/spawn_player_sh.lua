local Level = oop.Get("level_base")
if not Level then return end

function Level.GetArmor(armor,col)
	if TypeID(armor) == TYPE_TABLE then
		if not IsColor(armor[2]) then--pizdes cring
		if TypeID(armor) == TYPE_STRING then return armor[1] end

			armor = armor[math.random(1,#armor)]
			
			if TypeID(armor) == TYPE_TABLE then
				if not IsColor(armor[2]) then
					armor = armor[math.random(1,#armor)]

					if TypeID(armor) == TYPE_TABLE then
						col = armor[2]
						armor = armor[1]
					end
				else
					col = armor[2]
					armor = armor[1]
				end
			end
		else
			col = armor[2]
			armor = armor[1]
		end
	end

	return armor,{color = col}
end

function Level.GetModel(model)
	local model = model[math.random(1,#model)]
	local bodygroup = {}
	local force

	if TypeID(model) == TYPE_TABLE then
		for i,value in pairs(model[2] or {}) do
			bodygroup[i] = (TypeID(value) == TYPE_TABLE and math.random(value[1],value[2])) or value
		end

		model = model[1]
		force = model[3]
	end

	return model,bodygroup,force
end