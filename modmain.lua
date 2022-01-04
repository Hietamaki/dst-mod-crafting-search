local ICON_MODE = "󰀖" --tophat
local ICON_ACTIVATION = "󰀓" --sanity
local ICON_TAB = "󰀌" --hammer
local ICON_CRAFT = "󰀏" --lightbulb
local ICON_CANT_BUILD = "󰀒" --redgem

local KEY_DEBUG = GLOBAL.KEY_BACKSLASH
local KEY_RESET = GLOBAL.KEY_F4
local KEY_CRAFT_INPUT = GLOBAL.KEY_F1
local KEY_CRAFT_LAST = GLOBAL.KEY_F2
local KEY_CRAFT_ALT = GLOBAL.KEY_C
local KEY_ESCAPE = GLOBAL.KEY_ESCAPE

local lastItem = ""

local L18N_RECIPE_NAMES_MAP = {
	-- Simple: set 1
	["axe"] = GLOBAL.STRINGS.NAMES.AXE,
	["pickaxe"] = GLOBAL.STRINGS.NAMES.PICKAXE,
	["shovel"] = GLOBAL.STRINGS.NAMES.SHOVEL,
	["hammer"] = GLOBAL.STRINGS.NAMES.HAMMER,
	["rope"] = GLOBAL.STRINGS.NAMES.ROPE,
	["boards"] = GLOBAL.STRINGS.NAMES.BOARDS,
	["cutstone"] = GLOBAL.STRINGS.NAMES.CUTSTONE,
	["healingsalve"] = GLOBAL.STRINGS.NAMES.HEALINGSALVE,
	["armorwood"] = GLOBAL.STRINGS.NAMES.ARMORWOOD,
	["spear"] = GLOBAL.STRINGS.NAMES.SPEAR,
	["hambat"] = GLOBAL.STRINGS.NAMES.HAMBAT,
	["footballhat"] = GLOBAL.STRINGS.NAMES.FOOTBALLHAT,
	-- Simple: set 2
	["campfire"] = GLOBAL.STRINGS.NAMES.CAMPFIRE,
	["torch"] = GLOBAL.STRINGS.NAMES.TORCH,
	["boomerang"] = GLOBAL.STRINGS.NAMES.BOOMERANG,
	["icestaff"] = GLOBAL.STRINGS.NAMES.ICESTAFF,
	["treasurechest"] = GLOBAL.STRINGS.NAMES.TREASURECHEST,
	["researchlab"] = GLOBAL.STRINGS.NAMES.RESEARCHLAB,
	["fast_farmplot"] = GLOBAL.STRINGS.NAMES.FAST_FARMPLOT,
	["cookpot"] = GLOBAL.STRINGS.NAMES.COOKPOT,
	["trap_teeth"] = GLOBAL.STRINGS.NAMES.TRAP_TEETH,
	["marblebean"] = GLOBAL.STRINGS.NAMES.MARBLEBEAN,
	["reviver"] = GLOBAL.STRINGS.NAMES.REVIVER,
	["coldfire"] = GLOBAL.STRINGS.NAMES.COLDFIRE,
	-- Advanced
	["axe"] = GLOBAL.STRINGS.NAMES.AXE,
	["pickaxe"] = GLOBAL.STRINGS.NAMES.PICKAXE,
	["shovel"] = GLOBAL.STRINGS.NAMES.SHOVEL,
	["hammer"] = GLOBAL.STRINGS.NAMES.HAMMER,
	["pitchfork"] = GLOBAL.STRINGS.NAMES.PITCHFORK,
	["razor"] = GLOBAL.STRINGS.NAMES.RAZOR,
	["featherpencil"] = GLOBAL.STRINGS.NAMES.FEATHERPENCIL,
	["saltlick"] = GLOBAL.STRINGS.NAMES.SALTLICK,
	["goldenaxe"] = GLOBAL.STRINGS.NAMES.GOLDENAXE,
	["goldenpickaxe"] = GLOBAL.STRINGS.NAMES.GOLDENPICKAXE,
	["goldenshovel"] = GLOBAL.STRINGS.NAMES.GOLDENSHOVEL,
	["saddle_basic"] = GLOBAL.STRINGS.NAMES.SADDLE_BASIC,
	["campfire"] = GLOBAL.STRINGS.NAMES.CAMPFIRE,
	["firepit"] = GLOBAL.STRINGS.NAMES.FIREPIT,
	["torch"] = GLOBAL.STRINGS.NAMES.TORCH,
	["coldfire"] = GLOBAL.STRINGS.NAMES.COLDFIRE,
	["coldfirepit"] = GLOBAL.STRINGS.NAMES.COLDFIREPIT,
	["minerhat"] = GLOBAL.STRINGS.NAMES.MINERHAT,
	["molehat"] = GLOBAL.STRINGS.NAMES.MOLEHAT,
	["pumpkin_lantern"] = GLOBAL.STRINGS.NAMES.PUMPKIN_LANTERN,
	["lantern"] = GLOBAL.STRINGS.NAMES.LANTERN,
	["mushroom_light"] = GLOBAL.STRINGS.NAMES.MUSHROOM_LIGHT,
	["mushroom_light2"] = GLOBAL.STRINGS.NAMES.MUSHROOM_LIGHT2,
	["lighter"] = GLOBAL.STRINGS.NAMES.LIGHTER,
	["reviver"] = GLOBAL.STRINGS.NAMES.REVIVER,
	["healingsalve"] = GLOBAL.STRINGS.NAMES.HEALINGSALVE,
	["bandage"] = GLOBAL.STRINGS.NAMES.BANDAGE,
	["lifeinjector"] = GLOBAL.STRINGS.NAMES.LIFEINJECTOR,
	["trap"] = GLOBAL.STRINGS.NAMES.TRAP,
	["birdtrap"] = GLOBAL.STRINGS.NAMES.BIRDTRAP,
	["bugnet"] = GLOBAL.STRINGS.NAMES.BUGNET,
	["fishingrod"] = GLOBAL.STRINGS.NAMES.FISHINGROD,
	["umbrella"] = GLOBAL.STRINGS.NAMES.UMBRELLA,
	["heatrock"] = GLOBAL.STRINGS.NAMES.HEATROCK,
	["backpack"] = GLOBAL.STRINGS.NAMES.BACKPACK,
	["tent"] = GLOBAL.STRINGS.NAMES.TENT,
	["slow_farmplot"] = GLOBAL.STRINGS.NAMES.SLOW_FARMPLOT,
	["fast_farmplot"] = GLOBAL.STRINGS.NAMES.FAST_FARMPLOT,
	["fertilizer"] = GLOBAL.STRINGS.NAMES.FERTILIZER,
	["mushroom_farm"] = GLOBAL.STRINGS.NAMES.MUSHROOM_FARM,
	["beebox"] = GLOBAL.STRINGS.NAMES.BEEBOX,
	["meatrack"] = GLOBAL.STRINGS.NAMES.MEATRACK,
	["cookpot"] = GLOBAL.STRINGS.NAMES.COOKPOT,
	["icebox"] = GLOBAL.STRINGS.NAMES.ICEBOX,
	["saltbox"] = GLOBAL.STRINGS.NAMES.SALTBOX,
	["portablecookpot_item"] = GLOBAL.STRINGS.NAMES.PORTABLECOOKPOT_ITEM,
	["portableblender_item"] = GLOBAL.STRINGS.NAMES.PORTABLEBLENDER_ITEM,
	["portablespicer_item"] = GLOBAL.STRINGS.NAMES.PORTABLESPICER_ITEM,
	["researchlab"] = GLOBAL.STRINGS.NAMES.RESEARCHLAB,
	["researchlab2"] = GLOBAL.STRINGS.NAMES.RESEARCHLAB2,
	["transistor"] = GLOBAL.STRINGS.NAMES.TRANSISTOR,
	["seafaring_prototyper"] = GLOBAL.STRINGS.NAMES.SEAFARING_PROTOTYPER,
	["cartographydesk"] = GLOBAL.STRINGS.NAMES.CARTOGRAPHYDESK,
	["sculptingtable"] = GLOBAL.STRINGS.NAMES.SCULPTINGTABLE,
	["winterometer"] = GLOBAL.STRINGS.NAMES.WINTEROMETER,
	["rainometer"] = GLOBAL.STRINGS.NAMES.RAINOMETER,
	["gunpowder"] = GLOBAL.STRINGS.NAMES.GUNPOWDER,
	["lightning_rod"] = GLOBAL.STRINGS.NAMES.LIGHTNING_ROD,
	["firesuppressor"] = GLOBAL.STRINGS.NAMES.FIRESUPPRESSOR,
	["spear"] = GLOBAL.STRINGS.NAMES.SPEAR,
	["hambat"] = GLOBAL.STRINGS.NAMES.HAMBAT,
	["armorwood"] = GLOBAL.STRINGS.NAMES.ARMORWOOD,
	["footballhat"] = GLOBAL.STRINGS.NAMES.FOOTBALLHAT,
	["boomerang"] = GLOBAL.STRINGS.NAMES.BOOMERANG,
	["trap_teeth"] = GLOBAL.STRINGS.NAMES.TRAP_TEETH,
	["blowdart_sleep"] = GLOBAL.STRINGS.NAMES.BLOWDART_SLEEP,
	["blowdart_fire"] = GLOBAL.STRINGS.NAMES.BLOWDART_FIRE,
	["blowdart_pipe"] = GLOBAL.STRINGS.NAMES.BLOWDART_PIPE,
	["blowdart_yellow"] = GLOBAL.STRINGS.NAMES.BLOWDART_YELLOW,
	["spear_wathgrithr"] = GLOBAL.STRINGS.NAMES.SPEAR_WATHGRITHR,
	["wathgrithrhat"] = GLOBAL.STRINGS.NAMES.WATHGRITHRHAT,
	["treasurechest"] = GLOBAL.STRINGS.NAMES.TREASURECHEST,
	["homesign"] = GLOBAL.STRINGS.NAMES.HOMESIGN,
	["minisign_item"] = GLOBAL.STRINGS.NAMES.MINISIGN_ITEM,
	["fence_gate_item"] = GLOBAL.STRINGS.NAMES.FENCE_GATE_ITEM,
	["fence_item"] = GLOBAL.STRINGS.NAMES.FENCE_ITEM,
	["pighouse"] = GLOBAL.STRINGS.NAMES.PIGHOUSE,
	["rabbithouse"] = GLOBAL.STRINGS.NAMES.RABBITHOUSE,
	["birdcage"] = GLOBAL.STRINGS.NAMES.BIRDCAGE,
	["scarecrow"] = GLOBAL.STRINGS.NAMES.SCARECROW,
	["turf_road"] = GLOBAL.STRINGS.NAMES.TURF_ROAD,
	["turf_dragonfly"] = GLOBAL.STRINGS.NAMES.TURF_DRAGONFLY,
	["dragonflychest"] = GLOBAL.STRINGS.NAMES.DRAGONFLYCHEST,
	["rope"] = GLOBAL.STRINGS.NAMES.ROPE,
	["boards"] = GLOBAL.STRINGS.NAMES.BOARDS,
	["cutstone"] = GLOBAL.STRINGS.NAMES.CUTSTONE,
	["papyrus"] = GLOBAL.STRINGS.NAMES.PAPYRUS,
	["waxpaper"] = GLOBAL.STRINGS.NAMES.WAXPAPER,
	["beeswax"] = GLOBAL.STRINGS.NAMES.BEESWAX,
	["marblebean"] = GLOBAL.STRINGS.NAMES.MARBLEBEAN,
	["bearger_fur"] = GLOBAL.STRINGS.NAMES.BEARGER_FUR,
	["nightmarefuel"] = GLOBAL.STRINGS.NAMES.NIGHTMAREFUEL,
	["purplegem"] = GLOBAL.STRINGS.NAMES.PURPLEGEM,
	["moonrockcrater"] = GLOBAL.STRINGS.NAMES.MOONROCKCRATER,
	["malbatross_feathered_weave"] = GLOBAL.STRINGS.NAMES.MALBATROSS_FEATHERED_WEAVE,
	["researchlab4"] = GLOBAL.STRINGS.NAMES.RESEARCHLAB4,
	["researchlab3"] = GLOBAL.STRINGS.NAMES.RESEARCHLAB3,
	["resurrectionstatue"] = GLOBAL.STRINGS.NAMES.RESURRECTIONSTATUE,
	["amulet"] = GLOBAL.STRINGS.NAMES.AMULET,
	["blueamulet"] = GLOBAL.STRINGS.NAMES.BLUEAMULET,
	["purpleamulet"] = GLOBAL.STRINGS.NAMES.PURPLEAMULET,
	["firestaff"] = GLOBAL.STRINGS.NAMES.FIRESTAFF,
	["icestaff"] = GLOBAL.STRINGS.NAMES.ICESTAFF,
	["wereitem_goose"] = GLOBAL.STRINGS.NAMES.WEREITEM_GOOSE,
	["wereitem_beaver"] = GLOBAL.STRINGS.NAMES.WEREITEM_BEAVER,
	["wereitem_moose"] = GLOBAL.STRINGS.NAMES.WEREITEM_MOOSE,
	["abigail_flower"] = GLOBAL.STRINGS.NAMES.ABIGAIL_FLOWER,
	["sewing_kit"] = GLOBAL.STRINGS.NAMES.SEWING_KIT,
	["flowerhat"] = GLOBAL.STRINGS.NAMES.FLOWERHAT,
	["strawhat"] = GLOBAL.STRINGS.NAMES.STRAWHAT,
	["tophat"] = GLOBAL.STRINGS.NAMES.TOPHAT,
	["rainhat"] = GLOBAL.STRINGS.NAMES.RAINHAT,
	["beefalohat"] = GLOBAL.STRINGS.NAMES.BEEFALOHAT,
	["winterhat"] = GLOBAL.STRINGS.NAMES.WINTERHAT,
	["kelphat"] = GLOBAL.STRINGS.NAMES.KELPHAT,
	["featherhat"] = GLOBAL.STRINGS.NAMES.FEATHERHAT,
	["cane"] = GLOBAL.STRINGS.NAMES.CANE,
	["eyebrellahat"] = GLOBAL.STRINGS.NAMES.EYEBRELLAHAT,
	["hawaiianshirt"] = GLOBAL.STRINGS.NAMES.HAWAIIANSHIRT,
	["thulecite"] = GLOBAL.STRINGS.NAMES.THULECITE,
	["wall_ruins_item"] = GLOBAL.STRINGS.NAMES.WALL_RUINS_ITEM,
	["orangeamulet"] = GLOBAL.STRINGS.NAMES.ORANGEAMULET,
	["yellowamulet"] = GLOBAL.STRINGS.NAMES.YELLOWAMULET,
	["greenamulet"] = GLOBAL.STRINGS.NAMES.GREENAMULET,
	["orangestaff"] = GLOBAL.STRINGS.NAMES.ORANGESTAFF,
	["yellowstaff"] = GLOBAL.STRINGS.NAMES.YELLOWSTAFF,
	["greenstaff"] = GLOBAL.STRINGS.NAMES.GREENSTAFF,
	["ruinshat"] = GLOBAL.STRINGS.NAMES.RUINSHAT,
	["armorruins"] = GLOBAL.STRINGS.NAMES.ARMORRUINS,
	["ruins_bat"] = GLOBAL.STRINGS.NAMES.RUINS_BAT,
	["eyeturret_item"] = GLOBAL.STRINGS.NAMES.EYETURRET_ITEM
}

