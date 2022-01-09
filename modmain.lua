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

local lastItem = ""

function table_invert(t)
	local s={}
	for k,v in pairs(t) do
	  s[v]=k
	end
	return s
 end

itemsByName = {}

local function getItemName(recipeName)
	return GLOBAL.STRINGS.NAMES[string.upper(recipeName)]
end
 
local function getItemNames()
	local builder = GLOBAL.ThePlayer.replica.builder
	local keyset={}
	local n=0
	
	for k,v in pairs(GLOBAL.AllRecipes) do
		local recipe = GLOBAL.GetValidRecipe(k)
		name = getItemName(k)
		if name ~= nil and recipe ~= nil then
			--if builder:KnowsRecipe(k) or GLOBAL.CanPrototypeRecipe(recipe.level, builder:GetTechTrees()) then
				n=n+1
				keyset[n]=string.lower(name)
				itemsByName[string.lower(name)] = k
			--end
		end
	end

	return keyset
end

local function sendMessage(msg)
	--function Talker:Say(script, time, noanim, force, nobroadcast, colour, text_filter_context, original_author_netid)
	GLOBAL.ThePlayer.components.talker:Say(msg, nil, nil, nil, nil)
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
			builder:MakeRecipeFromMenu(recipe, nil)
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


require "util"
local TextCompleter = require "util/textcompleter"
local Screen = require "widgets/screen"
local TextEdit = require "widgets/textedit"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local ScrollableChatQueue = require "widgets/redux/scrollablechatqueue"
--local VirtualKeyboard = require "screens/virtualkeyboard"


local Emoji = require("util/emoji")
local UserCommands = require("usercommands")

local CraftInput = Class(Screen, function(self, whisper)
	Screen._ctor(self, "CraftInput")
	self.whisper = whisper
	self.runtask = nil
	self.is_crafting_input = true
	self:DoInit()
end)

function CraftInput:OnBecomeActive()
    CraftInput._base.OnBecomeActive(self)

    self.chat_edit:SetFocus()
    self.chat_edit:SetEditing(true)

	if GLOBAL.IsConsole() then
		TheFrontEnd:LockFocus(true)
	end

    if GLOBAL.ThePlayer ~= nil and GLOBAL.ThePlayer.HUD ~= nil then
        GLOBAL.ThePlayer.HUD.controls.networkchatqueue:Hide()
    end
end

function CraftInput:OnBecomeInactive()
    CraftInput._base.OnBecomeInactive(self)

    if self.runtask ~= nil then
        self.runtask:Cancel()
        self.runtask = nil
    end

    if GLOBAL.ThePlayer ~= nil and GLOBAL.ThePlayer.HUD ~= nil then
        GLOBAL.ThePlayer.HUD.controls.networkchatqueue:Show()
    end

	---self:Close()
	--sendMessage("onBecomeInactive")
end

