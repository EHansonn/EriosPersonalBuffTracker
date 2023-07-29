local LAM = LibAddonMenu2
-- Creating LAM2 MENU --
function EPBT.CreateSettingsMenu()
    local panelName = "EriosGroupBuffTracker"
    local panelData = {
        type = "panel",
        name = EPBT.name,
        displayName = panelName,
        author = EPBT.author,
        version = EPBT.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local options = {}

    table.insert(options, {
        type = "description",
        text = "Highlights the cooldowns of the buffs you cast",

    })

    table.insert(options, {
        type = "editbox",
        name = "Buff1 ",
        default = EPBT.defaults.buff1,
        getFunc = function()
            return EPBT.SV.buff1
        end,
        setFunc = function(text)
            EPBT.SV.buff1 = text
            EPBT.UpdateBuffs()
            EPBT.updateText()
            zo_callLater(function()
                EPBT.UpdateBuffs()
                EPBT.updateText()
            end,200)

        end
    })

    table.insert(options, {
        type = "editbox",
        name = "Buff2 ",
        default = EPBT.defaults.buff2,
        getFunc = function()
            return EPBT.SV.buff2
        end,
        setFunc = function(text)
            EPBT.SV.buff2 = text
            EPBT.UpdateBuffs()
            EPBT.updateText()

            zo_callLater(function()
                EPBT.UpdateBuffs()
                EPBT.updateText()
            end,200)

        end
    })

    table.insert(options, {
        type = "checkbox",
        name = "Ava only? ",
        default = EPBT.defaults.avaOnly,
        getFunc = function()
            return EPBT.SV.avaOnly
        end,
        setFunc = function(text)
            EPBT.SV.avaOnly = text
        end
    })

    table.insert(options, {
        type = "checkbox",
        name = "Buff1 enabled? ",
        default = EPBT.defaults.buff1Enabled,
        getFunc = function()
            return EPBT.SV.buff1Enabled
        end,
        setFunc = function(text)
            EPBT.SV.buff1Enabled = text
        end
    })

    table.insert(options, {
        type = "checkbox",
        name = "Buff2 enabled? ",
        default = EPBT.defaults.buff2Enabled,
        getFunc = function()
            return EPBT.SV.buff2Enabled
        end,
        setFunc = function(text)
            EPBT.SV.buff2Enabled = text
        end
    })

    table.insert(options, {
        type = "checkbox",
        name = "Show timer ",
        default = EPBT.defaults.showTime,
        getFunc = function()
            return EPBT.SV.showTime
        end,
        setFunc = function(text)
            EPBT.SV.showTime = text
        end
    })


    -- Registering Panel and Options
    local controlPanel = LAM:RegisterAddonPanel(panelName,panelData)
    LAM:RegisterOptionControls(panelName,options)
end
