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

local CraftInput = Class(Screen, function(self, glob, craft_fn, ui_type)
	Screen._ctor(self, "CraftInput")
	self._G = glob
    GLOBAL = glob
    self.craftItem = craft_fn
	self.runtask = nil
    self.ui_type = ui_type
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
    return true
end

local function DoRun(inst, self)
    self.runtask = nil
    self:Run()
    self:Close()
end

local function DoClose(inst, self)
    self.runtask = nil
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
    
    local ci = self
	self.chat_edit:SetForceEdit(true)

    local CloseMaybe = function()
        if ci.recipe.shown == false then
            ci:Close()
        end
        ci.chat_edit:Hide() ci.chat_type:Hide() self.chat_edit:SetForceEdit(false) ci.chat_edit:SetEditing(false)
    end
    self.chat_edit.OnStopForceEdit = CloseMaybe
    --self.chat_edit.OnLoseFocus = function() TheFrontEnd:PopScreen(self) end
    
    -- tausta?
    --self:AddChild(Image("images/hud.xml", "craft_bg.tex"))
    self.slot = self.root:AddChild(Image("images/hud.xml", "craft_slot.tex"))
    self.slot:SetPosition(-565, 270)
    self.slot:Hide()
    self.tile = self.root:AddChild(RecipeTile(nil))
    self.chat_edit:EnableWordPrediction({width = 800, mode=self._G.Profile:GetChatAutocompleteMode()})
    self.recipe = self.root:AddChild(RecipePopup(false))
    self.recipe:SetPosition(-540, 250, 0)
    self.recipe.OnLoseFocus = function() ci.recipe:Hide() ci.slot:Hide() ci.tile:Hide() ci.chat_edit:Show() ci.chat_type:Show() ci.chat_edit:SetForceEdit(true) ci.chat_edit:SetEditing(true) ci.chat_edit:SetFocus() end
    --self.recipe.OnGainFocus = function() self:SetFocus() end
    --self.recipe.button:Hide()
   
    self.recipe:Hide()
    --self.recipe.origOnControl = self.recipe.OnControl
    --self.recipe.OnControl = function(self, d, k) self:origOnControl(d, k) ci.chat_edit:SetFocus() end
    --self.chat_edit.prediction_widget.OnControl = (function() return true end)

    --self.slot:SetScaleMode(self._G.SCALEMODE_NONE)
    --self.tile:SetScaleMode(self._G.SCALEMODE_NONE)
    --self.recipe:SetScaleMode(self._G.SCALEMODE_NONE)

    --self.tile:SetPosition(-350, 100, 0)
    self.tile:SetPosition(-560, 273, 0)
    --self.craft_name = self.root:AddChild(Text(self._G.UIFONT, fontsize))
    --self.craft_name:SetPosition(-300, 80)
    --self.craft_name:SetHAlign(self._G.ANCHOR_LEFT)


	
	local data = {
		words = Helper:listReadableItemNames(),
		delim = "#",
		--GetDisplayString = function(word) return word end
	}

	self.chat_edit:AddWordPredictionDictionary(data)
    self.chat_edit:SetString("#")

	
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

    local full_ui = function(self, key, down)
        local res = self:origOnRawKey(key, down)
        if self["prediction_btns"] then

            local funkkari = function() 

                local skin = nil
                if ci.recipe["skins_spinner"] then
                    skin = ci.recipe.skins_spinner.GetItem()
                end
                ci.craftItem(ci.recipe.recipe.name, skin)
                ci.inst:DoTaskInTime(0, DoClose, ci)
                return true
            end

            ci.recipe.button:SetWhileDown(funkkari)
            ci.recipe.button:SetOnClick(funkkari)

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
                --ci.recipe.button:Hide()
                ci.recipe:Show()
                ci.slot:Show()
                ci.tile:SetRecipe(recipe)
                ci.tile:Show()
                --ci.craft_name:SetString(Helper:getReadableItemName(item))
            end
        end

        return res
    end

    if self.ui_type == "full" then
        self.chat_edit.prediction_widget.origOnRawKey = self.chat_edit.prediction_widget.OnRawKey
        self.chat_edit.prediction_widget.OnRawKey = full_ui
    end
end

function CraftInput:GetSelectedItem()
	local pred_widget = self.chat_edit.prediction_widget
	return pred_widget:GetSelectedItem()
end


return CraftInput