function CraftInput:GetHelpText()
    local controller_id = GLOBAL.TheInput:GetControllerID()
    local t = {}

    table.insert(t,  GLOBAL.TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

	table.insert(t,  GLOBAL.TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.CraftInput.HELP_WHISPER)
	table.insert(t,  GLOBAL.TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.CraftInput.HELP_SAY)

    return table.concat(t, "  ")
end

function CraftInput:OnControl(control, down)
    if self.runtask ~= nil or CraftInput._base.OnControl(self, control, down) then return true end

    if self.networkchatqueue:OnChatControl(control, down) then return true end

    --jcheng: don't allow debug menu stuff going on right now
    if control == CONTROL_OPEN_DEBUG_CONSOLE then
        return true
    end

	if not down and (control == CONTROL_CANCEL) then
		sendMessage("CONTROL_CANCEL")
		self:Close()
		return true
	end

    -- For controllers, the misc_2 button will whisper if in say mode or say if in whisper mode. This is to allow the player to only bind one key to initiate chat mode.
	if not GLOBAL.TheInput:PlatformUsesVirtualKeyboard() then
		if GLOBAL.TheInput:ControllerAttached() then
			if not down and control == CONTROL_MENU_MISC_2 then
				self.whisper = not self.whisper
				self:OnTextEntered()
				return true
			end

			if not down and (control == CONTROL_TOGGLE_SAY or control == CONTROL_TOGGLE_WHISPER) then
				self:Close()
				return true
			end
		end
	else -- has virtual keyboard
		if not down then
			if control == CONTROL_MENU_MISC_2 then
				self.whisper = true
				self.chat_edit:SetEditing(true)
				return true
			elseif control == CONTROL_ACCEPT then
				self.whisper = false
				self.chat_edit:SetEditing(true)
				return true
			elseif control == CONTROL_CANCEL then
		      self:Close()
			  return true
		end
	end
	end
end

--function CraftInput:OnRawKey(key, down)
--    if self.runtask ~= nil then return true end
--    if CraftInput._base.OnRawKey(self, key, down) then
--		sendMessage("Hmm true")
--        return true
--    end
--	sendMessage("Hmm false")
--
--    return false
--end

local function cleanItemName(name)
	name = string.lower(name)
	name = name:match( "^%s*(.-)%s*$" )
	return name:match( "^#*(.-)#*$" )
end

function CraftInput:Run()
    local chat_string = self.chat_edit:GetString()
	local item = cleanItemName(chat_string)
	craftItem(itemsByName[item])
	--print(itemsByName[item])
    chat_string = chat_string ~= nil and chat_string:match("^%s*(.-%S)%s*$") or ""
    if chat_string == "" then
        return
    end
end

function CraftInput:Close()
    --SetPause(false)
    GLOBAL.TheInput:EnableDebugToggle(true)
    TheFrontEnd:PopScreen(self)
end

local function DoRun(inst, self)
    self.runtask = nil
    self:Run()
    self:Close()
end

function CraftInput:OnTextEntered()
	--self.chat_edit:SetString(string.lower(self.chat_edit.string))
    if self.runtask ~= nil then
        self.runtask:Cancel()
    end
    self.runtask = self.inst:DoTaskInTime(0, DoRun, self)
end

function CraftInput:DoInit()
    --SetPause(true,"console")
    GLOBAL.TheInput:EnableDebugToggle(false)

    local label_height = 50
    local fontsize = 30
    local edit_width = 850
    local edit_width_padding = 0
    local chat_type_width = 150

    self.root = self:AddChild(Widget("chat_input_root"))
    self.root:SetScaleMode(GLOBAL.SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(GLOBAL.ANCHOR_MIDDLE)
    self.root:SetVAnchor(GLOBAL.ANCHOR_BOTTOM)
    self.root = self.root:AddChild(Widget(""))

    self.root:SetPosition(45.2, 100, 0)

	if not GLOBAL.TheInput:PlatformUsesVirtualKeyboard() then
	    self.chat_type = self.root:AddChild(Text(GLOBAL.TALKINGFONT, fontsize))
	    self.chat_type:SetPosition(-505, 0, 0)
	    self.chat_type:SetRegionSize(chat_type_width, label_height)
	    self.chat_type:SetHAlign(GLOBAL.ANCHOR_RIGHT)
	    self.chat_type:SetString("Craft item:")
	    self.chat_type:SetColour(.6, .6, .6, 1)
	end

    self.chat_edit = self.root:AddChild(TextEdit(GLOBAL.TALKINGFONT, fontsize, ""))
    self.chat_edit.edit_text_color = GLOBAL.WHITE
    self.chat_edit.idle_text_color = GLOBAL.WHITE
    self.chat_edit:SetEditCursorColour(GLOBAL.unpack(GLOBAL.WHITE))
    self.chat_edit:SetPosition(-.5 * edit_width_padding, 0, 0)
    self.chat_edit:SetRegionSize(edit_width - edit_width_padding, label_height)
    self.chat_edit:SetHAlign(GLOBAL.ANCHOR_LEFT)

    -- the screen will handle the help text
    self.chat_edit:SetHelpTextApply("")
    self.chat_edit:SetHelpTextCancel("")
    self.chat_edit:SetHelpTextEdit("")
    self.chat_edit.HasExclusiveHelpText = function() return false end

    self.chat_edit.OnTextEntered = function() self:OnTextEntered() end
    self.chat_edit:SetPassControlToScreen(GLOBAL.CONTROL_CANCEL, true)
    self.chat_edit:SetPassControlToScreen(GLOBAL.CONTROL_MENU_MISC_2, true) -- toggle between say and whisper
    self.chat_edit:SetPassControlToScreen(GLOBAL.CONTROL_SCROLLBACK, true)
    self.chat_edit:SetPassControlToScreen(GLOBAL.CONTROL_SCROLLFWD, true)
    self.chat_edit:SetTextLengthLimit(GLOBAL.MAX_CHAT_INPUT_LENGTH)
    self.chat_edit:EnableWordWrap(false)
    --self.chat_edit:EnableWhitespaceWrap(true)
    self.chat_edit:EnableRegionSizeLimit(true)
    self.chat_edit:EnableScrollEditWindow(false)

	self.chat_edit:SetForceEdit(true)
    self.chat_edit.OnStopForceEdit = function() self:Close() end

    self.chat_queue_root = self.chat_edit:AddChild(Widget("chat_queue_root"))
    self.chat_queue_root:SetScaleMode(GLOBAL.SCALEMODE_PROPORTIONAL)
    self.chat_queue_root:SetHAnchor(GLOBAL.ANCHOR_MIDDLE)
    self.chat_queue_root:SetVAnchor(GLOBAL.ANCHOR_BOTTOM)
    self.chat_queue_root = self.chat_queue_root:AddChild(Widget(""))
    self.chat_queue_root:SetPosition(-90,765,0)
    self.networkchatqueue = self.chat_queue_root:AddChild(ScrollableChatQueue())

    self.chat_edit:EnableWordPrediction({width = 800, mode=GLOBAL.Profile:GetChatAutocompleteMode()})
    --self.chat_edit:AddWordPredictionDictionary(Emoji.GetWordPredictionDictionary())

	
	local data = {
		words = getItemNames(),
		delim = "#",
	}

	--sendMessage("Words "..#(data.words).." / ")

	--data.GetDisplayString = function(word) return word end

	self.chat_edit:AddWordPredictionDictionary(data)

    self.chat_edit:SetString("#")

	
	self.chat_edit.OnTextInputted = function(text, k)
		--self.chat_edit._base.OnRawKey(text, k)
		--print(self.chat_edit:GetString())
		self.chat_edit:SetString(string.lower(self.chat_edit:GetString()))
	--	print(type(text))
		
		--self.chat_edit:SetString(string.lower(self.chat_edit.string))
		-- convert upper to lower
		--if key > 64 and key < 91 then
		--	key = key + 32
		--	sendMessage("Hmm "..key)
		--end
		--if self.runtask ~= nil then return true end
		--if ci._base.OnRawKey(self, key, down) then
		--    return true
		--end

		return false
	end
end



local function closePrompt()
	local gump = TheFrontEnd:GetActiveScreen()

	if gump.name == "CraftInput" then
		TheFrontEnd:PopScreen(gump)
		return true
	end
end

local function startInput(key)
	if not isPlayerAvailable() then
		return
	end

	local gump = TheFrontEnd:GetActiveScreen()

	if gump.name == "CraftInput" then
		closePrompt()
	elseif gump.name == "HUD" then
		TheFrontEnd:PushScreen(CraftInput(false))
	end
end

local function craftLast()
	if lastItem ~= "" then
		craftItem(lastItem)
	end
end


local function enterKey()
	
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

GLOBAL.TheInput:AddKeyDownHandler(KEY_CRAFT_INPUT, function() startInput(KEY_F1) end)
GLOBAL.TheInput:AddKeyDownHandler(KEY_CRAFT_LAST, function() craftLast() end)
GLOBAL.TheInput:AddKeyUpHandler(KEY_ESCAPE, function() return closePrompt() end)
GLOBAL.TheInput:AddKeyUpHandler(KEY_ENTER, function() enterKey() end)
--GLOBAL.TheInput:AddKeyDownHandler(KEY_RESET, function() reset() end)
