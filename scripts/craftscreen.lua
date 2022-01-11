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

local Helper = require "helper"

local CraftInput = Class(Screen, function(self, glob, craft_fn)
	Screen._ctor(self, "CraftInput")
	self._G = glob
	Helper = Helper:new(self._G)
    self.craftItem = craft_fn

    Helper:getItemNames()
	self.runtask = nil
	self.is_crafting_input = true
	self:DoInit()
end)

function CraftInput:OnBecomeActive()
    CraftInput._base.OnBecomeActive(self)

    self.chat_edit:SetFocus()
    self.chat_edit:SetEditing(true)

	if self._G.IsConsole() then
		TheFrontEnd:LockFocus(true)
	end

    if self._G.ThePlayer ~= nil and self._G.ThePlayer.HUD ~= nil then
        self._G.ThePlayer.HUD.controls.networkchatqueue:Hide()
    end
end

function CraftInput:OnBecomeInactive()
    CraftInput._base.OnBecomeInactive(self)

    if self.runtask ~= nil then
        self.runtask:Cancel()
        self.runtask = nil
    end

    if self._G.ThePlayer ~= nil and self._G.ThePlayer.HUD ~= nil then
        self._G.ThePlayer.HUD.controls.networkchatqueue:Show()
    end

	---self:Close()
	--Helper:sendMessage("onBecomeInactive")
end

function CraftInput:GetHelpText()
    local controller_id = self._G.TheInput:GetControllerID()
    local t = {}

    table.insert(t,  self._G.TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

	table.insert(t,  self._G.TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.CraftInput.HELP_WHISPER)
	table.insert(t,  self._G.TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.CraftInput.HELP_SAY)

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
		Helper:sendMessage("CONTROL_CANCEL")
		self:Close()
		return true
	end

    -- For controllers, the misc_2 button will whisper if in say mode or say if in whisper mode. This is to allow the player to only bind one key to initiate chat mode.
	if not self._G.TheInput:PlatformUsesVirtualKeyboard() then
		if self._G.TheInput:ControllerAttached() then
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
--		Helper:sendMessage("Hmm true")
--        return true
--    end
--	Helper:sendMessage("Hmm false")
--
--    return false
--end


function CraftInput:Run()
    local chat_string = self.chat_edit:GetString()
	local item = Helper:cleanItemName(chat_string)
	Helper:getItemNames()
    print("item")
    print(item)
    print(Helper.itemsByName[item])
	self.craftItem(Helper.itemsByName[item])
	--print(Helper.itemsByName[item])
    chat_string = chat_string ~= nil and chat_string:match("^%s*(.-%S)%s*$") or ""
    if chat_string == "" then
        return
    end
end

function CraftInput:Close()
    --SetPause(false)
    self._G.TheInput:EnableDebugToggle(true)
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
    self._G.TheInput:EnableDebugToggle(false)

    local label_height = 50
    local fontsize = 30
    local edit_width = 850
    local edit_width_padding = 0
    local chat_type_width = 150

    self.root = self:AddChild(Widget("chat_input_root"))
    self.root:SetScaleMode(self._G.SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(self._G.ANCHOR_MIDDLE)
    self.root:SetVAnchor(self._G.ANCHOR_BOTTOM)
    self.root = self.root:AddChild(Widget(""))

    self.root:SetPosition(45.2, 100, 0)

	if not self._G.TheInput:PlatformUsesVirtualKeyboard() then
	    self.chat_type = self.root:AddChild(Text(self._G.TALKINGFONT, fontsize))
	    self.chat_type:SetPosition(-505, 0, 0)
	    self.chat_type:SetRegionSize(chat_type_width, label_height)
	    self.chat_type:SetHAlign(self._G.ANCHOR_RIGHT)
	    self.chat_type:SetString("Craft item:")
	    self.chat_type:SetColour(.6, .6, .6, 1)
	end

    self.chat_edit = self.root:AddChild(TextEdit(self._G.TALKINGFONT, fontsize, ""))
    self.chat_edit.edit_text_color = self._G.WHITE
    self.chat_edit.idle_text_color = self._G.WHITE
    self.chat_edit:SetEditCursorColour(self._G.unpack(self._G.WHITE))
    self.chat_edit:SetPosition(-.5 * edit_width_padding, 0, 0)
    self.chat_edit:SetRegionSize(edit_width - edit_width_padding, label_height)
    self.chat_edit:SetHAlign(self._G.ANCHOR_LEFT)

    -- the screen will handle the help text
    self.chat_edit:SetHelpTextApply("")
    self.chat_edit:SetHelpTextCancel("")
    self.chat_edit:SetHelpTextEdit("")
    self.chat_edit.HasExclusiveHelpText = function() return false end

    self.chat_edit.OnTextEntered = function() self:OnTextEntered() end
    self.chat_edit:SetPassControlToScreen(self._G.CONTROL_CANCEL, true)
    self.chat_edit:SetPassControlToScreen(self._G.CONTROL_MENU_MISC_2, true) -- toggle between say and whisper
    self.chat_edit:SetPassControlToScreen(self._G.CONTROL_SCROLLBACK, true)
    self.chat_edit:SetPassControlToScreen(self._G.CONTROL_SCROLLFWD, true)
    self.chat_edit:SetTextLengthLimit(self._G.MAX_CHAT_INPUT_LENGTH)
    self.chat_edit:EnableWordWrap(false)
    --self.chat_edit:EnableWhitespaceWrap(true)
    self.chat_edit:EnableRegionSizeLimit(true)
    self.chat_edit:EnableScrollEditWindow(false)

	self.chat_edit:SetForceEdit(true)
    self.chat_edit.OnStopForceEdit = function() self:Close() end

    self.chat_queue_root = self.chat_edit:AddChild(Widget("chat_queue_root"))
    self.chat_queue_root:SetScaleMode(self._G.SCALEMODE_PROPORTIONAL)
    self.chat_queue_root:SetHAnchor(self._G.ANCHOR_MIDDLE)
    self.chat_queue_root:SetVAnchor(self._G.ANCHOR_BOTTOM)
    self.chat_queue_root = self.chat_queue_root:AddChild(Widget(""))
    self.chat_queue_root:SetPosition(-90,765,0)
    self.networkchatqueue = self.chat_queue_root:AddChild(ScrollableChatQueue())

    self.chat_edit:EnableWordPrediction({width = 800, mode=self._G.Profile:GetChatAutocompleteMode()})
    --self.chat_edit:AddWordPredictionDictionary(Emoji.GetWordPredictionDictionary())

	
	local data = {
		words = Helper.itemsByID,
		delim = "#",
	}

	--Helper:sendMessage("Words "..#(data.words).." / ")

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
		--	Helper:sendMessage("Hmm "..key)
		--end
		--if self.runtask ~= nil then return true end
		--if ci._base.OnRawKey(self, key, down) then
		--    return true
		--end

		return false
	end
end


return CraftInput