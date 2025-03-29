DisplayFrame = CreateFrame("Frame", "Raidlist_DisplayFrame", UIParent, "BasicFrameTemplateWithInset")
tinsert(UISpecialFrames, DisplayFrame:GetName())

DisplayFrame:SetSize(600, 400)
DisplayFrame:SetPoint("CENTER")
DisplayFrame:SetMovable(true)
DisplayFrame:SetResizable(true)

local dragBar = CreateFrame("Frame", nil, DisplayFrame, "PanelDragBarTemplate")
dragBar:SetHeight(32)
dragBar:SetPoint("TOPLEFT")
dragBar:SetPoint("TOPRIGHT")

local resizeButton = CreateFrame("Button", nil, DisplayFrame, "PanelResizeButtonTemplate")
resizeButton:SetPoint("BOTTOMRIGHT", -4, 4)

local minimumWidth = 200
local minimumHeight = 200
resizeButton:Init(DisplayFrame, minimumWidth, minimumHeight)

DisplayFrame:RegisterEvent("UPDATE_INSTANCE_INFO")

DisplayFrame:SetScript("OnEvent", function(self, event, ...)
    if (event == "UPDATE_INSTANCE_INFO") then
        local raidAmount = GetNumSavedInstances()
        for i = 1, raidAmount, 1 do
            local name, id, reset, difficulty, locked, extended, instanceIDMostSig,
            isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress, extendDisables, instanceId
            = GetSavedInstanceInfo(i)
            if(locked) then
                FinishedRaids[i] = {
                    InstanceID = instanceId,
                    difficulty = difficulty
                }
            end
        end
    end
end)

DisplayFrame.TitleBg:SetHeight(30)
DisplayFrame.title = DisplayFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
DisplayFrame.title:SetPoint("TOPLEFT", DisplayFrame.TitleBg, "TOPLEFT", 5, -3)
DisplayFrame.title:SetText("Raidlist Addon")
DisplayFrame.Text = DisplayFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
DisplayFrame.Text:SetPoint("CENTER")
DisplayFrame.Text:SetJustifyH("LEFT")
DisplayFrame.Text:SetJustifyV("TOP")
DisplayFrame:Hide()