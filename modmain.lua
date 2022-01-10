itemsByID={}
itemsByName = {}

local function cleanItemName(name)
	name = string.lower(name)
	name = name:match( "^%s*(.-)%s*$" )
	return name:match( "^#*(.-)#*$" )
end

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

local CraftInput = require "craftscreen"

local ICON_MODE = "󰀖" --tophat
local ICON_ACTIVATION = "󰀓" --sanity
local ICON_CRAFT = "󰀌" --hammer
local ICON_INVENT = "󰀏" --lightbulb
local ICON_RED_GEM = "󰀒" --redgem
local ICON_CANT_BUILD = "" --redgem

local KEY_DEBUG = GLOBAL.KEY_BACKSLASH
local KEY_RESET = GLOBAL.KEY_F5
local KEY_CRAFT_INPUT = GLOBAL.KEY_F1
local KEY_CRAFT_LAST = GLOBAL.KEY_F2
local KEY_CRAFT_ALT = GLOBAL.KEY_C
local KEY_ESCAPE = GLOBAL.KEY_ESCAPE
local KEY_ENTER = GLOBAL.KEY_ENTER

local bind = GetModConfigData("bind")
local binded_modifier = GetModConfigData("modifier")
KEY_CRAFT_INPUT = GLOBAL[bind]

local lastItem = ""


local function getItemName(recipeName)
	return GLOBAL.STRINGS.NAMES[string.upper(recipeName)]
end
 

local function isPlayerAvailable()
	local DST = GLOBAL.TheSim:GetGameID() == "DST"
	return DST and GLOBAL.ThePlayer ~= nil
end

local function isInputLocked()
	if not isPlayerAvailable() then
		return true
	end
	
	if GLOBAL.ThePlayer.HUD == nil then
		return true
	end
	
	return GLOBAL.ThePlayer.HUD:IsCraftInputOpen() or GLOBAL.ThePlayer.HUD:IsConsoleScreenOpen()
end

local function craftItem(recipeName)
	print(recipeName)
	if not isPlayerAvailable() then
		return
	end
	
	local recipe = GLOBAL.GetValidRecipe(recipeName)
	
	local talker = GLOBAL.ThePlayer.components.talker
	local builder = GLOBAL.ThePlayer.replica.builder

	if recipe == nil then
		sendMessage(ICON_CANT_BUILD.." No such item.")
		return
	end

	lastItem = recipeName

	local icon = ICON_CRAFT

	local localizedRecipeName = getItemName(recipe.name)

	if not builder:KnowsRecipe(recipeName) then
		if  GLOBAL.CanPrototypeRecipe(recipe.level, builder:GetTechTrees()) and
			builder:CanLearn(recipe.name) then
			icon = ICON_INVENT
		else
			sendMessage(ICON_CANT_BUILD.." I don't know the recipe for "..localizedRecipeName..".")
        	return false
		end
	end

	if not builder:IsBuildBuffered(recipeName) and not builder:CanBuild(recipeName) then
		for i, v in ipairs(recipe.ingredients) do
			if not builder.inst.replica.inventory:Has(v.type, math.max(1, GLOBAL.RoundBiasedUp(v.amount * builder:IngredientMod()))) then
				local many = ""
				if v.amount > 1 then
					many = v.amount.." "
				end
				sendMessage(ICON_CANT_BUILD.." "..localizedRecipeName.."? I don't have "..many..v.type)
				return false
			end
		end
		for i, v in ipairs(recipe.character_ingredients) do
			if not builder:HasCharacterIngredient(v) then
				sendMessage(ICON_CANT_BUILD.." "..localizedRecipeName.."? I don't have ".. v.type)
				return false
            end
        end
        for i, v in ipairs(recipe.tech_ingredients) do
            if not builder:HasTechIngredient(v) then
				sendMessage(ICON_CANT_BUILD.." No tech ingredient for "..localizedRecipeName..".")
                return false
            end
        end
		sendMessage(ICON_CANT_BUILD.." "..localizedRecipeName.."? Something wrong.")
		return
	end
	
	sendMessage(icon.." Crafting "..localizedRecipeName)
	
	if recipe.placer == nil then
		builder:MakeRecipeFromMenu(recipe, nil)
	else
		if not builder:IsBuildBuffered(recipeName) then
			builder:BufferBuild(recipeName)
		end
		GLOBAL.ThePlayer.components.playercontroller:StartBuildPlacementMode(recipe, nil)
	end
end

GLOBAL.AddModUserCommand("oma", "craft", {
	aliases = {"c"},
	permission = GLOBAL.COMMAND_PERMISSION.USER,
	slash = false,
	desc = "Craft items with /c <item name>!",
	params = {"n"},
	paramsoptional = {false},
	localfn = function(params, caller)
		craftItem(params.n)
	end
})	




local function closePrompt()
	local gump = TheFrontEnd:GetActiveScreen()

	if gump.name == "CraftInput" then
		TheFrontEnd:PopScreen(gump)
		return true
	end
end

local function craftLast()
	
	if lastItem ~= "" then
		craftItem(lastItem)
	end
end

local function startInput()
	if not isPlayerAvailable() then
		return
	end

	if GLOBAL.TheInput:IsKeyDown(GLOBAL[binded_modifier]) then
		craftLast()
		return
	end

	local gump = TheFrontEnd:GetActiveScreen()

	if gump.name == "CraftInput" then
		--closePrompt()
		return false
	elseif gump.name == "HUD" then
		TheFrontEnd:PushScreen(CraftInput(GLOBAL, craftItem))
	end
end


local function enterKey()
	
	getItemNames()
	
	local craft_input = TheFrontEnd:GetActiveScreen()
	if craft_input.name ~= "CraftInput" then
		return
	end

	if cleanItemName(craft_input.chat_edit:GetString()) == "" then
		closePrompt()
		return
	end

	--print(craft_input.chat_edit.string)
	
	local pred_widget = craft_input.chat_edit.prediction_widget
	
	if #(pred_widget.prediction_btns) > 0 then
	--if pred_widget["prediction_btns"] then
		local strItem = pred_widget.prediction_btns[pred_widget.active_prediction_btn].text.string
		
		-- Remove #
		strItem = strItem:match( "^#*(.-)#*$" )
		--sendMessage("Hmm.. "..strItem)
		craftItem(itemsByName[strItem])
		closePrompt()
		return
	end

end



--local function reset()
--	GLOBAL.TheNet:SendWorldRollbackRequestToServer(0)
--end

GLOBAL.TheInput:AddKeyDownHandler(GLOBAL[bind], function() startInput() end)
GLOBAL.TheInput:AddKeyUpHandler(KEY_ESCAPE, function() return closePrompt() end)
GLOBAL.TheInput:AddKeyUpHandler(KEY_ENTER, function() enterKey() end)
--GLOBAL.TheInput:AddKeyDownHandler(KEY_RESET, function() reset() end)

if bind == "KEY_F1" then
	GLOBAL.TheInput:AddKeyDownHandler(KEY_CRAFT_LAST, function() craftLast() end)
end