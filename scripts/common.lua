itemsByID={}
itemsByName = {}

function sendMessage(msg)
	--function Talker:Say(script, time, noanim, force, nobroadcast, colour, text_filter_context, original_author_netid)
	GLOBAL.ThePlayer.components.talker:Say(msg, nil, nil, nil, nil)
end

function getItemName(recipeName)
	return GLOBAL.STRINGS.NAMES[string.upper(recipeName)]
end
 
local function getItemNames()
	local builder = GLOBAL.ThePlayer.replica.builder

	local n=0
	
	for k,v in pairs(GLOBAL.AllRecipes) do
		local recipe = GLOBAL.GetValidRecipe(k)
		name = getItemName(k)
		if name ~= nil and recipe ~= nil then
			--if builder:KnowsRecipe(k) or GLOBAL.CanPrototypeRecipe(recipe.level, builder:GetTechTrees()) then
				n=n+1
				itemsByID[n]=string.lower(name)
				itemsByName[string.lower(name)] = k
			--end
		end
	end

	return itemsByID
end


getItemNames()