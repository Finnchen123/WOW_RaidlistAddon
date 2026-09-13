local addonName, Raidlist = ...

Raidlist.Name = addonName
Raidlist.FinishedRaids = {}
Raidlist.AvailableLanguages = {
    "en",
    "de"
}

Raidlist.DifficultyByID = {}

for _, difficulty in ipairs(Raidlist.Difficulties) do
    Raidlist.DifficultyByID[difficulty.ID] = difficulty
end


-- ============================================================
-- Saved Variables
-- ============================================================

RaidlistDB = RaidlistDB or {}

-- Migration from the old standalone SavedVariable.
if RaidlistDB.language == nil then
    RaidlistDB.language = UsedLanguage or "en"
end

if RaidlistDB.showErrorsInChat == nil then
    RaidlistDB.showErrorsInChat = false
end

-- Old variable is no longer used.
-- It remains in the TOC for one migration release.
UsedLanguage = nil


-- ============================================================
-- Localization
-- ============================================================

Raidlist.Strings = {
    en = {
        title = "Raidlist",
        subtitle = "Old raid lockouts for transmog and mount runs",

        language = "Language",
        raid = "Raid",

        finished = "Finished",
        available = "Available",
        blocked = "Blocked",
        unavailable = "Unavailable",

        compartmentTooltip = "Open Raidlist",
        compartmentTooltipDescription = "Shows your old raid lockouts.",

        slashHelp = "Use /raidlist to open Raidlist or /raidlist options for the settings."
    },

    de = {
        title = "Raidlist",
        subtitle = "Alte Raid-Lockouts für Transmog- und Mount-Runs",

        language = "Sprache",
        raid = "Raid",

        finished = "Abgeschlossen",
        available = "Verfügbar",
        blocked = "Blockiert",
        unavailable = "Nicht verfügbar",

        compartmentTooltip = "Raidlist öffnen",
        compartmentTooltipDescription = "Zeigt deine alten Raid-Lockouts an.",

        slashHelp = "Nutze /raidlist zum Öffnen oder /raidlist options für die Einstellungen."
    }
}


function Raidlist:GetLanguage()
    if not Raidlist.Strings[RaidlistDB.language] then
        RaidlistDB.language = "en"
    end

    return RaidlistDB.language
end


function Raidlist:GetText(key)
    local language = self:GetLanguage()
    local strings = self.Strings[language] or self.Strings.en

    return strings[key] or self.Strings.en[key] or key
end


function Raidlist:SetLanguage(language)
    if not self.Strings[language] then
        return
    end

    RaidlistDB.language = language

    self:RefreshUI()
end


-- ============================================================
-- Saved raid lockouts
-- ============================================================

function Raidlist:RefreshSavedRaids()
    wipe(self.FinishedRaids)

    local savedInstanceCount = GetNumSavedInstances()

    for index = 1, savedInstanceCount do
        local _,
              _,
              _,
              difficultyID,
              locked,
              _,
              _,
              isRaid,
              _,
              _,
              _,
              _,
              _,
              instanceID = GetSavedInstanceInfo(index)

        if locked and isRaid and instanceID then
            self.FinishedRaids[#self.FinishedRaids + 1] = {
                InstanceID = instanceID,
                DifficultyID = difficultyID
            }
        end
    end
end


function Raidlist:GetFinishedDifficulties(instanceID)
    local result = {}

    for _, finishedRaid in ipairs(self.FinishedRaids) do
        if finishedRaid.InstanceID == instanceID then
            result[finishedRaid.DifficultyID] = true
        end
    end

    return result
end


-- ============================================================
-- Raid list data
-- ============================================================

function Raidlist:GetRaidRows()
    local rows = {}
    local language = self:GetLanguage()

    for index, raid in ipairs(self.Raids) do
        local finishedDifficulties =
            self:GetFinishedDifficulties(raid.InstanceID)

        local blockedDifficulties = {}
        local supportedDifficulties = {}

        for _, difficultyID in ipairs(raid.Difficulties) do
            supportedDifficulties[difficultyID] = true
        end

        -- Determine which difficulties are blocked by an
        -- already completed difficulty.
        for difficultyID in pairs(finishedDifficulties) do
            local difficulty =
                self.DifficultyByID[difficultyID]

            if difficulty then
                for _, blockedID in ipairs(difficulty.Blocking) do
                    blockedDifficulties[blockedID] = true
                end
            else
                self.Logger:Error(
                    "Unknown difficulty ID: "
                    .. tostring(difficultyID)
                )
            end
        end

        local row = {
            index = index,
            raidName =
                raid.Names[language]
                or raid.Names.en
                or ("Instance " .. tostring(raid.InstanceID)),

            instanceID = raid.InstanceID,

            statuses = {}
        }

        for _, difficulty in ipairs(self.Difficulties) do
            local difficultyID = difficulty.ID
            local status

            if not supportedDifficulties[difficultyID] then
                status = "unavailable"

            elseif finishedDifficulties[difficultyID] then
                status = "finished"

            elseif blockedDifficulties[difficultyID] then
                status = "blocked"

            else
                status = "available"
            end

            row.statuses[difficultyID] = status
        end

        rows[#rows + 1] = row
    end

    return rows
end


-- ============================================================
-- UI control
-- ============================================================

function Raidlist:RefreshUI()
    if not self.UI then
        return
    end

    self.UI:Refresh()
end


function Raidlist:Toggle()
    if not self.UI then
        return
    end

    if self.UI:IsShown() then
        self.UI:Hide()
        return
    end

    -- Use the currently cached values immediately...
    self:RefreshSavedRaids()
    self:RefreshUI()

    -- ...and request fresh server data afterwards.
    RequestRaidInfo()

    self.UI:Show()
end


-- ============================================================
-- Slash commands
-- ============================================================

SLASH_RAIDLIST1 = "/raidlist"

SlashCmdList["RAIDLIST"] = function(message)
    message = strtrim(string.lower(message or ""))

    if message == "options"
        or message == "option"
        or message == "settings"
    then
        if Raidlist.OpenSettings then
            Raidlist:OpenSettings()
        end

        return
    end

    if message == "help" then
        print(
            "|cff4ea1ff[Raidlist]|r "
            .. Raidlist:GetText("slashHelp")
        )

        return
    end

    Raidlist:Toggle()
end


-- ============================================================
-- Addon Compartment
-- ============================================================

function Raidlist_OnAddonCompartmentClick(_, _)
    Raidlist:Toggle()
end


function Raidlist_OnAddonCompartmentEnter(_, menuButtonFrame)
    GameTooltip:SetOwner(menuButtonFrame, "ANCHOR_LEFT")

    GameTooltip:SetText(
        Raidlist:GetText("compartmentTooltip")
    )

    GameTooltip:AddLine(
        Raidlist:GetText(
            "compartmentTooltipDescription"
        ),
        1,
        1,
        1
    )

    GameTooltip:Show()
end


function Raidlist_OnAddonCompartmentLeave()
    GameTooltip:Hide()
end


-- ============================================================
-- Events
-- ============================================================

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("UPDATE_INSTANCE_INFO")


eventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        Raidlist:RefreshSavedRaids()

        if Raidlist.Logger then
            Raidlist.Logger:InstallErrorHandler()
        end

        RequestRaidInfo()

    elseif event == "UPDATE_INSTANCE_INFO" then
        Raidlist:RefreshSavedRaids()

        if Raidlist.UI
            and Raidlist.UI:IsShown()
        then
            Raidlist:RefreshUI()
        end
    end
end)