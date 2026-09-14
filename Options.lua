local addonName, Raidlist = ...

local isGerman =
    GetLocale() == "deDE"


local text = {
    title = "Raidlist",

    errorLabel = isGerman
        and "Fehler im Chat anzeigen"
        or "Show errors in chat",

    errorDescription = isGerman
        and "Zeigt Lua-Fehler und interne Raidlist-Fehlermeldungen zusätzlich im Chat an."
        or "Displays Lua errors and internal Raidlist errors in the chat window.",

    vendorLabel = isGerman
        and "Sammelverkauf-Knopf beim Händler aktivieren"
        or "Enable vendor sell-all button",

    vendorDescription = isGerman
        and "Aktiviert den Knopf zum automatischen Verkaufen passender Ausrüstungsgegenstände beim Händler."
        or "Enables the button for automatically selling matching equipment items at vendors.",

    expansionLabel = isGerman
        and "Verkaufbare Erweiterung"
        or "Sellable expansion",

    expansionDescription = isGerman
        and "Legt fest, aus welcher Erweiterung Ausrüstungsgegenstände automatisch verkauft werden dürfen."
        or "Determines which expansion equipment items may be sold automatically.",
}


local expansions = {
    {
        id = 0,
        name = "Classic"
    },
    {
        id = 1,
        name = "The Burning Crusade"
    },
    {
        id = 2,
        name = "Wrath of the Lich King"
    },
    {
        id = 3,
        name = "Cataclysm"
    },
    {
        id = 4,
        name = "Mists of Pandaria"
    },
    {
        id = 5,
        name = "Warlords of Draenor"
    },
    {
        id = 6,
        name = "Legion"
    },
    {
        id = 7,
        name = "Battle for Azeroth"
    },
    {
        id = 8,
        name = "Shadowlands"
    },
    {
        id = 9,
        name = "Dragonflight"
    },
    {
        id = 10,
        name = "The War Within"
    },
    {
        id = 11,
        name = "Midnight"
    }
}


local category, layout =
    Settings.RegisterVerticalLayoutCategory(
        text.title
    )


do
    local variable =
        addonName .. "_ShowErrorsInChat"

    local variableKey =
        "showErrorsInChat"

    local defaultValue =
        false

    local setting =
        Settings.RegisterAddOnSetting(
            category,
            variable,
            variableKey,
            RaidlistDB,
            type(defaultValue),
            text.errorLabel,
            defaultValue
        )

    Settings.CreateCheckbox(
        category,
        setting,
        text.errorDescription
    )
end


do
    local variable =
        addonName .. "_ShowVendorButton"

    local variableKey =
        "showVendorButton"

    local defaultValue =
        false

    local setting =
        Settings.RegisterAddOnSetting(
            category,
            variable,
            variableKey,
            RaidlistDB,
            type(defaultValue),
            text.vendorLabel,
            defaultValue
        )

    Settings.CreateCheckbox(
        category,
        setting,
        text.vendorDescription
    )
end


do
    local variable =
        addonName .. "_SellableExpansionID"

    local variableKey =
        "sellableExpansionID"

    local defaultValue =
        9

    local function GetExpansionOptions()
        local container =
            Settings.CreateControlTextContainer()

        for _, expansion in ipairs(
            expansions
        ) do
            container:Add(
                expansion.id,
                expansion.name
            )
        end

        return container:GetData()
    end

    local setting =
        Settings.RegisterAddOnSetting(
            category,
            variable,
            variableKey,
            RaidlistDB,
            type(defaultValue),
            text.expansionLabel,
            defaultValue
        )

    Settings.CreateDropdown(
        category,
        setting,
        GetExpansionOptions,
        text.expansionDescription
    )
end


Settings.RegisterAddOnCategory(
    category
)

Raidlist.SettingsCategory =
    category


function Raidlist:OpenSettings()
    Settings.OpenToCategory(
        self.SettingsCategory:GetID()
    )
end