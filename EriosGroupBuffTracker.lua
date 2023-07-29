EPBT = {}

EPBT.name = "Erios Personal Buff Tracker"
EPBT.version = "1.0.0"
EPBT.author = "Erio"

EPBT.SavedVariablesName = "EPBTVars"
EPBT.SVVersion = "1.0.0"

local updateInterval = 500 -- in ms. Update this if you want the UI to update faster.
local buff1 = "Echoing Vigor" -- temp values. dont worry about these
local buff2 = "Regeneration"
local ActiveBuffs = {[buff1] = {}, [buff2] = {}}

EPBT.defaults = {
    buff1x = 275,
    buff1y = 275,
    buff2x = 400,
    buff2y = 400,
    buff1 = "Echoing Vigor",
    buff2 = "Radiating Regeneration",
    avaOnly = true,
    buff1Enabled = true,
    buff2Enabled = true,
    showTime = true,
}

EPBT.SV = {}

function EPBT.onLoad(eventCode, addonName)
    EVENT_MANAGER:UnregisterForEvent(EPBT.name, EVENT_ADD_ON_LOADED)
    EPBT.SV = ZO_SavedVars:NewAccountWide(EPBT.SavedVariablesName, EPBT.SVVersion, nil, EPBT.defaults)

    EPBT.CreateSettingsMenu()

    EVENT_MANAGER:RegisterForEvent(EPBT.name, EVENT_EFFECT_CHANGED, EPBT.BuffCastedOrEnded)
    EVENT_MANAGER:RegisterForUpdate(EPBT.name, updateInterval, EPBT.updateGroupUI)
    EVENT_MANAGER:RegisterForEvent(EPBT.name, EVENT_PLAYER_ACTIVATED,EPBT.init)

    EPBT.init()

    SLASH_COMMANDS["/egt"] = EPBT.debugtwo

    -- This addon only checks the update of the buffs YOU cast.
end

------------------------------------------------------------------------
-- Checking group buffs
------------------------------------------------------------------------

function EPBT.init()
    EPBT.UpdateAnchors()
    EPBT.UpdateBuffs()
    EPBT.updateText()
end

function EPBT.updateGroupUI()
    local timeLeft = ""
    local groupSize = GetGroupSize()
    if (groupSize < 2) or ((IsInAvAZone() == false) and (EPBT.SV.avaOnly == true)) then EPBT.HideUI() return end
    if (EPBT.SV.buff1Enabled == false) and (EPBT.SV.buff2Enabled == false) then return end

    EPBT.UpdateWidth()
    EPBT.ShowUI()

    for i = 1, groupSize do
        local namespace = GetControl("MyPersBuffsp" .. i)
        local namespace2 = GetControl("MyPersBuffs2p" .. i)

        local unitName = GetUnitDisplayName(GetGroupUnitTagByIndex(i))
        local textString = "|cFF0000" .. unitName .. "|r"
        local textString2 = "|cFF0000" .. unitName .. "|r"
        if (ActiveBuffs[buff1][unitName] ~= false) or (ActiveBuffs[buff2][unitName] ~= false) then
            local unitId = GetGroupUnitTagByIndex(i)
            local NumBuffs = GetNumBuffs(unitId)
            for buff = 1, NumBuffs do
                local buffName,  ts,  timeEnding,  buffSlot,  sc,  ifn,  nt,   et,   at,   set,  aid,  cco,  cbp = GetUnitBuffInfo(unitId,buff)
                local currentTimeStamp = GetGameTimeMilliseconds() / 1000
                timeLeft = timeEnding - currentTimeStamp
                timeLeft = math.floor(timeLeft + 0.5)
                if (EPBT.SV.buff1Enabled) and (buffName == buff1) and (buffSlot == ActiveBuffs[buff1][unitName]) and (timeLeft ~= 0) then
                    textString = "|c00FF00" .. unitName .. "|r "
                    if (EPBT.SV.showTime) then textString = textString .. timeLeft end
                end
                if (EPBT.SV.buff2Enabled) and (buffName == buff2) and (buffSlot == ActiveBuffs[buff2][unitName]) and (timeLeft ~= 0)then
                    textString2 = "|c00FF00" .. unitName .. "|r "
                    if (EPBT.SV.showTime) then textString2 = textString2 .. timeLeft end
                end
            end
        end
        namespace:SetText(textString)
        namespace2:SetText(textString2)
    end
