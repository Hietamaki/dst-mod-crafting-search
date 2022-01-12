local Helper = require "helper"
local CraftInput = require "craftscreen"

Helper = Helper:new(GLOBAL)


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
local KEY_ESCAPE = GLOBAL.KEY_ESCAPE
local KEY_ENTER = GLOBAL.KEY_ENTER

local bind = GetModConfigData("bind")
local binded_modifier = GetModConfigData("modifier")
KEY_CRAFT_INPUT = GLOBAL[bind]

local lastItem = ""
 
local function isPlayerAvailable()
	local DST = GLOBAL.TheSim:GetGameID() == "DST"
	return DST and GLOBAL.ThePlayer ~= nil
end

local function craftItem(recipeName)
	
	if not isPlayerAvailable() then
		return
	end
	
	local recipe = GLOBAL.GetValidRecipe(recipeName)
	
	local talker = GLOBAL.ThePlayer.components.talker
	local builder = GLOBAL.ThePlayer.replica.builder

	if recipe == nil then
		Helper:sendMessage(ICON_CANT_BUILD.." No such item.")
		return
	end

	lastItem = recipeName

	local icon = ICON_CRAFT

	local localizedRecipeName = Helper:getReadableItemName(recipe.name)

	if not builder:KnowsRecipe(recipeName) then
		if  GLOBAL.CanPrototypeRecipe(recipe.level, builder:GetTechTrees()) and
			builder:CanLearn(recipe.name) then
			icon = ICON_INVENT
		else
			Helper:sendMessage(ICON_CANT_BUILD.." I don't know the recipe for "..localizedRecipeName..".")
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
				Helper:sendMessage(ICON_CANT_BUILD.." "..localizedRecipeName.."? I don't have "..many..v.type)
				return false
			end
		end
		for i, v in ipairs(recipe.character_ingredients) do
			if not builder:HasCharacterIngredient(v) then
				Helper:sendMessage(ICON_CANT_BUILD.." "..localizedRecipeName.."? I don't have ".. v.type)
				return false
            end
        end
        for i, v in ipairs(recipe.tech_ingredients) do
            if not builder:HasTechIngredient(v) then
				Helper:sendMessage(ICON_CANT_BUILD.." No tech ingredient for "..localizedRecipeName..".")
                return false
            end
        end
		Helper:sendMessage(ICON_CANT_BUILD.." "..localizedRecipeName.."? Something wrong.")
		return
	end
	
	Helper:sendMessage(icon.." Crafting "..localizedRecipeName)
	
	if recipe.placer == nil then
		builder:MakeRecipeFromMenu(recipe, nil)
	else
		if not builder:IsBuildBuffered(recipeName) then
			builder:BufferBuild(recipeName)
		end
		GLOBAL.ThePlayer.components.playercontroller:StartBuildPlacementMode(recipe, nil)
	end
end

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
		--pass through - we are in middle of input
		return false
	elseif gump.name == "HUD" then
		-- no menus open
		TheFrontEnd:PushScreen(CraftInput(GLOBAL, craftItem))
	end
end


local function enterKey()
	
	local craft_input = TheFrontEnd:GetActiveScreen()
	if craft_input.name ~= "CraftInput" then
		return
	end

	if Helper:cleanItemName(craft_input.chat_edit:GetString()) == "" then
		closePrompt()
		return
	end
	
	local pred_widget = craft_input.chat_edit.prediction_widget
	
	if #(pred_widget.prediction_btns) > 0 then
		local strItem = pred_widget.prediction_btns[pred_widget.active_prediction_btn].text.string
		
		-- Remove #
		strItem = strItem:match( "^#*(.-)#*$" )
		craftItem(Helper:getRawItemName(strItem))
		closePrompt()
		return
	end

end

GLOBAL.TheInput:AddKeyDownHandler(GLOBAL[bind], function() startInput() end)
GLOBAL.TheInput:AddKeyUpHandler(KEY_ESCAPE, function() return closePrompt() end)
GLOBAL.TheInput:AddKeyUpHandler(KEY_ENTER, function() enterKey() end)

if bind == "KEY_F1" then
	GLOBAL.TheInput:AddKeyDownHandler(KEY_CRAFT_LAST, function() craftLast() end)
end