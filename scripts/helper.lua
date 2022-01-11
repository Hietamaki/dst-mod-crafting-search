
local Helper = {}

function Helper:new(global)
    self.itemsByID={}
    self.itemsByName = {}
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

function Helper:getItemName(recipeName)
	return self._G.STRINGS.NAMES[string.upper(recipeName)]
end
 
function Helper:getItemNames()
	local builder = self._G.ThePlayer.replica.builder

	local n=0
	
	for k,v in pairs(self._G.AllRecipes) do
		local recipe = self._G.GetValidRecipe(k)
		local name = self:getItemName(k)
		if name ~= nil and recipe ~= nil then
			--if builder:KnowsRecipe(k) or self._G.CanPrototypeRecipe(recipe.level, builder:GetTechTrees()) then
				n=n+1
				self.itemsByID[n]=string.lower(name)
				self.itemsByName[string.lower(name)] = k
			--end
		end
	end

	return self.itemsByID
end

return Helper