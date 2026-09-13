RaidlistSettings = RaidlistSettings or {}


if RaidlistSettings.language == nil then
    RaidlistSettings.language = "en"
end

if RaidlistSettings.showErrorsInChat == nil then
    RaidlistSettings.showErrorsInChat = false
end

local SettingsTexts = {
    en = {
        showErrors = "Show errors in chat",
        showErrorsDescription =
            "Displays Raidlist error messages in the chat window."
    },

    de = {
        showErrors = "Fehler im Chat anzeigen",
        showErrorsDescription =
            "Zeigt Fehlermeldungen von Raidlist im Chatfenster an."
    }
}

local language = RaidlistSettings.language or "en"
local texts = SettingsTexts[language] or SettingsTexts.en

local category, layout =
    Settings.RegisterVerticalLayoutCategory("Raidlist")

local showErrorsSetting =
    Settings.RegisterAddOnSetting(
        category,
        "Raidlist_ShowErrorsInChat",
        "showErrorsInChat",
        RaidlistSettings,
        type(false),
        texts.showErrors,
        false
    )

Settings.CreateCheckbox(
    category,
    showErrorsSetting,
    texts.showErrorsDescription
)

Settings.RegisterAddOnCategory(category)


RaidlistSettingsCategory = category