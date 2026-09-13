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
        or "Displays Lua errors and internal Raidlist errors in the chat window."
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


Settings.RegisterAddOnCategory(category)

Raidlist.SettingsCategory = category


function Raidlist:OpenSettings()
    Settings.OpenToCategory(
        self.SettingsCategory:GetID()
    )
end