local function getItemNames()
	local keyset={}
	local n=0
	
	for k,v in pairs(GLOBAL.AllRecipes) do
		--todo: if unlocked
	  n=n+1
	  keyset[n]=k
	end

	return keyset
end

local function sendMessage(msg)
	GLOBAL.ThePlayer.components.talker:Say(ICON_MODE.." "..msg)
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
	local localizedRecipeName = recipe == nil and "I have no idea about '"..recipeName.."'" or L18N_RECIPE_NAMES_MAP[recipeName]
	localizedRecipeName = localizedRecipeName == nil and recipeName or localizedRecipeName
	
	local builder = GLOBAL.ThePlayer.replica.builder
	local talker = GLOBAL.ThePlayer.components.talker

	if recipe == nil then
		talker:Say(ICON_CANT_BUILD.." No such item.")
		return
	end

	--localizedRecipeName = recipe.product

	if not builder:KnowsRecipe(recipeName) then
		talker:Say(ICON_CANT_BUILD.." I don't know the recipe for "..localizedRecipeName..".")
		return
	end

	if not builder:CanBuild(recipeName) then
		for i, v in ipairs(recipe.ingredients) do
			if not builder.inst.replica.inventory:Has(v.type, math.max(1, GLOBAL.RoundBiasedUp(v.amount * builder:IngredientMod()))) then
				local many = ""
				if v.amount > 1 then
					many = v.amount.." "
				end
				talker:Say(ICON_CANT_BUILD.." "..localizedRecipeName.."? I don't have "..many..v.type)
				return false
			end
		end
		for i, v in ipairs(recipe.character_ingredients) do
			if not builder:HasCharacterIngredient(v) then
				talker:Say(ICON_CANT_BUILD.." "..localizedRecipeName.."? I don't have ".. v.type)
				return false
            end
        end
		talker:Say(ICON_CANT_BUILD.." "..localizedRecipeName.."? I don't have the resources.")
		return
	end

	talker:Say(ICON_CRAFT.." Building "..localizedRecipeName)
	
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

