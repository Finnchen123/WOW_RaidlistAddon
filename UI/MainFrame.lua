local _, Raidlist = ...

local UI = {}

Raidlist.UI = UI


-- ============================================================
-- Constants
-- ============================================================

local WINDOW_WIDTH = 960
local WINDOW_HEIGHT = 620

local BACKGROUND_COLOR = {
    0.035,
    0.04,
    0.05,
    0.98
}

local BORDER_COLOR = {
    0.20,
    0.23,
    0.28,
    1
}

local HEADER_COLOR = {
    0.065,
    0.075,
    0.09,
    1
}


-- ============================================================
-- Main frame
-- ============================================================

local frame = CreateFrame(
    "Frame",
    "RaidlistMainFrame",
    UIParent,
    "BackdropTemplate"
)

UI.Frame = frame

frame:SetSize(
    WINDOW_WIDTH,
    WINDOW_HEIGHT
)

frame:SetPoint("CENTER")

frame:SetClampedToScreen(true)
frame:SetMovable(true)

frame:SetFrameStrata("DIALOG")

frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1
})

frame:SetBackdropColor(
    unpack(BACKGROUND_COLOR)
)

frame:SetBackdropBorderColor(
    unpack(BORDER_COLOR)
)

frame:Hide()

tinsert(
    UISpecialFrames,
    frame:GetName()
)


-- ============================================================
-- Title bar
-- ============================================================

local titleBar = CreateFrame(
    "Frame",
    nil,
    frame,
    "BackdropTemplate"
)

UI.TitleBar = titleBar

titleBar:SetPoint(
    "TOPLEFT",
    1,
    -1
)

titleBar:SetPoint(
    "TOPRIGHT",
    -1,
    -1
)

titleBar:SetHeight(52)

titleBar:SetBackdrop({
    bgFile =
        "Interface\\Buttons\\WHITE8x8"
})

titleBar:SetBackdropColor(
    unpack(HEADER_COLOR)
)


-- Dragging

titleBar:EnableMouse(true)

titleBar:RegisterForDrag(
    "LeftButton"
)

titleBar:SetScript(
    "OnDragStart",
    function()
        frame:StartMoving()
    end
)

titleBar:SetScript(
    "OnDragStop",
    function()
        frame:StopMovingOrSizing()
    end
)


-- ============================================================
-- Icon
-- ============================================================

local icon = titleBar:CreateTexture(
    nil,
    "ARTWORK"
)

icon:SetSize(
    32,
    32
)

icon:SetPoint(
    "LEFT",
    14,
    0
)

icon:SetTexture(
    "Interface\\Icons\\Achievement_Raid_ClassicRaid_Ragnaros"
)


-- ============================================================
-- Title
-- ============================================================

local title =
    titleBar:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormalLarge"
    )

UI.Title = title

title:SetPoint(
    "TOPLEFT",
    icon,
    "TOPRIGHT",
    10,
    -2
)

title:SetJustifyH("LEFT")


local subtitle =
    titleBar:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontHighlightSmall"
    )

UI.Subtitle = subtitle

subtitle:SetPoint(
    "TOPLEFT",
    title,
    "BOTTOMLEFT",
    0,
    -3
)

subtitle:SetTextColor(
    0.65,
    0.68,
    0.72
)

subtitle:SetJustifyH("LEFT")


-- ============================================================
-- Close button
-- ============================================================

local closeButton = CreateFrame(
    "Button",
    nil,
    titleBar,
    "UIPanelCloseButton"
)

closeButton:SetPoint(
    "TOPRIGHT",
    -5,
    -5
)

closeButton:SetScript(
    "OnClick",
    function()
        frame:Hide()
    end
)


-- ============================================================
-- Toolbar
-- ============================================================

local toolbar = CreateFrame(
    "Frame",
    nil,
    frame
)

UI.Toolbar = toolbar

toolbar:SetPoint(
    "TOPLEFT",
    frame,
    "TOPLEFT",
    16,
    -64
)

toolbar:SetPoint(
    "TOPRIGHT",
    frame,
    "TOPRIGHT",
    -16,
    -64
)

toolbar:SetHeight(34)


-- Language label

local languageLabel =
    toolbar:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

UI.LanguageLabel = languageLabel

languageLabel:SetPoint(
    "LEFT",
    0,
    0
)


-- ============================================================
-- Modern language dropdown
-- ============================================================