end

-- Updates the active buffs table with who has the currently tracked buffs whenever the player casts a buff, or the buff casted ends.
function EPBT.BuffCastedOrEnded( ec,  ct,  effectSlot,  effectName,  unitTag,  timeStarted,  timeEnding,  sc,  icn,  nt,  et,  at,  set,  unitName,  ud,  aid,  sourceUnitType)
    if (IsInAvAZone() == false) and (EPBT.SV.avaOnly == true) then return end
    if (effectName ~= buff1) and (effectName ~= buff2) then return end
    if sourceUnitType ~= COMBAT_UNIT_TYPE_PLAYER then return end
    unitName = ( GetUnitDisplayName(unitTag))
    if (unitName == nil) then return end
    if timeStarted ~= timeEnding then ActiveBuffs[effectName][unitName] = effectSlot return end
    if timeStarted == timeEnding then ActiveBuffs[effectName][unitName] = false end
end


------------------------------------------------------------------------
-- UI Updating Stuff
------------------------------------------------------------------------

function EPBT.updateText() -- Updates the buff menus labels for the buff name
    MyPersBuffsWindowTitle:SetText("|cFFFF00" .. buff1 .."|r")
    MyPersBuffs2WindowTitle:SetText("|cFFFF00" .. buff2 .."|r")
end

function EPBT.UpdateBuffs() -- initalizes the buffs to the LAM selected buffs
    buff1 = EPBT.SV.buff1
    buff2 = EPBT.SV.buff2
    ActiveBuffs = {[buff1] = {}, [buff2] = {}}
end

function EPBT.UpdateAnchors() -- Sets the position of the menus on the screen
    MyPersBuffs:ClearAnchors()
    MyPersBuffs:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,EPBT.SV.buff1x,EPBT.SV.buff1y)

    MyPersBuffs2:ClearAnchors()
    MyPersBuffs2:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,EPBT.SV.buff2x,EPBT.SV.buff2y)

    EPBT.updateText()
end

function EPBT.buff2Save() -- saves buff2 location
    EPBT.SV.buff2x = MyPersBuffs2:GetLeft()
    EPBT.SV.buff2y = MyPersBuffs2:GetTop()
    EPBT.UpdateAnchors()
    EPBT.updateText()
end

function EPBT.buff1Save() -- saves buff1 location
    EPBT.SV.buff1x = MyPersBuffs:GetLeft()
    EPBT.SV.buff1y = MyPersBuffs:GetTop()
    EPBT.UpdateAnchors()
    EPBT.updateText()
end


function EPBT.HideUI() -- Hides both buff menus
    if (IsUnitGrouped('player') == false) then EPBT.UpdateBuffs() end
    MyPersBuffs:SetHidden(true)
    MyPersBuffs2:SetHidden(true)
end

function EPBT.ShowUI() -- Shows the buff menus (if enabled)
    MyPersBuffs:SetHidden(not EPBT.SV.buff1Enabled)
    MyPersBuffs2:SetHidden(not EPBT.SV.buff2Enabled)
end

function EPBT.UpdateWidth() -- Updates length and width to match group size
    local groupSize = GetGroupSize()
    local x = 175
    local y = (45) + (15 * groupSize)
    MyPersBuffs:SetDimensions(x,y)
    MyPersBuffs2:SetDimensions(x,y)
end

function EPBT.debugtwo()
    -- hello world
end



-- Entry Point
EVENT_MANAGER:RegisterForEvent(EPBT.name,EVENT_ADD_ON_LOADED,EPBT.onLoad)