function CraftInput:OnRawKey(key, down)
    if self.runtask ~= nil then return true end
    if CraftInput._base.OnRawKey(self, key, down) then
        return true
    end

    return false
end

function CraftInput:Run()
    local chat_string = self.chat_edit:GetString()
	local item = string.sub(chat_string, 2)
	craftItem(item)
	lastItem = item
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
	data.GetDisplayString = function(word) return word end

	self.chat_edit:AddWordPredictionDictionary(data)

    self.chat_edit:SetString("#")
end



local function closePrompt(key)
	CraftInput:Close()
end

local function startInput(key)
	if not isPlayerAvailable() then
		return
	end
	
	--GLOBAL.ThePlayer.components.talker:Say(ICON_CRAFT.." debug")
	TheFrontEnd:PushScreen(CraftInput(false))
end

local function craftLast()
	if lastItem ~= "" then
		craftItem(lastItem)
	end
end


local function reset()
	GLOBAL.TheNet:SendWorldRollbackRequestToServer(0)
end

GLOBAL.TheInput:AddKeyDownHandler(KEY_CRAFT_INPUT, function() startInput(KEY_F1) end)
GLOBAL.TheInput:AddKeyDownHandler(KEY_CRAFT_LAST, function() craftLast() end)
GLOBAL.TheInput:AddKeyDownHandler(KEY_RESET, function() reset() end)
GLOBAL.TheInput:AddKeyDownHandler(KEY_ESCAPE, function() closePrompt() end)
