local _G = GLOBAL
local TUNING = _G.TUNING

local is_dst
function IsDST()
	if is_dst == nil then
		is_dst = GLOBAL.kleifileexists("scripts/networking.lua") and true or false
	end
	return is_dst
end
_G.IsDST = IsDST

function SetTheWorld()
	if IsDST() == false then 
		local TheWorld = _G.GetWorld()
		_G.rawset(_G, "TheWorld", TheWorld)
		-- _G.TheWorld = TheWorld
	end
end
function SetThePlayer(player)
	if IsDST() == false then  
		_G.rawset(_G, "ThePlayer", player)
		-- _G.TheWorld = TheWorld
	end
end 


-------------------------------------------------------------------------------------
-- Auto Weapon

TUNING.FS_COMBAT_INSTINCT = GetModConfigData("FS_COMBAT_INSTINCT") == "on" 
TUNING.FS_DEFENSIVE_INSTINCT = GetModConfigData("FS_DEFENSIVE_INSTINCT") == "on" 
TUNING.FS_HOLD_MELEE = GetModConfigData("FS_HOLD_MELEE") == "on" 
TUNING.FS_HOLD_PROJECTILE = GetModConfigData("FS_HOLD_PROJECTILE") == "on" 

-------------------------------------------------------------------------------------
-- Damage Indicator 
TUNING.SHOW_DAMAGE = GetModConfigData("SHOW_DAMAGE") == "on" 
TUNING.SHOW_HEAL = GetModConfigData("SHOW_HEAL") == "on"  
TUNING.HIDE_HP_CHANGES_LESS = _G.tonumber(GetModConfigData("HIDE_HP_CHANGES_LESS"))

TUNING.LABEL_FONT_SIZE = 70
TUNING.HEALTH_LOSE_COLOR = {
	r = 0.7,
	g = 0,
	b = 0,
	a = 1
}
TUNING.HEALTH_GAIN_COLOR = {
	r = 0,
	g = 0.7,
	b = 0,
	a = 1
} 
TUNING.LABEL_TIME = 0.5
TUNING.LABEL_TIME_DELTA = 0.01   


-------------
-- Wdiget 
local ToggleButton = GetModConfigData("togglekey")


--      for k,v in pairs(ThePlayer.components) do print("components" , k) end
-------------------------------------------------------------------------------------
-- Setup Functionality

function OnActivated(player)
	-- local player = playercontroller.inst  
	-- print("OnActivated prefabs", _G.ThePlayer)
	_G.ThePlayer:AddComponent("damageindicator") 
	_G.ThePlayer:AddComponent("fightersense")
end

function SimPostInit(player)
	-- example of modifying the player charater
	-- player.components.health:SetMaxHealth(50)

	print("SimPostInit")
	if IsDST() then
		_G.TheWorld:ListenForEvent("playeractivated", OnActivated)

	else 
		-- local TheWorld = _G.TheWorld and _G.TheWorld or _G.GetWorld()
		SetTheWorld()
		SetThePlayer(player)
		OnActivated(player) 
	end

end

AddSimPostInit(SimPostInit)



_G.TEST = function()
for k, fn in pairs(_G.TEST_FN) do
	fn()
end 
end

_G.TEST_FN = {}
_G.ADDTEST = function(fn)
table.insert(_G.TEST_FN, fn)
end 


local function IsDefaultScreen()
	return GLOBAL.TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil
end

local function AddWidget(parent)

	local ControlWidget = _G.require "widgets/fightersense"

	local widget = parent:AddChild(ControlWidget())   
	widget:Hide()

	-- local keydown = false
	GLOBAL.TheInput:AddKeyDownHandler(ToggleButton, function()
		if not IsDefaultScreen() then return end 
		widget:Show()
		end)
	GLOBAL.TheInput:AddKeyUpHandler(ToggleButton, function()
		if not IsDefaultScreen() then return end 
		widget:Hide()
		end)
end 

if IsDST() then
	AddClassPostConstruct( "widgets/controls", function (controls)
		AddWidget(controls)
		end  )
else 
	Assets = {
		Asset("ATLAS", "images/avatars.xml"),
		Asset("IMAGE", "images/avatars.tex"),
	}

	AddSimPostInit(function()
		local controls = _G.ThePlayer.HUD
		AddWidget(controls)
		end)

end