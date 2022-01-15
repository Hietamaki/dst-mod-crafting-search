local Helper = require "helper"
local CraftInput = require "craftscreen"

Helper = Helper:new(GLOBAL)

local ICON_CRAFT = "󰀌" --hammer
local ICON_INVENT = "󰀏" --lightbulb
local ICON_CANT_CRAFT = ""

local KEY_DEBUG = GLOBAL.KEY_BACKSLASH
local KEY_RESET = GLOBAL.KEY_F5
local KEY_CRAFT_INPUT = GLOBAL.KEY_F1
local KEY_CRAFT_LAST = GLOBAL.KEY_F2
local KEY_ESCAPE = GLOBAL.KEY_ESCAPE
local KEY_ENTER = GLOBAL.KEY_ENTER

local bind = GetModConfigData("bind")
local binded_modifier = GetModConfigData("modifier")
local ui_type = GetModConfigData("ui")

KEY_CRAFT_INPUT = GLOBAL[bind]

state = {lastItem = "",skin=nil}
 
local function isPlayerAvailable()
	local DST = GLOBAL.TheSim:GetGameID() == "DST"
	return DST and GLOBAL.ThePlayer ~= nil
end

local function getPlural(msg, amount)
	if amount > 1 and string.sub(msg, -1) == "s" then
		return amount.." "..msg
	elseif amount > 1 then
		return amount.." "..msg.."s"
	else
		return msg
	end
end

local function craftItem(recipeName, skin)
	
	if not isPlayerAvailable() then
		return
	end
	
	local recipe = GLOBAL.GetValidRecipe(recipeName)
	
	local talker = GLOBAL.ThePlayer.components.talker
	local builder = GLOBAL.ThePlayer.replica.builder

	if recipe == nil then
		Helper:sendMessage(ICON_CANT_CRAFT.." No such item.")
		return
	end

	if skin ~= nil then
		GLOBAL.Profile:SetLastUsedSkinForItem(recipeName, skin)
	end

	state.lastItem = recipeName

	local icon = ICON_CRAFT
	local localizedRecipeName = Helper:getReadableItemName(recipe.name)
	local invented_msg = ""
	local missing_msg = ""

	if not builder:KnowsRecipe(recipeName) then
		if  GLOBAL.CanPrototypeRecipe(recipe.level, builder:GetTechTrees()) and
			builder:CanLearn(recipe.name) then
			icon = ICON_INVENT
		else
			invented_msg = "I don't know the recipe for "..localizedRecipeName.."."
		end
	end

	if not builder:IsBuildBuffered(recipeName) and not builder:CanBuild(recipeName) then
		for i, v in ipairs(recipe.ingredients) do
			if not builder.inst.replica.inventory:Has(v.type, math.max(1, GLOBAL.RoundBiasedUp(v.amount * builder:IngredientMod()))) then
				missing_msg = missing_msg .." "..getPlural(v.type, v.amount) ..","
			end
		end
		for i, v in ipairs(recipe.character_ingredients) do
			if not builder:HasCharacterIngredient(v) then
				missing_msg = missing_msg .." ".. v.type..","
            end
        end
        for i, v in ipairs(recipe.tech_ingredients) do
            if not builder:HasTechIngredient(v) then
				missing_msg = missing_msg .." tech ingredient."
            end
        end
		--Helper:sendMessage(ICON_CANT_CRAFT.." "..localizedRecipeName.."? Something wrong.")
	end

	if invented_msg ~= "" and missing_msg == ""  then
		Helper:sendMessage(ICON_CANT_CRAFT.." "..invented_msg)
	elseif invented_msg == "" and missing_msg ~= ""  then
		Helper:sendMessage(ICON_CANT_CRAFT.." "..localizedRecipeName.."? I don't have"..string.sub(missing_msg, 1, -2))
	elseif invented_msg ~= "" and missing_msg ~= ""  then
		Helper:sendMessage(ICON_CANT_CRAFT.." "..invented_msg .." Also I don't have"..string.sub(missing_msg, 1, -2))
	else
		Helper:sendMessage(icon.." Crafting "..localizedRecipeName)
		
		if skin == nil then
			skin = GLOBAL.Profile:GetLastUsedSkinForItem(recipeName)
		end
		
		if recipe.placer == nil then
			return builder:MakeRecipeFromMenu(recipe, skin)
		else
			if not builder:IsBuildBuffered(recipeName) then
				builder:BufferBuild(recipeName)
			end
			return GLOBAL.ThePlayer.components.playercontroller:StartBuildPlacementMode(recipe, nil)
		end
	end
end

local function closePrompt()
	local activeScreen = TheFrontEnd:GetActiveScreen()

	if activeScreen.name == "CraftInput" then
		activeScreen:Close()
		return true
	end
end

local function craftLast()
	
	if state.lastItem ~= "" then
		craftItem(state.lastItem, state.skin)
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

	local activeScreen = TheFrontEnd:GetActiveScreen()

	if activeScreen.name == "CraftInput" then
		--pass through - we are in middle of input
		return false
	elseif activeScreen.name == "HUD" then
		-- no menus open
		TheFrontEnd:PushScreen(CraftInput(GLOBAL, craftItem, ui_type))
	end
end

local function enterKey()
	
	local activeScreen = TheFrontEnd:GetActiveScreen()
	
	if activeScreen.name ~= "CraftInput" then
		return
	end
	
	if Helper:cleanItemName(activeScreen.chat_edit:GetString()) == "" then
		activeScreen:Close()
		return
	end
	
	item = activeScreen:GetSelectedItem()
	if item then
		activeScreen:Close()
		craftItem(item)
	end
end

GLOBAL.TheInput:AddKeyDownHandler(GLOBAL[bind], function() startInput() end)
GLOBAL.TheInput:AddKeyUpHandler(KEY_ESCAPE, function() return closePrompt() end)
GLOBAL.TheInput:AddKeyUpHandler(KEY_ENTER, function() enterKey() end)

if bind == "KEY_F1" then
	GLOBAL.TheInput:AddKeyDownHandler(KEY_CRAFT_LAST, function() craftLast() end)
end