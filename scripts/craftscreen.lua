itemsByID={}
itemsByName = {}
local GLOBAL = 0

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
		local name = getItemName(k)
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
local craftItem

local CraftInput = Class(Screen, function(self, glob, craft_fn)
	Screen._ctor(self, "CraftInput")
	GLOBAL = glob
    craftItem = craft_fn

    getItemNames()
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
    print(item)
    print(itemsByName[item])
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
		words = itemsByID,
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


return CraftInput