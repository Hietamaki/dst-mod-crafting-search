
local Helper = {}

function Helper:new(global)
    self.readableItemNames={}
    self.rawItemNames = {}
    self._G = global

    return self

end

function Helper:cleanItemName(name)
	name = string.lower(name)
	name = name:match( "^%s*(.-)%s*$" )
	return name:match( "^#*(.-)#*$" )
end

function Helper:sendMessage(msg)
	--function Talker:Say(script, time, noanim, force, nobroadcast, colour, text_filter_context, original_author_netid)
	self._G.ThePlayer.components.talker:Say(msg, nil, nil, nil, nil)
end

function Helper:getRawItemName(readableName)

    if #(self.rawItemNames) == 0 then
        self.generateItemNames()
    end

    return self.rawItemNames[readableName]
end

function Helper:getReadableItemName(recipeName)
	return self._G.STRINGS.NAMES[string.upper(recipeName)]
end

function Helper:listReadableItemNames()
    if #(self.rawItemNames) == 0 then
        self:generateItemNames()
    end
    
    return self.readableItemNames
end

function Helper:generateItemNames()
    if self == nil then
        return
    end

	local builder = self._G.ThePlayer.replica.builder

	local n=0
	
	for k,v in pairs(self._G.AllRecipes) do
		local recipe = self._G.GetValidRecipe(k)
		local readableName = self:getReadableItemName(k)
		if readableName ~= nil and recipe ~= nil then
			--if builder:KnowsRecipe(k) or self._G.CanPrototypeRecipe(recipe.level, builder:GetTechTrees()) then
				n=n+1
				self.readableItemNames[n]=string.lower(readableName)
				self.rawItemNames[string.lower(readableName)] = k
			--end
		end
	end

	return self.readableItemNames
end


return Helper