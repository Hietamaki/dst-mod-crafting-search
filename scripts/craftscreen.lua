require "util"

local TextCompleter = require "util/textcompleter"
local Screen = require "widgets/screen"
local RecipePopup = require "widgets/recipepopup"
local RecipeTile = require "widgets/recipetile"
local TextEdit = require "widgets/textedit"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local ScrollableChatQueue = require "widgets/redux/scrollablechatqueue"
--local VirtualKeyboard = require "screens/virtualkeyboard"
local Emoji = require("util/emoji")
local UserCommands = require("usercommands")

local Helper = require "helper"
local GLOBAL

local CraftInput = Class(Screen, function(self, glob, craft_fn)
	Screen._ctor(self, "CraftInput")
	self._G = glob
    GLOBAL = glob
    self.craftItem = craft_fn
	self.runtask = nil
	self.is_crafting_input = true
	Helper = Helper:new(self._G)

	self:DoInit()
end)

function CraftInput:OnBecomeActive()
    CraftInput._base.OnBecomeActive(self)

    self.chat_edit:SetFocus()
    self.chat_edit:SetEditing(true)

	if self._G.IsConsole() then
		TheFrontEnd:LockFocus(true)
	end

end

function CraftInput:OnBecomeInactive()
    CraftInput._base.OnBecomeInactive(self)

    if self.runtask ~= nil then
        self.runtask:Cancel()
        self.runtask = nil
    end
end

function CraftInput:Run()
    local chat_string = self.chat_edit:GetString()
	local item = Helper:cleanItemName(chat_string)
	
	self.craftItem(Helper:getRawItemName(item))
    chat_string = chat_string ~= nil and chat_string:match("^%s*(.-%S)%s*$") or ""
    if chat_string == "" then
        return
    end
end

function CraftInput:Close()
    self._G.TheInput:EnableDebugToggle(true)
    TheFrontEnd:PopScreen(self)
end

local function DoRun(inst, self)
    self.runtask = nil
    self:Run()
    self:Close()
end

function CraftInput:OnTextEntered()
    if self.runtask ~= nil then
        self.runtask:Cancel()
    end
    self.runtask = self.inst:DoTaskInTime(0, DoRun, self)
end

function CraftInput:DoInit()
    self._G.TheInput:EnableDebugToggle(false)

    local label_height = 50
    local fontsize = 40
    local edit_width = 850
    local edit_width_padding = 0
    local chat_type_width = 150

    self.root = self:AddChild(Widget("chat_input_root"))
    --self.root:SetScaleMode(self._G.SCALEMODE_PROPORTIONAL)
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

    -- tausta?
    --self:AddChild(Image("images/hud.xml", "craft_bg.tex"))
    self.slot = self.root:AddChild(Image("images/hud.xml", "craft_slot.tex"))
    self.slot:SetPosition(-565, 270)
    self.slot:Hide()
    self.tile = self.root:AddChild(RecipeTile(nil))
    self.recipe = self.root:AddChild(RecipePopup(false))
    self.recipe:SetPosition(-540, 250, 0)
    self.recipe.button:Hide()  
    self.recipe:Hide()
    self.slot:SetScaleMode(self._G.SCALEMODE_NONE)
    self.tile:SetScaleMode(self._G.SCALEMODE_NONE)
    self.recipe:SetScaleMode(self._G.SCALEMODE_NONE)

    --self.tile:SetPosition(-350, 100, 0)
    self.tile:SetPosition(-560, 273, 0)
    --self.craft_name = self.root:AddChild(Text(self._G.UIFONT, fontsize))
    --self.craft_name:SetPosition(-300, 80)
    --self.craft_name:SetHAlign(self._G.ANCHOR_LEFT)

    self.chat_edit:EnableWordPrediction({width = 800, mode=self._G.Profile:GetChatAutocompleteMode()})

	
	local data = {
		words = Helper:listReadableItemNames(),
		delim = "#",
		--GetDisplayString = function(word) return word end
	}

	self.chat_edit:AddWordPredictionDictionary(data)
    self.chat_edit:SetString("#")
    local ci = self

	
	self.chat_edit.OnTextInputted = function(text, k)
		self.chat_edit:SetString(string.lower(self.chat_edit:GetString()))
        self.chat_edit.prediction_widget:RefreshPredictions()
		return false
	end

    self.chat_edit.prediction_widget.GetSelectedItem = function(self)
        if #(self.prediction_btns) > 0 then
            local strItem = self.prediction_btns[self.active_prediction_btn].text.string
            
            -- Remove #
            strItem = strItem:match( "^#*(.-)#*$" )
            return Helper:getRawItemName(strItem)
        end
    end


    self.chat_edit.prediction_widget.origOnRawKey = self.chat_edit.prediction_widget.OnRawKey
    self.chat_edit.prediction_widget.OnRawKey = function(self, key, down)
        local res = self:origOnRawKey(key, down)
        if self["prediction_btns"] then

            local item = self:GetSelectedItem()
            local recipe = GLOBAL.GetValidRecipe(item)
            if recipe == nil then
                ci.recipe:Hide()
                ci.tile:Hide()
                ci.slot:Hide()
                --ci.craft_name:SetString("")
            else
                --print(ci._G.ThePlayer)
                ci.recipe:SetRecipe(recipe, ci._G.ThePlayer)
                ci.recipe.button:Hide()
                ci.recipe:Show()
                ci.slot:Show()
                ci.tile:SetRecipe(recipe)
                ci.tile:Show()
                --ci.craft_name:SetString(Helper:getReadableItemName(item))
            end
        end

        return res
    end
end

function CraftInput:GetSelectedItem()
	local pred_widget = self.chat_edit.prediction_widget
	return pred_widget:GetSelectedItem()
end


return CraftInput