local languageDropdown =
    CreateFrame(
        "DropdownButton",
        "RaidlistLanguageDropdown",
        toolbar,
        "WowStyle1DropdownTemplate"
    )

UI.LanguageDropdown =
    languageDropdown

languageDropdown:SetPoint(
    "LEFT",
    languageLabel,
    "RIGHT",
    12,
    0
)

languageDropdown:SetWidth(130)

languageDropdown:SetDefaultText(
    "Language"
)


local languageNames = {
    en = "English",
    de = "Deutsch"
}


languageDropdown:SetupMenu(
    function(_, rootDescription)
        for _, language in ipairs(
            Raidlist.AvailableLanguages
        ) do
            rootDescription:CreateRadio(
                languageNames[language]
                    or language,

                function(value)
                    return Raidlist:GetLanguage()
                        == value
                end,

                function(value)
                    Raidlist:SetLanguage(value)
                end,

                language
            )
        end
    end
)


-- ============================================================
-- Main content area
-- ============================================================

local content = CreateFrame(
    "Frame",
    nil,
    frame
)

UI.Content = content

content:SetPoint(
    "TOPLEFT",
    frame,
    "TOPLEFT",
    16,
    -108
)

content:SetPoint(
    "BOTTOMRIGHT",
    frame,
    "BOTTOMRIGHT",
    -16,
    48
)


-- ============================================================
-- Footer / Legend
-- ============================================================

local footer = CreateFrame(
    "Frame",
    nil,
    frame
)

UI.Footer = footer

footer:SetPoint(
    "BOTTOMLEFT",
    16,
    8
)

footer:SetPoint(
    "BOTTOMRIGHT",
    -16,
    8
)

footer:SetHeight(30)


local legendItems = {}


local function CreateLegendItem(
    index,
    symbol,
    red,
    green,
    blue
)
    local holder =
        CreateFrame(
            "Frame",
            nil,
            footer
        )

    holder:SetSize(
        180,
        24
    )

    if index == 1 then
        holder:SetPoint(
            "LEFT",
            0,
            0
        )
    else
        holder:SetPoint(
            "LEFT",
            legendItems[index - 1].Holder,
            "RIGHT",
            10,
            0
        )
    end

    local symbolText =
        holder:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalLarge"
        )

    symbolText:SetPoint(
        "LEFT",
        0,
        0
    )

    symbolText:SetText(symbol)

    symbolText:SetTextColor(
        red,
        green,
        blue
    )

    local description =
        holder:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlightSmall"
        )

    description:SetPoint(
        "LEFT",
        symbolText,
        "RIGHT",
        6,
        0
    )

    legendItems[index] = {
        Holder = holder,
        Text = description
    }

    return legendItems[index]
end


UI.LegendFinished =
    CreateLegendItem(
        1,
        "●",
        0.25,
        0.90,
        0.40
    )

UI.LegendAvailable =
    CreateLegendItem(
        2,
        "●",
        0.95,
        0.30,
        0.30
    )

UI.LegendBlocked =
    CreateLegendItem(
        3,
        "●",
        0.25,
        0.60,
        1.00
    )

UI.LegendUnavailable =
    CreateLegendItem(
        4,
        "–",
        0.45,
        0.48,
        0.52
    )


-- ============================================================
-- Public UI functions
-- ============================================================

function UI:IsShown()
    return frame:IsShown()
end


function UI:Show()
    frame:Show()
end


function UI:Hide()
    frame:Hide()
end


function UI:RefreshLocalization()
    self.Title:SetText(
        Raidlist:GetText("title")
    )

    self.Subtitle:SetText(
        Raidlist:GetText("subtitle")
    )

    self.LanguageLabel:SetText(
        Raidlist:GetText("language")
    )

    self.LegendFinished.Text:SetText(
        Raidlist:GetText("finished")
    )

    self.LegendAvailable.Text:SetText(
        Raidlist:GetText("available")
    )

    self.LegendBlocked.Text:SetText(
        Raidlist:GetText("blocked")
    )

    self.LegendUnavailable.Text:SetText(
        Raidlist:GetText("unavailable")
    )

    if self.RefreshHeaders then
        self:RefreshHeaders()
    end
end


function UI:Refresh()
    self:RefreshLocalization()

    if self.RefreshRaidList then
        self:RefreshRaidList(
            Raidlist:GetRaidRows()
        )
    end
end


frame:SetScript(
    "OnShow",
    function()
        Raidlist:RefreshSavedRaids()
        UI:Refresh()

        RequestRaidInfo()
    end
)